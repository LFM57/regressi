unit options;

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
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.Colors,
  FMX.ExtCtrls,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Graphics,
  FMX.Spinbox,
  FMX.ScrollBox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  aidekey,
  compile,
  constreg,
  coordphys,
  graphker,
  maths,
  regutil,
  uniteker,
  images, FMX.Memo.Types;

type
  TOptionsDlg = class(TForm)
    PageControl: TTabControl;
    CalculTS: TTabItem;
    Panel1: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    LissageLabel: TLabel;
    OrdreFiltrageSE: TSpinBox;
    Label1: TLabel;
    TabSheet4: TTabItem;
    GrilleCB: TCheckBox;
    IncertitudeCB: TCheckBox;
    Label11: TLabel;
    Label17: TLabel;
    OrdreSplineSE: TSpinBox;
    DimPointSE: TSpinBox;
    OptionsBtn: TButton;
    GraduationZeroCB: TCheckBox;
    GraduationPiCB: TCheckBox;
    Memo1: TMemo;
    ExtrapoleDerCB: TCheckBox;
    WidthEcranSE: TSpinBox;
    LabelWidth: TLabel;
    UniteParCB: TCheckBox;
    NbrePointsDerSB: TSpinBox;
    CoeffEllipseRG: TGroupBox;
    sigmaRB: TRadioButton;
    e95RB: TRadioButton;
    e99RB: TRadioButton;
    ChiffresSignifSE: TSpinBox;
    Label3: TLabel;
    CSVTS: TTabItem;
    ValeursSeulesCB: TCheckBox;
    VraiCSVCB: TCheckBox;
    LigneCombo: TComboBox;
    ReticuleCB: TCheckBox;
    Label2: TLabel;
    procedure NbreSpinButtonDownClick(Sender: TObject);
    procedure NbreSpinButtonUpClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure NbreEditChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure OptionsBtnClick(Sender: TObject);
    procedure ModifGrapheClick(Sender: TObject);
    procedure SpinEditHauteurChange(Sender: TObject);
    procedure sigmaRBChange(Sender: TObject);
    procedure e95RBChange(Sender: TObject);
    procedure e99RBChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    Procedure EcritConfig;
  public
    modifDerivee,modifGraphe : boolean;
    Procedure LitConfig;
  end;

var
  OptionsDlg: TOptionsDlg;

implementation

uses Regmain, fft, optcolordlg;

{$R *.FMX}

procedure TOptionsDlg.NbreSpinButtonDownClick(Sender: TObject);
begin
     if NbrePointDerivee>MinPointsDerivee then begin
        dec(NbrePointDerivee,2);
        ModifDerivee := true;
     end;
end;

procedure TOptionsDlg.NbreSpinButtonUpClick(Sender: TObject);
begin
     if NbrePointDerivee<MaxPointsDerivee then begin
        inc(NbrePointDerivee,2);
        ModifDerivee := true;
     end;
end;

procedure TOptionsDlg.FormActivate(Sender: TObject);
begin
       inherited;
       widthEcranSE.value := penWidthEcran;
       uniteParCB.IsChecked  := UniteParenthese;
       ExtrapoleDerCB.IsChecked  := ExtrapoleDerivee;
       GraduationPiCB.IsChecked  := GraduationPi;
       GrilleCB.IsChecked  := OgQuadrillage in OptionGrapheDefault;
       OrdreSplineSE.Value := OrdreLissage;
       OrdreFiltrageSE.Value := OrdreFiltrage;
       DimPointSE.Value := DimPointVGA;
       IncertitudeCB.IsChecked  := TraceEllipse;
       NbrePointsDerSB.Value := NbrePointDerivee;
       ModifDerivee := false;
       ModifGraphe := false;
       ChiffresSignifSE.value := precision;
       if coeffEllipse<1.1
          then sigmaRB.isChecked := true
          else if coeffEllipse<2
              then e95RB.ischecked := true
              else e99RB.isChecked := true;
       GraduationZeroCB.IsChecked  := OgZeroGradue in optionGrapheDefault;
       ReticuleCB.IsChecked := withReticule;
       if ord(PstyleReticule) < LigneCombo.Items.Count then
          LigneCombo.itemIndex := ord(PstyleReticule);
       VraiCSVCB.IsChecked := oCSV_vrai;
       ValeursSeulesCB.IsChecked := oCSV_valeursSeules;
end;

procedure TOptionsDlg.OKBtnClick(Sender: TObject);

