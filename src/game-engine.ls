require! {
  fs
  path

  async
}
class GameEngine
  (@options) ->

  start: (callback) ->
    @_load-map callback

  _load-map: (callback) ->
    {map} = @options
    p = path.join __dirname, "../map/#map."
    map-path = p + \map
    info-path = p + \json
    (err, results) <~ async.map [map-path, info-path], fs.read-file
    if err
      callback err
    else
      @map = results[0].to-string!.replace(/\n/g, '')
      @map-info = JSON.parse results[1].to-string!
      callback null

exports = module.exports = GameEngine
