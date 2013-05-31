require! {
  should
  async

  SnakeGame: \../game/snake

  './test-helper'.async-error-throw
}

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
      {map} = game
      # check map
      map.should.be.a \object
      map.name.should.equal \test
      map.'max-snake'.should.equal 4
      # check map string
      map.string.should.have.length 100
      map.string[0].should.equal \.
      # check map array
      map.array.should.have.length 12
      map.array[0][0].should.equal \#
      map.array[0].should.have.length 12

      done!

  describe '#_load-config()', (...) ->
    it 'should load snake and food config', (done) ->
      game = SnakeGame do
        map: \test
        snake: 2
        food: 1
      (err) <- game._load-config
      should.not.exist err

      {config} = game
      config.snake.should.equal 2
      config.food.should.equal 1

      done!

    it "should use `max-snake` as the default value of snake and food", (done) ->
      game = SnakeGame do
        map: \test
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
            map: \test
            snake: snake
          (err) <- game._load-config

          async-error-throw err, "`snake` is out of range"
          callback null

      async.parallel [out-of-range-test(6), out-of-range-test(1), out-of-range-test(-1)], done

  describe '#_setup()', (...) ->
    var game
    before-each (done) ->
      game := SnakeGame do
        map: \test
        snake: 2
        food: 2
      (err) <- game._load-config
      (err) <- game._setup
      should.not.exists err

      done!


    it 'should generate random coordinate on space for each snake', (done) ->
      for snake in game.snakes
        [x, y] = snake.position[0]
        game.map.array[y][x].should.equal \.

      done!

    it 'should generate random heading for each snake', (done) ->
      for snake in game.snakes
        snake.heading.should.be.an.instanceof Array
        snake.heading.should.have.length 2

      done!

    it 'should generate random coordinate on space for each food', (done) ->
      for food in game.foods
        [x, y] = food
        game.map.array[y][x].should.equal \.

      done!

  describe '#_get-random-space()', (...) ->
    it 'should generate random cooradinate on space', (done) ->
      game = SnakeGame do
        map: \wall
      (err) <- game._load-config
      for i from 0 til 50
        [x, y] = game._get-random-space!
        game.map.array[y][x].should.equal \.

      done!
