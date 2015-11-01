crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

input = require '../utils/input.coffee'

class LineItem extends FormView
  tag: 'lineitem'
  html: require '../../templates/lineitem.jade'

  renderCurrency: require('../utils/currency.coffee').renderUICurrencyFromJSON

  inputConfigs: [
    input('quantity', '', 'quantity-select parsenumber')
  ]

  invoiceObs: null
  disabled: false

  setDisabled: (state)->
    @disabled = state
    @update()

  js: (opts)->
    super

    @invoiceObs = opts.invoiceobs
    @invoiceObs.on Events.Invoice.Disable, ()=>
      @setDisabled true
    @invoiceObs.on Events.Invoice.Enable, ()=>
      @setDisabled false

    @currency = opts.currency

    @on 'update', ()=>
      if @disabled
        $(@root).find('select').prop('disabled', true)
      else
        $(@root).find('select').prop('disabled', false)

LineItem.register()

module.exports = LineItem
