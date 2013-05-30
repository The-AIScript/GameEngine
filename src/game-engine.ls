require! {
  fs
  path
  events.EventEmitter

  async
  zmq
}
class GameEngine extends EventEmitter
  (@options) ~>

  init: (callback) ~>
    async.waterfall [
      @_load-map,
      (callback) ~>
        # game-related configs
        default-config =
          snake: @map-info.\max-snake
          food: @map-info.\max-snake
        default-config <<< @options

        @game-info = {}
        @game-info{snake, food} = default-config

        err = null
        if @game-info.snake > @map-info.\max-snake or @game-info.snake < 2
          err = new Error "`snake` is out of range"
        callback err
      , (callback) ~>
        # engine-related configs
        @resource = @options.resource
        if not @resource
          callback new Error 'Must provide socket `resource`!'
        else callback null
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
      @map-info = JSON.parse results[1].to-string!
      @map-info.map = results[0].to-string!.replace(/\n/g, '')
      callback null

  _bind: (callback) ~>
    @socket = zmq.socket 'pub'
    @socket.bind @resource, callback

  send: (data) ~>
    @socket.send data

  close: ~>
    @socket.close!

exports = module.exports = GameEngine
