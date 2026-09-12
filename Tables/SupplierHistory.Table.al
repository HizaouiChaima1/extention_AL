namespace DefaultPublisher.ALProject1;
using Microsoft.Purchases.Vendor;
/// <summary>
/// Logs individual delivery events for each supplier.
/// Tracks on-time performance and quality issues to calculate history_score.
/// </summary>
table 50101 "Supplier History"
{
    Caption = 'Supplier History';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
            NotBlank = true;
        }
        field(3; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(5; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(6; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(7; "Expected Delivery Date"; Date)
        {
            Caption = 'Expected Delivery Date';
        }
        field(8; "Actual Delivery Date"; Date)
        {
            Caption = 'Actual Delivery Date';
        }
        field(9; "On Time"; Boolean)
        {
            Caption = 'On Time';
        }
        field(10; "Quality Issue"; Boolean)
        {
            Caption = 'Quality Issue';
        }
        field(11; "Quantity Ordered"; Decimal)
        {
            Caption = 'Quantity Ordered';
            DecimalPlaces = 0 : 2;
        }
        field(12; "Quantity Received"; Decimal)
        {
            Caption = 'Quantity Received';
            DecimalPlaces = 0 : 2;
        }
        field(13; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DecimalPlaces = 2 : 5;
        }
        field(14; "Notes"; Text[250])
        {
            Caption = 'Notes';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(VendorIdx; "Vendor No.", "Order Date") { }
        key(ItemIdx; "Item No.", "Vendor No.") { }
    }
}
