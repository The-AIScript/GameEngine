require! {
  fs
  path
  events.EventEmitter

  async
  _: underscore

  './helper'.random-int
  './helper'.direction-mapping
  Map: \./map
}
class SnakeGame extends EventEmitter
  (@options = {}, @engine) ~>

  init: (callback) ~>
    @operations = []
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
    @finish-count = 0
    @round = 0
    @snakes = []
    @foods = []
    @heads = []
    @new-positions = []
    @targets = []
    fs.write-file-sync './log', ''
    for i from 0 til @config.snake
      snake = {}
      birth-position = @map.get-random-space!
      snake.position = [birth-position]
      @heads[i] = birth-position
      @map.set birth-position, \S
      snake.heading = random-int(4) - 1
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
    console.log "[Event: connected:all]"
    @was-dead = []
    for i from 0 til @config.snake
      @was-dead.push false
    @engine.on \finish, @_on-finish-handler
    @engine.on \finish:all, @_on-finish-all-handler
    @engine.send @_get-full-data!

  _on-finish-handler: ~>
    console.log "[Event: finish]"
    ++@finish-count
    if @finish-count is @config.snake
      @engine.emit \finish:all

  _on-finish-all-handler: ~>
    console.log "[Event: finish:all]"
    is-dead = []
    is-eaten = []
    for i from 0 til @config.snake
      is-dead.push false

    for i from 0 til @config.food
      is-eaten.push false

    # try move
    console.log "[pre-Move]", @operations
    for operation, id in @operations
      if not @was-dead[id]
        new-position = []
        new-position[0] = @heads[id][0] + direction-mapping[operation][0]
        new-position[1] = @heads[id][1] + direction-mapping[operation][1]
        @new-positions[id] = new-position
        @targets[id] = @map.get(@new-positions[id])

    console.log "[eat or die]"
    # eat or die
    for target, id in @targets
      switch target
      case \F
        for i from 0 til @config.food
          if _.is-equal @new-positions[id], @foods[i]
            is-eaten[i] = true
            @snakes[id].position.push [0, 0] # grop up, the tail will be throw away
      case \#
        is-dead[id] = @was-dead[id] = true

    # is bump?
    console.log "[bump]"
    for i from 0 til @config.snake - 1
      for j from i + 1 til @config.snake
        if _.is-equal @new-positions[i], @new-positions[j]
          is-dead[i] = is-dead[j] = @was-dead[i] = @was-dead[j] = true

    # new food
    console.log "[new food]"
    for i from 0 til @config.food
      if is-eaten[i]
        @foods.splice i, 1
        food = @map.get-random-space @new-positions
        @foods.push food

    # move the snake
    console.log "[move]"
    @heads = @new-positions
    for snake, id in @snakes
      snake.position.unshift @new-positions[id]
      snake.position.pop!

    for i from 0 til @config.snake
      # kill the snake
      if is-dead[i]
        for pos in @snakes[i].position
          [x, y] = pos
          @map.battlefield[y][x] = \#
      # update heading
      @snakes[i].heading = @operations[i]

    # is game end?
    life-count = 0
    for dead in @was-dead
      if not dead
        ++life-count

    if life-count <= 1
      console.log "!![Game end!]!!"
      @engine.emit \end
    else
      console.log "[next round]"
      # next round

      ++@round
      @finish-count = 0
      data = {}
      data <<< @config
      data.round = @round
      data{snakes, foods} = @
      data.map = @map.to-string!
      @map = Map data
      # logger
      console.log "real-map", @map.real-map
      fs.append-file-sync './log', @map.to-string(@map.real-map) + \\n\n
      console.log "\n!!!!!!!!!!!!!!!!!!!!!!!!!\n!![Game Round #{@round}]!!\n!!!!!!!!!!!!!!!!!!!!!!!!!\n"
      @engine.send data

exports = module.exports = SnakeGame
