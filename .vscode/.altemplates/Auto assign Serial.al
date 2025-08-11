// pageextension 50120 ItemTrackingLinesExt extends "Item Tracking Lines"
// {
//     actions
//     {
//         addlast(processing)
//         {
//             action(AutoAssignSerial)
//             {
//                 Caption = 'Auto Assign Serial';
//                 Image = Allocate;
//                 ToolTip = 'Automatically assign available serial numbers from inventory';

//                 trigger OnAction()
//                 begin
//                     AssignSerialsFromLedgerSimple(Rec);
//                 end;
//             }
//         }
//     }

//     procedure AssignSerialsFromLedgerSimple(var Rec: Record "Tracking Specification")
//     var
//         CreateReservEntry: Codeunit "Create Reserv. Entry";
//         TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
//         TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
//         ExistingQty: Decimal;
//         RemainingQty: Decimal;
//         NeededQty: Decimal;
//         FoundCount: Integer;
//         ItemNo: Code[20];
//         VariantCode: Code[10];
//         LocationCode: Code[10];
//     begin
//         // دریافت اطلاعات منبع (سفارش فروش یا حمل انبار)
//         if not GetSourceDocumentInformation(Rec, ItemNo, VariantCode, LocationCode, NeededQty) then
//             exit;

//         // بررسی و اعتبارسنجی آیتم و قابلیت ردیابی
//         if not ValidateItemForTracking(ItemNo) then
//             exit;

//         // محاسبه مقادیر موجود و باقی‌مانده
//         ExistingQty := CalculateExistingTrackingQuantity(Rec);
//         RemainingQty := NeededQty - ExistingQty;

//         if RemainingQty <= 0 then begin
//             Message('All required quantity has already been assigned.');
//             exit;
//         end;

//         // تخصیص شماره‌های سریال از موجودی
//         FoundCount := ProcessSerialAssignment(Rec, ItemNo, VariantCode, LocationCode, RemainingQty);

//         // بروزرسانی صفحه و نمایش نتیجه
//         CurrPage.Update(true);
//         DisplayAssignmentResults(FoundCount, RemainingQty, ExistingQty, NeededQty);
//     end;

//     local procedure GetSourceDocumentInformation(TrackingSpec: Record "Tracking Specification"; var ItemNo: Code[20]; var VariantCode: Code[10]; var LocationCode: Code[10]; var NeededQty: Decimal) Success: Boolean
//     var
//         CurrentSalesLine: Record "Sales Line";
//         CurrentWhseShptLine: Record "Warehouse Shipment Line";
//     begin
//         Success := false;

//         case TrackingSpec."Source Type" of
//             DATABASE::"Sales Line":
//                 Success := GetSalesLineInformation(TrackingSpec, CurrentSalesLine, ItemNo, VariantCode, LocationCode, NeededQty);
//             DATABASE::"Warehouse Shipment Line":
//                 Success := GetWarehouseShipmentInformation(TrackingSpec, CurrentWhseShptLine, ItemNo, VariantCode, LocationCode, NeededQty);
//             else begin
//                 Message('This function only works for Sales Orders and Warehouse Shipments.');
//                 Success := false;
//             end;
//         end;
//     end;

//     local procedure GetSalesLineInformation(TrackingSpec: Record "Tracking Specification"; var SalesLine: Record "Sales Line"; var ItemNo: Code[20]; var VariantCode: Code[10]; var LocationCode: Code[10]; var NeededQty: Decimal) Success: Boolean
//     begin
//         Clear(SalesLine);
//         SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
//         SalesLine.SetRange("Document No.", TrackingSpec."Source ID");
//         SalesLine.SetRange("Line No.", TrackingSpec."Source Ref. No.");

//         if not SalesLine.FindFirst() then begin
//             Message('Sales Order line not found.');
//             exit(false);
//         end;

//         ItemNo := SalesLine."No.";
//         VariantCode := SalesLine."Variant Code";
//         LocationCode := SalesLine."Location Code";
//         NeededQty := SalesLine."Qty. to Ship";
//         exit(true);
//     end;

