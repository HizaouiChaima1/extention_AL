namespace DefaultPublisher.ALProject1;

using Microsoft.Inventory.Item;

/// <summary>
/// Modal dialog page that allows the user to confirm or change
/// the Item No. and Quantity before creating a Purchase Order.
/// </summary>
page 50106 "PO Input Dialog"
{
    PageType = StandardDialog;
    Caption = 'Confirm Purchase Order Details';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(OrderDetails)
            {
                Caption = 'Order Details';

                field(ItemNo; SelectedItemNo)
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    ToolTip = 'Select the item to include in the Purchase Order.';
                    TableRelation = Item."No.";
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        Item: Record Item;
                    begin
                        if Item.Get(SelectedItemNo) then
                            ItemDescription := Item.Description
                        else
                            ItemDescription := '';
                    end;
                }

                field(ItemDescription; ItemDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Item Description';
                    ToolTip = 'Description of the selected item.';
                    Editable = false;
                }

                field(Quantity; SelectedQty)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity';
                    ToolTip = 'Enter the quantity to order.';
                    MinValue = 0;
                    DecimalPlaces = 0 : 2;
                    ShowMandatory = true;
                }
            }
        }
    }

    /// <summary>
    /// Initialises the dialog with default values from the scenario.
    /// </summary>
    procedure SetDefaults(ItemNo: Code[20]; Qty: Decimal)
    var
        Item: Record Item;
    begin
        SelectedItemNo := ItemNo;
        SelectedQty := Qty;
        if Item.Get(SelectedItemNo) then
            ItemDescription := Item.Description;
    end;

    /// <summary>
    /// Returns the values chosen by the user.
    /// </summary>
    procedure GetValues(var ItemNo: Code[20]; var Qty: Decimal)
    begin
        ItemNo := SelectedItemNo;
        Qty := SelectedQty;
    end;

    var
        SelectedItemNo: Code[20];
        SelectedQty: Decimal;
        ItemDescription: Text[100];
}
