crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

input = require '../../utils/input.coffee'

class Stripe extends Screen
  tag: 'stripe'
  html: require '../../../templates/screens/stripe.jade'
  inputConfigs: [
    input 'user.email',             '', 'input required'
    input 'user.password',          '', 'password'
    input 'user.name',              '', 'input name required'
    input 'payment.account.number', '', 'input required'
    input 'payment.account.expiry', '', 'input required'
    input 'payment.account.cvc',    '', 'input required'
  ]

  js:()->
    console.log 'STRIPE'
    super

Stripe.register()

module.exports = Stripe
