riot = require 'riot'

crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView
requestAnimationFrame = crowdcontrol.utils.shim.requestAnimationFrame

input = require '../utils/input'

class Promo extends FormView
  tag:      'promo'
  html:     require '../../templates/promo.jade'

  renderCurrency: require('../utils/currency').renderUICurrencyFromJSON

  order:    null
  client:   null
  freeProduct: null

  model:
    promoCode: ''

  codeApplied: false
  clickedApplyPromoCode: false
  locked: false
  invalidCode: ''

  inputConfigs: [
    input 'promoCode', 'Promo/Coupon Code', 'input uppercase trim'
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

  _change: ()->
    super
    requestAnimationFrame ()=>
      @update()

  resetState: ()->
    @invalidCode = ''

  _submit: ()->
    if @model.promoCode == ''
      return

    @locked = true
    @codeApplied = false
    @clickedApplyPromoCode = true
    @invalidCode = ''
    @freeProduct = null
    @update()

    @client.util.coupon(@model.promoCode).then((res)=>
      coupon = res.responseText
      if coupon.enabled
        @order.coupon = coupon
        @order.couponCodes = [@model.promoCode]
        if coupon.freeProductId != "" && coupon.freeQuantity > 0
          @client.util.product(coupon.freeProductId).then((res)=>
            @freeProduct = res.responseText
            @freeProduct.quantity = coupon.freeQuantity
            @codeApplied = true
            @locked = false
            @update()
          ).catch (err)=>
            @codeApplied = true
            @locked = false
            @update()
            console.log "couponFreeProduct Error: #{err}"
        else
          @codeApplied = true
          @locked = false
      else
        @invalidCode = 'expired'
        @clickedApplyPromoCode = false
        @locked = false
      @update()
    ).catch (err)=>
      @locked = false
      @invalidCode = 'invalid'
      @clickedApplyPromoCode = false
      @update()

Promo.register()

module.exports = Promo