//     local procedure GetWarehouseShipmentInformation(TrackingSpec: Record "Tracking Specification"; var WhseShptLine: Record "Warehouse Shipment Line"; var ItemNo: Code[20]; var VariantCode: Code[10]; var LocationCode: Code[10]; var NeededQty: Decimal) Success: Boolean
//     begin
//         Clear(WhseShptLine);
//         WhseShptLine.SetRange("No.", TrackingSpec."Source ID");
//         WhseShptLine.SetRange("Line No.", TrackingSpec."Source Ref. No.");

//         if not WhseShptLine.FindFirst() then begin
//             Message('Warehouse Shipment line not found.');
//             exit(false);
//         end;

//         ItemNo := WhseShptLine."Item No.";
//         VariantCode := WhseShptLine."Variant Code";
//         LocationCode := WhseShptLine."Location Code";
//         NeededQty := WhseShptLine."Qty. Outstanding (Base)";
//         exit(true);
//     end;

//     local procedure ValidateItemForTracking(ItemNo: Code[20]) IsValid: Boolean
//     var
//         Item: Record Item;
//     begin
//         if not Item.Get(ItemNo) then begin
//             Message('Item %1 not found.', ItemNo);
//             exit(false);
//         end;

//         if Item."Item Tracking Code" = '' then begin
//             Message('Item %1 is not enabled for tracking.', Item."No.");
//             exit(false);
//         end;

//         exit(true);
//     end;

// local procedure CalculateExistingTrackingQuantity(TrackingSpec: Record "Tracking Specification") ExistingQty: Decimal
// var
//     ExistingTrackingSpec: Record "Tracking Specification";
// begin
//     ExistingQty := 0;
//     ExistingTrackingSpec.Reset();
//     ExistingTrackingSpec.SetRange("Source Type", TrackingSpec."Source Type");
//     ExistingTrackingSpec.SetRange("Source ID", TrackingSpec."Source ID");
//     ExistingTrackingSpec.SetRange("Source Ref. No.", TrackingSpec."Source Ref. No.");

//     if ExistingTrackingSpec.FindSet() then
//         repeat
//             ExistingQty += Abs(ExistingTrackingSpec."Quantity (Base)");
//         until ExistingTrackingSpec.Next() = 0;
// end;

//     local procedure ProcessSerialAssignment(var TrackingSpec: Record "Tracking Specification"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10]; RemainingQty: Decimal) FoundCount: Integer
//     var
//         CreateReservEntry: Codeunit "Create Reserv. Entry";
//         TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
//         TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
//         ItemLedgEntry: Record "Item Ledger Entry";
//         Item: Record Item;
//     begin
//         FoundCount := 0;

//         // تنظیم فیلترهای آیتم لجر انتری
//         SetupItemLedgerFilters(ItemLedgEntry, ItemNo, VariantCode, LocationCode);

//         // تنظیم ترتیب بر اساس روش کاستینگ
//         SetItemLedgerSorting(ItemLedgEntry, ItemNo);

//         if ItemLedgEntry.FindSet() then
//             repeat
//                 if FoundCount >= RemainingQty then
//                     break;

//                 if IsSerialNumberAvailable(TrackingSpec, ItemLedgEntry, ItemNo) then begin
//                     CreateNewTrackingSpecification(TrackingSpec, ItemLedgEntry);
//                     SetVariables(TrackingSpec, TempTrackingSpecificationModify, TempTrackingSpecificationDelete);
//                     CreateReservEntry.CreateReservEntryFrom(TrackingSpec);
//                     FoundCount += 1;
//                 end;
//             until ItemLedgEntry.Next() = 0;
//     end;

//     local procedure SetupItemLedgerFilters(var ItemLedgEntry: Record "Item Ledger Entry"; ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
//     begin
//         Clear(ItemLedgEntry);
//         ItemLedgEntry.SetRange("Item No.", ItemNo);
//         ItemLedgEntry.SetRange("Entry Type", ItemLedgEntry."Entry Type"::Purchase);
//         ItemLedgEntry.SetFilter("Remaining Quantity", '>0');
//         ItemLedgEntry.SetFilter("Serial No.", '<>%1', '');
//         ItemLedgEntry.SetRange("Document Type", ItemLedgEntry."Document Type"::"Purchase Receipt");

//         if VariantCode <> '' then
//             ItemLedgEntry.SetRange("Variant Code", VariantCode);
//         if LocationCode <> '' then
//             ItemLedgEntry.SetRange("Location Code", LocationCode);
//     end;

