
codeunit 50401 ItemTrackingEventSubscriber
{
    //     //     [EventSubscriber(ObjectType::Table, database::"Tracking Specification", 'OnAfterModifyEvent', '', false, false)]
    //     //     local procedure OnAfterCopyTrackingFromItemLedgEntry(var Rec: Record "Tracking Specification"; var xRec: Record "Tracking Specification")
    //     //     var
    //     //         ItemTrackingLines: Page "Item Tracking Lines";
    //     //     begin
    //     //         Message('new test');
    //     //         // همگام‌سازی جدول موقت صفحه با Tracking Specification
    //     //         ItemTrackingLines.SetTableView(Rec);
    //     //         ItemTrackingLines.Update(true);
    //     //     end;
    //     [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnBeforeSetSourceSpecForTransferReceipt', '', false, false)]
    //     local procedure OnBeforeSetSourceSpecForTransferReceipt(
    //         var TrackingSpecificationRec: Record "Tracking Specification";
    //         var ReservEntry: Record "Reservation Entry";
    //         var TrackingSpecification: Record "Tracking Specification";
    //         CurrentRunMode: Enum "Item Tracking Run Mode";
    //         var DeleteIsBlocked: Boolean;
    //         var IsHandled: Boolean;
    //         var TempTrackingSpecification2: Record "Tracking Specification" temporary)
    //     var
    //         AutoSerialManagement: Codeunit "Auto Serial Management";
    //         TempSelectedSerials: Record "Tracking Specification" temporary;
    //     begin
    //         // Call the codeunit to fill TempSelectedSerials with auto-selected serials
    //         AutoSerialManagement.AutoSelectSerialNumbers(TrackingSpecification, TempSelectedSerials);

    //         // Add the selected serials to TempTrackingSpecification2
    //         if TempSelectedSerials.FindSet() then
    //             repeat
    //                 TempTrackingSpecification2.Init();
    //                 // TempTrackingSpecification2 := TempSelectedSerials;
    //                 TempTrackingSpecification2."Serial No." := 'W1';
    //                 TempTrackingSpecification2.Insert();
    //             until TempSelectedSerials.Next() = 0;

    //         // Optionally, set IsHandled := true if you want to override default logic
    //         // IsHandled := true;

    //         // For demo: show a message (remove in production)
    //         Message('Auto serials injected into TempTrackingSpecification2.');
    //     end;

    // [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnBeforeUpdateTrackingData', '', false, false)]
    // local procedure OnBeforeUpdateTrackingData(var TrackingSpecification: Record "Tracking Specification"; xTrackingSpecification: Record "Tracking Specification"; var xTempTrackingSpec: Record "Tracking Specification" temporary; CurrentSignFactor: Integer; var SourceQuantityArray: array[5] of Decimal; var IsHandled: Boolean)

    // begin
    //     Message('test OnBeforeUpdateTrackingData');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Management", 'OnBeforeTempHandlingSpecificationInsert', '', false, false)]

    // local procedure OnBeforeTempHandlingSpecificationInsert(var TempTrackingSpecification: Record "Tracking Specification" temporary; ReservationEntry: Record "Reservation Entry")

    // begin
    //     Message('test OnBeforeTempHandlingSpecificationInsert');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Tracking Management", 'OnSumUpItemTrackingOnBeforeTempHandlingSpecificationModify', '', false, false)]

    // local procedure OnSumUpItemTrackingOnBeforeTempHandlingSpecificationModify(var TempHandlingSpecification: Record "Tracking Specification" temporary; ReservEntry: Record "Reservation Entry")
    // var

    // begin
    //     Message('test OnSumUpItemTrackingOnBeforeTempHandlingSpecificationModify');


    // end;

    // [EventSubscriber(ObjectType::table, Database::"Tracking Specification", 'OnAfterSetTrackingFilterFromReservEntry', '', false, false)]
    // local procedure OnAfterSetTrackingFilterFromReservEntry(var TrackingSpecification: Record "Tracking Specification"; ReservationEntry: Record "Reservation Entry")
    // begin
    //     Message('test OnAfterSetTrackingFilterFromReservEntry');

    // end;

    // //3
    // [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Create Reserv. Entry", 'OnBeforeReservEntryInsert', '', false, false)]
    // local procedure OnBeforeReservEntryInsert(var ReservationEntry: Record "Reservation Entry")
    // begin
    //     Message('test OnBeforeReservEntryInsert');
    // end;

    // local procedure OnRegisterChangeOnChangeTypeInsertOnBeforeInsertReservEntry(var TrackingSpecification: Record "Tracking Specification"; var OldTrackingSpecification: Record "Tracking Specification"; var NewTrackingSpecification: Record "Tracking Specification"; FormRunMode: Option)
    // begin
    //     Message('test OnRegisterChangeOnChangeTypeInsertOnBeforeInsertReservEntry');
    // end;
    // //1
    // [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Create Reserv. Entry", 'OnAfterSetDates', '', false, false)]

    // local procedure OnAfterSetDates(var ReservationEntry: Record "Reservation Entry")
    // begin
    //     Message('test OnAfterSetDates');
    // end;

    // //2
    // [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Create Reserv. Entry", 'OnCreateReservEntryExtraFields', '', false, false)]
    // local procedure OnCreateReservEntryExtraFields(var InsertReservEntry: Record "Reservation Entry"; OldTrackingSpecification: Record "Tracking Specification"; NewTrackingSpecification: Record "Tracking Specification")
    // begin
    //     Message('test OnCreateReservEntryExtraFields');
    // end;

    // [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterCopyTrackingSpec', '', false, false)]
    // local procedure OnAfterCopyTrackingSpec(var SourceTrackingSpec: Record "Tracking Specification"; var DestTrkgSpec: Record "Tracking Specification")
    // begin


    //     Message('test OnAfterCopyTrackingSpec');
    // end;

    // [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnAfterMoveFields', '', false, false)]
    // local procedure OnAfterMoveFields(var TrkgSpec: Record "Tracking Specification"; var ReservEntry: Record "Reservation Entry")
    // begin
    //     Message('test OnAfterMoveFields');
    // end;

    // //4
    // [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnRegisterChangeOnAfterCreateReservEntry', '', false, false)]
    // local procedure OnRegisterChangeOnAfterCreateReservEntry(var ReservEntry: Record "Reservation Entry"; OldTrackingSpecification: Record "Tracking Specification")
    // begin
    //     Message('test OnRegisterChangeOnAfterCreateReservEntry');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Item Jnl.-Post Line", 'OnBeforeInsertSetupTempSplitItemJnlLine', '', false, false)]
    // local procedure OnBeforeInsertSetupTempSplitItemJnlLine(var TempTrackingSpecification: Record "Tracking Specification" temporary; var TempItemJournalLine: Record "Item Journal Line" temporary; var PostItemJnlLine: Boolean; var ItemJournalLine2: Record "Item Journal Line"; SignFactor: Integer; FloatingFactor: Decimal)
    // begin

    //     Message('test OnBeforeInsertSetupTempSplitItemJnlLine');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', false, false)]
    // local procedure OnAfterInitItemLedgEntry(var NewItemLedgEntry: Record "Item Ledger Entry"; var ItemJournalLine: Record "Item Journal Line"; var ItemLedgEntryNo: Integer)
    // begin
    //     Message('test OnAfterInitItemLedgEntry');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Whse.-Post Receipt (Yes/No)", 'OnBeforeConfirmWhseReceiptPost', '', false, false)]
    // local procedure OnBeforeConfirmWhseReceiptPost(var WhseReceiptLine: Record "Warehouse Receipt Line"; var HideDialog: Boolean; var IsPosted: Boolean)

    // begin
    //     Message('test OnBeforeConfirmWhseReceiptPost');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Purch.-Post", 'OnAfterSaveTempWhseSplitSpec', '', false, false)]
    // local procedure OnAfterSaveTempWhseSplitSpec(PurchaseLine: Record "Purchase Line"; var TempTrackingSpecification: Record "Tracking Specification" temporary)

    // begin
    //     Message('test OnAfterSaveTempWhseSplitSpec');

    // end;

    [EventSubscriber(ObjectType::page, 6510, 'OnInsertRecordOnBeforeTempItemTrackLineInsert', '', false, false)]

    local procedure OnInsertRecordOnBeforeTempItemTrackLineInsert(var TempTrackingSpecificationInsert: Record "Tracking Specification" temporary; var TempTrackingSpecification: Record "Tracking Specification" temporary)
    begin
        Message('start');
        TempTrackingSpecification."Serial No." := 'W1';
        TempTrackingSpecificationInsert."Serial No." := 'W1';
        Message('test saeid');
    end;
}