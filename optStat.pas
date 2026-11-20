unit optStat;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.UIConsts,
  System.Math,

  FMX.Types,
  FMX.Controls,
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
  FMX.Spinbox,
  FMX.ScrollBox,
  FMX.EditBox,
  FMX.Printer,
  FMX.Controls.Presentation,

  maths,
  aideKey,
  compile,
  constreg,
  regUtil,
  graphker,
  statCalc,
  images, FMX.Memo.Types;

type
  TStatOptDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    NombreSpin: TSpinBox;
    LabelNombre: TLabel;
    LabelAmplitude: TLabel;
    EditAmplitude: TEdit;
    EditCible: TEdit;
    CibleCB: TCheckBox;
    NomGroupe: TGroupBox;
    LabelDebut: TLabel;
    EditDebut: TEdit;
    GrapheGB: TGroupBox;
    int2SigmaCB: TCheckBox;
    int3SigmaCB: TCheckBox;
    t95CB: TCheckBox;
    t99CB: TCheckBox;
    CourbeGaussCB: TCheckBox;
    DistributionCB: TCheckBox;
    MedianeCB: TCheckBox;
    MoyenneCB: TCheckBox;
    CourbePoissonCB: TCheckBox;
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    EffectifGB: TGroupBox;
    EffectifCB: TComboBox;
    GrilleCB: TCheckBox;
    CourbeBinomeCB: TCheckBox;
    Int1SigmaCB: TCheckBox;
    ClasseGroupe: TListBox;
    ListeGr: TListBox;
    procedure ClasseGroupeClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CibleCBClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
     PoissonPermis : boolean;
     FrequenceGr : Tgrandeur;
     procedure resetListe;
  public
     FrequenceGrDefault : Tgrandeur;
     NomStat,NomEffectif,erreurStat : string;
     procedure Imprimer;
     procedure ImprimerGraphe(var bas : single);
     procedure ecritConfig;
     procedure litConfig;
     Procedure SetCoordonnee;
  end;

var
  StatOptDlg: TStatOptDlg;

implementation

{$R *.FMX}

uses regMain, modif, AideU;

const
      largeurNombreEntier = 50;
      largeurNombreReel = 70;
      largeurTitre = 95;

procedure TStatOptDlg.CibleCBClick(Sender: TObject);
begin
     EditCible.Visible := cibleCB.isChecked;
end;

procedure TStatOptDlg.ClasseGroupeClick(Sender: TObject);
begin
     ResetListe;
end;

procedure TStatOptDlg.FormCreate(Sender: TObject);
begin
   exclude(FRegressiMain.grapheStat.OptionGraphe,OgQuadrillage);
   FregressiMain.GrapheStat.monde[mondeX].zeroInclus := false;
   FrequenceGrDefault := Tgrandeur.create;
   FrequenceGrDefault.Init('N','','',variable);
   ClasseGroupe.ItemIndex := 0;
   NomStat := '';
   NomEffectif := '';
   indexStat := 1;
end;

procedure TStatOptDlg.FormDestroy(Sender: TObject);
begin
     FrequenceGrDefault.free;
end;

procedure TStatOptDlg.FormShow(Sender: TObject);
var i : integer;
begin
     inherited;
     EffectifCB.Items.Clear;
     ListeGr.Items.Clear;
     for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
         if genreG=variable then begin
            EffectifCB.Items.add(nom);
            ListeGr.Items.add(grandeurs[i].nom);
         end;
     listeGr.itemIndex := listeGr.items.indexOf(NomStat);
     if listeGr.itemIndex<0 then listeGr.itemIndex := 1;
     EffectifCB.itemIndex := effectifCB.items.indexOf(NomEffectif);
     if EffectifCB.itemIndex<0 then effectifCB.itemIndex := 0;
     EditAmplitude.text := FormatReg(statCourante.ecartDist);
     EditDebut.text :=  FormatReg(statCourante.debutDist);
     EditCible.text := FormatReg(statCourante.cible);
     ClasseGroupe.OnChange := nil;
     ClasseGroupe.itemIndex := ord(statCourante.classeStat);
     ClasseGroupe.OnChange := ClasseGroupeClick;
     NombreSpin.Value := statCourante.NbreClasse;
     CourbePoissonCB.visible := PoissonPermis;
     CourbeBinomeCB.visible := PoissonPermis;
     GrilleCB.IsChecked  := OgQuadrillage in FRegressiMain.grapheStat.optionGraphe;
     if not PoissonPermis then begin
          CourbePoissonCB.IsChecked  := false;
          CourbeBinomeCB.IsChecked  := false;
     end;
     resetListe;
