crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class ScreenManager extends View
  tag: 'screen-manager'
  html: require '../../templates/screenmanager.jade'

  # Array index of screen form script being shown
  index: 0

  # Array of screen tags to show
  script: null

  # array of referenced tags ot show
  scriptRefs: null

  # style attribute for specifying the width of .crowdstart-screen-strip
  style: ''

  events:
    "#{ Events.Screen.UpdateScript }": (script, index)->
      @updateScript script, index

    "#{ Events.Screen.TryNext }": ()->
      @tryNext()

    "#{ Events.Screen.Next }": ()->
      @next()

    "#{ Events.Screen.Back }": ()->
      @back()

  tryNext: ()->
    if @index < @script.length
      @scriptRefs[@index]?.submit()

  next: ()->
    if @index < @script.length - 1
      @index++
      @updateConfirmAndBackAndInvoice()
      @update()

  back: ()->
    if @index > 0
      @index--
      @updateConfirmAndBackAndInvoice()
      @update()

  updateConfirmAndBackAndInvoice: ()->
    show = true
    disable = false
    if @scriptRefs? && @scriptRefs[@index]
      if @scriptRefs[@index].disableInvoice
        disable = true
        @obs.trigger Events.Invoice.Disable

      if !@scriptRefs[@index].showConfirm
        show = false
        @obs.trigger Events.Confirm.Hide

    if show
      @obs.trigger Events.Confirm.Show

    if !disable
      @obs.trigger Events.Invoice.Enable

  updateScript: (script, index = 0)->
    if @script == script
      if @index != index
        @index = index
        @updateConfirmAndBackAndInvoice()
        @update()
        return
      return

    @script = script
    @index = index

    requestAnimationFrame ()=>
      if @scriptRefs?
        for ref in @scriptRefs
          ref?.unmount()

      @scriptRefs = []

      $el = $('.crowdstart-screen-strip')
      $el.html ''

      total = @script.length
      for script in @script
        $el.append $("<#{ script }>")
        instance = riot.mount script,
          model: @model
          total: total
          screenManagerObs: @obs
          client: @client
        @scriptRefs.push instance[0]

      @updateConfirmAndBackAndInvoice()
      @update()

  js: (opts)->
    @client = opts.client

    @updateScript(opts.script || [])

    @on 'update', ()=>
      total = @script.length
      @style = "transform: translateX(-#{ @index * 100 / total }%); width: #{ total * 100 }%;"
      $root = $(@root)
      $root.width $root.parent().outerWidth()
      $children = $root.find('.crowdstart-screen-strip').children()
      for child, i in $children
        $child = $(child).children()
        $child.css('display', if i == @index then '' else 'none')

      @obs.trigger Events.Screen.SyncScript, @scriptRefs, @index

      # if @scriptRefs?[@index]?
      #   $root.height $(@scriptRefs[@index].root).height()

ScreenManager.register()

module.exports = ScreenManager
