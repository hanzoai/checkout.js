crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

analytics = require '../../utils/analytics'

input = require '../../utils/input.coffee'
require 'card/lib/js/card'

class Payment extends Screen
  tag: 'payment'
  html: require '../../../templates/screens/payment.jade'
  title: 'Payment Info'
  card: null
  inputConfigs: [
    input 'user.email',             'youremail@somewhere.com',  'email input required'
    input 'user.password',          'Password',                 'password'
    input 'user.name',              'Full Name',                'input name required'
    input 'payment.account.number', 'XXXX XXXX XXXX XXXX',      'cardnumber requiredstripe'
    input 'payment.account.expiry', 'MM/YY',                    'input requiredstripe expiration'
    input 'payment.account.cvc',    'CVC',                      'input requiredstripe cvc'
  ]

  events:
    "#{ Events.Screen.Payment.ChooseStripe }": ()->
      @setSelected 'stripe'

    "#{ Events.Screen.Payment.ChoosePaypal }": ()->
      @setSelected 'paypal'

  setSelected: (selected)->
    @model.order.type = selected
    @model.payment.account._type = selected
    @fullyValidated = false
    riot.update()

  show: ()->
    analytics.track 'Viewed Checkout Step',
      step: 1

  _submit: ()->
    super()

    analytics.track 'Completed Checkout Step',
      step: 1

  js: ()->
    super

    @model.payment.account._type = @model.order.type

    @on 'update', ()=>
      if !@card?
        $card = $(@root).find('.crowdstart-card')
        if $card[0]?
          @card = new window.Card
            form: 'form#payment'
            container: '.crowdstart-card'
            width: 180

Payment.register()

module.exports = Payment