{$IFNDEF store}
procedure SauveOptions;
var Rini : TIniFile;
begin
    Rini := TIniFile.create(registreReg);
    try
    Rini.WriteInteger('PenStyle','Reticule',ord(PstyleReticule));
    Rini.WriteInteger('Color','Reticule',colorToInt(couleurReticule));
    Rini.WriteInteger('Color','FondReticule',colorToInt(FondReticule));
    Rini.writeInteger('Dérivée','Nombre',NbrePointDerivee);
    Rini.writeBool('Dérivée','Extrapole',ExtrapoleDerivee);
    Rini.writeInteger('Calcul','OrdreFiltrage',OrdreFiltrage);
    Rini.writeBool('Calcul','Cosinus',ModeleCosinus);
    Rini.writeInteger('Point','Taille',dimPointVGA);
    Rini.writeInteger('Color','Axe',colorToInt(couleurGrille));
    Rini.writeInteger('Dérivée','Degré',DegreDerivee);
    Rini.writeInteger('Graphe','ReperePage',ord(reperePage));
    Rini.writeInteger('Format','Chiffres',Precision);
    Rini.writeBool('Graphe','ZeroGradue',OgZeroGradue in OptionGrapheDefault);
    Rini.writeBool('FFT','Optimise',NbreHarmoniqueOptimise);
    Rini.writeBool('Graphe','Ellipse',TraceEllipse);
    Rini.writeBool('Graphe','Intersection',TraceIntersection);
    Rini.WriteBool('Regressi','AjusteAutoLin',true);
    Rini.WriteBool('Regressi','DataTrie',DataTrieGlb);
    Rini.WriteBool('Regressi','UnitePar',UniteParenthese);
    Rini.WriteBool('Regressi','GraduationPi',GraduationPi);
    Rini.WriteInteger('Graphe','CoeffEllipse',round(CoeffEllipse));
    Rini.WriteBool('Calcul','Degre',AngleEnDegre);
    Rini.WriteBool('Calcul','Decibel',ModeleDecibel);
    Rini.WriteBool('Calcul','Qualite',ModeleFacteurQualite);
    Rini.writeBool('Calcul','Cosinus',ModeleCosinus);
    Rini.writeInteger('Graphe','WidthEcran',round(penWidthEcran));
    Rini.DeleteKey('Impression','Bold');
    Rini.WriteBool('CSV','Vrai',oCSV_vrai);
    Rini.WriteBool('CSV','Valeurs',oCSV_valeursSeules);
    finally
    Rini.free;
    end;
end;
{$ENDIF}

begin // OKBtnClick
     UniteParenthese := uniteParCB.ischecked;
     FichierTrie := DataTrieGlb;
     oCSV_vrai := VraiCSVCB.isChecked;
     oCSV_valeursSeules := ValeursSeulesCB.isChecked;
     if GraduationZeroCB.ischecked
        then include(optionGrapheDefault,OgZeroGradue)
        else exclude(optionGrapheDefault,OgZeroGradue);
     penWidthEcran := widthEcranSE.value;
     TraceEllipse := IncertitudeCB.ischecked;
     DimPointVGA := round(DimPointSE.value);
     ModifDerivee := ModifDerivee or (ExtrapoleDerivee<>ExtrapoleDerCB.IsChecked) or
                     (NbrePointDerivee<>round(NbrePointsDerSB.Value));
     NbrePointDerivee := round(NbrePointsDerSB.Value);
     ExtrapoleDerivee := ExtrapoleDerCB.ischecked;
     if GrilleCB.ischecked
         then include(OptionGrapheDefault,OgQuadrillage)
         else exclude(OptionGrapheDefault,OgQuadrillage);
     GraduationPi := GraduationPiCB.ischecked;
     precision := round(chiffresSignifSE.value);
     OrdreLissage := round(OrdreSplineSE.Value);
     OrdreFiltrage := round(OrdreFiltrageSE.Value);
     if sigmaRB.isChecked then coeffEllipse := 1; // 68 %
     if e95RB.IsChecked then coeffEllipse := 1.96; // 95 %
     if e99RB.isChecked then coeffEllipse := 2.58; // 99 %
     if LigneCombo.itemIndex >= 0 then
        PstyleReticule := TStrokeDash(LigneCombo.itemIndex);
     withReticule := ReticuleCB.isChecked;
     {$IFNDEF store}
     SauveOptions;
     {$ENDIF}
end;// OKBtnClick

procedure TOptionsDlg.NbreEditChange(Sender: TObject);
begin
     ModifDerivee := true
end;

procedure TOptionsDlg.FormCreate(Sender: TObject);
begin
{$IFNDEF store}
    litConfig;
{$ENDIF}
end;

procedure TOptionsDlg.FormDestroy(Sender: TObject);
begin
{$IFNDEF store}
    ecritConfig;
{$ENDIF}
end;

procedure TOptionsDlg.OptionsBtnClick(Sender: TObject);
begin
   OptionCouleurDlg := TOptionCouleurDlg.create(self);
   OptionCouleurDlg.Graphe := nil;
   CentreForm(OptionCouleurDlg);
   OptionCouleurDlg.ShowModal;
   OptionCouleurDlg.free;
   ModifGraphe := true;
