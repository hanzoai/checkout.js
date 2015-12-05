theme = require './utils/theme'
analytics = require './utils/analytics'

riot = require 'riot'
window.riot = riot

crowdcontrol = require 'crowdcontrol'
requestAnimationFrame = crowdcontrol.utils.shim.requestAnimationFrame

Events = crowdcontrol.Events
Crowdstart = require 'crowdstart.js'

# These don't return anything but register stuff with crowdcontrol
require './events'
Views = require './views'
Widget = Views.Widget

require '../vendor/js/select2'
select2Css = require '../vendor/css/select2'

head = document.head || document.getElementsByTagName('head')[0]
style = document.createElement 'STYLE'
style.type = 'text/css'
if style.styleSheet
  style.styleSheet.cssText = select2Css
else
  style.appendChild document.createTextNode select2Css
head.appendChild style

# Format of opts.config
# {
#   ########################
#   ### Order Overrides ####
#   ########################
#   narrow:             bool (always in narrow mode - 400px wide)
#   currency:           string (3 letter ISO code)
#   taxRate:            number (decimal) taxRate, overridden by opts.taxRates
#   shippingRate:       number (per item cost in cents or base unit for zero decimal currencies)
#   termsUrl:           string (url of terms page)
#   callToActions:      [string, string] (Up to 2 element array containing the text for the confirmation button)
#   shippingDetails:    string (description of when shipping happens)
#   showPromoCode:      bool (defaults: true, show the promo/coupon code)
#   processors: {
#       stripe:         bool (defaults: true, show the stripe checkout
#       paypal:         bool (defaults: false, show the paypal checkout
#   }
# }
#
# Format of opts.taxRates
# Tax rates are filtered based on exact string match of city, state, and country.
# Tax rates are evaluated in the order listed in the array.  This means if the first tax rate
# is matched, then the subsequent tax rates will not be evaluated.
# Therefore, list tax rates from specific to general
#
# If no city, state, or country is set, then the tax rate will be used if evaluated
#
# [
#   {
#     taxRate:  number (decimal tax rate)
#     city:     null or string (name of city where tax is charged)
#     state:    null or string (2 digit Postal code of US state or name of non-US state where tax is charged)
#     country:  null or string (2 digit ISO country code eg. 'us' where tax is charged)
#   }
# ]
#
# Format of opts.analytics
# {
#   pixels: map of string to string (map of pixel names to pixel url)
# }
#
# Format of opts.thankyou
# {
#   ###########################
#   ### Links and Messages ####
#   ###########################
#   header:         string (header message)
#   body:           string (thank you body message)
#   facebook:       string (facebook account name)
#   googlePlus:     string (google plus username)
#   twitter:        string (twitter account name)
#   twitterMsg:     string (tweet message)
#   pinterest:      bool (show/hide pinterest button)
#   emailSubject:   string (email subject line)
#   emailMsg:       string (email body contents)
# }
#
# Format of opts.theme
# {
#   ######################
#   ### Theme Options ####
#   ######################
#   background:             'white'
#   light:                  'white'
#   dark:                   'lightslategray'
#   medium:                 '#DDDDDD'
#   error:                  'red'
#   promoCodeForeground:    'white'
#   promoCodeBackground:    'lightslategray'
#   calloutForeground:      'white'
#   calloutBackground:      '#27AE60'
#   showPromoCode:          'steelblue'
#   progress:               '#27AE60'
#   spinner:                'rgb(255,255,255)'
#   spinnerTrail:           'rgba(255,255,255,0.2)'
#   fontFamily:             "'Helvetica Neue', Helvetica, Arial, sans-serif"
#   borderRadius:           5
# }
#
# Format of opts.test
# {
#   #####################
#   ### Test Options ####
#   #####################
#   endpoint:   string  (endpoint to hit with api)
#   paypal:     bool    (set to true if we want to use paypal sandbox)
# }
#
# Format of opts.referralProgram
# Referral Program Object

