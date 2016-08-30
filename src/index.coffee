_               = require 'lodash'
{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-wemo:index')
WemoManager     = require './wemo-manager'

class Connector extends EventEmitter
  constructor: ->
    @wemo = new WemoManager
    @wemo.on 'update', (data) =>
      @emit 'update', data

  isOnline: (callback) =>
    @wemo.isOnline (error, {running}) =>
      return callback error if error?
      callback null, {running}

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}, callback=->) =>
    { @options, desiredState } = device
    debug 'on config', @options
    { @wemoName, @autoDiscover } = @options ? {}
    @wemo.discover {@wemoName, @autoDiscover, desiredState}, callback

  start: (device, callback) =>
    debug 'started'
    @onConfig device, callback

module.exports = Connector
