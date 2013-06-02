require! {
  events.EventEmitter

  zmq
  async
  msgpack
}

class AIEngine extends EventEmitter
  (@options = {}) ~>

  init: (callback) ~>
    async.series [
      @_load-config
      @_connect
    ], callback

  _load-config: (callback) ~>
    @resource = @options.resource
    @id = @options.id
    @strategy = @options.strategy

    if not @resource
      callback new Error 'Must provide socket `resource`!'
    else if not @id?
      callback new Error "Must provide engine's `id`!"
    else if not (@strategy? and typeof! @strategy is \Function)
      callback new Error "Must ptovide engine's `strategy`!"
    else
      callback null

  _connect: (callback) ~>
    @subscriber = zmq.socket 'sub'
    @subscriber.connect @resource.pub
    @subscriber.subscribe ''
    @requestor = zmq.socket 'req'
    @requestor.connect @resource.rep
    @requestor.send \ACK

    @subscriber.on 'message', (data) ~>
      @_execute-ai msgpack.unpack(data)

    callback null

  _execute-ai: (@data) ~>
    (err) <~ @strategy @
    @emit 'finish'

  close: ~>
    @subscriber.close!
    @requestor.close!

exports = module.exports = AIEngine
