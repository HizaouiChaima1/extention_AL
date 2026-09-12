namespace DefaultPublisher.ALProject1;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item;
/// <summary>
/// Links vendors to items with vendor-specific pricing and lead times.
/// Core data source for the scoring engine's price and lead time normalization.
/// </summary>
table 50104 "Supplier Item"
{
    Caption = 'Supplier Item';
    DataClassification = CustomerContent;
    DrillDownPageId = "Supplier Item List";
    LookupPageId = "Supplier Item List";

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
            NotBlank = true;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
            NotBlank = true;
        }
        field(3; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(4; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
        field(5; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            MinValue = 0;
            DecimalPlaces = 2 : 5;
        }
        field(6; "Lead Time Days"; Integer)
        {
            Caption = 'Lead Time (Days)';
            MinValue = 0;
        }
        field(7; "Min Order Qty"; Decimal)
        {
            Caption = 'Minimum Order Quantity';
            MinValue = 0;
            DecimalPlaces = 0 : 2;
        }
        field(8; "Preferred"; Boolean)
        {
            Caption = 'Preferred Supplier';
        }
        field(9; "Last Order Date"; Date)
        {
            Caption = 'Last Order Date';
        }
        field(10; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
        }
    }

    keys
    {
        key(PK; "Vendor No.", "Item No.")
        {
            Clustered = true;
        }
        key(ItemIdx; "Item No.", "Vendor No.") { }
        key(PriceIdx; "Item No.", "Unit Price") { }
    }
}
