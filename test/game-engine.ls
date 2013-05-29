require! {
  should
  async

  GameEngine: \../src/game-engine

  './helper'.async-error-throw
}

describe "Game Engine", ->
  describe '#_load-map()', (...) ->
    it 'should throw an error if the map does not exists', (done) ->
      game-engine = GameEngine do
        map: \blabla

      (err) <- game-engine._load-map
      err.should.be.an.instanceof Error
      err.code.should.eql \ENOENT

      done!

    it 'should load the map correctly', (done) ->
      game-engine = GameEngine do
        map: \test

      (err) <- game-engine._load-map
      should.not.exist err
      {map-info} = game-engine
      # check map-info
      map-info.should.be.a \object
      map-info.name.should.equal \test
      map-info.'max-snake'.should.equal 4
      # check map
      map-info.map.should.have.length 100
      map-info.map[0].should.equal \.

      done!

  describe '#init()', (...) ->
    it 'should read snake and food config correctly', (done) ->
      game-engine = GameEngine do
        map: \test
        snake: 2
        food: 1

      (err) <- game-engine.init
      should.not.exist err
      {game-info} = game-engine
      game-info.snake.should.equal 2
      game-info.food.should.equal 1

      done!

    it "should use `max-snake` as the default value of snake and food", (done) ->
      game-engine = GameEngine do
        map: \test

      (err) <- game-engine.init
      should.not.exist err
      {game-info} = game-engine
      game-info.snake.should.equal 4
      game-info.food.should.equal 4

      done!

    it "should throw an error if `snake` is greater than `max-snake` or less than 2", (done) ->
      out-of-range-test = (snake) ->
        (callback) ->
          game-engine = GameEngine do
            map: \test
            snake: snake

          (err) <- game-engine.init
          async-error-throw err, "`snake` is out of range"
          callback null

      async.parallel [out-of-range-test(6), out-of-range-test(1), out-of-range-test(-1)], done
