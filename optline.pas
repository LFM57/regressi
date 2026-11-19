unit optline;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
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
  FMX.TMSFNCColorPicker;


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
  private
  public
    DessinLoc : TdessinLine;
  end;

var
  OptionLigneDlg: TOptionLigneDlg;

implementation

{$R *.FMX}

procedure TOptionLigneDlg.FormShow(Sender: TObject);
begin with dessinLoc do begin
        CouleurCombo.selectedColor := stroke.color;
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
       stroke.color := CouleurCombo.selectedColor;
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
