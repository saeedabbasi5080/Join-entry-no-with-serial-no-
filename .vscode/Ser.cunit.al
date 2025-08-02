// codeunit 50403 "Auto Serial Management"
// {
//     procedure AutoSelectSerialNumbers(
//         var TrackingSpecification: Record "Tracking Specification";
//         var TempSelectedSerials: Record "Tracking Specification" temporary)
//     var
//         Item: Record Item;
//         ItemLedgerEntry: Record "Item Ledger Entry";
//         TempItemLedgerEntry: Record "Item Ledger Entry" temporary;
//         QtyToSelect: Decimal;
//         SelectedQty: Decimal;
//         CurrentAssignedQty: Decimal;
//         TotalNeededQty: Decimal;
//         re: record "Entry Summary";
//         LocalEntryNo: Integer;
//     begin
//         LocalEntryNo := 1;
//         // Check if the item has an Item Tracking Code
//         if not Item.Get(TrackingSpecification."Item No.") then begin
//             Message('Item %1 not found.', TrackingSpecification."Item No.");
//             exit;
//         end;

//         if Item."Item Tracking Code" = '' then begin
//             Message('Item %1 is not enabled for tracking.', Item."No.");
//             exit;
//         end;

//         // Calculate the required quantity
//         QtyToSelect := GetTotalQuantityNeeded(TrackingSpecification);
//         CurrentAssignedQty := GetAlreadyAssignedQuantity(TrackingSpecification);

//         if QtyToSelect <= CurrentAssignedQty then begin
//             Message('The required quantity has already been assigned.');
//             exit;
//         end;

//         QtyToSelect := QtyToSelect - CurrentAssignedQty;

//         // Set Item Ledger Entry filters
//         SetItemLedgerFilters(ItemLedgerEntry, TrackingSpecification);

//         // Copy existing records to the temporary table for better sorting
//         if ItemLedgerEntry.FindSet() then
//             repeat
//                 if not IsSerialReserved(ItemLedgerEntry) then begin
//                     TempItemLedgerEntry.TransferFields(ItemLedgerEntry);
//                     TempItemLedgerEntry.Insert();
//                 end;
//             until ItemLedgerEntry.Next() = 0;

//         // Sort based on Costing Method
//         if Item."Costing Method" = Item."Costing Method"::FIFO then begin
//             // FIFO: First In, First Out
//             TempItemLedgerEntry.SetCurrentKey("Item No.", "Posting Date");
//             TempItemLedgerEntry.SetAscending("Posting Date", true);
//         end else begin
//             // LIFO or other methods: Based on Expiration or Warranty Date
//             TempItemLedgerEntry.SetCurrentKey("Item No.", "Expiration Date", "Warranty Date");
//             TempItemLedgerEntry.SetAscending("Expiration Date", true);
//             TempItemLedgerEntry.SetAscending("Warranty Date", true);
//         end;

//         if TempItemLedgerEntry.FindSet() then
//             repeat
//                 if CreateTrackingLineToTemp(TrackingSpecification, TempItemLedgerEntry, TempSelectedSerials, LocalEntryNo) then begin
//                     SelectedQty += 1;
//                     LocalEntryNo += 1;
//                 end;

//                 if SelectedQty >= QtyToSelect then
//                     break;
//             until TempItemLedgerEntry.Next() = 0;

//         if SelectedQty = 0 then
//             Message('No available serial numbers found.')
//         else
//             if SelectedQty < QtyToSelect then
//                 Message('Only %1 serial numbers out of %2 required were selected.', SelectedQty, QtyToSelect)
//             else
//                 Message('%1 serial numbers were successfully selected.', SelectedQty);
//     end;

//     local procedure SetItemLedgerFilters(var ItemLedgerEntry: Record "Item Ledger Entry"; TrackingSpecification: Record "Tracking Specification")
//     begin
//         ItemLedgerEntry.Reset();
//         ItemLedgerEntry.SetRange("Item No.", TrackingSpecification."Item No.");
//         ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Purchase);
//         ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Purchase Receipt");
//         ItemLedgerEntry.SetFilter("Remaining Quantity", '>0'); // Only available quantities
//         ItemLedgerEntry.SetFilter("Serial No.", '<>%1', ''); // Only items with serial numbers

//         // If Variant exists
//         if TrackingSpecification."Variant Code" <> '' then
//             ItemLedgerEntry.SetRange("Variant Code", TrackingSpecification."Variant Code");

