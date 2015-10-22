crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

class Screen extends FormView
  tag: 'screen'
  title: 'Untitled'
  showConfirm: true
  showBack: true
  disableInvoice: false

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
    @client = opts.client
    super

  _submit: ()->
    @screenManagerObs.trigger Events.Screen.Next

module.exports = Screen
