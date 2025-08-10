pageextension 50120 ItemTrackingLinesExt extends "Item Tracking Lines"
{
    actions
    {
        addlast(processing)
        {
            action(Test)
            {
                Caption = 'Test Action';
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
        TrackingSpec: Record "Tracking Specification";
        ItemLedgEntry: Record "Item Ledger Entry";
        ReservEntry: Record "Reservation Entry";
        Item: Record Item;
        ExistingQty: Decimal;
        RemainingQty: Decimal;
        nNeeded: Decimal;
        foundCount: Integer;
        hasFound: Boolean;
        ItemNo: Code[20];
        VariantCode: Code[10];
        LocationCode: Code[10];
    begin
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
        TrackingSpec.Reset();
        TrackingSpec.SetRange("Source Type", Rec."Source Type");
        TrackingSpec.SetRange("Source ID", Rec."Source ID");
        TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
        if TrackingSpec.FindSet() then
            repeat
                ExistingQty += Abs(TrackingSpec."Quantity (Base)");
            until TrackingSpec.Next() = 0;

        // 4. Calculate remaining quantity
        RemainingQty := nNeeded - ExistingQty;

        if RemainingQty <= 0 then begin
            Message('All required quantity has already been assigned.');
            exit;
        end;

        foundCount := 0;

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
                if foundCount >= RemainingQty then
                    break;

                hasFound := true;

                // Check that serial is not reserved for another document
                Clear(ReservEntry);
                ReservEntry.SetRange("Item No.", ItemNo);
                ReservEntry.SetRange("Serial No.", ItemLedgEntry."Serial No.");
                ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);

                // اگر منبع Sales Line است، سفارش فعلی را به جز منطق اضافه کنید
                if Rec."Source Type" = DATABASE::"Sales Line" then
                    ReservEntry.SetFilter("Source ID", '<>%1', Rec."Source ID");

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
                    // ایجاد رکورد جدید برای هر سریال
                    Clear(Rec);
                    xRec."Serial No." := '';
                    Rec.TransferFields(xRec); // کپی کردن مقادیر پایه از رکورد فعلی

                    // تنظیم مقادیر جدید
                    Rec.Validate("Serial No.", ItemLedgEntry."Serial No.");
                    Rec.Validate("Lot No.", ItemLedgEntry."Lot No.");
                    Rec.Validate("Quantity (Base)", 1);
                    Rec."Expiration Date" := ItemLedgEntry."Expiration Date";
                    Rec."Warranty Date" := ItemLedgEntry."Warranty Date";

                    // درج رکورد جدید
                    InsertRecord(Rec);
                    SetVariables(Rec, TempTrackingSpecificationModify, TempTrackingSpecificationDelete);
                    CreateReservEntry.CreateReservEntryFrom(Rec);

                    foundCount += 1;
                end;
            until ItemLedgEntry.Next() = 0;

        // بروزرسانی صفحه
        CurrPage.Update(true);

        // 6. Show result
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