//     local procedure SetItemLedgerSorting(var ItemLedgEntry: Record "Item Ledger Entry"; ItemNo: Code[20])
//     var
//         Item: Record Item;
//     begin
//         if Item.Get(ItemNo) then begin
//             if Item."Costing Method" = Item."Costing Method"::FIFO then
//                 ItemLedgEntry.SetCurrentKey("Entry No.")
//             else
//                 ItemLedgEntry.SetCurrentKey("Expiration Date", "Warranty Date");
//         end;
//     end;

//     local procedure IsSerialNumberAvailable(TrackingSpec: Record "Tracking Specification"; ItemLedgEntry: Record "Item Ledger Entry"; ItemNo: Code[20]) IsAvailable: Boolean
//     var
//         ReservEntry: Record "Reservation Entry";
//         TempTrackingSpec: Record "Tracking Specification";
//     begin
//         IsAvailable := true;

//         // بررسی رزرو بودن شماره سریال برای سند دیگر
//         if IsSerialReservedElsewhere(TrackingSpec, ItemLedgEntry, ItemNo) then
//             IsAvailable := false;

//         // بررسی وجود شماره سریال در خطوط ردیابی فعلی
//         if IsAvailable and DoesSerialExistInCurrentTracking(TrackingSpec, ItemLedgEntry."Serial No.") then
//             IsAvailable := false;
//     end;

//     local procedure IsSerialReservedElsewhere(TrackingSpec: Record "Tracking Specification"; ItemLedgEntry: Record "Item Ledger Entry"; ItemNo: Code[20]) IsReserved: Boolean
//     var
//         ReservEntry: Record "Reservation Entry";
//     begin
//         Clear(ReservEntry);
//         ReservEntry.SetRange("Item No.", ItemNo);
//         ReservEntry.SetRange("Serial No.", ItemLedgEntry."Serial No.");
//         ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);

//         if TrackingSpec."Source Type" = DATABASE::"Sales Line" then
//             ReservEntry.SetFilter("Source ID", '<>%1', TrackingSpec."Source ID");

//         exit(not ReservEntry.IsEmpty());
//     end;

//     local procedure DoesSerialExistInCurrentTracking(TrackingSpec: Record "Tracking Specification"; SerialNo: Code[50]) Exists: Boolean
//     var
//         TempTrackingSpec: Record "Tracking Specification";
//     begin
//         TempTrackingSpec.Reset();
//         TempTrackingSpec.SetRange("Source Type", TrackingSpec."Source Type");
//         TempTrackingSpec.SetRange("Source ID", TrackingSpec."Source ID");
//         TempTrackingSpec.SetRange("Source Ref. No.", TrackingSpec."Source Ref. No.");
//         TempTrackingSpec.SetRange("Serial No.", SerialNo);
//         exit(not TempTrackingSpec.IsEmpty());
//     end;

//     local procedure CreateNewTrackingSpecification(var TrackingSpec: Record "Tracking Specification"; ItemLedgEntry: Record "Item Ledger Entry")
//     begin
//         Clear(TrackingSpec);
//         xRec."Serial No." := '';
//         TrackingSpec.TransferFields(xRec);

//         TrackingSpec.Validate("Serial No.", ItemLedgEntry."Serial No.");
//         TrackingSpec.Validate("Lot No.", ItemLedgEntry."Lot No.");
//         TrackingSpec.Validate("Quantity (Base)", 1);
//         TrackingSpec."Expiration Date" := ItemLedgEntry."Expiration Date";
//         TrackingSpec."Warranty Date" := ItemLedgEntry."Warranty Date";

//         InsertRecord(TrackingSpec);
//     end;

//     local procedure DisplayAssignmentResults(FoundCount: Integer; RemainingQty: Decimal; ExistingQty: Decimal; NeededQty: Decimal)
//     begin
//         if FoundCount = 0 then
//             Message('No available serials found.')
//         else
//             if FoundCount < RemainingQty then
//                 Message('Only %1 serials out of %2 needed were found and added.\nTotal assigned: %3 of %4',
//                     FoundCount, RemainingQty, ExistingQty + FoundCount, NeededQty)
//             else
//                 Message('%1 serials successfully added.\nTotal assigned: %2 of %3',
//                     FoundCount, ExistingQty + FoundCount, NeededQty);
//     end;
// }