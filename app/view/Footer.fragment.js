(function() {
  sap.ui.jsfragment("view.Footer", {
    createContent: function(oController) {
      return new sap.m.Bar({
        contentRight: [
          new sap.m.Text({
            text: "mitsuruog 2014"
          })
        ]
      });
    }
  });

}).call(this);
