require! {
  _: \underscore.string
  './helper'.random-int
  './helper'.deep-clone-array
}

class Map
  (@options = {}) ~>
    @height = @options.height
    if not @height?
      throw new Error 'Must provide `height`!'

    @width = @options.width
    if not @width?
      throw new Error 'Must provide `width`!'

    @map = @options.map
    if not @map?
      throw new Error 'Must provide `map`!'

    if @height * @width isnt @map.length
      throw new Error 'height and width do not match the map string'

    @battlefield = _.chop @map, @width
    wall = _.repeat \#, @width
    @battlefield.push wall
    @battlefield.unshift wall
    @battlefield = @battlefield.map (line) ->
      line = line.split('')
      line.push(\#)
      line.unshift(\#)
      line

    @real-map = deep-clone-array @battlefield

    @_add-snakes!
    @_add-foods!

  get: ([x, y]) ~>
    @real-map[y][x]

  set: ([x, y], value) ~>
    @real-map[y][x] = value

  get-random-space: ~>
    [x, y] = [0, 0]
    while @get([x, y]) isnt \.
      x = random-int @width
      y = random-int @height

    [x, y]

  _add-snakes: ~>
    if @options.snakes?
      for snake in @options.snakes
        for pos in snake.position
          @set pos, 'S'

  _add-foods: ~>
    if @options.foods?
      for food in @options.foods
        @set food, 'F'

exports = module.exports = Map
