crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

analytics = require '../../utils/analytics'

class ThankYou extends Screen
  tag: 'thankyou'
  title: 'Done!'
  html: require '../../../templates/screens/thankyou.jade'
  showConfirm: false
  showBack: false
  showInvoice: false

  _submit: ()->
    # This is never called because confirmation button is gone
    # analytics.track 'Completed Checkout Step',
    #   step: 3

  show: ()->
    analytics.track 'Viewed Checkout Step',
      step: 3

ThankYou.register()

module.exports = ThankYou
