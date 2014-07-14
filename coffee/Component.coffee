jQuery.sap.declare "com.mitsuruog.openui5.odata.Component"

sap.ui.core.UIComponent.extend "com.mitsuruog.openui5.odata.Component",
  metadata: 
    routing:
      config:
        viewType: "JS"
        viewPath: "view"
        targetControl: "appConteiner"
        clearTarget: false
        transition: "slide"
        targetAggregation: "pages"
      routes: [{
        pattern: ""
        name: "Master"
        view: "Master"
      }, {
        pattern: "product/{id}"
        name: "Detail"
        view: "Detail"
      }, {
        pattern: ":all*:"
        name: "NotFound"
        view: "NotFound"
      }]

  init: ->
    jQuery.sap.require "sap.m.routing.RouteMatchedHandler"

    # call overriden init.
    sap.ui.core.UIComponent.prototype.init.apply @, arguments

    # set custom behavior to the router.
    router = @getRouter()

    # initialize the router
    @routeHandler = new sap.m.routing.RouteMatchedHandler router
    router.initialize()

    # ここにOdataServiceのエンドポイントを設定します
    # /V3/Northwind/Northwind.svc/

  destroy: ->
    if @routeHandler
      @routeHandler.destroy()
    # call overriden destroy.
    sap.ui.core.UIComponent.prototype.destroy.apply @, arguments

  createContent: ->
    # create root view.
    view = sap.ui.view
      id: "app"
      viewName: "view.App"
      type: "JS"
      viewData: 
        component: @

    view