(function() {
  sap.ui.jsfragment("view.SearchList", {
    createContent: function(oController) {
      return new sap.m.Table({
        id: oController.getView().createId("productList"),
        growing: true,
        growingThreshold: 5,
        growingTriggerText: "もっと見る",
        noDataText: "データがありません。",
        headerToolbar: this._createHeaderToolbar(oController),
        columns: this._createHeaderColumns(oController)
      });
    },
    _createHeaderToolbar: function(oController) {
      return new sap.m.Toolbar({
        content: [
          new sap.m.SearchField({
            id: oController.getView().createId("query"),
            search: [oController.onSearch, oController]
          }), new sap.m.Button({
            icon: "sap-icon://drop-down-list",
            press: [oController.onOpenDialog, oController]
          })
        ]
      });
    },
    _createHeaderColumns: function(oController) {
      return [
        new sap.m.Column({
          mergeDuplicates: true,
          header: new sap.m.Label({
            text: "Supplier"
          }),
          minScreenWidth: "Tablet",
          demandPopin: true
        }), new sap.m.Column({
          header: new sap.m.Label({
            text: "Category"
          }),
          minScreenWidth: "Tablet",
          demandPopin: true
        }), new sap.m.Column({
          header: new sap.m.Label({
            text: "Product"
          }),
          width: "12rem"
        }), new sap.m.Column({
          header: new sap.m.Label({
            text: "Order"
          }),
          minScreenWidth: "Tablet",
          demandPopin: true,
          hAlign: "Right"
        }), new sap.m.Column({
          header: new sap.m.Label({
            text: "Stock"
          }),
          minScreenWidth: "Tablet",
          demandPopin: true,
          hAlign: "Right"
        }), new sap.m.Column({
          header: new sap.m.Label({
            text: "Price"
          }),
          hAlign: "Right"
        })
      ];
    },
    _createTemplate: function(oController) {
      return new sap.m.ColumnListItem({
        type: "Navigation",
        press: [oController.onItemPress, oController],
        cells: [
          new sap.m.Text({
            text: "メーカー名"
          }), new sap.m.Text({
            text: "カテゴリ名"
          }), new sap.m.ObjectIdentifier({
            title: "商品名",
            text: "商品のスペック"
          }), new sap.m.ObjectNumber({
            number: "受注数"
          }), new sap.m.ObjectNumber({
            number: "在庫数"
          }), new sap.m.ObjectNumber({
            number: "価格",
            unit: "USD"
          })
        ]
      });
    }
  });

}).call(this);
