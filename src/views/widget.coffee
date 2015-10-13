crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

PagingModel = require '../models/paging.coffee'

class Widget extends View
  tag: 'widget'
  html: require '../../templates/widget.jade'
  js: (opts)->
    @pagingModel = new PagingModel ['Payment Method', 'Payment Info', 'Shipping Address'], 0

  close: ()->
    @obs.trigger "#{Events.Modal.Close}"

Widget.register()

module.exports = Widget

