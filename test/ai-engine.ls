require! {
  zmq
  should

  AIEngine: \../src/ai-engine
  './helper'.async-error-throw
}

describe "AI Engine", (...) ->
  describe '#_load-config()', (...) ->
    it 'should throw an error if socket `resource` is not provided', (done) ->
      ai-engine = AIEngine id: 1

      (err) <- ai-engine._load-config
      async-error-throw err, "Must provide socket `resource`!"

      done!

    it 'should throw an error if ai `id` is not provided', (done) ->
      resource = 'ipc:///tmp/id-test.ipc'
      ai-engine = AIEngine resource: resource

      (err) <- ai-engine._load-config
      async-error-throw err, "Must provide engine's `id`!"

      done!

  describe '#_subscribe()', (...) ->
    it 'should subscribe to game engine', (done) ->
      # the publisher
      socket = zmq.socket 'pub'
      resource = 'ipc:///tmp/subscribe-test.ipc'
      (err) <- socket.bind resource
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

          ai-engine._subscribe (err) ->
            should.not.exist err

          <- ai-engine.on \finish

          finish-count := finish-count + 1
          ai-engine.data.to-string!.should.equal \hello
          ai-engine.close!
          if finish-count is 2
            socket.close!
            done!

      socket.send \hello

