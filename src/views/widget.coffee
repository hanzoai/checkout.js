crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class Widget extends View
  tag: 'widget'
  html: require '../../templates/widget.jade'
  js: (opts)->
    @screens = ['Payment Method', 'Payment Info', 'Shipping Address']

  close: ()->
    @obs.trigger "#{Events.Modal.Close}"

Widget.register()

module.exports = Widget

