crowdcontrol = require 'crowdcontrol'
riot = require 'riot'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

input = require '../utils/input.coffee'

class Promo extends FormView
  tag:      'promo'
  html:     require '../../templates/promo.jade'

  renderCurrency: require('../utils/currency.coffee').renderUICurrencyFromJSON

  order:    null
  client:   null

  model:
    promoCode: ''

  codeApplied: false
  clickedApplyPromoCode: false
  locked: false
  invalidCode: ''

  inputConfigs: [
    input 'promoCode', 'Promo/Coupon Code', 'input uppercase'
  ]

  js: (opts)->
    super

    @order = opts.order
    @coupon = opts.coupon
    @client = opts.client

  discount: ()->
    switch @order.coupon.type
      when 'flat'
        if !@order.coupon.productId? || @order.coupon.productId == ''
          @order.discount = (@order.coupon.amount || 0)
          riot.update()
          return @order.discount
        else
          discount = 0
          for item in @order.items
            if item.productId == @order.coupon.productId
              discount += (@order.coupon.amount || 0) * item.quantity
          @order.discount = discount
          riot.update()
          return discount

      when 'percent'
        discount = 0
        if !@order.coupon.productId? || @order.coupon.productId == ''
          for item in @order.items
            discount += (@order.coupon.amount || 0) * item.price * item.quantity * 0.01
        else
          for item in @order.items
            if item.productId == @order.coupon.productId
              discount += (@order.coupon.amount || 0) * item.price * item.quantity * 0.01
        discount = Math.floor discount
        @order.discount = discount
        riot.update()
        return discount

    @order.discount = 0
    riot.update()
    return 0

  _submit: ()->
    if @model.promoCode == ''
      return

    @locked = true
    @codeApplied = false
    @clickedApplyPromoCode = true
    @invalidCode = ''
    @update()

    @client.util.coupon(@model.promoCode).then((res)=>
      @locked = false
      coupon = res.responseText
      if coupon.enabled
        @order.coupon = coupon
        @order.couponCodes = [@model.promoCode]
        @codeApplied = true
      else
        @invalidCode = 'expired'
        @clickedApplyPromoCode = false
      @update()
    ).catch (err)=>
      @locked = false
      @invalidCode = 'invalid'
      @clickedApplyPromoCode = false
      @update()

Promo.register()

module.exports = Promo
