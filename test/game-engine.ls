require! {
  should

  GameEngine: \../src/game-engine
}

describe "Game Engine", ->
  describe '#start()', (...) ->
    describe '#_load-map()', (...) ->
      it 'should throw an error if the map does not exists', (done) ->
        game-engine = new GameEngine do
          map: \blabla

        (err) <- game-engine._load-map
        err.should.be.an.instanceof Error
        err.code.should.eql \ENOENT

        done!

      it 'should load the map correctly', (done) ->
        game-engine = new GameEngine do
          map: \test

        (err) <- game-engine._load-map
        should.not.exist err
        {map, map-info} = game-engine
        # check map
        map.should.have.length 100
        map[0].should.equal \.
        # check map-info
        map-info.should.be.a \object
        map-info.name.should.equal \test

        done!
