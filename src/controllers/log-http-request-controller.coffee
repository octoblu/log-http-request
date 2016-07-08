class LogHttpRequestController
  constructor: ({@logHttpRequestService}) ->

  log: (request, response) =>
    {uuid} = request.params

    @logHttpRequestService.log {uuid}, (error) =>
      return response.sendError error if error?
      response.sendStatus 204

module.exports = LogHttpRequestController
