riot = require 'riot'
window.riot = riot

crowdcontrol = require 'crowdcontrol'

Events = crowdcontrol.Events
Client = require 'crowdstart.js'

require './events'
require './views/modal'

class Checkout
  key: ''
  order: null
  user: null
  items: null
  itemUpdateQueue: null
  obs: null

  constructor: (@key)->
    $modal = $('<modal><h1>YAY</h1></modal>')
    $('body').append($modal)

    riot.mount('modal')

    @client = new Client(@key)

    search = /([^&=]+)=?([^&]*)/g
    q = window.location.href.split('?')[1]
    qs = {}
    if q?
      while (match = search.exec(q))
        qs[decodeURIComponent(match[1])] = decodeURIComponent(match[2])

    @order =
      items: []

    if qs.referrer?
      @order.referrerId = qs.referrer

    @items = []
    @itemUpdateQueue = []

    @obs = {}
    riot.observable(@obs)

  open: ()->
    @obs.trigger Events.Modal.Open
    @obs.trigger Events.Modal.DisableClose
    setTimeout ()=>
      @obs.trigger Events.Modal.EnableClose
    , 500

  update: ()->
    @obs.trigger Events.Checkout.Update,
      user: @user
      order: @order
      config: @config

  setConfig:(@config)->
    @update()

  setUser: (@user)->
    @update()

  updateItem: (id, quantity)->
    @itemUpdateQueue.push [id, quantity]

    if @itemUpdateQueue.length == 1
      @_updateItem()

  _updateItem: ()->
    if itemUpdateQueue.length == 0
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
        @set = true
        item.quantity = quantity
        @items[i].quantity = quantity

    if set
      @items.push
        id: item
        quantity: quantity

      @client.util.product(id).then((res)=>
        @order.items.push(res.responseText)
        @_updateItem()
      ).catch (err)->
        console.log "updateItem Error: #{err}"
        @_updateItem()

if window.Crowdstart?
  window.Crowdstart.Checkout = Checkout
else
  window.Crowdstart =
    Checkout: Checkout

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
