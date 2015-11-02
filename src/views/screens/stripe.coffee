crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

analytics = require '../../utils/analytics'

input = require '../../utils/input.coffee'
require 'card/lib/js/card'

class Stripe extends Screen
  tag: 'stripe'
  html: require '../../../templates/screens/stripe.jade'
  title: 'Payment Info'
  $card: null
  inputConfigs: [
    input 'user.email',             'youremail@somewhere.com',  'email input required'
    input 'user.password',          'Password',                 'password'
    input 'user.name',              'Full Name',                'input name required'
    input 'payment.account.number', 'XXXX XXXX XXXX XXXX',      'cardnumber required'
    input 'payment.account.expiry', 'MM/YY',                    'input required expiration'
    input 'payment.account.cvc',    'CVC',                      'input required cvc'
  ]

  show: ()->
    analytics.track 'Viewed Checkout Step',
      step: 1

  _submit: ()->
    super()

    analytics.track 'Completed Checkout Step',
      step: 1

  js: ()->
    super

    @on 'update', ()=>
      if !@card?
        $card = $('.crowdstart-card')
        if $card[0]
          @card = new window.Card
            form: 'form#stripe'
            container: '.crowdstart-card'
            width: 180

Stripe.register()

module.exports = Stripe
