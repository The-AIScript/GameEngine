require! {
  should

  '../game/helper'.map-data-to-array
  '../game/helper'.deep-clone-array
}

describe "Helpers", ->
  describe '#map-data-to-array()', (...) ->
    var array
    height = 2
    width = 4
    # hook
    before ->
      map-obj =
        height: height
        width: width
        string: \........
      array := map-data-to-array map-obj
    # test cases
    it 'should accept an map-data object and return an array', ->
      array.should.be.an.instanceof Array

    it 'should throw an error if height * width do not match string.length', ->
      map-obj =
        height: 2
        width: 4
        string: \..
      fn = ~>
        map-data-to-array map-obj

      fn.should.throw '`height` and `width` do not match the string'

    it 'should wrap the map by walls(#)', ->
      array.join('').should.have.length(height * width + (height + width) * 2 + 4)

    it 'should chop the string by length', ->
      array.should.have.length(height + 2)
      array[0].should.have.length(width + 2)

  describe '#deep-clone-array()', (...) ->
    it 'should deep clone an array', ->
      a = [[1 2 3] [4 5 6]]
      b = deep-clone-array a
      b[0] = 1
      a[0].should.eql [1 2 3]
