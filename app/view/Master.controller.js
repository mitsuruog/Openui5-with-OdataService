(function() {
  sap.ui.controller("view.Master", {
    onInit: function() {
      this.router = sap.ui.core.UIComponent.getRouterFor(this);
      this.router.attachRouteMatched(this.onRouteMatched, this);
      this.query = this.getView().byId("query");
      return this.productList = this.getView().byId("productList");
    },
    onRouteMatched: function(evt) {
      if (evt.getParameter("name") !== "Master") {

      }
    },
    onSearch: function(evt) {},
    onItemPress: function(evt) {
      var context;
      context = evt.getSource().getBindingContext();
      return this.router.navTo("Detail", {
        id: context.getObject().ProductID
      });
    },
    onOpenDialog: function(evt) {
      if (!this._viewSetting) {
        this._viewSetting = sap.ui.jsfragment("view.ViewSettings", this);
      }
      return this._viewSetting.open();
    },
    onChangeViewSettings: function(evt) {}
  });

}).call(this);
