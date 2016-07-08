{afterEach, beforeEach, describe, it} = global
{expect} = require 'chai'

request   = require 'request'
fakeredis = require 'fakeredis'
_         = require 'lodash'
uuid      = require 'uuid'

Server  = require '../../src/server'

describe 'Log HTTP Request', ->
  beforeEach (done) ->
    clientId = uuid.v1()
    client   = fakeredis.createClient clientId
    @client  = fakeredis.createClient clientId

    serverOptions =
      port: undefined,
      disableLogging: true
      client: client
      jobLogQueue: 'sample-log'

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

    it 'should push a job into the client', (done) ->
      @client.lpop 'sample-log', (error, entryJSON) =>
        return done error if error?
        entry = JSON.parse entryJSON

        expect(entry.index).to.satisfy (index) => _.startsWith(index, 'metrics-log-http-request:log-')
        expect(entry).to.containSubset {
          type: 'http'
          body:
            request:
              metadata:
                jobType: 'GET'
                fromUuid: 'some-uuid'
            response:
              metadata:
                code: 204
        }
        done()

      expect()
