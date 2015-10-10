riot = require 'riot'

crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class Modal extends View
  html: require '../../templates/modal.jade'
  isOpen: false
  canClose: true
  events:
    "#{Events.Modal.Open}": ()->
      @open()
    "#{Events.Modal.Close}": ()->
      @close()
    "#{Events.Modal.DisableClose}": ()->
      @canClose = false
    "#{Events.Modal.EnableClose}": ()->
      @canClose = true

  js: (opts)->
    $(document).on('keydown', @closeOnEscape)

  open: ()->
    @isOpen = true
    @update()

  close: ()->
    if @canClose
      @isOpen = false
      @update()
    else
      return true

  closeOnEscape: (event)->
    if event.which == 27
      @close()

module.exports = Modal
