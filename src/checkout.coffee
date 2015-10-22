_ = require 'underscore'
theme = require './utils/theme.coffee'

riot = require 'riot'
window.riot = riot

crowdcontrol = require 'crowdcontrol'

Events = crowdcontrol.Events
Client = require 'crowdstart.js'

# These don't return anything but register stuff with crowdcontrol
require './events'
Views = require './views'
Widget = Views.Widget

require '../vendor/js/select2'
select2Css = require '../vendor/css/select2'

head = document.head || document.getElementsByTagName('head')[0]
style = document.createElement 'STYLE'
style.type = 'text/css'
if  style.styleSheet
  style.styleSheet.cssText = select2Css
else
  style.appendChild document.createTextNode select2Css
head.appendChild style

# Format of opts.config
# {
#   ########################
#   ### Order Overrides ####
#   ########################
#
#   currency:       string (3 letter ISO code)
#   taxRate:        number (decimal)
#   shippingRate:   number (per item cost in cents or base unit for zero decimal currencies)
#   termsUrl:       string (url of terms page)
# }
#
# Format of opts.social
# {
#   ##################################
#   ### Social Links and Messages ####
#   ##################################
#   facebook:       string (facebook account name)
#   facebookMsg:    string (share message)
#   googlePlus:     string (google plus username)
#   twitter:        string (twitter account name)
#   twitterMsg:     string (tweet message)
#   pinterest:      bool (show/hide pinterest button)
#   emailSubject:   string (email subject line)
#   emailNsg:       string (email body contents)
# }
#
# Format of opts.theme
# {
#   ######################
#   ### Theme Options ####
#   ######################
# }

class Checkout
  key: ''
  order: null
  user: null
  items: null
  itemUpdateQueue: null
  obs: null
  model: null
  config: null
  social: null
  theme: null

  currentScript: null
  stripeScript: ['choose', 'stripe', 'shipping', 'thankyou']
  paypalScript: ['choose', 'paypal', 'thankyou']

  constructor: (@key, opts = {})->
    @client = new Client(@key)

    search = /([^&=]+)=?([^&]*)/g
    q = window.location.href.split('?')[1]
    qs = {}
    if q?
      while (match = search.exec(q))
        qs[decodeURIComponent(match[1])] = decodeURIComponent(match[2])

    @user = opts.user || {}

    @order = {}
    @order = _.extend(@order, opts.order) if opts.order?

    @order.items        = []
    @order.currency     = opts.config?.currency         || @order.currency      || 'usd'
    @order.taxRate      = opts.config?.taxRate          || @order.taxRate       || 0
    @order.shippingRate = opts.config?.shippingRate     || @order.shippingRate  || 0
    @order.shippingAddress =
      country: 'us'

    if qs.referrer?
      @order.referrerId = qs.referrer || @order.referrerId

    @items = []
    @itemUpdateQueue = []

    @config = {}
    @config = _.extend(@config, opts.config) if opts.config?
    @config.termsUrl = opts.config?.termsUrl || ''

    @social = {}
    @social = _.extend(@social, opts.social) if opts.social?

    @theme = {}
    @theme = _.extend(@theme, opts.theme) if opts.theme?

    @model =
      user:     @user
      order:    @order
      config:   @config
      social:   @social
      scripts:
        stripe: @stripeScript
        paypal: @paypalScript

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

    @obs.trigger Events.Screen.UpdateScript, @stripeScript

    @obs.on Events.Checkout.Done, ()->

  open: ()->
    @obs.trigger Events.Modal.Open
    @obs.trigger Events.Modal.DisableClose
    setTimeout ()=>
      @obs.trigger Events.Modal.EnableClose
    , 600

    return false

  update: ()->
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

    @user = _.extend @user, user
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

    set = false
    if quantity == 0
      for item, i in @items
        if item.id == id
          break

      @items.splice i, 1
      @order.items.splice i, 1
      return

    for item, i in @items
      if item.id == id
        set = true
        item.quantity = quantity
        @items[i].quantity = quantity

    if !set
      @items.push
        id: item
        quantity: quantity

      @client.util.product(id).then((res)=>
        product = res.responseText
        @order.items.push
          productId: product.id
          productName: product.name
          quantity: quantity
          price: product.price
          listPrice: product.listPrice
        @_setItem()
      ).catch (err)->
        console.log "setItem Error: #{err}"
        @_setItem()
    else
      @_setItem()

if window.Crowdstart?
  window.Crowdstart.Checkout = Checkout
else
  window.Crowdstart =
    Checkout: Checkout

if module?
  module.exports = Checkout

# riot = require 'riot'
# analytics = require './utils/analytics'
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
