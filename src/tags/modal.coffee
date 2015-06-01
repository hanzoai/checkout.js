View = require '../view'
modalHTML = require '../../templates/modal'
modalCSS = require '../../css/modal'

$ ()->
  $('head')
    .append($("<style>#{ modalCSS }</style>"))

module.exports = new View 'modal', modalHTML, (opts)->
  close = ()->
    $('modal').removeClass('crowdstart-active')

  waitRef = opts.config.waitRef
  @closeOnClickOff = (event)->
    if waitRef.waitId == 0 && $(event.target).hasClass('crowdstart-modal') || $(event.target).parent().hasClass('crowdstart-modal-target')
      close()
    else
      return true # bubble

  @closeOnEscape = (event)->
    if event.which == 27
      close()

  $(document).on('keydown', @closeOnEscape)
