crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

input = require '../../utils/input.coffee'

class PayPal extends Screen
  tag: 'paypal'
  title: 'Pay with PayPal'
  html: require '../../../templates/screens/paypal.jade'

  first: false
  payKey: ''

  inputConfigs: [
    input 'user.email',             'youremail@somewhere.com',  'input required'
    input 'user.password',          'Password',                 'password'
    input 'user.name',              'Full Name',                'input name required'
  ]

  js: (opts)->
    super
    @on 'update', ()=>
      if !@first && $('#paypal')[0]?
        @embeddedPPFlow = new PAYPAL.apps.DGFlow trigger: 'gopaypal'
        @first = true

  _submit: (event)->
    @screenManagerObs.trigger Events.Confirm.Lock

    data =
      user:     @model.user
      order:    @model.order
      payment:  @model.payment

    @client.payment.paypal(data).then((res)=>
      @payKey = res.responseText.payKey
      @update()
      requestAnimationFrame ()=>
        @screenManagerObs.trigger Events.Screen.Next
        @screenManagerObs.trigger Events.Confirm.Unlock
        @screenManagerObs.trigger Events.Checkout.Done

        $(@root).find('#gopaypal').trigger 'click'
        $(@root).find('form').submit()
    ).catch (err)->
      console.log "shipping submit Error: #{err}"
      @screenManagerObs.trigger Events.Confirm.Unlock
      @screenManagerObs.trigger Events.Checkout.Done

PayPal.register()

module.exports = PayPal
