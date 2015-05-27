View = require '../view'
checkboxHTML = require '../../templates/checkbox'
checkboxCSS = require '../../css/checkbox'

form = require '../utils/form'

$ ()->
  $('head')
    .append($("<style>#{ checkboxCSS }</style>"))

module.exports = new View 'checkbox', checkboxHTML, ()->
  @checked = false
  # This is to fix safari
  @removeError = form.removeError

  @toggle = (event)=>
    @checked = !@checked
    @removeError(event)
