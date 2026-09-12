namespace DefaultPublisher.ALProject1;

using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item;
using Microsoft.Bank.BankAccount;
using Microsoft.Foundation.UOM;
using Microsoft.Purchases.Document;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Inventory.Setup;

/// <summary>
/// Generates comprehensive sample data for all entities:
/// Vendors, Items, Bank Accounts, Supplier Ratings, Supplier History,
/// Supplier Items, Purchase Invoices, Purchase Orders, and Scoring Scenarios.
/// </summary>
codeunit 50100 "Sample Data Generator"
{
    /// <summary>
    /// Main entry point - generates all sample data.
    /// </summary>
    procedure GenerateAllData()
    begin
        EnsureUnitsOfMeasure();
        GenerateVendors();
        GenerateItems();
        EnsureAllItemUnitsOfMeasure();
        GenerateBankAccounts();
        GenerateSupplierRatings();
        GenerateSupplierItems();
        GenerateSupplierHistory();
        GeneratePurchaseInvoices();
        GeneratePurchaseOrders();
        GenerateScenarios();
        Message('Sample data generated successfully!\\ \\' +
                '• 40 Vendors\\ ' +
                '• 40 Items\\ ' +
                '• 5 Bank Accounts\\ ' +
                '• 40 Supplier Ratings\\ ' +
                '• 150+ Supplier-Item links\\ ' +
                '• 60 History entries\\ ' +
                '• 5 Purchase Invoices\\ ' +
                '• 3 Purchase Orders\\ ' +
                '• 5 Scoring Scenarios');
    end;

    // ─────────────────────────────────────────────
    // Units of Measure
    // ─────────────────────────────────────────────
    local procedure EnsureUnitsOfMeasure()
    begin
        CreateUOM('PCS', 'Piece');
        CreateUOM('BOX', 'Box');
        CreateUOM('M', 'Meter');
        CreateUOM('KG', 'Kilogram');
    end;

    local procedure CreateUOM(UOMCode: Code[10]; UOMDescription: Text[50])
    var
        UOM: Record "Unit of Measure";
    begin
        if UOM.Get(UOMCode) then
            exit;
        UOM.Init();
        UOM.Code := UOMCode;
        UOM.Description := UOMDescription;
        UOM.Insert(true);
    end;

    // ─────────────────────────────────────────────
    // Posting Group Setup Helpers
    // ─────────────────────────────────────────────
    local procedure GetOrCreateVendorPostingGroups(var GenBusCode: Code[20]; var VATBusCode: Code[20]; var VendPostingCode: Code[20])
    var
        GenBus: Record "Gen. Business Posting Group";
        VATBus: Record "VAT Business Posting Group";
        VendPosting: Record "Vendor Posting Group";
    begin
        // Gen. Business Posting Group
        GenBus.Reset();
        if GenBus.FindFirst() then
            GenBusCode := GenBus.Code
        else begin
            GenBus.Init();
            GenBus.Code := 'DOMESTIC';
            GenBus.Description := 'Domestic Customers/Vendors';
            if not GenBus.Get('DOMESTIC') then
                GenBus.Insert(false);
            GenBusCode := 'DOMESTIC';
        end;

        // VAT Business Posting Group
        VATBus.Reset();
        if VATBus.FindFirst() then
            VATBusCode := VATBus.Code
        else begin
            VATBus.Init();
            VATBus.Code := 'DOMESTIC';
            VATBus.Description := 'Domestic VAT';
            if not VATBus.Get('DOMESTIC') then
                VATBus.Insert(false);
            VATBusCode := 'DOMESTIC';
        end;

        // Vendor Posting Group
        VendPosting.Reset();
        if VendPosting.FindFirst() then
            VendPostingCode := VendPosting.Code
        else begin
            VendPosting.Init();
            VendPosting.Code := 'DOMESTIC';
            VendPosting.Description := 'Domestic Payables';
            if not VendPosting.Get('DOMESTIC') then
                VendPosting.Insert(false);
            VendPostingCode := 'DOMESTIC';
        end;
    end;

    local procedure GetOrCreateItemPostingGroups(var GenProdCode: Code[20]; var VATProdCode: Code[20]; var InvPostingCode: Code[20])
    var
        GenProd: Record "Gen. Product Posting Group";
        VATProd: Record "VAT Product Posting Group";
        InvPosting: Record "Inventory Posting Group";
    begin
        // Gen. Product Posting Group
        GenProd.Reset();
        if GenProd.FindFirst() then
            GenProdCode := GenProd.Code
        else begin
            GenProd.Init();
            GenProd.Code := 'RETAIL';
            GenProd.Description := 'Retail Items';
            if not GenProd.Get('RETAIL') then
                GenProd.Insert(false);
            GenProdCode := 'RETAIL';
        end;

        // VAT Product Posting Group
        VATProd.Reset();
        if VATProd.FindFirst() then
            VATProdCode := VATProd.Code
        else begin
            VATProd.Init();
            VATProd.Code := 'STANDARD';
            VATProd.Description := 'Standard VAT Rate';
            if not VATProd.Get('STANDARD') then
                VATProd.Insert(false);
            VATProdCode := 'STANDARD';
        end;

        // Inventory Posting Group
        InvPosting.Reset();
        if InvPosting.FindFirst() then
            InvPostingCode := InvPosting.Code
        else begin
            InvPosting.Init();
            InvPosting.Code := 'RESALE';
            InvPosting.Description := 'Resale Items';
            if not InvPosting.Get('RESALE') then
                InvPosting.Insert(false);
            InvPostingCode := 'RESALE';
        end;
    end;

    local procedure GetOrCreateBankPostingGroup(): Code[20]
    var
        BankPosting: Record "Bank Account Posting Group";
    begin
        BankPosting.Reset();
        if BankPosting.FindFirst() then
            exit(BankPosting.Code);

        BankPosting.Init();
        BankPosting.Code := 'OPERATING';
        if not BankPosting.Get('OPERATING') then
            BankPosting.Insert(false);
        exit('OPERATING');
    end;

    // ─────────────────────────────────────────────
    // Vendors (40 Total: V-10000 to V-10039)
    // ─────────────────────────────────────────────
    local procedure GenerateVendors()
    begin
        // Original 10 Vendors
        CreateVendor('V-10000', 'TechParts SARL', 'Alger', 'contact@techparts.dz', '+213 21 55 00 01');
        CreateVendor('V-10001', 'ElectroPro Distribution', 'Oran', 'info@electropro.dz', '+213 41 33 00 02');
        CreateVendor('V-10002', 'MegaSupply Co', 'Constantine', 'sales@megasupply.com', '+213 31 22 00 03');
        CreateVendor('V-10003', 'QuickShip Maroc', 'Casablanca', 'orders@quickship.ma', '+212 5 22 00 04');
        CreateVendor('V-10004', 'GlobalParts Inc', 'Paris', 'info@globalparts.fr', '+33 1 40 00 05');
        CreateVendor('V-10005', 'PremiumTech SAS', 'Lyon', 'contact@premiumtech.fr', '+33 4 72 00 06');
        CreateVendor('V-10006', 'EcoParts Algerie', 'Blida', 'ventes@ecoparts.dz', '+213 25 44 00 07');
        CreateVendor('V-10007', 'FastDeal Trading', 'Tunis', 'sales@fastdeal.tn', '+216 71 00 08');
        CreateVendor('V-10008', 'ValuePlus SARL', 'Annaba', 'info@valueplus.dz', '+213 38 55 00 09');
        CreateVendor('V-10009', 'SmartSource Ltd', 'Istanbul', 'orders@smartsource.tr', '+90 212 00 10');

        // 30 Additional Vendors (V-10010 to V-10039)
        CreateVendor('V-10010', 'Atlas Componentes', 'Madrid', 'contact@atlascomp.es', '+34 91 100 11');
        CreateVendor('V-10011', 'Biskra Tech', 'Biskra', 'info@biskratech.dz', '+213 33 70 00 12');
        CreateVendor('V-10012', 'Sahara Logistics', 'Ouargla', 'contact@saharalog.dz', '+213 29 71 00 13');
        CreateVendor('V-10013', 'EuroIndustrie GmbH', 'Stuttgart', 'sales@euroindustrie.de', '+49 711 00 14');
        CreateVendor('V-10014', 'Maghreb Outillage', 'Setif', 'orders@maghreboutill.dz', '+213 36 90 00 15');
        CreateVendor('V-10015', 'Orient Electronics', 'Shenzhen', 'info@orientelectro.cn', '+86 755 00 16');
        CreateVendor('V-10016', 'Mediterranean Parts', 'Marseille', 'sales@medparts.fr', '+33 4 91 00 17');
        CreateVendor('V-10017', 'Maghreb Connect SARL', 'Tlemcen', 'contact@maghrebconnect.dz', '+213 43 20 00 18');
        CreateVendor('V-10018', 'Nord-Afrique Metal', 'Bejaia', 'info@nametal.dz', '+213 34 12 00 19');
        CreateVendor('V-10019', 'Italia Hardware SpA', 'Milan', 'orders@italiahardware.it', '+39 02 00 20');
        CreateVendor('V-10020', 'SinoTech Supply', 'Shanghai', 'sales@sinotech.cn', '+86 21 00 21');
        CreateVendor('V-10021', 'Algerie Equipement', 'Tizi Ouzou', 'contact@algerieequip.dz', '+213 26 21 00 22');
        CreateVendor('V-10022', 'Iberica Distribution', 'Valencia', 'info@ibericadist.es', '+34 96 300 23');
        CreateVendor('V-10023', 'Atlas Plastic SARL', 'Mostaganem', 'ventes@atlasplastic.dz', '+213 45 30 00 24');
        CreateVendor('V-10024', 'Emirates Trading', 'Dubai', 'info@emiratestrading.ae', '+971 4 00 25');
        CreateVendor('V-10025', 'Rhone Composants', 'Grenoble', 'contact@rhonecomp.fr', '+33 4 76 00 26');
        CreateVendor('V-10026', 'Constantine Cables', 'Constantine', 'sales@constantinecables.dz', '+213 31 66 00 27');
        CreateVendor('V-10027', 'Tunis Microtech', 'Sfax', 'orders@tunismicrotech.tn', '+216 74 00 28');
        CreateVendor('V-10028', 'Bosphore Import-Export', 'Izmir', 'info@bosphoreimp.tr', '+90 232 00 29');
        CreateVendor('V-10029', 'Deutschland Sensor AG', 'Nurnberg', 'sales@de-sensor.de', '+49 911 00 30');
        CreateVendor('V-10030', 'West-Coast Silicon', 'San Jose', 'contact@wcsilicon.com', '+1 408 00 31');
        CreateVendor('V-10031', 'Casatech Distribution', 'Casablanca', 'info@casatech.ma', '+212 5 20 00 32');
        CreateVendor('V-10032', 'Sahara Power SARL', 'Hassi Messaoud', 'sales@saharapower.dz', '+213 29 73 00 33');
        CreateVendor('V-10033', 'Setif Plast', 'Setif', 'orders@setifplast.dz', '+213 36 84 00 34');
        CreateVendor('V-10034', 'Algiers Fasteners', 'Alger', 'contact@algiersfast.dz', '+213 21 60 00 35');
        CreateVendor('V-10035', 'Nippon Precision Co', 'Tokyo', 'info@nipponprecision.jp', '+81 3 00 36');
        CreateVendor('V-10036', 'Oran Electrique', 'Oran', 'sales@oranelectrique.dz', '+213 41 40 00 37');
        CreateVendor('V-10037', 'Pyrenees Outillage', 'Toulouse', 'orders@pyreneesoutill.fr', '+33 5 61 00 38');
        CreateVendor('V-10038', 'Soummam Distribution', 'Akbou', 'info@soummamdist.dz', '+213 34 35 00 39');
        CreateVendor('V-10039', 'Global Wire SARL', 'Chlef', 'contact@globalwire.dz', '+213 27 77 00 40');
    end;

    local procedure CreateVendor(VendorNo: Code[20]; VendorName: Text[100]; City: Text[30]; Email: Text[80]; Phone: Text[30])
    var
        Vendor: Record Vendor;
        GenBusCode: Code[20];
        VATBusCode: Code[20];
        VendPostingCode: Code[20];
    begin
        if Vendor.Get(VendorNo) then
            exit;

        GetOrCreateVendorPostingGroups(GenBusCode, VATBusCode, VendPostingCode);

        Vendor.Init();
        Vendor."No." := VendorNo;
        Vendor.Name := VendorName;
        Vendor.City := City;
        Vendor."E-Mail" := Email;
        Vendor."Phone No." := Phone;

        if GenBusCode <> '' then
            Vendor."Gen. Bus. Posting Group" := GenBusCode;
        if VATBusCode <> '' then
            Vendor."VAT Bus. Posting Group" := VATBusCode;
        if VendPostingCode <> '' then
            Vendor."Vendor Posting Group" := VendPostingCode;

        Vendor.Insert(false);
    end;

    // ─────────────────────────────────────────────
    // Items (40 Total: ITEM-1000 to ITEM-1039)
    // ─────────────────────────────────────────────
    local procedure GenerateItems()
    begin
        // Electronic Components (10)
        CreateItem('ITEM-1000', 'Resistance 10K Ohm', 'PCS', 0.50, 0.75);
        CreateItem('ITEM-1001', 'Condensateur 100uF', 'PCS', 1.20, 1.80);
        CreateItem('ITEM-1002', 'Circuit Integre IC-7805', 'PCS', 3.50, 5.25);
        CreateItem('ITEM-1003', 'LED Rouge 5mm', 'PCS', 0.30, 0.50);
        CreateItem('ITEM-1004', 'Transistor NPN 2N2222', 'PCS', 0.80, 1.20);
        CreateItem('ITEM-1005', 'Diode Zener 5.1V', 'PCS', 0.45, 0.70);
        CreateItem('ITEM-1006', 'Relais 12V 10A', 'PCS', 4.50, 6.75);
        CreateItem('ITEM-1007', 'Fusible 5A', 'PCS', 0.60, 0.90);
        CreateItem('ITEM-1008', 'Transformateur 220V/12V', 'PCS', 15.00, 22.50);
        CreateItem('ITEM-1009', 'Microcontroleur Arduino Nano', 'PCS', 8.50, 12.75);
        // Mechanical Parts (5)
        CreateItem('ITEM-1010', 'Vis M4x20 Inox', 'BOX', 5.00, 7.50);
        CreateItem('ITEM-1011', 'Roulement 608ZZ', 'PCS', 3.20, 4.80);
        CreateItem('ITEM-1012', 'Ressort Compression 25mm', 'PCS', 1.80, 2.70);
        CreateItem('ITEM-1013', 'Ecrou M4 Inox', 'BOX', 3.50, 5.25);
        CreateItem('ITEM-1014', 'Rondelle Plate M4', 'BOX', 2.00, 3.00);
        // General Supplies (5)
        CreateItem('ITEM-1015', 'Cable Electrique 1.5mm2', 'M', 1.20, 1.80);
        CreateItem('ITEM-1016', 'Connecteur RJ45', 'PCS', 0.90, 1.35);
        CreateItem('ITEM-1017', 'Gaine Thermoretractable 6mm', 'M', 0.70, 1.05);
        CreateItem('ITEM-1018', 'Boitier Plastique 100x60x25', 'PCS', 4.50, 6.75);
        CreateItem('ITEM-1019', 'Plaque Circuit Imprime 10x15', 'PCS', 6.00, 9.00);

        // 20 Additional Items (ITEM-1020 to ITEM-1039)
        // Advanced Electronics (8)
        CreateItem('ITEM-1020', 'Capteur de Temperature PT100', 'PCS', 12.00, 18.00);
        CreateItem('ITEM-1021', 'Afficheur LCD 16x2', 'PCS', 4.50, 6.75);
        CreateItem('ITEM-1022', 'Alimentation Decoupage 12V 5A', 'PCS', 14.00, 21.00);
        CreateItem('ITEM-1023', 'Moteur Pas a Pas NEMA 17', 'PCS', 16.50, 24.75);
        CreateItem('ITEM-1024', 'Interrupteur Fin de Course', 'PCS', 1.10, 1.65);
        CreateItem('ITEM-1025', 'Potentiometre 10K Ohm', 'PCS', 0.75, 1.15);
        CreateItem('ITEM-1026', 'Module Bluetooth HC-05', 'PCS', 5.20, 7.80);
        CreateItem('ITEM-1027', 'Module Wifi ESP8266', 'PCS', 3.80, 5.70);
        // Mechanical & Hardware (6)
        CreateItem('ITEM-1028', 'Tige Filetee M8 Inox 1m', 'M', 4.20, 6.30);
        CreateItem('ITEM-1029', 'Profil Alumunium 2020 1m', 'M', 7.50, 11.25);
        CreateItem('ITEM-1030', 'Courroie Crantee GT2 6mm', 'M', 2.10, 3.15);
        CreateItem('ITEM-1031', 'Poulie Crantee GT2 20 Dents', 'PCS', 1.80, 2.70);
        CreateItem('ITEM-1032', 'Vanne Solenoide 12V', 'PCS', 11.00, 16.50);
        CreateItem('ITEM-1033', 'Joint Torique NBR 10mm', 'BOX', 3.00, 4.50);
        // Raw Materials & Tools (6)
        CreateItem('ITEM-1034', 'Fil d Etain 0.8mm 250g', 'PCS', 9.50, 14.25);
        CreateItem('ITEM-1035', 'Multimetre Numerique', 'PCS', 22.00, 33.00);
        CreateItem('ITEM-1036', 'Gaine Tressee 10mm', 'M', 1.40, 2.10);
        CreateItem('ITEM-1037', 'Carton d Emballage 30x20x15', 'BOX', 8.00, 12.00);
        CreateItem('ITEM-1038', 'Ruban Adhesif d Emballage', 'PCS', 1.20, 1.80);
        CreateItem('ITEM-1039', 'Cable Cuivre Denude 2.5mm2', 'M', 1.80, 2.70);
    end;

    local procedure CreateItem(ItemNo: Code[20]; ItemDesc: Text[100]; BaseUOM: Code[10]; UnitCost: Decimal; UnitPrice: Decimal)
    var
        Item: Record Item;
        GenProdCode: Code[20];
        VATProdCode: Code[20];
        InvPostingCode: Code[20];
    begin
        EnsureItemUnitOfMeasure(ItemNo, BaseUOM);

        if Item.Get(ItemNo) then
            exit;

        GetOrCreateItemPostingGroups(GenProdCode, VATProdCode, InvPostingCode);

        Item.Init();
        Item."No." := ItemNo;
        Item.Description := ItemDesc;
        Item.Type := Item.Type::Inventory;
        Item."Base Unit of Measure" := BaseUOM;
        Item."Unit Cost" := UnitCost;
        Item."Unit Price" := UnitPrice;
        Item."Replenishment System" := Item."Replenishment System"::Purchase;

        if GenProdCode <> '' then
            Item."Gen. Prod. Posting Group" := GenProdCode;
        if VATProdCode <> '' then
            Item."VAT Prod. Posting Group" := VATProdCode;
        if InvPostingCode <> '' then
            Item."Inventory Posting Group" := InvPostingCode;

        Item.Insert(false);
    end;

    procedure EnsureItemUnitOfMeasure(ItemNo: Code[20]; UOMCode: Code[10])
    var
        ItemUOM: Record "Item Unit of Measure";
        UOM: Record "Unit of Measure";
    begin
        if (ItemNo = '') or (UOMCode = '') then
            exit;

        // 1. Ensure global UOM exists in Table 204
        if not UOM.Get(UOMCode) then begin
            UOM.Init();
            UOM.Code := UOMCode;
            UOM.Description := UOMCode;
            if not UOM.Insert(false) then;
        end;

        // 2. Ensure Item UOM exists in Table 5404
        if not ItemUOM.Get(ItemNo, UOMCode) then begin
            ItemUOM.Init();
            ItemUOM."Item No." := ItemNo;
            ItemUOM.Code := UOMCode;
            ItemUOM."Qty. per Unit of Measure" := 1;
            if not ItemUOM.Insert(false) then;
        end;
    end;

    procedure EnsureAllItemUnitsOfMeasure()
    var
        Item: Record Item;
    begin
        if Item.FindSet() then
            repeat
                if Item."Base Unit of Measure" <> '' then
                    EnsureItemUnitOfMeasure(Item."No.", Item."Base Unit of Measure")
                else
                    EnsureItemUnitOfMeasure(Item."No.", 'PCS');
            until Item.Next() = 0;
    end;

    // ─────────────────────────────────────────────
    // Bank Accounts (5)
    // ─────────────────────────────────────────────
    local procedure GenerateBankAccounts()
    begin
        CreateBankAccount('BANK-001', 'Compte Principal - BNA', '001 00012 0300001234 56', 'DZ12 0001 0001 2030 0001 2345 6');
        CreateBankAccount('BANK-002', 'Compte Fournisseurs - CPA', '004 00025 0400005678 90', 'DZ34 0004 0002 5040 0005 6789 0');
        CreateBankAccount('BANK-003', 'Compte Devises EUR', '007 00033 0500009012 34', 'DZ56 0007 0003 3050 0009 0123 4');
        CreateBankAccount('BANK-004', 'Compte Operations - BEA', '010 00041 0600003456 78', 'DZ78 0010 0004 1060 0003 4567 8');
        CreateBankAccount('BANK-005', 'Caisse Principale', '', '');
    end;

    local procedure CreateBankAccount(BankNo: Code[20]; BankName: Text[100]; AccountNo: Text[30]; IBAN: Code[50])
    var
        BankAccount: Record "Bank Account";
        BankPostingCode: Code[20];
    begin
        if BankAccount.Get(BankNo) then
            exit;

        BankPostingCode := GetOrCreateBankPostingGroup();

        BankAccount.Init();
        BankAccount."No." := BankNo;
        BankAccount.Name := BankName;
        BankAccount."Bank Account No." := AccountNo;
        BankAccount.IBAN := IBAN;

        if BankPostingCode <> '' then
            BankAccount."Bank Acc. Posting Group" := BankPostingCode;

        BankAccount.Insert(false);
    end;

    // ─────────────────────────────────────────────
    // Supplier Ratings (40 Total)
    // ─────────────────────────────────────────────
    local procedure GenerateSupplierRatings()
    begin
        //                         VendorNo    Quality  Reliab. LeadTime  DelivPerf  TotalOrd  OnTime  QualIss
        CreateSupplierRating('V-10000', 4.5, 0.95, 3, 0.93, 40, 37, 1);
        CreateSupplierRating('V-10001', 4.2, 0.88, 5, 0.86, 35, 30, 3);
        CreateSupplierRating('V-10002', 3.8, 0.92, 7, 0.89, 30, 27, 2);
        CreateSupplierRating('V-10003', 4.0, 0.85, 2, 0.83, 25, 21, 4);
        CreateSupplierRating('V-10004', 3.5, 0.78, 10, 0.76, 20, 15, 5);
        CreateSupplierRating('V-10005', 4.8, 0.97, 6, 0.95, 45, 43, 0);
        CreateSupplierRating('V-10006', 3.2, 0.82, 8, 0.80, 18, 14, 4);
        CreateSupplierRating('V-10007', 4.1, 0.90, 4, 0.88, 32, 28, 2);
        CreateSupplierRating('V-10008', 3.6, 0.75, 12, 0.73, 15, 11, 5);
        CreateSupplierRating('V-10009', 4.3, 0.93, 5, 0.91, 38, 35, 1);

        // 30 New Ratings
        CreateSupplierRating('V-10010', 4.4, 0.91, 4, 0.90, 28, 25, 1);
        CreateSupplierRating('V-10011', 3.9, 0.86, 6, 0.84, 22, 18, 2);
        CreateSupplierRating('V-10012', 4.0, 0.89, 3, 0.87, 31, 27, 2);
        CreateSupplierRating('V-10013', 4.7, 0.96, 5, 0.94, 42, 40, 1);
        CreateSupplierRating('V-10014', 3.7, 0.80, 8, 0.78, 19, 15, 3);
        CreateSupplierRating('V-10015', 3.6, 0.74, 14, 0.72, 50, 36, 6);
        CreateSupplierRating('V-10016', 4.3, 0.92, 5, 0.90, 33, 30, 1);
        CreateSupplierRating('V-10017', 4.1, 0.87, 4, 0.85, 27, 23, 2);
        CreateSupplierRating('V-10018', 3.8, 0.83, 7, 0.81, 24, 20, 3);
        CreateSupplierRating('V-10019', 4.6, 0.94, 6, 0.93, 36, 34, 1);
        CreateSupplierRating('V-10020', 3.5, 0.71, 15, 0.70, 60, 42, 8);
        CreateSupplierRating('V-10021', 4.0, 0.88, 3, 0.86, 29, 25, 2);
        CreateSupplierRating('V-10022', 4.2, 0.90, 5, 0.88, 30, 26, 2);
        CreateSupplierRating('V-10023', 3.9, 0.84, 6, 0.82, 21, 17, 3);
        CreateSupplierRating('V-10024', 4.5, 0.93, 7, 0.91, 35, 32, 1);
        CreateSupplierRating('V-10025', 4.7, 0.95, 4, 0.94, 38, 36, 0);
        CreateSupplierRating('V-10026', 4.1, 0.89, 3, 0.87, 26, 23, 1);
        CreateSupplierRating('V-10027', 4.0, 0.86, 5, 0.85, 25, 21, 2);
        CreateSupplierRating('V-10028', 3.8, 0.81, 9, 0.79, 20, 16, 4);
        CreateSupplierRating('V-10029', 4.9, 0.98, 4, 0.97, 48, 47, 0);
        CreateSupplierRating('V-10030', 4.6, 0.93, 8, 0.92, 40, 37, 1);
        CreateSupplierRating('V-10031', 4.2, 0.88, 3, 0.86, 32, 28, 2);
        CreateSupplierRating('V-10032', 3.9, 0.85, 5, 0.83, 23, 19, 3);
        CreateSupplierRating('V-10033', 3.7, 0.82, 7, 0.80, 18, 14, 3);
        CreateSupplierRating('V-10034', 4.3, 0.91, 2, 0.89, 34, 30, 1);
        CreateSupplierRating('V-10035', 4.8, 0.97, 6, 0.96, 44, 42, 0);
        CreateSupplierRating('V-10036', 4.1, 0.87, 3, 0.85, 27, 23, 2);
        CreateSupplierRating('V-10037', 4.4, 0.92, 5, 0.91, 37, 34, 1);
        CreateSupplierRating('V-10038', 3.8, 0.84, 4, 0.82, 21, 17, 2);
        CreateSupplierRating('V-10039', 4.0, 0.86, 5, 0.85, 26, 22, 2);
    end;

    local procedure CreateSupplierRating(VendorNo: Code[20]; Quality: Decimal; Reliability: Decimal; LeadTime: Integer; DelivPerf: Decimal; TotalOrd: Integer; OnTime: Integer; QualIss: Integer)
    var
        Rating: Record "Supplier Rating";
    begin
        if Rating.Get(VendorNo) then
            exit;
        Rating.Init();
        Rating."Vendor No." := VendorNo;
        Rating."Quality Rating" := Quality;
        Rating."Reliability Rate" := Reliability;
        Rating."Lead Time Days" := LeadTime;
        Rating."Delivery Performance" := DelivPerf;
        Rating."Last Evaluation Date" := CalcDate('<-1M>', Today());
        Rating."Total Orders" := TotalOrd;
        Rating."On Time Deliveries" := OnTime;
        Rating."Quality Issues" := QualIss;
        Rating.Insert(true);
    end;

    // ─────────────────────────────────────────────
    // Supplier Items (vendor-item matrix with prices)
    // ─────────────────────────────────────────────
    local procedure GenerateSupplierItems()
    begin
        // ITEM-1000 Resistance - 6 suppliers with varying prices
        CreateSupplierItem('V-10000', 'ITEM-1000', 0.42, 3, 100, true);
        CreateSupplierItem('V-10001', 'ITEM-1000', 0.48, 5, 200, false);
        CreateSupplierItem('V-10003', 'ITEM-1000', 0.55, 2, 50, false);
        CreateSupplierItem('V-10005', 'ITEM-1000', 0.38, 6, 500, false);
        CreateSupplierItem('V-10007', 'ITEM-1000', 0.45, 4, 100, false);
        CreateSupplierItem('V-10009', 'ITEM-1000', 0.40, 5, 150, false);

        // ITEM-1001 Condensateur - 5 suppliers
        CreateSupplierItem('V-10000', 'ITEM-1001', 1.10, 3, 50, true);
        CreateSupplierItem('V-10002', 'ITEM-1001', 1.30, 7, 100, false);
        CreateSupplierItem('V-10004', 'ITEM-1001', 1.05, 10, 200, false);
        CreateSupplierItem('V-10007', 'ITEM-1001', 1.15, 4, 50, false);
        CreateSupplierItem('V-10009', 'ITEM-1001', 1.08, 5, 80, false);

        // ITEM-1002 Circuit Integre - 5 suppliers
        CreateSupplierItem('V-10000', 'ITEM-1002', 3.20, 3, 20, true);
        CreateSupplierItem('V-10001', 'ITEM-1002', 3.80, 5, 30, false);
        CreateSupplierItem('V-10005', 'ITEM-1002', 2.90, 6, 50, false);
        CreateSupplierItem('V-10007', 'ITEM-1002', 3.50, 4, 25, false);
        CreateSupplierItem('V-10009', 'ITEM-1002', 3.10, 5, 30, false);

        // ITEM-1003 LED Rouge - 4 suppliers
        CreateSupplierItem('V-10001', 'ITEM-1003', 0.28, 5, 500, true);
        CreateSupplierItem('V-10003', 'ITEM-1003', 0.35, 2, 200, false);
        CreateSupplierItem('V-10006', 'ITEM-1003', 0.32, 8, 1000, false);
        CreateSupplierItem('V-10008', 'ITEM-1003', 0.25, 12, 2000, false);

        // ITEM-1004 Transistor - 4 suppliers
        CreateSupplierItem('V-10000', 'ITEM-1004', 0.72, 3, 100, true);
        CreateSupplierItem('V-10002', 'ITEM-1004', 0.85, 7, 200, false);
        CreateSupplierItem('V-10005', 'ITEM-1004', 0.68, 6, 150, false);
        CreateSupplierItem('V-10009', 'ITEM-1004', 0.75, 5, 100, false);

        // ITEM-1005 Diode Zener - 4 suppliers
        CreateSupplierItem('V-10001', 'ITEM-1005', 0.40, 5, 100, true);
        CreateSupplierItem('V-10003', 'ITEM-1005', 0.50, 2, 50, false);
        CreateSupplierItem('V-10006', 'ITEM-1005', 0.42, 8, 200, false);
        CreateSupplierItem('V-10007', 'ITEM-1005', 0.44, 4, 100, false);

        // ITEM-1006 Relais - 4 suppliers
        CreateSupplierItem('V-10000', 'ITEM-1006', 4.20, 3, 10, true);
        CreateSupplierItem('V-10002', 'ITEM-1006', 4.80, 7, 20, false);
        CreateSupplierItem('V-10004', 'ITEM-1006', 4.00, 10, 50, false);
        CreateSupplierItem('V-10005', 'ITEM-1006', 3.80, 6, 30, false);

        // ITEM-1007 Fusible - 5 suppliers
        CreateSupplierItem('V-10001', 'ITEM-1007', 0.55, 5, 200, true);
        CreateSupplierItem('V-10003', 'ITEM-1007', 0.65, 2, 100, false);
        CreateSupplierItem('V-10005', 'ITEM-1007', 0.48, 6, 300, false);
        CreateSupplierItem('V-10008', 'ITEM-1007', 0.50, 12, 500, false);
        CreateSupplierItem('V-10011', 'ITEM-1007', 0.52, 6, 250, false);

        // ITEM-1008 Transformateur - 4 suppliers
        CreateSupplierItem('V-10000', 'ITEM-1008', 13.50, 3, 5, true);
        CreateSupplierItem('V-10004', 'ITEM-1008', 12.00, 10, 10, false);
        CreateSupplierItem('V-10005', 'ITEM-1008', 14.50, 6, 5, false);
        CreateSupplierItem('V-10009', 'ITEM-1008', 13.00, 5, 8, false);

        // ITEM-1009 Arduino Nano - 5 suppliers
        CreateSupplierItem('V-10000', 'ITEM-1009', 7.80, 3, 10, true);
        CreateSupplierItem('V-10002', 'ITEM-1009', 9.00, 7, 20, false);
        CreateSupplierItem('V-10005', 'ITEM-1009', 7.20, 6, 15, false);
        CreateSupplierItem('V-10007', 'ITEM-1009', 8.20, 4, 10, false);
        CreateSupplierItem('V-10009', 'ITEM-1009', 7.50, 5, 12, false);

        // ITEM-1010 Vis Inox - 4 suppliers
        CreateSupplierItem('V-10002', 'ITEM-1010', 4.50, 7, 10, true);
        CreateSupplierItem('V-10004', 'ITEM-1010', 4.00, 10, 20, false);
        CreateSupplierItem('V-10006', 'ITEM-1010', 5.20, 8, 5, false);
        CreateSupplierItem('V-10008', 'ITEM-1010', 4.30, 12, 15, false);

        // ITEM-1011 Roulement - 4 suppliers
        CreateSupplierItem('V-10000', 'ITEM-1011', 2.90, 3, 20, true);
        CreateSupplierItem('V-10002', 'ITEM-1011', 3.40, 7, 30, false);
        CreateSupplierItem('V-10004', 'ITEM-1011', 2.70, 10, 50, false);
        CreateSupplierItem('V-10009', 'ITEM-1011', 3.00, 5, 25, false);

        // ITEM-1012 Ressort - 5 suppliers
        CreateSupplierItem('V-10002', 'ITEM-1012', 1.60, 7, 50, true);
        CreateSupplierItem('V-10006', 'ITEM-1012', 1.90, 8, 30, false);
        CreateSupplierItem('V-10008', 'ITEM-1012', 1.50, 12, 100, false);
        CreateSupplierItem('V-10014', 'ITEM-1012', 1.75, 8, 40, false);
        CreateSupplierItem('V-10018', 'ITEM-1012', 1.65, 7, 50, false);

        // ITEM-1013 Ecrou - 5 suppliers
        CreateSupplierItem('V-10002', 'ITEM-1013', 3.10, 7, 10, true);
        CreateSupplierItem('V-10004', 'ITEM-1013', 2.90, 10, 20, false);
        CreateSupplierItem('V-10006', 'ITEM-1013', 3.60, 8, 5, false);
        CreateSupplierItem('V-10010', 'ITEM-1013', 3.00, 4, 15, false);
        CreateSupplierItem('V-10034', 'ITEM-1013', 2.80, 2, 20, false);

        // ITEM-1014 Rondelle - 5 suppliers
        CreateSupplierItem('V-10002', 'ITEM-1014', 1.80, 7, 10, true);
        CreateSupplierItem('V-10006', 'ITEM-1014', 2.10, 8, 5, false);
        CreateSupplierItem('V-10008', 'ITEM-1014', 1.70, 12, 20, false);
        CreateSupplierItem('V-10010', 'ITEM-1014', 1.75, 4, 15, false);
        CreateSupplierItem('V-10034', 'ITEM-1014', 1.65, 2, 25, false);

        // ITEM-1015 Cable - 5 suppliers
        CreateSupplierItem('V-10001', 'ITEM-1015', 1.05, 5, 100, true);
        CreateSupplierItem('V-10003', 'ITEM-1015', 1.30, 2, 50, false);
        CreateSupplierItem('V-10004', 'ITEM-1015', 0.95, 10, 500, false);
        CreateSupplierItem('V-10006', 'ITEM-1015', 1.15, 8, 200, false);
        CreateSupplierItem('V-10008', 'ITEM-1015', 0.90, 12, 1000, false);

        // ITEM-1016 Connecteur RJ45 - 4 suppliers
        CreateSupplierItem('V-10001', 'ITEM-1016', 0.82, 5, 100, true);
        CreateSupplierItem('V-10003', 'ITEM-1016', 0.95, 2, 50, false);
        CreateSupplierItem('V-10007', 'ITEM-1016', 0.85, 4, 80, false);
        CreateSupplierItem('V-10009', 'ITEM-1016', 0.80, 5, 100, false);

        // ITEM-1017 Gaine - 5 suppliers
        CreateSupplierItem('V-10001', 'ITEM-1017', 0.62, 5, 200, true);
        CreateSupplierItem('V-10006', 'ITEM-1017', 0.75, 8, 100, false);
        CreateSupplierItem('V-10008', 'ITEM-1017', 0.58, 12, 500, false);
        CreateSupplierItem('V-10026', 'ITEM-1017', 0.65, 3, 150, false);
        CreateSupplierItem('V-10039', 'ITEM-1017', 0.60, 5, 300, false);

        // ITEM-1018 Boitier - 4 suppliers
        CreateSupplierItem('V-10000', 'ITEM-1018', 4.00, 3, 10, true);
        CreateSupplierItem('V-10002', 'ITEM-1018', 4.70, 7, 15, false);
        CreateSupplierItem('V-10005', 'ITEM-1018', 3.80, 6, 20, false);
        CreateSupplierItem('V-10007', 'ITEM-1018', 4.30, 4, 10, false);

        // ITEM-1019 Plaque PCB - 4 suppliers
        CreateSupplierItem('V-10000', 'ITEM-1019', 5.50, 3, 5, true);
        CreateSupplierItem('V-10005', 'ITEM-1019', 5.00, 6, 10, false);
        CreateSupplierItem('V-10007', 'ITEM-1019', 5.80, 4, 8, false);
        CreateSupplierItem('V-10009', 'ITEM-1019', 5.30, 5, 10, false);

        // 20 New Items (ITEM-1020 to ITEM-1039) with 4-5 suppliers each
        // ITEM-1020 Capteur PT100 - 4 suppliers
        CreateSupplierItem('V-10010', 'ITEM-1020', 11.50, 4, 5, true);
        CreateSupplierItem('V-10013', 'ITEM-1020', 14.00, 5, 10, false);
        CreateSupplierItem('V-10029', 'ITEM-1020', 16.50, 4, 5, false);
        CreateSupplierItem('V-10030', 'ITEM-1020', 10.80, 8, 20, false);

        // ITEM-1021 Afficheur LCD - 4 suppliers
        CreateSupplierItem('V-10015', 'ITEM-1021', 3.60, 14, 50, false);
        CreateSupplierItem('V-10020', 'ITEM-1021', 3.20, 15, 100, false);
        CreateSupplierItem('V-10025', 'ITEM-1021', 4.80, 4, 10, true);
        CreateSupplierItem('V-10027', 'ITEM-1021', 4.20, 5, 20, false);

        // ITEM-1022 Alimentation 12V - 4 suppliers
        CreateSupplierItem('V-10011', 'ITEM-1022', 13.50, 6, 5, true);
        CreateSupplierItem('V-10013', 'ITEM-1022', 16.00, 5, 10, false);
        CreateSupplierItem('V-10032', 'ITEM-1022', 15.00, 5, 8, false);
        CreateSupplierItem('V-10036', 'ITEM-1022', 14.20, 3, 5, false);

        // ITEM-1023 Moteur NEMA 17 - 4 suppliers
        CreateSupplierItem('V-10015', 'ITEM-1023', 13.80, 14, 20, false);
        CreateSupplierItem('V-10019', 'ITEM-1023', 17.50, 6, 5, true);
        CreateSupplierItem('V-10029', 'ITEM-1023', 18.00, 4, 5, false);
        CreateSupplierItem('V-10035', 'ITEM-1023', 19.50, 6, 5, false);

        // ITEM-1024 Interrupteur Fin de Course - 5 suppliers
        CreateSupplierItem('V-10011', 'ITEM-1024', 1.00, 6, 50, true);
        CreateSupplierItem('V-10014', 'ITEM-1024', 1.25, 8, 20, false);
        CreateSupplierItem('V-10017', 'ITEM-1024', 1.05, 4, 30, false);
        CreateSupplierItem('V-10021', 'ITEM-1024', 1.15, 3, 25, false);
        CreateSupplierItem('V-10034', 'ITEM-1024', 1.10, 2, 40, false);

        // ITEM-1025 Potentiometre 10K - 5 suppliers
        CreateSupplierItem('V-10010', 'ITEM-1025', 0.70, 4, 100, true);
        CreateSupplierItem('V-10011', 'ITEM-1025', 0.68, 6, 150, false);
        CreateSupplierItem('V-10015', 'ITEM-1025', 0.55, 14, 500, false);
        CreateSupplierItem('V-10025', 'ITEM-1025', 0.85, 4, 50, false);
        CreateSupplierItem('V-10036', 'ITEM-1025', 0.72, 3, 80, false);

        // ITEM-1026 Module Bluetooth - 5 suppliers
        CreateSupplierItem('V-10015', 'ITEM-1026', 4.20, 14, 30, false);
        CreateSupplierItem('V-10020', 'ITEM-1026', 3.90, 15, 50, false);
        CreateSupplierItem('V-10025', 'ITEM-1026', 5.80, 4, 15, false);
        CreateSupplierItem('V-10027', 'ITEM-1026', 5.50, 5, 10, true);
        CreateSupplierItem('V-10030', 'ITEM-1026', 6.00, 8, 15, false);

        // ITEM-1027 Module Wifi ESP8266 - 5 suppliers
        CreateSupplierItem('V-10010', 'ITEM-1027', 3.50, 4, 20, false);
        CreateSupplierItem('V-10015', 'ITEM-1027', 2.90, 14, 50, false);
        CreateSupplierItem('V-10020', 'ITEM-1027', 2.70, 15, 100, false);
        CreateSupplierItem('V-10025', 'ITEM-1027', 4.10, 4, 15, true);
        CreateSupplierItem('V-10030', 'ITEM-1027', 3.20, 8, 30, false);

        // ITEM-1028 Tige Filetee M8 - 5 suppliers
        CreateSupplierItem('V-10010', 'ITEM-1028', 4.00, 4, 15, false);
        CreateSupplierItem('V-10014', 'ITEM-1028', 4.40, 8, 10, false);
        CreateSupplierItem('V-10018', 'ITEM-1028', 3.90, 7, 10, true);
        CreateSupplierItem('V-10021', 'ITEM-1028', 4.30, 3, 10, false);
        CreateSupplierItem('V-10034', 'ITEM-1028', 4.10, 2, 15, false);

        // ITEM-1029 Profil Alumunium - 5 suppliers
        CreateSupplierItem('V-10014', 'ITEM-1029', 7.80, 8, 10, false);
        CreateSupplierItem('V-10018', 'ITEM-1029', 7.00, 7, 5, true);
        CreateSupplierItem('V-10021', 'ITEM-1029', 7.20, 3, 10, false);
        CreateSupplierItem('V-10022', 'ITEM-1029', 8.20, 5, 10, false);
        CreateSupplierItem('V-10037', 'ITEM-1029', 8.00, 5, 10, false);

        // ITEM-1030 Courroie GT2 - 5 suppliers
        CreateSupplierItem('V-10010', 'ITEM-1030', 2.30, 4, 15, false);
        CreateSupplierItem('V-10014', 'ITEM-1030', 2.20, 8, 20, false);
        CreateSupplierItem('V-10019', 'ITEM-1030', 2.50, 6, 10, true);
        CreateSupplierItem('V-10035', 'ITEM-1030', 2.70, 6, 10, false);
        CreateSupplierItem('V-10037', 'ITEM-1030', 2.40, 5, 15, false);

        // ITEM-1031 Poulie GT2 - 5 suppliers
        CreateSupplierItem('V-10010', 'ITEM-1031', 1.85, 4, 15, false);
        CreateSupplierItem('V-10014', 'ITEM-1031', 2.00, 8, 15, false);
        CreateSupplierItem('V-10019', 'ITEM-1031', 1.90, 6, 10, true);
        CreateSupplierItem('V-10035', 'ITEM-1031', 2.10, 6, 10, false);
        CreateSupplierItem('V-10037', 'ITEM-1031', 1.75, 5, 20, false);

        // ITEM-1032 Vanne Solenoide - 5 suppliers
        CreateSupplierItem('V-10011', 'ITEM-1032', 11.80, 6, 5, false);
        CreateSupplierItem('V-10013', 'ITEM-1032', 12.50, 5, 5, true);
        CreateSupplierItem('V-10029', 'ITEM-1032', 13.00, 4, 5, false);
        CreateSupplierItem('V-10032', 'ITEM-1032', 10.50, 5, 10, false);
        CreateSupplierItem('V-10036', 'ITEM-1032', 11.20, 3, 5, false);

        // ITEM-1033 Joint Torique - 4 suppliers
        CreateSupplierItem('V-10002', 'ITEM-1033', 3.10, 7, 10, false);
        CreateSupplierItem('V-10014', 'ITEM-1033', 2.90, 8, 15, false);
        CreateSupplierItem('V-10023', 'ITEM-1033', 2.80, 6, 10, true);
        CreateSupplierItem('V-10033', 'ITEM-1033', 2.60, 7, 15, false);

        // ITEM-1034 Fil d Etain - 4 suppliers
        CreateSupplierItem('V-10010', 'ITEM-1034', 9.00, 4, 5, false);
        CreateSupplierItem('V-10014', 'ITEM-1034', 9.20, 8, 5, true);
        CreateSupplierItem('V-10025', 'ITEM-1034', 10.20, 4, 5, false);
        CreateSupplierItem('V-10038', 'ITEM-1034', 9.80, 4, 5, false);

        // ITEM-1035 Multimetre - 5 suppliers
        CreateSupplierItem('V-10011', 'ITEM-1035', 24.00, 6, 3, false);
        CreateSupplierItem('V-10013', 'ITEM-1035', 25.00, 5, 2, true);
        CreateSupplierItem('V-10016', 'ITEM-1035', 23.50, 5, 5, false);
        CreateSupplierItem('V-10029', 'ITEM-1035', 28.00, 4, 2, false);
        CreateSupplierItem('V-10036', 'ITEM-1035', 22.50, 3, 4, false);

        // ITEM-1036 Gaine Tressee - 4 suppliers
        CreateSupplierItem('V-10001', 'ITEM-1036', 1.35, 5, 50, false);
        CreateSupplierItem('V-10017', 'ITEM-1036', 1.28, 4, 40, false);
        CreateSupplierItem('V-10026', 'ITEM-1036', 1.30, 3, 50, true);
        CreateSupplierItem('V-10039', 'ITEM-1036', 1.25, 5, 100, false);

        // ITEM-1037 Carton d Emballage - 4 suppliers
        CreateSupplierItem('V-10002', 'ITEM-1037', 7.80, 7, 50, false);
        CreateSupplierItem('V-10012', 'ITEM-1037', 8.20, 3, 40, false);
        CreateSupplierItem('V-10023', 'ITEM-1037', 7.50, 6, 50, true);
        CreateSupplierItem('V-10033', 'ITEM-1037', 7.20, 7, 100, false);

        // ITEM-1038 Ruban Adhesif - 4 suppliers
        CreateSupplierItem('V-10002', 'ITEM-1038', 1.15, 7, 50, false);
        CreateSupplierItem('V-10012', 'ITEM-1038', 1.22, 3, 40, false);
        CreateSupplierItem('V-10023', 'ITEM-1038', 1.10, 6, 50, true);
        CreateSupplierItem('V-10033', 'ITEM-1038', 1.05, 7, 100, false);

        // ITEM-1039 Cable Cuivre Denude - 4 suppliers
        CreateSupplierItem('V-10001', 'ITEM-1039', 1.75, 5, 100, false);
        CreateSupplierItem('V-10015', 'ITEM-1039', 1.50, 14, 200, false);
        CreateSupplierItem('V-10026', 'ITEM-1039', 1.70, 3, 100, true);
        CreateSupplierItem('V-10039', 'ITEM-1039', 1.65, 5, 200, false);
    end;

    local procedure CreateSupplierItem(VendorNo: Code[20]; ItemNo: Code[20]; UnitPrice: Decimal; LeadTimeDays: Integer; MinOrderQty: Decimal; Preferred: Boolean)
    var
        SuppItem: Record "Supplier Item";
    begin
        if SuppItem.Get(VendorNo, ItemNo) then
            exit;
        SuppItem.Init();
        SuppItem."Vendor No." := VendorNo;
        SuppItem."Item No." := ItemNo;
        SuppItem."Unit Price" := UnitPrice;
        SuppItem."Lead Time Days" := LeadTimeDays;
        SuppItem."Min Order Qty" := MinOrderQty;
        SuppItem.Preferred := Preferred;
        SuppItem."Last Order Date" := CalcDate('<-' + Format(LeadTimeDays + 5) + 'D>', Today());
        SuppItem.Insert(true);
    end;

    // ─────────────────────────────────────────────
    // Supplier History (delivery events)
    // ─────────────────────────────────────────────
    local procedure GenerateSupplierHistory()
    var
        OrderDate: Date;
        ExpectedDate: Date;
        ActualDate: Date;
        OnTime: Boolean;
        QualityIssue: Boolean;
        i: Integer;
    begin
        // V-10000 TechParts - 8 deliveries, mostly on time
        for i := 1 to 8 do begin
            OrderDate := CalcDate('<-' + Format(i * 15) + 'D>', Today());
            ExpectedDate := CalcDate('<+3D>', OrderDate);
            OnTime := (i <> 3); // 1 late delivery
            if OnTime then
                ActualDate := ExpectedDate
            else
                ActualDate := CalcDate('<+2D>', ExpectedDate);
            QualityIssue := (i = 5); // 1 quality issue
            CreateHistoryEntry('V-10000', 'PO-H-' + Format(1000 + i), 'ITEM-1000', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 100, 100, 0.42);
        end;

        // V-10001 ElectroPro - 7 deliveries, some late
        for i := 1 to 7 do begin
            OrderDate := CalcDate('<-' + Format(i * 18) + 'D>', Today());
            ExpectedDate := CalcDate('<+5D>', OrderDate);
            OnTime := not (i in [2, 4, 6]); // 3 late
            if OnTime then
                ActualDate := ExpectedDate
            else
                ActualDate := CalcDate('<+3D>', ExpectedDate);
            QualityIssue := (i in [3, 7]);
            CreateHistoryEntry('V-10001', 'PO-H-' + Format(1100 + i), 'ITEM-1001', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 50, 50, 1.10);
        end;

        // V-10002 MegaSupply - 6 deliveries
        for i := 1 to 6 do begin
            OrderDate := CalcDate('<-' + Format(i * 20) + 'D>', Today());
            ExpectedDate := CalcDate('<+7D>', OrderDate);
            OnTime := not (i in [2, 5]);
            if OnTime then
                ActualDate := ExpectedDate
            else
                ActualDate := CalcDate('<+4D>', ExpectedDate);
            QualityIssue := (i = 3);
            CreateHistoryEntry('V-10002', 'PO-H-' + Format(1200 + i), 'ITEM-1010', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 10, 10, 4.50);
        end;

        // V-10003 QuickShip - 5 deliveries, fast but less reliable
        for i := 1 to 5 do begin
            OrderDate := CalcDate('<-' + Format(i * 22) + 'D>', Today());
            ExpectedDate := CalcDate('<+2D>', OrderDate);
            OnTime := not (i in [1, 4]);
            if OnTime then
                ActualDate := ExpectedDate
            else
                ActualDate := CalcDate('<+1D>', ExpectedDate);
            QualityIssue := (i = 2);
            CreateHistoryEntry('V-10003', 'PO-H-' + Format(1300 + i), 'ITEM-1015', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 200, 200, 1.30);
        end;

        // V-10004 GlobalParts - 4 deliveries, slow and unreliable
        for i := 1 to 4 do begin
            OrderDate := CalcDate('<-' + Format(i * 25) + 'D>', Today());
            ExpectedDate := CalcDate('<+10D>', OrderDate);
            OnTime := (i = 2);
            if OnTime then
                ActualDate := ExpectedDate
            else
                ActualDate := CalcDate('<+5D>', ExpectedDate);
            QualityIssue := (i in [1, 3]);
            CreateHistoryEntry('V-10004', 'PO-H-' + Format(1400 + i), 'ITEM-1008', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 5, 5, 12.00);
        end;

        // V-10005 PremiumTech - 9 deliveries, excellent
        for i := 1 to 9 do begin
            OrderDate := CalcDate('<-' + Format(i * 12) + 'D>', Today());
            ExpectedDate := CalcDate('<+6D>', OrderDate);
            OnTime := true; // Always on time
            ActualDate := ExpectedDate;
            QualityIssue := false; // No quality issues
            CreateHistoryEntry('V-10005', 'PO-H-' + Format(1500 + i), 'ITEM-1009', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 15, 15, 7.20);
        end;

        // V-10006 EcoParts - 4 deliveries, mediocre
        for i := 1 to 4 do begin
            OrderDate := CalcDate('<-' + Format(i * 30) + 'D>', Today());
            ExpectedDate := CalcDate('<+8D>', OrderDate);
            OnTime := (i in [1, 3]);
            if OnTime then
                ActualDate := ExpectedDate
            else
                ActualDate := CalcDate('<+3D>', ExpectedDate);
            QualityIssue := (i = 2);
            CreateHistoryEntry('V-10006', 'PO-H-' + Format(1600 + i), 'ITEM-1012', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 30, 30, 1.60);
        end;

        // V-10007 FastDeal - 6 deliveries, good
        for i := 1 to 6 do begin
            OrderDate := CalcDate('<-' + Format(i * 16) + 'D>', Today());
            ExpectedDate := CalcDate('<+4D>', OrderDate);
            OnTime := not (i = 3);
            if OnTime then
                ActualDate := ExpectedDate
            else
                ActualDate := CalcDate('<+2D>', ExpectedDate);
            QualityIssue := (i = 5);
            CreateHistoryEntry('V-10007', 'PO-H-' + Format(1700 + i), 'ITEM-1016', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 80, 80, 0.85);
        end;

        // V-10008 ValuePlus - 3 deliveries, poor
        for i := 1 to 3 do begin
            OrderDate := CalcDate('<-' + Format(i * 35) + 'D>', Today());
            ExpectedDate := CalcDate('<+12D>', OrderDate);
            OnTime := (i = 2);
            if OnTime then
                ActualDate := ExpectedDate
            else
                ActualDate := CalcDate('<+6D>', ExpectedDate);
            QualityIssue := (i = 1);
            CreateHistoryEntry('V-10008', 'PO-H-' + Format(1800 + i), 'ITEM-1003', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 500, 480, 0.25);
        end;

        // V-10009 SmartSource - 7 deliveries, very good
        for i := 1 to 7 do begin
            OrderDate := CalcDate('<-' + Format(i * 14) + 'D>', Today());
            ExpectedDate := CalcDate('<+5D>', OrderDate);
            OnTime := not (i = 4);
            if OnTime then
                ActualDate := ExpectedDate
            else
                ActualDate := CalcDate('<+1D>', ExpectedDate);
            QualityIssue := false;
            CreateHistoryEntry('V-10009', 'PO-H-' + Format(1900 + i), 'ITEM-1002', OrderDate, ExpectedDate, ActualDate, OnTime, QualityIssue, 30, 30, 3.10);
        end;
    end;

    local procedure CreateHistoryEntry(VendorNo: Code[20]; DocNo: Code[20]; ItemNo: Code[20]; OrderDate: Date; ExpectedDate: Date; ActualDate: Date; OnTime: Boolean; QualityIssue: Boolean; QtyOrdered: Decimal; QtyReceived: Decimal; UnitCost: Decimal)
    var
        History: Record "Supplier History";
    begin
        History.Init();
        // Entry No. is AutoIncrement, don't set it
        History."Vendor No." := VendorNo;
        History."Document No." := DocNo;
        History."Item No." := ItemNo;
        History."Order Date" := OrderDate;
        History."Expected Delivery Date" := ExpectedDate;
        History."Actual Delivery Date" := ActualDate;
        History."On Time" := OnTime;
        History."Quality Issue" := QualityIssue;
        History."Quantity Ordered" := QtyOrdered;
        History."Quantity Received" := QtyReceived;
        History."Unit Cost" := UnitCost;
        if QualityIssue then
            History.Notes := 'Quality issue reported on this delivery'
        else
            if not OnTime then
                History.Notes := 'Delivered late by ' + Format(ActualDate - ExpectedDate) + ' days'
            else
                History.Notes := 'Delivered on time';
        History.Insert(true);
    end;

    // ─────────────────────────────────────────────
    // Purchase Invoices (5 historical invoices)
    // ─────────────────────────────────────────────
    local procedure GeneratePurchaseInvoices()
    begin
        CreatePurchaseDocument(
            "Purchase Document Type"::Invoice, 'PI-10001',
            'V-10000', CalcDate('<-60D>', Today()),
            'ITEM-1000', 500, 0.42);
        CreatePurchaseDocument(
            "Purchase Document Type"::Invoice, 'PI-10002',
            'V-10005', CalcDate('<-45D>', Today()),
            'ITEM-1009', 20, 7.20);
        CreatePurchaseDocument(
            "Purchase Document Type"::Invoice, 'PI-10003',
            'V-10001', CalcDate('<-30D>', Today()),
            'ITEM-1015', 300, 1.05);
        CreatePurchaseDocument(
            "Purchase Document Type"::Invoice, 'PI-10004',
            'V-10002', CalcDate('<-20D>', Today()),
            'ITEM-1010', 15, 4.50);
        CreatePurchaseDocument(
            "Purchase Document Type"::Invoice, 'PI-10005',
            'V-10009', CalcDate('<-10D>', Today()),
            'ITEM-1002', 40, 3.10);
    end;

    // ─────────────────────────────────────────────
    // Purchase Orders (3 open/draft orders)
    // ─────────────────────────────────────────────
    local procedure GeneratePurchaseOrders()
    begin
        CreatePurchaseDocument(
            "Purchase Document Type"::Order, 'PO-10001',
            'V-10000', Today(),
            'ITEM-1006', 25, 4.20);
        CreatePurchaseDocument(
            "Purchase Document Type"::Order, 'PO-10002',
            'V-10007', Today(),
            'ITEM-1018', 10, 4.30);
        CreatePurchaseDocument(
            "Purchase Document Type"::Order, 'PO-10003',
            'V-10005', Today(),
            'ITEM-1019', 20, 5.00);
    end;

    local procedure CreatePurchaseDocument(DocType: Enum "Purchase Document Type"; DocNo: Code[20]; VendorNo: Code[20]; DocDate: Date; ItemNo: Code[20]; Qty: Decimal; UnitCost: Decimal)
    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        if PurchHeader.Get(DocType, DocNo) then
            exit;

        // Create Header
        PurchHeader.Init();
        PurchHeader."Document Type" := DocType;
        PurchHeader."No." := DocNo;
        PurchHeader.Insert(false);

        PurchHeader.Validate("Buy-from Vendor No.", VendorNo);
        PurchHeader.Validate("Order Date", DocDate);
        PurchHeader.Validate("Posting Date", DocDate);
        PurchHeader.Validate("Document Date", DocDate);
        PurchHeader.Validate("Expected Receipt Date", CalcDate('<+7D>', DocDate));
        PurchHeader.Modify(false);

        // Create Line
        PurchLine.Init();
        PurchLine."Document Type" := DocType;
        PurchLine."Document No." := DocNo;
        PurchLine."Line No." := 10000;
        PurchLine.Insert(false);

        PurchLine.Validate(Type, PurchLine.Type::Item);
        PurchLine.Validate("No.", ItemNo);
        PurchLine.Validate(Quantity, Qty);
        PurchLine.Validate("Direct Unit Cost", UnitCost);
        PurchLine.Modify(false);
    end;

    // ─────────────────────────────────────────────
    // Scoring Scenarios (5)
    // ─────────────────────────────────────────────
    local procedure GenerateScenarios()
    begin
        CreateScenario('SCEN-001', 'Approvisionnement Resistances', 'ITEM-1000', 1000);
        CreateScenario('SCEN-002', 'Achat Microcontroleurs', 'ITEM-1009', 50);
        CreateScenario('SCEN-003', 'Commande Cables Electriques', 'ITEM-1015', 500);
        CreateScenario('SCEN-004', 'Achat Capteurs Temperature', 'ITEM-1020', 100);
        CreateScenario('SCEN-005', 'Commande Alimentations 12V', 'ITEM-1022', 25);
    end;

    local procedure CreateScenario(ScenCode: Code[20]; ScenDesc: Text[100]; ItemNo: Code[20]; ReqQty: Decimal)
    var
        Scenario: Record "Scoring Scenario";
    begin
        if Scenario.Get(ScenCode) then
            exit;
        Scenario.Init();
        Scenario.Code := ScenCode;
        Scenario.Description := ScenDesc;
        Scenario."Item No." := ItemNo;
        Scenario."Required Qty" := ReqQty;
        // Weights use InitValue defaults: 30, 25, 20, 15, 10
        Scenario."Price Weight" := 30;
        Scenario."Lead Time Weight" := 25;
        Scenario."Quality Weight" := 20;
        Scenario."Reliability Weight" := 15;
        Scenario."History Weight" := 10;
        Scenario.Insert(true);
    end;
}
