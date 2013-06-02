require! {
  zmq
  should
  msgpack

  AIEngine: \../src/ai-engine
  GameEngine: \../src/game-engine
  './test-helper'.async-error-throw
}
resource =
  pub: 'ipc:///tmp/id-test-pub.ipc'
  rep : 'ipc:///tmp/id-test-rep.ipc'

describe "AI Engine", (...) ->
  describe '#_load-config()', (...) ->
    it 'should throw an error if socket `resource` is not provided', (done) ->
      ai-engine = AIEngine id: 1

      (err) <- ai-engine._load-config
      async-error-throw err, "Must provide socket `resource`!"

      done!

    it 'should throw an error if ai `id` is not provided', (done) ->
      ai-engine = AIEngine resource: resource

      (err) <- ai-engine._load-config
      async-error-throw err, "Must provide engine's `id`!"

      done!

    it 'should throw an error if ai `strategy` is not provided', (done) ->
      ai-engine = AIEngine do
        resource: resource
        id: 1

      (err) <- ai-engine._load-config
      async-error-throw err, "Must ptovide engine's `strategy`!"

      done!

    it 'should load `resource` and `id` and `strategy`', (done) ->
      fn = ->
        @
      ai-engine = AIEngine do
        id: 1
        resource: resource
        strategy: fn

      (err) <- ai-engine._load-config
      should.exist ai-engine.id
      ai-engine.id.should.equal 1
      should.exist ai-engine.resource
      ai-engine.resource.should.eql resource
      should.exist ai-engine.strategy
      ai-engine.strategy.should.be.a \function

      done!


  describe '#_connect()', (...) ->
    it 'should connect to game engine', (done) ->
      resource =
        pub: 'ipc:///tmp/connect-test-pub.ipc'
        rep: 'ipc:///tmp/connect-test-rep.ipc'

      # the replier
      replier = zmq.socket \rep
      (err) <- replier.bind resource.rep
      should.not.exist err

      finish-count = 0
      replier.on \message, (data) ->
        replier.send \hello
        finish-count := finish-count + 1
        if finish-count is 2
          replier.close!
          done!

      # the subscriber
      finish-count = 0
      fn = (data, callback) ->
        callback null
      for i in [0, 1]
        let index = i
          ai-engine = AIEngine do
            resource: resource
            id: index
            strategy: fn

          (err) <- ai-engine._load-config

          ai-engine._connect (err) ->
            should.not.exist err

          <- ai-engine.subscriber.on \message
          ai-engine.close!

