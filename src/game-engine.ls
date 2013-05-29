require! {
  fs
  path

  async
}
class GameEngine
  (options, callback) ->
    {@map} = options

  start: (callback) ->
    async.waterfall [
      (callback) ~>
        p = path.join __dirname, "../map/#{@map}."
        map-path = p + \map
        info-path = p + \json
        async.map [map-path, info-path], fs.read-file, callback
      (results, callback) ~>
        @map = results[0].to-string!.replace(/\n/g, '')
        @map-info = JSON.parse results[1].to-string!
        callback null
    ], callback

exports = module.exports = GameEngine