end;

procedure TStatOptDlg.ResetListe;
begin
     EditCible.Visible := cibleCB.isChecked;
     LabelNombre.Visible := false;
     LabelAmplitude.Visible := false;
     EditAmplitude.Visible := false;
     LabelDebut.Visible := false;
     EditDebut.Visible := false;
     NombreSpin.Visible := false;
     EffectifGB.Visible := false;
     case ClasseGroupe.ItemIndex of
          0 : ;
          1 : begin
             NombreSpin.Visible := true;
             LabelNombre.Visible := true;
          end;
          2 : begin
             LabelAmplitude.Visible := true;
             EditAmplitude.Visible := true;
             LabelDebut.Visible := true;
             EditDebut.Visible := true;
          end;
          3 : begin
             EffectifGB.Visible := true;
             EffectifGB.Text  := 'Effectif';
          end;
          4 : begin
             EffectifGB.Visible := true;
             EffectifGB.Text  := 'Fréquence';
          end;
     end;
end;

procedure TStatOptDlg.OKBtnClick(Sender: TObject);
begin
     statCourante := pages[pageCourante].stat;
     if listeGr.itemIndex<0 then listeGr.itemIndex := 1;
     NomStat := listeGr.items[listeGr.itemIndex];
     if effectifCB.itemIndex<0 then effectifCB.itemIndex := 0;     
     NomEffectif := EffectifCB.items[effectifCB.itemIndex];
     if GrilleCB.ischecked
             then include(FRegressiMain.grapheStat.OptionGraphe,OgQuadrillage)
             else exclude(FRegressiMain.grapheStat.OptionGraphe,OgQuadrillage);
     indexStat := indexNom(nomStat);
     indexEffectif := indexNom(nomEffectif);
     statCourante.classeStat := TclasseStat(ClasseGroupe.itemIndex);
     if (grandeurs[indexStat].genreG<>variable) and
            (statCourante.classeStat in [csEffectifDonne,csFrequenceDonnee]) then begin
               if indexEffectif=indexVariab[1]
                  then indexStat := indexVariab[0]
                  else indexStat := indexVariab[1];
     end;
     case statCourante.classeStat of
              csNombreImpose : statCourante.NbreClasse := round(NombreSpin.Value);
              csEcartImpose : begin
                 try
                 statCourante.ecartDist := getFloat(EditAmplitude.text);
                 except end;
                 try
                 statCourante.debutDist := getFloat(EditDebut.text);
                 except end;
              end;
     end;
     if CibleCB.ischecked
            then begin
               try
               statCourante.cible := getFloat(EditCible.text)
               except end;
            end
            else statCourante.cible := Nan;
end;

procedure TStatOptDlg.ImprimerGraphe(var bas : single);
begin
    FRegressiMain.grapheStat.versImprimante(bas)
end;

procedure TStatOptDlg.Imprimer;
var bas : single;
begin
       if OKReg(OkImprGr,0) then begin
          try
          beginPrintGr(bas);
          FRegressiMain.GrapheStat.versImprimante(bas);
          if OKReg(OkImprTab,0) then begin
             BeginPrintTxt(bas);
             PrintLine(stStatistique+caption,bas);
             PrintGrid(FRegressiMain.StatGrid,bas);
             PrintGrid(FRegressiMain.DistGrid,bas);
          end;
          Printer.endDoc;
          except

          end;
      end;
end;

Procedure TstatOptDlg.ecritConfig;
begin
   ecritSousSection(1,'X');
   ecritLigneRW3(nomStat);
   ecritSousSection(1,'Y');
   ecritLigneRW3(nomEffectif);
   ecritSousSection(5,'Options');
   ecritIntegerRW3(ord(courbeGaussCB.IsChecked));
   ecritIntegerRW3(ord(distributionCB.IsChecked));
   ecritIntegerRW3(ord(classeGroupe.itemIndex));
   ecritIntegerRW3(ord(courbePoissonCB.IsChecked));
   ecritIntegerRW3(ord(courbeBinomeCB.IsChecked));
end;

