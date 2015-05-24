module.exports = class Payment
  constructor: ()->
    @type = 'stripe'
    @account =
      number: ''
      month: ''
      year: ''
      cvc: ''
