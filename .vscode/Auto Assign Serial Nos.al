pageextension 50120 ItemTrackingLinesExt extends "Item Tracking Lines"
{
    actions
    {
        addlast(processing)
        {
            action(AssignSerials)
            {
                Caption = 'Auto Select Serial';
                Image = Allocate;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    AssignSerialsFromLedgerSimple();
                end;
            }
        }
    }

    local procedure AssignSerialsFromLedgerSimple()
    var
        CurrentSalesLine: Record "Sales Line";
        TrackingSpec: Record "Tracking Specification";
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry: Record "Reservation Entry";
        Item: Record Item;
        NextEntryNo: Integer;
        ExistingQty: Decimal;
        RemainingQty: Decimal;
        nNeeded: Decimal;
        foundCount: Integer;
        hasFound: Boolean;
    begin
        // 1. Find current sales order line
        Clear(CurrentSalesLine);
        CurrentSalesLine.SetRange("Document Type", CurrentSalesLine."Document Type"::Order);
        CurrentSalesLine.SetRange("Document No.", Rec."Source ID");
        CurrentSalesLine.SetRange("Line No.", Rec."Source Ref. No.");
        if not CurrentSalesLine.FindFirst() then begin
            Message('Order line not found.');
            exit;
        end;

        // 2. Check item
        Clear(Item);
        if not Item.Get(CurrentSalesLine."No.") then begin
            Message('Item %1 not found.', CurrentSalesLine."No.");
            exit;
        end;

        if Item."Item Tracking Code" = '' then begin
            Message('Item %1 is not enabled for tracking.', Item."No.");
            exit;
        end;

        // 3. Calculate existing quantity in Item Tracking Lines
        ExistingQty := 0;
        TrackingSpec.Reset();
        TrackingSpec.SetRange("Source Type", Rec."Source Type");
        TrackingSpec.SetRange("Source ID", Rec."Source ID");
        TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        if TrackingSpec.FindSet() then
            repeat
                ExistingQty += Abs(TrackingSpec."Quantity (Base)");
            until TrackingSpec.Next() = 0;

        // 4. Calculate remaining quantity
        nNeeded := Abs(CurrentSalesLine."Quantity (Base)");
        RemainingQty := nNeeded - ExistingQty;

        if RemainingQty <= 0 then begin
            Message('All required quantity has already been assigned.');
            exit;
        end;

        // 5. Find last Entry No
        TrackingSpec.Reset();
        TrackingSpec.SetRange("Source Type", Rec."Source Type");
        TrackingSpec.SetRange("Source ID", Rec."Source ID");
        TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        if TrackingSpec.FindLast() then
            NextEntryNo := TrackingSpec."Entry No." + 1
        else
            NextEntryNo := 1;

        foundCount := 0;

        // 6. Search Item Ledger Entries and create tracking specifications
        Clear(ItemLedgEntry);
        ItemLedgEntry.SetRange("Item No.", CurrentSalesLine."No.");
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Purchase);
        ItemLedgEntry.SetFilter("Remaining Quantity", '>0');
        ItemLedgEntry.SetFilter("Serial No.", '<>%1', '');

        if CurrentSalesLine."Variant Code" <> '' then
            ItemLedgEntry.SetRange("Variant Code", CurrentSalesLine."Variant Code");
        if CurrentSalesLine."Location Code" <> '' then
            ItemLedgEntry.SetRange("Location Code", CurrentSalesLine."Location Code");

        ItemLedgEntry.SetCurrentKey("Entry No.");
        if ItemLedgEntry.FindSet() then
            repeat
                if foundCount >= RemainingQty then
                    break;

                hasFound := true;

                // Check that serial is not reserved for another document
                Clear(ReservEntry);
                ReservEntry.SetRange("Item No.", CurrentSalesLine."No.");
                ReservEntry.SetRange("Serial No.", ItemLedgEntry."Serial No.");
                ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
                ReservEntry.SetFilter("Source ID", '<>%1', CurrentSalesLine."Document No.");
                if not ReservEntry.IsEmpty() then
                    hasFound := false;

                // Check that serial doesn't already exist in tracking lines
                if hasFound then begin
                    TrackingSpec.Reset();
                    TrackingSpec.SetRange("Source Type", Rec."Source Type");
                    TrackingSpec.SetRange("Source ID", Rec."Source ID");
                    TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
                    TrackingSpec.SetRange("Serial No.", ItemLedgEntry."Serial No.");
                    if not TrackingSpec.IsEmpty() then
                        hasFound := false;
                end;

                if hasFound then begin
                    // Create new record directly in Rec
                    // Rec.Init();
                    // Rec."Entry No." := NextEntryNo;
                    // Rec."Source Type" := Rec."Source Type";
                    // Rec."Source Subtype" := Rec."Source Subtype";
                    // Rec."Source ID" := Rec."Source ID";
                    // Rec."Source Batch Name" := Rec."Source Batch Name";
                    // Rec."Source Prod. Order Line" := Rec."Source Prod. Order Line";
                    // Rec."Source Ref. No." := Rec."Source Ref. No.";
                    // Rec."Item No." := ItemLedgEntry."Item No.";
                    // Rec."Variant Code" := ItemLedgEntry."Variant Code";
                    // Rec."Location Code" := ItemLedgEntry."Location Code";
                    Rec.Validate("Serial No.", ItemLedgEntry."Serial No.");
                    // Rec."Lot No." := ItemLedgEntry."Lot No.";

                    // Set quantities (negative for Sales Order)
                    Rec."Quantity (Base)" := 1;
                    // Rec."Qty. to Handle (Base)" := -1;
                    // Rec."Qty. to Invoice (Base)" := -1;

                    // Rec."Expiration Date" := ItemLedgEntry."Expiration Date";
                    // Rec."Warranty Date" := ItemLedgEntry."Warranty Date";
                    // Rec."Creation Date" := Today;

                    Rec.Insert();
                    foundCount += 1;
                    NextEntryNo += 1;
                end;
            until ItemLedgEntry.Next() = 0;

        // 7. Show result
        if foundCount = 0 then
            Message('No available serials found.')
        else
            if foundCount < RemainingQty then
                Message('Only %1 serials out of %2 needed were found and added.\nTotal assigned: %3 of %4',
                    foundCount, RemainingQty, ExistingQty + foundCount, nNeeded)
            else
                Message('%1 serials successfully added.\nTotal assigned: %2 of %3',
                    foundCount, ExistingQty + foundCount, nNeeded);
    end;
}