Procedure TstatOptDlg.litConfig;
var i,imax : integer;
begin
   while (Length(LigneWin)>0) and (ligneWin[1]=symbReg2) do begin
   imax := NbreLigneWin(ligneWin);
   if pos('X',ligneWin)<>0
      then nomStat := litLigneWinU
      else if pos('Y',ligneWin)<>0
      then nomEffectif := litLigneWinU
      else if pos('Options',ligneWin)<>0
          then begin
               courbeGaussCB.IsChecked  := litBooleanWin;
               if imax>1 then
                   distributionCB.IsChecked  := litBooleanWin;
               if imax>2 then begin
                   litLigneWin;
                   ClasseGroupe.ItemIndex := strToInt(ligneWin);
               end;
               if imax>3 then
                   CourbePoissonCB.IsChecked  := litBooleanWin;
               if imax>4 then
                   CourbeBinomeCB.IsChecked  := litBooleanWin;
               for i := 6 to imax do litLigneWin;
          end
          else for i := 1 to imax do litLigneWin;
   litLigneWin;
end end;


procedure TstatOptDlg.SetCoordonnee;
var Ylegende : single;
    deltaYlegende : single;

Procedure AjouteLegende(xLegende : double;const t : string;Couleur : TAlphaColor);
var Dessin : TdessinText;
begin
      if (xlegende<FRegressiMain.grapheStat.monde[mondeX].mini) or
         (xlegende>FRegressiMain.grapheStat.monde[mondeX].maxi) then exit;
      Dessin := TdessinText.createText(FRegressiMain.grapheStat);
      with Dessin do begin
         text := text+' '+t+' ';
         color := couleur;
         couleurFond := claWhite;
         Agraphe := FRegressiMain.grapheStat;
      end;
      FRegressiMain.GrapheStat.dessinTexts.add(Dessin);
end;

Procedure SetHistogramme;
// Tracé de l'histogramme de la variable aléatoire

procedure SetCourbeGauss;
Const Nth = 30;
      yth : array[0..Nth] of double =
        (0.0022,0.003,0.004,0.00525,0.00675,
         0.00875,0.0112,0.01415,0.01775,0.022,
         0.027,0.0328,0.0395,0.047,0.05545,
         0.06475,0.07485,0.0857,0.0971,0.10895,
         0.121,0.13305,0.14485,0.15615,0.1666,
         0.17605,0.18415,0.1907,0.1955,0.1985,
         0.19945);
var x,y : vecteur;
    i : integer;
    h,echelle : double;
    Acourbe : Tcourbe;
begin with statCourante do begin
// comparaison avec la loi normale
     setLength(x,2*Nth+1);
     setLength(y,2*Nth+1);
     h := sigma/10;
     for i := 0 to 2*Nth do x[i] := moyenne+(i-Nth)*h;
     echelle := Ntotal*2*EcartDist/Sigma;
     for i := 0 to Nth do begin
        y[i] := yth[i]*echelle;
        y[2*Nth-i] := y[i];
     end;
     Acourbe := FRegressiMain.GrapheStat.AjouteCourbe(x,y,mondeY,succ(2*Nth),
         grandeurs[indexStat],frequenceGr,pageCourante);
     if (min>0) and (x[0]<0) then begin
        Acourbe.DebutC := ceil(Nth-moyenne/h);
     end;
     Acourbe.setStyle(couleurInit[3],TStrokeDash.Solid,mCroix);
     Acourbe.Adetruire := true;
     Acourbe.trace := [trLigne];
end end;

procedure SetCourbePoisson;
var x,y : vecteur;
    i,Nth : integer;
    echelle,maxPoisson : double;
    Acourbe : Tcourbe;
begin with FRegressiMain.grapheStat,statCourante do begin
// comparaison avec la loi de Poisson
     Nth := round(moyenne)*2;
     if Nth<max then Nth := round(max);
     setlength(x,2*Nth);setlength(y,2*Nth);
     for i := 0 to pred(Nth) do x[i] := i;
     echelle := Ntotal*EcartDist;
     maxPoisson := 0;
     for i := 0 to Nth do begin
         y[i] := poisson(i,moyenne)*echelle;
         if y[i]>maxPoisson then maxPoisson := y[i];
     end;
     Acourbe := AjouteCourbe(x,y,mondeY,Nth,grandeurs[indexStat],nil,pageCourante);
     Acourbe.Adetruire := true;
     Acourbe.trace := [trPoint];
