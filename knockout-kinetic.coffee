###
Knockout Kinetic plugin version 0.1.4
Copyright 2012 Christopher Currie - https://github.com/christophercurrie
License: MIT (http://www.opensource.org/licenses/mit-license.php)
###

do (factory = (ko, exports) ->

  expandConfig = (config) ->
      result = {}
      for key, value of ko.utils.unwrapObservable config
        realValue = ko.utils.unwrapObservable value
        result[key] = realValue if typeof realValue isnt 'undefined'
      result

  applyAnimations = (node, animations) ->
    for own key, value of animations
      do (key, value) ->
        trans = null
        if typeof node[key] == 'function'
          fn = (value) -> node[key](value)
          if ko.isSubscribable value
            value.subscribe (newValue) ->
              if trans then trans.stop()
              trans = fn newValue if newValue
          else
            fn value if value
    return

  applyEvents = (node, element, events) ->
    for own key, value of events
      do (key, value) -> node.on key, (evt) ->
        value element, evt
    return

  redraw = (node) ->
    if node.getStage()
      # while we'd like to only draw when the node changes, we can't reliably detect change
      # to the node content. It is thus incumbent on users to ensure their observables don't
      # fire too frequently to ensure good performance. To mitigate naive usage, we throttle
      # synchronous updates to attempt to ensure only the last change is drawn.

      # do this on a per stage/layer basis.
      drawTarget = if node.nodeType is 'Stage'
        # clear *all* per layer timeouts, since the stage will be redrawn
        clearTimeout layer._kktimeout for layer in node.children
        node
      else
        node.getLayer()

      drawTarget = if typeof node.draw == 'function' then node else node.getLayer()
      clearTimeout drawTarget._kktimeout
      drawTarget._kktimeout = setTimeout (do (drawTarget) -> -> drawTarget.draw()), 1

  makeBindingHandler = (nodeFactory) ->
    init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
      config = expandConfig valueAccessor()
      node = nodeFactory config, element.parentNode

      innerContext = bindingContext.createChildContext viewModel 
      ko.utils.extend innerContext, parentNode: node
      ko.applyBindingsToDescendants innerContext, element

      parentNode = bindingContext.parentNode
      if parentNode
        parentNode.add node
        ko.utils.domNodeDisposal.addDisposeCallback element, do (node) -> ->
          # Kinetic cascade removes children, so check if it's contained.
          # Kinetic also does not have a cheap check for this, so linear scan we go
          parent = node.getParent()
          if not parent then return
          for child in parent.children when child is node
            parent.remove node
            redraw parent
            break

      element.style.display = 'none' if element.style # won't have style if it's virtual
      element._kk = node
      applyAnimations node, allBindingsAccessor()['animate']
      applyEvents node, element, allBindingsAccessor()['events']
      { controlsDescendantBindings: true }

    update: (element, valueAccessor) ->
      node = element._kk
      config = expandConfig valueAccessor()
      node.setAttrs(config)
      redraw node

  for nodeType, ctor of Kinetic when typeof ctor == 'function'
    nodeFactory = do (nodeType, ctor) ->
      if nodeType == 'Stage'
        (config, parent) ->
          config['container'] = parent
          new ctor(config)
      else
        (config) -> new ctor(config)

    bindingName = "Kinetic.#{nodeType}"
    ko.bindingHandlers[bindingName] = makeBindingHandler nodeFactory
    ko.virtualElements.allowedBindings[bindingName] = true

  return
) ->
  # Module systems magic dance.
  # https://github.com/SteveSanderson/knockout.mapping/blob/5b2c61d7f91def6c1815f379fa6c10f78d0ef8e1/knockout.mapping.js

  if typeof require == 'function' && typeof exports == 'object' && typeof module == 'object'
    # CommonJS or Node: hard-coded dependency on 'knockout'
    factory(require('knockout'), exports)
  else if typeof define == 'function' && define['amd']
    # AMD anonymous module with hard-coded dependency on 'knockout'
    define(['knockout', 'exports'], factory)
  else
    # <script> tag: use the global `ko` object, attaching a `kinetic` property
    factory(ko, ko.kinetic = {})

