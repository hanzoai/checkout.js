module.exports =
  showError: (target, message, css = {})->
    hover = $(target)
      .parent()
      .children '.crowdstart-hover'

    if !hover[0]?
      hover = $(target)
        .parent()
        .append('<div class="crowdstart-hover" style="opacity:0">')
        .children '.crowdstart-hover'
      hover.append '<span class="crowdstart-message">'
      requestAnimationFrame ()->
        hover.removeAttr 'style'

    hover
      .closest('.crowdstart-form-control')
      .addClass('crowdstart-error')
      .find('.crowdstart-hover')
      .removeClass 'crowdstart-hidden'
      .find('.crowdstart-message')
      .text(message)
      .css css

  removeError: (event)->
    $el = $(event.target)
      .closest('.crowdstart-form-control')
      .removeClass('crowdstart-error')
      .find('.crowdstart-hover')
      .addClass 'crowdstart-hidden'
    setTimeout ()->
      $el.remove()
    , 500

  isPassword: (text)->
    return text.length >= 6

  isRequired: (text)->
    return text.length > 0

  isEmail: (email)->
    return email.match /[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?/
