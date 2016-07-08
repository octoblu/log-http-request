LogHttpRequestController = require './controllers/log-http-request-controller'

class Router
  constructor: ({@logHttpRequestService}) ->

  route: (app) =>
    logHttpRequestController = new LogHttpRequestController {@logHttpRequestService}

    app.get '/:uuid', logHttpRequestController.log

module.exports = Router
