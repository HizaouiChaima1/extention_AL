namespace DefaultPublisher.ALProject1;

page 50114 "Supplier Item API"
{
    PageType = API;
    APIPublisher = 'defaultpublisher';
    APIGroup = 'alproject1';
    APIVersion = 'v1.0';
    EntityName = 'supplierItem';
    EntitySetName = 'supplierItems';
    SourceTable = "Supplier Item";
    DelayedInsert = true;
    ODataKeyFields = "Vendor No.", "Item No.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(vendorNo; Rec."Vendor No.") { Caption = 'Vendor No.'; }
                field(itemNo; Rec."Item No.") { Caption = 'Item No.'; }
                field(vendorName; Rec."Vendor Name") { Caption = 'Vendor Name'; }
                field(itemDescription; Rec."Item Description") { Caption = 'Item Description'; }
                field(unitPrice; Rec."Unit Price") { Caption = 'Unit Price'; }
                field(leadTimeDays; Rec."Lead Time Days") { Caption = 'Lead Time Days'; }
                field(minOrderQty; Rec."Min Order Qty") { Caption = 'Min Order Qty'; }
                field(preferred; Rec.Preferred) { Caption = 'Preferred'; }
                field(lastOrderDate; Rec."Last Order Date") { Caption = 'Last Order Date'; }
                field(currencyCode; Rec."Currency Code") { Caption = 'Currency Code'; }
            }
        }
    }
}