class Checkout
  key: ''
  order: null
  payment: null
  user: null
  itemUpdateQueue: null
  obs: null
  model: null
  config: null
  thankyou: null
  theme: null
  analytics: null
  referralProgram: null
  taxRates: null

  reset: true
  waits: 0

  currentScript: null
  script: ['payment', 'shipping', 'thankyou']

  constructor: (@key, opts = {})->
    @client = new Crowdstart.Api
      key: @key
      endpoint: opts?.test?.endpoint

    search = /([^&=]+)=?([^&]*)/g
    q = window.location.href.split('?')[1]
    qs = {}
    if q?
      while (match = search.exec(q))
        qs[decodeURIComponent(match[1])] = decodeURIComponent(match[2])

    @config =
      showPromoCode:    true
      termsUrl:         ''
      callToActions:    []
      processors:
        stripe: true
        paypal: true
    @config = $.extend(@config, opts.config) if opts.config?

    @user = opts.user || {}

    @order = {}
    @order = $.extend(@order, opts.order) if opts.order?

    @order.items        = []
    @order.currency     = opts.config?.currency         || @order.currency      || 'usd'
    @order.taxRate      = opts.config?.taxRate          || @order.taxRate       || 0
    @order.shippingRate = opts.config?.shippingRate     || @order.shippingRate  || 0
    @order.shippingAddress =
      country: 'us'
    @order.discount = 0
    if @config.processors.stripe
      @order.type = 'stripe'
    else if @config.processors.paypal
      @order.type = 'paypal'

    if qs.referrer?
      @order.referrerId = qs.referrer || @order.referrerId

    @payment =
      account:
        _type: 'stripe'
    @itemUpdateQueue = []

    @thankyou =
      header:   'Thank You!'
      body:     'Check Your Email For The Order Confirmation.'
    @thankyou = $.extend(@thankyou, opts.thankyou) if opts.thankyou?

    @theme = {}
    @theme = $.extend(@theme, opts.theme) if opts.theme?

    @test = {}
    @test = $.extend(@test, opts.test) if opts.test?

    @analytics = {}
    @analytics = $.extend(@analytics, opts.analytics) if opts.analytics?

    @referralProgram    = opts.referralProgram
    @taxRates           = opts.taxRates || []

    @model =
      user:             @user
      order:            @order
      payment:          @payment
      config:           @config
      thankyou:         @thankyou
      test:             @test
      analytics:        @analytics
      referralProgram:  @referralProgram
      taxRates:         @taxRates
      scripts:
        basic: @script

    @obs = {}
    riot.observable @obs

    modal = document.createElement 'MODAL'

    widgetTag = Widget.prototype.tag
    widget = document.createElement widgetTag.toUpperCase()
    widget.setAttribute 'model', '{ model }'
    widget.setAttribute 'obs', '{ obs }'
    widget.setAttribute 'client', '{ client }'

    modal.appendChild widget
    document.body.appendChild modal

    theme.setTheme @theme
    riot.mount 'modal',
      obs: @obs
      model: @model
      client: @client

    @obs.on Events.Checkout.Done, ()=>
      @reset = true

    if window.location.hash == '#checkoutsuccess'
      @obs.trigger Events.Screen.UpdateScript, @script, 2
      @reset = false
      @open()
      id = setInterval ()->
        $(window).resize()
      , 50
      setTimeout ()=>
        clearInterval id
        riot.update()
        @reset = true
      , 1000
    else
      @obs.trigger Events.Screen.UpdateScript, @script

  open: ()->
    if @reset
      @obs.trigger Events.Screen.UpdateScript, @script
      @reset = false

    @obs.trigger Events.Modal.Open
    @obs.trigger Events.Modal.DisableClose
    setTimeout ()=>
      @obs.trigger Events.Modal.EnableClose
    , 600

    for item in @order.items
      analytics.track 'Added Product',
        id: item.productId
        sku: item.productSlug
        name: item.productName
        quantity: item.quantity
        price: parseFloat(item.price / 100)

    analytics.track 'Viewed Checkout Step',
      step: 1

    $('.crowdstart-modal-target').css 'top', $(window).scrollTop() + 'px'

    return false

  one: ()->
    @obs.one.apply @obs, arguments

  on: ()->
    @obs.on.apply @obs, arguments

  off: ()->
    @obs.off.apply @obs, arguments

  update: ()->
    if @waits == 0
      #ugly hack to make each loops render in riot
      items = @order.items
      @order.items = []
      riot.update()

      @order.items = items
      riot.update()

      @obs.trigger Events.Checkout.Update,
        user:     @user
        order:    @order
        config:   @config

      riot.update()

  setConfig:(@config)->
    @update()

  setUser: (user = {})->
    if !user?
      return

    @user = $.extend @user, user
    @model.user = @user
    @update()

  setItem: (id, quantity)->
    @itemUpdateQueue.push [id, quantity]

    if @itemUpdateQueue.length == 1
      @_setItem()

  _setItem: ()->
    if @itemUpdateQueue.length == 0
      @update()
      return

    [id, quantity] = @itemUpdateQueue.shift()

    # delete item
    if quantity == 0
      for item, i in @order.items
        break if item.productId == id || item.productSlug == id

      if i < @order.items.length
        @order.items.splice i, 1
      @_setItem()
      return

    # try and update item quantity
    for item, i in @order.items
      continue if item.productId != id && item.productSlug != id

      item.quantity = quantity

      @_setItem()
      return

    # fetch up to date information at time of checkout openning
    # TODO: Think about revising so we don't report old prices if they changed after checkout is open
    @order.items.push
      id: id
      quantity: quantity

    # waiting for response so don't update
    @waits++

    @client.product.get(id).then((product)=>
      @waits--
      for item, i in @order.items
        if product.id == item.id || product.slug == item.id
          @_updateItem product, item
          break
      @_setItem()
    ).catch (err)=>
      @waits--
      console.log "setItem Error: #{err}"
      @_setItem()

  _updateItem: (product, item)->
    item.id             = undefined
    item.productId      = product.id
    item.productSlug    = product.slug
    item.productName    = product.name
    item.price          = product.price
    item.listPrice      = product.listPrice

Checkout.countries = require './data/countries'
Checkout.currencies = require './data/currencies'

