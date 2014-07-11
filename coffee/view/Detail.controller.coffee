sap.ui.controller "view.Detail",

  onInit: ->
    @router = sap.ui.core.UIComponent.getRouterFor @
    @router.attachRouteMatched @onRouteMatched, @

    @tabs = @getView().byId "tabs"

  onRouteMatched: (evt) ->
    unless evt.getParameter("name") is "Detail"
      return

    # URLパラメータから商品IDを取得します。
    @productId = evt.getParameters().arguments.id

    # ここでEntityにアクセスします。
    @getView().bindElement "/Products(#{@productId})"

    # tabもデータをバインドします
    @tabs.getItems().forEach (item) ->
      item.bindElement item.getKey()


  onNavBack: (evt) ->
    window.history.go -1