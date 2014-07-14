sap.ui.jsfragment "view.SupplierAddressForm",

  createContent: (oController) ->
    form = new sap.ui.layout.form.SimpleForm
      minWidth: 1024,
      editable: false
      content: [
        new sap.ui.core.Title
          text: "Company"
        new sap.m.Label
          text: "SupplierID"
        new sap.m.Text
          text: "メーカーID"
        new sap.m.Label
          text: "CompanyName"
        new sap.m.Text
          text: "メーカー名"
        new sap.ui.core.Title
          text: "Contact"
        new sap.m.Label
          text: "ContactName"
        new sap.m.Text
          text: "担当者"
        new sap.m.Label
          text: "ContactTitle"
        new sap.m.Text
          text: "肩書き"
        new sap.m.Label
          text: "PostalCode"
        new sap.m.Text
          text: "郵便番号"
        new sap.m.Label
          text: "Addreess"
        new sap.m.Text
          text: "住所"
        new sap.m.Label
          text: "Phone"
        new sap.m.Text
          text: "電話番号"
        new sap.m.Label
          text: "HomePage"
        new sap.m.Text
          text: "Webサイト"
      ]

    grid = new sap.ui.layout.Grid
      defaultSpan: "L12 M12 S12"
      hSpacing: 2
      width: "auto"
      content :[form]
