crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class Invoice extends View
  tag: 'invoice'
  html: require '../../templates/invoice.jade'
  checkoutObs: null

  renderCurrency: require('../utils/currency.coffee').renderUICurrencyFromJSON

  js: (opts)->
    @checkoutObs = opts.checkoutObs

  subtotal: ()->
    items = @model.items
    subtotal = 0
    for item in items
      subtotal += item.price * item.quantity
    # subtotal -= @discount()

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
