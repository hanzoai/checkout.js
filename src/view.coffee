riot = require 'riot'

class View
  tag:'view'
  html: '<div></div>'
  ctx: null
  js: ()->
  constructor: (@tag, @html, @js)->
    view = @
    riot.tag @tag, @html, (opts) ->
      @view = view
      @opts = opts
      view.ctx = @
      view.js.call(@, opts, view) if view.js?

  update: ()->
    @ctx.update() if @ctx?

module.exports = View
