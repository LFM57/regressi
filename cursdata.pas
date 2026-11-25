unit cursdata;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
  System.Classes,
  System.IniFiles,

  FMX.Types,
  FMX.Controls,
  FMX.Colors,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.StdCtrls,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Graphics,
  FMX.Controls.Presentation,

  aidekey,
  compile,
  graphker,
  regutil,
  images,
  
  FMX.TMSFNCTypes,
  FMX.TMSFNCUtils, FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomControl, FMX.TMSFNCCustomPicker,
  FMX.TMSFNCColorPicker, FMX.TMSFNCColorSelector;

type
  TReticuleDataDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    GroupBox1: TGroupBox;
    YCB: TCheckBox;
    XCB: TCheckBox;
    DeltaXCB: TCheckBox;
    ReticuleCB: TCheckBox;
    deltaYCB: TCheckBox;
    LigneCombo: TComboBox;
    DeuxCurseursCB: TCheckBox;
    ReticuleColor: TTMSFNCColorPicker;
    penteCB: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure DeuxCurseursCBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ReticuleColorColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure HelpBtnClick(Sender: TObject);
  private
    FReticuleColor: TAlphaColor;
    FPickerInitColor: TAlphaColor;
    FColorChanged: Boolean;
    procedure SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
  public
     Agraphe : TgrapheReg;
  end;

var
  ReticuleDataDlg: TReticuleDataDlg;

implementation

uses AideU;

{$R *.FMX}

procedure TReticuleDataDlg.FormCreate(Sender: TObject);
var Rini : TIniFile;
begin
    Rini := TIniFile.create(registreReg);
    try
      deuxCurseursCB.isChecked := Rini.ReadBool('Reticule','Double',false);
    finally
    Rini.free;
    end;
end;

procedure TReticuleDataDlg.FormDestroy(Sender: TObject);
var Rini : TIniFile;
begin
     Rini := TIniFile.create(registreReg);
     try
       Rini.WriteBool('Reticule','Double',deuxCurseursCB.isChecked);
     finally
     Rini.free;
     end;
     inherited
end;

procedure TReticuleDataDlg.SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
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

procedure TReticuleDataDlg.ReticuleColorColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FReticuleColor := AColor;
    FColorChanged := True;
  end;
end;

procedure TReticuleDataDlg.FormShow(Sender: TObject);
begin with Agraphe do begin
    ReticuleCB.IsChecked  := CurseurOsc[1].Complet;
    FReticuleColor := couleurReticule;
    if (FReticuleColor and $FF000000) = 0 then
      FReticuleColor := claBlack;
    FColorChanged := False;
    SetPickerNearestColor(ReticuleColor, FReticuleColor);
    FPickerInitColor := ReticuleColor.selectedColor;
    LigneCombo.itemIndex := ord(PstyleReticule);
    deltaXCB.IsChecked  := coDeltaX in optionCurseur;
    deltaYCB.IsChecked  := coDeltaY in optionCurseur;
    penteCB.IsChecked  := coPente in optionCurseur;
    XCB.IsChecked  := coX in optionCurseur;
    YCB.IsChecked  := coY in optionCurseur;
    DeuxCurseursCBClick(nil);
end end;

procedure TReticuleDataDlg.OKBtnClick(Sender: TObject);
begin with Agraphe do begin
      PstyleReticule := TStrokeDash(LigneCombo.itemIndex);
      if FColorChanged then
        couleurReticule := FReticuleColor
      else if ((ReticuleColor.selectedColor and $FF000000) <> 0) and
              (ReticuleColor.selectedColor <> FPickerInitColor) then
        couleurReticule := ReticuleColor.selectedColor
      else if (FReticuleColor and $FF000000) <> 0 then
        couleurReticule := FReticuleColor
      else if (ReticuleColor.selectedColor and $FF000000) <> 0 then
        couleurReticule := ReticuleColor.selectedColor
      else
        couleurReticule := claBlack;
      optionCurseur := [];
      if XCB.IsChecked then include(optionCurseur,coX);
      if YCB.IsChecked then include(optionCurseur,coY);
      if deltaXCB.IsChecked and DeuxCurseursCB.IsChecked then include(optionCurseur,coDeltaX);
      if penteCB.IsChecked and DeuxCurseursCB.IsChecked then include(optionCurseur,coPente);
      if deltaYCB.IsChecked  and DeuxCurseursCB.IsChecked then include(optionCurseur,coDeltaY);
      CurseurOsc[1].Complet := ReticuleCB.isChecked;
      CurseurOsc[2].Complet := ReticuleCB.isChecked;
      CurseurOsc[1].visible := true;
      CurseurOsc[2].visible := DeuxCurseursCB.IsChecked;
      CurseurOsc[1].isData := true;
      CurseurOsc[2].isData := true;
      CurseurOsc[1].indexCourbe := -1;
      CurseurOsc[2].indexCourbe := -1;
      CurseurOsc[1].stroke.dash := PstyleReticule;
      CurseurOsc[2].stroke.dash := PstyleReticule;
end end;

procedure TReticuleDataDlg.DeuxCurseursCBClick(Sender: TObject);
begin
      deltaXCB.Visible := DeuxCurseursCB.isChecked;
      deltaYCB.Visible := DeuxCurseursCB.isChecked;
      penteCB.Visible := DeuxCurseursCB.isChecked;
end;


procedure TReticuleDataDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
