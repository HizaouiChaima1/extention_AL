namespace DefaultPublisher.ALProject1;
using Microsoft.Purchases.Vendor;
/// <summary>
/// Stores the computed score breakdown for each supplier in a given scenario.
/// Populated by the Scoring Engine (Codeunit 50101).
/// </summary>
table 50103 "Scenario Supplier Score"
{   Caption = 'Scenario Supplier Score';
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Scenario Code"; Code[20])
        {
            Caption = 'Scenario Code';
            TableRelation = "Scoring Scenario".Code;
            NotBlank = true;
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
        field(10; "Price Score"; Decimal)
        {
            Caption = 'Price Score';
            DecimalPlaces = 2 : 4;
            Editable = false;
        }
        field(11; "Lead Time Score"; Decimal)
        {
            Caption = 'Lead Time Score';
            DecimalPlaces = 2 : 4;
            Editable = false;
        }
        field(12; "Quality Score"; Decimal)
        {
            Caption = 'Quality Score';
            DecimalPlaces = 2 : 4;
            Editable = false;
        }
        field(13; "Reliability Score"; Decimal)
        {
            Caption = 'Reliability Score';
            DecimalPlaces = 2 : 4;
            Editable = false;
        }
        field(14; "History Score"; Decimal)
        {
            Caption = 'History Score';
            DecimalPlaces = 2 : 4;
            Editable = false;
        }
        field(20; "Total Score"; Decimal)
        {
            Caption = 'Total Score';
            DecimalPlaces = 2 : 4;
            Editable = false;
        }
        field(21; "Rank"; Integer)
        {
            Caption = 'Rank';
            Editable = false;
        }
        field(22; "Supplier Unit Price"; Decimal)
        {
            Caption = 'Supplier Unit Price';
            DecimalPlaces = 2 : 5;
            Editable = false;
        }
        field(23; "Supplier Lead Time"; Integer)
        {
            Caption = 'Supplier Lead Time (Days)';
            Editable = false;
        }
    }

    keys
    {   key(PK; "Scenario Code", "Vendor No.")
        {
            Clustered = true;
        }
        key(ScoreIdx; "Scenario Code", "Total Score")
        {
            // Descending sort for ranking
        }
        key(RankIdx; "Scenario Code", "Rank") { }
    }
}
