namespace DefaultPublisher.ALProject1;

/// <summary>
/// List page showing all supplier-item relationships with prices and lead times.
/// This is the core data used by the scoring engine for price and lead time normalization.
/// </summary>
page 50104 "Supplier Item List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Supplier Item";
    Caption = 'Supplier Items';
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
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The item number.';
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'The item description.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'This vendor''s unit price for the item.';
                }
                field("Lead Time Days"; Rec."Lead Time Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Delivery lead time in days for this vendor.';
                }
                field("Min Order Qty"; Rec."Min Order Qty")
                {
                    ApplicationArea = All;
                    ToolTip = 'Minimum order quantity for this vendor-item combination.';
                }
                field(Preferred; Rec.Preferred)
                {
                    ApplicationArea = All;
                    ToolTip = 'Whether this is the preferred supplier for the item.';
                }
                field("Last Order Date"; Rec."Last Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date of the last order placed with this vendor for this item.';
                }
            }
        }
    }
}
