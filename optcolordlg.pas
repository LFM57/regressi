unit optcolordlg;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
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
    procedure FormShow(Sender: TObject);
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
    procedure GrilleColorColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure CouleurTangenteColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure ReticuleColorColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure FondReticuleColorColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure FondColorColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure HelpBtnClick(Sender: TObject);
  private
    FGrilleColor, FTangenteColor, FReticuleColor, FFondReticuleColor, FTexteColor: TAlphaColor;
    FPickerInitGrille, FPickerInitTangente, FPickerInitReticule, FPickerInitFondReticule, FPickerInitTexte: TAlphaColor;
    FGrilleChanged, FTangenteChanged, FReticuleChanged, FFondReticuleChanged, FTexteChanged: Boolean;
    procedure SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
    function ResolvePickerColor(APicker: TTMSFNCColorPicker; AInitial, APickerInit: TAlphaColor;
      AChanged: Boolean; AFallback: TAlphaColor): TAlphaColor;
  public
    Graphe : TgrapheReg;
    Modification : boolean;
  end;

var
  OptionCouleurDlg: TOptionCouleurDlg;

implementation

{$R *.FMX}

uses regMain, AideU;

procedure TOptionCouleurDlg.SetPickerNearestColor(APicker: TTMSFNCColorPicker; AColor: TAlphaColor);
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

function TOptionCouleurDlg.ResolvePickerColor(APicker: TTMSFNCColorPicker; AInitial, APickerInit: TAlphaColor;
  AChanged: Boolean; AFallback: TAlphaColor): TAlphaColor;
begin
  if AChanged and ((AInitial and $FF000000) <> 0) then
    Result := AInitial
  else if ((APicker.SelectedColor and $FF000000) <> 0) and (APicker.SelectedColor <> APickerInit) then
    Result := APicker.SelectedColor
  else if (AInitial and $FF000000) <> 0 then
    Result := AInitial
  else if (APicker.SelectedColor and $FF000000) <> 0 then
    Result := APicker.SelectedColor
  else
    Result := AFallback;
end;

procedure TOptionCouleurDlg.GrilleColorColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FGrilleColor := AColor;
    FGrilleChanged := True;
  end;
end;

procedure TOptionCouleurDlg.CouleurTangenteColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FTangenteColor := AColor;
    FTangenteChanged := True;
  end;
end;

procedure TOptionCouleurDlg.ReticuleColorColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FReticuleColor := AColor;
    FReticuleChanged := True;
  end;
end;

procedure TOptionCouleurDlg.FondReticuleColorColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FFondReticuleColor := AColor;
    FFondReticuleChanged := True;
  end;
end;

procedure TOptionCouleurDlg.FondColorColorSelected(Sender: TObject; AColor: TAlphaColor);
begin
  if (AColor and $FF000000) <> 0 then begin
    FTexteColor := AColor;
    FTexteChanged := True;
  end;
end;

