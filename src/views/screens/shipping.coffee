crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

input = require '../../utils/input.coffee'

class Shipping extends Screen
  tag: 'shipping'
  title: 'Shipping Address'
  html: require '../../../templates/screens/shipping.jade'
  inputConfigs: [
    input 'order.shippingAddress.line1',        '123 Street',       'input required'
    input 'order.shippingAddress.line2',        '123 Apt',          'input'
    input 'order.shippingAddress.city',         'City',             'input required'
    input 'order.shippingAddress.state',        'State',            'input required'
    input 'order.shippingAddress.postalCode',   'Zip/Postal Code',  'input postalRequired'
    input 'order.shippingAddress.country',      '',                 'country-select required'
  ]

  _submit: ()->
    @screenManagerObs.trigger Events.Confirm.Lock
    @screenManagerObs.trigger Events.Confirm.Error, ''

    data =
      user:     @model.user
      order:    @model.order
      payment:  @model.payment

    @client.payment.authorize(data).then((res)=>
      @model.order = res.responseText
      @screenManagerObs.trigger Events.Screen.Next
      @screenManagerObs.trigger Events.Confirm.Unlock
      @screenManagerObs.trigger Events.Checkout.Done

      riot.update()
    ).catch (err)=>
      console.log "shipping submit Error: #{err}"

      res = @client.lastResponse
      if res.status == 402 && res.error.code == 'card-declined'
        @screenManagerObs.trigger Events.Confirm.Error, 'Sorry, your card was declined. Please check your payment information.'
      else
        @screenManagerObs.trigger Events.Confirm.Error, 'Sorry, unable to complete your transaction. Please try again later.'

      @screenManagerObs.trigger Events.Confirm.Unlock
      @screenManagerObs.trigger Events.Checkout.Done

Shipping.register()

module.exports = Shipping
