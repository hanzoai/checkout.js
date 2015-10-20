crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

input = require '../../utils/input.coffee'
require 'card/lib/js/card'

class Stripe extends Screen
  tag: 'stripe'
  html: require '../../../templates/screens/stripe.jade'
  title: 'Payment Info'
  $card: null
  inputConfigs: [
    input 'user.email',             'youremail@somewhere.com',  'input required'
    input 'user.password',          'Password',                 'password'
    input 'user.name',              'Full Name',                'input name required'
    input 'payment.account.number', 'XXXX XXXX XXXX XXXX',      'input required'
    input 'payment.account.expiry', 'MM/YY',                    'input required expiration'
    input 'payment.account.cvc',    'CVC',                      'input required'
  ]

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

          $card
            .css(
              'margin-top': '-93px'
              'margin-left': '103px')
            .children()
            .css
              top: '50px'
              height: '192px'
              '-webkit-transform': 'scale(0.514285714285714)'
              '-ms-transform': 'scale(0.514285714285714)'
              transform: 'scale(0.514285714285714)'

Stripe.register()

module.exports = Stripe