//     Acourbe.motif := mBarreG;
     Acourbe.motif := mHisto;
     Acourbe.courbeExp := false;
     Acourbe.indexModele := 1;
     Acourbe.couleur := couleurInit[2];
     monde[mondeX].mini := 0;
     if monde[mondeX].maxi<Nth then
        monde[mondeX].maxi := Nth;
     if monde[mondeY].maxi<MaxPoisson then
        monde[mondeY].maxi := MaxPoisson*1.05;
     AjouteLegende(monde[mondeX].maxi/10,'Poisson',Acourbe.couleur);
end end;

procedure SetCourbeBinomiale;
var x,y : vecteur;
    i,Nth : integer;
    echelle : double;
    Acourbe : Tcourbe;
begin with statCourante do begin
// comparaison avec la loi binomiale
     Nth := round(moyenne)*2;
     if Nth<max then Nth := round(max);
     setlength(x,2*Nth);setlength(y,2*Nth);
     for i := 0 to pred(Nth) do x[i] := i;
     echelle := Ntotal*EcartDist;
     for i := 0 to Nth do
         y[i] := Binomial(moyenne,Ntotal,i)*echelle;
     Acourbe := FRegressiMain.GrapheStat.AjouteCourbe(x,y,mondeY,Nth,grandeurs[indexStat],nil,pageCourante);
     Acourbe.Adetruire := true;
     Acourbe.trace := [trPoint];
     Acourbe.motif := mBarreD;
     Acourbe.couleur := couleurInit[3];
     FRegressiMain.GrapheStat.monde[mondeX].mini := 0;
     if FRegressiMain.GrapheStat.monde[mondeX].maxi<Nth then FRegressiMain.GrapheStat.monde[mondeX].maxi := Nth;
     AjouteLegende(FRegressiMain.GrapheStat.monde[mondeX].maxi/10,'Binomiale',Acourbe.couleur); { TODO : traduction 1 }
end end;

procedure SetPoints;
var x,y : vecteur;
    i : integer;
    Acourbe : Tcourbe;
begin with statCourante do begin
     setlength(x,Nbre);
     setLength(y,Nbre);
     for i := 0 to pred(Nbre) do begin
         x[i] := donnees[i];
         y[i] := 0;
     end;
     Acourbe := FRegressiMain.GrapheStat.AjouteCourbe(x,y,mondeY,Nbre,
         grandeurs[indexStat],frequenceGr,pageCourante);
     Acourbe.setStyle(couleurInit[1],TStrokeDash.Solid,mCroix);
     Acourbe.Adetruire := true;
     Acourbe.trace := [trPoint];
end end;

procedure setCourbe;
var Acourbe : Tcourbe;
    idebut,ifin : integer;
begin with FRegressiMain.grapheStat,statCourante do begin
    idebut := 1;
    while NbreDist[iDebut]=0 do inc(iDebut);
    iFin := MaxHisto;
    while NbreDist[iFin]=0 do dec(iFin);
// histogramme de la distribution experimentale
    Acourbe := AjouteCourbe(BornesDist,NbreDist,mondeY,iFin,
        grandeurs[indexStat],frequenceGr,pageCourante);
    monde[mondeX].mini := BornesDist[iDebut-1]-sigma/3;
    monde[mondeX].maxi := BornesDist[iFin]+sigma/3;
    monde[mondeY].mini := 0;
    monde[mondeY].maxi := maxDist*1.05;
    Acourbe.setStyle(couleurInit[1],TStrokeDash.Solid,mCroix);
    if classeStat in [csEffectifDonne,csFrequenceDonnee]
       then begin
          Acourbe.DebutC := 0;
          Acourbe.FinC := pred(Nbre);
          Acourbe.trace := [trPoint];
          Acourbe.motif := mHisto;
       end
       else begin
          Acourbe.DebutC := pred(iDebut);
          Acourbe.FinC := iFin;
          Acourbe.trace := [trStat];
       end;
    if DistributionCB.IsChecked  then begin // distribution
       Acourbe := AjouteCourbe(MoyDist,NbreDist,mondeY,iFin,
           grandeurs[indexStat],frequenceGr,pageCourante);
       Acourbe.setStyle(couleurInit[2],TStrokeDash.Solid,mCroix);
       Acourbe.DebutC := iDebut;
       Acourbe.FinC := iFin;
       Acourbe.trace := [trLigne];
    end;
end end;  // setCourbe

