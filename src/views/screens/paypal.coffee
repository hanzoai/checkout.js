crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

analytics = require '../../utils/analytics'

input = require '../../utils/input.coffee'

class PayPal extends Screen
  tag: 'paypal'
  title: 'Pay with PayPal'
  html: require '../../../templates/screens/paypal.jade'

  payKey: ''

  inputConfigs: [
    input 'user.email',             'youremail@somewhere.com',  'email input required'
    input 'user.password',          'Password',                 'password'
    input 'user.name',              'Full Name',                'input name required'
  ]

  show: ()->
    analytics.track 'Viewed Checkout Step',
      step: 1

  _submit: (event)->
    @screenManagerObs.trigger Events.Confirm.Lock

    data =
      user:     @model.user
      order:    @model.order
      payment:  @model.payment

    @client.payment.paypal(data).then((res)=>
      @payKey = res.responseText.payKey

      analytics.track 'Completed Checkout Step',
        step: 1

      if @model.test.paypal
        window.location.href = "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_ap-payment&paykey=#{ @payKey }"
      else
        window.location.href = "https://www.paypal.com/cgi-bin/webscr?cmd=_ap-payment&paykey=#{ @payKey }"
    ).catch (err)->
      console.log "shipping submit Error: #{err}"
      @screenManagerObs.trigger Events.Confirm.Unlock
      @screenManagerObs.trigger Events.Checkout.Done

PayPal.register()

module.exports = PayPal
