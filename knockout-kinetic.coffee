###
Knockout Kinetic plugin version 0.1.2
Copyright 2012 Christopher Currie - https://github.com/christophercurrie
License: MIT (http://www.opensource.org/licenses/mit-license.php)
###

do (factory = (ko, exports) ->

  expandConfig = (config) ->
      result = {}
      for key, value of ko.utils.unwrapObservable config
        result[key] = ko.utils.unwrapObservable value
      result

  makeBindingHandler = (nodeFactory) ->
    init: (element, valueAccessor, allBindingsAccessor, viewModel, bindingContext) ->
      config = expandConfig valueAccessor()
      node = nodeFactory(config, element.parentNode)
      innerContext = bindingContext.extend
        parentNode: node

      ko.applyBindingsToDescendants innerContext, element
      bindingContext.parentNode.add node if bindingContext.parentNode
      element.style.display = 'none' if element.style # won't have style if it's virtual
      element._kk = node
      { controlsDescendantBindings: true }

    update: (element, valueAccessor) ->
      node = element._kk
      config = expandConfig valueAccessor()
      updated = false
      for key, value of config
        # Hack! I don't think `attrs` is a part of the Kinetic Node API
        if value == node.attrs[key] then continue
        node.attrs[key] = value
        updated = true
      node.getLayer().draw() if updated and node.getParent()

  for nodeType, ctor of Kinetic when typeof ctor == 'function'
    nodeFactory = do (nodeType, ctor) ->
      if nodeType == 'Stage'
        (config, parent) ->
          config['container'] = parent
          new ctor(config)
      else
        (config) -> new ctor(config)

    bindingName = "Kinetic.#{nodeType}"
    ko.bindingHandlers[bindingName] = makeBindingHandler(nodeFactory)
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

