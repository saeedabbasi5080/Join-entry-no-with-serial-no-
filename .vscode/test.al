pageextension 50120 ItemTrackingLinesExt extends "Item Tracking Lines"
{
    actions
    {
        addlast(processing)
        {
            action(Test)
            {
                Caption = 'Auoto Assigin Serial';
                Image = Allocate;

                trigger OnAction()

                begin
                    AssignSerialsFromLedgerSimple(Rec);
                end;
            }
        }
    }

    procedure AssignSerialsFromLedgerSimple(var Rec: Record "Tracking Specification")
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
        TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
        CurrentSalesLine: Record "Sales Line";
        CurrentWhseShptLine: Record "Warehouse Shipment Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry: Record "Reservation Entry";
        Item: Record Item;
        CheckTrackingSpec: Record "Tracking Specification"; // فقط برای چک کردن
        ExistingQty: Decimal;
        RemainingQty: Decimal;
        nNeeded: Decimal;
        FoundCount: Integer;
        hasFound: Boolean;
        ItemNo: Code[20];
        VariantCode: Code[10];
        LocationCode: Code[10];
        ReservedQtyCheck: Decimal;
        CurrRecQtyChec: Decimal;
    begin
        // Initial validation: Check if there are already tracking lines with serial numbers
        CurrRecQtyChec := 0;
        Rec.Reset();
        Rec.SetRange("Source Type", Rec."Source Type");
        Rec.SetRange("Source ID", Rec."Source ID");
        Rec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        Rec.SetFilter("Serial No.", '<>%1', '');
        if Rec.FindSet() then
            repeat
                CurrRecQtyChec += Abs(Rec."Quantity (Base)");
            until Rec.Next() = 0;


        // if not Rec.IsEmpty() then begin
        //     Message('Serial numbers have already been assigned to this line. No additional assignment needed.');
        //     exit;
        // end;

        // 1. Determine source type and get line information
        case Rec."Source Type" of
            DATABASE::"Sales Line":
                begin
                    Clear(CurrentSalesLine);
                    CurrentSalesLine.SetRange("Document Type", CurrentSalesLine."Document Type"::Order);
                    CurrentSalesLine.SetRange("Document No.", Rec."Source ID");
                    CurrentSalesLine.SetRange("Line No.", Rec."Source Ref. No.");
                    if not CurrentSalesLine.FindFirst() then begin
                        Message('Sales Order line not found.');
                        exit;
                    end;
                    ItemNo := CurrentSalesLine."No.";
                    VariantCode := CurrentSalesLine."Variant Code";
                    LocationCode := CurrentSalesLine."Location Code";
                    nNeeded := CurrentSalesLine."Qty. to Ship";
                end;
            DATABASE::"Warehouse Shipment Line":
                begin
                    Clear(CurrentWhseShptLine);
                    CurrentWhseShptLine.SetRange("No.", Rec."Source ID");
                    CurrentWhseShptLine.SetRange("Line No.", Rec."Source Ref. No.");
                    if not CurrentWhseShptLine.FindFirst() then begin
                        Message('Warehouse Shipment line not found.');
                        exit;
                    end;
                    ItemNo := CurrentWhseShptLine."Item No.";
                    VariantCode := CurrentWhseShptLine."Variant Code";
                    LocationCode := CurrentWhseShptLine."Location Code";
                    nNeeded := CurrentWhseShptLine."Qty. Outstanding (Base)";
                end;
            else begin
                Message('This function only works for Sales Orders and Warehouse Shipments.');
                exit;
            end;
        end;

        if CurrRecQtyChec >= nNeeded then begin
            Message('Serial numbers have already been assigned to this line. No additional assignment needed.');
            // Format(Rec."Source Type"), nNeeded, CurrRecQtyChec);
            exit;
        end;

        // Additional validation: Check if sufficient quantity is already reserved for this document
        // ReservedQtyCheck := 0;
        // Clear(ReservEntry);
        // ReservEntry.SetRange("Item No.", ItemNo);
        // ReservEntry.SetRange("Source ID", Rec."Source ID");
        // ReservEntry.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        // // ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
        // ReservEntry.SetFilter("Serial No.", '<>%1', '');
        // if ReservEntry.FindSet() then
        //     repeat
        //         ReservedQtyCheck += Abs(ReservEntry."Quantity (Base)");
        //     until ReservEntry.Next() = 0;

        // if ReservedQtyCheck >= nNeeded then begin
        //     Message('Sufficient serial numbers are already reserved for this %1. Required: %2, Reserved: %3',
        //         Format(Rec."Source Type"), nNeeded, ReservedQtyCheck);
        //     exit;
        // end;

        // 2. Check item
        Clear(Item);
        if not Item.Get(ItemNo) then begin
            Message('Item %1 not found.', ItemNo);
            exit;
        end;

        if Item."Item Tracking Code" = '' then begin
            Message('Item %1 is not enabled for tracking.', Item."No.");
            exit;
        end;

        // 3. Calculate existing quantity in Item Tracking Lines
        ExistingQty := 0;
        Rec.Reset();
        Rec.SetRange("Source Type", Rec."Source Type");
        Rec.SetRange("Source ID", Rec."Source ID");
        Rec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        if Rec.FindSet() then
            repeat
                ExistingQty += Abs(Rec."Quantity (Base)");
            until Rec.Next() = 0;

        // 4. Calculate remaining quantity
        RemainingQty := nNeeded - ExistingQty;

        if RemainingQty <= 0 then begin
            Message('All required quantity has already been assigned.');
            exit;
        end;

        FoundCount := 0;

        // 5. Search Item Ledger Entries and create tracking specifications
        Clear(ItemLedgEntry);
        ItemLedgEntry.SetRange("Item No.", ItemNo);
        ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Purchase);
        ItemLedgEntry.SetFilter("Remaining Quantity", '>0');
        ItemLedgEntry.SetFilter("Serial No.", '<>%1', '');
        ItemLedgEntry.SetRange("Document Type", ItemLedgEntry."Document Type"::"Purchase Receipt");

        if VariantCode <> '' then
            ItemLedgEntry.SetRange("Variant Code", VariantCode);
        if LocationCode <> '' then
            ItemLedgEntry.SetRange("Location Code", LocationCode);

        // Sort by proper criteria based on costing method
        if Item."Costing Method" = Item."Costing Method"::FIFO then
            ItemLedgEntry.SetCurrentKey("Entry No.") // FIFO - earliest entries first
        else
            // For other costing methods, sort by expiration date or warranty date
            ItemLedgEntry.SetCurrentKey("Expiration Date", "Warranty Date");

        if ItemLedgEntry.FindSet() then
            repeat
                if FoundCount >= RemainingQty then
                    break;

                hasFound := true;

                // Check that serial is not reserved for another document
                Clear(ReservEntry);
                ReservEntry.SetRange("Item No.", ItemNo);
                ReservEntry.SetRange("Serial No.", Rec."Serial No.");
                ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);

                // If source is Sales Line, add except current order logic
                if Rec."Source Type" = DATABASE::"Sales Line" then
                    ReservEntry.SetFilter("Source ID", '<>%1', Rec."Source ID");

                if not ReservEntry.IsEmpty() then
                    hasFound := false;

                // Check that serial doesn't already exist in tracking lines
                if hasFound then begin
                    Rec.Reset();
                    Rec.SetRange("Source Type", Rec."Source Type");
                    Rec.SetRange("Source ID", Rec."Source ID");
                    Rec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
                    Rec.SetRange("Serial No.", ItemLedgEntry."Serial No.");
                    if not Rec.IsEmpty() then
                        hasFound := false;
                end;

                if hasFound then begin
                    // Create new record for each serial
                    Clear(Rec);
                    xRec."Serial No." := '';
                    xRec."Entry No." := 0;
                    xRec."Quantity (Base)" := 0;
                    Rec.TransferFields(xRec); // Copy base values from current record

                    // Set new values
                    Rec.Validate("Serial No.", ItemLedgEntry."Serial No.");
                    // Rec.Validate("Lot No.", ItemLedgEntry."Lot No.");
                    if Rec."Quantity (Base)" < 1 then
                        Rec.Validate("Quantity (Base)", 1);
                    Rec."Expiration Date" := ItemLedgEntry."Expiration Date";
                    Rec."Warranty Date" := ItemLedgEntry."Warranty Date";

                    // Insert new record
                    if Rec."Entry No." = 0 then begin
                        InsertRecord(Rec);
                        SetVariables(Rec, TempTrackingSpecificationDelete, TempTrackingSpecificationModify);
                        CreateReservEntry.CreateReservEntryFrom(Rec);
                        FoundCount += 1;
                    end
                    else
                        if Rec."Entry No." <> xRec."Entry No." then begin
                            InsertRecord(Rec);
                            SetVariables(Rec, TempTrackingSpecificationDelete, TempTrackingSpecificationModify);
                            CreateReservEntry.CreateReservEntryFrom(Rec);
                            FoundCount += 1;
                        end;


                end;
            until ItemLedgEntry.Next() = 0;

        // Refresh page
        CurrPage.Update(true);

        // 6. Show result
        if FoundCount = 0 then
            Message('No available serials found.')
        else
            if FoundCount < RemainingQty then
                Message('Only %1 serials out of %2 needed were found and added.\Total assigned: %3 of %4',
                    FoundCount, RemainingQty, ExistingQty + FoundCount, nNeeded)
            else
                Message('%1 serials successfully added.\Total assigned: %2 of %3',
                    FoundCount, ExistingQty + FoundCount, nNeeded);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        TempTrackingSpecificationInsert: Record "Tracking Specification" temporary;
        TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
        TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
    begin
        // Use Business Central's standard logic to delete the tracking line
        // SetVariables(TempTrackingSpecificationInsert, TempTrackingSpecificationModify, Rec);
        exit(true);
    end;
}