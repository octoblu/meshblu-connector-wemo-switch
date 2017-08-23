{beforeEach, context, describe, it} = global
{expect} = require 'chai'
sinon = require 'sinon'

UUID = require 'uuid'
WemoClient = require 'wemo-client'
WemoManager = require '../src/wemo-manager'
{EventEmitter} = require 'events'

describe 'WemoManager', ->
  beforeEach ->
    @sut = new WemoManager
    {@wemo} = @sut
    @wemo.discover = sinon.stub()
    @wemo.client = sinon.stub()

  describe '->isOnline', ->
    context 'when there is a client', ->
      beforeEach ->
        @sut.client = {}

      it 'should be online', (done) ->
        @sut.isOnline (error, {running}) =>
          return done error if error?
          expect(running).to.be.true
          done()

    context 'when there is no client', ->
      beforeEach ->
        @sut.client = null

      it 'should be offline', (done) ->
        @sut.isOnline (error, {running}) =>
          return done error if error?
          expect(running).to.be.false
          done()

  describe '->discover', ->
    context 'when looking for a client', ->
      context 'when there is no client', ->
        beforeEach (done) ->
          wemoName = 'foo'
          autoDiscover = false
          @sut.discover {wemoName, autoDiscover}, done

        it 'should start discovering', ->
          expect(@sut.discovering).to.be.true

        it 'should call wemo.discover', ->
          expect(@wemo.discover).to.have.been.called

        context 'when the correct client has been discovered', ->
          beforeEach (done) ->
            @client = new EventEmitter
            @wemo.client.returns @client
            device =
              deviceType: WemoClient.DEVICE_TYPE.Switch
              friendlyName: 'foo'
            @sut._onDiscover device, done

          it 'should stop discovering', ->
            expect(@sut.discovering).to.be.false

          it 'should create a client', ->
            expect(@sut.client).to.deep.equal @client

    context 'when auto discovering', ->
      context 'when there is no client', ->
        beforeEach (done) ->
          wemoName = null
          autoDiscover = true
          @sut.discover {wemoName, autoDiscover}, done

        it 'should start discovering', ->
          expect(@sut.discovering).to.be.true

        it 'should call wemo.discover', ->
          expect(@wemo.discover).to.have.been.called

        context 'when the correct client has been discovered', ->
          beforeEach (done) ->
            @client = new EventEmitter
            @wemo.client.returns @client
            device =
              deviceType: WemoClient.DEVICE_TYPE.Switch
              friendlyName: UUID.v4()
            @sut._onDiscover device, done

          it 'should stop discovering', ->
            expect(@sut.discovering).to.be.false

          it 'should create a client', ->
            expect(@sut.client).to.deep.equal @client
