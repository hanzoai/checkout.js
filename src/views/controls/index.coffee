_ = require('underscore')

crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
InputView = crowdcontrol.view.form.InputView

helpers = crowdcontrol.view.form.helpers
helpers.defaultTagName = 'crowdstart-input'

class Input extends InputView
  tag: 'crowdstart-input'
  errorHtml: require '../../../templates/control/error.jade'
  html: require '../../../templates/control/input.jade'
  js:(opts)->
    @model = if opts.input then opts.input.model else @model

Input.register()

# views
class Static extends Input
  tag: 'crowdstart-static'
  html: '<span>{ model.value }</span>'

Static.register()

class Checkbox extends Input
  tag: 'crowdstart-checkbox'
  html: require '../../../templates/control/checkbox.jade'
  change: (event) ->
    value = event.target.checked
    if value != @model.value
      @obs.trigger Events.Input.Change, @model.name, value
      @model.value = value
      @update()

Checkbox.register()

class Select extends Input
  tag: 'crowdstart-select'
  html: require '../../../templates/control/select.jade'
  tags: false

  lastValueSet: null

  events:
    "#{Events.Input.Set}": (name, value) ->
      if name == @model.name && value?
        @clearError()
        @model.value = value
        # whole page needs to be updated for side effects
        riot.update()

  options: ()->
    return @selectOptions

  changed: false
  change: (event) ->
    value = $(event.target).val()
    if value != @model.value
      @obs.trigger Events.Input.Change, @model.name, value
      @model.value = value
      @changed = true
      @update()

  isCustom: (o)->
    options = o
    if !options?
      options = @options()

    for name, value of options
      if _.isObject value
        if !@isCustom value
          return false

      else if name == @model.value
        return false

    return true

  initSelect: ($select)->
    $select.select2(
      tags: @tags
      placeholder: @model.placeholder
      minimumResultsForSearch: Infinity
    ).change((event)=>@change(event))

  js:(opts)->
    super

    @selectOptions = opts.options

    @on 'update', ()=>
      $select = $(@root).find('select')
      if $select[0]?
        if !@initialized
          requestAnimationFrame ()=>
            @initSelect($select)
            @initialized = true
            @changed = true
        else if @changed
          requestAnimationFrame ()=>
            # this bypasses caching of select option names
            # no other way to force select2 to flush cache
            if @isCustom()
              $select.select('destroy')
              @initSelect($select)
            $select.select2('val', @model.value)
            @changed = false
      else
        requestAnimationFrame ()=>
          @update()

    @on 'unmount', ()=>
      $select = $(@root).find('select')

Select.register()

class QuantitySelect extends Select
  tag: 'crowdstart-quantity-select'
  options: ()->
    return {
      1: 1
      2: 2
      3: 3
      4: 4
      5: 5
      6: 6
      7: 7
      8: 8
      9: 9
    }

QuantitySelect.register()

class CountrySelect extends Select
  tag: 'crowdstart-country-select'
  options: ()->
    return require '../../data/countries'

  js: ()->
    @model.value = @model.value.toLowerCase() if @model.value?

    super

CountrySelect.register()

# tag registration
helpers.registerTag (inputCfg)->
  return inputCfg.hints.input
, 'crowdstart-input'

helpers.registerTag (inputCfg)->
  return inputCfg.hints.static
, 'crowdstart-static'

helpers.registerTag (inputCfg)->
  return inputCfg.hints.checkbox
, 'crowdstart-checkbox'

helpers.registerTag (inputCfg)->
  return inputCfg.hints.select
, 'crowdstart-select'

helpers.registerTag (inputCfg)->
  return inputCfg.hints['country-select']
, 'crowdstart-country-select'

helpers.registerTag (inputCfg)->
  return inputCfg.hints['quantity-select']
, 'crowdstart-quantity-select'

countryUtils = require '../../utils/country'

helpers.registerValidator ((inputCfg) -> return inputCfg.hints.postalRequired)
, (model, name)->
  value = model[name]
  if countryUtils.requiresPostalCode(model.country || '') && (!value? || value == '')
    throw new Error "Required for Selected Country"

  return value

helpers.registerValidator ((inputCfg) -> return inputCfg.hints.required)
, (model, name)->
  value = model[name]
  if _.isNumber(value)
    return value

  value = value?.trim()
  throw new Error "Required" if !value? || value == ''

  return value

helpers.registerValidator ((inputCfg) -> return inputCfg.hints.uppercase)
, (model, name)->
  value = model[name].toUpperCase()
  return value

helpers.registerValidator ((inputCfg) -> return inputCfg.hints.terms)
, (model, name)->
  value = model[name]
  if !value
    throw new Error 'Please read and agree to the terms and conditions.'
  return value

helpers.registerValidator ((inputCfg) -> return inputCfg.hints.name)
, (model, name)->
  value = model[name]

  i = value.indexOf ' '
  model.firstName = name.slice 0, i
  model.lastName = name.slice i+1
  return value

helpers.registerValidator ((inputCfg) -> return inputCfg.hints.cardnumber)
, (model, name)->
  value = model[name]
  return crowdcontrol.utils.shim.promise.new (resolve, reject)->
    requestAnimationFrame ()->
      if $('input[name=number]').hasClass('jp-card-invalid')
        reject new Error('Enter a valid card number')
      resolve value

helpers.registerValidator ((inputCfg) -> return inputCfg.hints.expiration)
, (model, name)->
  value = model[name]

  date = value.split '/'
  model.month = (date[0]).trim()
  model.year = ('' + (new Date()).getFullYear()).substr(0, 2) + (date[1]).trim()

  return crowdcontrol.utils.shim.promise.new (resolve, reject)->
    requestAnimationFrame ()->
      if $('input[name=expiry]').hasClass('jp-card-invalid')
        reject new Error('Enter a valid expiration date')
      resolve value

helpers.registerValidator ((inputCfg) -> return inputCfg.hints.cvc)
, (model, name)->
  value = model[name]
  return crowdcontrol.utils.shim.promise.new (resolve, reject)->
    requestAnimationFrame ()->
      if $('input[name=number]').hasClass('jp-card-invalid')
        reject new Error('Enter a valid CVC number')
      resolve value

emailRe = /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

helpers.registerValidator ((inputCfg) -> return inputCfg.hints.email)
, (model, name)->
  value = model[name]
  throw new Error "Enter a valid email" if !emailRe.test value
  return value

