crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
FormView = crowdcontrol.view.form.FormView

input = require '../utils/input.coffee'

class LineItem extends FormView
  tag: 'linetime'
  html: require '../../templates/lineitem.jade'

  inputConfigs: [
    input('')
  ]

LineItem.register()

module.exports = LineItem