//         // If Location Code is specified
//         if TrackingSpecification."Location Code" <> '' then
//             ItemLedgerEntry.SetRange("Location Code", TrackingSpecification."Location Code");
//     end;

//     local procedure IsSerialReserved(ItemLedgerEntry: Record "Item Ledger Entry"): Boolean
//     var
//         ReservationEntry: Record "Reservation Entry";
//     begin
//         ReservationEntry.Reset();
//         ReservationEntry.SetRange("Item No.", ItemLedgerEntry."Item No.");
//         ReservationEntry.SetRange("Serial No.", ItemLedgerEntry."Serial No.");
//         ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Reservation);
//         ReservationEntry.SetFilter("Quantity (Base)", '<>0');

//         if ItemLedgerEntry."Variant Code" <> '' then
//             ReservationEntry.SetRange("Variant Code", ItemLedgerEntry."Variant Code");

//         if ItemLedgerEntry."Location Code" <> '' then
//             ReservationEntry.SetRange("Location Code", ItemLedgerEntry."Location Code");

//         exit(not ReservationEntry.IsEmpty);
//     end;

//     local procedure CreateTrackingLineToTemp(
//         var TrackingSpecification: Record "Tracking Specification";
//         ItemLedgerEntry: Record "Item Ledger Entry";
//         var TempSelectedSerials: Record "Tracking Specification" temporary;
//         EntryNo: Integer): Boolean
//     var
//         NewTrackingSpec: Record "Tracking Specification";
//         CurrentAssignedQty: Decimal;
//         TotalNeededQty: Decimal;
//     begin
//         // Check if the required quantity has already been assigned
//         CurrentAssignedQty := GetAlreadyAssignedQuantity(TrackingSpecification);
//         TotalNeededQty := GetTotalQuantityNeeded(TrackingSpecification);

//         if CurrentAssignedQty >= TotalNeededQty then begin
//             // The required quantity has already been assigned, do not create a new record
//             exit(false);
//         end;

//         // Check if this serial number has already been assigned for this Source
//         NewTrackingSpec.Reset();
//         NewTrackingSpec.SetRange("Source Type", TrackingSpecification."Source Type");
//         NewTrackingSpec.SetRange("Source ID", TrackingSpecification."Source ID");
//         NewTrackingSpec.SetRange("Source Ref. No.", TrackingSpecification."Source Ref. No.");
//         NewTrackingSpec.SetRange("Serial No.", ItemLedgerEntry."Serial No.");

//         if NewTrackingSpec.FindFirst() then begin
//             // If this serial number has already been assigned, do nothing
//             exit(false);
//         end;

//         // Create a new record in TempSelectedSerials
//         TempSelectedSerials.Init();
//         TempSelectedSerials."Entry No." := EntryNo;
//         TempSelectedSerials."Source Type" := TrackingSpecification."Source Type";
//         TempSelectedSerials."Source Subtype" := TrackingSpecification."Source Subtype";
//         TempSelectedSerials."Source ID" := TrackingSpecification."Source ID";
//         TempSelectedSerials."Source Batch Name" := TrackingSpecification."Source Batch Name";
//         TempSelectedSerials."Source Prod. Order Line" := TrackingSpecification."Source Prod. Order Line";
//         TempSelectedSerials."Source Ref. No." := TrackingSpecification."Source Ref. No.";
//         TempSelectedSerials."Item No." := ItemLedgerEntry."Item No.";
//         TempSelectedSerials."Variant Code" := ItemLedgerEntry."Variant Code";
//         TempSelectedSerials."Location Code" := ItemLedgerEntry."Location Code";
//         TempSelectedSerials."Serial No." := ItemLedgerEntry."Serial No.";
//         TempSelectedSerials."Lot No." := ItemLedgerEntry."Lot No.";
//         TempSelectedSerials."Expiration Date" := ItemLedgerEntry."Expiration Date";
//         TempSelectedSerials."Warranty Date" := ItemLedgerEntry."Warranty Date";
//         TempSelectedSerials."Quantity (Base)" := -1; // Negative for exit
//         TempSelectedSerials."Qty. to Handle (Base)" := -1;
//         TempSelectedSerials."Qty. to Invoice (Base)" := -1;
//         TempSelectedSerials."Creation Date" := Today;

