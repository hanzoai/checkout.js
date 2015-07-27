assert    = require 'assert'
should    = require('chai').should()

{getBrowser} = require './util'

# Removes the leading '$'
parsePrice = (str) ->
  str = str.substring(1, str.length)
  parseFloat str

parseTotal = (str) ->
  str = str.split(' ')[0] # strip currency ('$180.00 (USD)')
  parsePrice str

describe "Checkout (#{process.env.BROWSER})", ->
  testPage = "http://localhost:#{process.env.PORT ? 3333}/widget.html"

  setupModal = (browser) ->
    browser
      .url testPage
      .waitForExist 'modal', 5000

      # Click the Buy button
      .click 'a.btn'
      .waitForExist '.crowdstart-active', 5000
      .waitForExist '.crowdstart-line-item'
      .waitForVisible '.crowdstart-line-item:nth-child(2) .select2'

  describe 'Changing the quantity of a line item', ->
    # Long or undecipherable selectors
    selectors =
      quantity: '.crowdstart-invoice > div:nth-child(2) select'
      unitPrice: 'div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div:nth-child(2) > span'
      lineItemPrice: 'div.crowdstart-invoice > div:nth-child(2) > div:nth-child(2) > div.crowdstart-col-1-3-bl.crowdstart-text-right.crowdstart-money'

      # Such T-shirt (second line item)
      quantity2: '.crowdstart-invoice > div:nth-child(3) select'

      total: '.crowdstart-invoice > div:nth-child(9) .crowdstart-money'

    it 'should update line item cost and total cost', (done) ->
      unitPrice = 0

      setupModal(getBrowser())

        # Select 2 for 'Such T-shirt
        .selectByValue selectors.quantity, '2'

        .getText selectors.unitPrice, (err, res) ->
          unitPrice = parsePrice res

        # Test if unitPrice is correct
        .getText selectors.lineItemPrice, (err, res) ->
          lineItemPrice = parsePrice res
          assert.strictEqual lineItemPrice, unitPrice * 2

        # Remove the first line item
        .selectByValue selectors.quantity2, '0'

        # Test if total is correct
        .getText selectors.total, (err, res) ->
          total = parseTotal res
          assert.strictEqual total, unitPrice * 2

        .end done

  describe 'Completing the form', ->
    it 'should work', (done) ->
      setupModal(getBrowser())
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

        .end done

  describe 'Leaving fields empty', ->
    it 'should display alerts', (done) ->
      alerts =
        creditCard: '//*[@id="crowdstart-checkout"]/div[4]/div[1]/div/span'
        expiration: '//*[@id="crowdstart-checkout"]/div[6]/div/div[1]/div/span'
        cvc: '//*[@id="crowdstart-checkout"]/div[6]/div/div[2]/div/span'

      selectors =
        checkoutButton: 'a.crowdstart-checkout-button'

      setupModal(getBrowser())
        # Agree to terms
        .click 'label[for=terms]'

        .click selectors.checkoutButton
        .getText alerts.creditCard, (err, res) ->
          assert.strictEqual res, 'Enter a valid card number'
        .setValue 'input#crowdstart-credit-card', '4242424242424242'

        .click selectors.checkoutButton
        .getText alerts.expiration, (err, res) ->
          assert.strictEqual res, 'Enter a valid expiration date'
        .setValue 'input#crowdstart-expiry', '1122'

        .click selectors.checkoutButton
        .getText alerts.cvc, (err, res) ->
          assert.strictEqual res, 'Enter a valid CVC number'
        .setValue '#crowdstart-cvc', '424'

        .click selectors.checkoutButton
        # The text of the checkout button should change if our test
        # was successful
        .getText selectors.checkoutButton, (err, res) ->
          assert.strictEqual res, 'CONFIRM'

        .end done
