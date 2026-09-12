namespace DefaultPublisher.ALProject1;

using Microsoft.Purchases.Document;
using Microsoft.Inventory.Item;

/// <summary>
/// Creates Purchase Orders in Draft (Status = Open) for the best-ranked supplier
/// in a given scoring scenario.
/// </summary>
codeunit 50102 "PO Draft Creator"
{
    /// <summary>
    /// Creates a Purchase Order in draft mode for the best vendor in the scenario.
    /// Prompts the user to confirm or change the Item and Quantity before creating.
    /// The PO will have Status = Open (which is the "Draft" state in BC).
    /// </summary>
    procedure CreateDraftPO(ScenarioCode: Code[20])
    var
        Scenario: Record "Scoring Scenario";
        ScenarioScore: Record "Scenario Supplier Score";
        SupplierItem: Record "Supplier Item";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        DataGen: Codeunit "Sample Data Generator";
        PONo: Code[20];
        SelectedItemNo: Code[20];
        SelectedQty: Decimal;
    begin
        // ── Validate scenario ──
        if not Scenario.Get(ScenarioCode) then
            Error('Scenario %1 not found.', ScenarioCode);

        if Scenario.Status = "Scenario Status"::Draft then
            Error('Scenario %1 has not been scored yet. Run scoring first.', ScenarioCode);

        if Scenario."PO Created" then
            Error('A Purchase Order (%1) has already been created for scenario %2.', Scenario."PO No.", ScenarioCode);

        if Scenario."Best Vendor No." = '' then
            Error('No best vendor found for scenario %1.', ScenarioCode);

        // ── Get best vendor's score details ──
        ScenarioScore.SetRange("Scenario Code", ScenarioCode);
        ScenarioScore.SetRange(Rank, 1);
        if not ScenarioScore.FindFirst() then
            Error('No ranked suppliers found for scenario %1.', ScenarioCode);

        // ── Ask user to confirm / change Item and Quantity ──
        SelectedItemNo := Scenario."Item No.";
        SelectedQty := Scenario."Required Qty";

        if not PromptItemAndQty(SelectedItemNo, SelectedQty) then
            exit; // User cancelled

        // ── Validate item exists ──
        if not Item.Get(SelectedItemNo) then
            Error('Item %1 not found.', SelectedItemNo);

        if SelectedQty <= 0 then
            Error('Quantity must be greater than zero.');

        // ── Get supplier item details for pricing ──
        if not SupplierItem.Get(Scenario."Best Vendor No.", SelectedItemNo) then
            Error('Supplier item link not found for Vendor %1 and Item %2.',
                Scenario."Best Vendor No.", SelectedItemNo);

        // ── Create Purchase Order Header ──
        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Order;
        // Let BC assign the No. from No. Series
        PurchHeader.Insert(true);
        PONo := PurchHeader."No.";

        PurchHeader.Validate("Buy-from Vendor No.", Scenario."Best Vendor No.");
        PurchHeader.Validate("Order Date", Today());
        PurchHeader.Validate("Posting Date", Today());
        PurchHeader.Validate("Document Date", Today());
        PurchHeader.Validate("Expected Receipt Date",
            CalcDate('<+' + Format(SupplierItem."Lead Time Days") + 'D>', Today()));
        PurchHeader.Validate("Vendor Order No.",
            StrSubstNo('AUTO-SCORING-%1', ScenarioCode));
        PurchHeader.Modify(true);

        // Status is Open (Draft) by default - no need to set it explicitly

        // ── Ensure Item Unit of Measure exists in Table 5404 ──
        DataGen.EnsureAllItemUnitsOfMeasure();

        // ── Create Purchase Order Line ──
        PurchLine.Init();
        PurchLine."Document Type" := PurchHeader."Document Type";
        PurchLine."Document No." := PurchHeader."No.";
        PurchLine."Line No." := 10000;
        PurchLine.Insert(true);

        PurchLine.Validate(Type, PurchLine.Type::Item);
        PurchLine.Validate("No.", SelectedItemNo);
        PurchLine.Validate(Quantity, SelectedQty);
        PurchLine.Validate("Direct Unit Cost", SupplierItem."Unit Price");
        PurchLine.Validate("Expected Receipt Date",
            CalcDate('<+' + Format(SupplierItem."Lead Time Days") + 'D>', Today()));
        PurchLine.Modify(true);

        // ── Update scenario ──
        Scenario."PO Created" := true;
        Scenario."PO No." := PONo;
        Scenario.Status := "Scenario Status"::"PO Created";
        Scenario.Modify(true);

        Message(
            'Purchase Order %1 created in DRAFT (Open) status!\\\\' +
            'Vendor: %2\\' +
            'Item: %3\\' +
            'Quantity: %4\\' +
            'Unit Cost: %5\\' +
            'Total Amount: %6\\' +
            'Expected Delivery: %7 days\\\\' +
            'Vendor Score: %8/100 (Rank #%9)',
            PONo,
            Scenario."Best Vendor No.",
            SelectedItemNo,
            SelectedQty,
            SupplierItem."Unit Price",
            SelectedQty * SupplierItem."Unit Price",
            SupplierItem."Lead Time Days",
            Format(ScenarioScore."Total Score", 0, '<Precision,2:2><Standard Format,0>'),
            ScenarioScore.Rank
        );
    end;

    /// <summary>
    /// Shows a dialog for the user to confirm or change the Item No. and Quantity.
    /// Returns false if the user cancels.
    /// </summary>
    local procedure PromptItemAndQty(var ItemNo: Code[20]; var Qty: Decimal): Boolean
    var
        InputDialog: Page "PO Input Dialog";
    begin
        InputDialog.SetDefaults(ItemNo, Qty);
        if InputDialog.RunModal() = Action::OK then begin
            InputDialog.GetValues(ItemNo, Qty);
            exit(true);
        end;
        exit(false);
    end;

    /// <summary>
    /// Creates Draft POs for the best vendor in ALL scored scenarios.
    /// </summary>
    procedure CreateDraftPOsForAllScenarios()
    var
        Scenario: Record "Scoring Scenario";
        CreatedCount: Integer;
    begin
        Scenario.SetRange(Status, "Scenario Status"::Scored);
        Scenario.SetRange("PO Created", false);

        if not Scenario.FindSet() then begin
            Message('No scored scenarios found that need Purchase Orders.');
            exit;
        end;

        repeat
            CreateDraftPO(Scenario.Code);
            CreatedCount += 1;
        until Scenario.Next() = 0;

        Message('%1 Purchase Order(s) created in Draft status.', CreatedCount);
    end;
}