Procedure AjouteLigneVert(x : double;Couleur : TAlphaColor);
var Dessin : TdessinLine;
begin
   if (x<FRegressiMain.grapheStat.monde[mondeX].mini) or
      (x>FRegressiMain.grapheStat.monde[mondeX].maxi) then exit;
   Dessin := TdessinLine.createLine(FRegressiMain.grapheStat);
   with Dessin do begin
        position.y := yLegende;
        position.X := FRegressiMain.grapheStat.WindowX(x);
        Stroke.Dash := TStrokeDash.Solid;
        stroke.color := couleur;
        Agraphe := FRegressiMain.grapheStat;
   end;
   FRegressiMain.GrapheStat.dessinLines.add(Dessin);
end;

Procedure AjouteDeuxLignes(marge : double;const text : string;
    couleur : TAlphaColor);
begin
      AjouteLigneVert(statCourante.moyenne-marge,couleur);
      AjouteLigneVert(statCourante.moyenne+marge,couleur);
      AjouteLegende(statCourante.moyenne-marge*1.2,'m-'+text,couleur);
      AjouteLegende(statCourante.moyenne+marge*1.2,'m+'+text,couleur);
      yLegende := yLegende + deltayLegende;
end;

Procedure AjouteLigne(valeur : double;const text : string;couleur : TAlphaColor);
begin
      AjouteLigneVert(valeur,couleur);
      AjouteLegende(valeur,text,couleur);
      yLegende := yLegende + deltayLegende;
end;

begin // SetHistogramme
with FRegressiMain.grapheStat,statCourante do begin
   if not(classeStat in [csEffectifDonne,csFrequenceDonnee]) then setPoints;
   setCourbe;
   deltayLegende := paintBox.height/100;
   yLegende := paintBox.height-deltayLegende;
   if MoyenneCB.IsChecked  then
      AjouteLigne(moyenne,stMoyenne+' '+
            grandeurs[indexStat].FormatValeurEtUnite(moyenne),
            claBlue);
   if MedianeCB.IsChecked  then
      AjouteLigne(mediane,stMediane+' '+
            grandeurs[indexStat].FormatValeurEtUnite(mediane),
            claRed);
   if not isNan(cible) then
      AjouteLigne(cible,stCible+' '+
            grandeurs[indexStat].FormatValeurEtUnite(cible),claGreen);
   if CourbeGaussCB.IsChecked  then setCourbeGauss;
   if CourbePoissonCB.IsChecked  then setCourbePoisson;
   if CourbeBinomeCB.IsChecked  then setCourbeBinomiale;
   if t95CB.IsChecked  then
       AjouteDeuxLignes(t95,'µ95',claBlue);
   if t99CB.IsChecked  then
       AjouteDeuxLignes(t99,'µ99',claRed);
   if int2SigmaCB.IsChecked  then
       AjouteDeuxLignes(2*sigma,'2'+sigmaMin,claBlue);
   if int3SigmaCB.IsChecked  then
       AjouteDeuxLignes(3*sigma,'3'+sigmaMin,claRed);
   if int1SigmaCB.IsChecked  then
       AjouteDeuxLignes(sigma,sigmaMin,claGreen);
end end; // SetHistogramme

