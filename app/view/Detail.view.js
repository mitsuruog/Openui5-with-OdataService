(function() {
  sap.ui.jsview("view.Detail", {
    getControllerName: function() {
      return "view.Detail";
    },
    createContent: function(oController) {
      var footer, info, tabs;
      this.page = new sap.m.Page({
        title: "Product Detail",
        showNavButton: true,
        navButtonPress: [oController.onNavBack, oController]
      });
      info = sap.ui.jsfragment("view.ProductInfo", oController);
      tabs = new sap.m.IconTabBar({
        id: this.createId("tabs"),
        items: [
          new sap.m.IconTabFilter({
            key: "Supplier",
            text: "Supplier",
            icon: "sap-icon://supplier",
            content: [sap.ui.jsfragment("view.SupplierAddressForm")]
          }), new sap.m.IconTabFilter({
            key: "Category",
            text: "Category",
            icon: "sap-icon://hint",
            content: [sap.ui.jsfragment("view.CategoryInfoForm")]
          })
        ]
      });
      footer = sap.ui.jsfragment("view.Footer", oController);
      this.page.addContent(info);
      this.page.addContent(tabs);
      this.page.setFooter(footer);
      return this.page;
    }
  });

}).call(this);