if window.Crowdstart?
  window.Crowdstart.Checkout = Checkout
else
  window.Crowdstart =
    Checkout: Checkout

if module?
  module.exports = Checkout

# riot = require 'riot'
#
# require './tags/checkbox'
# require './tags/checkout'
# require './tags/modal'
# require './tags/progressbar'
# screens = require './screens'
# countries = require './data/countries'
#
# API = require './models/api'
# ItemRef = require './models/itemRef'
# User = require './models/user'
# Order = require './models/order'
# Payment = require './models/payment'
#
# theme = require './utils/theme'
#
#
# waitRef =
#   waitId: 0
#
# # checkout
# #  api:    object of API Class
# #  order:  object of Order Class
# #  config: config object such as:
# #    {
# #      screens: [screens.card],
# #      callToActions: ['Pre-order'],
# #    }
# #
# checkout = (api, order, user = (new User), config = {}) ->
#   config.callToActions  = config.callToActions  || ['Pre-Order', 'Confirm']
#   config.thankYouHeader = config.thankYouHeader || 'Thank You'
#   config.thankYouBody   = config.thankYouBody   || 'You will receive a confirmation email for your preorder.'
#   config.shareHeader    = config.shareHeader    || 'Follow us to get the latest updates'
#   config.screens        = config.screens        || [screens.card, screens.shipping]
#   config.termsUrl       = config.termsUrl       || 'http://www.crowdstart.com/terms'
#   config.internationalShipping  = config.internationalShipping || 0 #In Cents
#   config.shippingDetails        = config.shippingDetails || ''
#   config.allowDuplicateUsers    = config.allowDuplicateUsers || false
#
#   # Configure social sharing
#   config.shareMsg       = config.shareMsg       || ''
#   config.facebook       = config.facebook       || ''
#   config.googlePlus     = config.googlePlus     || ''
#   config.twitter        = config.twitter        || ''
#   config.twitterMsg     = config.twitterMsg     || ''
#   config.pinterest      = config.pinterest      || false
#   config.emailSubject   = config.emailSubject   || ''
#   config.emailBody      = config.emailBody      || ''
#   config.forgotPasswordUrl    = config.forgotPasswordUrl || ''
#
#   config.showPromoCode = config.showPromoCode || false
#
#   config.waitRef = waitRef
#
#   # Configure analytics/conversion tracking
#   config.pixels     = config.pixels || {}
#
#   api.getItems order, (order) ->
#     $modal = $('modal').remove()
#     $modal = $ '''
#       <modal>
#         <checkout api="{ opts.api }" model="{ opts.model }" config="{ opts.config }">
#         </checkout>
#       </modal>
#       '''
#
#     $(window).off('.crowdstart-modal-target')
#       .on('scroll.crowdstart-modal-target', ->
#         if !$modal.hasClass 'crowdstart-active'
#           $modal.children().first().css('top', $(@).scrollTop() + 'px'))
#       .on('resize.crowdstart-modal-target', ->
#         $modal.children().first().css('height', $(window).height() + 'px'))
#
#     requestAnimationFrame ->
#       $modal.children().first().css('height', $(window).height() + 'px')
#
#     for screen in config.screens
#       $modal.find('checkout').append $ """
#         <#{ screen.tag } api="{ opts.api }" model="{ opts.model }" config="{ opts.config }">
#         </#{ screen.tag }>
#         """
#
#     $('body').prepend $modal
#
#
#     for item in order.items
#       analytics.track 'Added Product',
#         id: item.productId
#         sku: item.productSlug
#         name: item.productName
#         quantity: item.quantity
#         price: parseFloat(item.price / 100)
#
#       analytics.track 'Viewed Checkout Step',
#         step: 1
#
#     model =
#       payment: (new Payment)
#       order:   order
#       user:    user
#
#     riot.mount 'modal',
#       api:    api
#       model:  model
#       config: config
#
# button = (sel)->
#   $el = $(sel)
#   $el.off('.crowdstart-button').on('click.crowdstart-button', ()->
#     $('modal').addClass('crowdstart-active')
#     clearTimeout waitRef.waitId
#     waitRef.waitId = setTimeout ()->
#       waitRef.waitId = 0
#     , 500
#     return false)
#
# if window?
#   if window.Crowdstart?
#     window.Crowdstart.API       = API
#     window.Crowdstart.Checkout  k checkout
#     window.Crowdstart.Button            = button
#     window.Crowdstart.ItemRef           = ItemRef
#     window.Crowdstart.Order             = Order
#     window.Crowdstart.User              = User
#     window.Crowdstart.ShippingCountries = countries
#     window.Crowdstart.setTheme          = theme.setTheme
#     window.Crowdstart.Events            = {}
#   else
#     window.Crowdstart =
#       API:      API
#       Checkout: checkout
#       Button:   button
#       ItemRef:  ItemRef
#       Order:    Order
#       User:     User
#       ShippingCountries: countries
#       setTheme: theme.setTheme
#       Events: {}
#
#   riot.observable window.Crowdstart.Events
#
# module.exports = checkout
