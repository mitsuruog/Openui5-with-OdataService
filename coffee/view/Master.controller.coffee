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
    query = @query.getValue()
    #
    # 検索条件は"Contains", EQ", "StartsWith"など
    # 
    filters = [new sap.ui.model.Filter("ProductName", "Contains", query)]
    binding = @productList.getBinding "items"
    binding.filter filters, sap.ui.model.FilterType.Application

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
    params = evt.getParameters()
    binding = @productList.getBinding "items"

    #ソート設定
    sortSettings = []
    if params.sortItem
      path = params.sortItem.getKey()
      descending = params.sortDescending
      sortSettings.push new sap.ui.model.Sorter(path, descending)
    # [Issue] The following problem occurred: Request aborted.
    # [MEMO] 
    # このタイミングでバックエンドにリクエストが送られるが、直後のfilterにてabortされる。
    # silentオプションかsorterとfilter同時設定が出来る方法があればいいのにな。
    binding.sort sortSettings

    #フィルタ設定
    filterSettings = []
    jQuery.each params.filterItems, (i, item) ->
      settingArray = item.getKey().split "___"
      filter = new sap.ui.model.Filter settingArray[0], settingArray[1], settingArray[2], settingArray[3]
      filterSettings.push filter
    binding.filter filterSettings
    