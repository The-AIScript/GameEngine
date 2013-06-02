require! {
  fs
  path
  events.EventEmitter

  async
  zmq
  msgpack

  AIEngine: \./ai-engine
}
class GameEngine extends EventEmitter
  (@options = {}) ~>

  init: (callback) ~>
    async.series [
      @_load-config
      @_init-game
      @_bind
      @_init-ai
    ], callback

  _load-config: (callback) ~>
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

  _init-game: (callback) ~>
    # TODO: hard coded snake game here
    Game = require \../game/snake
    @game = Game @options, this
    @game.init callback

  _bind: (callback) ~>
    @connection-count = 0
    @publisher = zmq.socket 'pub'
    @replier = zmq.socket 'rep'
    async.parallel [
      @_bind-publisher
      @_bind-replier
    ], callback

  _init-ai: (callback) ~>
    @ai-engines = []
    async.map [0 til @game.config.snake], (index, callback) ~>
      ai-engine = AIEngine do
        resource: @config.resource
        id: index
        strategy: @options.strategies[index]
      @ai-engines[index] = ai-engine
      ai-engine.init callback
    , callback

  send: (data) ~>
    @publisher.send msgpack.pack(data)

  close: ~>
    @publisher.close!
    @replier.close!
    if @ai-engines?
      for ai in @ai-engines
        ai.close!

  # handler
  _replier-handler: (data) ~>
    if data.to-string! is \ACK
      @replier.send \OK
      @emit 'connected:one'
      ++@connection-count
      if @connection-count is @game.config.snake
        @emit 'connected:all'

  # helper
  _bind-publisher: (callback) ~>
    @publisher.bind @config.resource.pub, callback

  _bind-replier: (callback) ~>
    async.series [
      (callback) ~>
        @replier.bind @config.resource.rep, callback
      , (callback) ~>
        @replier.on \message, @_replier-handler
        callback null
    ], callback

exports = module.exports = GameEngine
