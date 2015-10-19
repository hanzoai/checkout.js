crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

class Screen extends FormView
  tag: 'screen'

  index: 0
  total: 1
  style: ''

  screenManagerObs: null

  js: (opts)->
    @index = opts.index ? 0
    @total = opts.total ? 1

    left = opts.index * 2
    width = 100 / opts.total

    @style = "left: #{left}em; width: #{width}%;"
    @screenManagerObs = opts.screenManagerObs
    super

  _submit: ()->
    @screenManagerObs.trigger Events.Screen.Next

module.exports = Screen
