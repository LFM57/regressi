unit optcolordlg;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,

  FMX.StdCtrls,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.Colors,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Ani,
  FMX.Graphics,
  FMX.Spinbox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  FMX.TMSFNCTypes, FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomComponent, FMX.TMSFNCBitmapContainer,
  FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomPicker,
  FMX.TMSFNCStrokeKindPicker,
  FMX.TMSFNCFillKindPicker,
  FMX.TMSFNCStrokeKindSelector,
  FMX.TMSFNCFillKindSelector,
  FMX.TMSFNCAnalogTimePicker, FMX.TMSFNCCustomSelector,
  FMX.TMSFNCPanel,
  FMX.TMSFNCColorSelector,
  FMX.TMSFNCColorPicker, FMX.TMSFNCColorWheel,

  aidekey,
  compile,
  constreg,
  graphker,
  regutil,
  images,
  grapheVariabU;



type
  TOptionCouleurDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    PageControl1: TTabControl;
    PageTS: TTabItem;
    ModeleTS: TTabItem;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    CourbeTS: TTabItem;
    Label3: TLabel;
    ResetBtn: TButton;
    Label4: TLabel;
    CourbeSE: TSpinBox;
    LigneCombo: TComboBox;
    PointCombo: TComboBox;
    LigneComboBis: TComboBox;
    PointComboBis: TComboBox;
    TabSheet1: TTabItem;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    TangenteCB: TComboBox;
    ReticuleCB: TComboBox;
    PageSE: TSpinBox;
    Label1: TLabel;
    Label2: TLabel;
    LabelWidth: TLabel;
    WidthEcranSE: TSpinBox;
    GroupBox1: TGroupBox;
    Label11: TLabel;
    ReperePageGB: TGroupBox;
    TraitRB: TRadioButton;
    ColorAnimation1: TColorAnimation;
    ColorComboBox1: TColorComboBox;
    ColorComboBox2: TColorComboBox;
    ColorComboBox3: TColorComboBox;
    ColorComboBox4: TColorComboBox;
    ColorComboBox5: TColorComboBox;
    ColorComboBox6: TColorComboBox;
    ColorComboBox7: TColorComboBox;
    ColorComboBox8: TColorComboBox;
    ListBoxItem1: TListBoxItem;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    ListBoxItem8: TListBoxItem;
    ListBoxItem9: TListBoxItem;
    ListBoxItem10: TListBoxItem;
    ListBoxItem11: TListBoxItem;
    ListBoxItem12: TListBoxItem;
    ListBoxItem13: TListBoxItem;
    ListBoxItem14: TListBoxItem;
    ListBoxItem15: TListBoxItem;
    ListBoxItem16: TListBoxItem;
    Cercle: TListBoxItem;
    ListBoxItem18: TListBoxItem;
    Losange: TListBoxItem;
    ListBoxItem20: TListBoxItem;
    MotifRB: TRadioButton;
    CouleurRB: TRadioButton;
    CouleurComboPage: TTMSFNCColorPicker;
    CouleurComboCourbe: TTMSFNCColorPicker;
    CouleurTangente: TTMSFNCColorPicker;
    ReticuleColor: TTMSFNCColorPicker;
    FondReticuleColor: TTMSFNCColorPicker;
    FondColor: TTMSFNCColorPicker;
    GrilleColor: TTMSFNCColorPicker;
    procedure FormActivate(Sender: TObject);
    procedure SetModif(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure PointComboChange(Sender: TObject);
    procedure LigneComboChange(Sender: TObject);
    procedure CouleurComboClick(Sender: TObject);
    procedure ResetBtnClick(Sender: TObject);
    procedure PointComboBisChange(Sender: TObject);
    procedure LigneComboBisChange(Sender: TObject);
    procedure CouleurComboBisClick(Sender: TObject);
    procedure CourbeSEClick(Sender: TObject);
    procedure PageSEChange(Sender: TObject);
    procedure ColorModeleChange(Sender: TObject);
    procedure CouleurComboPageColorSelected(Sender: TObject;
      AColor: TAlphaColor);
    procedure CouleurComboCourbeColorSelected(Sender: TObject;
      AColor: TAlphaColor);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
    Graphe : TgrapheReg;
    Modification : boolean;
  end;

var
  OptionCouleurDlg: TOptionCouleurDlg;

implementation

{$R *.FMX}

uses regMain, AideU;

procedure TOptionCouleurDlg.FormActivate(Sender: TObject);

procedure AffecteCouleur(abox : TcolorComboBox);
begin
     abox.color := CouleurModele[abox.tag];
end;

var i : integer;
    abox : TcolorComboBox;
begin
     inherited;
     PageSE.Min := 1;
     PageSE.Max := MaxPages;
     CourbeSE.Min := 1;
     CourbeSE.Max := MaxOrdonnee;
     if CourbeSE.Value < 1 then CourbeSE.Value := 1;
     if CourbeSE.Value > MaxOrdonnee then CourbeSE.Value := MaxOrdonnee;
     CouleurTangente.selectedColor := graphker.CouleurTangente;
     TangenteCB.itemIndex := ord(styleTangente);
     ReticuleColor.selectedColor := CouleurReticule;
     FondReticuleColor.selectedColor := FondReticule;
     FondColor.selectedColor := CouleurTexte;
     ReticuleCB.itemIndex := ord(PstyleReticule);
     widthEcranSE.value := penWidthEcran;
     GrilleColor.selectedColor := couleurGrille;
     Modification := false;
     traitRB.IsChecked := reperePage=spStyle;
     motifRB.IsChecked := reperePage=spMotif;
     couleurRB.IsChecked := reperePage=spCouleur;
     for i := 0 to pred(ComponentCount) do
         if Components[i] is TcolorComboBox
            then begin
               abox := Components[i] as TcolorComboBox;
               abox.color := CouleurModele[abox.tag];
            end;
     PageSEChange(Sender);
     CourbeSEClick(Sender);
end;

procedure TOptionCouleurDlg.SetModif(Sender: TObject);
begin
     Modification := true
end;

procedure TOptionCouleurDlg.OKBtnClick(Sender: TObject);
var c : integer;
begin
    CouleurGrille := GrilleColor.selectedColor;
    graphker.CouleurTangente := CouleurTangente.selectedColor;
    CouleurReticule := ReticuleColor.selectedColor;
    FondReticule := FondReticuleColor.selectedColor;
    CouleurTexte := FondColor.selectedColor;
    if ReticuleCB.itemIndex>=0 then
       PstyleReticule := TStrokeDash(ReticuleCB.itemIndex);
    penWidthEcran:= widthEcranSE.value;
    if traitRB.ischecked then reperePage := spStyle;
    if couleurRB.ischecked then reperePage := spcouleur;
    if motifRB.ischecked then reperePage := spmotif;
    if graphe<>nil then with graphe do begin
        for c := 1 to MaxOrdonnee do with coordonnee[c] do begin
           couleur := couleurInit[c];
           styleT := PstyleInit[c];
           motif := motifInit[c];
        end;
//        if paintBox.isVisible then setCoordonnee;
    end;
end;

procedure TOptionCouleurDlg.PointComboChange(Sender: TObject);
begin
     MotifPages[round(PageSE.value)] := Tmotif(PointCombo.itemIndex)
end;

procedure TOptionCouleurDlg.LigneComboChange(Sender: TObject);
begin
     PstylePages[round(PageSE.value)] := TStrokeDash(LigneCombo.itemIndex)
end;

procedure TOptionCouleurDlg.CouleurComboClick(Sender: TObject);
begin
     CouleurPages[round(PageSE.value)] := CouleurComboPage.selectedColor
end;

procedure TOptionCouleurDlg.CouleurComboCourbeColorSelected(Sender: TObject;
  AColor: TAlphaColor);
begin
     CouleurInit[round(CourbeSE.value)] := CouleurComboCourbe.selectedColor;
     if Graphe<>nil then
        Graphe.coordonnee[round(CourbeSE.value)].couleur := CouleurComboCourbe.selectedColor;
     Modification := true;
end;

procedure TOptionCouleurDlg.CouleurComboPageColorSelected(Sender: TObject;
  AColor: TAlphaColor);
begin
    CouleurPages[round(PageSE.value)] := CouleurComboPage.selectedColor
end;

procedure TOptionCouleurDlg.ResetBtnClick(Sender: TObject);
var i,j : integer;
begin
     for i := 0 to pred(NbreCouleur) do begin
         j := (i mod 4) +1;
         CouleurPages[i] := couleurInit[j];
         MotifPages[i] := motifInit[j];
         PstylePages[i] := PstyleInit[j];
     end;
end;

procedure TOptionCouleurDlg.ColorModeleChange(Sender: TObject);
begin
    with sender as TcolorComboBox do
         CouleurModele[tag] := color
end;

procedure TOptionCouleurDlg.PointComboBisChange(Sender: TObject);
begin
     MotifInit[round(CourbeSE.value)] := Tmotif(PointComboBis.itemIndex);
     if Graphe<>nil then
        Graphe.coordonnee[round(CourbeSE.value)].motif := Tmotif(PointComboBis.itemIndex);
     Modification := true;
end;

procedure TOptionCouleurDlg.LigneComboBisChange(Sender: TObject);
begin
     PstyleInit[round(CourbeSE.value)] := TStrokeDash(LigneComboBis.itemIndex);
     if Graphe<>nil then
        Graphe.coordonnee[round(CourbeSE.value)].styleT := TStrokeDash(LigneComboBis.itemIndex);
     Modification := true;
end;

procedure TOptionCouleurDlg.CouleurComboBisClick(Sender: TObject);
begin
     CouleurInit[round(CourbeSE.value)] := CouleurComboCourbe.selectedColor;
     if Graphe<>nil then
        Graphe.coordonnee[round(CourbeSE.value)].couleur := CouleurComboCourbe.selectedColor;
     Modification := true;
end;

procedure TOptionCouleurDlg.CourbeSEClick(Sender: TObject);
var index : integer;
begin
     index := round(CourbeSE.value);
     if index < 1 then index := 1;
     if index > MaxOrdonnee then index := MaxOrdonnee;
     CouleurComboCourbe.selectedColor := couleurInit[index];
     LigneComboBis.itemIndex := ord(PstyleInit[index]);
     PointComboBis.itemIndex := ord(motifInit[index]);
end;

procedure TOptionCouleurDlg.PageSEChange(Sender: TObject);
var index : integer;
begin
     index := round(PageSE.value);
     CouleurComboPage.selectedColor := couleurPages[index];
     LigneCombo.itemIndex := ord(PstylePages[index]);
     PointCombo.itemIndex := ord(motifPages[index]);
end;


procedure TOptionCouleurDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
