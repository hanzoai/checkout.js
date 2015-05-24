View = require '../view'
moneyHTML = require '../../templates/money'

module.exports = new View 'money', moneyHTML, (opts, view)->
  @displayPrice = 0
