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
    @total = opts.total ? 1

    width = 100 / @total

    @on 'update', ()=>
      $(@root).css('width', "#{width}%")

    @screenManagerObs = opts.screenManagerObs
    super

  _submit: ()->
    @screenManagerObs.trigger Events.Screen.Next

module.exports = Screen
