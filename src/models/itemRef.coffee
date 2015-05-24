#ItemRef contains 2 pieces of data:
#
# 1) productId can be either a product id or product slug
# 2) quantity is the number of the items specified
#

module.exports = class ItemRef
  constructor: (@productId, @quantity=1)->
    @quantity = Math.min(Math.max(@quantity, 1), 9)
