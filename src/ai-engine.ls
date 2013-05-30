require! {
  events.EventEmitter

  zmq
}

class AIEngine extends EventEmitter
  (@options = {}) ~>

  init: (callback) ~>
    async.series [@_load-config, @_subscribe], callback

  _subscribe: (callback) ~>
    @socket = zmq.socket 'sub'
    @socket.connect @resource
    @socket.subscribe ''

    @socket.on 'message', (data) ~>
      @_ai data

    callback null

  _load-config: (callback) ~>
    @resource = @options.resource
    @id = @options.id
    if not @resource
      callback new Error 'Must provide socket `resource`!'
    else if not @id?
      callback new Error "Must provide engine's `id`!"
    else
      callback null

  _ai: (@data) ~>
    @emit 'finish'

  close: ~>
    @socket.close!

exports = module.exports = AIEngine
