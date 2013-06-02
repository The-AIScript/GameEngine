require! {
  should

  Map: \../game/map
}

describe "Map", ->
  describe 'initialize', (...) ->
    it 'should throw an error if height is not provided', ->
      fn = ->
        map = Map do
          width: 2
          map: \....
      fn.should.throw 'Must provide `height`!'

    it 'should throw an error if width is not provided', ->
      fn = ->
        map = Map do
          height: 2
          map: \....
      fn.should.throw 'Must provide `width`!'

    it 'should throw an error if map is not provided', ->
      fn = ->
        map = Map do
          width: 2
          height: 2
      fn.should.throw 'Must provide `map`!'

    it 'should throw an error if width * height isnt map.length', ->
      fn = ->
        map = Map do
          width: 1
          height: 2
          map: \....

      fn.should.throw 'height and width do not match the map string'

    it 'should generate map array `battlefield`', ->
      map = Map do
        width: 4
        height: 4
        map: \................
        snakes:
          * heading: [1 0]
            position: [[1 1]]
          * heading: [-1 0]
            position: [[4 3], [4 4]]
        foods: [
          [3 2]
          [1 4]
        ]

      battlefield = [
        <[# # # # # #]>
        <[# . . . . #]>
        <[# . . . . #]>
        <[# . . . . #]>
        <[# . . . . #]>
        <[# # # # # #]>
      ]
      should.exist map.battlefield
      map.battlefield.should.be.an.instanceof Array
      map.battlefield.should.eql battlefield

    it 'should generate map array with objects `real-map`', ->
      map = Map do
        width: 4
        height: 4
        map: \................
        snakes:
          * heading: [1 0]
            position: [[1 1]]
          * heading: [-1 0]
            position: [[4 3], [4 4]]
        foods: [
          [3 2]
          [1 4]
        ]

      real-map = [
        <[# # # # # #]>
        <[# S . . . #]>
        <[# . . F . #]>
        <[# . . . S #]>
        <[# F . . S #]>
        <[# # # # # #]>
      ]

      should.exist map.real-map
      map.real-map.should.be.an.instanceof Array
      map.real-map.should.eql real-map

  describe '#get-random-space()', (...) ->
    it 'should return coordinates on random space(.) of real-map', ->
      map = Map do
        width: 4
        height: 4
        map: \................
        snakes:
          * heading: [1 0]
            position: [[1 1]]
          * heading: [-1 0]
            position: [[4 3], [4 4]]
        foods: [
          [3 2]
          [1 4]
        ]

      for i from 0 to 100
        space = map.get-random-space!
        map.get(space).should.equal \.
