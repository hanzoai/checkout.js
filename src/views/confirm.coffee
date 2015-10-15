crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

input = require '../utils/input.coffee'

class Confirm extends FormView
  tag: 'confirm'
  html: require '../../templates/confirm.jade'
  confirm: {}

  model:
    agreed: false

  inputConfigs: [
    input('agreed', '', 'checkbox')
  ]

  js: (opts)->
    super
    @config = opts.config

Confirm.register()

module.exports = Confirm
