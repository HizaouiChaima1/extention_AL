namespace DefaultPublisher.ALProject1;

using Microsoft.Purchases.Vendor;

/// <summary>
/// AI Scoring Engine: evaluates and ranks suppliers for a given scenario.
/// 
/// Formula:
///   total_score = price_score × 0.30
///               + lead_time_score × 0.25
///               + quality_score × 0.20
///               + reliability_score × 0.15
///               + history_score × 0.10
///
/// Where:
///   price_score      = (1 - (price - min_price) / (max_price - min_price)) × 100
///   lead_time_score  = (1 - (lead_time - min_lead) / (max_lead - min_lead)) × 100
///   quality_score    = (quality_rating / 5) × 100
///   reliability_score = reliability_rate × 100
///   history_score    = delivery_performance × 100
/// </summary>
codeunit 50101 "Supplier Scoring Engine"
{
    /// <summary>
    /// Runs the full scoring process for a scenario:
    /// 1. Finds all suppliers for the scenario's item
    /// 2. Calculates normalized scores
    /// 3. Ranks suppliers
    /// 4. Updates the scenario with the best vendor
    /// </summary>
    procedure RunScoring(ScenarioCode: Code[20])
    var
        Scenario: Record "Scoring Scenario";
        SupplierItem: Record "Supplier Item";
        SupplierRating: Record "Supplier Rating";
        ScenarioScore: Record "Scenario Supplier Score";
        MinPrice: Decimal;
        MaxPrice: Decimal;
        MinLeadTime: Decimal;
        MaxLeadTime: Decimal;
        PriceScore: Decimal;
        LeadTimeScore: Decimal;
        QualityScore: Decimal;
        ReliabilityScore: Decimal;
        HistoryScore: Decimal;
        TotalScore: Decimal;
        SupplierCount: Integer;
    begin
        if not Scenario.Get(ScenarioCode) then
            Error('Scenario %1 not found.', ScenarioCode);

        if Scenario."Item No." = '' then
            Error('Scenario %1 has no Item No. specified.', ScenarioCode);

        // ── Step 1: Clear previous scores ──
        ScenarioScore.SetRange("Scenario Code", ScenarioCode);
        ScenarioScore.DeleteAll();

        // ── Step 2: Find min/max for normalization ──
        SupplierItem.SetRange("Item No.", Scenario."Item No.");
        if not SupplierItem.FindSet() then
            Error('No suppliers found for item %1.', Scenario."Item No.");

        MinPrice := 999999999;
        MaxPrice := 0;
        MinLeadTime := 999999999;
        MaxLeadTime := 0;
        SupplierCount := 0;

        repeat
            SupplierCount += 1;
            if SupplierItem."Unit Price" < MinPrice then
                MinPrice := SupplierItem."Unit Price";
            if SupplierItem."Unit Price" > MaxPrice then
                MaxPrice := SupplierItem."Unit Price";
            if SupplierItem."Lead Time Days" < MinLeadTime then
                MinLeadTime := SupplierItem."Lead Time Days";
            if SupplierItem."Lead Time Days" > MaxLeadTime then
                MaxLeadTime := SupplierItem."Lead Time Days";
        until SupplierItem.Next() = 0;

        // ── Step 3: Calculate scores for each supplier ──
        SupplierItem.FindSet();
        repeat
            // Price Score (lower price = higher score)
            if MaxPrice = MinPrice then
                PriceScore := 100
            else
                PriceScore := (1 - (SupplierItem."Unit Price" - MinPrice) / (MaxPrice - MinPrice)) * 100;

            // Lead Time Score (shorter lead time = higher score)
            if MaxLeadTime = MinLeadTime then
                LeadTimeScore := 100
            else
                LeadTimeScore := (1 - (SupplierItem."Lead Time Days" - MinLeadTime) / (MaxLeadTime - MinLeadTime)) * 100;

            // Quality, Reliability, and History from Supplier Rating
            QualityScore := 0;
            ReliabilityScore := 0;
            HistoryScore := 0;

            if SupplierRating.Get(SupplierItem."Vendor No.") then begin
                QualityScore := (SupplierRating."Quality Rating" / 5) * 100;
                ReliabilityScore := SupplierRating."Reliability Rate" * 100;
                HistoryScore := SupplierRating."Delivery Performance" * 100;
            end;

            // Total Score with configurable weights
            TotalScore :=
                PriceScore * (Scenario."Price Weight" / 100) +
                LeadTimeScore * (Scenario."Lead Time Weight" / 100) +
                QualityScore * (Scenario."Quality Weight" / 100) +
                ReliabilityScore * (Scenario."Reliability Weight" / 100) +
                HistoryScore * (Scenario."History Weight" / 100);

            // Insert score record
            ScenarioScore.Init();
            ScenarioScore."Scenario Code" := ScenarioCode;
            ScenarioScore."Vendor No." := SupplierItem."Vendor No.";
            ScenarioScore."Price Score" := PriceScore;
            ScenarioScore."Lead Time Score" := LeadTimeScore;
            ScenarioScore."Quality Score" := QualityScore;
            ScenarioScore."Reliability Score" := ReliabilityScore;
            ScenarioScore."History Score" := HistoryScore;
            ScenarioScore."Total Score" := TotalScore;
            ScenarioScore."Supplier Unit Price" := SupplierItem."Unit Price";
            ScenarioScore."Supplier Lead Time" := SupplierItem."Lead Time Days";
            ScenarioScore.Insert(true);
        until SupplierItem.Next() = 0;

        // ── Step 4: Calculate ranks ──
        CalculateRanks(ScenarioCode);

        // ── Step 5: Update scenario with best vendor ──
        UpdateScenarioBestVendor(ScenarioCode);

        Message('Scoring completed for scenario %1.\\%2 suppliers evaluated.', ScenarioCode, SupplierCount);
    end;

    /// <summary>
    /// Assigns ranks (1 = best) based on Total Score descending.
    /// </summary>
    local procedure CalculateRanks(ScenarioCode: Code[20])
    var
        ScenarioScore: Record "Scenario Supplier Score";
        CurrentRank: Integer;
    begin
        CurrentRank := 0;

        ScenarioScore.SetRange("Scenario Code", ScenarioCode);
        ScenarioScore.SetCurrentKey("Scenario Code", "Total Score");
        // We need descending order - iterate and assign ranks
        // AL doesn't have native descending iteration on SetCurrentKey,
        // so we collect scores and rank them

        // First pass: count entries
        if not ScenarioScore.FindSet() then
            exit;

        // Since we can't sort descending easily, find the max score iteratively
        RankByDescendingScore(ScenarioCode);
    end;

    local procedure RankByDescendingScore(ScenarioCode: Code[20])
    var
        ScenarioScore: Record "Scenario Supplier Score";
        TempScore: Record "Scenario Supplier Score" temporary;
        MaxScore: Decimal;
        CurrentRank: Integer;
        Assigned: Integer;
        TotalEntries: Integer;
    begin
        // Copy all scores to temp table
        ScenarioScore.SetRange("Scenario Code", ScenarioCode);
        TotalEntries := ScenarioScore.Count();
        if TotalEntries = 0 then
            exit;

        if ScenarioScore.FindSet() then
            repeat
                TempScore := ScenarioScore;
                TempScore.Insert();
            until ScenarioScore.Next() = 0;

        // Assign ranks by finding max score, assigning rank, removing from temp
        CurrentRank := 0;
        Assigned := 0;

        while Assigned < TotalEntries do begin
            CurrentRank += 1;
            MaxScore := -1;

            // Find max score in remaining
            TempScore.Reset();
            if TempScore.FindSet() then
                repeat
                    if TempScore."Total Score" > MaxScore then
                        MaxScore := TempScore."Total Score";
                until TempScore.Next() = 0;

            // Assign rank to all entries with this max score
            TempScore.Reset();
            if TempScore.FindSet() then
                repeat
                    if TempScore."Total Score" = MaxScore then begin
                        ScenarioScore.Get(ScenarioCode, TempScore."Vendor No.");
                        ScenarioScore.Rank := CurrentRank;
                        ScenarioScore.Modify();
                        TempScore.Delete();
                        Assigned += 1;
                    end;
                until TempScore.Next() = 0;
        end;
    end;

    /// <summary>
    /// Sets the Best Vendor and Score on the Scenario record.
    /// </summary>
    local procedure UpdateScenarioBestVendor(ScenarioCode: Code[20])
    var
        Scenario: Record "Scoring Scenario";
        ScenarioScore: Record "Scenario Supplier Score";
    begin
        if not Scenario.Get(ScenarioCode) then
            exit;

        ScenarioScore.SetRange("Scenario Code", ScenarioCode);
        ScenarioScore.SetRange(Rank, 1);
        if ScenarioScore.FindFirst() then begin
            Scenario."Best Vendor No." := ScenarioScore."Vendor No.";
            Scenario."Best Vendor Score" := ScenarioScore."Total Score";
        end;

        Scenario.Status := "Scenario Status"::Scored;
        Scenario."Scored At" := CurrentDateTime();
        Scenario.Modify(true);
    end;

    /// <summary>
    /// Returns the score breakdown as formatted text for display.
    /// </summary>
    procedure GetScoreBreakdown(ScenarioCode: Code[20]; VendorNo: Code[20]): Text
    var
        ScenarioScore: Record "Scenario Supplier Score";
        Vendor: Record Vendor;
        VendorName: Text;
    begin
        if not ScenarioScore.Get(ScenarioCode, VendorNo) then
            exit('Score not found.');

        if Vendor.Get(VendorNo) then
            VendorName := Vendor.Name
        else
            VendorName := VendorNo;

        exit(StrSubstNo(
            'Supplier: %1\Rank: #%2\Total Score: %3\\\' +
            'Price Score: %4 (30%%)\Lead Time Score: %5 (25%%)\' +
            'Quality Score: %6 (20%%)\Reliability Score: %7 (15%%)\' +
            'History Score: %8 (10%%)',
            VendorName, ScenarioScore.Rank, Format(ScenarioScore."Total Score", 0, '<Precision,2:2><Standard Format,0>'),
            Format(ScenarioScore."Price Score", 0, '<Precision,2:2><Standard Format,0>'),
            Format(ScenarioScore."Lead Time Score", 0, '<Precision,2:2><Standard Format,0>'),
            Format(ScenarioScore."Quality Score", 0, '<Precision,2:2><Standard Format,0>'),
            Format(ScenarioScore."Reliability Score", 0, '<Precision,2:2><Standard Format,0>'),
            Format(ScenarioScore."History Score", 0, '<Precision,2:2><Standard Format,0>')
        ));
    end;
}
