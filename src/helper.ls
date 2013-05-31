require! {
  should
  _: \underscore.string
}


# helpers
exports.map-string-to-array = (map-info) ->
  {height, width, map-data} = map-info
  map = _.chop map-data, width
  wall = _.repeat \#, width + 2
  map = map.map (line) ->
    \# + line + \#
  map.push wall
  map.unshift wall
  map

exports.random-int = (max, min = 1) ->
  Math.floor(Math.random! * (max - min + 1)) + min

exports.async-error-throw = (err, error-message, no-error-message = "No error founded!") ->
  should.exist err, no-error-message
  err.should.be.an.instanceof Error
  err.message.should.equal error-message
