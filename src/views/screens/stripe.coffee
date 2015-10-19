crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

input = require '../../utils/input.coffee'

class Stripe extends Screen
  tag: 'stripe'
  html: require '../../../templates/screens/stripe.jade'
  inputConfigs: [
    input 'user.email',             'youremail@somewhere.com',  'input required'
    input 'user.password',          'Password',                 'password'
    input 'user.name',              'Full Name',                'input name required'
    input 'payment.account.number', 'XXXX XXXX XXXX XXXX',      'input required'
    input 'payment.account.expiry', 'MM/YY',                    'input required'
    input 'payment.account.cvc',    'CVC',                      'input required'
  ]

Stripe.register()

module.exports = Stripe
