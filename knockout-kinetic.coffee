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
          fn = (value) ->
            try
              node[key](value)
            catch error
              return
          if ko.isSubscribable value
            value.subscribe (newValue) ->
              if trans then trans.stop()
              trans = fn newValue if newValue
          else
            fn value if value?
    return

  applyEvents = (node, element, events) ->
    # Remove all knockout events
    removeEvents = []
    for own baseName, listeners of node.eventListeners
      for listener in listeners
        if listener.name is 'knockout'
          removeEvents.push baseName
    node.off "#{name}.knockout" for name in removeEvents

    for own key, value of events
      do (key, value) -> node.on "#{key}.knockout", (evt) ->
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

  # For given virtual elements 'ancestor' and 'element' that represent
  # Kinetic nodes, find element's index within the set of elements that
  # share its parent Kinetic node.
  #
  # Because of the way the binding works, we know when this is called that
  # there will be no Kinetic nodes between 'ancestor' and 'element', though
  # there may be other non-Kinetic virtual elements. Thus only one level of
  # indexing needs to be tracked, as we won't descend into virtual elements
  # that implement Kinetic nodes.
  getKineticContainerIndex = (ancestor, element, state = { index: 0 }) ->
    isKineticBinding = (e) -> e._kk?

    child = ko.virtualElements.firstChild ancestor
    while child?
      if child._kk is element._kk then return state.index
      if isKineticBinding child
        state.index += 1
      else
        result = getKineticContainerIndex child, element, state
        if result >= 0 then return result
      child = ko.virtualElements.nextSibling child
     
    -1

  makeBindingHandler = (nodeFactory) ->
    init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
      params = expandConfig valueAccessor()
      config = if (params.config or params.animate or params.events) then params.config else params
      node = nodeFactory config, element.parentNode
      element._kk = node

      innerContext = bindingContext.createChildContext viewModel
      ko.utils.extend innerContext, 'knockout-kinetic':
        parentElement: element
        parentNode: node
      ko.applyBindingsToDescendants innerContext, element

      kk = bindingContext['knockout-kinetic'] || {}
      if kk.parentNode
        # We need to ensure that the current node is placed in its container
        # at the same index as the virtual element is within the containing
        # element.
        #
        # Obstacles:
        #
        # 1. Knockout does not provide an API to obtain the containing element
        #    of a virtual element.
        #    a. Virtual elements don't follow DOM nesting rules (they are all
        #       just comments, so they are siblings to the elements they
        #       "contain").
        #    b. The "containing" element may be a non knockout-kinetic element
        #       like "with" or "foreach", which must be traversed through to
        #       find the Kinetic container.
        #    c. The "sibling" elements may not actually be virtualBindings
        #       (plain text elements, etc) so we need to check of they have
        #       a Kinetic binding on them or they don't count.
        #    These bits are done in 'getKineticContainerIndex' above
        #
        # 2. Kinetic does not provide an API to insert elements in the middle
        #    of a container. Instead, one adds the element to the container
        #    and then calls 'setZIndex' to specify where in the stack it should
        #    go. (This mechanism implicitly modifies the zIndex of siblings).
        kk.parentNode.add node
        index = getKineticContainerIndex kk.parentElement, element
        if index < 0 then throw new Error("element not contained within parent")
        node.setZIndex index

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
      applyAnimations node, params.animate
      applyEvents node, element, params.events

      { controlsDescendantBindings: true }

    update: (element, valueAccessor) ->
      node = element._kk
      params = expandConfig valueAccessor()
      config = if params.config or params.events or params.animate then params.config else params
      node.setAttrs(config)
      applyAnimations node, params.animate
      applyEvents node, element, params.events
      redraw node

  register = (name, factory) ->
    ko.bindingHandlers[name] = makeBindingHandler factory
    ko.virtualElements.allowedBindings[name] = true

  exports['register'] = register

  for nodeType, ctor of Kinetic when typeof ctor == 'function'
    nodeFactory = do (nodeType, ctor) ->
      if nodeType == 'Stage'
        (config, parent) ->
          config['container'] = parent
          new ctor(config)
      else
        (config) -> new ctor(config)

    register "Kinetic.#{nodeType}", nodeFactory

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

