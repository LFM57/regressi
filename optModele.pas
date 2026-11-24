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
  FMX.EditBox,
  FMX.Spinbox,

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
    IntersectionCB: TCheckBox;
    Label1: TLabel;
    NbreMCSE: TSpinBox;
    procedure OKBtnClick(Sender: TObject);
    procedure OptionsBtnClick(Sender: TObject);
    procedure ColorBox1Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
    DlgGraphique : TgrapheReg;
  end;

var
  OptionModeleDlg: TOptionModeleDlg;

implementation

uses optcolordlg, AideU;

{$R *.FMX}

procedure TOptionModeleDlg.FormActivate(Sender: TObject);
begin
     NbreMCSE.Value := NbreMC;
end;

procedure TOptionModeleDlg.FormShow(Sender: TObject);
var i,j : integer;
begin
  inherited;
     EchelleModeleCB.IsChecked  := OmEchelle in DlgGraphique.optionModele;
     ExtrapoleModeleCB.IsChecked  := OmExtrapole in DlgGraphique.optionModele;
     ajusteOrigineCB.IsChecked  := ajusteOrigine;
//     chi2CB.Visible := pages[pageCourante].chi2Permis;
     chi2CB.IsChecked  := traceEllipse;
     IntersectionCB.IsChecked := traceIntersection;
     NbreMCSE.Value := NbreMC;
     for i := 0 to pred(ComponentCount) do
        if Components[i] is TColorComboBox then begin
           j := TColorComboBox(Components[i]).tag;
           TColorComboBox(Components[i]).Color := couleurModele[j];
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
    traceEllipse := chi2CB.isChecked;
    traceIntersection := IntersectionCB.isChecked;
    ajusteOrigine := ajusteOrigineCB.isChecked;
    NbreMC := round(NbreMCSE.Value);
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
     if sender is TColorComboBox then
        with sender as TColorComboBox do
           CouleurModele[tag] := Color
end;


procedure TOptionModeleDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
