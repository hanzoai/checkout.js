View = require '../view'
progressBarHTML = require '../../templates/progressbar'
progressBarCSS = require '../../css/progressbar'

$ ()->
  $('head')
    .append($("<style>#{ progressBarCSS }</style>"))

class ProgressBarView extends View
  tag: 'progressbar'
  name: 'Payment Information'
  html: progressBarHTML
  constructor: ()->
    super(@tag, @html, @js)
    @items = []
    @index = 0

  setItems: (i)->
    @items = i
    @update()
  setIndex: (i)->
    @index = i
    @update()

module.exports = new ProgressBarView
