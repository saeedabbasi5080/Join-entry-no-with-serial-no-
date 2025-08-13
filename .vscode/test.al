// pageextension 50120 ItemTrackingLinesExt extends "Item Tracking Lines"
// {
//     actions
//     {
//         addlast(processing)
//         {
//             // action(Test)
//             // {
//             //     Caption = 'Auoto Assigin Serial';
//             //     Image = Allocate;

//             //     trigger OnAction()

//             //     begin
//             //         AssignSerialsFromLedgerSimple(Rec);
//             //     end;
//             // }
//             // action(test2)
//             // {
//             //     Caption = 'Auoto Assigin Serial Soroush';
//             //     Image = Allocate;

//             //     trigger OnAction()

//             //     begin
//             //         // AssignSerialsFromLedgerSimpleSoroush(Rec);
//             //     end;
//             // }

//             action(test3)
//             {
//                 Caption = 'Auto Assign Serial Delete';
//                 Image = Allocate;

//                 trigger OnAction()

//                 begin
//                     AssignSerialsFromLedgerSimpleDelete(Rec);
//                 end;
//             }
//         }
//     }

//     // procedure AssignSerialsFromLedgerSimpleSoroush(var Rec: Record "Tracking Specification")
//     // var
//     //     CreateReservEntry: Codeunit "Create Reserv. Entry";
//     //     TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
//     //     TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
//     //     TempTrackingSpecificationInsert: Record "Tracking Specification" temporary;

//     //     CorrespondingSalesLine: Record "Sales Line";
//     //     CurrentWhseShptLine: Record "Warehouse Shipment Line";
//     //     ItemLedgEntry: Record "Item Ledger Entry";
//     //     ReservEntry: Record "Reservation Entry";
//     //     Item: Record Item;
//     //     CheckTrackingSpec: Record "Tracking Specification"; // فقط برای چک کردن
//     //     ExistingQty: Decimal;
//     //     RemainingQty: Decimal;
//     //     nNeeded: Decimal;
//     //     FoundCount: Integer;
//     //     hasFound: Boolean;
//     //     ItemNo: Code[20];
//     //     VariantCode: Code[10];
//     //     LocationCode: Code[10];
//     //     ReservedQtyCheck: Decimal;
//     //     CurrRecQtyChec: Decimal;



//     //     //soroush
//     //     Index: Integer;
//     //     InsertEntryNo: Integer;
//     //     LineCountToGenerate: Integer;
//     //     TrackingSpecifictionRecInstance: Record "Tracking Specification" temporary;
//     // begin
//     //     IsCreated := true;
//     //     // Initial validation: Check if there are already tracking lines with serial numbers
//     //     // CurrRecQtyChec := 0;
//     //     // Rec.Reset();
//     //     // Rec.SetRange("Source Type", Rec."Source Type");
//     //     // Rec.SetRange("Source ID", Rec."Source ID");
//     //     // Rec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
//     //     // Rec.SetFilter("Serial No.", '<>%1', '');
//     //     // if Rec.FindSet() then
//     //     //     repeat
//     //     //         CurrRecQtyChec += Abs(Rec."Quantity (Base)");
//     //     //     until Rec.Next() = 0;




//     //     //CALCULATE CORRENT QUANTITY THAT HAVE SERIAL
//     //     Rec.SetFilter("Serial No.", '<>%1', '');
//     //     Rec.CalcSums("Quantity (Base)");

//     //     //TOTAL QUANTITY SHOULD BE GENERATE 
//     //     CorrespondingSalesLine := GetRelatedSalesLine();

//     //     //REMAIN LINE TO GENERATE 
//     //     LineCountToGenerate := CorrespondingSalesLine."Qty. to Ship" - Rec."Quantity (Base)";
//     //     InsertEntryNo := xrec."Entry No.";
//     //     Rec.Reset();
//     //     if (LineCountToGenerate > 0) then begin
//     //         begin
//     //             for Index := 1 to LineCountToGenerate do begin
//     //                 // Clear(Rec);
//     //                 // Rec."Serial No." := '';
//     //                 // Rec.TransferFields(xRec); // Copy base values from current record
//     //                 TempTrackingSpecificationModify := rec;


//     //                 TempTrackingSpecificationDelete := xRec;
//     //                 // TempTrackingSpecificationDelete."Serial No." := '';
//     //                 // TempTrackingSpecificationDelete."Entry No." := InsertEntryNo + 1;
//     //                 // TempTrackingSpecificationDelete.Insert();

