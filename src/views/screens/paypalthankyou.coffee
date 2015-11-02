crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
ThankYou = require './thankyou'

analytics = require '../../utils/analytics'

class PaypalThankYou extends ThankYou
  tag: 'paypal-thankyou'

  show: ()->
    analytics.track 'Viewed Checkout Step',
      step: 2
    analytics.track 'Completed Checkout Step',
      step: 2
    analytics.track 'Viewed Checkout Step',
      step: 3

PaypalThankYou.register()

module.exports = PaypalThankYou
