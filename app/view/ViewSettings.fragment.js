(function() {
  sap.ui.jsfragment("view.ViewSettings", {
    createContent: function(oController) {
      return new sap.m.ViewSettingsDialog({
        title: "ソート&フィルタ",
        confirm: [oController.onChangeViewSettings, oController],
        sortItems: [
          new sap.m.ViewSettingsItem({
            text: "テキスト",
            key: "プロパティ名",
            selected: true
          })
        ],
        filterItems: [
          new sap.m.ViewSettingsFilterItem({
            text: "テキスト",
            key: "プロパティ名",
            multiSelect: false,
            items: [
              new sap.m.ViewSettingsItem({
                text: "条件",
                key: "プロパティ"
              })
            ]
          })
        ]
      });
    }
  });

}).call(this);
