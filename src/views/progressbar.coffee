crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class ProgressBar extends View
  tag: 'progressbar'
  html: require '../../templates/progressbar.jade'

  # model: PagingModel

  events:
    "#{Events.ProgressBar.Update}": (i)->
      @model.index = i
      @update()

  js: (opts)->

ProgressBar.register()

module.exports = ProgressBar
