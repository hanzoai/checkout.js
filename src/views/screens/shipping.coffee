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

  disableInvoice: true

  _submit: ()->
    @screenManagerObs.trigger Events.Confirm.Lock

    data =
      user:     @model.user
      order:    @model.order
      payment:  @model.payment

    @client.payment.authorize(data).then((res)=>
      console.log "yay!"
      @screenManagerObs.trigger Events.Screen.Next
      @screenManagerObs.trigger Events.Confirm.Unlock
    ).catch (err)->
      console.log "shipping submit Error: #{err}"
      @screenManagerObs.trigger Events.Confirm.Unlock

Shipping.register()

module.exports = Shipping
