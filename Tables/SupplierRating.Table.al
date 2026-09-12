namespace DefaultPublisher.ALProject1;
using Microsoft.Purchases.Vendor;
/// <summary>
/// Stores supplier quality, reliability, and delivery performance ratings.
/// Used by the Scoring Engine to calculate supplier scores.
/// </summary>
table 50100 "Supplier Rating"
{
    Caption = 'Supplier Rating';
    DataClassification = CustomerContent;
    DrillDownPageId = "Supplier Rating List";
    LookupPageId = "Supplier Rating List";
    fields
    {   field(1; "Vendor No."; Code[20])
        {   Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
            NotBlank = true;
  }
        field(2; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(3; "Quality Rating"; Decimal)
        {
            Caption = 'Quality Rating (0-5)';
            MinValue = 0;
            MaxValue = 5;
            DecimalPlaces = 1 : 2;
        }
        field(4; "Reliability Rate"; Decimal)
        {
            Caption = 'Reliability Rate (0-1)';
            MinValue = 0;
            MaxValue = 1;
            DecimalPlaces = 2 : 4;
        }
        field(5; "Lead Time Days"; Integer)
        {
            Caption = 'Lead Time (Days)';
            MinValue = 0;
        }
        field(6; "Delivery Performance"; Decimal)
        {
            Caption = 'Delivery Performance (0-1)';
            MinValue = 0;
            MaxValue = 1;
            DecimalPlaces = 2 : 4;
        }
        field(7; "Last Evaluation Date"; Date)
        {
            Caption = 'Last Evaluation Date';
        }
        field(8; "Total Orders"; Integer)
        {
            Caption = 'Total Orders';
            Editable = false;
        }
        field(9; "On Time Deliveries"; Integer)
        {
            Caption = 'On Time Deliveries';
            Editable = false;
        }
        field(10; "Quality Issues"; Integer)
        {
            Caption = 'Quality Issues';
            Editable = false;
        }
    }
    keys
    {   key(PK; "Vendor No.")
        {    Clustered = true;
        }
        key(QualityIdx; "Quality Rating") { }
        key(ReliabilityIdx; "Reliability Rate") { }
    }
}
