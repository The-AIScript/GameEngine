require! {
  should

  '../game/helper'.map-string-to-array
}

describe "Helpers", ->
  describe '#map-string-to-array()', (...) ->
    var array
    height = 2
    width = 4
    # hook
    before ->
      map-obj =
        height: height
        width: width
        string: \........
      array := map-string-to-array map-obj
    # test cases
    it 'should accept an map-data object and return an array', ->
      array.should.be.an.instanceof Array

    it 'should throw an error if height * width do not match string.length', ->
      map-obj =
        height: 2
        width: 4
        string: \..
      fn = ->
        map-string-to-array map-obj

      fn.should.throw '`height` and `width` do not match the string'

    it 'should wrap the map by walls(#)', ->
      array.join('').should.have.length(height * width + (height + width) * 2 + 4)

    it 'should chop the string by length', ->
      array.should.have.length(height + 2)
      array[0].should.have.length(width + 2)
