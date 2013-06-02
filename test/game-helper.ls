require! {
  should

  '../game/helper'.map-data-to-array
  '../game/helper'.deep-clone-array
}

describe "Helpers", ->
  describe '#deep-clone-array()', (...) ->
    it 'should deep clone an array', ->
      a = [[1 2 3] [4 5 6]]
      b = deep-clone-array a
      b[0] = 1
      a[0].should.eql [1 2 3]