//     //                 TempTrackingSpecificationInsert.Init();
//     //                 TempTrackingSpecificationInsert.TransferFields(xRec);
//     //                 // Set new values
//     //                 TempTrackingSpecificationInsert.Validate("Serial No.", GenerateRandomString(7));
//     //                 // Rec.Validate("Lot No.", ItemLedgEntry."Lot No.");
//     //                 TempTrackingSpecificationInsert.Validate("Quantity (Base)", 1);
//     //                 // InsertRecord(Rec);
//     //                 InsertEntryNo += 1;
//     //                 // Insert new record
//     //                 TempTrackingSpecificationInsert.Validate("Entry No.", InsertEntryNo);
//     //                 TempTrackingSpecificationInsert.Insert();

//     //                 rec := TempTrackingSpecificationInsert;
//     //                 rec.Insert();

//     //                 //InsertRecord(Rec);
//     //                 //SetVariables(Rec, TempTrackingSpecificationDelete, TempTrackingSpecificationModify);
//     //             end;
//     //             SetVariables(TempTrackingSpecificationInsert, TempTrackingSpecificationDelete, TempTrackingSpecificationModify);

//     //         end;

//     //     end;

//     //     CurrPage.Update(false);
//     // end;


//     procedure AssignSerialsFromLedgerSimpleDelete(var Rec: Record "Tracking Specification")
//     var
//         CreateReservEntry: Codeunit "Create Reserv. Entry";


//         CorrespondingSalesLine: Record "Sales Line";
//         CurrentWhseShptLine: Record "Warehouse Shipment Line";
//         ItemLedgEntry: Record "Item Ledger Entry";
//         ReservEntry: Record "Reservation Entry";
//         Item: Record Item;
//         CheckTrackingSpec: Record "Tracking Specification"; // فقط برای چک کردن
//         ExistingQty: Decimal;
//         RemainingQty: Decimal;
//         nNeeded: Decimal;
//         FoundCount: Integer;
//         hasFound: Boolean;
//         ItemNo: Code[20];
//         VariantCode: Code[10];
//         LocationCode: Code[10];
//         ReservedQtyCheck: Decimal;
//         CurrRecQtyChec: Decimal;



//         //soroush
//         Index: Integer;
//         InsertEntryNo: Integer;
//         LineCountToGenerate: Integer;
//         TrackingSpecifictionRecInstance: Record "Tracking Specification" temporary;


//     begin
//         AutoAssignMode := true;

//         IsCreated := true;

//         //CALCULATE CORRENT QUANTITY THAT HAVE SERIAL
//         Rec.SetFilter("Serial No.", '<>%1', '');
//         Rec.CalcSums("Quantity (Base)");

//         //TOTAL QUANTITY SHOULD BE GENERATE 
//         CorrespondingSalesLine := GetRelatedSalesLine();

//         //REMAIN LINE TO GENERATE 
//         LineCountToGenerate := CorrespondingSalesLine."Qty. to Ship" - Rec."Quantity (Base)";

//         Rec.Reset();
//         Rec.SetCurrentKey("Entry No.");
//         if Rec.FindLast() then begin
//             InsertEntryNo := Rec."Entry No.";
//         end;
//         // if rec.FindFirst() then begin
//         //     InsertEntryNo := rec."Entry No.";
//         // end;
//         Rec.Reset();

//         // if (not rec.IsEmpty)
//         // then begin
//         //     TempTrackingSpecificationModify.init();
//         //     TempTrackingSpecificationModify := rec;
//         //     TempTrackingSpecificationModify.Insert();
//         // end;



//         if TempTrackingSpecificationInsert.FindSet() then begin
//             repeat
//                 rec.SetRange("Serial No.", TempTrackingSpecificationInsert."Serial No.");
//                 if (not rec.FindFirst()) then begin
//                     TempTrackingSpecificationDelete.init();
//                     TempTrackingSpecificationDelete := TempTrackingSpecificationInsert;
//                     TempTrackingSpecificationDelete.Insert();
//                 end;

//             until TempTrackingSpecificationInsert.Next() = 0;
//         end;

//         rec.Reset();


//         if (LineCountToGenerate > 0) then begin
//             begin
//                 for Index := 1 to LineCountToGenerate do begin

//                     TempTrackingSpecificationInsert.Init();
//                     TempTrackingSpecificationInsert.TransferFields(xRec);
//                     // Set new values
//                     TempTrackingSpecificationInsert.Validate("Serial No.", GenerateRandomString(7));
//                     TempTrackingSpecificationInsert.Validate("Quantity (Base)", 1);
//                     InsertEntryNo += 1;
//                     // Insert new record
//                     TempTrackingSpecificationInsert.Validate("Entry No.", InsertEntryNo);
//                     TempTrackingSpecificationInsert.Insert();

