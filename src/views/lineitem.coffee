crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

input = require '../utils/input.coffee'

class LineItem extends FormView
  tag: 'lineitem'
  html: require '../../templates/lineitem.jade'

  renderCurrency: require('../utils/currency.coffee').renderUICurrencyFromJSON

  inputConfigs: [
    input('quantity', '', 'quantity-select')
  ]

  js: (opts)->
    super
    @currency = opts.currency

LineItem.register()

module.exports = LineItem
