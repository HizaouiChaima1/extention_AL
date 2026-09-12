namespace DefaultPublisher.ALProject1;

/// <summary>
/// List page showing all supplier ratings with quality, reliability, and performance metrics.
/// </summary>
page 50100 "Supplier Rating List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Supplier Rating";
    Caption = 'Supplier Ratings';
    CardPageId = "Supplier Rating List";
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The vendor number.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'The vendor name.';
                }
                field("Quality Rating"; Rec."Quality Rating")
                {
                    ApplicationArea = All;
                    ToolTip = 'Quality rating on a scale of 0-5.';
                    StyleExpr = QualityStyle;
                }
                field("Reliability Rate"; Rec."Reliability Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Reliability rate from 0 to 1.';
                    StyleExpr = ReliabilityStyle;
                }
                field("Lead Time Days"; Rec."Lead Time Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Average lead time in days.';
                }
                field("Delivery Performance"; Rec."Delivery Performance")
                {
                    ApplicationArea = All;
                    ToolTip = 'Percentage of on-time deliveries (0-1).';
                    StyleExpr = DeliveryStyle;
                }
                field("Total Orders"; Rec."Total Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total number of orders placed with this vendor.';
                }
                field("On Time Deliveries"; Rec."On Time Deliveries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of deliveries made on time.';
                }
                field("Quality Issues"; Rec."Quality Issues")
                {
                    ApplicationArea = All;
                    ToolTip = 'Number of quality issues reported.';
                }
                field("Last Evaluation Date"; Rec."Last Evaluation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date of the last supplier evaluation.';
                }
            }
        }
    }

    var
        QualityStyle: Text;
        ReliabilityStyle: Text;
        DeliveryStyle: Text;

    trigger OnAfterGetRecord()
    begin
        // Color coding based on performance
        if Rec."Quality Rating" >= 4.0 then
            QualityStyle := 'Favorable'
        else
            if Rec."Quality Rating" >= 3.0 then
                QualityStyle := 'Ambiguous'
            else
                QualityStyle := 'Unfavorable';

        if Rec."Reliability Rate" >= 0.90 then
            ReliabilityStyle := 'Favorable'
        else
            if Rec."Reliability Rate" >= 0.80 then
                ReliabilityStyle := 'Ambiguous'
            else
                ReliabilityStyle := 'Unfavorable';

        if Rec."Delivery Performance" >= 0.90 then
            DeliveryStyle := 'Favorable'
        else
            if Rec."Delivery Performance" >= 0.80 then
                DeliveryStyle := 'Ambiguous'
            else
                DeliveryStyle := 'Unfavorable';
    end;
}
