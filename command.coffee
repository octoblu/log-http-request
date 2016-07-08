Redis  = require 'ioredis'
Server = require './src/server'

class Command
  constructor: ->
    throw new Error 'Missing required environment: JOB_LOGGER_QUEUE' unless process.env.JOB_LOGGER_QUEUE

    @client         = new Redis(process.env.JOB_LOGGER_REDIS_URI || 'redis://localhost:6379')
    @disableLogging = process.env.DISABLE_LOGGING == 'true'
    @jobLogQueue    = process.env.JOB_LOGGER_QUEUE
    @port           = process.env.PORT || 80

    process.on 'SIGINT', @_onSIGINT
    process.on 'SIGTERM', @_onSIGTERM
    @client.on 'error', @fatal

  fatal: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    @server = new Server {@client, @disableLogging, @jobLogQueue, @port}
    @server.run (error) =>
      return @fatal error if error?

      {address, port} = @server.address()
      console.log "Server listening on #{address}:#{port}"


  stop: =>
    process.exit 0 unless @server?

    @server.stop (error) =>
      return @fatal @error if error?
      process.exit 0

    setTimeout @_onStopTimeout, 10 * 1000

  _onSIGINT: =>
    console.log "SIGINT caught, stopping"
    @stop()

  _onSIGTERM: =>
    console.log "SIGTERM caught, stopping"
    @stop()

  _onStopTimeout: =>
    console.error 'server.stop took too long, forcing exit'
    process.exit 1

command = new Command()
command.run()
