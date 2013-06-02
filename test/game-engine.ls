require! {
  should
  async
  zmq
  msgpack

  GameEngine: \../src/game-engine
  Game: \../game/snake

  './test-helper'.async-error-throw
}

resource =
  pub: 'ipc:///tmp/test-pub.ipc'
  rep: 'ipc:///tmp/test-rep.ipc'

describe "Game Engine", ->
  describe '#_load-config()', (...) ->
    it "should load resource config", (done) ->
      game-engine = GameEngine do
        resource: resource

      (err) <- game-engine._load-config
      should.not.exist err
      game-engine.config.resource.should.equal resource

      done!

    it "should throw an error if socket `resource` is not provided", (done) ->
      game-engine = GameEngine do
        map: \test

      (err) <- game-engine._load-config
      async-error-throw err, "Must provide socket `resource`!"

      done!

    it "should throw an error if `resource` doesn't include `pub` or `rep` property", (done) ->
      game-engine = GameEngine do
        resource:
          pub: 'ipc:///tmp/test-pub.ipc'

      (err) <- game-engine._load-config
      async-error-throw err, "`resource` should include `pub` and `rep`!"

      game-engine = GameEngine do
        resource:
          rep: 'ipc:///tmp/test-pub.ipc'

      (err) <- game-engine._load-config
      async-error-throw err, "`resource` should include `pub` and `rep`!"

      game-engine = GameEngine do
        resource:
          blabla: 'blabla'
      (err) <- game-engine._load-config
      async-error-throw err, "`resource` should include `pub` and `rep`!"

      done!

  describe '#_bind()', (...) ->
    it "should trigger events when requestor connected", (done) ->
      resource:
        pub: 'ipc:///tmp/bind-test-pub.ipc'
        rep: 'ipc:///tmp/bind-test-rep.ipc'
      options =
        map: \test
        resource: resource
        snake: 2

      # setup publisher
      game-engine = GameEngine options
      (err) <- game-engine._load-config
      game-engine.game = Game options, game-engine
      (err) <- game-engine.game._load-config
      (err) <- game-engine._bind
      should.not.exist err

      # setup subscriber
      subscriber = zmq.socket 'sub'
      subscriber.connect resource.pub
      subscriber.subscribe ''
      requestor = zmq.socket 'req'
      requestor.connect resource.rep

      # handlers
      requestor.on \message, (data) ->
        data.to-string!.should.equal \OK

      subscriber.count = 0
      game-engine.on \connected:one, ->
        ++subscriber.count

      game-engine.on \connected:all, ->
        subscriber.count.should.equal 2
        game-engine.send \bind

      subscriber.on \message, (data) ->
        msgpack.unpack(data).should.equal \bind
        subscriber.close!
        game-engine.close!
        done!

      # send message
      requestor.send \ACK
      requestor.send \ACK

  describe '#_init-ai()', (...) ->
    it 'should init `snake` ai-engines', (done) ->
      fn = (data, callback) ->
        callback null
      game-engine = GameEngine do
        resource: resource
        map: \test
        snake: 2
        strategies: [fn, fn]

      (err) <- game-engine._load-config
      (err) <- game-engine._init-game
      (err) <- game-engine._bind
      (err) <- game-engine._init-ai
      should.not.exist err

      game-engine.ai-engines.should.have.length 2
      game-engine.close!
      done!
