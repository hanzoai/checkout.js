crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class Invoice extends View
  tag: 'invoice'
  html: require '../../templates/invoice.jade'
  client: null
  hide: false

  renderCurrency: require('../utils/currency.coffee').renderUICurrencyFromJSON

  events:
    "#{ Events.Invoice.Hide }": ()->
      @setHide true
    "#{ Events.Invoice.Show }": ()->
      @setHide false

  setHide: (state)->
    @hide = state
    @update()

  js:(opts)->
    @client = opts.client

  subtotal: ()->
    items = @model.items
    subtotal = -@model.discount || 0
    for item in items
      subtotal += item.price * item.quantity

    @model.subtotal = subtotal
    return subtotal

  shipping: ()->
    items = @model.items
    shippingRate = @model.shippingRate || 0
    # shipping = 0
    # for item in items
    #   shipping += shippingRate * item.quantity

    # return @ctx.order.shipping = shipping
    return @model.shipping = shippingRate

  taxRate: ()->
    return (@model.taxRate || 0) * 100

  tax: ()->
    return @model.tax = Math.ceil (@model.taxRate || 0) * @subtotal()

  total: ()->
    total = @subtotal() + @shipping() + @tax()

    @model.total = total
    return total

Invoice.register()

module.exports = Invoice
