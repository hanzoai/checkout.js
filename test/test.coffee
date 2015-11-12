assert    = require 'assert'
should    = require('chai').should()

{getBrowser, TIMEOUT} = require './util'

parsePrice = (str) ->
  parseFloat str.match /[\d.]+/

describe "Checkout (#{process.env.BROWSER})", ->
  testPage = "http://localhost:#{process.env.PORT ? 3333}/widget.html"

  openWidget = (browser) ->
    browser
      .url testPage

      .waitForExist 'modal', TIMEOUT

      # Click the Buy button
      .click 'a.btn'
      .waitForExist '.crowdstart-active', TIMEOUT
      .waitForExist 'lineitem', TIMEOUT
      .waitForVisible 'lineitem:nth-of-type(2) .select2', TIMEOUT

  describe 'Changing the quantity of a line item', ->
    it 'should update line item cost', (done) ->
      unitPrice = 0

      openWidget getBrowser()
        # Select 2 for 'Such T-shirt
        .selectByValue('.crowdstart-items > lineitem:nth-of-type(2) select', '2')

        .getText '.crowdstart-items > lineitem:nth-of-type(2) .crowdstart-item-price'
        .then (text) ->
          console.log text
          unitPrice = parsePrice text

        .getText '.crowdstart-items > lineitem:nth-of-type(2) .crowdstart-item-total-price'
        .then (text) ->
          console.log text
          lineItemPrice = parsePrice text
          assert.strictEqual lineItemPrice, unitPrice * 2
        .end done

  describe 'Completing the form', ->
    it 'should work', (done) ->
      openWidget getBrowser()
        # Payment information
        .setValue '#user\\.email', 'test2@checkouttests.xyz'
        .setValue '#user\\.name', 'checkout test2'
        .setValue '#payment\\.account\\.number', '4242424242424242'
        .setValue '#payment\\.account\\.expiry', '1122'
        .setValue '#payment\\.account\\.cvc', '424'
        .click 'label[for=agreed]'
        .click 'confirm .crowdstart-button'
        # Billing information
        .waitForVisible 'shipping', TIMEOUT
        .setValue '#order\\.shippingAddress\\.line1', '1234 fake street'
        .setValue '#order\\.shippingAddress\\.city', 'fake city'
        .setValue '#order\\.shippingAddress\\.state', 'fake state'
        .setValue '#order\\.shippingAddress\\.postalCode', '55555'
        .click 'confirm .crowdstart-button'

        .waitForExist '.crowdstart-loader', TIMEOUT
        .waitForExist '.crowdstart-loader', TIMEOUT, true
        .waitForVisible 'thankyou', TIMEOUT
        .getHTML 'thankyou h1'
        .then (text) ->
          assert.strictEqual text, '<h1>Thank You!</h1>'
        .end done
