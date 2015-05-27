View = require '../view'
shippingHTML = require '../../templates/shipping'

form = require '../utils/form'
country = require '../utils/country'

class ShippingView extends View
  tag: 'shipping'
  name: 'Shipping Info'
  html: shippingHTML
  constructor: ()->
    super(@tag, @html, @js)

  js: (opts, view)->
    self = @
    view.model = opts.model

    $ ()->
      requestAnimationFrame ()->
        $('.crowdstart-country-select')
          .select2()
          .on('change', (event)->
            self.updateCountry event
            self.update()
          )

    @country = country
    @countries = require '../data/countries'

    @user = opts.model.user
    @payment = opts.model.payment
    @order = opts.model.order

    @removeError = form.removeError

    @updateLine1        = (event) => @view.updateLine1(event)
    @updateLine2        = (event) => @view.updateLine2(event)
    @updateCity         = (event) => @view.updateCity(event)
    @updateState        = (event) => @view.updateState(event)
    @updatePostalCode   = (event) => @view.updatePostalCode(event)
    @updateCountry      = (event) => @view.updateCountry(event)

  updateLine1: (event)->
    line1 = event.target.value
    if form.isRequired line1
      @ctx.order.shippingAddress.line1 = line1
      return true

    form.showError event.target, 'Enter a Address'
    return false

  updateLine2: (event)->
    line2 = event.target.value
    @ctx.order.shippingAddress.line2 = line2
    return true

  updateCity: (event)->
    city = event.target.value
    if form.isRequired city
      @ctx.order.shippingAddress.city = city
      return true

    form.showError event.target, 'Enter a City'
    return false

  updateState: (event)->
    state = event.target.value
    if form.isRequired state
      @ctx.order.shippingAddress.state = state
      return true

    form.showError event.target, 'Enter a State'
    return false

  updatePostalCode: (event)->
    postalCode = event.target.value
    if country.requiresPostalCode(@ctx.order.shippingAddress.country) && !form.isRequired(postalCode)
      form.showError event.target, 'Enter a Postal Code'
      return false

    @ctx.order.shippingAddress.postalCode = postalCode
    return true

  updateCountry: (event)->
    c = event.target.value
    @ctx.order.shippingAddress.country = c
    return true

  validate: (success=(()->), fail=(()->))->
    if @updateLine1(target: $('#crowdstart-line1')[0]) &&
    @updateLine2(target: $('#crowdstart-line2')[0]) &&
    @updateCity(target: $('#crowdstart-city')[0]) &&
    @updateState(target: $('#crowdstart-state')[0]) &&
    @updatePostalCode(target: $('#crowdstart-postalCode')[0]) &&
    @updateCountry(target: $('#crowdstart-country-select')[0])
      success()
    else
      fail()

module.exports = new ShippingView

