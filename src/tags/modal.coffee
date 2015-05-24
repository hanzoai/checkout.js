View = require '../view'
modalHTML = require '../../templates/modal'
modalCSS = require '../../css/modal'

$ ()->
  $('head')
    .append($("<style>#{ modalCSS }</style>"))

module.exports = new View 'modal', modalHTML, ()->
