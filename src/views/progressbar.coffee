crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class ProgressBar extends View
  tag: 'progressbar'
  html: require '../../templates/progressbar.jade'
  screens: []
  index: 0

  events:
    "#{Events.ProgressBar.Update}": (i)->
      @index = i

  js: (opts)->
    @screens = opts.screens

ProgressBar.register()

module.exports = ProgressBar
