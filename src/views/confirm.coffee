crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

input = require '../utils/input.coffee'

class Confirm extends FormView
  tag: 'confirm'
  html: require '../../templates/confirm.jade'
  locked: false
  hide: false

  model:
    agreed: false

  inputConfigs: [
    input 'agreed', '', 'checkbox terms'
  ]

  events:
    "#{ Events.Confirm.Hide }": ()->
      @setHide true
    "#{ Events.Confirm.Show }": ()->
      @setHide false
    "#{ Events.Confirm.Lock }": ()->
      @setLock true
    "#{ Events.Confirm.Unlock}": ()->
      @setLock false

  setHide: (state)->
    @hide = state
    @update()

  setLock: (state)->
    @locked = state
    @update()

  js: (opts)->
    super
    @config = opts.config

  _submit: (event)->
    if @locked
      return false

    @obs.trigger Events.Screen.TryNext, event

Confirm.register()

module.exports = Confirm
