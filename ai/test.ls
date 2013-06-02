require! {
  '../game/helper'.map-data-to-array
  '../game/helper'.direction-mapping
  Map: \../game/map
}
exports = module.exports = (config, callback) ->
  logic = AILogic config
  logic.run callback

class AILogic
  (@options = {}) ~>
    @map = Map @options.data
    {@position, @heading} = @options.data.snakes[@options.id]
    @head = @position[0]
    @foods = @options.data.foods
    @back-direction = (@heading + 2) % 4

  run: (callback) ~>
    operation = -1
    min-distance = Infinity
    for i from 0 to 3
      try-position = [direction-mapping[i][0] + @head[0], direction-mapping[i][1] + @head[1]]
      if i isnt @back-direction and @map.get(try-position) is \.
        distance = Math.min.apply @, @_get-food-distance try-position
        if distance < min-distance
          min-distance = distance
          operation = i

    if operation = -1
      operation = @heading
    callback null, operation

  _get-food-distance: (position = @head) ~>
    distance = []
    for i from 0 til @foods.length
      distance.push Math.abs(position[0] - @foods[i][0]) + Math.abs(position[1] - @foods[i][1])
    distance
