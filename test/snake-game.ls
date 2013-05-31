require! {
  should
  async

  SnakeGame: \../game/snake
}

describe "Snake Game", ->
  describe '#_load-map()', (...) ->
    it 'should throw an error if the map does not exists', (done) ->
      game = SnakeGame do
        map: \blabla

      (err) <- game._load-map
      err.should.be.an.instanceof Error
      err.code.should.eql \ENOENT

      done!
