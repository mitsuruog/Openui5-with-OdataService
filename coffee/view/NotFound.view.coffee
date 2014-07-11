sap.ui.jsview "view.NotFound",

  getControllerName: -> "view.NotFound"

  createContent: (oController) ->
    @page = new sap.m.Page
      title: "Not Found"

    @page