end;

procedure TOptionsDlg.ModifGrapheClick(Sender: TObject);
begin
    ModifGraphe := true;
end;

procedure TOptionsDlg.LitConfig;
var Rini : TIniFile;
    i : integer;

procedure litOptionGr(Ident : string;Aopt : ToptionGraphe);
begin
  if Rini.readBool('Graphe',Ident,Aopt in OptionGrapheDefault) then
     include(OptionGrapheDefault,Aopt);
end;

begin
{$IFDEF store}
exit;
{$ENDIF}
  try
  Rini := TIniFile.Create(registreReg);
  try
  ModeleCosinus := Rini.ReadBool('Calcul','Cosinus',ModeleCosinus);
  PstyleReticule := TStrokeDash(Rini.ReadInteger('PenStyle','Reticule',0));
  LitColor(Rini,'Reticule',CouleurReticule);
  couleurFoncee(CouleurReticule);
  LitColor(Rini,'FondReticule',FondReticule);
  couleurClaire(FondReticule);
  OrdreFiltrage := Rini.ReadInteger('Calcul','OrdreFiltrage',OrdreFiltrage);
  CoeffEllipse := Rini.ReadInteger('Graphe','CoeffEllipse',1);
  if coeffEllipse=2 then coeffEllipse := 1.96; // 95 %
  if coeffEllipse=3 then coeffEllipse := 2.58; // 99 %
  GraduationZeroCB.IsChecked  := Rini.ReadBool('Graphe','ZeroGradue',ogZeroGradue in OptionGrapheDefault);
  if GraduationZeroCB.IsChecked  then
     include(OptionGrapheDefault,ogZeroGradue);
  AngleEnDegre := Rini.ReadBool('Calcul','Degre',true);
  ModeleDecibel := Rini.ReadBool('Calcul','Decibel',false);
  ModeleFacteurQualite := Rini.ReadBool('Calcul','Qualite',true);
  ExtrapoleDerivee := Rini.ReadBool('Dérivée','Extrapole',true);
  NbreHarmoniqueOptimise := Rini.ReadBool('FFT','Optimise',false);
  DimPointVGA := Rini.ReadInteger('Point','Taille',4);
  DataTrieGlb := Rini.ReadBool('Regressi','DataTrie',false);
  UniteParenthese := Rini.ReadBool('Regressi','UnitePar',UniteParenthese);
  penWidthEcran := Rini.readInteger('Graphe','WidthEcran',2);
  Precision := Rini.ReadInteger('Format','Chiffres',4);
  NbrePointDerivee := Rini.ReadInteger('Dérivée','Nombre',5);
  GraduationPi := Rini.ReadBool('Regressi','GraduationPi',true);
  TraceEllipse := Rini.ReadBool('Graphe','Ellipse',false);
  TraceIntersection := Rini.ReadBool('Graphe','Intersection',false);
  oCSV_vrai := Rini.ReadBool('CSV','Vrai',true);
  oCSV_valeursSeules := Rini.ReadBool('CSV','Valeurs',false);
  reperePage := TreperePage(Rini.ReadInteger('graphe','ReperePage',ord(reperePage)));
  for i := 0 to pred(MaxPagesGr) do begin
      litColor(Rini,'C'+IntToStr(i),couleurPages[i]);
      PstylePages[i] := TStrokeDash(Rini.ReadInteger('PenStyle','C'+IntToStr(i),ord(PstylePages[i])));
      MotifPages[i] := Tmotif(Rini.ReadInteger('PointStyle','C'+IntToStr(i),ord(MotifPages[i])));
  end;
  litColor(Rini,'Vitesse',couleurMecanique[1]);
  litColor(Rini,'Acceleration',couleurMecanique[2]);
  CouleurVitesseImposee := Rini.ReadBool('Color','VitesseImposee',true);
  LitColor(Rini,'Grille',couleurGrille);
  LitColor(Rini,'Texte',couleurTexte);
  LitColor(Rini,'Ligne',couleurLigne);
  Rini.ReadInteger('Graphe','ZoneVirage',1);
  for i := 1 to MaxOrdonnee do begin
      litColor(Rini,'O'+IntToStr(i),couleurInit[i]);
      PstyleInit[i] := TStrokeDash(Rini.ReadInteger('PenStyle','O'+IntToStr(i),ord(PstyleInit[i])));
      MotifInit[i] := Tmotif(Rini.ReadInteger('PointStyle','O'+IntToStr(i),ord(MotifInit[i])));
  end;
  for i := 1 to MaxIntervalles do begin
      litColor(Rini,'M'+IntToStr(i),couleurModele[i]);
      litColor(Rini,'S'+IntToStr(i),couleurModele[-i]);
  end;
  LigneRappelTangente := TligneRappel(Rini.ReadInteger('Graphe','Tangente',0));
  avecOptionsXY := Rini.ReadBool('Graphe','OptionsXY',avecOptionsXY);
  NbreHarmoniqueAff := Rini.ReadInteger('FFT','NbreHarmAff',NbreHarmoniqueAff);
  LitOptionGr('Grille',OgQuadrillage);
  LitOptionGr('ZeroIdem',OgMemeZero);
  Rini.ReadBool('Sauvegarde','Arecuperer',true);
  FreqMaxSonagramme := Rini.ReadInteger('FFT','FreqSonMax',5000);
  dateVerifVersion := Rini.readDateTime('VerifVersion','Date',now);
  finally
  Rini.Free;
  end;
  except
  end;
