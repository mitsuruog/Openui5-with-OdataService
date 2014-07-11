(function() {
  sap.ui.jsview("view.Master", {
    getControllerName: function() {
      return "view.Master";
    },
    createContent: function(oController) {
      var footer, list;
      this.page = new sap.m.Page({
        title: "Product List"
      });
      list = sap.ui.jsfragment("view.SearchList", oController);
      footer = sap.ui.jsfragment("view.Footer", oController);
      this.page.addContent(list);
      this.page.setFooter(footer);
      return this.page;
    }
  });

}).call(this);
