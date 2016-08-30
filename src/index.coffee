_               = require 'lodash'
{EventEmitter}  = require 'events'
debug           = require('debug')('meshblu-connector-wemo:index')
WemoManager     = require './wemo-manager'

class Connector extends EventEmitter
  constructor: ->
    @wemo = new WemoManager

  isOnline: (callback) =>
    @wemo.isOnline (error, {running}) =>
      return callback error if error?
      callback null, {running}

  close: (callback) =>
    debug 'on close'
    callback()

  onConfig: (device={}, callback=->) =>
    { @options } = device
    debug 'on config', @options
    { @wemoName, @autoDiscover } = @options ? {}
    @wemo.discover {@wemoName, @autoDiscover}, callback

  start: (device, callback) =>
    debug 'started'
    @onConfig device, callback

  turnOff: (callback) =>
    @wemo.turnOff callback

  turnOn: (callback) =>
    @wemo.turnOn callback

module.exports = Connector
