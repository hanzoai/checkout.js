assert    = require 'assert'
should    = require('chai').should()

{getBrowser} = require './util'

parsePrice = (str) ->
  str = str.substring(1, str.length) # strip $
  parseFloat str

sleep = (seconds) ->
  e = new Date().getTime() + (seconds * 1000)
  while (new Date().getTime() <= e)
    1

describe "Checkout (#{process.env.BROWSER})", ->
  @timeout 90000

  browser = getBrowser()
  testPage = "http://localhost:#{process.env.PORT ? 3333}/widget.html"

  describe 'Changing the quantity of a line item', ->
    it 'should update line item cost', (done) ->
      unitPrice = 0

      # Select 2 for 'Such T-shirt'
      browser
        .url testPage

        .waitForExist 'modal', ->
          sleep 1

        # Click the Buy button
        .click 'a.btn'

        .waitForExist '.crowdstart-active'

        .waitForExist '.crowdstart-line-item'

        .waitForVisible '.crowdstart-line-item:nth-child(2) .select2', ->
          sleep 1

        # Select 2 for 'Such T-shirt
        .click '.crowdstart-line-item:nth-child(2) .select2'

        .click '.select2-results__options > li:nth-child(3)'

        .getText 'div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > span', (err, res) ->
          unitPrice = parsePrice res

        .getText 'div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div.crowdstart-col-1-3-bl.crowdstart-text-right.crowdstart-money', (err, res) ->
          lineItemPrice = parsePrice res
          assert.strictEqual lineItemPrice, unitPrice * 2
        .call done

  describe 'Completing the form', ->
    it 'should work', (done) ->
      browser
        .url testPage
        .waitForExist 'modal', ->
          sleep 1
        .click 'a.btn'
        .waitForExist '.crowdstart-active'
        .waitForExist '.crowdstart-line-item'
        .waitForEnabled '#crowdstart-credit-card', ->
          sleep 1
        .setValue '#crowdstart-credit-card', '4242424242424242'
        .setValue '#crowdstart-expiry', '1122'
        .setValue '#crowdstart-cvc', '424'
        .click 'span.crowdstart-checkbox'
        .click 'a.crowdstart-checkout-button'
        .waitForEnabled '#crowdstart-line1', ->
          sleep 1
        .setValue '#crowdstart-line1', '1234 fake street'
        .setValue '#crowdstart-city', 'fake city'
        .setValue '#crowdstart-state', 'fake state'
        .setValue '#crowdstart-postalCode', '55555'
        .click 'a.crowdstart-checkout-button'
        .waitForExist '.crowdstart-loader', 10000, true, ->
          sleep 1
        .getText '.crowdstart-thankyou > form > h1', (err, res) ->
          assert.strictEqual res, 'Thank You'
        .call done
