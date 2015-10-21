crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

input = require '../../utils/input.coffee'

class Choose extends Screen
  tag: 'choose'
  title: 'Select Payment'
  html: require '../../../templates/screens/choose.jade'
  scripts: null
  showConfirm: false

  js: ()->
    @scripts = @model.scripts
    super

  stripe: ()->
    @screenManagerObs.trigger Events.Screen.UpdateScript, @scripts.stripe, 1

  paypal: ()->
    @screenManagerObs.trigger Events.Screen.UpdateScript, @scripts.paypal, 1

  _submit: ()->

Choose.register()

module.exports = Choose
