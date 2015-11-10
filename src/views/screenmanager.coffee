riot = require 'riot'

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
      @scriptRefs[@index]?.show()
      @update()

  back: ()->
    if @index > 0
      @index--
      @updateConfirmAndBackAndInvoice()
      @scriptRefs[@index]?.show()
      @update()

  updateConfirmAndBackAndInvoice: ()->
    show = true
    disable = false
    if @scriptRefs? && @scriptRefs[@index]
      if !@scriptRefs[@index].showInvoice
        disable = true
        @obs.trigger Events.Invoice.Hide

      if !@scriptRefs[@index].showConfirm
        show = false
        @obs.trigger Events.Confirm.Hide

    if show
      @obs.trigger Events.Confirm.Show

    if !disable
      @obs.trigger Events.Invoice.Show

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

      @scriptRefs[@index]?.show()

      # sometimes a single update does not work
      @update()
      riot.update()

  js: (opts)->
    @client = opts.client

    @updateScript(opts.script || [])

    resizeFn = ()=>
      $root = $(@root)
      $root.width $root.parent().outerWidth()
      $root.height $($root.find('.crowdstart-screen-strip').children()[@index]).outerHeight()
      return $root

    $(window).on 'resize', resizeFn

    @on 'update', ()=>
      total = @script.length
      @style = "transform: translateX(-#{ @index * 100 / total }%); width: #{ total * 100 }%;"

    @on 'updated', ()=>
      $root = resizeFn()
      $children = $root.find('.crowdstart-screen-strip').children()
      for child, i in $children
        $child = $(child).children()
        if i == @index
          $child.css('display', '')
          do ($child)->
            requestAnimationFrame ()->
              $child.css 'opacity', 1
              $root.height $child.outerHeight()
        else
          $child.css 'opacity', 0
          do ($child)->
            setTimeout ()->
              $child.css 'display', 'none'
            , 500

      @obs.trigger Events.Screen.SyncScript, @scriptRefs, @index
      requestAnimationFrame ()->
        resizeFn()

      # if @scriptRefs?[@index]?
      #   $root.height $(@scriptRefs[@index].root).height()

    @on 'unmount', ()->
      $(window).off 'resize', resizeFn

ScreenManager.register()

module.exports = ScreenManager
