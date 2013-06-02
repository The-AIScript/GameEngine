require! {
  fs
  path
  events.EventEmitter

  async
  './helper'.random-int
  './helper'.direction-mapping
  Map: \./map
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
        @config = JSON.parse results[1].to-string!
        @config.map = results[0].to-string!.replace(/\n/g, '')
        @map = Map @config
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
        config =
          # default
          snake: @config.\max-snake
          food: @config.\max-snake
        config <<< @options

        @config{snake, food} = config

        if @config.snake > @config.\max-snake or @config.snake < 2
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
      birth-position = @map.get-random-space!
      snake.position = [birth-position]
      @map.set birth-position, \S
      snake.heading = direction-mapping[random-int(4) - 1]
      snake.id = i
      @snakes.push snake

    for i from 1 to @config.food
      pos = @map.get-random-space!
      @foods.push pos
      @map.set pos, \F

    @engine.on \connected:all, @_on-connected-handler

    callback null

  _get-full-data: ~>
    data = {}
    data <<< @config
    data.round = @round
    data{snakes, foods} = @
    data

  # handler
  _on-connected-handler: ~>
    @engine.send @_get-full-data!

exports = module.exports = SnakeGame
