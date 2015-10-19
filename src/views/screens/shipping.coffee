crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
Screen = require './screen'

input = require '../../utils/input.coffee'

class Shipping extends Screen
  tag: 'shipping'
  html: require '../../../templates/screens/shipping.jade'
  inputConfigs: [
    input 'order.shippingAddress.line1',        '123 Street',       'input required'
    input 'order.shippingAddress.line2',        '123 Apt',          'input required'
    input 'order.shippingAddress.city',         'City',             'input required'
    input 'order.shippingAddress.state',        'State',            'input required'
    input 'order.shippingAddress.postalCode',   'Zip/Postal Code',  'input requiredforcountry:US'
    input 'order.shippingAddress.country',      '',                 'input required'
  ]

Shipping.register()

module.exports = Shipping