//         TempSelectedSerials.Insert(true);
//         exit(true); // Indicate success
//     end;

//     local procedure GetNextReservationEntryNo(): Integer
//     var
//         ReservationEntry: Record "Reservation Entry";
//     begin
//         ReservationEntry.Reset();
//         ReservationEntry.SetCurrentKey("Entry No.");
//         if ReservationEntry.FindLast() then
//             exit(ReservationEntry."Entry No." + 1)
//         else
//             exit(1);
//     end;

//     local procedure GetNextEntryNo(): Integer
//     var
//         TrackingSpecification: Record "Tracking Specification";
//     begin
//         TrackingSpecification.Reset();
//         TrackingSpecification.SetCurrentKey("Entry No.");
//         if TrackingSpecification.FindLast() then
//             exit(TrackingSpecification."Entry No." + 1)
//         else
//             exit(1);
//     end;

//     procedure GetTotalQuantityNeeded(TrackingSpecification: Record "Tracking Specification"): Decimal
//     var
//         SalesLine: Record "Sales Line";
//         WhseShptLine: Record "Warehouse Shipment Line";
//     begin
//         case TrackingSpecification."Source Type" of
//             37: // Sales Line
//                 begin
//                     if SalesLine.Get(TrackingSpecification."Source Subtype", TrackingSpecification."Source ID", TrackingSpecification."Source Ref. No.") then
//                         exit(Abs(SalesLine."Quantity (Base)"));
//                 end;
//             7312: // Warehouse Shipment Line
//                 begin
//                     if WhseShptLine.Get(TrackingSpecification."Source ID", TrackingSpecification."Source Ref. No.") then
//                         exit(Abs(WhseShptLine."Qty. to Ship (Base)"));
//                 end;
//         end;
//         exit(0);
//     end;

//     procedure GetAlreadyAssignedQuantity(TrackingSpecification: Record "Tracking Specification"): Decimal
//     var
//         TrackingSpec: Record "Tracking Specification";
//         AssignedQty: Decimal;
//     begin
//         AssignedQty := 0;

//         // Count Tracking Specification records
//         TrackingSpec.Reset();
//         TrackingSpec.SetRange("Source Type", TrackingSpecification."Source Type");
//         TrackingSpec.SetRange("Source ID", TrackingSpecification."Source ID");
//         TrackingSpec.SetRange("Source Ref. No.", TrackingSpecification."Source Ref. No.");

//         if TrackingSpec.FindSet() then
//             repeat
//                 AssignedQty += Abs(TrackingSpec."Quantity (Base)");
//             until TrackingSpec.Next() = 0;

//         exit(AssignedQty);
//     end;

//     // Event Subscribers for automatic integration
//     [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnRegisterChangeOnChangeTypeInsertOnBeforeInsertReservEntry', '', false, false)]
//     local procedure OnRegisterChangeOnChangeTypeInsertOnBeforeInsertReservEntry(var TrackingSpecification: Record "Tracking Specification"; var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: Record "Tracking Specification"; FormRunMode: Option)
//     var
//         ReservationEntry: Record "Reservation Entry";
//     begin
//         // If the serial number has changed, delete the old record
//         if (NewTrackingSpecification."Serial No." <> OldTrackingSpecification."Serial No.") and (OldTrackingSpecification."Serial No." <> '') then begin
//             ReservationEntry.Reset();
//             ReservationEntry.SetRange("Source Type", OldTrackingSpecification."Source Type");
//             ReservationEntry.SetRange("Source ID", OldTrackingSpecification."Source ID");
//             ReservationEntry.SetRange("Source Ref. No.", OldTrackingSpecification."Source Ref. No.");
//             ReservationEntry.SetRange("Serial No.", OldTrackingSpecification."Serial No.");
//             ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Reservation);

//             if ReservationEntry.FindSet() then
//                 repeat
//                     ReservationEntry.Delete();
//                 until ReservationEntry.Next() = 0;
//         end;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Create Reserv. Entry", 'OnBeforeReservEntryInsert', '', false, false)]
//     local procedure OnBeforeReservEntryInsert(var ReservationEntry: Record "Reservation Entry")
//     begin
//         // You can add additional logic here before creating the reservation
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSetDates', '', false, false)]
//     local procedure OnAfterSetDates(var ReservationEntry: Record "Reservation Entry")
//     begin
//         // You can add additional logic here for setting dates
//     end;
// }