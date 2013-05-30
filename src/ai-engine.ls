require! {
  events.EventEmitter

  zmq
}

class AIEngine extends EventEmitter
  (@options = {}) ~>

  init: (callback) ~>
    @resource = @options.resource
    @id = @options.id
    if not @resource
      callback new Error 'Must provide socket `resource`!'
    else if not @id?
      callback new Error "Must provide engine's `id`!"
    else
      callback null

  subscribe: ~>
    @socket = zmq.socket 'sub'
    @socket.connect @resource
    @socket.subscribe ''

    @socket.on 'message', (data) ~>
      @ai data

  ai: (@data) ~>
    @emit 'finish'

  close: ~>
    @socket.close!

exports = module.exports = AIEngine
