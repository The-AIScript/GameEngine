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
  (@options) ~>

  init: (callback) ~>
    async.series [
      @_load-map
      @_load-game-config
      @_load-engine-config
      @_bind
    ], callback

  _load-map: (callback) ~>
    {map} = @options
    p = path.join __dirname, "../map/#map."
    map-path = p + \map
    info-path = p + \json
    (err, results) <~ async.map [map-path, info-path], fs.read-file
    if err
      callback err
    else
      @game-info = {}
      @game-info.map-info = JSON.parse results[1].to-string!
      @game-info.map-info.map-data = results[0].to-string!.replace(/\n/g, '')
      @game-info.map-info.map = map-string-to-array @game-info.map-info
      callback null

  _load-game-config: (callback) ~>
    # depends on #_load-map()
    default-config =
      snake: @game-info.map-info.\max-snake
      food: @game-info.map-info.\max-snake
    default-config <<< @options

    @game-info{snake, food} = default-config

    if @game-info.snake > @game-info.map-info.\max-snake or @game-info.snake < 2
      callback new Error "`snake` is out of range"
    else
      callback null

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
                if @connect-count is @game-info.snake
                  @emit 'connected:all'

            callback null
        ], callback
    ], callback

  _start-ai-engine: (callback) ~>
    @ai-engines = []
    async.map [0 til @game-info.snake], (index, callback) ~>
      ai-engine = AIEngine do
        resource: @config.resource
        id: index
      @ai-engines[index] = ai-engine
      ai-engine.init callback
    , callback

  send: (data) ~>
    @publisher.send data

  close: ~>
    @publisher.close!
    @replier.close!

exports = module.exports = GameEngine