//                     rec := TempTrackingSpecificationInsert;
//                     //InsertRecord(rec);
//                     rec.Insert();
//                 end;

//                 if (not rec.IsEmpty) then begin
//                     TempTrackingSpecificationModify.init();
//                     TempTrackingSpecificationModify := TempTrackingSpecificationInsert;
//                     TempTrackingSpecificationModify.Insert();
//                 end;





//                 SetVariables(TempTrackingSpecificationInsert, TempTrackingSpecificationDelete, TempTrackingSpecificationModify);
//             end;
//         end;

//         CurrPage.Update(false);
//     end;

//     trigger OnDeleteRecord(): Boolean
//     begin
//         if (AutoAssignMode) then begin

//             TempTrackingSpecificationInsert.SetRange("Serial No.", rec."Serial No.");
//             if (TempTrackingSpecificationInsert.FindFirst())
//              then begin
//                 TempTrackingSpecificationInsert.Delete();
//                 TempTrackingSpecificationDelete.init();
//                 TempTrackingSpecificationDelete := TempTrackingSpecificationInsert;
//                 TempTrackingSpecificationDelete.Insert();
//                 // TempTrackingSpecificationDelete.InsertSpecification();
//             end;
//         end;

//         exit(true);
//     end;

//     // trigger OnAfterGetCurrRecord()
//     // begin
//     //     if (AutoAssignMode) then AssignSerialsFromLedgerSimpleDelete(rec);
//     // end;

//     // trigger OnAfterGetRecord()
//     // begin
//     //     if (AutoAssignMode) then AssignSerialsFromLedgerSimpleDelete(rec);

//     // end;

//     trigger OnModifyRecord(): Boolean
//     begin
//         if (AutoAssignMode) then AssignSerialsFromLedgerSimpleDelete(rec);
//     end;

//     procedure AssignSerialsFromLedgerSimple(var Rec: Record "Tracking Specification")
//     var
//         CreateReservEntry: Codeunit "Create Reserv. Entry";
//         TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
//         TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
//         TempTrackingSpecificationInsert: Record "Tracking Specification" temporary;
//         orrespondingSalesLine: Record "Sales Line";
//         CurrentWhseShptLine: Record "Warehouse Shipment Line";
//         ItemLedgEntry: Record "Item Ledger Entry";
//         ReservEntry: Record "Reservation Entry";
//         Item: Record Item;
//         CheckTrackingSpec: Record "Tracking Specification"; // فقط برای چک کردن
//         ExistingQty: Decimal;
//         RemainingQty: Decimal;
//         nNeeded: Decimal;
//         FoundCount: Integer;
//         hasFound: Boolean;
//         ItemNo: Code[20];
//         VariantCode: Code[10];
//         LocationCode: Code[10];
//         ReservedQtyCheck: Decimal;
//         CurrRecQtyChec: Decimal;
//     begin

//         AutoAssignMode := true;
//         // Initial validation: Check if there are already tracking lines with serial numbers
//         CurrRecQtyChec := 0;
//         Rec.Reset();
//         Rec.SetRange("Source Type", Rec."Source Type");
//         Rec.SetRange("Source ID", Rec."Source ID");
//         Rec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
//         Rec.SetFilter("Serial No.", '<>%1', '');
//         if Rec.FindSet() then
//             repeat
//                 CurrRecQtyChec += Abs(Rec."Quantity (Base)");
//             until Rec.Next() = 0;


//         // if not Rec.IsEmpty() then begin
//         //     Message('Serial numbers have already been assigned to this line. No additional assignment needed.');
//         //     exit;
//         // end;



//         GetRelatedSalesLine();

//         if CurrRecQtyChec >= nNeeded then begin
//             Message('Serial numbers have already been assigned to this line. No additional assignment needed.');
//             // Format(Rec."Source Type"), nNeeded, CurrRecQtyChec);
//             exit;
//         end;

//         // Additional validation: Check if sufficient quantity is already reserved for this document
//         // ReservedQtyCheck := 0;
//         // Clear(ReservEntry);
//         // ReservEntry.SetRange("Item No.", ItemNo);
//         // ReservEntry.SetRange("Source ID", Rec."Source ID");
//         // ReservEntry.SetRange("Source Ref. No.", Rec."Source Ref. No.");
//         // // ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);
//         // ReservEntry.SetFilter("Serial No.", '<>%1', '');
//         // if ReservEntry.FindSet() then
//         //     repeat
//         //         ReservedQtyCheck += Abs(ReservEntry."Quantity (Base)");
//         //     until ReservEntry.Next() = 0;

