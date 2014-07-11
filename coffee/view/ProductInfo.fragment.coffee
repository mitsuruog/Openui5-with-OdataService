jQuery.sap.require "sap.ui.layout.form.SimpleForm"

sap.ui.jsfragment "view.ProductInfo",

  createContent: (oController) ->
    new sap.m.ObjectHeader
      title: "{ProductName}"
      number: "{UnitPrice}"
      numberUnit: "USD"
      statuses: [
        new sap.m.ObjectStatus
          text: 
            parts: [
              {path: "UnitsInStock"}
              {path: "UnitsOnOrder"}
            ]
            formatter: (stock, order) ->
              "#{order} / #{stock} (Order/Stock)"
          state:
            path: "UnitsInStock"
            formatter: (stock) ->
              return if stock <= 10 then "Error" else "Success"
      ]
      attributes: [
        new sap.m.ObjectAttribute
          text: "{QuantityPerUnit}"

      ]