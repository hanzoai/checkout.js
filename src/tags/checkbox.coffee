View = require '../view'
checkboxHTML = require '../../templates/checkbox'
checkboxCSS = require '../../css/checkbox'

$ ()->
  $('head')
    .append($("<style>#{ checkboxCSS }</style>"))

module.exports = new View 'checkbox', checkboxHTML, ()->
