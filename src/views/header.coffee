crowdcontrol = require 'crowdcontrol'
Events = crowdcontrol.Events
View = crowdcontrol.view.View

class Header extends View
  tag: 'header'
  html: require '../../templates/header.jade'

  # show the back button?
  showBack: true

  # Array index of screen form script being shown
  index: 0

  # array of referenced tags ot show
  scriptRefs: null

  # style attribute for progress width
  style: ''

  events:
    "#{ Events.Screen.SyncScript }": (scriptRefs, index)->
      @syncScript scriptRefs, index

  syncScript: (@scriptRefs, @index)->
    if @scriptRefs? && @scriptRefs[@index]?
      @showBack = @scriptRefs[@index].showBack
      @style = "width: #{ 100 / @scriptRefs.length }%"

    @update()

  back: ()->
    @obs.trigger "#{Events.Modal.Back}"

  close: ()->
    @obs.trigger "#{Events.Modal.Close}"

Header.register()

module.exports = Header
