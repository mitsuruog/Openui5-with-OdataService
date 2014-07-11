sap.ui.jsview "view.Detail",

  getControllerName: -> "view.Detail"

  createContent: (oController) ->
    @page = new sap.m.Page
      title: "Product Detail"
      showNavButton: true
      navButtonPress: [oController.onNavBack, oController]

    info = sap.ui.jsfragment "view.ProductInfo", oController

    tabs = new sap.m.IconTabBar
      id: @createId("tabs")
      items: [
        new sap.m.IconTabFilter
          key: "Supplier"
          text: "Supplier"
          icon: "sap-icon://supplier"
          content: [
            sap.ui.jsfragment "view.SupplierAddressForm"
          ]
        new sap.m.IconTabFilter
          key: "Category"
          text: "Category"
          icon: "sap-icon://hint"
          content: [
            sap.ui.jsfragment "view.CategoryInfoForm"
          ]
      ]

    footer = sap.ui.jsfragment "view.Footer", oController

    @page.addContent info
    @page.addContent tabs
    @page.setFooter footer
    @page