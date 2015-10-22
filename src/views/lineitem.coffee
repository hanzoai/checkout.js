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

  disabled: false

  events:
    "#{ Events.Invoice.Disable }": ()->
      @setDisabled true
    "#{ Events.Invoice.Enable }": ()->
      @setDisabled false

  setDisabled: (state)->
    @disabled = state
    @update()

  js: (opts)->
    super
    @currency = opts.currency

    @on 'update', ()=>
      if @disabled
        $(@root).find('select').prop('disabled', true)
      else
        $(@root).find('select').prop('disabled', false)

LineItem.register()

module.exports = LineItem
