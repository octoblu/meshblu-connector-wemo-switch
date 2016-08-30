_              = require 'lodash'
{EventEmitter} = require 'events'
WemoClient     = require '@octoblu/wemo-client'
debug           = require('debug')('meshblu-connector-wemo-switch:wemo-manager')

class WemoManager extends EventEmitter
  constructor: ->
    @_emit = _.throttle @emit, 500, {leading: true, trailing: false}
    @wemo = new WemoClient
    @client = null

  discover: ({wemoName, autoDiscover, desiredState}, callback) =>
    return @_updateState(desiredState, callback) if wemoName == @wemoName && autoDiscover == @autoDiscover && @client?
    { @wemoName, @autoDiscover } = { wemoName, autoDiscover }
    @client = null
    @discovering = true
    debug 'discovering...'
    @wemo.discover @_onDiscover, (error) =>
      @_updateState desiredState
    callback()

  isOnline: (callback) =>
    return callback null, running: !!@client

  _onDiscover: (device, callback=_.noop) =>
    unless device?
      debug 'missing device'
      return callback new Error 'missing device'
    { deviceType } = device
    {Switch, Insight} = WemoClient.DEVICE_TYPE
    if !_.includes [Switch, Insight], deviceType
      debug 'invalid device type', deviceType
      return callback new Error "invalid device type: #{deviceType}"
    if !@autoDiscover && device.friendlyName != @wemoName
      friendlyName = JSON.stringify(device.friendlyName)
      wemoName = JSON.stringify(@wemoName)
      debug('name doesn\'t match', JSON.stringify(device.friendlyName), JSON.stringify(@wemoName))
      return callback new Error "name doesn't match: #{friendlyName} #{wemoName}",
    @discovering = false
    debug 'discovered', device.friendlyName
    @client = @wemo.client device
    @client.on 'binaryState', (state) =>
      console.log 'binaryState', {state}
      @_emit 'update', on: state
    callback()

  _emitConnected: =>
    @emit 'connected'

  _updateState: (state, callback=_.noop) =>
    return callback new Error 'No current WeMo connection' unless @client?
    @client.setBinaryState state.on, (error) =>
      return callback error if error?
      @_emit 'update', desiredState: null
      callback()

module.exports = WemoManager
