require! {
  fs
  path
  events.EventEmitter

  async
  './helper'.map-string-to-array
}
class SnakeGame extends EventEmitter
  (@options) ~>

  init: (callback) ~>
    async.series [
      @_load-map
      @_load-config
      @_setup
    ], callback

  _load-map: (callback) ~>
    {map} = @options
    p = path.join __dirname, "../map/#map."
    map-path = p + \map
    data-path = p + \json
    (err, results) <~ async.map [map-path, data-path], fs.read-file
    if err
      callback err
    else
      @map = JSON.parse results[1].to-string!
      @map.string = results[0].to-string!.replace(/\n/g, '')
      @map.array = map-string-to-array @map
      callback null

exports = module.exports = SnakeGame
