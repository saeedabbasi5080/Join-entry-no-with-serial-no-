pageextension 50420 ItemTrackingLinesExt extends "Item Tracking Lines"
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

    trigger OnDeleteRecord(): Boolean
    var
        TrackingSpec: Record "Tracking Specification";
        SerialNo: Code[50];
    begin
        // Only delete the selected serial
        if Rec."Serial No." = '' then begin
            Message('Please select a serial first.');
            exit(false);
        end;

        SerialNo := Rec."Serial No.";

        // Use the same successful logic as before
        TrackingSpec.Reset();
        TrackingSpec.SetRange("Source Type", Rec."Source Type");
        TrackingSpec.SetRange("Source ID", Rec."Source ID");
        TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        TrackingSpec.SetRange("Serial No.", SerialNo); // Only selected serial

        if TrackingSpec.FindFirst() then begin
            if TrackingSpec.Delete() then begin
                CurrPage.Update(true);
                Message('Serial %1 deleted.', SerialNo);
            end else begin
                Message('Error deleting serial %1', SerialNo);
            end;
        end else begin
            Message('Serial %1 not found.', SerialNo);
        end;

        exit(false); // Return false because we handled the delete ourselves
    end;

    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        ItemLE: Record "Item Ledger Entry";
        foundCount: Integer;

    local procedure AssignSerialsFromLedgerSimple()
    var
        CurrentSalesLine: Record "Sales Line";
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

        // 3. Main execution - always work with Tracking Specification
        AssignToTrackingSpec(CurrentSalesLine);
    end;

    local procedure AssignToTrackingSpec(CurrentSalesLine: Record "Sales Line")
    var
        hasFound: Boolean;
        TrackingSpec: Record "Tracking Specification";
        NextEntryNo: Integer;
        NewTrackingSpec: Record "Tracking Specification";
        ExistingQty: Decimal;
        RemainingQty: Decimal;
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry: Record "Reservation Entry";
        nNeeded: Decimal;
    begin
        // First convert Reservation Entries to Tracking Specification
        ConvertReservationToTrackingSpec(CurrentSalesLine);

        // Calculate existing quantity in Item Tracking Lines
        ExistingQty := 0;
        TrackingSpec.Reset();
        TrackingSpec.SetRange("Source Type", Rec."Source Type");
        TrackingSpec.SetRange("Source ID", Rec."Source ID");
        TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        if TrackingSpec.FindSet() then
            repeat
                ExistingQty += Abs(TrackingSpec."Quantity (Base)");
            until TrackingSpec.Next() = 0;

        // Calculate remaining quantity
        nNeeded := Abs(CurrentSalesLine."Quantity (Base)");
        RemainingQty := nNeeded - ExistingQty;

        if RemainingQty <= 0 then begin
            Message('All required quantity has already been assigned.');
            exit;
        end;

        // Find last Entry No
        TrackingSpec.Reset();
        TrackingSpec.SetRange("Source Type", Rec."Source Type");
        TrackingSpec.SetRange("Source ID", Rec."Source ID");
        TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        if TrackingSpec.FindLast() then
            NextEntryNo := TrackingSpec."Entry No." + 1
        else
            NextEntryNo := 1;

        foundCount := 0;

        // Search Item Ledger Entries
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
                    // Create new record
                    Clear(NewTrackingSpec);
                    NewTrackingSpec.Init();
                    NewTrackingSpec."Entry No." := NextEntryNo;
                    NewTrackingSpec."Source Type" := Rec."Source Type";
                    NewTrackingSpec."Source Subtype" := Rec."Source Subtype";
                    NewTrackingSpec."Source ID" := Rec."Source ID";
                    NewTrackingSpec."Source Batch Name" := Rec."Source Batch Name";
                    NewTrackingSpec."Source Prod. Order Line" := Rec."Source Prod. Order Line";
                    NewTrackingSpec."Source Ref. No." := Rec."Source Ref. No.";
                    NewTrackingSpec."Item No." := ItemLedgEntry."Item No.";
                    NewTrackingSpec."Variant Code" := ItemLedgEntry."Variant Code";
                    NewTrackingSpec."Location Code" := ItemLedgEntry."Location Code";
                    NewTrackingSpec."Serial No." := ItemLedgEntry."Serial No.";
                    NewTrackingSpec."Lot No." := ItemLedgEntry."Lot No.";

                    // Set quantities (negative for Sales Order)
                    NewTrackingSpec."Quantity (Base)" := -1;
                    NewTrackingSpec."Qty. to Handle (Base)" := -1;
                    NewTrackingSpec."Qty. to Invoice (Base)" := -1;

                    NewTrackingSpec."Expiration Date" := ItemLedgEntry."Expiration Date";
                    NewTrackingSpec."Warranty Date" := ItemLedgEntry."Warranty Date";
                    NewTrackingSpec."Creation Date" := Today;

                    if NewTrackingSpec.Insert() then begin
                        foundCount += 1;
                        NextEntryNo += 1;
                    end;
                end;
            until ItemLedgEntry.Next() = 0;

        // Update page
        CurrPage.Update(false);

        ShowResult(foundCount, RemainingQty, ExistingQty, nNeeded);
    end;

    local procedure ConvertReservationToTrackingSpec(CurrentSalesLine: Record "Sales Line")
    var
        ReservEntry: Record "Reservation Entry";
        TrackingSpec: Record "Tracking Specification";
        NewTrackingSpec: Record "Tracking Specification";
        NextEntryNo: Integer;
    begin
        // Check if Reservation Entry exists
        ReservEntry.SetSourceFilter(
            Rec."Source Type",
            Rec."Source Subtype",
            Rec."Source ID",
            Rec."Source Ref. No.",
            false);
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
        ReservEntry.SetFilter("Serial No.", '<>%1', '');

        if ReservEntry.IsEmpty() then
            exit; // No Reservation Entry exists

        // Find last Entry No in Tracking Spec
        TrackingSpec.Reset();
        TrackingSpec.SetRange("Source Type", Rec."Source Type");
        TrackingSpec.SetRange("Source ID", Rec."Source ID");
        TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        if TrackingSpec.FindLast() then
            NextEntryNo := TrackingSpec."Entry No." + 1
        else
            NextEntryNo := 1;

        // Convert each Reservation Entry to Tracking Specification
        if ReservEntry.FindSet() then
            repeat
                // Check if this serial already exists in Tracking Spec
                TrackingSpec.Reset();
                TrackingSpec.SetRange("Source Type", Rec."Source Type");
                TrackingSpec.SetRange("Source ID", Rec."Source ID");
                TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
                TrackingSpec.SetRange("Serial No.", ReservEntry."Serial No.");

                if TrackingSpec.IsEmpty() then begin
                    // Create new Tracking Specification
                    Clear(NewTrackingSpec);
                    NewTrackingSpec.Init();
                    NewTrackingSpec."Entry No." := NextEntryNo;
                    NewTrackingSpec."Source Type" := ReservEntry."Source Type";
                    NewTrackingSpec."Source Subtype" := ReservEntry."Source Subtype";
                    NewTrackingSpec."Source ID" := ReservEntry."Source ID";
                    NewTrackingSpec."Source Batch Name" := Rec."Source Batch Name";
                    NewTrackingSpec."Source Prod. Order Line" := Rec."Source Prod. Order Line";
                    NewTrackingSpec."Source Ref. No." := ReservEntry."Source Ref. No.";
                    NewTrackingSpec."Item No." := ReservEntry."Item No.";
                    NewTrackingSpec."Variant Code" := ReservEntry."Variant Code";
                    NewTrackingSpec."Location Code" := ReservEntry."Location Code";
                    NewTrackingSpec."Serial No." := ReservEntry."Serial No.";
                    NewTrackingSpec."Lot No." := ReservEntry."Lot No.";
                    NewTrackingSpec."Quantity (Base)" := ReservEntry."Quantity (Base)";
                    NewTrackingSpec."Qty. to Handle (Base)" := ReservEntry."Quantity (Base)";
                    NewTrackingSpec."Qty. to Invoice (Base)" := ReservEntry."Quantity (Base)";
                    NewTrackingSpec."Expiration Date" := ReservEntry."Expiration Date";
                    NewTrackingSpec."Warranty Date" := ReservEntry."Warranty Date";
                    NewTrackingSpec."Creation Date" := Today;

                    if NewTrackingSpec.Insert() then
                        NextEntryNo += 1;
                end;
            until ReservEntry.Next() = 0;
    end;

    local procedure ShowResult(FoundCount: Integer; RemainingQty: Decimal; ExistingQty: Decimal; TotalNeeded: Decimal)
    begin
        if FoundCount = 0 then begin
            Message('No available serials found.');
            exit;
        end;

        if FoundCount < RemainingQty then
            Message('Only %1 serials out of %2 needed were found and added.\nTotal assigned: %3 of %4',
                FoundCount, RemainingQty, ExistingQty + FoundCount, TotalNeeded)
        else
            Message('%1 serials successfully added.\nTotal assigned: %2 of %3',
                FoundCount, ExistingQty + FoundCount, TotalNeeded);
    end;
}