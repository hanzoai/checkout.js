# Order contains 2 pieces of data:
#
# 1) currency is the ISO 4217 3 letter code such for a currency such as 'usd'
# 2) items is in the form of:
#
#  [
#    {
#      productId: 'awesome-widget',
#      quantity: 1,
#    },
#    {
#      productId: 'GFDNJgfklherre',
#      quantity: 1,
#    }
#  ]
#
#  productId can be either a product id or product slug
#

module.exports = class Order
  constructor: (@currency, @itemRefs, @shippingAddress={country: 'us'})->
    @items=[]
