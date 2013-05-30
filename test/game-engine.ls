require! {
  should
  async
  zmq

  GameEngine: \../src/game-engine

  './helper'.async-error-throw
}

resource = 'ipc:///tmp/test.ipc'

describe "Game Engine", ->
  describe '#_load-map()', (...) ->
    it 'should throw an error if the map does not exists', (done) ->
      game-engine = GameEngine do
        map: \blabla

      (err) <- game-engine._load-map
      err.should.be.an.instanceof Error
      err.code.should.eql \ENOENT

      done!

    it 'should load the map', (done) ->
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

  describe '#_load-game-config()', (...) ->
    it 'should load snake and food config', (done) ->
      game-engine = GameEngine do
        map: \test
        snake: 2
        food: 1
        resource: resource
      (err) <- game-engine._load-map
      should.not.exist err
      (err) <- game-engine._load-game-config
      should.not.exist err

      {game-info} = game-engine
      game-info.snake.should.equal 2
      game-info.food.should.equal 1

      done!

    it "should use `max-snake` as the default value of snake and food", (done) ->
      game-engine = GameEngine do
        map: \test
        resource: resource
      (err) <- game-engine._load-map
      should.not.exist err
      (err) <- game-engine._load-game-config
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
          (err) <- game-engine._load-map
          should.not.exist err
          (err) <- game-engine._load-game-config

          async-error-throw err, "`snake` is out of range"
          callback null

      async.parallel [out-of-range-test(6), out-of-range-test(1), out-of-range-test(-1)], done

  describe '#_load-engine-config()', (...) ->
    it "should load resource config", (done) ->
      game-engine = GameEngine do
        resource: resource

      (err) <- game-engine._load-engine-config
      should.not.exist err
      game-engine.resource.should.equal resource

      done!

    it "should throw an error if socket `resource` is not provided", (done) ->
      game-engine = GameEngine do
        map: \test

      (err) <- game-engine._load-engine-config
      async-error-throw err, "Must provide socket `resource`!"

      done!

  describe '#_bind()', (...) ->
    it 'should bind to socket resource', (done) ->
      resource = 'ipc:///tmp/bind-test.ipc'

      # setup publisher
      game-engine = GameEngine do
        map: \test
        resource: resource
      (err) <- game-engine.init
      should.not.exist err
      (err) <- game-engine._bind
      should.not.exist err

      client = zmq.socket 'sub'
      client.connect resource
      client.subscribe ''
      client.on \message, (data) ->
        data.to-string!.should.equal \bind
        client.close!
        game-engine.close!
        done!


      game-engine.send \bind
