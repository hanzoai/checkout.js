crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

class Screen extends FormView
  tag: 'screen'
  title: 'Untitled'
  showConfirm: true
  showBack: true
  showInvoice: true

  index: 0
  total: 1
  style: ''

  screenManagerObs: null

  js: (opts)->
    @total = opts.total ? 1

    width = 100 / @total

    @on 'updated', ()=>
      $(@root).css('width', "#{width}%")

    @screenManagerObs = opts.screenManagerObs
    @client = opts.client
    super

  show: ()->

  _submit: ()->
    @screenManagerObs.trigger Events.Screen.Next

module.exports = Screen
