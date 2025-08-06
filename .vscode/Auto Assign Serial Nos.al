pageextension 50120 ItemTrackingLinesExt extends "Item Tracking Lines"
{

    layout
    {
        modify("Serial No.")
        {


            ApplicationArea = All;
            Caption = 'Entry No. (Serial No.)';

            // trigger OnBeforeValidate()
            // var
            //     LotNo: Code[50];
            //     IsHandled1: Boolean;
            //     jhasjh: Codeunit "Item Tracking Line Handler CZA";
            // begin
            //     SerialNoOnAfterValidate();
            //     if Rec."Serial No." <> '' then begin
            //         IsHandled1 := false;
            //         // The following line was removed because the procedure is inaccessible:
            //         //OnValidateSerialNoOnBeforeFindLotNo(Rec, IsHandled1);
            //         // Proceed as if IsHandled1 is always false

            //         if not IsHandled1 then begin
            //             ItemTrackingDataCollection.FindLotNoBySNSilent(LotNo, Rec);
            //             Rec.Validate("Lot No.", LotNo);
            //         end;
            //         CurrPage.Update();
            //     end;
            // end;

            trigger OnAfterValidate()
            var
                LotNo: Code[50];
            begin
                // SerialNoOnAfterValidate();
                // if Rec."Serial No." <> '' then begin
                //     ItemTrackingDataCollection.FindLotNoBySNSilent(LotNo, Rec);
                //     Rec.Validate("Lot No.", LotNo);

                //end;
                // CurrPage.Update(true);
            end;


        }
    }
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

                var
                    TrackingSpecification: Record "Tracking Specification" temporary;
                    MySerials: array[2] of Code[50];
                    MyLots: array[2] of Integer;
                    TrackingSpec: Record "Tracking Specification";
                    i: Integer;
                    LineFilled: Boolean;
                begin
                    // داده تستی
                    MySerials[1] := 'SERIAL001';
                    MySerials[2] := 'SERIAL002';
                    MyLots[1] := 1;
                    MyLots[2] := 2;

                    // فرض: شرط اینکه فقط دو خط را پر کنیم
                    for i := 1 to 2 do begin
                        // LineFilled := false;
                        // Rec.Reset();
                        // شرط سرچ روی خطوط مرتبط با سند فعلی (در صورت نیاز فیلترهای مرتبط با Source Type/ID/Ref. No. اضافه کن)
                        // TrackingSpec.SetRange("Source ID", Rec."Source ID");
                        // TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
                        //with Rec do begin
                        repeat
                            if Rec."Serial No." = '' then begin
                                Rec.Validate("Serial No.", MySerials[i]);
                                Rec."Quantity (Base)" := MyLots[i];
                                // Rec."Entry No." := i;
                                // InsertSpecification1();


                                // TrackingSpecification := Rec;
                                // TrackingSpecification."Buffer Status" := 0;
                                // TrackingSpecification.InitQtyToShip();
                                // TrackingSpecification.Correction := false;
                                // TrackingSpecification."Quantity actual Handled (Base)" := 0;
                                // OnBeforeUpdateTrackingSpecification(Rec, TrackingSpecification);
                                if Rec."Buffer Status" = Rec."Buffer Status"::MODIFY then
                                    TrackingSpecification.Modify()
                                else
                                    TrackingSpecification.Insert();


                                // Rec.InitTrackingSpecification();
                                // Rec.SetTrackingBlank();
                                // Rec.SetTrackingFilterFromItemLedgEntry();
                                // Rec.SetTrackingFilterFromSpec(Rec);
                                // Rec.TrackingExists();
                                // Rec.AddLoadFields();
                                // Clear(Rec);
                                // CurrPage.Run();
                                CurrPage.SaveRecord();
                                CurrPage.SetRecord(Rec);
                                CurrPage.SetTableView(Rec);
                                CurrPage.Update(true);


                                Rec.Next();



                                //LineFilled := true;
                            end;
                        //CurrPage.update(true);
                        until (rec.Next() = 0);
                    end;
                    Message('دو خط با مقادیر تستی پر شد.');
                end;
                //AssignSerialsFromLedgerSimple();
                // FillTrackingSpecsManually();
                //end;
            }
        }
    }


    procedure InsertSpecification1()
    var
        TrackingSpecification: Record "Tracking Specification";
    begin
        // Rec.Reset();
        if Rec.FindSet() then begin
            repeat
                TrackingSpecification := Rec;
                TrackingSpecification."Buffer Status" := 0;
                TrackingSpecification.InitQtyToShip();
                TrackingSpecification.Correction := false;
                TrackingSpecification."Quantity actual Handled (Base)" := 0;
                OnBeforeUpdateTrackingSpecification(Rec, TrackingSpecification);
                if Rec."Buffer Status" = TrackingSpecification."Buffer Status"::MODIFY then
                    TrackingSpecification.Modify()
                else
                    TrackingSpecification.Insert();
            until (Rec.Next() = 0);
            Rec.DeleteAll();
        end;
    end;

    // procedure ApplySerialNoLogic(var Rec: Record "Tracking Specification")
    // var
    //     LotNo: Code[50];
    //     IsHandled: Boolean;

    // begin
    //     if Rec."Serial No." <> '' then begin
    //         IsHandled := false;
    //         OnValidateSerialNoOnBeforeFindLotNo1(Rec, IsHandled); // ایونت پابلیش می‌شود
    //         if not IsHandled then begin
    //             ItemTrackingDataCollection.FindLotNoBySNSilent(LotNo, Rec);
    //             Rec.Validate("Lot No.", LotNo);
    //         end;
    //         // اگر لازم بود: CurrPage.Update(); را اینجا صدا بزن (در Page Extension)
    //     end;
    // end;



    local procedure FillTrackingSpecsManually()
    var
        MySerials: array[2] of Code[50];
        MyLots: array[2] of Integer;
        TrackingSpec: Record "Tracking Specification";
        i: Integer;
        LineFilled: Boolean;
    begin
        // داده تستی
        MySerials[1] := 'SERIAL001';
        MySerials[2] := 'SERIAL002';
        MyLots[1] := 1;
        MyLots[2] := 2;

        // فرض: شرط اینکه فقط دو خط را پر کنیم
        for i := 1 to 2 do begin
            LineFilled := false;
            Rec.Reset();
            // شرط سرچ روی خطوط مرتبط با سند فعلی (در صورت نیاز فیلترهای مرتبط با Source Type/ID/Ref. No. اضافه کن)
            // TrackingSpec.SetRange("Source ID", Rec."Source ID");
            // TrackingSpec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
            if Rec.FindSet() then
                repeat
                    if Rec."Serial No." = '' then begin
                        Rec.Validate("Serial No.", MySerials[i]);
                        Rec."Quantity (Base)" := MyLots[i];
                        Rec.Modify();
                        LineFilled := true;
                        break;
                    end;
                until (TrackingSpec.Next() = 0) or LineFilled;
        end;
        Message('دو خط با مقادیر تستی پر شد.');
    end;

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
        nNeeded := CurrentSalesLine."Qty. to Ship";
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

                    // Rec.Insert();
                    foundCount += 1;
                    NextEntryNo += 1;
                end;
                CurrPage.Update(true);
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



    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateTrackingSpecification(var TrackingSpecRec: Record "Tracking Specification"; var TrackingSpec: Record "Tracking Specification")
    begin
    end;


}