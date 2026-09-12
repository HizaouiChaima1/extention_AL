namespace DefaultPublisher.ALProject1;

/// <summary>
/// Subpage (ListPart) showing the detailed score breakdown per supplier
/// for a given scenario. Used in Scenario Card and Dashboard FactBox.
/// </summary>
page 50103 "Scenario Score Subpage"
{
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = "Scenario Supplier Score";
    Caption = 'Supplier Scores';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Scores)
            {
                field(Rank; Rec.Rank)
                {
                    ApplicationArea = All;
                    ToolTip = 'Supplier rank (1 = best).';
                    StyleExpr = RankStyle;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Vendor number.';
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Vendor name.';
                }
                field("Total Score"; Rec."Total Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Weighted total score (0-100).';
                    StyleExpr = ScoreStyle;
                }
                field("Price Score"; Rec."Price Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Normalized price score (lower price = higher score).';
                }
                field("Lead Time Score"; Rec."Lead Time Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Normalized lead time score (shorter = higher).';
                }
                field("Quality Score"; Rec."Quality Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Quality score = (rating / 5) × 100.';
                }
                field("Reliability Score"; Rec."Reliability Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Reliability score = reliability_rate × 100.';
                }
                field("History Score"; Rec."History Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'History score = delivery_performance × 100.';
                }
                field("Supplier Unit Price"; Rec."Supplier Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'This supplier''s unit price for the item.';
                }
                field("Supplier Lead Time"; Rec."Supplier Lead Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'This supplier''s lead time in days.';
                }
            }
        }
    }

    var
        RankStyle: Text;
        ScoreStyle: Text;

    trigger OnAfterGetRecord()
    begin
        if Rec.Rank = 1 then
            RankStyle := 'Favorable'
        else
            if Rec.Rank <= 3 then
                RankStyle := 'Ambiguous'
            else
                RankStyle := 'Standard';

        if Rec."Total Score" >= 80 then
            ScoreStyle := 'Favorable'
        else
            if Rec."Total Score" >= 60 then
                ScoreStyle := 'Ambiguous'
            else
                ScoreStyle := 'Unfavorable';
    end;
}
