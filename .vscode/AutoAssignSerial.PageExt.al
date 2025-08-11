pageextension 50120 ItemTrackingLinesPageExt extends "Item Tracking Lines"
{
    actions
    {
        addlast(processing)
        {
            action(AutoAssignSerial)
            {
                Caption = 'Auto Assign Serial';
                Image = CreateSerialNo;
                // Only show button for Warehouse Shipment Lines
                // Visible = IsWarehouseShipmentSource();

                trigger OnAction()
                begin
                    AssignSerialsFromLedgerSimple(Rec);
                end;
            }
        }
    }

    // Function to check if current source is Warehouse Shipment
    // local procedure IsWarehouseShipmentSource(): Boolean
    // begin
    //     exit(Rec."Source Type" = 37);
    // end;

    // Rest of your code remains the same...
    procedure AssignSerialsFromLedgerSimple(var Rec: Record "Tracking Specification")
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
        TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
        ExistingQty: Decimal;
        RemainingQty: Decimal;
        RequiredQuantity: Decimal;
        FoundCount: Integer;
        ItemNo: Code[20];
        VariantCode: Code[10];
        LocationCode: Code[10];
    begin
        // Additional check to ensure this only works for Sales Lines
        if Rec."Source Type" <> 37 then begin
            Message('This function only works for Warehouse Shipment.');
            exit;
        end;

        // Get source document information
        if not GetSourceDocumentInformation(Rec, ItemNo, VariantCode, LocationCode, RequiredQuantity) then
            exit;

        // Validate item and tracking capabilities
        if not ValidateItemForTracking(ItemNo) then
            exit;

        // Calculate existing and remaining quantities
        ExistingQty := CalculateExistingTrackingQuantity(Rec);
        RemainingQty := RequiredQuantity - ExistingQty;

        if RemainingQty <= 0 then begin
            Message('All required quantity has already been assigned.');
            exit;
        end;

        // Process serial number assignment
        FoundCount := ProcessSerialNumberAssignment(Rec, ItemNo, VariantCode, LocationCode, RemainingQty);

        // Update page and display results
        CurrPage.Update(true);
        DisplayAssignmentResults(FoundCount, RemainingQty, ExistingQty, RequiredQuantity);
    end;

    local procedure GetSourceDocumentInformation(TrackingSpec: Record "Tracking Specification"; var ItemNo: Code[20]; var VariantCode: Code[10]; var LocationCode: Code[10]; var RequiredQuantity: Decimal) Success: Boolean
    begin
        // Only handle Sales Lines
        if TrackingSpec."Source Type" <> DATABASE::"Sales Line" then
            Error('This function only works for Sales Lines.');

        exit(GetSalesLineInformation(TrackingSpec, ItemNo, VariantCode, LocationCode, RequiredQuantity));
    end;

    // local procedure GetWarehouseShipmentInformation(TrackingSpec: Record "Tracking Specification"; var ItemNo: Code[20]; var VariantCode: Code[10]; var LocationCode: Code[10]; var RequiredQuantity: Decimal) Success: Boolean
    // var
    //     CurrentWhseShptLine: Record "Warehouse Shipment Line";
    // begin
    //     Clear(CurrentWhseShptLine);
    //     CurrentWhseShptLine.SetRange("No.", TrackingSpec."Source ID");
    //     CurrentWhseShptLine.SetRange("Line No.", TrackingSpec."Source Ref. No.");

    //     if not CurrentWhseShptLine.FindFirst() then begin
    //         Message('Warehouse Shipment line not found.');
    //         exit(false);
    //     end;

    //     ItemNo := CurrentWhseShptLine."Item No.";
    //     VariantCode := CurrentWhseShptLine."Variant Code";
    //     LocationCode := CurrentWhseShptLine."Location Code";
    //     RequiredQuantity := CurrentWhseShptLine."Qty. Outstanding (Base)";
    //     exit(true);
    // end;

    local procedure GetSalesLineInformation(TrackingSpec: Record "Tracking Specification"; var ItemNo: Code[20]; var VariantCode: Code[10]; var LocationCode: Code[10]; var RequiredQuantity: Decimal) Success: Boolean
    var
        CurrentSalesLine: Record "Sales Line";
    begin
        Clear(CurrentSalesLine);
        CurrentSalesLine.SetRange("Document Type", CurrentSalesLine."Document Type"::Order);
        CurrentSalesLine.SetRange("Document No.", TrackingSpec."Source ID");
        CurrentSalesLine.SetRange("Line No.", TrackingSpec."Source Ref. No.");

        if not CurrentSalesLine.FindFirst() then
            Error('Sales Order line not found.');

        ItemNo := CurrentSalesLine."No.";
        VariantCode := CurrentSalesLine."Variant Code";
        LocationCode := CurrentSalesLine."Location Code";
        RequiredQuantity := CurrentSalesLine."Qty. to Ship";
        exit(true);
    end;

    // Rest of your procedures remain exactly the same...
    local procedure ValidateItemForTracking(ItemNo: Code[20]) IsValid: Boolean
    var
        Item: Record Item;
    begin
        Clear(Item);
        if not Item.Get(ItemNo) then begin
            Message('Item %1 not found.', ItemNo);
            exit(false);
        end;

        if Item."Item Tracking Code" = '' then begin
            Message('Item %1 is not enabled for tracking.', Item."No.");
            exit(false);
        end;

        exit(true);
    end;

    local procedure CalculateExistingTrackingQuantity(TrackingSpec: Record "Tracking Specification") ExistingQty: Decimal
    var
        ExistingTrackingSpec: Record "Tracking Specification";
    begin
        ExistingQty := 0;
        ExistingTrackingSpec.Reset();
        ExistingTrackingSpec.SetRange("Source Type", TrackingSpec."Source Type");
        ExistingTrackingSpec.SetRange("Source ID", TrackingSpec."Source ID");
        ExistingTrackingSpec.SetRange("Source Ref. No.", TrackingSpec."Source Ref. No.");

        if ExistingTrackingSpec.FindSet() then
            repeat
                ExistingQty += Abs(ExistingTrackingSpec."Quantity (Base)");
            until ExistingTrackingSpec.Next() = 0;
    end;

    local procedure ProcessSerialNumberAssignment(var TrackingSpec: Record "Tracking Specification"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; RemainingQty: Decimal) FoundCount: Integer
    var
        CreateReservEntry: Codeunit "Create Reserv. Entry";
        TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
        TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        FoundCount := 0;

        SetupItemLedgerEntryFilters(ItemLedgEntry, ItemNo, VariantCode, LocationCode);
        SetItemLedgerEntrySorting(ItemLedgEntry, ItemNo);

        if ItemLedgEntry.FindSet() then
            repeat
                if FoundCount >= RemainingQty then
                    break;

                if IsSerialNumberAvailableForAssignment(TrackingSpec, ItemLedgEntry, ItemNo) then begin
                    CreateNewTrackingSpecificationRecord(TrackingSpec, ItemLedgEntry);
                    SetVariables(TrackingSpec, TempTrackingSpecificationModify, TempTrackingSpecificationDelete);
                    CreateReservEntry.CreateReservEntryFrom(TrackingSpec);
                    FoundCount += 1;
                end;
            until ItemLedgEntry.Next() = 0;
    end;

    local procedure SetupItemLedgerEntryFilters(var ItemLedgEntry: Record "Item Ledger Entry"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
    begin
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
    end;

    local procedure SetItemLedgerEntrySorting(var ItemLedgEntry: Record "Item Ledger Entry"; ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        if Item.Get(ItemNo) then begin
            if Item."Costing Method" = Item."Costing Method"::FIFO then
                // For FIFO costing method, sort by Entry No. to get earliest entries first
                ItemLedgEntry.SetCurrentKey("Entry No.")
            else
                // For non-FIFO costing methods, sort by Posting Date to get oldest items first (Age-based)
                ItemLedgEntry.SetCurrentKey("Posting Date");
        end;
    end;

    local procedure IsSerialNumberAvailableForAssignment(TrackingSpec: Record "Tracking Specification"; ItemLedgEntry: Record "Item Ledger Entry"; ItemNo: Code[20]) IsAvailable: Boolean
    begin
        IsAvailable := true;

        // Check if serial is reserved for another document
        if IsSerialNumberReservedElsewhere(TrackingSpec, ItemLedgEntry, ItemNo) then
            IsAvailable := false;

        // Check if serial already exists in current tracking lines
        if IsAvailable and DoesSerialNumberExistInCurrentTracking(TrackingSpec, ItemLedgEntry."Serial No.") then
            IsAvailable := false;
    end;

    local procedure IsSerialNumberReservedElsewhere(TrackingSpec: Record "Tracking Specification"; ItemLedgEntry: Record "Item Ledger Entry"; ItemNo: Code[20]) IsReserved: Boolean
    var
        ReservEntry: Record "Reservation Entry";
    begin
        Clear(ReservEntry);
        ReservEntry.SetRange("Item No.", ItemNo);
        ReservEntry.SetRange("Serial No.", ItemLedgEntry."Serial No.");
        ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);

        // For Warehouse Shipment, we don't need to exclude current source
        // as it works differently than Sales Orders
        exit(not ReservEntry.IsEmpty());
    end;

    local procedure DoesSerialNumberExistInCurrentTracking(TrackingSpec: Record "Tracking Specification"; SerialNo: Code[50]) Exists: Boolean
    var
        ExistingTrackingSpec: Record "Tracking Specification";
    begin
        ExistingTrackingSpec.Reset();
        ExistingTrackingSpec.SetRange("Source Type", TrackingSpec."Source Type");
        ExistingTrackingSpec.SetRange("Source ID", TrackingSpec."Source ID");
        ExistingTrackingSpec.SetRange("Source Ref. No.", TrackingSpec."Source Ref. No.");
        ExistingTrackingSpec.SetRange("Serial No.", SerialNo);
        exit(not ExistingTrackingSpec.IsEmpty());
    end;

    local procedure CreateNewTrackingSpecificationRecord(var TrackingSpec: Record "Tracking Specification"; ItemLedgEntry: Record "Item Ledger Entry")
    begin
        Clear(TrackingSpec);
        xRec."Serial No." := '';
        TrackingSpec.TransferFields(xRec);

        TrackingSpec.Validate("Serial No.", ItemLedgEntry."Serial No.");
        TrackingSpec.Validate("Lot No.", ItemLedgEntry."Lot No.");
        TrackingSpec.Validate("Quantity (Base)", 1);

        InsertRecord(TrackingSpec);
    end;

    local procedure DisplayAssignmentResults(FoundCount: Integer; RemainingQty: Decimal; ExistingQty: Decimal; RequiredQuantity: Decimal)
    begin
        if FoundCount = 0 then
            Message('No available serials found.')
        else
            if FoundCount < RemainingQty then
                Message('Only %1 serials out of %2 needed were found and added.\nTotal assigned: %3 of %4',
                    FoundCount, RemainingQty, ExistingQty + FoundCount, RequiredQuantity)
            else
                Message('%1 serials successfully added.\nTotal assigned: %2 of %3',
                    FoundCount, ExistingQty + FoundCount, RequiredQuantity);
    end;


    // trigger OnAfterGetCurrRecord()
    // begin
    //     IsWarehouseShipmentSource()
    // end;

}