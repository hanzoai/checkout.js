riot = require 'riot'

crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class Modal extends View
  html: require '../../templates/modal.jade'
  js: (opts)->
    @waitRef = opts.config.waitRef
    $(document).on('keydown', @closeOnEscape)

  close: ()->
    $('modal').removeClass('crowdstart-active')

  closeOnClickOff: (event)->
    if @waitRef.waitId == 0 &&
    $(event.target).hasClass('crowdstart-modal') ||
    $(event.target).parent().hasClass('crowdstart-modal-target')
      @close()
    else
      return true # bubble

  closeOnEscape: (event)->
    if event.which == 27
      @close()

module.exports = Modal
