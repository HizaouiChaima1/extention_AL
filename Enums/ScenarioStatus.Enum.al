namespace DefaultPublisher.ALProject1;

/// <summary>
/// Status of a scoring scenario.
/// </summary>
enum 50100 "Scenario Status"
{
    Extensible = true;

    value(0; "Draft")
    {
        Caption = 'Draft';
    }
    value(1; "Scored")
    {
        Caption = 'Scored';
    }
    value(2; "PO Created")
    {
        Caption = 'PO Created';
    }
}
