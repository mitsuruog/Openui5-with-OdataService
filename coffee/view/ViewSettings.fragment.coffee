sap.ui.jsfragment "view.ViewSettings",

  createContent: (oController) ->
    new sap.m.ViewSettingsDialog
      title: "ソート&フィルタ"
      confirm: [oController.onChangeViewSettings, oController]
      # ここにソート条件を書きます
      sortItems: [
        new sap.m.ViewSettingsItem
          text: "テキスト"
          key: "プロパティ名"
          selected: true
      ]
      # ここにフィルタ条件を書きます
      filterItems: [
        new sap.m.ViewSettingsFilterItem
          text: "テキスト"
          key: "プロパティ名"
          multiSelect: false
          items: [
            new sap.m.ViewSettingsItem
              text: "条件"
              key: "プロパティ"
          ]
      ]