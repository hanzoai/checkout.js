crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

analytics = require '../../utils/analytics'
input     = require '../../utils/input'

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

  updateShippingRate: ()->
    @model.order.shippingRate = 0

    for shippingRate in @shippingRates
      if shippingRate.city? && @model.order.shippingAddress.city? && shippingRate.city.toLowerCase() != @model.order.shippingAddress.city.toLowerCase()
        continue

      if shippingRate.state? && @model.order.shippingAddress.state? && shippingRate.state.toLowerCase() != @model.order.shippingAddress.state.toLowerCase()
        continue

      if shippingRate.country? && @model.order.shippingAddress.country? && shippingRate.country.toLowerCase() != @model.order.shippingAddress.country.toLowerCase()
        continue

      @model.order.shippingRate = shippingRate.shippingRate
      break

    riot.update()

  events:
    "#{Events.Input.Set}": ()->
      @updateTaxRate()
      @updateShippingRate()

  js: (opts)->
    super
    @taxRates       = @model.taxRates ? []
    @shippingRates  = @model.shippingRates ? []

  show: ()->
    analytics.track 'Viewed Checkout Step',
      step: 2

    $('body').animate(
      scrollTop: ($('screen-manager').first().offset().top - 50)
    , 500)

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

    @client.checkout.paypal(data).then((order)=>
      @payKey = order.payKey

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

    @client.checkout.charge(data).then((order)=>
      coupon = @model.order.coupon || {}
      @model.order = order

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
        @client.referrer.create(
          userId: @model.order.userId
          orderId: @model.order.orderId
          program: @model.referralProgram
        ).then((referrer)=>
          @model.referrerId = referrer.id
        ).catch (err)->
          console.log "new referralProgram Error: #{err}"

      @model.payment.account.number = ''
      @model.payment.account.expiry = ''
      @model.payment.account.cvc = ''

      @screenManagerObs.trigger Events.Screen.Next
      @screenManagerObs.trigger Events.Confirm.Unlock
      @screenManagerObs.trigger Events.Checkout.Done

      # force clear cardjs
      $('.crowdstart-card-widget input').val('')

      riot.update()
    ).catch (err)=>
      console.log "shipping submit Error: #{err}"

      res = err.data
      if res.error.code == 'card-declined'
        @screenManagerObs.trigger Events.Confirm.Error, 'Sorry, your card was declined. Please check your payment information.'
      else
        @screenManagerObs.trigger Events.Confirm.Error, 'Sorry, unable to complete your transaction. Please try again later.'

      @screenManagerObs.trigger Events.Confirm.Unlock
      @screenManagerObs.trigger Events.Checkout.Done

Shipping.register()

module.exports = Shipping
