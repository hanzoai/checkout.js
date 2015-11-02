crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

input = require '../utils/input.coffee'

class Tabs extends View
  tag: 'tabs'
  html: require '../../templates/tabs.jade'
  choice: 'stripe'
  scripts: null

  selected: 'stripe'

  js: ()->
    @scripts = @model.scripts

  chooseStripe: ()->
    @selected = 'stripe'
    @obs.trigger Events.Screen.UpdateScript, @scripts.stripe

  choosePaypal: ()->
    @selected = 'paypal'
    @obs.trigger Events.Screen.UpdateScript, @scripts.paypal

Tabs.register()

module.exports = Tabs
