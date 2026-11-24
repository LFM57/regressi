unit lecttext;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
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
  FMX.TMSFNCColorPicker;


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
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
    DessinLoc : TdessinText;
  end;

var
  LectureTexteDlg: TLectureTexteDlg;

implementation

uses AideU;

{$R *.FMX}

procedure TLectureTexteDlg.FormActivate(Sender: TObject);
begin with dessinLoc do begin
     PageControl.ActiveTab := TexteTab;
     Edit.text := text;
     Edit.SetFocus;
     PageGB.visible := (NbrePages>1);
     CadreCB.IsChecked  := avecCadre;
     CouleurCombo.selectedColor := color;
     spinEditHauteur.value := font.Size;
     OpaqueColorBox.selectedColor := couleurFond;
end end;

procedure TLectureTexteDlg.OKBtnClick(Sender: TObject);
begin with dessinLoc do begin
         color := CouleurCombo.selectedColor;
         couleurFond := OpaqueColorBox.selectedColor;
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
