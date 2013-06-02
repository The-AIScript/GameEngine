require! {
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
exports.random-int = (max, min = 1) ->
  Math.floor(Math.random! * (max - min + 1)) + min

deep-clone-array = exports.deep-clone-array = (array) ->
  if typeof! array is \Array
    result = []
    for i from 0 til array.length
      result.push deep-clone-array array[i]
    result
  else
    array