//         // if ReservedQtyCheck >= nNeeded then begin
//         //     Message('Sufficient serial numbers are already reserved for this %1. Required: %2, Reserved: %3',
//         //         Format(Rec."Source Type"), nNeeded, ReservedQtyCheck);
//         //     exit;
//         // end;

//         // 2. Check item
//         Clear(Item);
//         if not Item.Get(ItemNo) then begin
//             Message('Item %1 not found.', ItemNo);
//             exit;
//         end;

//         if Item."Item Tracking Code" = '' then begin
//             Message('Item %1 is not enabled for tracking.', Item."No.");
//             exit;
//         end;

//         // 3. Calculate existing quantity in Item Tracking Lines
//         ExistingQty := 0;
//         Rec.Reset();
//         Rec.SetRange("Source Type", Rec."Source Type");
//         Rec.SetRange("Source ID", Rec."Source ID");
//         Rec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
//         if Rec.FindSet() then
//             repeat
//                 ExistingQty += Abs(Rec."Quantity (Base)");
//             until Rec.Next() = 0;

//         // 4. Calculate remaining quantity
//         RemainingQty := nNeeded - ExistingQty;

//         if RemainingQty <= 0 then begin
//             Message('All required quantity has already been assigned.');
//             exit;
//         end;

//         FoundCount := 0;

//         // 5. Search Item Ledger Entries and create tracking specifications
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

//         // Sort by proper criteria based on costing method
//         if Item."Costing Method" = Item."Costing Method"::FIFO then
//             ItemLedgEntry.SetCurrentKey("Entry No.") // FIFO - earliest entries first
//         else
//             // For other costing methods, sort by expiration date or warranty date
//             ItemLedgEntry.SetCurrentKey("Expiration Date", "Warranty Date");

//         if ItemLedgEntry.FindSet() then
//             repeat
//                 if FoundCount >= RemainingQty then
//                     break;

//                 hasFound := true;

//                 // Check that serial is not reserved for another document
//                 Clear(ReservEntry);
//                 ReservEntry.SetRange("Item No.", ItemNo);
//                 ReservEntry.SetRange("Serial No.", Rec."Serial No.");
//                 ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);

//                 // If source is Sales Line, add except current order logic
//                 if Rec."Source Type" = DATABASE::"Sales Line" then
//                     ReservEntry.SetFilter("Source ID", '<>%1', Rec."Source ID");

//                 if not ReservEntry.IsEmpty() then
//                     hasFound := false;

//                 // Check that serial doesn't already exist in tracking lines
//                 if hasFound then begin
//                     Rec.Reset();
//                     Rec.SetRange("Source Type", Rec."Source Type");
//                     Rec.SetRange("Source ID", Rec."Source ID");
//                     Rec.SetRange("Source Ref. No.", Rec."Source Ref. No.");
//                     Rec.SetRange("Serial No.", ItemLedgEntry."Serial No.");
//                     if not Rec.IsEmpty() then
//                         hasFound := false;
//                 end;

//                 // if Rec.FindFirst() then begin
//                 //     IsModified := true;
//                 //     IsCreated := false;
//                 //     IsDeleted := false;
//                 // end;

//                 if hasFound then begin
//                     if IsDeleted then begin
//                         Clear(Rec);
//                         Rec."Serial No." := '';
//                         Rec.TransferFields(xRec); // Copy base values from current record

//                         // Set new values
//                         Rec.Validate("Serial No.", ItemLedgEntry."Serial No.");
//                         // Rec.Validate("Lot No.", ItemLedgEntry."Lot No.");
//                         Rec.Validate("Quantity (Base)", 1);
//                         Rec."Expiration Date" := ItemLedgEntry."Expiration Date";
//                         Rec."Warranty Date" := ItemLedgEntry."Warranty Date";

//                         // Insert new record
//                         InsertRecord(Rec);
//                         // SetVariables(TempTrackingSpecificationModify, TempTrackingSpecificationDelete, Rec);
//                         FoundCount += 1;
//                         IsCreated := false;
//                         IsModified := false;
//                     end;
//                     if IsModified then begin
//                         // Create new record for each serial
//                         Clear(Rec);
//                         Rec."Serial No." := '';
//                         Rec.TransferFields(xRec); // Copy base values from current record

//                         // Set new values
//                         Rec.Validate("Serial No.", ItemLedgEntry."Serial No.");
//                         // Rec.Validate("Lot No.", ItemLedgEntry."Lot No.");
//                         Rec.Validate("Quantity (Base)", 1);
//                         Rec."Expiration Date" := ItemLedgEntry."Expiration Date";
//                         Rec."Warranty Date" := ItemLedgEntry."Warranty Date";

