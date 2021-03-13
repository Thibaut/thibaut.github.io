###
 * Copyright 2013-2017 Thibaut Courouble
###

document = window.document

createElement = (tagName, className, innerHTML) ->
  el = document.createElement tagName
  el.className = className if className
  el.innerHTML = innerHTML if innerHTML
  el

addEvent = (el, event, fn) ->
  el.addEventListener event, fn, false

removeEvent = (el, event, fn) ->
  el.removeEventListener event, fn, false

transitionProp = transitionEvent = null

(->
  transitionPropertiesAndEventNames =
    'WebkitTransition': 'webkitTransitionEnd'
    'MozTransition'   : 'transitionend'
    'OTransition'     : 'oTransitionEnd'
    'transition'      : 'transitionend'

  for prop, event of transitionPropertiesAndEventNames when document.body.style[prop]?
    transitionProp = prop
    transitionEvent = event
    break
)()

class Gallery
  constructor: (@el) ->
    @list   = @findByClass 'gallery-list'
    @bar    = @findByClass 'gallery-bar'
    @length = @list.children.length

    @bar.appendChild el = createElement('a', 'gallery-prev', 'Previous')
    addEvent el, 'click', @slidePrev

    @bar.appendChild el = createElement('a', 'gallery-next', 'Next')
    addEvent el, 'click', @slideNext

    @bar.appendChild el = createElement('a', 'gallery-toggle', 'Fullscreen')
    addEvent el, 'click', @toggleFullScreen

    addEvent @el, 'mouseover', @onMouseover
    addEvent @list, 'click', @onClick

    @goTo 0

  findByClass: (className) ->
    @el.getElementsByClassName(className)[0]

  goTo: (n) ->
    return if @lock
    @setCursor n
    @setCurrent()

  slideTo: (n) ->
    return if @lock
    return @goTo n unless transitionEvent
    @lock = true

    if n > @cursor
      type = 'next'
      dir = 'left'
    else
      type = 'prev'
      dir = 'right'

    @setCursor n
    el = @list.children[@cursor]

    el.className += " #{type}"
    el.offsetWidth
    el.className += " #{dir}"
    @current.className += " #{dir}"

    callback = =>
      el.className = el.className.replace " #{type} #{dir}", ''
      @current.className = @current.className.replace " #{dir}", ''
      @setCurrent()
      @lock = false
      removeEvent @list, transitionEvent, callback

    addEvent @list, transitionEvent, callback

  setCursor: (n) ->
    @cursor = (if n < 0 then @length + n % @length else n) % @length
    @loadSlide @cursor
    @setCaption()

  setCurrent: ->
    @current?.className = @current.className.replace ' current', ''
    @current = @list.children[@cursor]
    @current.className += ' current'

  loadSlide: (n) ->
    el = @list.children[n]
    return unless el and el.tagName isnt 'A'

    img = createElement 'img', 'gallery-image'
    img.src = el.getAttribute 'data-src'
    img.setAttribute 'srcset', el.getAttribute('data-srcset') if el.hasAttribute('data-srcset')

    link = createElement 'a', 'gallery-item'
    link.href = img.src
    link.setAttribute 'target', '_blank'
    link.setAttribute 'data-caption', caption if caption = el.getAttribute('data-caption')
    link.appendChild(img)

    @list.replaceChild(link, el)

  setCaption: ->
    if caption = @list.children[@cursor].getAttribute('data-caption')
      @el.setAttribute 'data-caption', caption
    else
      @el.removeAttribute 'data-caption'

    @bar.appendChild @captionText = document.createTextNode('') unless @captionText
    @captionText.textContent = if @fullscreen
      "#{@cursor + 1}/#{@length}"
    else
      "# #{@cursor + 1} of #{@length}"

  slidePrev: =>
    @slideTo @cursor - 1
    @loadSlide @cursor - 1
    false

  slideNext: =>
    @slideTo @cursor + 1
    @loadSlide @cursor + 1
    false

  toggleFullScreen: =>
    if @fullscreen
      @leaveFullScreen()
      @fullscreen = false
    else
      @enterFullScreen()
      @fullscreen = true

    @setCaption()
    false

  enterFullScreen: ->
    @scrollTop = document.documentElement.scrollTop
    @el.className += ' gallery-fullscreen'
    @findByClass('gallery-toggle').textContent = 'Exit Fullscreen'
    document.documentElement.style.overflowY = 'hidden'

  leaveFullScreen: ->
    @el.className = @el.className.replace ' gallery-fullscreen', ''
    @findByClass('gallery-toggle').textContent = 'Fullscreen'
    document.documentElement.style.overflowY = 'scroll'
    document.documentElement.scrollTop = @scrollTop

  onClick: (event) =>
    unless @fullscreen and event.target.tagName is 'IMG'
      event.preventDefault()
      @toggleFullScreen()

  onMouseover: (event) =>
    return if @over
    @over = true
    @loadSlide 1
    addEvent window, 'keydown', @onKeydown
    addEvent @el, 'mouseout', @onMouseout

  onMouseout: (event) =>
    el = event.relatedTarget
    el = el.parentElement while el and el isnt @el
    return if el
    @over = false
    removeEvent window, 'keydown', @onKeydown
    removeEvent @el, 'mouseout', @onMouseout

  onKeydown: (event) =>
    return if event.ctrlKey or event.shiftKey or event.altKey or event.metaKey

    if event.keyCode is 37
      @slidePrev()
    else if event.keyCode is 39
      @slideNext()
    else if event.keyCode is 27 and @fullscreen
      @toggleFullScreen()
    else
      return

    false

onload = ->
  new Gallery el for el in document.querySelectorAll '.gallery'

document.addEventListener 'DOMContentLoaded', onload, false
document.body.className = document.body.className.replace 'noscript ', ''
document.body.className += ' touch' if typeof ontouchstart isnt 'undefined'
