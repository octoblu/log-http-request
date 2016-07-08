{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'

request       = require 'request'

Server  = require '../../src/server'

describe 'Hello', ->
  beforeEach (done) ->
    serverOptions =
      port: undefined,
      disableLogging: true

    @server = new Server serverOptions
    @server.run =>
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  describe 'On GET /some-uuid', ->
    beforeEach (done) ->
      request.get "http://localhost:#{@serverPort}/some-uuid", (error, @response, @body) => done error

    it 'should return a 204', ->
      expect(@response.statusCode).to.equal 204
