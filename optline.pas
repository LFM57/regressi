unit optline;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
  System.Classes,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.Colors,
  FMX.StdCtrls,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Graphics,
  FMX.Spinbox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  compile,
  Constreg,
  graphker,
  maths,
  regutil,
  selpage,
  uniteKer,
  images, 
  FMX.TMSFNCTypes,
  FMX.TMSFNCUtils, FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes, FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomPicker,
  FMX.TMSFNCColorPicker,
  FMX.TMSFNCColorSelector;


type
  TOptionLigneDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    PenBar: TPanel;
    LabelTaille: TLabel;
    LigneCombo: TComboBox;
    SpinEditWidth: TSpinBox;
    GroupBox3: TGroupBox;
    SansRB: TRadioButton;
    DoubleFlecheRB: TRadioButton;
    Fleche1RB: TRadioButton;
    OptionsRG: TListBox;
    GroupBox4: TGroupBox;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    CouleurCombo: TTMSFNCColorPicker;
    Fleche2RB: TRadioButton;
    procedure OKBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CouleurComboColorSelected(Sender: TObject; AColor: TAlphaColor);
  private
    FStrokeColor: TAlphaColor;
    FPickerInitColor: TAlphaColor;
    FColorChanged: Boolean;
    procedure SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
  public
    DessinLoc : TdessinLine;
  end;

var
  OptionLigneDlg: TOptionLigneDlg;

implementation

{$R *.FMX}

procedure TOptionLigneDlg.SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
var
  i, bestIdx: Integer;
  targetRec, itemRec: TAlphaColorRec;
  dist, bestDist, dr, dg, db: Integer;
begin
  APicker.SelectedColor := AColor;
  if (APicker.SelectedColor and $FF000000) <> 0 then
    Exit;
  if APicker.Items.Count = 0 then
    Exit;
  targetRec := TAlphaColorRec(AColor);
  bestIdx := 0;
  bestDist := MaxInt;
  for i := 0 to APicker.Items.Count - 1 do begin
    itemRec := TAlphaColorRec(APicker.Items[i].Color);
    dr := Integer(targetRec.R) - Integer(itemRec.R);
    dg := Integer(targetRec.G) - Integer(itemRec.G);
    db := Integer(targetRec.B) - Integer(itemRec.B);
    dist := dr * dr + dg * dg + db * db;
    if dist < bestDist then begin
      bestDist := dist;
      bestIdx := i;
    end;
  end;
  APicker.SelectedItemIndex := bestIdx;
end;

procedure TOptionLigneDlg.CouleurComboColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FStrokeColor := AColor;
    FColorChanged := True;
  end;
end;

procedure TOptionLigneDlg.FormShow(Sender: TObject);
begin with dessinLoc do begin
        FStrokeColor := stroke.color;
        if (FStrokeColor and $FF000000) = 0 then
          FStrokeColor := claBlue;
        FColorChanged := False;
        SetPickerNearestColor(CouleurCombo, FStrokeColor);
        FPickerInitColor := CouleurCombo.selectedColor;
        LigneCombo.itemIndex := ord(DashLigne);
        SpinEditWidth.Value := stroke.thickness;
        optionsRG.ItemIndex := ord(TexteLigne);
        case motifLigne of
            mlNone : sansRB.isChecked := true;
            mlFlecheDebut : fleche1RB.isChecked := true;
            mlDoubleFleche : doubleFlecheRB.isChecked := true;
            mlFlecheFin : fleche2RB.isChecked := true;
        end;
end end;

procedure TOptionLigneDlg.OKBtnClick(Sender: TObject);
begin with DessinLoc do begin
       if FColorChanged then
         stroke.color := FStrokeColor
       else if ((CouleurCombo.selectedColor and $FF000000) <> 0) and
               (CouleurCombo.selectedColor <> FPickerInitColor) then
         stroke.color := CouleurCombo.selectedColor
       else if (FStrokeColor and $FF000000) <> 0 then
         stroke.color := FStrokeColor
       else if (CouleurCombo.selectedColor and $FF000000) <> 0 then
         stroke.color := CouleurCombo.selectedColor
       else
         stroke.color := claBlue;
       stroke.thickness := SpinEditWidth.Value;
       DashLigne := TStrokeDash(LigneCombo.itemIndex);
       stroke.Dash := TStrokeDash(LigneCombo.itemIndex);
       if sansRB.isChecked then motifLigne := mlNone;
       if fleche1RB.isChecked then motifLigne := mlFlecheDebut;
       if fleche2RB.isChecked then motifLigne := mlFlecheFin;
       if doubleFlecheRB.isChecked then motifLigne := mlDoubleFleche;
       texteLigne := TTexteLigne(optionsRG.itemIndex)
end end;


end.
