Server        = require './src/server'

class Command
  constructor: ->
    @serverOptions =
      port:           process.env.PORT || 80
      disableLogging: process.DISABLE_LOGGING == 'true'

  fatal: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    @server = new Server @serverOptions
    @server.run (error) =>
      return @fatal error if error?

      {address, port} = @server.address()
      console.log "Server listening on #{address}:#{port}"

    process.on 'SIGINT', @_onSIGINT
    process.on 'SIGTERM', @_onSIGTERM

  stop: =>
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
