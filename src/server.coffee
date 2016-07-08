cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
packageVersion     = require 'express-package-version'
sendError          = require 'express-send-error'
JobLogger          = require 'job-logger'

Router                = require './router'
LogHttpRequestService = require './services/log-http-request-service'

class Server
  constructor: ({@disableLogging, @port, client, jobLogQueue})->
    @jobLogger = new JobLogger {client, jobLogQueue, indexPrefix: 'metrics-log-http-request', type: 'http'}

  address: =>
    @server.address()

  run: (callback) =>
    app = express()
    app.use cors()
    app.use errorHandler()
    app.use meshbluHealthcheck()
    app.use packageVersion()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use sendError()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'

    app.options '*', cors()

    logHttpRequestService = new LogHttpRequestService {@jobLogger}
    router = new Router {logHttpRequestService}

    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
