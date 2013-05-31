require! {
  fs
  path
  events.EventEmitter

  async
  zmq

  AIEngine: \./ai-engine
  './helper'.map-string-to-array
}
class GameEngine extends EventEmitter
  (@options = {}) ~>

  init: (callback) ~>
    async.series [
      @_load-engine-config
      @_bind
      @_start-ai-engine
    ], callback

  _init-game: (callback) ~>
    # TODO: hard coded snake game here
    Game = require \../game/snake
    @game = Game @options
    @game.init callback

  _load-engine-config: (callback) ~>
    @config = {}
    @config.resource = @options.resource
    if not @config.resource or typeof! @config.resource isnt \Object
      callback new Error 'Must provide socket `resource`!'
    else
      {pub, rep} = @config.resource
      if pub? and rep?
        callback null
      else
        callback new Error '`resource` should include `pub` and `rep`!'

  _bind: (callback) ~>
    @publisher = zmq.socket 'pub'
    @replier = zmq.socket 'rep'
    async.parallel [
      (callback) ~>
        @publisher.bind @config.resource.pub, callback
      , (callback) ~>
        async.series [
          (callback) ~>
            @replier.bind @config.resource.rep, callback
          , (callback) ~>
            @connect-count = 0
            @replier.on \message, (data) ~>
              if data.to-string! is \ACK
                @replier.send \OK
                @emit 'connected:one'
                ++@connect-count
                if @connect-count is @game.config.snake
                  @emit 'connected:all'

            callback null
        ], callback
    ], callback

  _start-ai-engine: (callback) ~>
    @ai-engines = []
    async.map [0 til @game.config.snake], (index, callback) ~>
      ai-engine = AIEngine do
        resource: @config.resource
        id: index
      @ai-engines[index] = ai-engine
      ai-engine.init callback
    , callback

  _send: (data) ~>
    @publisher.send data

  close: ~>
    @publisher.close!
    @replier.close!

exports = module.exports = GameEngine
