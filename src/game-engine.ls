require! {
  fs
  path

  async
}
class GameEngine
  (@options) ~>

  init: (callback) ~>
    async.waterfall [
      @_load-map,
      (callback) ~>
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

exports = module.exports = GameEngine
