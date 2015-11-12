crowdcontrol = require 'crowdcontrol'

InputConfig = crowdcontrol.view.form.InputConfig

module.exports = (name, placeholder, hints, value = '')->
  return new InputConfig(name, value, placeholder, hints)

