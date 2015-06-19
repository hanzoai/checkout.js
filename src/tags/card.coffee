View = require '../view'
cardHTML = require '../../templates/card'

form = require '../utils/form'

class CardView extends View
  tag: 'card'
  name: 'Payment Info'
  html: cardHTML
  constructor: ->
    super(@tag, @html, @js)

  js: (opts, view) ->
    view.model = opts.model

    $ ->
      requestAnimationFrame ->
        if $('.crowdstart-card')[0]?
          card = new Card
            form: 'form#crowdstart-checkout'
            container: '.crowdstart-card'
            width: 180

        $('.crowdstart-card')
          .css(
            'margin-top': '-93px'
            'margin-left': '103px')
          .children()
          .css
            top: '50px'
            height: '192px'
            '-webkit-transform': 'scale(0.514285714285714)'
            '-ms-transform': 'scale(0.514285714285714)'
            transform: 'scale(0.514285714285714)'

    @api = opts.api
    @user = opts.model.user
    @payment = opts.model.payment
    @order = opts.model.order
    @login = false
    @password = ''

    @removeError = form.removeError

    @updateEmail        = (event) => @view.updateEmail(event)
    @updateName         = (event) => @view.updateName(event)
    @updateCreditCard   = (event) => @view.updateCreditCard(event)
    @updateExpiry       = (event) => @view.updateExpiry(event)
    @updateCVC          = (event) => @view.updateCVC(event)

  updateName: (event) ->
    name = event.target.value
    if form.isRequired name
      @ctx.user.name = name

      i = name.indexOf ' '
      @ctx.user.firstName = name.slice(0, i)
      @ctx.user.lastName = name.slice(i+1)
      return true
    else
      form.showError event.target, 'Enter the name on your credit card'
      return false

  updateEmail: (event) ->
    email = event.target.value
    if form.isEmail email
      if @ctx.user.email != email
        @ctx.api.emailExists email, (data)=>
          @ctx.login = data.exists
          @update()
          if @ctx.login
            requestAnimationFrame ()->
              form.showError $('#crowdstart-password')[0], 'Enter the password for this account'

      @ctx.user.email = email

      return true
    else
      form.showError event.target, 'Enter a valid email'
      return false

  updatePassword: (event)->
    if !@ctx.login
      return true

    password = event.target.value
    if form.isPassword password
      @ctx.password = password

      return true
    else
      form.showError event.target, 'Enter a valid password'
      return false

  updateCreditCard: (event) ->
    cardNumber = event.target.value
    if form.isRequired cardNumber
      @ctx.payment.account.number = cardNumber

      requestAnimationFrame ->
        if $(event.target).hasClass('jp-card-invalid')
          form.showError event.target, 'Enter a valid card number'
      return true
    else
      form.showError event.target, 'Enter a valid card number'
      return false

  updateExpiry: (event) ->
    expiry = event.target.value
    if form.isRequired expiry
      date = expiry.split '/'
      @ctx.payment.account.month = (date[0]).trim()
      @ctx.payment.account.year = ('' + (new Date()).getFullYear()).substr(0, 2) + (date[1]).trim()

      requestAnimationFrame ->
        if $(event.target).hasClass('jp-card-invalid')
          form.showError event.target, 'Enter a valid expiration date', width: '150px'
      return true
    else
      form.showError event.target, 'Enter a valid expiration date', width: '150px'
      return false

  updateCVC: (event) ->
    cvc = event.target.value
    if form.isRequired cvc
      @ctx.payment.account.cvc = cvc

      requestAnimationFrame ->
        if $(event.target).hasClass('jp-card-invalid')
          form.showError event.target, 'Enter a valid CVC number', width: '140px'
      return true
    else
      form.showError event.target, 'Enter a valid CVC number', width: '140px'
      return false

  validate: (success=(->), fail=(->))->
    if @updateEmail(target: $('#crowdstart-email')[0]) &&
    @updateName(target: $('#crowdstart-name')[0]) &&
    @updatePassword(target: $('#crowdstart-password')[0]) &&
    @updateCreditCard(target: $('#crowdstart-credit-card')[0]) &&
    @updateExpiry(target: $('#crowdstart-expiry')[0]) &&
    @updateCVC(target: $('#crowdstart-cvc')[0])
      if @ctx.login
        @ctx.api.login(
          @ctx.user.email
          @ctx.password
          (token)=>
            @ctx.user.id = JSON.parse(atob(token.split('.')[1]))['user-id']
            success()
          ()->
            form.showError $('#crowdstart-password')[0], 'Email or password was invalid'
            fail())
        return
      requestAnimationFrame ()->
        if $('.jp-card-invalid').length == 0
          success()
        else
          fail()
    else
      fail()

module.exports = new CardView
