sap.ui.controller "view.Master",

  onInit: ->
    @router = sap.ui.core.UIComponent.getRouterFor @
    @router.attachRouteMatched @onRouteMatched, @

    @query = @getView().byId "query"
    @productList = @getView().byId "productList"

  onRouteMatched: (evt) ->
    unless evt.getParameter("name") is "Master"
      return

  onSearch: (evt) ->
    # ここに検索処理を書きます。

  onItemPress: (evt) ->
    context = evt.getSource().getBindingContext()
    @router.navTo "Detail",
      id: context.getObject().ProductID

  onOpenDialog: (evt) ->
    unless @_viewSetting
      @_viewSetting = sap.ui.jsfragment "view.ViewSettings", @
    @_viewSetting.open()

  onChangeViewSettings: (evt) ->
    # ここにソートとフィルタ処理を書きます。
    