end; // litConfig

procedure TOptionsDlg.sigmaRBChange(Sender: TObject);
begin
    if sigmaRB.IsChecked then coeffEllipse := 1; // 68 %
end;

procedure TOptionsDlg.e95RBChange(Sender: TObject);
begin
    if e95RB.IsChecked then coeffEllipse := 1.96; // 95 %
end;

procedure TOptionsDlg.e99RBChange(Sender: TObject);
begin
    if e99RB.IsChecked then coeffEllipse := 2.58; // 99 %
end;

procedure TOptionsDlg.SpinEditHauteurChange(Sender: TObject);
begin
  modifGraphe := true;
end;

Procedure TOptionsDlg.EcritConfig;
var i : integer;
    Rini : TIniFile;
begin
    Rini := TIniFile.create(registreReg);
    try
    with RIni do begin
    for i := 0 to pred(MaxPagesGr) do begin
        WriteInteger('Color','C'+IntToStr(i),ColorToInt(couleurPages[i]));
        WriteInteger('PenStyle','C'+IntToStr(i),ord(PstylePages[i]));
        WriteInteger('PointStyle','C'+IntToStr(i),ord(MotifPages[i]));
    end;
    WriteDateTime('VerifVersion','Date',dateVerifVersion);
    WriteInteger('Color','Reticule',ColorToInt(couleurReticule));
    WriteInteger('Color','FondReticule',ColorToInt(FondReticule));
    WriteInteger('Color','Grille',ColorToInt(couleurGrille));
    WriteInteger('Color','Texte',ColorToInt(couleurTexte));
    WriteInteger('Color','Ligne',ColorToInt(couleurLigne));
    WriteInteger('Color','Vitesse',ColorToInt(couleurMecanique[1]));
    WriteInteger('Color','Acceleration',ColorToInt(couleurMecanique[2]));
    WriteBool('Color','VitesseImposee',CouleurVitesseImposee);
    WriteInteger('Color','Axe',ColorToInt(couleurGrille));
    WriteInteger('Color','Texte',ColorToInt(couleurTexte));
    WriteInteger('Color','Ligne',ColorToInt(couleurLigne));
    for i := 1 to MaxOrdonnee do begin
        WriteInteger('Color','O'+IntToStr(i),ColorToInt(couleurInit[i]));
        WriteInteger('PenStyle','O'+IntToStr(i),ord(PstyleInit[i]));
        WriteInteger('PointStyle','O'+IntToStr(i),ord(MotifInit[i]));
    end;
    for i := 1 to MaxIntervalles do begin
        WriteInteger('Color','M'+IntToStr(i),ColorToInt(couleurModele[i]));
        WriteInteger('Color','S'+IntToStr(i),ColorToInt(couleurModele[-i]));
    end;
    WriteInteger('Color','FondMarque',ColorToInt(FondReticule));
    WriteInteger('Graphe','Tangente',ord(LigneRappelTangente));
    writeBool('Graphe','OptionsXY',avecOptionsXY);
    writeBool('Graphe','Grille',OgQuadrillage in OptionGrapheDefault);
    writeBool('Graphe','ZeroIdem',OgMemeZero in OptionGrapheDefault);
    writeBool('Graphe','ZeroGradue',OgZeroGradue in OptionGrapheDefault);
    writeInteger('FFT','Fenetre',ord(fenetre));
    writeInteger('FFT','PasSonAff',round(PasTempsSonagramme*1000));
    writeInteger('FFT','PasSonCalcul',round(PasSonCalcul*1000)); // en ms
    writeInteger('FFT','FreqSonMax',round(FreqMaxSonagramme));
    writeInteger('FFT','NbreHarmAff',NbreHarmoniqueAff);
    WriteBool('Sauvegarde','Arecuperer',false);
    end;
    finally
    Rini.free;
    end;
end; // EcritConfig

end.


