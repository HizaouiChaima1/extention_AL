namespace DefaultPublisher.ALProject1;

/// <summary>
/// Main dashboard page for the Supplier Scoring Agent.
/// Lists all scoring scenarios and provides actions to:
/// - Generate sample data
/// - Run scoring engine
/// - Create draft Purchase Orders
/// </summary>
page 50101 "Scoring Dashboard"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'Supplier, Scoring, Dashboard, Fournisseur, IA, AI, Score, Ranking';
    SourceTable = "Scoring Scenario";
    Caption = 'Supplier Scoring Dashboard';
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Scenarios)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique scenario code.';
                    StyleExpr = StatusStyle;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Scenario description.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The item to evaluate suppliers for.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Description of the item.';
                }
                field("Required Qty"; Rec."Required Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Required quantity to order.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Current status of the scenario.';
                    StyleExpr = StatusStyle;
                }
                field("Best Vendor No."; Rec."Best Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The vendor with the highest score.';
                }
                field("Best Vendor Name"; Rec."Best Vendor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Name of the best vendor.';
                }
                field("Best Vendor Score"; Rec."Best Vendor Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Score of the best vendor (0-100).';
                }
                field("PO No."; Rec."PO No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Created Purchase Order number.';
                }
            }
        }
        area(FactBoxes)
        {
            part(ScoreDetails; "Scenario Score Subpage")
            {
                ApplicationArea = All;
                Caption = 'Supplier Scores';
                SubPageLink = "Scenario Code" = field(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(DataGeneration)
            {
                Caption = 'Data Generation';

                action(GenerateSampleData)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Sample Data';
                    ToolTip = 'Creates all demo data: vendors, items, bank accounts, ratings, history, invoices, and scenarios.';
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    var
                        DataGen: Codeunit "Sample Data Generator";
                    begin
                        DataGen.GenerateAllData();
                        CurrPage.Update(false);
                    end;
                }
            }

            group(ScoringActions)
            {
                Caption = 'Scoring';

                action(RunScoring)
                {
                    ApplicationArea = All;
                    Caption = 'Run Scoring';
                    ToolTip = 'Evaluate all suppliers for the selected scenario using the AI scoring formula.';
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

                action(RunScoringAll)
                {
                    ApplicationArea = All;
                    Caption = 'Run Scoring (All Scenarios)';
                    ToolTip = 'Run scoring for all Draft scenarios.';
                    Image = AllLines;

                    trigger OnAction()
                    var
                        Scenario: Record "Scoring Scenario";
                        ScoringEngine: Codeunit "Supplier Scoring Engine";
                        Count: Integer;
                    begin
                        Scenario.SetRange(Status, "Scenario Status"::Draft);
                        if Scenario.FindSet() then
                            repeat
                                ScoringEngine.RunScoring(Scenario.Code);
                                Count += 1;
                            until Scenario.Next() = 0;
                        Message('Scoring completed for %1 scenario(s).', Count);
                        CurrPage.Update(false);
                    end;
                }
            }

            group(PurchaseOrderActions)
            {
                Caption = 'Purchase Orders';

                action(CreateDraftPO)
                {
                    ApplicationArea = All;
                    Caption = 'Create Draft PO';
                    ToolTip = 'Create a Purchase Order in Draft (Open) status for the best-ranked supplier.';
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

                action(CreateAllDraftPOs)
                {
                    ApplicationArea = All;
                    Caption = 'Create All Draft POs';
                    ToolTip = 'Create Purchase Orders for all scored scenarios that do not have a PO yet.';
                    Image = CreateDocuments;

                    trigger OnAction()
                    var
                        POCreator: Codeunit "PO Draft Creator";
                    begin
                        POCreator.CreateDraftPOsForAllScenarios();
                        CurrPage.Update(false);
                    end;
                }
            }
        }

        area(Navigation)
        {
            action(ViewRatings)
            {
                ApplicationArea = All;
                Caption = 'Supplier Ratings';
                ToolTip = 'View all supplier ratings and performance metrics.';
                Image = Vendor;
                RunObject = page "Supplier Rating List";
            }

            action(ViewSupplierItems)
            {
                ApplicationArea = All;
                Caption = 'Supplier Items';
                ToolTip = 'View the vendor-item price matrix.';
                Image = ItemAvailability;
                RunObject = page "Supplier Item List";
            }

            action(OpenScenarioCard)
            {
                ApplicationArea = All;
                Caption = 'Scenario Details';
                ToolTip = 'Open the detailed scenario card with score breakdown.';
                Image = ViewDetails;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "Scenario Card";
                RunPageLink = Code = field(Code);
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
