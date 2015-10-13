module.exports = class PagingModel
  screens: null
  index: 0
  constructor: (@screens, @index)->
    @index = 0 if !@index
    @screens = [] if !@screens || !@screens.length
