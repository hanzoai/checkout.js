crowdcontrol = require 'crowdcontrol'
InputView = crowdcontrol.view.form.InputView

helpers = crowdcontrol.view.form.helpers
helpers.defaultTagName = 'crowdstart-input'

# views
class Static extends InputView
  tag: 'crowdstart-static'
  html: '<span>{ model.value }</span>'

Static.register()

# tag registration
helpers.registerTag (inputCfg)->
  return inputCfg.hints.static
, 'static'
