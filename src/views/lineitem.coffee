crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

input = require '../utils/input'

class LineItem extends FormView
  tag: 'lineitem'
  html: require '../../templates/lineitem.jade'

  renderCurrency: require('../utils/currency').renderUICurrencyFromJSON

  inputConfigs: [
    input('quantity', '', 'quantity-select parsenumber')
  ]

  invoiceObs: null

  js: (opts)->
    super

    @currency = opts.currency

LineItem.register()

module.exports = LineItem
