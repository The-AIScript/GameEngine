require! {
  _s: \underscore.string
  _: \underscore
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

    @battlefield = _s.chop @map, @width
    wall = _s.repeat \#, @width
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
    if typeof! x isnt \Number or typeof! y isnt \Number
      throw new Error 'Coordinate must be number!'
    @real-map[y][x]

  set: ([x, y], value) ~>
    if typeof! x isnt \Number or typeof! y isnt \Number
      throw new Error 'Coordinate must be number!'
    @real-map[y][x] = value

  get-random-space: (exclude-list = []) ~>
    [x, y] = [0, 0]
    while @get([x, y]) isnt \. or @_inside-array [x, y], exclude-list
      x = random-int @width
      y = random-int @height

    [x, y]

  to-string: (source = @battlefield) ~>
    lines = source.slice 1, source.length - 1
    lines = lines.map (line) ~>
      line.slice(1, line.length - 1).join ''
    lines.join ''

  _add-snakes: ~>
    if @options.snakes?
      for snake in @options.snakes
        for pos in snake.position
          @set pos, 'S'

  _add-foods: ~>
    if @options.foods?
      for food in @options.foods
        @set food, 'F'

  _inside-array: ([x, y], exclude-list) ~>
    bool = false
    for i in exclude-list
      if _.is-equal [x, y], i
        bool = true

    bool

exports = module.exports = Map
