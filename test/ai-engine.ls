require! {
  zmq
  should

  AIEngine: \../src/ai-engine
  '../src/helper'.async-error-throw
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

    it 'should load `resource` and `id`', (done) ->
      ai-engine = AIEngine do
        id: 1
        resource: resource

      (err) <- ai-engine._load-config
      ai-engine.id.should.equal 1
      ai-engine.resource.should.eql resource

      done!


  describe '#_connect()', (...) ->
    it 'should connect to game engine', (done) ->
      # the publisher
      publisher = zmq.socket 'pub'
      resource =
        pub: 'ipc:///tmp/connect-test-pub.ipc'
        rep: 'ipc:///tmp/connect-test-rep.ipc'
      (err) <- publisher.bind resource.pub
      should.not.exist err

      # the subscriber
      finish-count = 0
      for i in [0, 1]
        let index = i
          ai-engine = AIEngine do
            resource: resource
            id: index

          (err) <- ai-engine._load-config
          should.not.exist err

          ai-engine._connect (err) ->
            should.not.exist err

          <- ai-engine.on \finish

          finish-count := finish-count + 1
          ai-engine.data.to-string!.should.equal \hello
          ai-engine.close!
          if finish-count is 2
            publisher.close!
            done!

      publisher.send \hello
