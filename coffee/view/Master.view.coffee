sap.ui.jsview "view.Master",

  getControllerName: -> "view.Master"

  createContent: (oController) ->
    @page = new sap.m.Page
      title: "Product List"

    list = sap.ui.jsfragment "view.SearchList", oController
    footer = sap.ui.jsfragment "view.Footer", oController

    @page.addContent list
    @page.setFooter footer
    @page