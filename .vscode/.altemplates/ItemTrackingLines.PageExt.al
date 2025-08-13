pageextension 50123 ItemTrackLinePageExt extends "Item Tracking Lines"
{
    actions
    {
        addlast(processing)
        {
            action(test4)
            {
                Caption = 'Auto Assign Serial Delete';
                Image = Allocate;

                trigger OnAction()
                begin
                    AssignSerialsFromLedgerSimpleDelete(Rec);
                end;
            }
        }
    }

    procedure AssignSerialsFromLedgerSimpleDelete(var Rec: Record "Tracking Specification")
    var
        CorrespondingSalesLine: Record "Sales Line";
        Index: Integer;
        InsertEntryNo: Integer;
        LineCountToGenerate: Integer;
        TotalNeededCount: Integer;
        ExistingRecCount: Integer;
    begin
        AutoAssignMode := true;

        // پاک‌سازی و بازنشانی مقادیر موقت
        TempTrackingSpecificationInsert.DeleteAll();
        TempTrackingSpecificationModify.DeleteAll();
        TempTrackingSpecificationDelete.DeleteAll();
        TempItemTrackLineInsert.DeleteAll();
        TempItemTrackLineModify.DeleteAll();
        TempItemTrackLineDelete.DeleteAll();

        // 1. محاسبه تعداد کلی مورد نیاز از Sales Line
        CorrespondingSalesLine := GetRelatedSalesLine();
        TotalNeededCount := CorrespondingSalesLine."Qty. to Ship";

        // 2. محاسبه تعداد فعلی رکوردهای موجود در Rec
        ExistingRecCount := 0;
        Rec.Reset();
        ExistingRecCount := Rec.Count();

        // 3. محاسبه تعداد رکوردهای جدید مورد نیاز
        LineCountToGenerate := TotalNeededCount - ExistingRecCount;

        // 4. رکوردهای موجود را در TempTrackingSpecificationModify قرار دهیم
        if Rec.FindSet() then
            repeat
                // افزودن به TempTrackingSpecificationModify
                TempTrackingSpecificationModify.Init();
                TempTrackingSpecificationModify.TransferFields(Rec);
                TempTrackingSpecificationModify.Insert();

                // افزودن به TempItemTrackLineModify
                TempItemTrackLineModify.Init();
                TempItemTrackLineModify.TransferFields(Rec);
                TempItemTrackLineModify.Insert();
            until Rec.Next() = 0;

        // 5. بررسی رکوردهای حذف شده
        // مقایسه رکوردهای اصلی (OriginalTrackingSpec) با رکوردهای فعلی (TempTrackingSpecificationModify)
        OriginalTrackingSpec.Reset();
        if OriginalTrackingSpec.FindSet() then
            repeat
                TempTrackingSpecificationModify.Reset();
                TempTrackingSpecificationModify.SetRange("Serial No.", OriginalTrackingSpec."Serial No.");
                if not TempTrackingSpecificationModify.FindFirst() then begin
                    // این رکورد در لیست فعلی نیست، پس حذف شده
                    TempTrackingSpecificationDelete.Init();
                    TempTrackingSpecificationDelete.TransferFields(OriginalTrackingSpec);
                    TempTrackingSpecificationDelete.Insert();

                    // به روز رسانی TempItemTrackLineDelete
                    TempItemTrackLineDelete.Init();
                    TempItemTrackLineDelete.TransferFields(OriginalTrackingSpec);
                    TempItemTrackLineDelete.Insert();
                end;
            until OriginalTrackingSpec.Next() = 0;

        // 6. پیدا کردن آخرین شماره Entry
        Rec.Reset();
        Rec.SetCurrentKey("Entry No.");
        if Rec.FindLast() then
            InsertEntryNo := Rec."Entry No."
        else
            InsertEntryNo := 0;

        // 7. ایجاد رکوردهای جدید مورد نیاز و افزودن به TempTrackingSpecificationInsert
        if LineCountToGenerate > 0 then begin
            for Index := 1 to LineCountToGenerate do begin
                // ایجاد یک رکورد جدید برای TempTrackingSpecificationInsert
                TempTrackingSpecificationInsert.Init();

                // کپی کردن مقادیر پایه از یک رکورد موجود یا xRec
                if Rec.FindFirst() then
                    TempTrackingSpecificationInsert.TransferFields(Rec)
                else
                    TempTrackingSpecificationInsert.TransferFields(xRec);

                // تنظیم مقادیر خاص برای رکورد جدید
                TempTrackingSpecificationInsert.Validate("Serial No.", GenerateRandomString(7));
                TempTrackingSpecificationInsert.Validate("Quantity (Base)", 1);
                InsertEntryNo += 1;
                TempTrackingSpecificationInsert.Validate("Entry No.", InsertEntryNo);
                TempTrackingSpecificationInsert.Insert();

                // افزودن رکورد جدید به Rec
                Rec := TempTrackingSpecificationInsert;
                Rec.Insert();

                // افزودن به TempItemTrackLineInsert
                TempItemTrackLineInsert.Init();
                TempItemTrackLineInsert.TransferFields(TempTrackingSpecificationInsert);
                TempItemTrackLineInsert.Insert();
            end;
        end;

        // 8. انتقال تغییرات به متغیرهای اصلی
        SetVariables(TempTrackingSpecificationInsert, TempTrackingSpecificationModify, TempTrackingSpecificationDelete);

        // 9. به‌روزرسانی صفحه
        CurrPage.Update(false);
    end;

    local procedure UpdateTrackingLineModify()
    var
        TempModify: Record "Tracking Specification" temporary;
        TempInitial: Record "Tracking Specification" temporary;
    begin
        // ابتدا کل رکوردهای اولیه را کپی می‌کنیم
        TempModify.DeleteAll();
        TempItemTrackLineInsert.Reset();
        if TempItemTrackLineInsert.FindSet() then
            repeat
                TempInitial.Init();
                TempInitial.TransferFields(TempItemTrackLineInsert);
                TempInitial.Insert();
            until TempItemTrackLineInsert.Next() = 0;

        // رکوردهای حذف شده را حذف می‌کنیم
        TempItemTrackLineDelete.Reset();
        if TempItemTrackLineDelete.FindSet() then
            repeat
                TempInitial.SetRange("Entry No.", TempItemTrackLineDelete."Entry No.");
                if TempInitial.FindFirst() then
                    TempInitial.Delete();
            until TempItemTrackLineDelete.Next() = 0;

        // نتیجه را در TempItemTrackLineModify قرار می‌دهیم
        TempItemTrackLineModify.DeleteAll();
        TempInitial.Reset();
        if TempInitial.FindSet() then
            repeat
                TempItemTrackLineModify.Init();
                TempItemTrackLineModify.TransferFields(TempInitial);
                TempItemTrackLineModify.Insert();
            until TempInitial.Next() = 0;

        // همچنین TempTrackingSpecificationModify را به روز می‌کنیم
        TempTrackingSpecificationModify.DeleteAll();
        TempItemTrackLineModify.Reset();
        if TempItemTrackLineModify.FindSet() then
            repeat
                TempTrackingSpecificationModify.Init();
                TempTrackingSpecificationModify.TransferFields(TempItemTrackLineModify);
                TempTrackingSpecificationModify.Insert();
            until TempItemTrackLineModify.Next() = 0;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        if (AutoAssignMode) then begin
            TempTrackingSpecificationInsert.SetRange("Serial No.", Rec."Serial No.");
            if (TempTrackingSpecificationInsert.FindFirst()) then begin
                TempTrackingSpecificationInsert.Delete();

                TempTrackingSpecificationDelete.Init();
                TempTrackingSpecificationDelete.TransferFields(Rec);
                TempTrackingSpecificationDelete.Insert();

                // به روز رسانی TempItemTrackLineDelete
                TempItemTrackLineDelete.Init();
                TempItemTrackLineDelete.TransferFields(Rec);
                TempItemTrackLineDelete.Insert();

                // به روز رسانی TempItemTrackLineModify
                UpdateTrackingLineModify();
            end;
        end;

        exit(true);
    end;

    trigger OnOpenPage()
    begin
        // فقط ذخیره دیتای اولیه Rec در OriginalTrackingSpec به عنوان مرجع اصلی
        OriginalTrackingSpec.DeleteAll();
        if Rec.FindSet() then
            repeat
                OriginalTrackingSpec.Init();
                OriginalTrackingSpec.TransferFields(Rec);
                OriginalTrackingSpec.Insert();
            until Rec.Next() = 0;
    end;

    local procedure GetRelatedSalesLine(): record "Sales Line"
    var
        SalesLine: record "Sales Line";
    begin
        Clear(SalesLine);
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange("Document No.", Rec."Source ID");
        SalesLine.SetRange("Line No.", Rec."Source Ref. No.");
        if SalesLine.FindFirst() then
            exit(SalesLine);

        Error(':((');
    end;

    procedure GenerateRandomString(Length: Integer) RandomString: Text
    var
        Characters: Text;
        i: Integer;
        RandomPos: Integer;
    begin
        Characters := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        RandomString := '';

        for i := 1 to Length do begin
            RandomPos := Random(StrLen(Characters)) + 1;
            RandomString += CopyStr(Characters, RandomPos, 1);
        end;
    end;

    var
        TempItemTrackLineInsert: Record "Tracking Specification" temporary;
        TempItemTrackLineModify: Record "Tracking Specification" temporary;
        TempItemTrackLineDelete: Record "Tracking Specification" temporary;
        TempTrackingSpecificationInsert: Record "Tracking Specification" temporary;
        TempTrackingSpecificationModify: Record "Tracking Specification" temporary;
        TempTrackingSpecificationDelete: Record "Tracking Specification" temporary;
        OriginalTrackingSpec: Record "Tracking Specification" temporary;
        AutoAssignMode: Boolean;
}