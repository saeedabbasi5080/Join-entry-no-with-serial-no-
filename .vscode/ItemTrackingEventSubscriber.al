// codeunit 50122 ItemTrackingEventSubscriber
// {
//     [EventSubscriber(ObjectType::Page, Page::"Item Tracking Lines", 'OnBeforeClosePage', '', false, false)]
//     local procedure OnBeforeClosePage_OnAfterEvent(var TrackingSpecification: Record "Tracking Specification"; var SkipWriteToDatabase: Boolean)
//     var
//         ReservEntry: Record "Reservation Entry";
//     begin
//         Message('ENT %1', TrackingSpecification."Entry No.");
//         // Clear(ReservEntry);
//         // ReservEntry.SetRange("Item No.", TrackingSpecification."Item No.");
//         // ReservEntry.SetRange("Serial No.", TrackingSpecification."Serial No.");
//         // ReservEntry.SetRange("Source ID", TrackingSpecification."Source ID");
//         // ReservEntry.SetRange("Source Ref. No.", TrackingSpecification."Source Ref. No.");
//         // ReservEntry.SetRange("Source Type", TrackingSpecification."Source Type");
//         // if ReservEntry.FindSet() then
//         //    // Message('OnBeforeClosePage');
//         // TrackingSpecification."Quantity (Base)" := 0;
//         // TrackingSpecification."Serial No." := '';
//         // TrackingSpecification.Modify();


//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterCreateReservEntryFor', '', false, false)]
//     local procedure OnAfterCreateReservEntryFor(var ReservationEntry: Record "Reservation Entry"; Sign: Integer; ForType: Option; ForSubtype: Integer; ForID: Code[20]; ForBatchName: Code[10]; ForProdOrderLine: Integer; ForRefNo: Integer; ForQtyPerUOM: Decimal; Quantity: Decimal; QuantityBase: Decimal; ForReservEntry: Record "Reservation Entry")
//     begin
//         // Message('Reservation Entry Created: %1', ReservationEntry."Entry No.");
//     end;


