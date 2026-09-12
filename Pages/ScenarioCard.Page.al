namespace DefaultPublisher.ALProject1;

/// <summary>
/// Card page for viewing and editing a Scoring Scenario.
/// Shows weights, results, and the full supplier score breakdown.
/// </summary>
page 50102 "Scenario Card"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Scoring Scenario";
    Caption = 'Scoring Scenario';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique scenario code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description of the scoring scenario.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The item to evaluate suppliers for.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Item description.';
                }
                field("Required Qty"; Rec."Required Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Quantity needed for this scenario.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Current status of the scenario.';
                    StyleExpr = StatusStyle;
                }
            }

            group(Weights)
            {
                Caption = 'Scoring Weights (%)';

                field("Price Weight"; Rec."Price Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Weight for price score (default: 30%).';
                }
                field("Lead Time Weight"; Rec."Lead Time Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Weight for lead time score (default: 25%).';
                }
                field("Quality Weight"; Rec."Quality Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Weight for quality score (default: 20%).';
                }
                field("Reliability Weight"; Rec."Reliability Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Weight for reliability score (default: 15%).';
                }
                field("History Weight"; Rec."History Weight")
                {
                    ApplicationArea = All;
                    ToolTip = 'Weight for delivery history score (default: 10%).';
                }
            }

            group(Results)
            {
                Caption = 'Scoring Results';
                Visible = (Rec.Status <> Rec.Status::Draft);

                field("Best Vendor No."; Rec."Best Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The supplier with the highest total score.';
                    StyleExpr = 'Strong';
                }
                field("Best Vendor Name"; Rec."Best Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the best supplier.';
                    StyleExpr = 'Strong';
                }
                field("Best Vendor Score"; Rec."Best Vendor Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Total score of the best supplier.';
                    StyleExpr = 'Favorable';
                }
                field("Scored At"; Rec."Scored At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date and time when scoring was performed.';
                }
                field("PO Created"; Rec."PO Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether a Purchase Order has been created.';
                }
                field("PO No."; Rec."PO No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Purchase Order number created from this scenario.';
                }
            }

            part(SupplierScores; "Scenario Score Subpage")
            {
                ApplicationArea = All;
                Caption = 'Supplier Score Breakdown';
                SubPageLink = "Scenario Code" = field(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RunScoring)
            {
                ApplicationArea = All;
                Caption = 'Run Scoring';
                ToolTip = 'Evaluate suppliers using the scoring formula.';
                Image = CalculateCost;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ScoringEngine: Codeunit "Supplier Scoring Engine";
                begin
                    ScoringEngine.RunScoring(Rec.Code);
                    CurrPage.Update(false);
                end;
            }

            action(CreateDraftPO)
            {
                ApplicationArea = All;
                Caption = 'Create Draft PO';
                ToolTip = 'Create a Purchase Order in Draft status for the best vendor.';
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    POCreator: Codeunit "PO Draft Creator";
                begin
                    POCreator.CreateDraftPO(Rec.Code);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            "Scenario Status"::Draft:
                StatusStyle := 'Standard';
            "Scenario Status"::Scored:
                StatusStyle := 'Favorable';
            "Scenario Status"::"PO Created":
                StatusStyle := 'Strong';
        end;
    end;
}
