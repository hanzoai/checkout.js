View = require '../view'
modalHTML = require '../../templates/modal'
modalCSS = require '../../css/modal'

$ ()->
  $('head')
    .append($("<style>#{ modalCSS }</style>"))

module.exports = new View 'modal', modalHTML, (opts)->
  close = ()->
    if window.location.hash == '#' + opts.id
      window.history.back()

  @closeOnClickOff = (event)->
    if $(event.target).hasClass('crowdstart-modal')
      close()

  @closeOnEscape = (event)->
    if event.which == 27
      close()

  $(document).on('keydown', @closeOnEscape)


