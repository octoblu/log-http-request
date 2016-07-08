class LogHttpRequestService
  constructor: ({@jobLogger}) ->
    throw new Error 'missing required param: jobLogger' unless @jobLogger?

  log: ({uuid}, callback) =>
    @jobLogger.log @formatMessage({uuid}), callback

  formatMessage: ({uuid}) =>
    return {
      request:
        metadata:
          fromUuid: uuid
          jobType: 'GET'
      response:
        metadata:
          jobLogs: ['log']
          code: 204
          success: true
    }


module.exports = LogHttpRequestService
