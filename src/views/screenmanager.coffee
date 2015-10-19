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
    "#{ Events.Screen.UpdateScript }": (script)->
      @updateScript script

    "#{ Events.Screen.TryNext }": ()->
      @tryNext()

    "#{ Events.Screen.Next }": ()->
      @next()

    "#{ Events.Screen.Back }": ()->
      @back()

  tryNext: ()->
    console.log('try next')
    if @index < @script.length
      @script[@index]?.submit()

  next: ()->
    console.log('next')
    if @index < @script.length
      @index++
      @update()

  back: ()->
    console.log('back')
    if @index >= 0
      @index--
      @update()

  updateScript: (@script)->
    @index = 0

    requestAnimationFrame ()=>
      if @scriptRefs?
        for ref in @scriptRefs
          ref?.unmount()

      @scriptRefs = []

      $el = $('.crowdstart-screen-strip')
      $el.html ''

      total = @script.length
      for script, i in @script
        $el.append $("<#{ script }>")
        instance = riot.mount script, {model: @model, index: i, total: total, screenManagerObs: @obs}
        @scriptRefs.push instance[0]

      @style = "width: #{ total * 100 }%"
      @update()

  js: (opts)->
    @updateScript(opts.script || [])

ScreenManager.register()

module.exports = ScreenManager