Procedure AfficheStat;
begin with statCourante,grandeurs[indexStat] do begin
    FRegressiMain.StatGrid.beginUpdate;
    if isNan(cible)
       then FRegressiMain.StatGrid.rowCount := 9
       else FRegressiMain.StatGrid.rowCount := 13;
    FRegressiMain.panelStatGrid.height := FRegressiMain.StatGrid.rowCount*FRegressiMain.StatGrid.DefaultRowHeight+4;
    FRegressiMain.StatGrid.ColumnWidths[0] := LargeurTitre;
    FRegressiMain.StatGrid.ColumnWidths[1] := LargeurNombreReel;
    FRegressiMain.StatGrid.width := largeurTitre+LargeurNombreReel+2;
    if (classeStat in [csEffectifDonne,csFrequenceDonnee])
       then begin
            FRegressiMain.StatGrid.cells[0,0] := '';
            FRegressiMain.StatGrid.cells[1,0] := '';
       end
       else begin
            FRegressiMain.StatGrid.cells[0,0] := stTaille;
            FRegressiMain.StatGrid.cells[1,0] := IntToStr(Ntotal);
       end;
    FRegressiMain.StatGrid.cells[0,1] := stEtendue+'mini';
    FRegressiMain.StatGrid.cells[1,1] := formatValeurEtUnite(min);
    FRegressiMain.StatGrid.cells[0,2] := stEtendue+'maxi';
    FRegressiMain.StatGrid.cells[1,2] := formatValeurEtUnite(max);
    if (classeStat in [csEffectifDonne,csFrequenceDonnee])
       then begin
          FRegressiMain.StatGrid.cells[0,3] := '';
          FRegressiMain.StatGrid.cells[1,3] := '';
       end
       else begin
          FRegressiMain.StatGrid.cells[0,3] := stMediane;
          FRegressiMain.StatGrid.cells[1,3] := formatValeurEtUnite(mediane);
       end;
    FRegressiMain.StatGrid.cells[0,4] := stMoyenne;
    FRegressiMain.StatGrid.cells[1,4] := formatValeurEtUnite(moyenne);
    if classeStat=csFrequenceDonnee then begin
        FRegressiMain.StatGrid.cells[0,5] := '';
        FRegressiMain.StatGrid.cells[1,5] := '';
        FRegressiMain.StatGrid.cells[0,6] := '';
        FRegressiMain.StatGrid.cells[1,6] := '';
    end
    else begin
    FRegressiMain.StatGrid.cells[0,5] := 'ICm 95% mini';
    FRegressiMain.StatGrid.cells[1,5] := formatValeurEtUnite(moyenne-t95);
    FRegressiMain.StatGrid.cells[0,6] := 'ICm 95% maxi';
    FRegressiMain.StatGrid.cells[1,6] := formatValeurEtUnite(moyenne+t95);
    end;
    FRegressiMain.StatGrid.cells[0,7] := stEcartType;
    FRegressiMain.StatGrid.cells[1,7] := formatValeurEtUnite(sigma);
    FRegressiMain.StatGrid.cells[0,8] := 'CV';
    FRegressiMain.StatGrid.cells[1,8] := chainePrec(sigma/abs(moyenne));
    if not isNan(cible) then begin
       FRegressiMain.StatGrid.cells[0,9] := stCible;
       FRegressiMain.StatGrid.cells[1,9] := formatReg(Cible);
       FRegressiMain.StatGrid.cells[0,10] := stInexactitude;
       FRegressiMain.StatGrid.cells[1,10] := '';
       FRegressiMain.StatGrid.cells[0,11]  := '   '+StAbsolue;
       FRegressiMain.StatGrid.cells[1,11] := formatValeurEtUnite(Moyenne-Cible);
       FRegressiMain.StatGrid.cells[0,12] := '   '+StRelative;
       FRegressiMain.StatGrid.cells[1,12] := ChainePrec(Abs((Moyenne-Cible)/Cible));
    end;
    FRegressiMain.StatGrid.endUpdate;  // ne marche pas ?
end end;

Procedure AfficheDist;
var i,idebut,ifin : integer;
    ligne : integer;
begin with FRegressiMain.DistGrid,statCourante do begin
     beginUpdate;
     idebut := 1;
     while (NbreDist[idebut]=0) do inc(idebut);
     ifin := MaxHisto;
     while (NbreDist[ifin]=0) do dec(ifin);
     RowCount := 2+iFin-iDebut;
     if grandeurs[indexStat].nomUnite<>''
         then begin
            cells[0,0] := stMini+' ('+grandeurs[indexStat].nomUnite+')';
            cells[1,0] := stMaxi+' ('+grandeurs[indexStat].nomUnite+')';
         end
         else begin
            cells[0,0] := stMinimum;
            cells[1,0] := stMaximum;
         end;
     cells[2,0] := stTaille;
     ColumnWidths[0] := largeurNombreReel;
     ColumnWidths[1] := largeurNombreReel;
     ColumnWidths[2] := largeurNombreEntier;
     FRegressiMain.DistGrid.width := 2*largeurNombreReel+largeurNombreEntier+20; // pour scrollBar
  (*     columns[3].header := stMoyenne+grandeurs[indexStat].nomUnite;*)
     for i := iDebut to iFin do begin
        ligne := succ(i-iDebut);
        cells[0,ligne] := grandeurs[indexStat].formatNombre(BornesDist[pred(i)],1);
        cells[1,ligne] := grandeurs[indexStat].formatNombre(BornesDist[i],1);
        cells[2,ligne] := IntToStr(round(NbreDist[i]));
(*        cells[3,ligne] := formatCourt(MoyDist[i]);*)
     end;
     endUpdate;
end end;

Procedure AfficheDistInteger;
var i,idebut,ifin : integer;
    ligne : integer;
