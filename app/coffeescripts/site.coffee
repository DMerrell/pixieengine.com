# Notifications
window.notify = (message, delay) ->
  $.pnotify
    pnotify_text: message
    pnotify_delay: delay

# Clickable
$(".clickable").live 'click', ->
  document.location = $(this).find("a").eq(0).attr("href")

# Tooltips
window.showTooltip = (element, html) ->
  position = element.offset() || {top: 50, left: 50}

  if !element.offset()
    $("#tooltip .icon").hide()
  else
    $("#tooltip .icon").show()

  $("#tooltip").find(".content").html(html)

  tooltipHeight = $('#tooltip').height()

  position.left += element.width() + 30
  position.top -= tooltipHeight / 2

  $("#tooltip").stop().offset(position).fadeIn()

window.hideTooltip = ->
  $("#tooltip").stop().fadeOut()

$("#tooltip").live
  mouseenter: -> $(this).css('opacity', 1)
  mouseleave: -> $(this).css('opacity', 0.4)

# Local Storage
getVal = (key) ->
  if localStorage
    try
      JSON.parse(localStorage[key])
    catch error
      undefined

setVal = (key, value) ->
  if localStorage
    localStorage[key] = value

$ ->
  # THEME
  setLightTheme = (active) ->
    $('#fullscreen').toggleClass('light', active)
    $('iframe').contents().find('html').toggleClass("light", active)
    $('.bulb').toggleClass("on", active)

    setVal('light', active)

  $('.bulb').click ->
    $(this).toggleClass('on')

    setLightTheme $(this).hasClass('on')

  if active = (getVal('light') || $("body").is(".light"))
    setLightTheme active

  # Display Flash Notice
  $("#flashes .notice").each ->
    notify($(this).html())

  # Tipsy
  $('.tipsy').tipsy
    delayIn: 200
    delayOut: 500
    fade: 50
    gravity: 'w'
    opacity: 1
