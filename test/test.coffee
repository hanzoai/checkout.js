assert    = require 'assert'
should    = require('chai').should()

{getBrowser} = require './util'

parsePrice = (str) ->
  str = str.substring(1, str.length) # strip $
  parseFloat str

describe "Checkout (#{process.env.BROWSER})", ->
  browser = getBrowser()
  testPage = "http://localhost:#{process.env.PORT ? 3333}/widget.html"

  describe 'Changing the quantity of a line item', ->
    it 'should update line item cost', (done) ->
      unitPrice = 0

      # Select 2 for 'Such T-shirt'
      browser
        .url testPage

        # Click the Buy button
        .click 'a.btn'

        # Select 2 for 'Such T-shirt
        .click '/html/body/modal/div[1]/checkout/div/div[3]/div[2]/div[2]/div[1]/div[1]/span/span[1]/span'

        .click '/html/body/span/span/span[2]/ul/li[3]'

        .getText 'div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > span', (err, res) ->
          unitPrice = parsePrice res

        .getText 'div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div.crowdstart-col-1-3-bl.crowdstart-text-right.crowdstart-money', (err, res) ->
          lineItemPrice = parsePrice res
          assert.strictEqual lineItemPrice, unitPrice * 2

        .call done

  describe 'Completing the form', ->
    it 'should work', (done) ->
      browser
        .setValue '#crowdstart-credit-card', '4242424242424242'
        .setValue '#crowdstart-expiry', '1122'
        .setValue '#crowdstart-cvc', '424'
        .click 'span.crowdstart-checkbox'
        .click 'a.crowdstart-checkout-button'
        .setValue '#crowdstart-line1', '1234 fake street'
        .setValue '#crowdstart-city', 'fake city'
        .setValue '#crowdstart-state', 'fake state'
        .setValue '#crowdstart-postalCode', '55555'
        .click 'a.crowdstart-checkout-button'
        .waitForVisible 'body > modal > div.crowdstart-modal-target > checkout > div > div.crowdstart-forms > div.crowdstart-screens > div > div > form > h1', 20000
        .getText 'body > modal > div.crowdstart-modal-target > checkout > div > div.crowdstart-forms > div.crowdstart-screens > div > div > form > h1', (err, res) ->
           assert.strictEqual res, 'Thank You'
        .call done
