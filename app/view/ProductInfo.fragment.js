(function() {
  jQuery.sap.require("sap.ui.layout.form.SimpleForm");

  sap.ui.jsfragment("view.ProductInfo", {
    createContent: function(oController) {
      return new sap.m.ObjectHeader({
        title: "タイトル",
        number: "価格",
        numberUnit: "USD",
        statuses: [
          new sap.m.ObjectStatus({
            text: "受注数と在庫数",
            state: "Success"
          })
        ],
        attributes: [
          new sap.m.ObjectAttribute({
            text: "商品のスペック"
          })
        ]
      });
    }
  });

}).call(this);
