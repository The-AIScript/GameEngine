require! {
  should
  _: \underscore.string
}

# mappings
exports.map-mapping =
  SPACE: \.
  WALL: \#

exports.direction-mapping =
  0: [0 -1]
  1: [1 0]
  2: [0 1]
  3: [-1 0]

# helpers
exports.map-string-to-array = (map-data) ->
  {height, width, string} = map-data
  if height * width isnt string.length
    throw new Error '`height` and `width` do not match the string'
  map-array = _.chop string, width
  wall = _.repeat \#, width + 2
  map-array = map-array.map (line) ->
    \# + line + \#
  map-array.push wall
  map-array.unshift wall
  map-array

exports.random-int = (max, min = 1) ->
  Math.floor(Math.random! * (max - min + 1)) + min

