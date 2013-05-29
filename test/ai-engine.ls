require! {
  should

  AIEngine: \../src/ai-engine

  './helper'.async-error-throw
}

describe "AI Engine", (...) ->
  describe '#init()', (...) ->
    it 'should throw an error if socket resource is not provided', (done) ->
      ai-engine = AIEngine!

      (err) <- ai-engine.init
      async-error-throw err, "Must provide socket resource!"

      done!

  describe '#subscribe()', (...) ->
    it 'should subsribe to game engine'
