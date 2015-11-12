crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'
requestAnimationFrame = crowdcontrol.utils.shim.requestAnimationFrame

input = require '../../utils/input.coffee'

class Choose extends Screen
  tag:          'choose'
  title:        'Select Payment'
  html:         require '../../../templates/screens/choose.jade'
  scripts:      null
  choice: 'stripe'

  js: ()->
    @scripts = @model.scripts
    super

    @stripe()

  #jquery stuff exists because cancellation behaves strangely
  stripe: ()->
    @choice = 'stripe'
    requestAnimationFrame ()=>
      $(@root).find('#choose-stripe').prop 'checked', true
      $(@root).find('#choose-paypal').prop 'checked', false

  paypal: ()->
    @choice = 'paypal'
    requestAnimationFrame ()=>
      $(@root).find('#choose-stripe').prop 'checked', false
      $(@root).find('#choose-paypal').prop 'checked', true

  _submit: ()->
    if @choice == 'stripe'
      @screenManagerObs.trigger Events.Screen.UpdateScript, @scripts.stripe, 1
    else if @choice == 'paypal'
      @screenManagerObs.trigger Events.Screen.UpdateScript, @scripts.paypal, 1

Choose.register()

module.exports = Choose
