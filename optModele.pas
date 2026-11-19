unit optModele;

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
  FMX.Colors,
  FMX.Objects,
  FMX.Menus,
  FMX.ExtCtrls,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Controls.Presentation,

  aidekey,
  compile,
  constreg,
  graphker,
  options,
  regutil,
  selpage,
  images;


type
  TOptionModeleDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    PageControl1: TTabControl;
    CalculTS: TTabItem;
    Chi2CB: TCheckBox;
    TabSheet1: TTabItem;
    AjusteOrigineCB: TCheckBox;
    EchelleModeleCB: TCheckBox;
    ExtrapoleModeleCB: TCheckBox;
    IncertitudeCB: TCheckBox;
    CouleurTS: TTabItem;
    Label5: TLabel;
    Label12: TLabel;
    Label6: TLabel;
    Label13: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    ColorComboBox1: TColorComboBox;
    ColorComboBox2: TColorComboBox;
    ColorComboBox3: TColorComboBox;
    ColorComboBox4: TColorComboBox;
    ColorComboBox5: TColorComboBox;
    ColorComboBox6: TColorComboBox;
    ColorComboBox7: TColorComboBox;
    ColorComboBox8: TColorComboBox;
    procedure OKBtnClick(Sender: TObject);
    procedure OptionsBtnClick(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
    DlgGraphique : TgrapheReg;
  end;

var
  OptionModeleDlg: TOptionModeleDlg;

implementation

uses optcolordlg;

{$R *.FMX}

procedure TOptionModeleDlg.FormShow(Sender: TObject);
var i,j : integer;
begin
  inherited;
     EchelleModeleCB.IsChecked  := OmEchelle in DlgGraphique.optionModele;
     ExtrapoleModeleCB.IsChecked  := OmExtrapole in DlgGraphique.optionModele;
     IncertitudeCB.IsChecked  := TraceEllipse;
     ajusteOrigineCB.IsChecked  := ajusteOrigine;
//     chi2CB.Visible := pages[pageCourante].chi2Permis;
     chi2CB.IsChecked  := traceEllipse and chi2CB.isVisible;
     with CouleurTS do
        for i := 0 to pred(childrenCount) do
           if children[i] is TcolorBox then begin
              j := TcolorBox(children[i]).tag;
              TcolorBox(children[i]).color := couleurModele[j];
           end;
end;

procedure TOptionModeleDlg.OKBtnClick(Sender: TObject);
begin
    if EchelleModeleCB.isChecked
        then include(DlgGraphique.OptionModele,OmEchelle)
        else exclude(DlgGraphique.OptionModele,OmEchelle);
    if ExtrapoleModeleCB.isChecked
        then include(DlgGraphique.OptionModele,OmExtrapole)
        else exclude(DlgGraphique.OptionModele,OmExtrapole);
    TraceEllipse := IncertitudeCB.isChecked;
    traceEllipse := chi2CB.isChecked;
    ajusteOrigine := ajusteOrigineCB.isChecked;
end;

procedure TOptionModeleDlg.OptionsBtnClick(Sender: TObject);
begin
   OptionCouleurDlg := TOptionCouleurDlg.create(self);
   OptionCouleurDlg.Graphe := nil;
   CentreForm(OptionCouleurDlg);
   OptionCouleurDlg.ShowModal;
   OptionCouleurDlg.free;
end;

procedure TOptionModeleDlg.ColorBox1Change(Sender: TObject);
begin
     with sender as TcolorBox do
        CouleurModele[tag] := color
end;

end.
