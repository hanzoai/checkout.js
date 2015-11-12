crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class Widget extends View
  tag: 'widget'
  html: require '../../templates/widget.jade'
  js: (opts)->
    @client = opts.client

Widget.register()

module.exports = Widget
