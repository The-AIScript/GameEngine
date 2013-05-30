require! {
  events.EventEmitter

  zmq
}

class AIEngine extends EventEmitter
  (@options = {}) ~>

  init: (callback) ~>
    async.series [@_load-config, @_subscribe], callback

  _subscribe: (callback) ~>
    @subscriber = zmq.socket 'sub'
    @subscriber.connect @resource.pub
    @subscriber.subscribe ''
    @requestor = zmq.socket 'req'
    @requestor.connect @resource.rep
    @requestor.send \ACK

    @subscriber.on 'message', (data) ~>
      @_execute-ai data

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

  _execute-ai: (@data) ~>
    @emit 'finish'

  close: ~>
    @subscriber.close!
    @requestor.close!

exports = module.exports = AIEngine
