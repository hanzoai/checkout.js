crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

analytics = require '../../utils/analytics'

input = require '../../utils/input.coffee'

class Shipping extends Screen
  tag: 'shipping'
  title: 'Shipping Address'
  html: require '../../../templates/screens/shipping.jade'
  taxRates: null
  inputConfigs: [
    input 'order.shippingAddress.line1',        '123 Street',       'input required'
    input 'order.shippingAddress.line2',        '123 Apt',          'input'
    input 'order.shippingAddress.city',         'City',             'input required'
    input 'order.shippingAddress.state',        'State',            'state-select required'
    input 'order.shippingAddress.postalCode',   'Zip/Postal Code',  'input postalRequired'
    input 'order.shippingAddress.country',      '',                 'country-select required'
  ]

  updateTaxRate: ()->
    @model.order.taxRate = 0

    for taxRate in @taxRates
      if taxRate.city? && @model.order.shippingAddress.city? && taxRate.city.toLowerCase() != @model.order.shippingAddress.city.toLowerCase()
        continue

      if taxRate.state? && @model.order.shippingAddress.state? && taxRate.state.toLowerCase() != @model.order.shippingAddress.state.toLowerCase()
        continue

      if taxRate.country? && @model.order.shippingAddress.country? && taxRate.country.toLowerCase() != @model.order.shippingAddress.country.toLowerCase()
        continue

      @model.order.taxRate = taxRate.taxRate
      break

    riot.update()

  events:
    "#{Events.Input.Set}": ()->
      @updateTaxRate()

  js: (opts)->
    super
    @taxRates = @model.taxRates ? []

  show: ()->
    analytics.track 'Viewed Checkout Step',
      step: 2

  _submit: ()->
    @screenManagerObs.trigger Events.Confirm.Lock
    @screenManagerObs.trigger Events.Confirm.Error, ''

    if @model.order.type == 'paypal'
      @submitPaypal()
    else
      @submitStripe()

  submitPaypal: ()->
    data =
      user:     @model.user
      order:    @model.order
      payment:  @model.payment

    @client.payment.paypal(data).then((res)=>
      @payKey = res.responseText.payKey

      analytics.track 'Completed Checkout Step',
        step: 2

      if @model.test.paypal
        window.location.href = "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_ap-payment&paykey=#{ @payKey }"
      else
        window.location.href = "https://www.paypal.com/cgi-bin/webscr?cmd=_ap-payment&paykey=#{ @payKey }"
    ).catch (err)=>
      console.log "shipping submit Error: #{err}"
      @screenManagerObs.trigger Events.Confirm.Error, 'Sorry, Paypal is unavailable.  Please try again later.'
      @screenManagerObs.trigger Events.Confirm.Unlock
      @screenManagerObs.trigger Events.Checkout.Done

  submitStripe: ()->
    data =
      user:     @model.user
      order:    @model.order
      payment:  @model.payment

    @client.payment.charge(data).then((res)=>
      coupon = @model.order.coupon || {}
      @model.order = res.responseText

      analytics.track 'Completed Checkout Step',
        step: 2

      options =
        orderId:  @model.order.id
        total:    parseFloat(@model.order.total/100),
        # revenue: parseFloat(order.total/100),
        shipping: parseFloat(@model.order.shipping/100),
        tax:      parseFloat(@model.order.tax/100),
        discount: parseFloat(@model.order.discount/100),
        coupon:   coupon.code || '',
        currency: @model.order.currency,
        products: []

      for item, i in @model.order.items
        options.products[i] =
          id: item.productId
          sku: item.productSlug
          name: item.productName
          quantity: item.quantity
          price: parseFloat(item.price / 100)

      analytics.track 'Completed Order', options
      if @model.analytics?.pixels?.checkout?
        analytics.track @model.analytics.pixels?.checkout

      if @model.referralProgram?
        @client.payment.newReferrer(
          userId: @model.order.userId
          orderId: @model.order.orderId
          program: @model.referralProgram
        ).then((res)=>
          @model.referrerId = res.responseText.id
        ).catch (err)->
          console.log "new referralProgram Error: #{err}"

      @screenManagerObs.trigger Events.Screen.Next
      @screenManagerObs.trigger Events.Confirm.Unlock
      @screenManagerObs.trigger Events.Checkout.Done

      riot.update()
    ).catch (err)=>
      console.log "shipping submit Error: #{err}"

      res = @client.lastResponse.responseText
      if res.status == 402 && res.error.code == 'card-declined'
        @screenManagerObs.trigger Events.Confirm.Error, 'Sorry, your card was declined. Please check your payment information.'
      else
        @screenManagerObs.trigger Events.Confirm.Error, 'Sorry, unable to complete your transaction. Please try again later.'

      @screenManagerObs.trigger Events.Confirm.Unlock
      @screenManagerObs.trigger Events.Checkout.Done

Shipping.register()

module.exports = Shipping
