(function() {
  sap.ui.controller("view.Detail", {
    onInit: function() {
      this.router = sap.ui.core.UIComponent.getRouterFor(this);
      this.router.attachRouteMatched(this.onRouteMatched, this);
      return this.tabs = this.getView().byId("tabs");
    },
    onRouteMatched: function(evt) {
      if (evt.getParameter("name") !== "Detail") {
        return;
      }
      this.productId = evt.getParameters()["arguments"].id;
      this.getView().bindElement("/Products(" + this.productId + ")");
      return this.tabs.getItems().forEach(function(item) {
        return item.bindElement(item.getKey());
      });
    },
    onNavBack: function(evt) {
      return window.history.go(-1);
    }
  });

}).call(this);
