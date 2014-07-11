sap.ui.controller "view.App",

  onInit: ->
    @router = sap.ui.core.UIComponent.getRouterFor @
    @router.attachRouteMatched @onRouteMatched, @

  onRouteMatched: (evt, param) ->
    unless evt.getParameter("name") is "App"
      return