begin with FRegressiMain.DistGrid,statCourante do begin
     FRegressiMain.DistGrid.beginUpdate;
     idebut := 1;
     while (NbreDist[idebut]=0) do inc(idebut);
     ifin := MaxHisto;
     while (NbreDist[ifin]=0) do dec(ifin);
     RowCount := 2+iFin-iDebut;
     if grandeurs[indexStat].nomUnite<>''
         then cells[0,0] := stValeur+' ('+grandeurs[indexStat].nomUnite+')'
         else cells[0,0] := stValeur;
     cells[1,0] := stTaille;
     ColumnWidths[0] := largeurNombreReel;
     ColumnWidths[1] := largeurNombreEntier;
     ColumnWidths[2] := 0;
     FRegressiMain.DistGrid.width := largeurNombreReel+largeurNombreEntier+4;
     for i := iDebut to iFin do begin
        ligne := succ(i-iDebut);
        cells[0,ligne] := grandeurs[indexStat].formatNombre(
                   round((BornesDist[pred(i)]+BornesDist[i])/2),1);
        cells[1,ligne] := IntToStr(round(NbreDist[i]));
     end;
     FRegressiMain.DistGrid.endUpdate;
end end;

Procedure AfficheDistEffectif;
var i : integer;
    ligne : integer;
begin with FRegressiMain.DistGrid,statCourante do begin
     FRegressiMain.DistGrid.beginUpdate;
     ColumnWidths[2] := 0;
     RowCount := 1+Nbre;
     cells[0,0] := stValeur+grandeurs[indexStat].nomUnite;
     cells[1,0] := stTaille;
     ColumnWidths[0] := LargeurNombreReel;
     ColumnWidths[1] := LargeurNombreEntier;
     FRegressiMain.DistGrid.width := largeurNombreReel+largeurNombreEntier+2;
     for i := 0 to pred(Nbre) do begin
        ligne := succ(i);
        cells[0,ligne] := grandeurs[indexStat].formatNombre(BornesDist[i],1);
        cells[1,ligne] := IntToStr(round(Effectif[i]));
     end;
     FRegressiMain.DistGrid.endUpdate;
end end;

Procedure AfficheDistFrequence;
var i : integer;
    ligne : integer;
begin with FRegressiMain.DistGrid,statCourante do begin
     FRegressiMain.DistGrid.beginUpdate;
     ColumnWidths[2] := 0;
     RowCount := 1+Nbre;
     if grandeurs[indexStat].nomUnite<>''
         then cells[0,0] := stValeur+' ('+grandeurs[indexStat].nomUnite+')'
         else cells[0,0] := stValeur;
     cells[1,0] := '';
     ColumnWidths[0] := largeurNombreReel;
     ColumnWidths[1] := largeurNombreEntier;
     FRegressiMain.DistGrid.width := largeurNombreReel+largeurNombreEntier+4;
     for i := 0 to pred(Nbre) do begin
        ligne := succ(i);
        cells[0,ligne] :=  grandeurs[indexStat].formatNombre(BornesDist[i],1);
        cells[1,ligne] := '';
     end;
     FRegressiMain.DistGrid.endUpdate;
end end;

Function TestFrequence : boolean;
Var i : integer;
    total : double;
begin with Pages[pageCourante] do begin
       total := 0;
       for i := 0 to pred(nmes) do
           total := total + valeurVar[indexEffectif,i];
       result := (abs(total-1)<0.01) or (abs(total-100)<1);
       if result then begin
           nomEffectif := grandeurs[indexEffectif].nom;
           nomStat := grandeurs[indexStat].nom;
           stat.classeStat := csFrequenceDonnee;
      end;
end end;

Function TestEffectif : boolean;
Var i,j,n : integer;
begin with Pages[pageCourante] do begin
       result := true;
       for i := 0 to pred(nmes) do begin
           if not IsEntier(valeurVar[indexEffectif,i],n) then begin
                  result := false;
                  break;
           end;     // indexEffectif non entier donc pas un effectif
           for j := 0 to pred(i) do
               if valeurVar[indexStat,i]=valeurVar[indexStat,j] then begin
                  result := false;
                  break;
               end; // doublon indexStat donc pas une variable
      end;
      if result then begin
           nomEffectif := grandeurs[indexEffectif].nom;
           nomStat := grandeurs[indexStat].nom;
           stat.ClasseStat := csEffectifDonne;
      end;
end end;

