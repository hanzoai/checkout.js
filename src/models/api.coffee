# api
#   key: publishable crowdstart api keys
#   store: the id of the store you want to access (optional)
#   cb: success callback
#   url: the path to your crowdstart instance, usually https://api.crowdstart.com (optional)
#

module.exports = class API
  constructor: (@key, @store='', @cb=((order)->), @url='https://api.crowdstart.com') ->

  getItems: (order, success, fail) ->
    itemRefs = order.itemRefs
    if itemRefs? && itemRefs.length > 0
      waitCount = order.itemRefs.length
      failed = false

      isDone = (product)->
        i = order.items.length
        order.items.push
          productId: product.id
          productSlug: product.slug
          productName: product.name
          quantity: itemRefs[i].quantity
          price: product.price
          listPrice: product.listPrice
          shipping: product.shipping

        if !failed && waitCount == order.items.length
          success order

      isFailed = ->
        failed = true
        fail.apply this, arguments if fail?

      for itemRef in order.itemRefs
        $.ajax
          url: if @store == '' then @url + '/product/' + itemRef.productId else @url + '/#{ @store }/product/' + itemRef.productId
          type: 'GET'
          headers:
            Authorization: @key
          contentType: 'application/json; charset=utf-8'
          dataType: 'json'
          success: isDone
          error: isFailed
    else
      order.items = []
      success order

  getCouponCode: (code, success, fail) ->
    $.ajax
      url: @url + '/coupon/' + code
      type: 'GET'
      headers:
        Authorization: @key
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      success: success
      error: fail

  charge: (model, success, fail) ->
    $.ajax
      url: if @store == '' then @url + '/charge' else @url + '/#{ @store }/charge'
      type: 'POST'
      headers:
        Authorization: @key
      contentType: 'application/json; charset=utf-8'
      data: JSON.stringify(model)
      dataType: 'json'
      success: (order) =>
        success order
        @cb order
      error: fail

  login: (email, password, success, fail)->
    $.ajax
      url: @url + '/account/login',
      type: 'POST',
      headers:
        Authorization: @key
      contentType: 'application/json; charset=utf-8'
      data: JSON.stringify({ email: email, password: password })
      dataType: 'json'
      success: success
      error: fail

  referrer: (order, program, success, fail) ->
    $.ajax
      url: @url + '/referrer',
      type: 'POST',
      headers:
        Authorization: @key
      contentType: 'application/json; charset=utf-8'
      data: JSON.stringify(
        program: program
        orderId: order.id
        userId: order.userId)
      dataType: 'json'
      success: success
      error: fail

  emailExists: (email, success, fail) ->
    $.ajax
      url: @url + '/account/exists/' + email
      type: 'GET'
      headers:
        Authorization: @key
      contentType: 'application/json; charset=utf-8'
      dataType: 'json'
      success: success
      error: fail
