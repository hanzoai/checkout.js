assert    = require 'assert'
should    = require('chai').should()

{getBrowser} = require './util'

parsePrice = (str) ->
  str = str.substring(1, str.length) # strip $
  parseFloat str

describe "Checkout (#{process.env.BROWSER})", ->
  testPage = "http://localhost:#{process.env.PORT ? 3333}/widget.html"
  browser  = null

  before (done) ->
    browser = getBrowser()
    browser.init done

  after (done) ->
    browser.end done

  describe 'Changing the quantity of a line item', ->
    it 'should update line item cost', (done) ->
      unitPrice = 0

      # Select 2 for 'Such T-shirt'
      browser
        .url testPage
        .url testPage
        .url testPage
        .url testPage
        .url testPage
        .url testPage

        .waitForExist 'modal', 50000

        # Click the Buy button
        .click 'a.btn'
        .waitForExist '.crowdstart-active', 5000
        .waitForExist '.crowdstart-line-item'
        .waitForVisible '.crowdstart-line-item:nth-child(2) .select2'

        # Select 2 for 'Such T-shirt
        .selectByValue('.crowdstart-invoice > div:nth-child(2) select', '2')

        .getText 'div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > span', (err, res) ->
          unitPrice = parsePrice res

        .getText 'div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div.crowdstart-col-1-3-bl.crowdstart-text-right.crowdstart-money', (err, res) ->
          lineItemPrice = parsePrice res
          assert.strictEqual lineItemPrice, unitPrice * 2
        .call done

  describe 'Completing the form', ->
    it 'should work', (done) ->
      browser
        # Setup page and modal
        .url testPage
        .waitForExist 'modal', 50000
        .click 'a.btn'
        .waitForExist '.crowdstart-active', 5000
        .waitForExist '.crowdstart-line-item'
        .waitForEnabled '#crowdstart-credit-card'
        .waitForVisible '.crowdstart-line-item:nth-child(2) .select2'

        # Payment information
        .setValue 'input#crowdstart-credit-card', '4242424242424242'
        .setValue 'input#crowdstart-expiry', '1122'
        .setValue '#crowdstart-cvc', '424'
        .click 'label[for=terms]'
        .click 'a.crowdstart-checkout-button'

        # Billing information
        .waitForEnabled '#crowdstart-line1'
        .setValue '#crowdstart-line1', '1234 fake street'
        .setValue '#crowdstart-city', 'fake city'
        .setValue '#crowdstart-state', 'fake state'
        .setValue '#crowdstart-postalCode', '55555'
        .click 'a.crowdstart-checkout-button'

        .waitForExist '.crowdstart-loader', 10000, true
        .getText '.crowdstart-thankyou > form > h1', (err, res) ->
          assert.strictEqual res, 'Thank You'
        .call done