Procedure InitStat;
begin with pages[pageCourante] do begin
      erreurStat := '';
      case stat.classeStat of
         csEffectifDonne : begin
            stat.setValeurEffectif(ValeurVar[indexStat],ValeurVar[indexEffectif],Nmes);
            if not stat.statOK then begin
               erreurStat := erEffectifNotInt;
               stat.classeStat := csFrequenceDonnee;
               stat.calcul;
               if not stat.statOK then begin
                    stat.classeStat := csAuto;
                    stat.setValeur(ValeurVar[indexStat],Nmes,true);
               end;
            end;
         end;
         csFrequenceDonnee : begin
            stat.setValeurEffectif(ValeurVar[indexStat],ValeurVar[indexEffectif],Nmes);
            if not stat.statOK then begin
               erreurStat := erPourCent;
               stat.classeStat := csEffectifDonne;
               stat.calcul;
               if not stat.statOK  then  begin
                    stat.classeStat := csAuto;
                    stat.setValeur(ValeurVar[indexStat],Nmes,true);
               end;
            end;
         end
         else stat.setValeur(ValeurVar[indexStat],Nmes,true);
      end;
   end;
end;

Var PrecisionS,SauvePrecision,i : integer;
    oldFormat : TnombreFormat;
begin // setCoordonnee
with FRegressiMain.grapheStat do begin
     reset;
     dessinTexts.clear;
     dessinLines.clear;
     grapheOK := NbreGrandeurs>0;
     if not GrapheOK then exit;
     FRegressiMain.DistGrid.beginUpdate;
     FRegressiMain.StatGrid.beginUpdate;
     indexStat := indexNom(nomStat);
     statCourante := pages[pageCourante].stat;
     if indexStat=grandeurInconnue then begin
        statCourante.ClasseStat := csAuto;
        if NbreVariabExp>1
           then begin
               indexStat := indexVariab[0];
               indexEffectif := indexVariab[1];
               if not TestEffectif then begin
                  if not TestFrequence then begin
                        indexStat := indexVariab[0];
                        indexEffectif := indexVariab[1];
                        testFrequence;
                  end;
                  indexStat := indexVariab[1];
                  indexEffectif := indexVariab[0];
                  testEffectif;
               end;
           end
           else begin
               indexStat := indexVariab[0];
               nomStat := grandeurs[indexStat].nom;
           end;
     end;
     indexEffectif := indexNom(nomEffectif);
     if indexEffectif=grandeurInconnue then begin
        indexEffectif := indexVariab[0];
        nomEffectif := grandeurs[indexEffectif].nom;
        if statCourante.ClasseStat=csEffectifDonne
           then statCourante.ClasseStat := csAuto;
     end;
     initStat;
     with statCourante do begin
          calcul;
          PoissonPermis := (moyenne<64) and statOK;
          if PoissonPermis then for i := 0 to pred(Nbre) do begin
             PoissonPermis := PoissonPermis and
                 (abs(donnees[i]-round(donnees[i]))<0.001);
             if not PoissonPermis then break;
          end;
     end;
     grapheOK := statCourante.statOK;
     if not GrapheOK then exit;
     Caption := stStatistique+nomStat;
     if statCourante.ClasseStat in [csEffectifDonne,csFrequenceDonnee]
        then frequenceGr := grandeurs[indexEffectif]
        else frequenceGr := frequenceGrDefault;
     with statCourante,grandeurs[indexStat] do begin
        SauvePrecision := PrecisionU;
        oldFormat := formatU;
        if oldFormat=fDefaut then formatU := fExponent;
        try
        PrecisionS := ceil(-log10(sigma/abs(Moyenne)))+1;
        except
        PrecisionS := precision;
        end;
        if precisionS<3 then precisionS := 3;
        if precisionS>8 then precisionS := 8;
        PrecisionU := PrecisionS;
     end;
     case statCourante.ClasseStat of
        csEffectifDonne : afficheDistEffectif;
        csFrequenceDonnee : afficheDistFrequence;
        else if statCourante.DataInteger and (statCourante.ecartDist=1)
           then afficheDistInteger
           else afficheDist;
     end;
     afficheStat;
     SetHistogramme;
     modif := [];
     grandeurs[indexStat].PrecisionU := SauvePrecision;
     grandeurs[indexStat].formatU := oldFormat;
     FRegressiMain.DistGrid.endUpdate;
     FRegressiMain.StatGrid.endUpdate;
end end; // setCoordonnee


procedure TStatOptDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