//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterCheckValidity', '', false, false)]
//     local procedure OnAfterCheckValidity_OnAfterEvent(ReservEntry: Record "Reservation Entry"; var IsError: Boolean)
//     begin
//         // Message('Event: OnAfterCheckValidity fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterCopyFromInsertReservEntry', '', false, false)]
//     local procedure OnAfterCopyFromInsertReservEntry_OnAfterEvent(var InsertReservEntry: Record "Reservation Entry"; var ReservEntry: Record "Reservation Entry"; FromReservEntry: Record "Reservation Entry"; Status: Enum "Reservation Status"; QtyToHandleAndInvoiceIsSet: Boolean)
//     begin
//         // Message('Event: OnAfterCopyFromInsertReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterCreateReservEntryFor', '', false, false)]
//     local procedure OnAfterCreateReservEntryFor_OnAfterEvent(var ReservationEntry: Record "Reservation Entry"; Sign: Integer; ForType: Option; ForSubtype: Integer; ForID: Code[20]; ForBatchName: Code[10]; ForProdOrderLine: Integer; ForRefNo: Integer; ForQtyPerUOM: Decimal; Quantity: Decimal; QuantityBase: Decimal; ForReservEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnAfterCreateReservEntryFor fired. Entry No.: %1', ReservationEntry."Entry No.");
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterCreateReservEntryFrom', '', false, false)]
//     local procedure OnAfterCreateReservEntryFrom_OnAfterEvent(var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnAfterCreateReservEntryFrom fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSplitReservEntry', '', false, false)]
//     local procedure OnAfterSplitReservEntry_OnAfterEvent(var ReservEntry2: Record "Reservation Entry"; TempTrackingSpecificaion: Record "Tracking Specification"; var Result: Boolean)
//     begin
//         // Message('Event: OnAfterSplitReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterCreateEntry', '', false, false)]
//     local procedure OnAfterCreateEntry_OnAfterEvent(ItemNo: Code[20]; VariantCode: Code[10]; LocationCode: Code[10])
//     begin
//         // Message('Event: OnAfterCreateEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterReservEntryInsert', '', false, false)]
//     local procedure OnAfterReservEntryInsert_OnAfterEvent(var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnAfterReservEntryInsert fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterReservEntryInsertNonSurplus', '', false, false)]
//     local procedure OnAfterReservEntryInsertNonSurplus_OnAfterEvent(var ReservationEntry2: Record "Reservation Entry"; var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnAfterReservEntryInsertNonSurplus fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSignFactor', '', false, false)]
//     local procedure OnAfterSignFactor_OnAfterEvent(ReservationEntry: Record "Reservation Entry"; var Sign: Integer)
//     begin
//         // Message('Event: OnAfterSignFactor fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSetNewTrackingFromItemJnlLine', '', false, false)]
//     local procedure OnAfterSetNewTrackingFromItemJnlLine_OnAfterEvent(var InsertReservEntry: Record "Reservation Entry"; ItemJnlLine: Record "Item Journal Line")
//     begin
//         // Message('Event: OnAfterSetNewTrackingFromItemJnlLine fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSetDates', '', false, false)]
//     local procedure OnAfterSetDates_OnAfterEvent(var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnAfterSetDates fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSetNewTrackingFromNewTrackingSpecification', '', false, false)]
//     local procedure OnAfterSetNewTrackingFromNewTrackingSpecification_OnAfterEvent(var InsertReservEntry: Record "Reservation Entry"; TrackingSpecification: Record "Tracking Specification")
//     begin
//         // Message('Event: OnAfterSetNewTrackingFromNewTrackingSpecification fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSetNewTrackingFromNewWhseItemTrackingLine', '', false, false)]
//     local procedure OnAfterSetNewTrackingFromNewWhseItemTrackingLine_OnAfterEvent(var InsertReservEntry: Record "Reservation Entry"; WhseItemTrackingLine: Record "Whse. Item Tracking Line")
//     begin
//         // Message('Event: OnAfterSetNewTrackingFromNewWhseItemTrackingLine fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterTransferReservEntry', '', false, false)]
//     local procedure OnAfterTransferReservEntry_OnAfterEvent(NewReservEntry: Record "Reservation Entry"; OldReservEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnAfterTransferReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBalanceListsOnAfterLoosenFilter1', '', false, false)]
//     local procedure OnBalanceListsOnAfterLoosenFilter1_OnAfterEvent(var TempTrackingSpecification1: Record "Tracking Specification" temporary; TempTrackingSpecification2: Record "Tracking Specification" temporary)
//     begin
//         // Message('Event: OnBalanceListsOnAfterLoosenFilter1 fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBalanceListsOnAfterLoosenFilter2', '', false, false)]
//     local procedure OnBalanceListsOnAfterLoosenFilter2_OnAfterEvent(var TempTrackingSpecification2: Record "Tracking Specification" temporary; TempTrackingSpecification1: Record "Tracking Specification" temporary)
//     begin
//         // Message('Event: OnBalanceListsOnAfterLoosenFilter2 fired.');
//     end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeCheckValidity', '', false, false)]
//     // local procedure OnBeforeCheckValidity_OnAfterEvent(var ReservationEntry: Record "Reservation Entry"; var IsHandled: Boolean)
//     // begin
//     //    // Message('Event: OnBeforeCheckValidity fired.');
//     // end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeClearTracking', '', false, false)]
//     // local procedure OnBeforeClearTracking_OnAfterEvent(var ReservEntry: Record "Reservation Entry"; var IsHandled: Boolean)
//     // begin
//     //    // Message('Event: OnBeforeClearTracking fired.');
//     // end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeCreateRemainingReservEntry', '', false, false)]
//     local procedure OnBeforeCreateRemainingReservEntry_OnAfterEvent(var ReservationEntry: Record "Reservation Entry"; FromReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeCreateRemainingReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeCreateRemainingReservEntryProcedure', '', false, false)]
//     local procedure OnBeforeCreateRemainingReservEntryProcedure_OnAfterEvent(var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeCreateRemainingReservEntryProcedure fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeCreateRemainingNonSurplusReservEntry', '', false, false)]
//     local procedure OnBeforeCreateRemainingNonSurplusReservEntry_OnAfterEvent(var ReservationEntry: Record "Reservation Entry"; FromReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeCreateRemainingNonSurplusReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeCreateWhseItemTrkgLines', '', false, false)]
//     local procedure OnBeforeCreateWhseItemTrkgLines_OnAfterEvent(ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeCreateWhseItemTrkgLines fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeReservEntryInsert', '', false, false)]
//     local procedure OnBeforeReservEntryInsert_OnAfterEvent(var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeReservEntryInsert fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeReservEntryInsertNonSurplus', '', false, false)]
//     local procedure OnBeforeReservEntryInsertNonSurplus_OnAfterEvent(var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeReservEntryInsertNonSurplus fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeReservEntryUpdateItemTracking', '', false, false)]
//     local procedure OnBeforeReservEntryUpdateItemTracking_OnAfterEvent(var ReservationEntry: Record "Reservation Entry"; var ReservationEntry2: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeReservEntryUpdateItemTracking fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeSplitNonSurplusReservEntry', '', false, false)]
//     local procedure OnBeforeSplitNonSurplusReservEntry_OnAfterEvent(var TempTrackingSpecification: Record "Tracking Specification" temporary; var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeSplitNonSurplusReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeSplitReservEntry', '', false, false)]
//     local procedure OnBeforeSplitReservEntry_OnAfterEvent(var TempTrackingSpecification: Record "Tracking Specification" temporary; var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeSplitReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeUseOldReservEntry', '', false, false)]
//     local procedure OnBeforeUseOldReservEntry_OnAfterEvent(var ReservEntry: Record "Reservation Entry"; var InsertReservEntry: Record "Reservation Entry"; CurrSignFactor: Integer)
//     begin
//         // Message('Event: OnBeforeUseOldReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBeforeUpdateItemTrackingAfterPosting', '', false, false)]
//     local procedure OnBeforeUpdateItemTrackingAfterPosting_OnAfterEvent(var ReservEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnBeforeUpdateItemTrackingAfterPosting fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnCreateEntryOnAfterCollectTrackingSpecificationTempTrkgSpec2', '', false, false)]
//     local procedure OnCreateEntryOnAfterCollectTrackingSpecificationTempTrkgSpec2_OnAfterEvent(var TempTrkgSpec2: Record "Tracking Specification" temporary; ReservEntry2: Record "Reservation Entry"; var TrackingSpecificationExists: Boolean)
//     begin
//         // Message('Event: OnCreateEntryOnAfterCollectTrackingSpecificationTempTrkgSpec2 fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnCreateEntryOnBeforeOnBeforeSplitReservEntry', '', false, false)]
//     local procedure OnCreateEntryOnBeforeOnBeforeSplitReservEntry_OnAfterEvent(var ReservEntry: Record "Reservation Entry"; var ReservEntry2: Record "Reservation Entry")
//     begin
//         // Message('Event: OnCreateEntryOnBeforeOnBeforeSplitReservEntry fired.');
//     end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnCreateEntryOnBeforeSurplusCondition', '', false, false)]
//     // local procedure OnCreateEntryOnBeforeSurplusCondition_OnAfterEvent(var ReservEntry: Record "Reservation Entry"; QtyToHandleAndInvoiceIsSet: Boolean; var InsertReservEntry: Record "Reservation Entry")
//     // begin
//     //    // Message('Event: OnCreateEntryOnBeforeSurplusCondition fired.');
//     // end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnCreateReservEntryExtraFields', '', false, false)]
//     local procedure OnCreateReservEntryExtraFields_OnAfterEvent(var InsertReservEntry: Record "Reservation Entry"; OldTrackingSpecification: Record "Tracking Specification"; NewTrackingSpecification: Record "Tracking Specification")
//     begin
//         // Message('Event: OnCreateReservEntryExtraFields fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnCreateRemainingReservEntryOnBeforeCreateReservEntryFrom', '', false, false)]
//     local procedure OnCreateRemainingReservEntryOnBeforeCreateReservEntryFrom_OnAfterEvent(var ReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnCreateRemainingReservEntryOnBeforeCreateReservEntryFrom fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnBeforeUpdateItemTracking', '', false, false)]
//     local procedure OnTransferReservEntryOnBeforeUpdateItemTracking_OnAfterEvent(var ReservationEntry: Record "Reservation Entry"; CarriedReservationEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnTransferReservEntryOnBeforeUpdateItemTracking fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnAfterNewReservEntryInsert', '', false, false)]
//     local procedure OnTransferReservEntryOnAfterNewReservEntryInsert_OnAfterEvent(var NewReservEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnTransferReservEntryOnAfterNewReservEntryInsert fired.');
//     end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnAfterCalcShouldCreateWhseItemTrkgLines', '', false, false)]
//     // local procedure OnTransferReservEntryOnAfterCalcShouldCreateWhseItemTrkgLines_OnAfterEvent(OldReservEntry: Record "Reservation Entry"; var ShouldCreateWhseItemTrkgLines: Boolean)
//     // begin
//     //    // Message('Event: OnTransferReservEntryOnAfterCalcShouldCreateWhseItemTrkgLines fired.');
//     // end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnBeforeNewReservEntryModify', '', false, false)]
//     local procedure OnTransferReservEntryOnBeforeNewReservEntryModify_OnAfterEvent(var NewReservEntry: Record "Reservation Entry"; IsPartnerRecord: Boolean)
//     begin
//         // Message('Event: OnTransferReservEntryOnBeforeNewReservEntryModify fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnBeforeTransferFields', '', false, false)]
//     local procedure OnTransferReservEntryOnBeforeTransferFields_OnAfterEvent(var OldReservationEntry: Record "Reservation Entry"; var UseQtyToHandle: Boolean; var UseQtyToInvoice: Boolean; var CurrSignFactor: Integer)
//     begin
//         // Message('Event: OnTransferReservEntryOnBeforeTransferFields fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnBeforeCheckCarriedItemTrackingSetupTrackingExists', '', false, false)]
//     local procedure OnTransferReservEntryOnBeforeCheckCarriedItemTrackingSetupTrackingExists_OnAfterEvent(var NewReservEntry: Record "Reservation Entry"; OldReservEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnTransferReservEntryOnBeforeCheckCarriedItemTrackingSetupTrackingExists fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnNewItemTracking', '', false, false)]
//     local procedure OnTransferReservEntryOnNewItemTracking_OnAfterEvent(var NewReservEntry: Record "Reservation Entry"; var InsertReservEntry: Record "Reservation Entry"; TransferQty: Decimal)
//     begin
//         // Message('Event: OnTransferReservEntryOnNewItemTracking fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnBeforeCreateRemainingReservEntry', '', false, false)]
//     local procedure OnTransferReservEntryOnBeforeCreateRemainingReservEntry_OnAfterEvent(var OldReservationEntry: Record "Reservation Entry"; var NewReservationEntry: Record "Reservation Entry"; TransferQty: Decimal)
//     begin
//         // Message('Event: OnTransferReservEntryOnBeforeCreateRemainingReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterCreateRemainingReservEntry', '', false, false)]
//     local procedure OnAfterCreateRemainingReservEntry_OnAfterEvent(OldReservEntry: Record "Reservation Entry"; LastReservEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnAfterCreateRemainingReservEntry fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnAfterCalcNewButUnchangedVersion', '', false, false)]
//     local procedure OnTransferReservEntryOnAfterCalcNewButUnchangedVersion_OnAfterEvent(var NewReservEntry: Record "Reservation Entry"; OldReservEntry: Record "Reservation Entry"; TransferQty: Decimal; var DoCreateNewButUnchangedVersion: Boolean)
//     begin
//         // Message('Event: OnTransferReservEntryOnAfterCalcNewButUnchangedVersion fired.');
//     end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnTransferReservEntryOnBeforeCreateNewReservEntry', '', false, false)]
//     // local procedure OnTransferReservEntryOnBeforeCreateNewReservEntry_OnAfterEvent(var NewReservEntry: Record "Reservation Entry"; OldReservEntry: Record "Reservation Entry"; var IsHandled: Boolean; TransferQty: Decimal)
//     // begin
//     //    // Message('Event: OnTransferReservEntryOnBeforeCreateNewReservEntry fired.');
//     // end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnUpdateItemTrackingAfterPostingOnBeforeReservEntryModify', '', false, false)]
//     local procedure OnUpdateItemTrackingAfterPostingOnBeforeReservEntryModify_OnAfterEvent(var ReservEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnUpdateItemTrackingAfterPostingOnBeforeReservEntryModify fired.');
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnAfterSetQtyToHandleAndInvoice', '', false, false)]
//     local procedure OnAfterSetQtyToHandleAndInvoice_OnAfterEvent(var InsertReservEntry: Record "Reservation Entry")
//     begin
//         // Message('Event: OnAfterSetQtyToHandleAndInvoice fired.');
//     end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnBalanceListsOnBeforeNextStateError', '', false, false)]
//     // local procedure OnBalanceListsOnBeforeNextStateError_OnAfterEvent(var NextState: Option; var IsHandled: Boolean)
//     // begin
//     //    // Message('Event: OnBalanceListsOnBeforeNextStateError fired.');
//     // end;

//     // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Create Reserv. Entry", 'OnCreateEntryOnBeforeSplitReservEntryLoop', '', false, false)]
//     // local procedure OnCreateEntryOnBeforeSplitReservEntryLoop_OnAfterEvent(var ReservEntry: Record "Reservation Entry"; var ReservEntry2: Record "Reservation Entry"; TrackingSpecificationExists: Boolean; var FirstSplit: Boolean; var IsHandled: Boolean)
//     // begin
//     //    // Message('Event: OnCreateEntryOnBeforeSplitReservEntryLoop fired.');
//     // end;
// }