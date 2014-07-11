sap.ui.jsview "view.App",

  getControllerName: -> "view.App"

  createContent: (oController) ->
    @setDisplayBlock true
    new sap.m.App "appConteiner"