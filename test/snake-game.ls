require! {
  should
  async

  SnakeGame: \../game/snake

  '../src/helper'.async-error-throw
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
