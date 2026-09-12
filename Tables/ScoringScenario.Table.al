namespace DefaultPublisher.ALProject1;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;
/// <summary>
/// Defines a scoring scenario: which item to evaluate, quantity needed,
/// and the weight of each scoring component.
/// </summary>
table 50102 "Scoring Scenario"
{
    Caption = 'Scoring Scenario';
    DataClassification = CustomerContent;
    DrillDownPageId = "Scenario Card";
    LookupPageId = "Scenario Card";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(4; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
        field(5; "Required Qty"; Decimal)
        {
            Caption = 'Required Quantity';
            MinValue = 0;
            DecimalPlaces = 0 : 2;
        }
        field(10; "Price Weight"; Decimal)
        {
            Caption = 'Price Weight (%)';
            InitValue = 30;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 2;
        }
        field(11; "Lead Time Weight"; Decimal)
        {
            Caption = 'Lead Time Weight (%)';
            InitValue = 25;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 2;
        }
        field(12; "Quality Weight"; Decimal)
        {
            Caption = 'Quality Weight (%)';
            InitValue = 20;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 2;
        }
        field(13; "Reliability Weight"; Decimal)
        {
            Caption = 'Reliability Weight (%)';
            InitValue = 15;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 2;
        }
        field(14; "History Weight"; Decimal)
        {
            Caption = 'History Weight (%)';
            InitValue = 10;
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 0 : 2;
        }
        field(20; "Status"; Enum "Scenario Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(21; "Best Vendor No."; Code[20])
        {
            Caption = 'Best Vendor No.';
            TableRelation = Vendor."No.";
            Editable = false;
        }
        field(22; "Best Vendor Name"; Text[100])
        {
            Caption = 'Best Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Best Vendor No.")));
            Editable = false;
        }
        field(23; "Best Vendor Score"; Decimal)
        {
            Caption = 'Best Vendor Score';
            DecimalPlaces = 2 : 4;
            Editable = false;
        }
        field(24; "Scored At"; DateTime)
        {
            Caption = 'Scored At';
            Editable = false;
        }
        field(25; "PO Created"; Boolean)
        {
            Caption = 'PO Created';
            Editable = false;
        }
        field(26; "PO No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