procedure TOptionCouleurDlg.FormShow(Sender: TObject);

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
     FTangenteColor := graphker.CouleurTangente;
     if (FTangenteColor and $FF000000) = 0 then FTangenteColor := claRed;
     FReticuleColor := CouleurReticule;
     if (FReticuleColor and $FF000000) = 0 then FReticuleColor := claBlack;
     FFondReticuleColor := FondReticule;
     if (FFondReticuleColor and $FF000000) = 0 then FFondReticuleColor := claYellow;
     FTexteColor := CouleurTexte;
     if (FTexteColor and $FF000000) = 0 then FTexteColor := claBlue;
     FGrilleColor := couleurGrille;
     if (FGrilleColor and $FF000000) = 0 then FGrilleColor := claSilver;
     FGrilleChanged := False;
     FTangenteChanged := False;
     FReticuleChanged := False;
     FFondReticuleChanged := False;
     FTexteChanged := False;
     SetPickerNearestColor(CouleurTangente, FTangenteColor);
     FPickerInitTangente := CouleurTangente.selectedColor;
     TangenteCB.itemIndex := ord(styleTangente);
     SetPickerNearestColor(ReticuleColor, FReticuleColor);
     FPickerInitReticule := ReticuleColor.selectedColor;
     SetPickerNearestColor(FondReticuleColor, FFondReticuleColor);
     FPickerInitFondReticule := FondReticuleColor.selectedColor;
     SetPickerNearestColor(FondColor, FTexteColor);
     FPickerInitTexte := FondColor.selectedColor;
     ReticuleCB.itemIndex := ord(PstyleReticule);
     widthEcranSE.value := penWidthEcran;
     SetPickerNearestColor(GrilleColor, FGrilleColor);
     FPickerInitGrille := GrilleColor.selectedColor;
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
    CouleurGrille := ResolvePickerColor(GrilleColor, FGrilleColor, FPickerInitGrille, FGrilleChanged, claSilver);
    graphker.CouleurTangente := ResolvePickerColor(CouleurTangente, FTangenteColor, FPickerInitTangente, FTangenteChanged, claRed);
    CouleurReticule := ResolvePickerColor(ReticuleColor, FReticuleColor, FPickerInitReticule, FReticuleChanged, claBlack);
    FondReticule := ResolvePickerColor(FondReticuleColor, FFondReticuleColor, FPickerInitFondReticule, FFondReticuleChanged, claYellow);
    CouleurTexte := ResolvePickerColor(FondColor, FTexteColor, FPickerInitTexte, FTexteChanged, claBlue);
    if ReticuleCB.itemIndex>=0 then
       PstyleReticule := TStrokeDash(ReticuleCB.itemIndex);
    if TangenteCB.itemIndex>=0 then
       styleTangente := TStrokeDash(TangenteCB.itemIndex);
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
var index: Integer;
begin
     if (CouleurComboPage.selectedColor and $FF000000) = 0 then Exit;
     index := round(PageSE.value);
     if (index >= 0) and (index <= MaxPages) then
       CouleurPages[index] := CouleurComboPage.selectedColor;
end;

procedure TOptionCouleurDlg.CouleurComboCourbeColorSelected(Sender: TObject;
  AColor: TAlphaColor);
var index: Integer;
begin
     if (AColor and $FF000000) = 0 then Exit;
     index := round(CourbeSE.value);
     if (index < 1) or (index > MaxOrdonnee) then Exit;
     CouleurInit[index] := AColor;
     if Graphe<>nil then
        Graphe.coordonnee[index].couleur := AColor;
     Modification := true;
end;

procedure TOptionCouleurDlg.CouleurComboPageColorSelected(Sender: TObject;
  AColor: TAlphaColor);
var index: Integer;
begin
    if (AColor and $FF000000) = 0 then Exit;
    index := round(PageSE.value);
    if (index >= 0) and (index <= MaxPages) then
      CouleurPages[index] := AColor;
end;

procedure TOptionCouleurDlg.ResetBtnClick(Sender: TObject);
var i,j : integer;
begin
     for i := 0 to MaxPages do begin
         j := (i mod 4) +1;
         CouleurPages[i] := couleurInit[j];
         MotifPages[i] := motifInit[j];
         PstylePages[i] := PstyleInit[j];
     end;
     PageSEChange(Sender);
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
var index: Integer;
begin
     if (CouleurComboCourbe.selectedColor and $FF000000) = 0 then Exit;
     index := round(CourbeSE.value);
     if (index < 1) or (index > MaxOrdonnee) then Exit;
     CouleurInit[index] := CouleurComboCourbe.selectedColor;
     if Graphe<>nil then
        Graphe.coordonnee[index].couleur := CouleurComboCourbe.selectedColor;
     Modification := true;
end;

procedure TOptionCouleurDlg.CourbeSEClick(Sender: TObject);
var index : integer;
begin
     index := round(CourbeSE.value);
     if index < 1 then index := 1;
     if index > MaxOrdonnee then index := MaxOrdonnee;
     SetPickerNearestColor(CouleurComboCourbe, couleurInit[index]);
     LigneComboBis.itemIndex := ord(PstyleInit[index]);
     PointComboBis.itemIndex := ord(motifInit[index]);
end;

procedure TOptionCouleurDlg.PageSEChange(Sender: TObject);
var index : integer;
begin
     index := round(PageSE.value);
     if index < 0 then index := 0;
     if index > MaxPages then index := MaxPages;
     SetPickerNearestColor(CouleurComboPage, couleurPages[index]);
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
