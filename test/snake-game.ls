require! {
  should
  async
  events.EventEmitter

  SnakeGame: \../game/snake

  './test-helper'.async-error-throw
}

event-emmitter = new EventEmitter

describe "Snake Game", ->
  describe '#_load-map()', (...) ->
    it 'should throw an error if the map is not provided', (done) ->
      game = SnakeGame!

      (err) <- game._load-map
      async-error-throw err, 'Must provide map file!'

      done!

    it 'should throw an error if the map does not exists', (done) ->
      game = SnakeGame do
        map: \blabla

      (err) <- game._load-map
      err.should.be.an.instanceof Error
      err.code.should.eql \ENOENT

      done!

    it 'should load the map', (done) ->
      game = SnakeGame do
        map: \test

      (err) <- game._load-map
      should.not.exist err
      {config, map} = game
      # check map-config
      config.should.be.a \object
      config.name.should.equal \test
      config.'max-snake'.should.equal 4
      # check map string
      config.map.should.have.length 100
      config.map[0].should.equal \.
      # check map array
      map.real-map.should.have.length 12
      map.get([0 0]).should.equal \#
      map.real-map[0].should.have.length 12

      done!

  describe '#_load-config()', (...) ->
    it 'should load snake and food config', (done) ->
      game = SnakeGame do
        * map: \test
          snake: 2
          food: 1
        * this
      (err) <- game._load-config
      should.not.exist err

      {config} = game
      config.snake.should.equal 2
      config.food.should.equal 1

      done!

    it "should use `max-snake` as the default value of snake and food", (done) ->
      game = SnakeGame do
        * map: \test
        * this
      (err) <- game._load-config
      should.not.exist err

      {config} = game
      config.snake.should.equal 4
      config.food.should.equal 4

      done!

    it "should throw an error if `snake` is greater than `max-snake` or less than 2", (done) ->
      out-of-range-test = (snake) ->
        (callback) ->
          game = SnakeGame do
            * map: \test
              snake: snake
            * this
          (err) <- game._load-config

          async-error-throw err, "`snake` is out of range"
          callback null

      async.parallel [out-of-range-test(6), out-of-range-test(1), out-of-range-test(-1)], done

    it "should throw an error if `engine` is not provided", (done) ->
      game = SnakeGame do
        map: \test

      (err) <- game._load-config
      async-error-throw err, "Must provide game-engine!"

      done!

  describe '#_setup()', (...) ->
    var game
    before-each (done) ->
      game := SnakeGame do
        * map: \test
          snake: 2
          food: 2
        * event-emmitter
      (err) <- game._load-config
      (err) <- game._setup
      should.not.exists err

      done!


    it 'should generate random coordinate on space for each snake', (done) ->
      for snake in game.snakes
        [x, y] = snake.position[0]
        game.map.battlefield[y][x].should.equal \.

      done!

    it 'should generate random heading for each snake', (done) ->
      for snake in game.snakes
        snake.heading.should.be.a \number

      done!

    it 'should generate random coordinate on space for each food', (done) ->
      for food in game.foods
        [x, y] = food
        game.map.battlefield[y][x].should.equal \.

      done!

  describe '#_get-full-data()', (...) ->
    var game
    before-each (done) ->
      game := SnakeGame do
        * map: \test
          snake: 3
          food: 2
        * new EventEmitter

      (err) <- game._load-config
      (err) <- game._setup
      done!

    it 'should return an object', ->
      game._get-full-data!.should.be.an.instanceof Object

    it 'should include map, config, snakes and food', ->
      full-data = game._get-full-data!
      should.exist full-data.snake
      should.exist full-data.food
      should.exist full-data.name
      should.exist full-data.height
      should.exist full-data.width
      should.exist full-data.map
      should.exist full-data.snakes
      full-data.snakes.should.be.an.instanceof Array
      should.exist full-data.foods
      full-data.foods.should.be.an.instanceof Array
      for i from 0 til 3
        full-data.snakes[i].should.be.a \object
        should.exist full-data.snakes[i].heading
        should.exist full-data.snakes[i].position
        should.exist full-data.snakes[i].id
        full-data.snakes[i].id.should.equal i
