require! {
  fs
  path
  events.EventEmitter

  async
  './helper'.map-string-to-array
  './helper'.random-int
  './helper'.direction-mapping
}
class SnakeGame extends EventEmitter
  (@options = {}, @engine) ~>

  init: (callback) ~>
    async.series [
      @_load-map
      @_load-config
      @_setup
    ], callback

  _load-map: (callback) ~>
    {map} = @options
    if not map?
      callback new Error "Must provide map file!"
    else
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

  _load-config: (callback) ~>
    async.series [
      (callback) ~>
        if @map?
          callback null
        else
          @_load-map callback
      , (callback) ~>
        if @engine?
          callback null
        else
          callback new Error 'Must provide game-engine!'
      , (callback) ~>
        default-config =
          snake: @map.\max-snake
          food: @map.\max-snake
        default-config <<< @options

        @config = {}
        @config{snake, food} = default-config

        if @config.snake > @map.\max-snake or @config.snake < 2
          callback new Error "`snake` is out of range"
        else
          callback null
    ], callback

  _setup: (callback) ~>
    @round = 0
    @snakes = []
    @foods = []
    for i from 0 til @config.snake
      snake = {}
      snake.position = [@_get-random-space!]
      snake.heading = direction-mapping[random-int(4) - 1]
      snake.id = i
      @snakes.push snake

    for i from 1 to @config.food
      @foods.push @_get-random-space!

    @engine.on \connected:all, @_on-connected-handler

    callback null

  _get-full-data: ~>
    data = {}
    data <<< @config
    data <<< @map
    data.map = data.string
    data.round = @round
    delete data.array
    delete data.string
    data{snakes, foods} = @
    data

  # handler
  _on-connected-handler: ~>
    @engine.send @_get-full-data!

  # helper
  _get-random-space: ~>
    [x, y] = [0, 0]
    while @map.array[y][x] isnt \.
      x = random-int @map.width
      y = random-int @map.height
    [x, y]

exports = module.exports = SnakeGame
