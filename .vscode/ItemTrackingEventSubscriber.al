codeunit 50101 ItemTrackingEventSubscriber
{
    var
        AutoAssignMode: Boolean;

    [EventSubscriber(ObjectType::page, page::"Item Tracking Lines", 'OnInsertRecordOnBeforeTempItemTrackLineInsert', '', false, false)]
    local procedure OnInsertRecordOnBeforeTempItemTrackLineInsert(var TempTrackingSpecificationInsert: Record "Tracking Specification" temporary; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    var
        SalesLine: Record "Sales Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry: Record "Reservation Entry";
        Item: Record Item;
        hasFound: Boolean;
        SerialNo: Code[50];
    begin
        // Only proceed if auto-assign mode is enabled
        if not AutoAssignMode then
            exit;

        // Check if this is for a Sales Order
        if TempTrackingSpecificationInsert."Source Type" <> DATABASE::"Sales Line" then
            exit;

        // Get the sales line
        Clear(SalesLine);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", TempTrackingSpecificationInsert."Source ID");
        SalesLine.SetRange("Line No.", TempTrackingSpecificationInsert."Source Ref. No.");
        if not SalesLine.FindFirst() then
            exit;

        // Check if item has tracking enabled
        Clear(Item);
        if not Item.Get(SalesLine."No.") then
            exit;
        if Item."Item Tracking Code" = '' then
            exit;

        // Auto-assign serial number if none is provided
        if TempTrackingSpecificationInsert."Serial No." = '' then begin
            SerialNo := FindAvailableSerial(SalesLine);
            if SerialNo <> '' then begin
                TempTrackingSpecificationInsert."Serial No." := SerialNo;
                TempTrackingSpecification."Serial No." := SerialNo;
            end;
        end;
    end;

    procedure SetAutoAssignMode(Enable: Boolean)
    begin
        AutoAssignMode := Enable;
    end;

    procedure AutoAssignSerials(var TrackingSpecRec: Record "Tracking Specification")
    var
        CurrentSalesLine: Record "Sales Line";
        TrackingSpec: Record "Tracking Specification";
        NewTrackingSpec: Record "Tracking Specification";
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
        CurrentSalesLine.SetRange("Document No.", TrackingSpecRec."Source ID");
        CurrentSalesLine.SetRange("Line No.", TrackingSpecRec."Source Ref. No.");
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
        TrackingSpec.SetRange("Source Type", TrackingSpecRec."Source Type");
        TrackingSpec.SetRange("Source ID", TrackingSpecRec."Source ID");
        TrackingSpec.SetRange("Source Ref. No.", TrackingSpecRec."Source Ref. No.");
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
        TrackingSpec.SetRange("Source Type", TrackingSpecRec."Source Type");
        TrackingSpec.SetRange("Source ID", TrackingSpecRec."Source ID");
        TrackingSpec.SetRange("Source Ref. No.", TrackingSpecRec."Source Ref. No.");
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
                    TrackingSpec.SetRange("Source Type", TrackingSpecRec."Source Type");
                    TrackingSpec.SetRange("Source ID", TrackingSpecRec."Source ID");
                    TrackingSpec.SetRange("Source Ref. No.", TrackingSpecRec."Source Ref. No.");
                    TrackingSpec.SetRange("Serial No.", ItemLedgEntry."Serial No.");
                    if not TrackingSpec.IsEmpty() then
                        hasFound := false;
                end;

                if hasFound then begin
                    // Create new record
                    Clear(NewTrackingSpec);
                    NewTrackingSpec.Init();
                    NewTrackingSpec."Entry No." := NextEntryNo;
                    NewTrackingSpec."Source Type" := TrackingSpecRec."Source Type";
                    NewTrackingSpec."Source Subtype" := TrackingSpecRec."Source Subtype";
                    NewTrackingSpec."Source ID" := TrackingSpecRec."Source ID";
                    NewTrackingSpec."Source Batch Name" := TrackingSpecRec."Source Batch Name";
                    NewTrackingSpec."Source Prod. Order Line" := TrackingSpecRec."Source Prod. Order Line";
                    NewTrackingSpec."Source Ref. No." := TrackingSpecRec."Source Ref. No.";
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

    local procedure FindAvailableSerial(SalesLine: Record "Sales Line"): Code[50]
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry: Record "Reservation Entry";
        TrackingSpec: Record "Tracking Specification";
        hasFound: Boolean;
    begin
        // Search Item Ledger Entries for available serials
        Clear(ItemLedgEntry);
        ItemLedgEntry.SetRange("Item No.", SalesLine."No.");
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Purchase);
        ItemLedgEntry.SetFilter("Remaining Quantity", '>0');
        ItemLedgEntry.SetFilter("Serial No.", '<>%1', '');

        if SalesLine."Variant Code" <> '' then
            ItemLedgEntry.SetRange("Variant Code", SalesLine."Variant Code");
        if SalesLine."Location Code" <> '' then
            ItemLedgEntry.SetRange("Location Code", SalesLine."Location Code");

        ItemLedgEntry.SetCurrentKey("Entry No.");
        if ItemLedgEntry.FindSet() then
            repeat
                hasFound := true;

                // Check that serial is not reserved for another document
                Clear(ReservEntry);
                ReservEntry.SetRange("Item No.", SalesLine."No.");
                ReservEntry.SetRange("Serial No.", ItemLedgEntry."Serial No.");
                ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
                ReservEntry.SetFilter("Source ID", '<>%1', SalesLine."Document No.");
                if not ReservEntry.IsEmpty() then
                    hasFound := false;

                // Check that serial doesn't already exist in tracking lines
                if hasFound then begin
                    TrackingSpec.Reset();
                    TrackingSpec.SetRange("Source Type", DATABASE::"Sales Line");
                    TrackingSpec.SetRange("Source ID", SalesLine."Document No.");
                    TrackingSpec.SetRange("Source Ref. No.", SalesLine."Line No.");
                    TrackingSpec.SetRange("Serial No.", ItemLedgEntry."Serial No.");
                    if not TrackingSpec.IsEmpty() then
                        hasFound := false;
                end;

                if hasFound then
                    exit(ItemLedgEntry."Serial No.");

            until ItemLedgEntry.Next() = 0;

        exit(''); // No available serial found
    end;
}