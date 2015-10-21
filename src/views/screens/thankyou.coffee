crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

input = require '../../utils/input.coffee'

class ThankYou extends Screen
  tag: 'thankyou'
  title: 'Done!'
  html: require '../../../templates/screens/thankyou.jade'
  showConfirm: false

  _submit: ()->

ThankYou.register()

module.exports = ThankYou
