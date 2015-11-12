crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

input = require '../utils/input.coffee'

class Tabs extends View
  tag: 'tabs'
  html: require '../../templates/tabs.jade'
  selected: 'stripe'

  chooseStripe: ()->
    @selected = 'stripe'
    @obs.trigger Events.Screen.Payment.ChooseStripe

  choosePaypal: ()->
    @selected = 'paypal'
    @obs.trigger Events.Screen.Payment.ChoosePaypal

Tabs.register()

module.exports = Tabs
