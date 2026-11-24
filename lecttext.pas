unit lecttext;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
  System.Classes,

  FMX.Types,
  FMX.Controls,
  FMX.Colors,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.StdCtrls,
  FMX.Ani,
  FMX.Spinbox,
  FMX.EditBox,
  FMX.ScrollBox,
  FMX.Controls.Presentation,

  aidekey,
  compile,
  constreg,
  graphker,
  regutil,
  images, FMX.Memo.Types, FMX.TMSFNCTypes, FMX.TMSFNCUtils, FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes, FMX.TMSFNCCustomControl, FMX.TMSFNCCustomPicker,
  FMX.TMSFNCColorPicker, FMX.TMSFNCColorSelector;


type
  TLectureTexteDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    PageControl: TTabControl;
    TexteTab: TTabItem;
    OptionsTab: TTabItem;
    Edit: TMemo;
    PageGB: TGroupBox;
    Label4: TLabel;
    Memo: TMemo;
    CadreCB: TCheckBox;
    LabelTaille: TLabel;
    SpinEditHauteur: TSpinBox;
    CouleurComboLabel: TLabel;
    ColorAnimation1: TColorAnimation;
    HelpBtn: TButton;
    LabelFond: TLabel;
    CouleurCombo: TTMSFNCColorPicker;
    opaqueColorBox: TTMSFNCColorPicker;
    procedure FormShow(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
    procedure CouleurComboColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure opaqueColorBoxColorSelected(Sender: TObject; AColor: TAlphaColor);
  private
    FTextColor: TAlphaColor;
    FFondColor: TAlphaColor;
    FPickerInitTextColor: TAlphaColor;
    FPickerInitFondColor: TAlphaColor;
    FTextColorChanged: Boolean;
    FFondColorChanged: Boolean;
    procedure SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
  public
    DessinLoc : TdessinText;
  end;

var
  LectureTexteDlg: TLectureTexteDlg;

implementation

uses AideU;

{$R *.FMX}

procedure TLectureTexteDlg.SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
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

procedure TLectureTexteDlg.CouleurComboColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FTextColor := AColor;
    FTextColorChanged := True;
  end;
end;

procedure TLectureTexteDlg.opaqueColorBoxColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FFondColor := AColor;
    FFondColorChanged := True;
  end;
end;

procedure TLectureTexteDlg.FormShow(Sender: TObject);
begin with dessinLoc do begin
     PageControl.ActiveTab := TexteTab;
     if texteBrut <> '' then
       Edit.text := texteBrut
     else
       Edit.text := text;
     Edit.SetFocus;
     PageGB.visible := (NbrePages>1);
     CadreCB.IsChecked  := avecCadre;
     FTextColor := color;
     if (FTextColor and $FF000000) = 0 then
       FTextColor := claBlack;
     FFondColor := couleurFond;
     if (FFondColor and $FF000000) = 0 then
       FFondColor := claWhite;
     FTextColorChanged := False;
     FFondColorChanged := False;
     SetPickerNearestColor(CouleurCombo, FTextColor);
     FPickerInitTextColor := CouleurCombo.selectedColor;
     spinEditHauteur.value := font.Size;
     SetPickerNearestColor(OpaqueColorBox, FFondColor);
     FPickerInitFondColor := OpaqueColorBox.selectedColor;
end end;

procedure TLectureTexteDlg.OKBtnClick(Sender: TObject);
begin with dessinLoc do begin
         if FTextColorChanged then
           color := FTextColor
         else if ((CouleurCombo.selectedColor and $FF000000) <> 0) and
                 (CouleurCombo.selectedColor <> FPickerInitTextColor) then
           color := CouleurCombo.selectedColor
         else if (FTextColor and $FF000000) <> 0 then
           color := FTextColor
         else if (CouleurCombo.selectedColor and $FF000000) <> 0 then
           color := CouleurCombo.selectedColor
         else
           color := claBlack;
         if FFondColorChanged then
           couleurFond := FFondColor
         else if ((OpaqueColorBox.selectedColor and $FF000000) <> 0) and
                 (OpaqueColorBox.selectedColor <> FPickerInitFondColor) then
           couleurFond := OpaqueColorBox.selectedColor
         else if (FFondColor and $FF000000) <> 0 then
           couleurFond := FFondColor
         else if (OpaqueColorBox.selectedColor and $FF000000) <> 0 then
           couleurFond := OpaqueColorBox.selectedColor
         else
           couleurFond := claWhite;
         text := Edit.text;
         texteBrut := Edit.text;
         avecCadre := CadreCB.isChecked;
         font.Size := spinEditHauteur.value;
end end;


procedure TLectureTexteDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