//                         // Insert new record
//                         InsertRecord(Rec);
//                         // SetVariables(TempTrackingSpecificationModify, Rec, TempTrackingSpecificationDelete);
//                         FoundCount += 1;
//                         IsCreated := false;
//                         IsDeleted := false;
//                     end;
//                     if IsCreated then begin
//                         Clear(Rec);
//                         Rec."Serial No." := '';
//                         Rec.TransferFields(xRec); // Copy base values from current record

//                         // Set new values
//                         Rec.Validate("Serial No.", ItemLedgEntry."Serial No.");
//                         // Rec.Validate("Lot No.", ItemLedgEntry."Lot No.");
//                         Rec.Validate("Quantity (Base)", 1);
//                         Rec."Expiration Date" := ItemLedgEntry."Expiration Date";
//                         Rec."Warranty Date" := ItemLedgEntry."Warranty Date";

//                         // Insert new record
//                         InsertRecord(Rec);

//                         FoundCount += 1;
//                     end;
//                     SetVariables(TempTrackingSpecificationInsert, TempTrackingSpecificationDelete, TempTrackingSpecificationModify);



//                     // end;

//                     // Check if reservation entry already exists before creating
//                     // Clear(ReservEntry);
//                     // ReservEntry.SetRange("Item No.", ItemNo);
//                     // ReservEntry.SetRange("Serial No.", Rec."Serial No.");
//                     // ReservEntry.SetRange("Source ID", Rec."Source ID");
//                     // ReservEntry.SetRange("Source Ref. No.", Rec."Source Ref. No.");
//                     // ReservEntry.SetRange("Source Type", Rec."Source Type");
//                     // // ReservEntry.SetRange("Reservation Status", ReservEntry."Reservation Status"::Reservation);

//                     // if ReservEntry.IsEmpty() then
//                     //     CreateReservEntry.CreateReservEntryFrom(Rec);




//                 end;
//             until ItemLedgEntry.Next() = 0;

//         // Refresh page
//         CurrPage.Update(true);

//         // 6. Show result
//         if FoundCount = 0 then
//             Message('No available serials found.')
//         else
//             if FoundCount < RemainingQty then
//                 Message('Only %1 serials out of %2 needed were found and added.\Total assigned: %3 of %4',
//                     FoundCount, RemainingQty, ExistingQty + FoundCount, nNeeded)
//             else
//                 Message('%1 serials successfully added.\Total assigned: %2 of %3',
//                     FoundCount, ExistingQty + FoundCount, nNeeded);
//     end;


//     procedure GenerateRandomString(Length: Integer) RandomString: Text
//     var
//         Characters: Text;
//         i: Integer;
//         RandomPos: Integer;
//     begin
//         Characters := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//         RandomString := '';

//         for i := 1 to Length do begin
//             RandomPos := Random(StrLen(Characters)) + 1;
//             RandomString += CopyStr(Characters, RandomPos, 1);
//         end;
//     end;

//     local procedure GetRelatedSalesLine(): record "Sales Line"
//     var
//         SalesLine: record "Sales Line";
//     begin
//         Clear(SalesLine);
//         SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
//         SalesLine.SetRange("Document No.", Rec."Source ID");
//         SalesLine.SetRange("Line No.", Rec."Source Ref. No.");
//         if SalesLine.FindFirst() then
//             exit(SalesLine);

//         Error(':((');
//     end;

//     // trigger OnDeleteRecord(): Boolean
//     // var
//     //     TempTrackingSpecificationInsert: Record "Tracking Specification" temporary;
//     //     TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
//     //     TempTrackingSpecificationModify: Record "Tracking Specification" temporary;

//     // begin
//     //     IsDeleted := true;
//     //     IsCreated := false;

//     //     // Use Business Central's standard logic to delete the tracking line
//     //     // SetVariables(TempTrackingSpecificationInsert, TempTrackingSpecificationModify, Rec);
//     //     exit(true);
//     // end;

//     // trigger OnModifyRecord(): Boolean
//     // begin
//     //     IsModified := true;
//     //     IsCreated := false;
//     //     exit(true);
//     // end;
//     trigger OnOpenPage()
//     begin
//         AutoAssignMode := false;
//     end;

//     var
//         IsDeleted: Boolean;
//         IsModified: Boolean;
//         IsCreated: Boolean;
//         TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
//         TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
//         TempTrackingSpecificationInsert: Record "Tracking Specification" temporary;
//         AutoAssignMode: Boolean;


// }