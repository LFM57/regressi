unit grapheVariabU;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.UIConsts,
  System.Actions,
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
  FMX.Printer,
  FMX.ActnList,
  FMX.Platform,
  FMX.Graphics,
  FMX.DialogService,

  FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomScrollControl,
  FMX.TMSFNCGridData, FMX.TMSFNCCustomGrid,
  FMX.TMSFNCGrid, FMX.TMSFNCGridCell,
  FMX.TMSFNCTypes, FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes, FMX.TMSFNCGridOptions,

  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,

  aidekey,
  compile,
  constreg,
  graphKer,
  maths,
  modeleGr,
  regutil,
  statCalc,
  uniteKer,
  myShape;


type
  TgrapheResidu = class(TgrapheReg)
  private
      dXresidu,dYresidu : vecteur;
  public
      constructor Create(apaintBox : TPaintBox);
      procedure PaintBoxPaint(miniX,maxiX : double);
      procedure SetCoordonnee(miniX,maxiX : double);
      destructor Destroy; override;
  end;

   TgrapheVariab = class(TgrapheReg)
   private
      courbePointCourant : integer;
      derf : matriceFonction;   // Dérivées premières / aux paramètres
      erreurCalcul,erreurParam : boolean;
      xOrigine : double;
      ValeurYDiff,ValeurYpDiff : TvecteurExtrapole;
      ValeurXDiff : vecteur;
      IsModeleSysteme : boolean;
      orthoAverifier : boolean;
      BorneDebut,BorneFin : array[1..MaxIntervalles] of TBorneShape;
      BorneSelect : TBorneShape;
      TailleEq : single;
      FPanLastPos : TPointF;
      FPanPrevCurseur : Tcurseur;
      FPanActive : boolean;
// Début data Animation
      InitManuelleAfaire : boolean;
      ParamAnimCourant : integer;
      NbrePasAnimation : integer;
      EchelleAutoAnimation : boolean;
// Fin data animation
      procedure setPointCourant(i,c : integer);
      procedure AffecteModele;
      procedure ZoomSuperpose;
      procedure ZoomModele;
      procedure ConvertitXY(sender : TObject;var x,y : single);
      function setBorne(P : TpointF) : boolean;
      procedure ajusteBorne(P : TpointF);
      function IndexCourbeLigne : integer;
  public
      BorneActive : codeIntervalle;
      modeleDependant : boolean;
      CurMovePermis : boolean;
      SpaceHeld : boolean;
      IsModeleMagnum : boolean;
      verifGraphe : boolean;
      configCharge : boolean;
      Origin : TpointF;
      iPropCourbe : integer;
      ValeurDeriveeX : TvecteurExtrapole;
      constructor Create(apaintBox : TPaintBox);
      procedure PanelCentralKeyDown(Sender: TObject; var Key: Word;
          var KeyChar: Char; Shift: TShiftState);
      procedure CompileModele(var PosErreur,LongErreur : integer);
      procedure ConstruitModele;
      Procedure EffectueModele(Ajuste,WithMessage : boolean);
      Procedure EffectueModeleMono(m : integer);
      procedure RazBornesClick;
      procedure ImprModeleBtnClick;
      procedure ChoixCurseurClick(sender : Tobject);
      procedure VecteursItemClick(Sender: TObject);
      procedure SetPenBrush(c : Tcurseur);
      Procedure SetCoordonnee;
      procedure EcritConfig;
      procedure LitConfig;
      procedure EcritConfigXML(ANode : IXMLNOde);
      procedure LitConfigXML(ANode : IXMLNOde);
      Procedure CalcIntersection;
      procedure ImprimerGraphe(var bas : single);
      procedure PaintBoxPaint;
      procedure PaintBoxMouseMove(sender : Tobject;Shift: TShiftState;
         X,Y: single);
      procedure PaintBoxMouseDown(sender : Tobject;Button: TMouseButton;
         Shift: TShiftState; X, Y: single);
      procedure PaintBoxMouseUp(sender : Tobject;Button: TMouseButton;
         Shift: TShiftState; X, Y: single);
      procedure PaintBoxMouseWheel(Sender: TObject; Shift: TShiftState;
         WheelDelta: Integer; var Handled: Boolean);
      destructor Destroy; override;
// Début procedure animation
      Procedure SetAnimation;
      procedure CalculeAnimation;
      function paramPrecedent : boolean;
      function paramSuivant : boolean;
      procedure SetCoordAnimation;
      Procedure ModifGrapheAnimation;
      procedure AddCourbesAnimation;
      procedure GBAnimationClick(Sender: TObject);
      procedure GBAnimationDblClick;
      procedure SliderAnimationChange(Sender: TObject);
      procedure VerifCoordAnimation;
      procedure SetStyleAnimation;
      procedure verifAnimation;
// Fin procedure animation
      procedure CalculCurseurModele(cellule : string);
      Procedure InitCurseurModele;
      procedure RemplitTableauEquivalence;
      procedure BarreEspace;
  end;

var
    Graphe : TgrapheVariab;

implementation

uses
     fspec, regmain, cursData, options, choixModele,
     systDiff, CoordPhys, Graphfft, Valeurs,
     optModele, PropCourbe, optionsvitesse, modif, choixParamAnim,
     curModeleU;

const
    NcurseurModeleMax = 16;
    DecaleLabel = 5;

{$I modele.pas}
{$I modeleMono.pas}

procedure TGrapheVariab.SetStyleAnimation;
var i : integer;
begin
     for i := 0 to pred(NbreParamAnimation) do with paramAnimation[i] do begin
         codeA := indexConstExp[i];
         SliderA.visible := active;
         if active
            then GroupBoxA.height := 48
            else GroupBoxA.height := 24;
         GroupBoxA.Enabled := active;
         GroupBoxA.Visible := true;
         if i=paramAnimCourant
              then begin
                 groupBoxA.textSettings.Font.style := [TFontStyle.fsBold];
                 groupBoxA.textSettings.FontColor := claRed;
                 sliderA.opacity := 1;
              end
              else begin
                 groupBoxA.textSettings.Font.style := [];
                 groupBoxA.textSettings.FontColor := claGray;
                 sliderA.opacity := 0.4;
              end;
              if (codeA<NbreGrandeurs) then
         GroupBoxA.text := grandeurs[codeA].formatNomEtUnite(valeurA)+
                   ' ['+formatReg(debutA)+','+formatReg(finA)+']';
     end;
     for i := NbreParamAnimation to maxParamAnimation do
            paramAnimation[i].groupBoxA.Visible := false;
end; // setStyleAnimation

procedure TGrapheVariab.VerifCoordAnimation;
var i : integer;
    avecAxe : boolean;
begin
    for i := 1 to maxOrdonnee do with coordonnee[i] do begin
        codeY := indexNom(nomY);
        if (codeY>maxGrandeurs) or
           not (grandeurs[codeY].genreG in [variable,constante,constanteGlb])
           then codeY := grandeurInconnue;
        codeX := indexNom(nomX);
        if (codeX<>grandeurInconnue) and
           not (grandeurs[codeX].genreG in [variable,constante,constanteGlb])
           then codeX := grandeurInconnue;
    end;
    nbreOrdonnee := 0;
    for i := 1 to maxOrdonnee do with coordonnee[i] do
        if (codeX<>grandeurInconnue) and
           (codeY<>grandeurInconnue)
           then begin
              inc(nbreOrdonnee);
              coordonnee[nbreOrdonnee] := coordonnee[i];
           end;
    for i := succ(NbreOrdonnee) to maxOrdonnee do with coordonnee[i] do begin
           codeX := grandeurInconnue;
           codeY := grandeurInconnue;
           iMondeC := mondeY;
           nomX := '';
           nomY := '';
           ligne := liDroite;
    end;
    if nbreOrdonnee=0 then begin
       for i := mondeX to MaxOrdonnee do Monde[i].graduation := gLin;
       with coordonnee[1] do begin
          codeX := indexVariab[0];
          nomX := grandeurs[codeX].nom;
          curseur := curSelect;
          codeY := indexVariab[1];
          nomY := grandeurs[codeY].nom;
          iMondeC := mondeY;
          nbreOrdonnee := 1;
       end;
       with coordonnee[2] do begin
          codeY := indexVariab[2];
          if (codeY<>grandeurInconnue) and
             (grandeurs[codeY].fonct.genreC=g_experimentale) then begin
             codeX := indexVariab[0];
             nomX := grandeurs[codeX].nom;
             nomY := grandeurs[codeY].nom;
             if unitesEgales(grandeurs[codeY],grandeurs[coordonnee[1].codeY])
                then iMondeC := mondeY
                else iMondeC := mondeDroit;
             nbreOrdonnee := 2;
          end;
       end;
    end // nbreOrdonnee=0
    else begin
        AvecAxe := false;
        for i := 1 to NbreOrdonnee do with coordonnee[i] do
            if iMondeC<>mondeSans then avecAxe := true;
        if not AvecAxe then coordonnee[1].iMondeC := mondeY;
    end;
end; // VerifCoordAnimation;

procedure TGrapheVariab.SliderAnimationChange(Sender: TObject);
var Lslider : TtrackBar;
    newValeur : double;
begin
    Lslider := (sender as  TtrackBar);
    paramAnimCourant := Lslider.Tag;
    with ParamAnimation[paramAnimCourant] do begin
        if variationLog
           then newValeur := power(10,Lslider.value)
           else newValeur := Lslider.value;
        if newValeur<>valeurA then begin
           valeurA := newValeur;
           calculeAnimation;
        end;
    end;
end; // SliderAnimationChange

procedure TGrapheVariab.GBAnimationClick(Sender: TObject);
var AgroupBox : TgroupBox;
    i : integer;
begin
    AgroupBox := (sender as  TgroupBox);
    i := AgroupBox.tag;
    if paramAnimation[i].active then begin
       paramAnimCourant := i;
       setStyleAnimation;
    end;
end;

procedure TGrapheVariab.GBAnimationDblClick;
begin
     if ParamAnimationDlg=nil then
        Application.CreateForm(TParamAnimationDlg, ParamAnimationDlg);
     ParamAnimationDlg.EchelleAutoCB.IsChecked := echelleAutoAnimation;
     if ParamAnimationDlg.ShowModal=mrOK then begin
        verifAnimation;
        echelleAutoAnimation := ParamAnimationDlg.EchelleAutoCB.IsChecked;
        setStyleAnimation;
     end;
end; // GBAnimationDblClick

Procedure TGrapheVariab.ModifGrapheAnimation;
begin
    if lecturePage then exit;
    if ([gmXY,gmOptions,gmPage,gmValeurs]*modif)<>[]
            then begin
                 setCoordAnimation;
                 calculeAnimation;
            end;
     paintBox.repaint;
end;

procedure TGrapheVariab.AddCourbesAnimation;
var j : integer;

Procedure AddLoc;
var courbeVariab : Tcourbe;

Procedure AddModele(p : integer);
var c : integer;
    x,y : vecteur;
    courbeAdd : Tcourbe;
begin with Coordonnee[j] do begin
    if (ModeleDefini in etatModele) and
       (pages[p].modeleCalcule) then
            for c := 1 to NbreModele do with fonctionTheorique[c] do
                  if (codeY=indexY) and (codeX=indexX) and not(implicite) then begin
                        exclude(courbeVariab.Trace,trLigne); // on trace le modèle à la place
                        setlength(x,pages[p].NmesMax+1);
                        setLength(y,pages[p].NmesMax+1);
                        courbeAdd := AjouteCourbe(x,y,iMondeC,pages[p].nmes,
                                           grandeurs[codeX],grandeurs[codeY],p);
                        courbeAdd.IndexModele := c;
                        courbeAdd.Trace := [trLigne];
                        courbeAdd.Adetruire := true;
            end; // modéle actif
    if (SimulationDefinie in etatModele) then
       for c := 1 to NbreFonctionSuper do with fonctionSuperposee[c] do
           if (codeY=indexY) and (codeX=indexX) then begin
                 exclude(courbeVariab.Trace,trLigne); // on trace le modèle à la place
                 setLength(x,pages[p].nmesMax+1);
                 setLength(y,pages[p].nmesMax+1);
                 courbeAdd := AjouteCourbe(x,y,iMondeC,pages[p].nmes,
                    grandeurs[codeX],grandeurs[codeY],p);
                 courbeAdd.IndexModele := -c;
                 courbeAdd.Trace := [trLigne];
                 courbeAdd.Adetruire := true;
           end; // simulation active
       if (ModeleDefini in etatModele) and
        pages[p].modeleCalcule and
       (NbreModele=2) and
       (fonctionTheorique[1].genreC=g_fonction) and
       (fonctionTheorique[1].indexX=0) and
       (fonctionTheorique[2].indexX=0) and
       (((fonctionTheorique[1].indexY=codeY) and
         (fonctionTheorique[2].indexY=codeX)) or
       ((fonctionTheorique[1].indexY=codeX) and
        (fonctionTheorique[2].indexY=codeY))) then begin
                  exclude(courbeVariab.Trace,trLigne); // on trace le modèle à la place
                  setLength(x,pages[p].NmesMax+1);
                  setLength(y,pages[p].NmesMax+1);
                  courbeAdd := AjouteCourbe(x,y,iMondeC,pages[p].nmes,
                                 grandeurs[codeX],grandeurs[codeY],p);
                  courbeAdd.ModeleParametrique := true;
                  courbeAdd.ModeleParamX1 := fonctionTheorique[1].indexY=codeX;
                  courbeAdd.Trace := [trLigne];
                  courbeAdd.Adetruire := true;
    end; // Modele parametrique
end end; //  AddModele

procedure AddPage(p : integer);
begin with pages[p],Coordonnee[j] do begin
             courbeVariab := AjouteCourbe(valeurVar[codeX],valeurVar[codeY],
                    iMondeC,nmes,grandeurs[codeX],grandeurs[codeY],p);
             courbeVariab.trace := trace;
             if (trLigne in Trace) and (ligne=liModele) then AddModele(p);
end end;

var x,y : vecteur;
    i,p : integer;
begin with pages[pageCourante],Coordonnee[j]  do begin
     if (grandeurs[codeY].genreG in [constante,constanteGlb]) or
        (grandeurs[codeX].genreG in [constante,constanteGlb])
        then begin
              setLength(y,nmes);
              case grandeurs[codeY].genreG of
                   constante : for i := 0 to pred(nmes) do y[i] := valeurConst[codeY];
                   variable : copyVecteur(y,valeurVar[codeY]);
                   constanteGlb : for i := 0 to pred(nmes) do y[i] := grandeurs[codeY].valCourante;
              end;
              setLength(x,nmes);
              case grandeurs[codeX].genreG of
                   constante : for i := 0 to pred(nmes) do x[i] := valeurConst[codeX];
                   variable : copyVecteur(x,valeurVar[codeX]);
                   constanteGlb : for i := 0 to pred(nmes) do x[i] := grandeurs[codeX].valCourante;
              end;
              courbeVariab := AjouteCourbe(x,y,iMondeC,nmes,
                   grandeurs[codeX],grandeurs[codeY],pageCourante);
              courbeVariab.Adetruire := true;
              courbeVariab.trace := trace;
        end
        else begin
             AddPage(pageCourante);
             if superposePage then
             for p := 1 to NbrePages do
                 if pages[p].Active and (p<>pageCourante) then begin
                    AddPage(p);
                    continue;
                 end;
        end;
        courbeVariab.setStyle(couleur,styleT,motif);
     monde[iMondeC].defini := true;
end end;

begin
     courbes.clear;
     if not grapheOK then setCoordAnimation;
     for j := 1 to NbreOrdonnee do AddLoc;
     monde[mondeX].defini := true;
end; // AddCourbeAnimation

procedure TGrapheVariab.CalculeAnimation;

Procedure TestModif;
begin
        if (([gmXY,gmModele,gmPage,gmValeurs]*modif)<>[]) or
           (courbes.count=0)
            then begin
               if ([gmValeurs]=modif)
                   then courbes.clear
                   else reset;
                setCoordonnee;
            end;
end;

var i,j : integer;
    modifNmes : boolean;
    code : integer;
begin
      if not grapheOK then setCoordAnimation;
      modifNmes := false;
      for i := 0 to pred(NbreParamAnimation) do with paramAnimation[i] do
          if active then begin
             codeA := indexNom(nomA);
             pages[pageCourante].valeurConst[codeA] := valeurA;
             grandeurs[codeA].valCourante := pages[pageCourante].valeurConst[codeA];
          end;
    //     cursor := crHourGlass;
      pages[pageCourante].RecalculP;
      if ModifNmes or pages[pageCourante].changeAdresse
         then addCourbesAnimation
         else for j := 0 to pred(Courbes.count) do with Courbes[j] do
             if (courbes[j].page=pageCourante) then begin
                debutC := 0;
                finC := pred(pages[pageCourante].nmes);
                if varY.genreG=constante then begin
                   code := varY.indexG;
                   if high(valy)<pages[pageCourante].nmes then setLength(valY,pages[pageCourante].nmes);
                   for i := 0 to pred(pages[pageCourante].nmes) do valy[i] := pages[pageCourante].valeurConst[code];
                end;
                if varX.genreG=constante then begin
                   code := varX.indexG;
                   if high(valx)<pages[pageCourante].nmes then setLength(valX,pages[pageCourante].nmes);
                   for i := 0 to pred(pages[pageCourante].nmes) do valx[i] := pages[pageCourante].valeurConst[code];
                end;
                if varY.genreG=constanteGlb then begin
                   if high(valy)<pages[pageCourante].nmes then setLength(valY,pages[pageCourante].nmes);
                   for i := 0 to pred(pages[pageCourante].nmes) do valy[i] := varY.valCourante;
                end;
                if varX.genreG=constanteGlb then begin
                   if high(valx)<pages[pageCourante].nmes then setLength(valX,pages[pageCourante].nmes);
                   for i := 0 to pred(pages[pageCourante].nmes) do valx[i] := varX.valCourante;
                end;
             end;
     // affecteModele;
     // zoomModele;
     // zoomSuperpose;
      if echelleAutoAnimation then AjusteMonde;
      setStyleAnimation;
end; // CalculeAnimation

procedure TGrapheVariab.SetCoordAnimation;
var j : integer;
begin
     reset;
     resetEquivalence;
     VerifCoordAnimation;
     grapheOK := true;
     for j := 1 to NbreOrdonnee do with Coordonnee[j] do begin
         if trace=[] then  if (modeAcquisition=AcqSimulation)
                    then trace := [trLigne]
                    else begin
                         trace := [trLigne,trPoint];
                         ligne := liSpline;
                    end;
         codeX := indexNom(nomX);
         codeY := indexNom(nomY);
     end;
     AddCourbesAnimation;
     for j := 1 to NbreOrdonnee do with Coordonnee[j] do begin
         if monde[iMondeC].axe=nil then
            monde[iMondeC].axe := grandeurs[codeY];
         if monde[MondeX].axe=nil then
            monde[MondeX].axe := grandeurs[codeX];
     end;
     if echelleAutoAnimation then monde[mondeX].defini := false;
end;// setCoordAnimation

function TGrapheVariab.ParamSuivant : boolean;
begin
     with paramAnimation[paramAnimCourant] do begin
        sliderA.value := sliderA.value+sliderA.frequency;
        SliderAnimationChange(sliderA);
        result := sliderA.value<sliderA.max
     end;
end;

function TGrapheVariab.ParamPrecedent : boolean;
begin
    with paramAnimation[paramAnimCourant] do begin
         sliderA.Value := sliderA.value-sliderA.frequency;
         SliderAnimationChange(sliderA);
         result := sliderA.value>sliderA.min;
    end;
end;

procedure TGrapheVariab.VerifAnimation;
var i : integer;
begin
        if (paramAnimCourant>=NbreParamAnimation) then paramAnimCourant := 0;
        if not paramAnimation[paramAnimCourant].active then
          for i := 0 to pred(NbreParamAnimation) do
              if paramAnimation[i].active then begin
                 paramAnimCourant := i;
                 break;
              end;
        for i := 0 to pred(NbreParamAnimation) do with paramAnimation[i] do begin
           codeA := indexConstExp[i];
           verifMinMaxReal(debutA,finA);
           if variationLog
           then begin
              if debutA<=0 then debutA := 0.1;
              if finA<=debutA then finA := debutA*10;
              if pasA<1 then pasA := power(finA/debutA,1/100);
              SliderA.max := log10(finA);
              SliderA.min := log10(debutA);
              SliderA.frequency := log10(pasA);
           end
           else begin
              if finA=debutA then finA := debutA+1;
              pasA := abs(pasA);
              if pasA=0 then pasA := (finA-debutA)/100;
              SliderA.max := finA;
              SliderA.min := debutA;
              SliderA.frequency := pasA;
           end;
        end;
end; // verifAnimation

Procedure TGrapheVariab.SetAnimation;
var i : integer;
    avecVerif,UnActif : boolean;
    valDebut,valFin,valC : double;
begin
    if NbreConstExp>maxParamAnimation
       then NbreParamAnimation := MaxParamAnimation+1
       else NbreParamAnimation := NbreConstExp;
    avecVerif := false;
    for i := 0 to pred(NbreParamAnimation) do with paramAnimation[i] do begin
           codeA := indexConstExp[i];
           if (nomA<>grandeurs[codeA].nom) or Ainitialiser then begin
              nomA := grandeurs[codeA].nom;
              valDebut := pages[1].valeurConst[codeA];
              valFin := pages[NbrePages].valeurConst[codeA];
              Ainitialiser := isNan(valDebut) or isNan(valFin);
              if isNan(valDebut) then valDebut := 1;
              if isNan(valFin) then valFin := valDebut+1;
              debutA := valDebut;
              finA := valFin;
              VerifMinMaxReal(debutA,finA);
              variationLog := false;
              if finA=debutA then finA := debutA+1;
              pasA := (finA-debutA)/100;
              valC := pages[PageCourante].valeurConst[codeA];
              if (valC<debutA) or (valC>finA) then valC := (valDebut+valFin)/2;
              valeurA := valC;
              avecVerif := avecVerif or not Ainitialiser;
              active := ((ModeAcquisition<>AcqSimulation) or
                         (i>0) or
                         (NbreParamAnimation=1)) and
                         not Ainitialiser;
           end;
           SliderA.visible := active;
           if active
              then GroupBoxA.height := 48
              else GroupBoxA.height := 24;
           if variationLog
              then SliderA.value := log10(valeurA)
              else SliderA.value := valeurA;
           GroupBoxA.visible := true;
    end;
    UnActif := false;
    for i := 0 to pred(NbreParamAnimation) do
           UnActif := UnActif or paramAnimation[i].active;
    if not UnActif then with paramAnimation[pred(NbreParamAnimation)] do begin
           active := true;
           SliderA.visible := true;
           GroupBoxA.height := 48;
    end;
    for i := NbreParamAnimation to maxParamAnimation do
           paramAnimation[i].GroupBoxA.visible := false;
    if (paramAnimCourant>=NbreParamAnimation) or
          not(paramAnimation[ParamAnimCourant].active) then
          for i := 0 to pred(NbreParamAnimation) do
             if paramAnimation[i].active then begin
                paramAnimCourant := i;
                break;
             end;
    if avecVerif
        then GBAnimationDblClick
        else begin
           verifAnimation;
           setStyleAnimation;
        end;
    InitManuelleAfaire := false;
end; //setAnimation

procedure TgrapheVariab.PaintBoxMouseMove(Sender: TObject;
     Shift: TShiftState; X,Y: single);

procedure AffichePosition;
var icourbe : integer;
begin
    if not(grapheOK) or (courbes.count=0) then exit;
    if (curseurCourant < 1) or (curseurCourant > maxCurseur) then curseurCourant := 1;
    iCourbe := courbeProche(origin);
    if iCourbe<0 then iCourbe := 0;
    with courbes[iCourbe] do begin
          if (varY<>nil) then curseurOsc[curseurCourant].mondeC := iMondeC;
          curseurOsc[curseurCourant].Pc := origin;
          if curseurCourant=2
             then paintBox.repaint // pour écart
             else curseurOsc[1].repaint;
    end;
end; // AffichePosition

procedure AfficheResidu;
var i, k : integer;
    ref, residu, ecart : double;
    YY : string;
    P : tpointF;
begin with pages[pageCourante] do begin
    if not(monde[mondeX].defini) then exit;
    if (indexCourbeModele < 0) or (indexCourbeModele >= courbes.Count) then exit;
    P.create(x,y);
    i := pointProche(P,indexCourbeModele,true,false);
    if (i<debut[1]) or (i>fin[1]) then exit;
    if courbes[indexCourbeModele].IncertY<>nil
       then begin
       try
          ref := courbes[indexCourbeModele].incertY[i];
          YY := stIncertitude;
          ref := (valeurVar[fonctionTheorique[1].indexY,i]-valeurTheorique[1,i])/ref;
          YY := stEcart+FloatToStrF(ref,ffGeneral,3,1)+' * '+YY;
       except
          YY := '';
       end;
       end
       else if modeleCalcule and fonctionTheorique[1].residuStat.statOK
          then begin
             k := i - debut[1];
             if (k < 0) or (k >= fonctionTheorique[1].residuStat.Nbre) then exit;
             ref := fonctionTheorique[1].residuStat.t95;
             if fonctionTheorique[1].residuStat.avecIncert then begin
                residu := fonctionTheorique[1].residuStat.residusNormalises[k];
                YY := stResiduNormalise;
             end else begin
                residu := fonctionTheorique[1].residuStat.residus[k];
                YY := stResiduStudent;
             end;
             YY := YY+FloatToStrF(residu,ffGeneral,3,1)+
                      stLimiteStudent95+FloatToStrF(ref,ffGeneral,3,1)+')';
          end
          else begin
             ecart := valeurVar[fonctionTheorique[1].indexY,i]-valeurTheorique[1,i];
             YY := stEcart+FloatToStrF(ecart,ffGeneral,3,1);
          end;
    FregressiMain.Aide.text := YY;
end end; // AfficheResidu

var deplacement : boolean;
    deltaM : double;
    hintLoc : string;
    iProche : integer;
    Pint : TPointF;
    m : indiceMonde;
begin // PaintBoxMouseMove
   if not grapheOK then exit;
   if ssRight in Shift then exit; // clic droit
   hintLoc := '';
   convertitXY(sender,x,y);
   if (sender is TBorneShape) then BorneSelect := sender as TborneShape;
   deplacement := ssLeft in Shift;
   origin.x := x;
   origin.Y := y;
   if FLegendDragging then begin
      if deplacement then begin
         FLegendCustomPos := True;
         FLegendPos := TPointF.Create(x - FLegendDragDelta.X, y - FLegendDragDelta.Y);
         paintBox.Repaint;
      end else begin
         FLegendDragging := False;
         paintBox.Cursor := crDefault;
      end;
      exit;
   end;
   case curseur of
        curReticuleModele : begin
           hintLoc := hReticuleModele;
           setReticuleModele(origin);
           affichePosition;
        end;
        curZoomAv,curEfface,curBornes : if deplacement then begin
               selection.width := x-selection.Position.x;
               selection.height := y-selection.position.y;
        end;
        curSelect : begin
            if deplacement
               then begin
                  if (borneSelect<>nil) then
                     ajusteBorne(origin);
                  if dessinTextCourant<>nil then
                     dessinTextCourant.affecteXY(x,y);
                  if (dessinLineCourant<>nil) then
                     dessinLineCourant.affecteXY(x,y);
                  hintLoc := hMove;
               end
               else begin // pas déplacement
                     if UseSelect then ;
                     paintBox.cursor := crDefault;
                     if indexPointCourant>=0 then hintLoc := '';
                     if curMovePermis then hintLoc := '';
                     if dessinLineCourant<>nil then
                        paintBox.cursor := crHandPoint;
                     if LegendHitTest(origin) then
                        paintBox.cursor := crHandPoint;
                     if SpaceHeld then
                        paintBox.cursor := crSizeAll;
               end;
           if FCoordonneesPhys.ModeleEnCours and
               (indexCourbeModele>=0) then afficheResidu
        end;
        curLigne : if (dessinLineCourant<>nil) then
            dessinLineCourant.affectePoint2(x,y);
        curTexte : ;
        curReticule : begin
           AffichePosition;
           hintLoc := stBarreReticule;
        end;
        curMove : if FPanActive and ((ssLeft in Shift) or (ssMiddle in Shift)) then begin
            if (Abs(x - FPanLastPos.X) > 0) or (Abs(y - FPanLastPos.Y) > 0) then begin
               if monde[mondeX].defini and (monde[mondeX].a <> 0) then begin
                  deltaM := (x - FPanLastPos.X) / monde[mondeX].a;
                  monde[mondeX].mini := monde[mondeX].mini - deltaM;
                  monde[mondeX].maxi := monde[mondeX].maxi - deltaM;
               end;
               for m := mondeY to high(indiceMonde) do
                  if monde[m].defini and (monde[m].a <> 0) then begin
                     deltaM := (y - FPanLastPos.Y) / monde[m].a;
                     monde[m].mini := monde[m].mini - deltaM;
                     monde[m].maxi := monde[m].maxi - deltaM;
                  end;
               FPanLastPos := TPointF.Create(x, y);
               useDefaut := False;
               useDefautX := False;
               include(modif, gmEchelle);
               paintBox.repaint;
            end;
        end
        else begin
            FPanActive := False;
            setPenBrush(FPanPrevCurseur);
        end;
        curOrigine : begin
            hintLoc := hOrigine;
            ReticuleOrigine.centre := origin;
        end;
        curEquivalence : if (indexCourbeEquivalence >= 0) and (indexCourbeEquivalence < courbes.Count) then begin
           iproche := PointProche(origin,indexCourbeEquivalence,true,ligneRappelTangente=lrTangente);
           if iProche>=0 then begin
              WindowRT(courbes[indexCourbeEquivalence].valX[iproche],
                       courbes[indexCourbeEquivalence].valY[iproche],mondeY,Pint);
              FRegressiMain.Cercle.position.x := Pint.x-tailleEq;
              FRegressiMain.Cercle.position.y := Pint.y-tailleEq;
           end;
        end;
        curReticuleData : if deplacement and (curseurCourant>0)
           then begin
               setSegmentInt(origin);
               setPointCourant(curseurOsc[curseurCourant].Ic,0);
               hintLoc := '';
           end
           else begin
                GetCurseurProche(origin,false);
                if curseurCourant=0
                   then paintBox.cursor := crDefault
                   else paintBox.cursor := crHandPoint;
           end;
   end;
   FregressiMain.Aide.text := hintLoc;
   paintBox.hint := hintLoc;
end; // PaintBoxMouseMove

procedure TgrapheVariab.SetPenBrush(c : Tcurseur);
var curModelePermis : boolean;
    i : integer;
begin
    if c=curOrigine then begin
       if monde[mondeX].axe.fonct.genreC<>g_experimentale then begin
          AfficheErreur(erOrigineExp,0);
          c := curSelect;
       end;
       if superposePage then begin
          AfficheErreur(erOriginePage,0);
          c := curSelect;
       end;
       if (c<>curOrigine) then showMessage(hCurseurOrigine);
     end;
     curseur := c;
     case curseur of
         curReticuleModele : begin
             if nbreModele>1
                then curModelePermis := (pages[pageCourante].modeleCalcule) and
                       (ModeleConstruit in etatModele) and
                       (monde[mondeX].axe=grandeurs[fonctionTheorique[1].indexX]) and
                       (monde[mondeY].axe=grandeurs[fonctionTheorique[1].indexY])
                else begin
                     curModelePermis := false;
                     i := 0;
                     while (not curModelePermis) and (i < courbes.Count) do
                         if (trLigne in courbes[i].trace) and
                            (courbes[i].page=pageCourante)
                            then curModelePermis := true
                            else inc(i);
                end;
             if curModelePermis
             then paintBox.cursor := crCross
             else begin
                afficheErreur(ErCurseurModele,0);
                curseur := curSelect;
             end;
         end;
         curZoomAv : ;
         curBornes : ;
         curTexte : ;
         curLigne : ;
         curReticule,curOrigine : paintBox.cursor := crNone;
         curEfface : ;
         curReticuleData : ;
         curEquivalence : ;
         curMove : paintBox.cursor := crSizeAll;
         else paintBox.cursor := crCross;
     end;// case curseur
     if not (curseur in [curZoomAv,curBornes,curEfface]) then selection.visible := false;
     curseurOsc[1].visible := curseur in [curReticule,curReticuleData,curReticuleModele];
     ReticuleOrigine.visible := curseur = curOrigine;
     FregressiMain.cercle.Visible := curseur in [curEquivalence,curReticuleData];
     if curseur=curEquivalence then begin
         tailleEq := 5*dimPoint;
         FRegressiMain.Cercle.width := 2*tailleEq;
         FRegressiMain.Cercle.height := 2*tailleEq;
     end;
     with FRegressiMain do begin
       SelectItem.IsChecked := (curseur = curSelect);
       CurTexteItem.IsChecked := (curseur = curTexte);
       CurLigneItem.IsChecked := (curseur = curLigne);
       CurGommesItem.IsChecked := (curseur = curEfface);
       CurReticuleItem.IsChecked := (curseur = curReticule);
       curDataItem.IsChecked := (curseur = curReticuleData);
       CurOrigineItem.IsChecked := (curseur = curOrigine);
       CurReticuleModeleItem.IsChecked := (curseur = curReticuleModele);
       TangenteItem.IsChecked := (curseur = curEquivalence);
     end;
end; // SetPenBrush

procedure TgrapheResidu.PaintBoxPaint(miniX,maxiX: double);
begin
        grapheOK := (pageCourante>0) and
           not(lecturePage) and
           (NbreVariab>1) and
           (NbrePages>0) and
           (ModeleDefini in graphe.etatModele) and
           (ModeleConstruit in graphe.etatModele) and
           pages[pageCourante].modeleCalcule;
        if grapheOK and
           (
           (([gmXY,gmModele,gmPage,gmValeurs]*modif)<>[]) or
            (courbes.count=0)) then begin
               if ([gmValeurs]=modif)
                   then courbes.clear
                   else reset;
              setCoordonnee(miniX,maxiX);
        end;
        if grapheOK and not useDefaut and (Pages[pageCourante].nmes>0) then begin
           miniTemps := Pages[pageCourante].valeurVar[0,0];
           maxiTemps := Pages[pageCourante].valeurVar[0,pred(Pages[pageCourante].nmes)];
        end;
        if grapheOK then chercheMonde;
        draw;
        if grapheOK then modif := [];
end;

procedure TgrapheVariab.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: single);

procedure AffecteDessinText;
begin
 if dessinTextCourant<>nil then begin
   dessinTextCourant.affecteXY(x,y);
   if dessinTextCourant.litOption
   then begin
      dessinTexts.Add(DessinTextCourant);
      ModifFichier := true;
   end
   else dessinTextCourant.free;
   dessinTextCourant := nil;
 end;
 setPenBrush(curSelect);
end; // AffecteDessinText

procedure AfficheSelection;
begin
          selection.Position.x := origin.X;
          selection.Position.y := origin.Y;
          selection.width := 0;
          selection.height := 0;
          selection.Visible := true;
          selection.BringToFront;
end;

var iProche : integer;
begin // MouseDown
   if not grapheOK then exit;
   origin.x := x;
   origin.Y := y;
   if (Button=TMouseButton.mbRight) then begin
      iPropCourbe := CourbeProche(origin);
      if iPropCourbe<0 then iPropCourbe := 0;
      if ((courbes[iPropCourbe].indexModele=0) or
          courbes[iPropCourbe].courbeExp) and
         (courbes[iPropCourbe].page=pageCourante)
         then begin
           FRegressiMain.ProprieteCourbe.visible := true;
           with courbes[iPropCourbe] do
                FRegressiMain.ProprieteCourbe.Text := stCaracDe+varY.nom+'=f('+varX.nom+')';
         end;
      FRegressiMain.IncertItem.IsChecked  := TraceEllipse;
      FRegressiMain.LegendeItem.IsChecked := ShowLegend;
      exit; // clic droit donc menu contextuel
   end;
   convertitXY(sender,X,Y);
   origin.x := x;
   origin.Y := y;
   if (sender is TBorneShape) then begin
      BorneSelect := sender as TborneShape;
      BorneSelect.isSelected := true;
   end;
   if (Button = TMouseButton.mbMiddle) or
      ((Button = TMouseButton.mbLeft) and SpaceHeld and (curseur = curSelect) and (borneSelect = nil)) then begin
      FPanActive := True;
      FPanPrevCurseur := curseur;
      FPanLastPos := origin;
      setPenBrush(curMove);
      exit;
   end;
   case curseur of
       curReticuleModele : ;
       curZoomAv,curBornes,curEfface : afficheSelection;
       curLigne : if (dessinLineCourant<>nil) then
          dessinLineCourant.affectePoint1(x,y);
       curTexte : affecteDessinText;
       curReticule : if not(ssDouble in shift) then if curseurCourant=1
            then begin   // active deuxième curseur pour différence
                curseurOsc[2].Pc := origin;
                curseurOsc[2].mondeC := curseurOsc[1].mondeC;
                curseurOsc[2].Visible := true;
                curseurOsc[2].bringToFront;
                curseurCourant := 2;
                paintBox.repaint; // pour les écarts
            end
            else begin // désactive deuxième curseur
                 curseurOsc[2].Visible := false;
                 curseurCourant := 1;
            end;
       curSelect : if (Button = TMouseButton.mbLeft) and (borneSelect=nil) and LegendHitTest(origin) then begin
              FLegendDragging := True;
              FLegendDragDelta := TPointF.Create(origin.X - FLegendRect.Left, origin.Y - FLegendRect.Top);
              paintBox.Cursor := crSizeAll;
       end
       else if curMovePermis and (borneSelect=nil) then begin
              FPanActive := True;
              FPanPrevCurseur := curSelect;
              FPanLastPos := origin;
              setPenBrush(curMove);
       end; // curSelect
       curEquivalence : if (ligneRappelTangente in [lrEquivalence, lrTangente]) and
                           (indexCourbeEquivalence >= 0) and (indexCourbeEquivalence < courbes.Count) then begin
           iproche := PointProche(origin,indexCourbeEquivalence,true,ligneRappelTangente=lrTangente);
           if iProche>=0 then begin
              AjouteEquivalence(iProche,true);
              paintBox.repaint;
           end;
           setPointCourant(iProche,indexCourbeEquivalence);
       end;
       curReticuleData : begin
          GetCurseurProche(origin,true);
          setSegmentInt(origin);
          SetPointCourant(curseurOsc[curseurCourant].Ic,0);
       end;
  end // case curseur
end; // PaintBoxMouseDown

procedure TgrapheVariab.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: single);

procedure AffecteDessinLine;
begin
if dessinLineCourant<>nil then
with dessinLineCourant do begin
   affectePoint2(x,y);
   if (abs(width)+abs(height))>3
   then begin
      dessinLines.Add(DessinLineCourant);
      ModifFichier := true;
   end
   else begin
      afficheErreur(erLigneNulle,0);
      dessinLineCourant.free;
   end;
end;
   dessinLineCourant := nil;
   setPenBrush(curSelect);
end; // AffecteDessinLine

Procedure affecteEfface;
var xfin,xdebut,yfin,ydebut : double;
    indexPoint : integer;
    modifNbre : boolean;
    p : codePage;
    APoint : TPointF;
begin
    if (selection.width=0) or (selection.height=0)
        then begin
            APoint := TPointF.create(x,y);
            indexPoint := PointProche(APoint,0,true,false);
            modifNbre := indexPoint>=0;
            if modifNbre then Pages[pageCourante].SupprimeLignes(indexPoint,indexPoint);
        end
        else begin
            APoint := TPointF.create(selection.position.x,selection.position.y);
            MondeRT(APoint,mondeY,xfin,yfin);
            APoint.Offset(selection.width,selection.height);
            MondeRT(APoint,mondeY,xdebut,ydebut);
            with coordonnee[1] do
                 ModifNbre := pages[pageCourante].EffacePage(xdebut,ydebut,xfin,yfin,codeX,codeY);
            if superposePage and (NbrePages>1) and OKreg(okSupprAutresPages,0) then
                 for p := 1 to NbrePages do if p<>pageCourante then with pages[p] do
                     if active then with coordonnee[1] do
                        EffacePage(xdebut,ydebut,xfin,yfin,codeX,codeY);
        end;
   if modifNbre then FRegressiMain.WMRegMaj(MajSupprPoints);
   setPenBrush(curSelect);
end; // affecteEfface

Procedure affecteOrigine;
var y0 : double;
    j,indexX : integer;
begin
   MondeRT(TpointF.create(x,0),mondeY,xOrigine,y0);
   setPenBrush(curSelect);
   indexX := coordonnee[1].codeX;
   with pages[pageCourante] do
        for j := 0 to pred(nmes) do
            valeurVar[indexX,j] := valeurVar[indexX,j]-xOrigine;
   FRegressiMain.WMRegMaj(MajValeur);
end; // affecteOrigine

procedure AffecteVecteur;
var j,iProche : integer;
    ib : integer;
    p : tpointF;
begin
    for j := 0 to pred(courbes.count) do with courbes[j] do
        if (trVitesse in trace) or (trAcceleration in trace) then begin
            P.create(x,y);
            iProche := PointProche(p,j,true,false);
             if (iProche>=0) and (iProche<256) then begin
                ib := byte(iProche);
                if ib in PointSelect
                   then exclude(PointSelect,ib)
                   else include(PointSelect,ib);
                break;
             end;
    end;
end; // AffecteVecteur

procedure AffecteUneBorne;
begin
   if setBorne(origin) then
     if [ModeleConstruit,ModeleLineaire] <= etatModele
         then FregressiMain.lanceModele(true)
         else ;
end;

Procedure affecteZoomAv;
begin
   setPenBrush(curSelect);
   if (selection.width=0) or
      (selection.Height=0) then exit;
   affecteZoomAvant(true);
   curMovePermis := true;
   include(modif,gmEchelle);
end; // affecteZoomAvant

Procedure affecteBornes;
var x1,x2,y1,y2 : double;
    i : integer;
    indexX,indexY : integer;
    mSelect,m : indiceMonde;
begin
        setPenBrush(curSelect);
        if (selection.width=0) or (selection.height=0) then exit;
        with pages[pageCourante] do begin
             debut[BorneActive] := pred(nmes);
             fin[BorneActive] := 0;
             indexX := indexNom(monde[mondeX].axe.nom);
             indexY := grandeurInconnue;
             mSelect := mondeY;
             if BorneActive<=NbreModele then
                for m := mondeY to mondeSans do
                  if  (monde[m].axe<>nil) and
                      (fonctionTheorique[BorneActive].indexY=
                       indexNom(monde[m].axe.nom))
                  then begin
                     indexY := indexNom(monde[m].axe.nom);
                     mSelect := m;
                     break;
                  end;
             if indexY=grandeurInconnue then
                for m := mondeY to mondeSans do
                    if monde[m].axe<>nil then begin
                       indexY := indexNom(monde[m].axe.nom);
                       mSelect := m;
                       break;
                    end;
             MondeRT(TpointF.create(selection.position.x,selection.Position.Y),mSelect,x1,y1);
             MondeRT(TpointF.create(selection.Position.X+selection.width,
                                    selection.position.y+selection.height),mSelect,x2,y2);
             for i := 0 to pred(nmes) do
                 if ((valeurVar[indexX,i]-x1)*(valeurVar[indexX,i]-x2)<0) and
                    ((valeurVar[indexY,i]-y1)*(valeurVar[indexY,i]-y2)<0)
                 then begin
                    if debut[BorneActive]>i then debut[BorneActive] := i;
                    if fin[BorneActive]<i then fin[BorneActive] := i;
                 end;
             if BorneActive=succ(NbreModele) then begin
                   FonctionTheorique[succ(NbreModele)].indexX := indexX;
                   FonctionTheorique[succ(NbreModele)].indexY := indexY;
                   if ChoixModeleDlg = nil then
                      Application.CreateForm(TChoixModeleDlg, ChoixModeleDlg);
                   ChoixModeleDlg.coordonnee := coordonnee;
                   ChoixModeleDlg.appelMagnum := false;
                   ChoixModeleDlg.appelRGS := false;
                   ChoixModeleDlg.PageControl.ActiveTab := ChoixModeleDlg.ModManuel;
                   CentreForm(choixModeleDlg);
                   if ChoixModeleDlg.showModal=mrOk then
                      if ChoixModeleDlg.modeleChoisi=mgManuel
                         then begin
                           if ChoixModeleDlg.effaceModele then FRegressiMain.MemoModele.lines.clear;
                           with FonctionTheorique[NbreModele] do
                           if enTete<>'' then begin
                              FRegressiMain.MemoModele.lines.Add(enTete+'='+expression);
                              FRegressiMain.lanceModele(genreC=g_fonction);
                              exit;
                           end
                         end
                         else FRegressiMain.ModeleMagnum(false);
             end
        end;
        if ModeleDefini in etatModele then
           if [ModeleConstruit,ModeleLineaire] <= etatModele
               then FRegressiMain.lanceModele(true)
               else begin
                  pages[pageCourante].ModeleCalcule := false;
                  pages[pageCourante].ModeleErrone := false;
                  include(modif,gmModele);
               end;
end; // affecteBornes

var P : TpointF;
begin // MouseUp
  if (x<0) or (y<0) or not(grapheOK) then exit;
  convertitXY(sender,x,y);
  origin.x := x;
  origin.Y := y;
  if Button=TMouseButton.mbRight then begin
      P.create(x,y);
      iPropCourbe := CourbeProche(p);
      if (iPropCourbe>=0) and
         ((courbes[iPropCourbe].indexModele=0) or
           courbes[iPropCourbe].courbeExp) and
         (courbes[iPropCourbe].page=pageCourante) then begin
            FRegressiMain.ProprieteCourbeClick(nil);
         end// caractéristiques de la courbe
         else
         if not (curseur in [curReticule,curReticuleData] )
             then FRegressiMain.MenuAxes.popUp(
                 P.X+FRegressiMain.panelCentral.position.x,
                 P.y+FRegressiMain.panelCentral.position.y);
     exit;
  end; // bouton droit
  if FLegendDragging then begin
     FLegendDragging := False;
     paintBox.Cursor := crDefault;
     paintBox.Repaint;
     exit;
  end;
  if (sender is TBorneShape) then BorneSelect := sender as TborneShape;
  case curseur of
       curReticuleModele : paintBox.repaint;
       curZoomAv : affecteZoomAv;
       curBornes : affecteBornes;
       curEfface : affecteEfface;
       curTexte : ;
       curLigne : affecteDessinLine;
       curSelect : begin
          if borneSelect<>nil
             then affecteUneBorne
             else if UseSelect then affecteVecteur;
          dessinLineCourant := nil;
          dessinTextCourant := nil;
       end;
       curReticuleData : ;
       curReticule : ;
       curEquivalence : ;
       curMove : begin FPanActive := False; setPenBrush(FPanPrevCurseur); end;
       curOrigine : affecteOrigine;
  end;
  paintBox.repaint;
end; // MouseUp

procedure TgrapheVariab.PaintBoxMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
var
  P: TPointF;
begin
  if not grapheOK then Exit;
  if Screen <> nil then
    P := paintBox.ScreenToLocal(Screen.MousePos)
  else
    P := origin;
  AffecteZoomWheel(WheelDelta, P);
  curMovePermis := True;
  include(modif, gmEchelle);
  paintBox.Repaint;
  Handled := True;
end;

constructor TgrapheResidu.Create(apaintBox : TPaintBox);
begin
  inherited create(apaintBox);
end;

constructor TgrapheVariab.Create(apaintBox : TPaintBox);

procedure CreateAnimation;
var i : integer;
begin
     InitManuelleAfaire := true;
     for i := 0 to maxParamAnimation do
         paramAnimation[i] := TparamAnimation.create;
     NbrePasAnimation := 100;
     paramAnimCourant := 0;
end;

var m : codeIntervalle;
    j : integer;
begin
  inherited create(aPaintBox);
  for j := 1 to maxIntervalles do begin
      BorneDebut[j] := TBorneShape.create(paintBox);
      BorneFin[j] := TBorneShape.create(paintBox);
      BorneDebut[j].visible := false;
      BorneDebut[j].IndexModele := j;
      BorneFin[j].IndexModele := j;
      BorneFin[j].visible := false;
      BorneDebut[j].genre := bsDebut;
      BorneFin[j].genre := bsFin;
  end;
  BorneSelect := nil;
  curseur := curSelect;
  FPanActive := False;
  FPanPrevCurseur := curSelect;
  SpaceHeld := False;
  VerifGraphe := true;
  for m := 1 to MaxIntervalles do  begin
      BorneDebut[m].SetMoveDown(PaintBoxMouseMove,PaintBoxMouseDown,PaintBoxMouseUp);
      BorneFin[m].SetMoveDown(PaintBoxMouseMove,PaintBoxMouseDown,PaintBoxMouseUp);
      valeurDeriveeX[m] := nil;
  end;
  for j := 1 to MaxCurseur do
      CurseurOsc[j].SetMoveDown(PaintBoxMouseMove,PaintBoxMouseDown,PaintBoxMouseUp);
  ReticuleOrigine.SetMoveDown(PaintBoxMouseMove,PaintBoxMouseDown,PaintBoxMouseUp);
  Selection.SetMoveDown(PaintBoxMouseMove,PaintBoxMouseDown,PaintBoxMouseUp);
  CreateAnimation;
end; // grapheVariab.Create

procedure TgrapheVariab.SetCoordonnee;

var CourbeExpAffectee,SimulationAffectee,withModele : boolean;

Procedure AjouteVariab(m : indiceMonde;i : indiceOrdonnee;page : codePage);
var x,y : vecteur;
    c : integer;
    avecModele : boolean;
    courbeVariab,courbeAdd : Tcourbe;
    iX,iY : integer;
    traceV : TsetTrace;
    ligneV : Tligne;
    couleurModeleCourant : TAlphaColor;

Procedure AddIncert(Acourbe : Tcourbe);
begin
      with pages[page] do begin
         Acourbe.IncertX := incertVar[iX];
         Acourbe.IncertY := incertVar[iY];
      end;
end;

var j,cc : integer;
    CouleurModeleActive : boolean;
begin with pages[page] do begin
      if m>=MaxMonde then exit;
      with Coordonnee[i] do begin
           iX := CodeX;
           iY := CodeY;
           exclude(trace,trSonagramme);
           TraceV := trace;
           LigneV := ligne;
           if (LigneV=LiModele) and (NbreModele=0) then LigneV := LiDroite;
           couleurModeleCourant := couleur;
      end;
     if (grandeurs[iY].genreG in [constante,constanteGlb]) or
        (grandeurs[iX].genreG in [constante,constanteGlb]) then begin
              setLength(y,nmes);
              case grandeurs[iY].genreG of
                   constante : for j := 0 to pred(nmes) do y[j] := valeurConst[iY];
                   variable : copyVecteur(y,valeurVar[iY]);
                   constanteGlb : for j := 0 to pred(nmes) do y[j] := grandeurs[iY].valCourante;
              end;
              setLength(x,nmes);
              case grandeurs[iX].genreG of
                   constante : for j := 0 to pred(nmes) do x[j] := valeurConst[iX];
                   variable : copyVecteur(x,valeurVar[iX]);
                   constanteGlb : for j := 0 to pred(nmes) do x[j] := grandeurs[iX].valCourante;
              end;
              courbeVariab := AjouteCourbe(x,y,m,nmes,
                   grandeurs[iX],grandeurs[iY],page);
              if (grandeurs[iY].genreG in [constante,constanteGlb]) and
                 (grandeurs[iX].genreG in [constante,constanteGlb])
                   then courbeVariab.Trace := [trPoint]
                   else courbeVariab.Trace := [trLigne];
              courbeVariab.Adetruire := true;
              with Coordonnee[i] do
                   courbeVariab.setStyle(couleur,styleT,motif);
              exit;
      end;
      courbeVariab := AjouteCourbe(valeurVar[iX],valeurVar[iY],m,nmes,
                                   grandeurs[iX],grandeurs[iY],page);
      with coordonnee[i] do courbeVariab.setStyle(couleur,styleT,motif);
      AddIncert(courbeVariab);
      avecModele := false;
      if traceV=[] then TraceV := [trPoint];
      courbeVariab.Trace := TraceV;
      CouleurModeleActive := false;
// 2 modeles différents => on force des couleurs différentes
      for c := 2 to NbreModele do
          for cc := 1 to pred(c) do
              if (fonctionTheorique[c].indexY)=
                 (fonctionTheorique[cc].indexY) then begin
                     CouleurModeleActive := true;
                     break;
               end;
    if TrLigne in TraceV then case LigneV of
        LiModele : begin
                exclude(courbeVariab.Trace,trLigne);
                exclude(traceV,trPoint);
                exclude(traceV,trLigne);
                if ModeleDefini in etatModele then begin
                   for c := 1 to NbreModele do with fonctionTheorique[c] do
                      if (iY=indexY) and (iX=indexX) and not(implicite) then begin
                            if (debut[c]>0) or
                               (fin[c]<pred(nmes)) or
                               CouleurModeleActive then begin
                                courbeAdd := AjouteCourbe(valeurVar[iX],valeurVar[iY],
                                         m,nmes,grandeurs[iX],grandeurs[iY],page);
                                courbeAdd.debutC := debut[c];
                                courbeAdd.finC := fin[c];
                                courbeAdd.trace := [trPoint];
                                courbeAdd.courbeExp := true;
                                courbeAdd.IndexModele := c;
                                AddIncert(courbeAdd);
                                CourbeExpAffectee := true;
                                couleurModeleCourant := couleurModele[c];
                                couleurM := couleurModele[c];
                                with coordonnee[i] do
                                     courbeAdd.setStyle(couleurModeleCourant,styleT,motif);
                                ModeleGraphique[c].couleur := couleurModeleCourant;
                            end
                            else begin // UN modele sur toute les donnees
                               courbeVariab.courbeExp := true;
                               courbeVariab.IndexModele := c;
                               courbeExpAffectee := true; { ?? }
                               with coordonnee[i] do courbeVariab.setStyle(couleur,styleT,motif);
                               if NbreModele>1 then couleurModeleCourant := couleurModele[c];
                               ModeleGraphique[c].couleur := couleurModeleCourant;
                            end; // modele sur toute les donnees
                            if modeleCalcule then begin
                               setlength(x,NmesMax+1);
                               setLength(y,NmesMax+1);
                               if c=1 then begin
                                  indexCourbeModele := courbes.count-1;
                               end;
                               courbeAdd := AjouteCourbe(x,y,m,nmes,
                                             grandeurs[iX],grandeurs[iY],page);
                               courbeAdd.IndexModele := c;
                               AvecModele := true;
                               if coordonnee[i].motif=mHisto
                                  then begin
                                      courbeAdd.Trace := [trPoint];
                                      courbeAdd.setStyle(couleurModele[c],TStrokeDash.Solid,mHisto);
                                      couleurModeleCourant := courbeAdd.couleur;
                                  end
                                  else begin
                                      courbeAdd.Trace := [trLigne];
                                      with coordonnee[i] do
                                           courbeAdd.setStyle(couleurModeleCourant,styleT,motif);
                                  end;
                               courbeAdd.Adetruire := true;
                               ModeleGraphique[c].couleur := couleurModeleCourant;
                               if c=1 then courbeModele := courbeAdd;
                               // lineaireVar
                            end;
           end; // for c de ModeleDefini
           if not(avecModele) and
                  (ModeleDefini in etatModele) and
                   modeleCalcule and
                   (NbreModele=2) and
                   (fonctionTheorique[1].genreC=g_fonction) and
                   (fonctionTheorique[1].indexX=0) and
                   (fonctionTheorique[2].indexX=0) and
                   (((fonctionTheorique[1].indexY=iY) and
                     (fonctionTheorique[2].indexY=iX)) or
                    ((fonctionTheorique[1].indexY=iX) and
                     (fonctionTheorique[2].indexY=iY))) then begin
                               setLength(x,System.Math.Max(NmesMax+1,2048));
                               setLength(y,System.Math.Max(NmesMax+1,2048));
                               courbeAdd := AjouteCourbe(x,y,m,nmes,
                                          grandeurs[iX],grandeurs[iY],page);
                               AvecModele := true;
                               courbeAdd.ModeleParametrique := true;
                               CourbeAdd.ModeleParamX1 := fonctionTheorique[1].indexY=iX;
                               courbeAdd.Trace := [trLigne];
                               courbeAdd.Adetruire := true;
                               with coordonnee[i] do
                                    courbeAdd.setStyle(couleurModeleCourant,styleT,motif);
                               ModeleGraphique[1].couleur := couleurModeleCourant;
                               ModeleGraphique[2].couleur := couleurModeleCourant;
                end; // Modele parametrique
           if not(avecModele) and
                  (ModeleDefini in etatModele) and
                   modeleCalcule and
                   (NbreModele=1) and
                   (fonctionTheorique[1].genreC=g_fonction) and
                   (fonctionTheorique[1].indexX=0) and
                   (((fonctionTheorique[1].indexY=iY) and
                     (fonctionTheorique[1].indexYp=iX)) or
                    ((fonctionTheorique[1].indexY=iX) and
                     (fonctionTheorique[1].indexYp=iY))) then begin
                               setlength(x,NmesMax+1);
                               setlength(y,NmesMax+1);
                               courbeAdd := AjouteCourbe(x,y,m,nmes,
                                  grandeurs[iX],grandeurs[iY],page);
                               AvecModele := true;
                               courbeAdd.PortraitDePhase := true;
                               CourbeAdd.ModeleParamX1 := fonctionTheorique[1].indexY=iX;
                               courbeAdd.Trace := [trLigne];
                               with coordonnee[i] do
                                    courbeAdd.setStyle(couleurModeleCourant,styleT,motif);
                               courbeAdd.Adetruire := true;
                               ModeleGraphique[1].couleur := couleurModeleCourant;
                end; // Portrait de phase avec fonction
          if not(avecModele) and
                (ModeleDefini in etatModele) and
                   modeleCalcule and
                   (NbreModele=1) and
                   (fonctionTheorique[1].genreC=g_diff2) and
                   (fonctionTheorique[1].indexX=0) and
                   (((fonctionTheorique[1].indexYp=iY) and
                     (fonctionTheorique[1].indexY=iX)) or
                    ((fonctionTheorique[1].indexYp=iX) and
                     (fonctionTheorique[1].indexY=iY))) then begin
                               setlength(x,nmesMax+1);
                               setlength(y,nmesMax+1);
                               courbeAdd := AjouteCourbe(x,y,m,nmes,
                                  grandeurs[iX],grandeurs[iY],page);
                               AvecModele := true;
                               courbeAdd.PortraitDePhase := true;
                               CourbeAdd.ModeleParamX1 := fonctionTheorique[1].indexY=iX;
                               courbeAdd.Trace := [trLigne];
                               with coordonnee[i] do
                                   courbeAdd.setStyle(couleurModeleCourant,styleT,motif);
                               courbeAdd.Adetruire := true;
                               ModeleGraphique[1].couleur := couleurModeleCourant;
                         end; // Portrait de phase équa diff
                end; // modeleDefini
                if not(avecModele) and
                   (NbreModele>0) and
                   fonctionTheorique[1].implicite then begin
                   setlength(x,NmesMax+1);
                   setLength(y,NmesMax+1);
                   courbeAdd := AjouteCourbe(x,y,m,nmes,
                      grandeurs[iX],grandeurs[iY],page);
                   courbeAdd.IndexModele := 1;
                   AvecModele := true;
                   courbeAdd.Trace := [trLigne];
                   courbeAdd.Adetruire := true;
                   with coordonnee[i] do
                        courbeAdd.setStyle(couleurModele[1],styleT,motif);
                   courbeModele := courbeAdd;
//                   indexCourbeModele := courbes.count-1;
                end;
                if not(avecModele) and
                   ((valeurLisse[iX]<>valeurVar[iX]) or
                    (valeurLisse[iY]<>valeurVar[iY]))
                        then begin
                            courbeAdd := AjouteCourbe(valeurLisse[iX],valeurLisse[iY],
                                m,nmes,grandeurs[iX],grandeurs[iY],page);
                            with coordonnee[i] do
                                courbeAdd.setStyle(couleur,styleT,motif);
                            courbeAdd.Trace := [trLigne];
                            courbeAdd.IndexModele := indexLisse;
                        end;
           if not(avecModele) and not(pasDeModele in etatModele) then
                   if (valeurLisse[iX]<>valeurVar[iX]) or
                      (valeurLisse[iY]<>valeurVar[iY])
                        then begin
                           courbeAdd := AjouteCourbe(valeurLisse[iX],valeurLisse[iY],
                                m,nmes,grandeurs[iX],grandeurs[iY],page);
                            with coordonnee[i] do
                                courbeAdd.setStyle(couleur,styleT,motif);
                            courbeAdd.Trace := [trLigne];
                            courbeAdd.IndexModele := indexLisse;
                        end;
        end;
        LiSpline,LiSinc : if (pages[page].nmes<maxVecteurDefaut) then begin
              courbeVariab.courbeExp := true;
              courbeVariab.optionLigne := ligneV;
        end;
    end; // case ligneV
    if (SimulationDefinie in etatModele) and
       withModele then
       for c := 1 to NbreFonctionSuper do with fonctionSuperposee[c] do
           if (iY=indexY) and (iX=indexX) then begin
                 setLength(x,nmesMax+1);
                 setLength(y,nmesMax+1);
                 courbeAdd := AjouteCourbe(x,y,m,nmes,
                    grandeurs[iX],grandeurs[iY],page);
                 courbeAdd.IndexModele := -c;
                 with coordonnee[i] do
                      courbeAdd.setStyle(couleurModele[-c],styleT,motif);
                 courbeAdd.Trace := [trLigne];
                 courbeAdd.Adetruire := true;
                 SimulationAffectee := true;
           end; // for c de SimulationDefini
    if TraceV<>[] then begin
       courbeVariab.trace := courbeVariab.trace+traceV;
       if avecModele and ([trVitesse,trAcceleration]*traceV<>[]) then begin
          courbeAdd := AjouteCourbe(valeurLisse[iX],valeurLisse[iY],
                         m,nmes,grandeurs[iX],grandeurs[iY],page);
          with coordonnee[i] do
               courbeAdd.setStyle(couleur,styleT,motif);
          courbeAdd.Trace := [];
          if trVitesse in traceV then begin
             include(courbeAdd.Trace,trVitesse);
             exclude(courbeVariab.Trace,trVitesse);
          end;
          if trAcceleration in traceV then begin
             include(courbeAdd.Trace,trAcceleration);
             exclude(courbeVariab.Trace,trAcceleration);
          end;
       end;
    end;
    withModele := withModele or avecModele;
end end; // AjouteVariab

procedure VerifCoordonnee;
var i : integer;
begin
    nbreOrdonnee := 0;
    for i := 1 to maxOrdonnee do with coordonnee[i] do begin
        codeY := indexNom(nomY);
        if codeY<>grandeurInconnue
           then monde[iMondeC].axe := grandeurs[codeY];
        codeX := indexNom(nomX);
        if codeX<>grandeurInconnue then
           monde[mondeX].axe := grandeurs[codeX];
        if (codeY<>grandeurInconnue) and
           (codeX<>grandeurInconnue) then inc(nbreOrdonnee);
    end;
    if (nbreOrdonnee=0) and (nbreVariab>1) then begin
        with coordonnee[1] do begin
          codeX := 0; codeY := indexVariab[1];
          nomX := grandeurs[codeX].nom;
          nomY := grandeurs[codeY].nom;
          monde[mondeX].axe := grandeurs[codeX];
          monde[iMondeC].axe := grandeurs[codeY];
        end;
        nbreOrdonnee := 1;
    end;
end;

var
  i,n : integer;
  p : codePage;
  courbeAdd : Tcourbe;
  x,y : vecteur;
  mondeLoc : indiceMonde;
begin // SetCoordonnee
   orthoAverifier := true;
   withModele := FCoordonneesPhys.ModeleEnCours;
   VerifCoordonnee;
   courbeModele := nil;
   indexCourbeModele := -1;
   CourbeExpAffectee := false;
   SimulationAffectee := false;
   mondeLoc := mondeY;
   Fvaleurs.majGridVariab := Pages[pageCourante].triAfaire;
   for p := 1 to NbrePages do Pages[p].tri;
   for i := 1 to maxOrdonnee do with Coordonnee[i] do
     if (codeX<>grandeurInconnue) and (codeY<>grandeurInconnue) then begin
        if superposePage and
           (NbrePages>1) and
           (OgAnalyseurLogique in OptionGraphe) then mondeLoc := mondeY;
        if OgPolaire in OptionGraphe then begin
            iMondeC := mondeY;
            if (i=1) then if codeY=grandeurInconnue
                  then monde[mondeY].Axe := nil
                  else monde[iMondeC].Axe := grandeurs[codeY];
        end;
        if withModele then begin
              include(trace,trLigne);
              ligne := liModele;
              include(trace,trPoint);
        end;
        superposePage := superposePage and (NbrePages>1);
        if superposePage then begin
           N := 0;
           for p := 1 to NbrePages do
               if pages[p].active then inc(N);
           superposePage := N>1;
           if N=0 then pages[pageCourante].Active := true;
        end;
        if superposePage
           then for p := 1 to NbrePages do begin
              if pages[p].active then
                 if OgAnalyseurLogique in OptionGraphe
                      then begin
                          AjouteVariab(mondeLoc,i,p);
                          inc(mondeLoc);
                      end
                      else AjouteVariab(iMondeC,i,p)
           end
           else AjouteVariab(iMondeC,i,pageCourante);
     end;
   if (ModeleDefini in etatModele) and
      withModele and
      not(CourbeExpAffectee) then with courbes[0] do begin
              courbeAdd := AjouteCourbe(
                   valX,valY,iMondeC,pages[page].nmes,
                   varX,varY,page);
              courbeAdd.debutC := pages[page].debut[1];
              courbeAdd.finC := pages[page].fin[1];
              courbeAdd.trace := [trPoint];
              with pages[page] do begin
                 courbeAdd.IncertX := incertVar[varX.indexG];
                 courbeAdd.IncertY := incertVar[varY.indexG];
              end;
              with Coordonnee[1] do
                   courbeAdd.setStyle(couleur,styleT,motif);
              courbeAdd.courbeExp := true;
              courbeAdd.indexModele := 1;
   end;
   if (SimulationDefinie in etatModele) and
      FCoordonneesPhys.ModeleEnCours and
       not(SimulationAffectee) and
       (courbes.count>0) then begin
                 i := courbes.count;
                 repeat dec(i)
                 until (i<0) or
                       (fonctionSuperposee[1].indexY=courbes[i].varY.indexG);
                 if i>=0 then begin
                    setLength(x,pages[pageCourante].nmesMax+1);
                    setLength(y,pages[pageCourante].nmesMax+1);
                    courbeAdd := AjouteCourbe(x,y,
                         courbes[i].iMondeC,pages[pageCourante].nmes,
                         courbes[i].varX,courbes[i].varY,pageCourante);
                    courbeAdd.IndexModele := -1;
                    fonctionSuperposee[1].indexX := courbes[i].varX.indexG;
                    with coordonnee[i] do
                        courbeAdd.setStyle(couleurModele[-1],styleT,motif);
                    courbeAdd.Trace := [trLigne];
                    courbeAdd.Adetruire := true;
                 end;   
   end;
   modif := [gmEchelle];
   grapheOK := true;
end; // SetCoordonnee

procedure TgrapheVariab.ImprimerGraphe(var bas : single);
begin
     versImprimante(bas);
end;

procedure TgrapheVariab.PaintBoxPaint;

procedure MajIntersection;
var i,j : integer;
    equ : Tequivalence;
    trouve,correct : boolean;
    xr,yr : double;
begin
  if (PageCourante < 1) or (PageCourante > MaxPages) then exit;
  if not traceIntersection or (NbreModele<2) then begin // suppression
       j := 0;
       while j<equivalences[pageCourante].count do begin
         equ := equivalences[pageCourante].items[j];
         if (lrReticule in equ.ligneRappel) and (equ.isIntersection)
            then equivalences[pageCourante].Delete(j)
            else inc(j);
       end;
       exit;
  end;
  for i := 2 to nbreModele do begin
        trouve := false;
        xr := pages[pageCourante].X_inter[i];
        yr := pages[pageCourante].Y_inter[i];
        Correct := not isNan(xr) and not isNan(yr);
        for j := 0 to Pred(equivalences[pageCourante].count) do begin
             equ := equivalences[pageCourante].items[j];
             if (lrReticule in equ.ligneRappel) and (equ.isIntersection) then begin
                trouve := true;
                if correct then begin
                   equ.ve := xr;
                   equ.phe := yr;
                end
                else equivalences[pageCourante].Delete(j);
                break;
             end;
        end;
        if not trouve and Correct then begin
                equ := Tequivalence.CreateEq(xr,yr,0,self);
                equ.mondepH := mondeY;
                equ.isIntersection := true;
                equ.ligneRappel := [lrReticule];
                ligneRappelCourante := lrReticule;
                Equivalences[pageCourante].Add(equ);
        end;
  end;
end; // MajIntersection

Procedure TestModif;
var i : integer;
begin
        if (([gmXY,gmModele,gmPage,gmValeurs]*modif)<>[]) or
           (courbes.count=0)
            then begin
              courbes.clear;
              if ([gmValeurs]<>modif) then begin
                 monde[mondeX].defini := False;
                 AutoTick  := True;
                 for i := mondeX to mondeSans do begin
                     if not useDefaut then monde[i].reset(false);
                     monde[i].axe := nil;
                 end;
              end;
              setCoordonnee;
              if UseDefaut then begin
                  monde[mondeX].defini := true;
                  for i := 1 to maxOrdonnee do with Coordonnee[i] do
                      if codeX<>grandeurInconnue then
                         monde[iMondeC].defini := true;
              end;
            end;
end;

procedure effaceBornes;
var i : integer;
begin
    for i := 1 to maxIntervalles do begin
        borneDebut[i].Visible := false;
        borneFin[i].Visible := false;
    end;
end;

procedure traceBornes;
var i : integer;
    P : TPointF;
    hasVertBounds : boolean;
    minXLeft, maxXRight, x1, x2 : single;
begin
 hasVertBounds := False;
 minXLeft := limiteCourbe.Right;
 maxXRight := limiteCourbe.Left;
 for i := 0 to pred(Courbes.Count) do with courbes[i] do begin
 if courbeExp and (page=pageCourante) then begin
      if (indexModele>0) then begin // (debutC > 0)
        borneDebut[indexModele].stroke.color := couleur;
        borneDebut[indexModele].fill.color := couleur;
        borneDebut[indexModele].visible := true;
        borneDebut[indexModele].indexCourbe := i;
        borneDebut[indexModele].haut := limiteCourbe.top;
        borneDebut[indexModele].bas := limiteCourbe.bottom;
        borneDebut[indexModele].avecVert :=
              fonctionTheorique[indexModele].variableEgalAbscisse and
             (fonctionTheorique[indexModele].indexX = indexTri);
        if borneDebut[indexModele]<>borneSelect then begin
           WindowRT(valX[debutC], valY[debutC], iMondeC, P);
           borneDebut[indexModele].centre := P;
        end;
        borneDebut[indexModele].bringToFront;
      end;
      if (indexModele>0) then begin // (finC < pred(pages[page].nmes))
        borneFin[indexModele].stroke.color := couleur;
        borneFin[indexModele].fill.color := couleur;
        borneFin[indexModele].visible := true;
        borneFin[indexModele].indexCourbe := i;
        borneFin[indexModele].haut := limiteCourbe.top;
        borneFin[indexModele].bas := limiteCourbe.bottom;
        borneFin[indexModele].avecVert :=
              fonctionTheorique[indexModele].variableEgalAbscisse and
             (fonctionTheorique[indexModele].indexX = indexTri);
        if borneFin[indexModele]<>borneSelect then begin
           WindowRT(valX[finC], valY[finC], iMondeC, P);
           borneFin[indexModele].centre := P;
        end;
        borneFin[indexModele].bringToFront;
        if borneDebut[indexModele].avecVert and borneFin[indexModele].avecVert then begin
           x1 := Min(borneDebut[indexModele].centre.X, borneFin[indexModele].centre.X);
           x2 := Max(borneDebut[indexModele].centre.X, borneFin[indexModele].centre.X);
           if not hasVertBounds then begin
              minXLeft := x1;
              maxXRight := x2;
              hasVertBounds := True;
           end else begin
              if x1 < minXLeft then minXLeft := x1;
              if x2 > maxXRight then maxXRight := x2;
           end;
        end;
      end;
    end; // bornes
    end;// with courbes
 if hasVertBounds then begin
    if minXLeft < limiteCourbe.Left then minXLeft := limiteCourbe.Left;
    if minXLeft > limiteCourbe.Right then minXLeft := limiteCourbe.Right;
    if maxXRight < limiteCourbe.Left then maxXRight := limiteCourbe.Left;
    if maxXRight > limiteCourbe.Right then maxXRight := limiteCourbe.Right;
    canvas.Fill.Kind := TBrushKind.Solid;
    canvas.Fill.Color := TAlphaColor($141E293B);
    if minXLeft > limiteCourbe.Left + 1 then
       canvas.FillRect(TRectF.Create(limiteCourbe.Left, limiteCourbe.Top,
                                     minXLeft, limiteCourbe.Bottom), 0, 0, [], 1);
    if maxXRight < limiteCourbe.Right - 1 then
       canvas.FillRect(TRectF.Create(maxXRight, limiteCourbe.Top,
                                     limiteCourbe.Right, limiteCourbe.Bottom), 0, 0, [], 1);
    canvas.Fill.Kind := TBrushKind.None;
 end;
end; // traceBornes


begin // PaintBoxPaint
        if lecturePage then exit;
        grapheOK := (NbreVariab>1) and (NbrePages>0);
        if not grapheOK then begin
           reset;
           optionGraphe := optionGrapheDefault;
        end;
        if grapheOK then TestModif;
        if not useDefaut and (Pages[pageCourante].nmes>0) then begin
           miniTemps := Pages[pageCourante].valeurVar[0,0];
           maxiTemps := Pages[pageCourante].valeurVar[0,pred(Pages[pageCourante].nmes)];
        end;
        if grapheOK and
           (gmEchelle in modif) or
           (gmValeurModele in modif) or
           ((gmPage in modif) and
             pages[pageCourante].modeleCalcule)
               then AffecteModele;
        if grapheOK then chercheMonde;
        if grapheOK and ((gmEchelle in modif) or (pages[pageCourante].nmes<128)) and
           (omExtrapole in OptionModele)
           then begin
              ZoomModele;
              ZoomSuperpose;
           end;
        limiteFenetre := TRectF.create(0,0,paintBox.width,paintBox.height);
        MajIntersection;
        draw;
        effaceBornes;
        if FCoordonneesPhys.ModeleEnCours then traceBornes;
        setPenBrush(curseur);
        if grapheOK then begin
           modif := [];
           if orthoAverifier and VerifierOrtho then begin
              afficheErreur(erOrtho,0);
              verifierOrtho := false;
              orthoAverifier := false;
           end;
           if VerifierLog then begin
             afficheErreur(erAxeLog,0);
             verifierLog := false;
           end;
        end;
        if curseur<>curMove then begin
           IndexPointCourant := -1;
           CourbePointCourant := 0;
        end;
        if (PropCourbeForm<>nil) and
           PropCourbeForm.visible and
           grapheOK then begin
              if (iPropCourbe>=courbes.Count) or
                 (iPropCourbe<0) then iPropCourbe := 0;
              PropCourbeForm.Acourbe := courbes[iPropCourbe];
              PropCourbeForm.MaJ;
        end;
        if curseur=CurReticuleModele then with curseurOsc[1] do begin
              indexCourbe := indexCourbeLigne;
              if indexCourbe >= 0 then
                mondeC := courbes[indexCourbe].iMondeC;
        end;
end; // PaintBoxPaint

destructor TgrapheResidu.Destroy;
begin
     dXresidu := nil;
     dYresidu := nil;
     inherited
end;

destructor TgrapheVariab.Destroy;
var m : codeIntervalle;
    i : integer;
begin
     for m := 1 to maxIntervalles do begin
         ValeurDeriveeX[m] := nil;
         ValeurYDiff[m] := nil;
         ValeurYpDiff[m] := nil;
         for i := 1 to maxParametres do
             libere(derf[m,i]);
     end;
     ValeurXDiff := nil;
     inherited destroy;
end;

Procedure TGrapheVariab.EcritConfigXML(Anode : IXMLNode);

procedure ecritDefaut;

procedure ecritMonde(m : indiceMonde);
var  DefautXML : IXMLNode;
begin with monde[m] do begin
       if useZoom then getMinMaxdefaut;
       DefautXML := ANode.AddChild(stDefaut);
       DefautXML.Attributes[stIndex] := intToStr(ord(m));
       writeFloatXML(DefautXML,'MinD',minDefaut);
       writeFloatXML(DefautXML,'MaxD',maxDefaut);
       writeFloatXML(DefautXML,'Delta',deltaAxe);
       writeIntegerXML(DefautXML,'NTicks',NTicks);
end end;

var m : IndiceMonde;
begin
    if useDefaut or
       useDefautX or
       useZoom then begin
       for m := mondeX to mondeDroit do
           ecritMonde(m);
    end;
end; // ecritDefaut

Procedure ecritAnimation;
var i : integer;
    AnimXML,ParamXML : IXMLNode;
begin
   AnimXML := Anode.AddChild('ANIMATION');
   writeBoolXML(AnimXML,'AnimationTemporelle',false);
   writeBoolXML(AnimXML,'AnimationManuelle',FregressiMain.AnimationBtn.isPressed);
   writeBoolXML(AnimXML,'TitreAnimation',FregressiMain.titreAnimCB.isChecked);
   writeIntegerXML(AnimXML,'NbreTick',round(FregressiMain.AnimationTB.value));
   writeIntegerXML(AnimXML,'NbreParamAnim',NbreParamAnimation);
   for i := 0 to pred(NbreParamAnimation) do begin
       ParamXML := AnimXML.AddChild('ParamAnim');
       ParamXML.Attributes[stIndex] := intToStr(i);
       paramAnimation[i].ecritXML(ParamXML);
   end;
end;

var i : integer;
    p : integer;
    OptionsXML,CoordXML : IXMLNode;
begin
   for i := 1 to NbreOrdonnee do with coordonnee[i] do begin
       CoordXML := ANode.AddChild('COORD');
       CoordXML.Attributes[stIndex] := intToStr(i);
       writeIntegerXML(CoordXML,'LIGNE',ord(ligne));
       writeColorXML(CoordXML,stCouleur,couleur);
       writeIntegerXML(CoordXML,'MOTIF',ord(Motif));
       writeStringXML(CoordXML,'X',coordonnee[i].nomX);
       writeStringXML(CoordXML,'Y',nomY);
       writeIntegerXML(CoordXML,'TRACE',word(Trace));
       writeIntegerXML(CoordXML,'MONDE',ord(iMondeC));
       writeIntegerXML(CoordXML,'GRADUATION',ord(monde[iMondeC].Graduation));
       writeIntegerXML(CoordXML,'ZERO',ord(monde[iMondeC].ZeroInclus));
   end;
   if useDefaut then begin
      writeBoolXML(Anode,'UseDefault',UseDefaut);
      writeFloatXML(ANode,'MINIT',miniTemps);
      writeFloatXML(Anode,'MAXIT',maxiTemps);
   end;
   writeBoolXML(Anode,'EchelleAutoAnim',EchelleAutoAnimation);
   OptionsXML := ANode.addChild('OPTIONS');
   writeIntegerXML(optionsXML,'OptGraphe',byte(optionGraphe));{1}
   writeIntegerXML(optionsXML,'OptModele',byte(optionModele));{2}
   writeBoolXML(optionsXML,'SuperPage',SuperposePage);
   writeBoolXML(optionsXML,'Ellipse',traceEllipse);
   writeBoolXML(optionsXML,'Intersection',traceIntersection);
   writeBoolXML(optionsXML,'ProjeteVecteur',projeteVecteur);
   writeBoolXML(optionsXML,'ProlongeVect',ProlongeVecteur);
   writeBoolXML(optionsXML,'CouleurVitesseImposee',couleurVitesseImposee);
   writeIntegerXML(optionsXML,'ReperePage',ord(reperePage));
   writeIntegerXML(optionsXML,'OrdreLissage',OrdreLissage);
   writeIntegerXML(optionsXML,'PenWidth',round(PenWidthEcran));
   ecritDefaut;
   for i := 0 to pred(DessinTexts.count) do begin
       OptionsXML := ANode.addChild('TEXTE');
       dessinTexts[i].StoreXML(OptionsXML);
   end;
   for i := 0 to pred(DessinLines.count) do begin
       OptionsXML := ANode.addChild('SHAPE');
       dessinLines[i].StoreXML(OptionsXML);
   end;
   for p := 1 to nbrePages do begin
       OptionsXML := writeBoolXML(ANode,'MODELECALC',Pages[p].ModeleCalcule);
       optionsXML.Attributes[stPage] := intToStr(p);
       for i := 0 to pred(Equivalences[p].count) do begin
          OptionsXML := ANode.addChild(stTangente);
          equivalences[p][i].StoreXML(OptionsXML);
          optionsXML.Attributes[stPage] := intToStr(p);
       end;
   end;
   if FregressiMain.animationBtn.isPressed or (NbreParamAnimation>0) then ecritAnimation;
end;  // ecritConfigXML

Procedure TgrapheVariab.ecritConfig;

Procedure EcritGraphe;
var i,p : integer;
begin
   ecritSousSection(NbreOrdonnee,'LIGNE');
   for i := 1 to NbreOrdonnee do
       ecritIntegerRW3(ord(coordonnee[i].ligne));
   ecritSousSection(NbreOrdonnee,'COULEUR');
   for i := 1 to NbreOrdonnee do
       ecritColorRW3(coordonnee[i].couleur);
   ecritSousSection(NbreOrdonnee,'MOTIF');
   for i := 1 to NbreOrdonnee do
       ecritIntegerRW3(ord(coordonnee[i].Motif));
   ecritSousSection(NbreOrdonnee,'X');
   for i := 1 to NbreOrdonnee do
       ecritLigneRW3U(coordonnee[i].nomX);
   ecritSousSection(NbreOrdonnee,'Y');
   for i := 1 to NbreOrdonnee do
       ecritLigneRW3U(coordonnee[i].nomY);
   ecritSousSection(NbreOrdonnee,'TRACE');
   for i := 1 to NbreOrdonnee do
       ecritIntegerRW3(word(coordonnee[i].Trace));
   ecritSousSection(NbreOrdonnee,'MONDE');
   for i := 1 to NbreOrdonnee do
       ecritIntegerRW3(ord(coordonnee[i].iMondeC));
   if useDefaut then begin
      ecritSousSection(mondeSans-mondeX+1,'MAXI');
      for i := mondeX to mondeSans do
          ecritFloatRW3(monde[i].maxDefaut);
      ecritSousSection(mondeSans-mondeX+1,'MINI');
      for i := mondeX to mondeSans do
          ecritFloatRW3(monde[i].minDefaut);
      ecritSousSection(2,'TEMPSMINMAX');
      ecritFloatRW3(miniTemps);
      ecritFloatRW3(maxiTemps);
   end;
   ecritSousSection(succ(mondeDroit-mondeX),'GRADUATION');
   for i := mondeX to MondeDroit do
       ecritIntegerRW3(ord(monde[i].Graduation));
   ecritSousSection(succ(mondeDroit-mondeX),'ZERO');
   for i := mondeX to MondeDroit do
       ecritIntegerRW3(ord(monde[i].ZeroInclus));
   ecritSousSection(22,'OPTIONS');
   ecritIntegerRW3(byte(optionGraphe));{1}
   ecritIntegerRW3(byte(optionModele));{2}
   ecritIntegerRW3(0);{3}
   ecritIntegerRW3(OrdreLissage);{4}
   ecritIntegerRW3(DimPointVGA);{5}
   ecritIntegerRW3(ord(UseDefaut));{6}
   ecritIntegerRW3(ord(SuperposePage));{7}
   ecritIntegerRW3(ord(TraceEllipse));{8}
   ecritIntegerRW3(ord(projeteVecteur)); {9}
   ecritIntegerRW3(-1);{10}
   ecritIntegerRW3(ord(false));{11}
   ecritIntegerRW3(ord(false));{12}
   ecritIntegerRW3(trunc(Echellevecteur*100));{13}
   ecritIntegerRW3(ord(ProlongeVecteur));{14}
   ecritIntegerRW3(1);{15 entier pour rétro compatibilité}
   ecritIntegerRW3(pasPoint);{16}
   ecritIntegerRW3(ord(CouleurVitesseImposee));{17}
   ecritIntegerRW3(ord(ajusteOrigine));{18}
   ecritIntegerRW3(ord(UseSelect));{19}
   ecritIntegerRW3(NbreVecteurVitesseMax);{20}
   ecritIntegerRW3(25);{21}
   ecritIntegerRW3(round(PenWidthEcran));{22}
   for p := 1 to nbrePages do
   if curseur=curReticuleData then begin
      ecritSousSection(17,'CURSEUR');
      for i := 1 to 2 do with curseurOsc[i] do begin // 8*2=16
          ecritFloatRW3(Pc.x);
          ecritFloatRW3(Pc.y);
          ecritIntegerRW3(ic);
          ecritFloatRW3(xr);
          ecritFloatRW3(yr);
          ecritIntegerRW3(indexCourbe);
          ecritIntegerRW3(mondeC);
          ecritLigneRW3('zzzzz');
      end;
      ecritIntegerRW3(byte(optionCurseur)); // 17
   end;
end;  // ecritGraphe

var i : integer;
begin  // ecritConfig
   ecritGraphe;
   if (ModeleDefini in etatModele) and
      FCoordonneesPhys.ModeleEnCours then begin
        ecritSousSection(NbrePages,'MODELECALC');
        for i := 1 to NbrePages do
            ecritIntegerRW3(ord(Pages[i].ModeleCalcule));
   end;
end; // ecritConfig

Procedure TgrapheVariab.litConfigXML(ANode : IXMLNode);
var CoordCourante : integer;
    avecDefaut : boolean;
    mondeCourant : indiceMonde;

procedure ResetCoord;
var i : integer;
begin
    avecDefaut := false;
    mondeCourant := mondeY;
    for i := mondeX to mondeSans do with monde[i] do begin
        defini := false;
        axe := nil;
    end;
    for i := 1 to maxOrdonnee do with coordonnee[i] do begin
        nomX := '';
        nomY := '';
        codeX := grandeurInconnue;
        codeY := grandeurInconnue;
        exclude(trace,trSonagramme);
    end;
    modif := [];
end;

procedure VerifCoord;

procedure affecteDefaut;
var m : indiceMonde;
begin
    useDefaut := true;
    useDefautX := true;
    useZoom := false;
    monde[mondeX].defini := true;
    for m := mondeX to mondeDroit do with monde[m] do
        SetMinMaxDefaut(mini, maxi);
end;

var i : integer;
begin
    for i := 1 to maxOrdonnee do with coordonnee[i] do begin
        codeY := indexNom(nomY);
        if codeY<>grandeurInconnue
           then monde[iMondeC].axe := grandeurs[codeY];
        codeX := indexNom(nomX);
        if codeX<>grandeurInconnue then
           monde[mondeX].axe := grandeurs[codeX];
    end;
    if avecDefaut then affecteDefaut;
end;

procedure LoadXMLInReg(ANode: IXMLNode);

procedure Suite;
var i: Integer;
begin
if ANode.HasChildNodes then
   for I := 0 to ANode.ChildNodes.Count - 1 do
       LoadXMLInReg(ANode.ChildNodes.Nodes[I]);
end;

var zByte : byte;
    zBool : boolean;
    zWord : word;
    AdessinLine : TdessinLine;
    AdessinText : TdessinText;
    p : integer;
    newEquivalence : Tequivalence;
begin // loadXMLInReg
      if ANode.NodeName='COORD' then begin
         coordCourante := ANode.Attributes[stIndex];
         suite;
         exit;
      end;
      if SameText(ANode.NodeName, stDefaut) then begin
         mondeCourant := IndiceMonde(Integer(ANode.Attributes[stIndex]));
         suite;
         exit;
      end;
      if ANode.NodeName='X' then begin
         coordonnee[coordCourante].nomX := ANode.NodeValue;
         exit;
      end;
      if ANode.NodeName='Y' then  begin
         coordonnee[coordCourante].nomY := ANode.NodeValue;
         exit;
      end;
      if ANode.NodeName='MONDE' then begin
        zByte := GetIntegerXML(ANode);
        coordonnee[coordCourante].iMondeC := indiceMonde(zByte);
        exit;
      end;
      if ANode.NodeName='GRADUATION' then begin
         zByte := GetIntegerXML(ANode);
         monde[coordCourante].graduation := Tgraduation(zByte);
         exit;
      end;
      if ANode.NodeName='OPTIONS' then begin
         suite;
         exit;
      end;
      if ANode.NodeName='ZERO' then begin
         zBool := GetBoolXML(ANode);
         monde[coordCourante].zeroInclus := zBool;
         exit;
      end;
      if ANode.NodeName='MAXIT' then begin
         maxiTemps := GetFloatXML(ANode);
         exit;
      end;;
      if ANode.NodeName='MINIT' then begin
         miniTemps := GetFloatXML(ANode);
         exit;
      end;;
      if ANode.NodeName='OptGraphe' then begin
         zByte := GetIntegerXML(ANode);
         optionGraphe := TsetOptionGraphe(zByte);
         exit;
      end;
      if ANode.NodeName='ReperePage' then begin
         reperePage := TreperePage(GetIntegerXML(ANode));
         exit;
      end;
      if ANode.NodeName='OptModele' then begin
         zByte := GetIntegerXML(ANode);
         optionModele := TsetOptionModele(zByte);
         exit;
      end;
      if ANode.NodeName='MINI' then begin
         miniTemps := GetFloatXML(ANode);
         exit;
      end;
      if ANode.NodeName='TEXTE' then begin
         AdessinText := TdessinText.createText(TGrapheVariab(self));
         AdessinText.loadXML(ANode);
         dessinTexts.add(AdessinText);
         exit;
      end;
      if ANode.NodeName='SHAPE' then begin
         AdessinLine := TdessinLine.createLine(TGrapheVariab(self));
         AdessinLine.loadXML(ANode);
         dessinLines.add(AdessinLine);
         exit;
      end;
      if ANode.NodeName='MODELECALC' then begin
         if ANode.HasAttribute(stPage) then
            p := ANode.Attributes[stPage]
         else
            p := ANode.Attributes['Index'];
         pages[p].modeleCalcule := getBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='CURSEUR' then begin
         exit;
      end;
      if ANode.NodeName='TRACE' then begin
         zWord := GetIntegerXML(ANode);
         coordonnee[coordCourante].Trace := TsetTrace(zWord);
         exclude(coordonnee[coordCourante].trace,trSonagramme);
         exit;
      end;
      if SameText(ANode.NodeName, stCouleur) then begin
         coordonnee[coordCourante].couleur := getColorXML(ANode);
         exit;
      end;
      if ANode.NodeName='CouleurVitesseImposee' then begin
         CouleurVitesseImposee := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='SuperPage' then begin
         superposePage := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='AutoTick' then begin
         autoTick := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='NTicks' then begin
         monde[mondeCourant].NTicks := GetIntegerXML(ANode);
         exit;
      end;
      if ANode.NodeName='MinD' then begin
         monde[mondeCourant].Mini := GetFloatXML(ANode);
         avecDefaut := true;
         exit;
      end;
      if ANode.NodeName='MaxD' then begin
         monde[mondeCourant].Maxi := GetFloatXML(ANode);
         exit;
      end;
      if ANode.NodeName='Delta' then begin
         monde[mondeCourant].DeltaAxe := GetFloatXML(ANode);
         exit;
      end;
      if ANode.NodeName='EchelleAutoAnim' then begin
         echelleAutoAnimation := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='ProjeteVect' then begin
         ProjeteVecteur := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='FilDeFer' then begin
         exit;
      end;
      if ANode.NodeName='Ellipse' then begin
         TraceEllipse := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='Intersection' then begin
         TraceIntersection := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='ProlongeVect' then begin
         ProlongeVecteur := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='LIGNE' then begin
         zByte := GetIntegerXML(ANode);
         coordonnee[coordCourante].ligne := Tligne(zByte);
         exit;
      end;
      if ANode.NodeName='MOTIF' then begin
         zByte := GetIntegerXML(ANode);
         coordonnee[coordCourante].motif := Tmotif(zByte);
         exit;
      end;
      if (ANode.NodeName='PenWidth') or (ANode.NodeName='azerty') then begin
         penWidthEcran := GetIntegerXML(ANode);
         exit;
      end;
      if ANode.NodeName='OrdreLissage' then begin
         ordreLissage := GetIntegerXML(ANode);
         exit;
      end;
      if SameText(ANode.NodeName, stTangente) then begin
         p := ANode.Attributes['Page'];
         NewEquivalence := Tequivalence.Create(self);
         NewEquivalence.LoadXML(ANode);
         equivalences[p].add(newEquivalence);
         exit;
      end;
      if ANode.NodeName='AnimationTemporelle' then begin
         exit;
      end;
      if ANode.NodeName='AnimationManuelle' then begin
         FRegressiMain.AnimationBtn.isPressed := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='TitreAnimation' then begin
         FRegressiMain.titreAnimCB.isChecked := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='NbreTick' then begin
         FRegressiMain.AnimationTB.value := GetIntegerXML(ANode);
         exit;
      end;
      if ANode.NodeName='LignePoint' then begin
         exit;
      end;
      if ANode.NodeName='NbreParamAnim' then begin
         NbreParamAnimation := GetIntegerXML(ANode);
         exit;
      end;
      if ANode.NodeName='ANIMATION' then begin
         suite;
         exit;
      end;
      if ANode.NodeName='ParamAnim' then begin
         p := ANode.Attributes[stIndex];
         paramAnimation[p].litXML(ANode);
         exit;
      end;
end; // LoadXMLInReg

var i: Integer;
begin
   Curseur := curSelect;
   configCharge := true;
   resetCoord;
   if ANode.HasChildNodes then
      for i := 0 to ANode.ChildNodes.Count - 1 do
          LoadXMLInReg(ANode.ChildNodes.Nodes[i]);
   verifCoord;
   if FRegressiMain.AnimationBtn.isPressed then begin
      verifAnimation;
      FRegressiMain.PanelAnimation.visible := true;
      setStyleAnimation;
   end;
end; // litConfigXML

Procedure TgrapheVariab.litConfig;
var imax : integer;

procedure VerifCoord;
var i : integer;
begin
    for i := mondeX to mondeSans do monde[i].axe := nil;
    for i := 1 to maxOrdonnee do with coordonnee[i] do begin
        codeY := indexNom(nomY);
        if codeY<>grandeurInconnue
           then monde[iMondeC].axe := grandeurs[codeY];
        codeX := indexNom(nomX);
        if codeX<>grandeurInconnue then
           monde[mondeX].axe := grandeurs[codeX];
        monde[iMondeC].defini := false;
        exclude(trace,trSonagramme);
    end;
    if not useDefautX then
       monde[MondeX].defini := false; // ??
end;

procedure litOptions;
var i : integer;
    zInt : integer;
begin
             litLigneWin; {1}
             optionGraphe := TsetOptionGraphe(byte(strToInt(ligneWin)));
             litLigneWin; {2}
             optionModele := TsetOptionModele(byte(strToInt(ligneWin)));
             litLigneWin; {3}
             litLigneWin; {4}
             OrdreLissage := strToInt(ligneWin);
             litLigneWin; {5}
             DimPointVGA := strToInt(ligneWin);
             if imax>=6 then useDefaut := litBooleanRW3; {6}
             if imax>=7 then superposePage := litBooleanRW3; {7}
             if imax>=8 then traceEllipse := litBooleanRW3; {8}
             if imax>=9 then ProjeteVecteur := litBooleanRW3;{9}
             if imax>=10 then litLigneWin;{10}
             if imax>=11 then litBooleanRW3; {11}
             if imax>=12 then litBooleanRW3;{12}
             if imax>=13 then begin
                echelleVecteur := litIntegerRW3;// 13
                echelleVecteur := echelleVecteur/100;
             end;
             if imax>=14 then ProlongeVecteur := litBooleanRW3; {14 }
             if imax>=15 then litLigneWin; // 15 autrefois entier
             if imax>=16 then pasPoint := litIntegerRW3; //16
             if imax>=17 then couleurVitesseImposee := litBooleanRW3; {17 }
             if imax>=18 then ajusteOrigine := litBooleanRW3; {18 }
             if imax>=19 then useSelect := litBooleanRW3; {19 }
             if imax>=20 then NbreVecteurVitesseMax := litIntegerRW3; {20 }
             if imax>=21 then litLigneWin; // 21
             if imax>=22 then PenWidthEcran := litIntegerRW3; // 22
             if imax>=23 then litFloatRW3;{23 zeroPolaire}
             if imax>=24 then litBooleanRW3;{24 withBandeConfiance }
             if imax>=25 then litBooleanRW3;{25 withBandePrediction}
             if imax>=26 then begin {26}
                 zint := litIntegerRW3;
                 reperePage := TreperePage(zint);
             end;
             for i := 27 to imax do litLigneWin;
end;

procedure litGraduation;
var i : integer;
    zbyte : byte;
begin
for i := 1 to imax do begin
       litLigneWin;
       if ligneWin[1]<>symbReg2 then begin
           zByte := StrToInt(ligneWin);
           monde[pred(i)].graduation := Tgraduation(zByte);
       end;
end;
end;

var i : integer;
    zByte : byte;
    zWord : word;
    zLong: longWord;
    MajDefaut : boolean;
    couleur : TAlphaColor;
    TamponDessin : TTamponTexteLigne;
begin // litConfig
   MajDefaut := false;
   Curseur := curSelect;
   configCharge := true;
   while (Length(LigneWin)>0) and (ligneWin[1]=symbReg2) do begin
      imax := NbreLigneWin(ligneWin);
      if pos('X',ligneWin)<>0 then
           for i := 1 to imax do
                coordonnee[i].nomX := litLigneWinU else
      if pos('Y',ligneWin)<>0 then
           for i := 1 to imax do
                coordonnee[i].nomY := litLigneWinU else
      if pos('MONDE',ligneWin)<>0 then
           for i := 1 to imax do begin
                litLigneWin;
                if ligneWin[1]<>symbReg2 then begin
                       zByte := StrToInt(ligneWin);
                       coordonnee[i].iMondeC := indiceMonde(zByte);
                end
           end else
      if pos('DESSIN',ligneWin)<>0 then begin
         TamponDessin := TTamponTexteLigne.create(self);
         TamponDessin.load;
         TamponDessin.Free;
      end else
      if pos('GRADUATION',ligneWin)<>0 then litGraduation else
      if pos('OPTIONS',ligneWin)<>0 then litOptions else
      if pos('ZERO',ligneWin)<>0 then for i := 1 to imax do
                monde[pred(i)].zeroInclus := litBooleanRW3 else
      if pos('MAXI',ligneWin)<>0 then
           for i := 1 to imax do with monde[pred(i)] do begin
               minDefaut := litFloatRW3;
               MajDefaut := true;
           end else
      if pos('MINI',ligneWin)<>0 then
          for i := 1 to imax do with monde[pred(i)] do begin
               minDefaut := litFloatRW3;
               MajDefaut := true;
          end else
      if pos('MODELECALC',ligneWin)<>0 then
         for i := 1 to imax do litBooleanRW3 else
      if pos('TEMPSMINMAX',ligneWin)<>0 then begin
                miniTemps := litFloatRW3;
                maxiTemps := litFloatRW3;
           end else
      if pos('TRACE',ligneWin)<>0 then
           for i := 1 to imax do begin
                 litLigneWin;
                 zWord := StrToInt(ligneWin);
                 coordonnee[i].Trace := TsetTrace(zWord);
                 exclude(coordonnee[i].trace,trSonagramme);
           end else
      if pos('COULEUR',ligneWin)<>0 then
           for i := 1 to imax do begin
               litLigneWin;
               try
               zLong := strToInt(ligneWin);
               couleur := intToColor(zLong);
               except
               couleur := couleurInit[i];
               end;
               coordonnee[i].couleur := couleur;
           end else
      if pos('LIGNE',ligneWin)<>0 then for i := 1 to imax do begin
               litLigneWin;
               zByte := StrToInt(ligneWin);
               coordonnee[i].ligne := Tligne(zByte);
           end else
      if pos('MOTIF',ligneWin)<>0 then
           for i := 1 to imax do begin
               litLigneWin;
               zByte := StrToInt(ligneWin);
               coordonnee[i].motif := Tmotif(zByte);
           end else
       for i := 1 to imax do litLigneWin;
       litLigneWin;
   end;
   verifCoord;
   if majDefaut then for i := mondeX to high(indiceMonde) do
      with monde[i] do
           setMinMaxDefaut(minDefaut,maxDefaut); // prise en compte des coord log
end; // litConfig

procedure TgrapheVariab.SetPointCourant(i,c : integer);

Procedure AffichePointCourant;
var Pint : TpointF;
    dimP : single;
begin if indexPointCourant>=0 then
with courbes[courbePointCourant] do begin
        FRegressiMain.cercle.fill.color := couleur;
        FRegressiMain.cercle.stroke.Dash := TStrokeDash.Solid;
        FRegressiMain.cercle.fill.kind := TBrushKind.Solid;
        WindowRT(valX[indexPointCourant],valY[indexPointCourant],iMondeC,Pint);
        DimP := dimPoint+2;
        FRegressiMain.Cercle.position.x := Pint.x-dimP;
        FRegressiMain.Cercle.position.y := Pint.y-dimP;
        FRegressiMain.Cercle.width := 2*dimP;
        FRegressiMain.Cercle.height := 2*dimP;
end end;

begin
     AffichePointCourant; // efface
     if curseur in [curSelect,curReticule,curReticuleData,curMove,curEquivalence]
        then indexPointCourant := i
        else indexPointCourant := -1;
     courbePointCourant := c;
     if indexPointCourant>=0 then begin
        FValeurs.MesureCourante := indexPointCourant;
        FValeurs.gridVariab.focusedCell := makeCell(1,FValeurs.MesureCourante+2);
     end;
     AffichePointCourant; // retrace
end;

procedure TgrapheVariab.RazBornesClick;
var i : integer;
begin with pages[pageCourante] do begin
         ModeleCalcule := false;
         ModeleErrone := false;         
         for i := 1 to maxIntervalles do resetDebutFin(i);
         include(modif,gmModele);
         PaintBox.repaint;
end end;

procedure TgrapheVariab.ImprModeleBtnClick;
var bas : single;

procedure ImprimeModele;
var page : codePage;
begin
         BeginPrintTxt(bas);
         PrintList(TexteModele,stModelisation,bas);
         if superposePage
            then begin
               for page := 1 to NbrePages do with pages[page] do if active
                   then PrintList(TexteResultatModele,TitrePage,bas)
            end
            else with pages[pageCourante] do
              PrintList(TexteResultatModele,TitrePage,bas)
end;

begin
     if OKreg(OkImprGr,0) then begin
           try
           beginPrintGr(bas);
           bas := 0;
           versImprimante(bas);
           ImprimeModele;
           Printer.endDoc;
           except
           end;
     end;
end;

procedure TgrapheVariab.VecteursItemClick(Sender: TObject);
var complement : array[1..2] of string;

procedure SetVecteurs(j : integer);
var nomVitesseX,nomVitesseY : string;
    nomX : string;
    nomAccelerationX,nomAccelerationY : string;

Function AddVitesse(y : string) : string;
begin
    if y[length(y)]='''' then delete(y,length(y),1);
    result := 'v'+y;
    Fvaleurs.memo.lines.add('v'+y+'=Diff('+y+','+grandeurs[0].nom+')');
    recompiler := true;
end;

Function AddAcceleration(y,v : string) : string;
begin
    if y[length(y)]='''' then delete(y,length(y),1);
    result := 'a'+y;
    Fvaleurs.memo.lines.add('a'+y+'=Diff('+v+','+grandeurs[0].nom+')');
    recompiler := true;
end;

Procedure AddNorme(x,y : string);
begin
    Fvaleurs.memo.lines.add(x[1]+complement[j]+'=Sqrt('+x+'^2+'+y+'^2)');
    recompiler := true;
end;

var indexvX,indexvY : integer;
    indexX,indexY : integer;
    indexaX,indexaY : integer;
    creationvx,creationvy,creationax,creationay : boolean;
begin
      indexX := indexNom(coordonnee[j].nomX);
      if (indexX=0) and (NbreOrdonnee=2) and (j=1) then begin // x(t),y(t) transformé en y(x)
          coordonnee[1].nomX := coordonnee[1].nomY;
          indexX := indexNom(coordonnee[1].nomX);
          coordonnee[1].nomY := coordonnee[2].nomY;
          NbreOrdonnee := 1;
          coordonnee[2].nomX := '';
          coordonnee[2].nomY := '';
          include(OptionGraphe,OgOrthonorme);
      end;
      if (indexX=grandeurInconnue) or (indexX=0) then begin
         exclude(coordonnee[j].trace,trVitesse);
         exclude(coordonnee[j].trace,trAcceleration);
         exit;
      end;
      indexY := indexNom(coordonnee[j].nomY);
      if indexY=grandeurInconnue then begin
         exclude(coordonnee[j].trace,trVitesse);
         exclude(coordonnee[j].trace,trAcceleration);
         exit;
      end;
      indexvX := IndexVitesse(coordonnee[j].nomX);
      creationvX := indexvX=GrandeurInconnue;
      if creationvX
         then nomVitesseX := AddVitesse(coordonnee[j].nomX)
         else nomVitesseX := grandeurs[indexvX].nom;
      indexvY := IndexVitesse(grandeurs[indexY].nom);
      creationvY := indexvY=GrandeurInconnue;
      if creationvY
         then nomVitesseY := AddVitesse(coordonnee[j].nomY)
         else nomVitesseY := grandeurs[indexvY].nom;
      nomX := coordonnee[j].nomX;
      if length(nomX)>1 then
         complement[j] := copy(nomX,2,length(nomX)-1);
      if (j=2) and (complement[1]=complement[2]) then
         complement[2] := complement[2]+'N';
      if creationvX and creationvY then AddNorme(nomVitesseX,nomVitesseY);
      if trAcceleration in coordonnee[j].trace then begin
         indexaX := IndexAcceleration(grandeurs[indexX].nom);
         creationaX := indexaX=GrandeurInconnue;
         if creationaX
            then nomAccelerationX := AddAcceleration(coordonnee[j].nomX,nomVitesseX)
            else nomAccelerationX := grandeurs[indexaX].nom;
         indexaY := IndexAcceleration(grandeurs[indexY].nom);
         creationaY := indexaY=GrandeurInconnue;
         if creationaY
            then nomAccelerationY := AddAcceleration(coordonnee[j].nomY,nomVitesseY)
            else nomAccelerationY := grandeurs[indexaY].nom;
         if creationaX and creationaY then AddNorme(nomAccelerationX,nomAccelerationY);
      end; // accélération
end; // setVecteurs

var j : integer;
begin // VecteursItemClick
     complement[1] := '';
     complement[2] := '';
     (sender as TmenuItem).IsChecked := true;
     exclude(coordonnee[1].trace,trVitesse);
     exclude(coordonnee[1].trace,trAcceleration);
     exclude(coordonnee[2].trace,trVitesse);
     exclude(coordonnee[2].trace,trAcceleration);
     if FRegressiMain.AccelerItem.IsChecked or
        FRegressiMain.VitesseAccItem.IsChecked
        then include(coordonnee[1].trace,trAcceleration);
     if FRegressiMain.VitesseItem.IsChecked  or
        FRegressiMain.VitesseAccItem.IsChecked
        then include(coordonnee[1].trace,trVitesse);
     for j := 2 to NbreOrdonnee do
         coordonnee[j].trace := coordonnee[1].trace;
     if (trVitesse in coordonnee[1].trace) or
        (trAcceleration in coordonnee[1].trace)
        then begin
           for j := 1 to NbreOrdonnee do setVecteurs(j);
           if recompiler then
              Fvaleurs.MajBtnClick(nil);
        end;
     include(modif,gmXY);
     paintBox.Repaint;
end;// VecteursItemClick

procedure TgrapheVariab.ChoixCurseurClick(sender : TObject);
var  newCurseur : Tcurseur;
     codeDerivee, i, k : integer;
     existedBefore, savedRecompiler : boolean;
     nomDer : string;
begin // ChoixCurseurClick
     newCurseur := Tcurseur((sender as Tcomponent).tag);
     (sender as TmenuItem).IsChecked := true;
     if (newCurseur=curEquivalence) then begin
         if (courbes.Count = 0) or (monde[mondeY].axe = nil) or (monde[mondeX].axe = nil) then begin
            setPenBrush(curSelect);
            exit;
         end;
         indexCourbeEquivalence := -1;
         for i := 0 to pred(courbes.Count) do
            if (courbes[i].page = pageCourante) and (courbes[i].iMondeC = mondeY) and (courbes[i].varY <> nil) then begin
               indexCourbeEquivalence := i;
               if courbes[i].courbeExp then break;
            end;
         if indexCourbeEquivalence < 0 then
            indexCourbeEquivalence := 0;
         mondeDerivee := courbes[indexCourbeEquivalence].iMondeC;
         if monde[mondeDerivee].axe = nil then mondeDerivee := mondeY;
         if monde[mondeDerivee].axe = nil then begin
            setPenBrush(curSelect);
            exit;
         end;
         existedBefore := (indexDerivee(monde[mondeDerivee].axe, monde[mondeX].axe, false, false) <> grandeurInconnue);
         codeDerivee := indexDerivee(monde[mondeDerivee].axe, monde[mondeX].axe, true, true);
         if codeDerivee=grandeurInconnue then begin
            setPenBrush(curSelect);
            exit;
         end;
         if (not existedBefore) and (FValeurs <> nil) then begin
            nomDer := 'd' + monde[mondeDerivee].axe.nom;
            if (IndexNom(nomDer) <> grandeurInconnue) or (not NomCorrect(nomDer, grandeurInconnue)) then begin
               k := 1;
               repeat
                  nomDer := 'der' + IntToStr(k) + '_' + monde[mondeDerivee].axe.nom;
                  inc(k);
               until (IndexNom(nomDer) = grandeurInconnue) and NomCorrect(nomDer, grandeurInconnue);
            end;
            grandeurs[codeDerivee].nom := nomDer;
            savedRecompiler := Recompiler;
            FValeurs.Memo.Lines.Add(nomDer + '=Diff(' + monde[mondeDerivee].axe.nom + ',' + monde[mondeX].axe.nom + ')');
            Recompiler := savedRecompiler;
         end;
         if not (ligneRappelTangente in [lrEquivalence, lrTangente]) then
            ligneRappelTangente := lrEquivalence;
         ligneRappelCourante := ligneRappelTangente;
         setPenBrush(curEquivalence);
         exit;
     end;
     if (NewCurseur=curReticuleData) then begin
        setPenBrush(curSelect);
        ReticuleDataDlg := TReticuleDataDlg.create(FregressiMain);
        ReticuleDataDlg.Agraphe := self;
        CentreForm(reticuleDataDlg);
        if ReticuleDataDlg.showModal=mrOK
        then begin
            CurseurOsc[1].Pc := TPointF.create(2*paintBox.width/3,2*paintBox.height/3);
            CurseurOsc[2].Pc := TPointF.create(paintBox.width/3,paintBox.height/3);
        end
        else begin
           newCurseur := curSelect;
           (sender as TmenuItem).IsChecked := false;
        end;
        ReticuleDataDlg.free;
     end;
     setPenBrush(NewCurseur);
     dessinTextCourant := nil;
     dessinLineCourant := nil;
     case curseur of
          curReticule : begin
              Origin := FRegressiMain.ScreenToClient(Origin);
              Origin.Offset(paintBox.Position.x,PaintBox.Position.y);
              if not InitReticule then setPenBrush(curSelect);
              pages[pageCourante].affecteConstParam;
              ligneRappelCourante := lrReticule;
          end;
          curReticuleModele : begin
              curseurVisible := true;
              curseurCourant := 1;
              with CurseurOsc[1] do begin
                 isData := false;
                 indexCourbe := indexCourbeLigne;
                 if indexCourbe >= 0 then begin
                    mondeC := courbes[indexCourbe].imondeC;
                    Ic := (courbes[indexCourbe].finC + courbes[indexCourbe].debutC) div 2;
                    if (Ic >= 0) and (Ic < length(courbes[indexCourbe].valX)) and
                       (Ic < length(courbes[indexCourbe].valY)) then begin
                       Xr := courbes[indexCourbe].valX[Ic];
                       Yr := courbes[indexCourbe].valY[Ic];
                       windowRT(Xr, Yr, MondeC, Pc);
                    end;
                 end;
              end;
              paintBox.repaint;
          end;
          curSelect, curReticuleData : paintBox.repaint;
          curLigne : begin
               DessinLineCourant := TdessinLine.createLine(self);
               DessinLineCourant.stroke.color := couleurLigne;
               DessinLineCourant.SetMoveDown(PaintBoxMouseMove,nil,nil);
          end;
          curTexte : begin
               DessinTextCourant := TdessinText.createText(self);
               DessinTextCourant.color := couleurTexte;
          end;
          curEquivalence :;
     end;
end;  // ChoixCurseurClick

procedure TgrapheResidu.SetCoordonnee(miniX,maxiX : double);

procedure TraceSigma;
var Xlegende : double;

Procedure traceH(yr : double;titre : string);
var dessinL : TdessinLine;
    dessinT : TdessinText;
begin
     DessinL := TdessinLine.createLine(self);
     with DessinL do begin
        stroke.color := claNavy;
        stroke.Dash := TstrokeDash.Solid;
        xReal := monde[mondeX].mini;
        yReal := yr;
     end;
     DessinL.width := paintBox.width;
     DessinL.height := 1;
     dessinLines.Add(DessinL);
     if titre='' then exit;
     DessinT := TdessinText.createText(self);
     with DessinT do begin
        couleurFond := claWhite;
        texteBrut := titre;
        text := titre;
        color := claNavy;
        xReal := xLegende;
        yReal := yr;
     end;
     dessinTexts.Add(DessinT);
end;

begin
      DessinTexts.clear;
      with monde[mondeX] do
         xLegende := (mini+maxi)/3;
      traceH(-fonctionTheorique[1].residuStat.t95,'95%');
      with monde[mondeX] do
         xLegende := 2*(mini+maxi)/3;
      traceH(+fonctionTheorique[1].residuStat.t95,'95%');
end; // TraceSigma

var Acourbe : Tcourbe;
    ValeurX,ValeurY : vecteur;
    mini,maxi : double;
    i,j,iX,iY : integer;
    Vminmax : vecteur;
    tampon : double;
begin with pages[pageCourante] do begin
        if FRegressiMain.residusItem.IsChecked  then begin
            paintBox.visible := true;
            FRegressiMain.splitterResidu.visible := true;
        end;
        if not fonctionTheorique[1].residuStat.statOK then exit;
        grapheOK := (NbreVariab>1) and (NbrePages>0) and
              pages[pageCourante].modeleCalcule and
                (ModeleDefini in graphe.etatModele) and
                (ModeleConstruit in graphe.etatModele);
        if not grapheOK  then exit;
        optionGraphe := [];
        iX := fonctionTheorique[1].indexX;
        iY := fonctionTheorique[1].indexY;
        setLength(valeurX,NmesMax+1);
        setLength(valeurY,NmesMax+1);
        superposePage := false;
        Reset;
        j := 0;
        if traceEllipse then begin
           setLength(dXresidu,NmesMax+1);
           setLength(dYresidu,NmesMax+1);
        end;
        for i := debut[1] to fin[1] do begin
            if j >= fonctionTheorique[1].residuStat.Nbre then break;
            valeurX[j] := valeurVar[iX,i];
            valeurY[j] := fonctionTheorique[1].residuStat.residus[j];
            if traceEllipse then begin
               dXresidu[j] := incertVar[iX,i];
               dYresidu[j] := incertVar[iY,i];
            end;
            inc(j);
        end;
        Acourbe := Tcourbe.create(valeurX,valeurY,0,pred(j),
                  grandeurs[iX],grandeurs[iY]);
        Acourbe.page := pageCourante;
        Acourbe.setStyle($FFD62728,TStrokeDash.Solid,mCroix);
        Acourbe.trace := [trResidus];
        monde[mondeX].mini := miniX;
        monde[mondeX].maxi := maxiX;
        monde[mondeX].Axe := grandeurs[iX];
        monde[mondeY].Axe := grandeurs[iY];
        if TraceEllipse then with fonctionTheorique[1].residuStat do begin
           Acourbe.IncertX := dXresidu;
           Acourbe.IncertY := dYresidu;
           setLength(Vminmax,Max(NmesMax, Nbre)+1);
           for i := 0 to pred(Nbre) do
               Vminmax[i] := residus[i]+dyResidu[i];
           GetMinMax(Vminmax,Nbre,tampon,maxi);
           for i := 0 to pred(Nbre) do
               Vminmax[i] := residus[i]-dyResidu[i];
           GetMinMax(Vminmax,Nbre,mini,tampon);
           VminMax := nil;
        end
        else GetMinMax(valeurY,j,mini,maxi);
        with fonctionTheorique[1].residuStat do begin
           if maxi<(t95*1.1) then
               maxi := t95*1.1;
           if mini>(-t95*1.1) then
               mini := -t95*1.1;
        end;
        if maxi>abs(mini)
            then mini := -maxi
            else maxi := abs(mini);
        monde[mondeY].mini := mini;
        monde[mondeY].maxi := maxi;
        monde[mondeY].Axe := grandeurs[iY];
        courbes.Add(Acourbe);
        Acourbe.aDetruire := true;
        monde[mondeY].defini := true;
        monde[mondeX].defini := true;
        with paintBox.Canvas do begin
           stroke.color := couleurAxeX;
           stroke.Dash := TStrokeDash.Solid;
        end;
        TraceSigma;
        modif := [];
end end; // setCoordonneeResidu

procedure TgrapheVariab.AffecteModele;
var i : integer;
begin
if not(ModeleDefini in etatModele) and
   not(SimulationDefinie in etatModele) then exit;
for i := 0 to pred(courbes.count) do with courbes[i] do begin
    if (indexModele<0) and (-indexModele<=NbreFonctionSuper) then
    with fonctionSuperposee[-indexModele],Pages[page] do begin
             DebutC := 0;
             AffecteConstParam;
             AffecteVariableP(false);
             if genreC=g_fonction then GenereM(valX,valY,
                   valeurVar[indexX,0],valeurVar[indexX,pred(nmes)],
                   monde[mondeX].graduation=gLog,FinC);
             if genreC=g_equation then GenereEquation(valX,valY,
                          monde[mondeX].axe,
                          monde[mondeY].axe,page,FinC);
    end;
    if (indexModele>0) and not courbeExp and
       (indexModele<=NbreModele) then
    with fonctionTheorique[indexModele],Pages[page] do begin
               DebutC := debut[indexModele];
               FinC := fin[indexModele];
               copyVecteur(valX,valeurVar[indexX]);
               if ModeleCalcule
                    then copyVecteur(valY,valeurTheorique[indexModele])
                    else copyVecteur(valY,valeurVar[indexY]);
               continue;
    end; // with pages
    if ModeleParametrique and (NbreModele=2) then
    with Pages[page] do begin
               DebutC := debut[1];
               FinC := fin[1];
               if ModeleCalcule
                    then if ModeleParamX1
                           then begin
                               copyVecteur(valX,valeurTheorique[1]);
                               copyVecteur(valY,valeurTheorique[2]);
                           end
                           else begin
                               copyVecteur(valY,valeurTheorique[1]);
                               copyVecteur(valX,valeurTheorique[2]);
                           end
                    else if ModeleParamX1
                          then begin
                             copyVecteur(valX,valeurVar[fonctionTheorique[1].indexY]);
                             copyVecteur(valY,valeurVar[fonctionTheorique[2].indexY]);
                           end
                           else begin
                             copyVecteur(valX,valeurVar[fonctionTheorique[2].indexY]);
                             copyVecteur(valY,valeurVar[fonctionTheorique[1].indexY]);
                           end;
                continue;
    end; // with pages
    if PortraitDePhase and (NbreModele=1) then
    with Pages[page] do begin
               DebutC := debut[1];
               FinC := fin[1];
               if ModeleCalcule
                    then if ModeleParamX1
                           then begin
                               copyVecteur(valX,valeurTheorique[1]);
                               copyVecteur(valY,valeurLisse[fonctionTheorique[1].indexYp]);
                           end
                           else begin
                               copyVecteur(valY,valeurTheorique[1]);
                               copyVecteur(valX,valeurLisse[fonctionTheorique[1].indexYp]);
                           end
                    else if ModeleParamX1
                          then begin
                             copyVecteur(valX,valeurVar[fonctionTheorique[1].indexY]);
                             copyVecteur(valY,valeurVar[fonctionTheorique[1].indexYp]);
                           end
                           else begin
                             copyVecteur(valX,valeurVar[fonctionTheorique[1].indexY]);
                             copyVecteur(valY,valeurVar[fonctionTheorique[1].indexYp]);
                           end;
              continue;
    end;// with pages
end // i
end; // affecteModele

procedure TgrapheVariab.ZoomModele;
var i : integer;
    valT : vecteur;
begin
    if (NbreModele=0) or not(ModeleDefini in etatModele) then exit;
    ChercheMinMax;
    for i := 0 to pred(courbes.count) do with courbes[i] do begin
        if pages[page].modeleErrone then continue;
        pages[page].AffecteConstParam;
        pages[page].AffecteVariableP(false);
        if (indexModele>0) and not courbeExp and
           (indexModele<=NbreModele) and
           (motif<>mHisto) then
              with fonctionTheorique[indexModele] do
              case genreC of
                  g_fonction : begin
                     debutC := 0;
                     if varX.indexG=indexX
                        then GenereM(valX,valY,miniMod,maxiMod,
                                     monde[mondeX].graduation=gLog,FinC)
                        else begin
                            if (indexX=0) and useDefaut
                               then begin
                                    maxiMod := maxiTemps;
                                    miniMod := miniTemps;
                               end
                               else GetMinMax(ValX,succ(FinC),miniMod,maxiMod);
                            GenereM(valX,valY,miniMod,maxiMod,false,FinC);
                        end;
                  end;// fonction
                  g_equation : GenereEquation(valX,valY,
                                   monde[mondeX].axe,
                                   monde[mondeY].axe,page,FinC);
                  g_diff2 : begin
                        if isModeleSysteme
                           then begin if indexModele=1 then
                               ExtrapoleDiff2(page,Pages[page].debut[1],
                                         monde[mondeX].mini,monde[mondeX].maxi,
                                         ValeurXDiff,ValeurYDiff,valeurYpDiff,1,NbreModele);
                            end
                            else ExtrapoleDiff2(page,Pages[page].debut[indexModele],
                                         monde[mondeX].mini,monde[mondeX].maxi,
                                         ValeurXDiff,ValeurYDiff,valeurYpDiff,indexModele,indexModele);
                        copyVecteur(valX,valeurXDiff);
                        copyVecteur(valY,ValeurYDiff[indexModele]);
                        debutC := 0;
                        finC := pred(Pages[page].NmesMax);
                  end;// diff2
                  g_diff1 : begin
                        if isModeleSysteme
                           then begin if indexModele=1 then
                               ExtrapoleDiff1(page,Pages[page].debut[1],
                                         monde[mondeX].mini,monde[mondeX].maxi,
                                         ValeurXDiff,ValeurYDiff,1,NbreModele);
                           end
                           else ExtrapoleDiff1(page,Pages[page].debut[indexModele],
                                         monde[mondeX].mini,monde[mondeX].maxi,
                                         ValeurXDiff,ValeurYDiff,indexModele,indexModele);
                        copyVecteur(valX,valeurXDiff);
                        copyVecteur(valY,ValeurYDiff[indexModele]);
                        debutC := 0;
                        finC := pred(pages[page].NmesMax);
                  end; // diff1
              end;// case
                if modeleParametrique and (NbreModele=2) then begin { Fonction }
                      if useDefaut
                         then begin
                              maxiMod := maxiTemps;
                              miniMod := miniTemps;
                         end
                         else GetMinMax(Pages[page].ValeurVar[0],pages[page].nmes,miniMod,maxiMod);
                      GenereModeleParametrique(valY,valX,miniMod,maxiMod,finC);
                      if ModeleParamX1 then swap(valX,valY);
                      debutC := 0;
                      continue;
                end;
                if portraitDePhase and
                   (fonctionTheorique[1].genreC=g_fonction) and
                   (NbreModele=1) then begin
                     if useDefaut
                         then begin
                              maxiMod := maxiTemps;
                              miniMod := miniTemps;
                         end
                         else GetMinMax(Pages[page].ValeurVar[0],pages[page].nmes,miniMod,maxiMod);
                      FonctionTheorique[1].GenereM(valX,valY,miniMod,maxiMod,false,FinC);
                      copyVecteur(valT,valX);
                      DeriveeGauss(valT,valY,finC+1,valX,NbrePointDerivee);
                      valT := nil;
                      if ModeleParamX1 then swap(valX,valY);
                      debutC := 0;
                      continue;
                end;
                if portraitDePhase and
                   (fonctionTheorique[1].genreC=g_diff2) and
                   (NbreModele=1) then begin
                     if useDefaut
                         then begin
                              maxiMod := maxiTemps;
                              miniMod := miniTemps;
                         end
                         else GetMinMax(Pages[page].ValeurVar[0],pages[page].nmes,miniMod,maxiMod);
                       ExtrapoleDiff2(page,Pages[page].debut[1],
                              miniMod,maxiMod,
                              ValeurXDiff,ValeurYDiff,valeurYpDiff,1,1);
                       if ModeleParamX1
                          then begin
                              copyVecteur(valX,valeurYDiff[1]);
                              copyVecteur(valY,valeurYpDiff[1]);
                          end
                          else begin
                              copyVecteur(valX,valeurYpDiff[1]);
                              copyVecteur(valY,valeurYDiff[1]);
                          end;
                       debutC := 0;
                       finC := pred(pages[page].NmesMax);
                       continue;
                end; // portrait de phase diff2
                if (indexModele=1) and not(courbeExp) then begin
                       setLength(valYder,finC);
                       DeriveeGauss(valX,valY,finC,valYder,NbrePointDerivee);
                end;
     end; // for i
end; // zoomModele

procedure TgrapheVariab.ZoomSuperpose;
var i : integer;
begin
    if (NbreFonctionSuper=0) or not(SimulationDefinie in etatModele) then exit;
    chercheMinMax;
    for i := 0 to pred(courbes.count) do with courbes[i] do begin
        if (indexModele<0) and (-indexModele<=NbreFonctionSuper) then
            with fonctionSuperposee[-indexModele] do begin
                 pages[page].AffecteConstParam;
                 pages[page].AffecteVariableP(false);
                 debutC := 0;
                 if genreC=g_equation
                    then GenereEquation(valX,valY,
                          monde[mondeX].axe,
                          monde[mondeY].axe,page,FinC)
                    else if indexX=varX.indexG
                    then GenereM(valX,valY,
                                 miniMod,maxiMod,monde[mondeX].Graduation=gLog,FinC)
                    else begin
                         if (varX=grandeurs[0]) and useDefaut
                            then begin
                                 maxiMod := maxiTemps;
                                 miniMod := miniTemps;
                            end
                            else GetMinMax(ValX,succ(FinC),miniMod,maxiMod);
                         GenereM(valX,valY,miniMod,maxiMod,false,FinC);
                    end; // not mondeX
         end; // boucle i
    end;
end; // zoomSuperpose

procedure TgrapheVariab.PanelCentralKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
var i : integer;
    P : TPointF;

Function MajI  : boolean;
begin with pages[pageCourante] do begin
      MajI := true;
      case key of
           vkLeft,vkDown : dec(i);
           vkReturn : ;
           vkRight,vkUp : inc(i);
           vkPrior : dec(i,10);
           vkHome : i := 0;
           vkEnd : i := pred(nmes);
           vkNext : inc(i,10);
           else MajI := false;
       end;
       if i<0 then i := 0;
       if i>=nmes then i := pred(nmes);
end end;

procedure gereEquivalence(ajout : boolean);
begin
     if (equivalenceCourante<>nil) and
        (indexCourbeEquivalence >= 0) and (indexCourbeEquivalence < courbes.Count) then with equivalenceCourante do begin
          windowRT(Ve,pHe,mondeY,P);
          i := PointProche(P,indexCourbeEquivalence,true,ligneRappelTangente=lrTangente);
          if ajout and (i>=0) then begin
              AjouteEquivalence(i,true);
              setPointCourant(i,indexCourbeEquivalence);
          end;
          if majI then begin
              SetValeurEquivalence(i);
              paintBox.repaint; // trace
          end;
     end;
end;

begin
     if keyChar=' ' then
         case curseur of
               curReticuleModele,curReticule : BarreEspace;
               curEquivalence : gereEquivalence(true);
               curReticuleData : begin
                  GetCurseurProche(Origin,true);
                  if curseurCourant>0 then i := curseurOsc[curseurCourant].Ic;
               end;
         end;
     with pages[pageCourante] do case curseur of
        curReticuleData : begin
            if key=vkEscape then begin
               setPenBrush(CurSelect);
               exit;
            end;
            GetCurseurProche(Origin,true);
            if curseurCourant>0 then i := curseurOsc[curseurCourant].Ic;
        end;
        curTexte : ;
        curLigne : ;
        curEfface,curReticule,curReticuleModele : if key=vkEscape then begin
           setPenBrush(CurSelect);
           exit;
        end;
        curEquivalence : if (equivalenceCourante<>nil) and
                            (indexCourbeEquivalence >= 0) and (indexCourbeEquivalence < courbes.Count) then with equivalenceCourante do begin
           windowRT(Ve,pHe,mondeY,P);
           i := PointProche(P,indexCourbeEquivalence,true,ligneRappelTangente=lrTangente);
           if (key=vkReturn) and (i>=0) then begin
              AjouteEquivalence(i,true);
              setPointCourant(i,indexCourbeEquivalence);
           end;
           if majI then begin
              SetValeurEquivalence(i);
              paintBox.repaint; // trace
              exit;
           end;
        end; // curEquivalence
     end; // case
     case key of
          vkSpace : case curseur of
               curReticuleModele,curReticule : BarreEspace;
               curEquivalence : gereEquivalence(true);
          end;
          vkDelete,vkBack : begin
             if (curseur in [curSelect,curReticule,curReticuleData]) and
                (indexPointCourant>=0) then begin
                   Pages[pageCourante].SupprimeLignes(indexPointCourant,indexPointCourant);
                   FRegressiMain.WMRegMaj(MajSupprPoints);
                   key := 0;
             end;
             if DessinTextCourant<>nil then dessinTexts.delete(dessinTexts.indexOf(DessinTextCourant));
             if DessinLineCourant<>nil then dessinLines.delete(dessinLines.indexOf(DessinLineCourant));
          end;
          vkReturn : if curseur=curEquivalence then gereEquivalence(true);
     end;
end; // keyDown

procedure TgrapheVariab.ConvertitXY(sender : TObject;var x,y : single);
begin
   if sender is Tlabel then begin
      X := X+(sender as TLabel).position.x;
      Y := Y+(sender as TLabel).position.y;
   end;
   if sender is TLine then begin
      X := X+(sender as TLine).position.x;
      Y := Y+(sender as TLine).position.y;
   end;
   if sender is TReticuleShape then begin
      X := X+(sender as TShape).position.x;
      Y := Y+(sender as TShape).position.y;
   end;
   if sender is TRectSelect then begin
      X := X+(sender as TShape).position.x;
      Y := Y+(sender as TShape).position.y;
   end;
   if sender is TBorneShape then begin
      X := X+(sender as TBorneShape).Position.x;
      Y := Y+(sender as TBorneShape).Position.y;
   end;
end;


function TgrapheVariab.setBorne(P : TpointF) : boolean;
var i: integer;
begin
    i := PointProche(P, borneSelect.indexCourbe, False,borneSelect.avecVert);
    if i >= 0 then begin
       case borneSelect.genre of
          bsDebut: courbes[borneSelect.indexCourbe].debutC := i;
          bsFin: courbes[borneSelect.indexCourbe].finC := i;
       end;
    end;
    BorneSelect.Centre := P;
    borneSelect.isSelected := false;
    result := courbes[borneSelect.indexCourbe].debutC<courbes[borneSelect.indexCourbe].finC;
    if result then case borneSelect.genre of
         bsDebut : pages[pageCourante].debut[borneSelect.indexModele] :=
             courbes[borneSelect.indexCourbe].debutC;
         bsFin : pages[pageCourante].fin[borneSelect.indexModele] :=
             courbes[borneSelect.indexCourbe].finC;
        end;
    borneSelect := nil;
end; // setBorne

procedure TgrapheVariab.ajusteBorne(P : TpointF);
var i: integer;
    oldCentre : TPointF;
begin
    i := PointProche(P, borneSelect.indexCourbe, False, borneSelect.avecVert);
    if i < 0 then exit;
    with courbes[BorneSelect.indexCourbe] do
         WindowRT(valX[i], valY[i], iMondeC, P);
    oldCentre := BorneSelect.Centre;
    BorneSelect.Centre := P;
    if (Abs(oldCentre.X - P.X) > 0.5) or (Abs(oldCentre.Y - P.Y) > 0.5) then
       paintBox.Repaint;
end; // ajusteBorne

Procedure TGrapheVariab.CalculCurseurModele(cellule : string);
var xr,yr : double;
    LindexCourbe : integer;

Procedure AffecteCurseurModele;
var NewEquivalence : Tequivalence;
    i : integer;
begin with CurseurModeleDlg do
  if (Ligne-2)>=equivalences[pageCourante].count
    then begin
       NewEquivalence := Tequivalence.CreateEq(xr,yr,0,self);
       NewEquivalence.ligneRappel := [lrXdeY];
       equivalences[pageCourante].Add(NewEquivalence);
       with Tableau do
            if ligne=pred(rowCount) then begin
                rowCount := rowCount+1;
                for i := 0 to 2 do cells[i,pred(rowCount)] := '';
            end;
    end
    else begin
       NewEquivalence := equivalences[pageCourante].items[Ligne-2];
       NewEquivalence.ve := xr;
       NewEquivalence.ligneRappel := [lrXdeY];
       NewEquivalence.pHe := yr;
    end;
  paintBox.repaint;
end;

Function CalculExp : double;
var posErreur,longErreur : integer;
    i : integer;
begin
   if cellule=''
     then result := Nan
     else begin
        PrevenirFonctionDeParam := false;
        for i := 2 to length(cellule)-1 do begin
            if (Cellule[i]=',') and
                charInSet(Cellule[i-1],['0'..'9']) and
                charInSet(Cellule[i+1],['0'..'9'])
                then cellule[i] := '.';
        end;
        grandeurImmediate.fonct.expression := cellule;
        if grandeurImmediate.compileG(posErreur,longErreur,0)
           then begin
              try
              result := calcule(grandeurImmediate.fonct.calcul);
              except
              result := Nan;
              end;
           end
           else result := Nan
     end;
end;

procedure InterpoleX;
var distanceMin,distance : single;
    i : integer;
    Pi : TPointF;
    Lyr : double;
begin
          LindexCourbe := indexCourbeLigne;
          if LindexCourbe<0 then exit;
          xr := 1;
          yr := calculExp;
          with courbes[LindexCourbe] do begin
               if nbreExtrapole>0 then begin
                 windowRT(xr, yr,courbes[LindexCourbe].imondeC,Pi);
                 distanceMin := 16;
                 for i := 0 to NbreExtrapole-1 do begin
                    distance := abs(Pi.y - valExtrapole[i].y);
                    if distance < distanceMin then begin
                       distanceMin := distance;
                       Pi.x := valExtrapole[i].x;
                    end;
                 end;
                 mondeRT(Pi,courbes[LindexCourbe].imondeC,xr, Lyr);
                 curseurModeleDlg.tableau.cells[0,curseurModeleDlg.ligne] := FormatReg(xr);
               end
               else begin
                    xr := Nan;
                    curseurModeleDlg.tableau.cells[0,curseurModeleDlg.ligne] := '?';
               end;
          end;
end;

procedure InterpoleModeles;

function InterpoleModele(iC : integer) : boolean;
var i,i1 : integer;
    ecartY,deltaY,deltaX : double;
begin
       result := false;
       if (iC < 0) or (iC >= courbes.Count) then exit;
       LindexCourbe := iC;
       i := pointProcheReal(0,yr,courbes[iC],courbes[iC].imondeC);
       if i<0 then exit;
       with courbes[iC] do begin
            ecartY := yr-valY[i];
            if i<finC then i1 := succ(i) else i1 := pred(i);
            deltaY := valY[i1]-valY[i];
            deltaX := valX[i1]-valX[i];
            try
               xr := valX[i]+deltaX*ecartY/deltaY;
            except
               xr := valX[i];
            end;
            curseurModeleDlg.tableau.cells[0,curseurModeleDlg.ligne] := FormatReg(xr);
            result := true;
       end;
end;

var i : integer;
    iModele : shortInt;
begin
     yr := calculExp;
     xr := Nan;
     if nbreModele=1
        then InterpoleModele(indexCourbeModele)
        else begin
             for i := 0 to pred(courbes.count) do begin
                 iModele := courbes[i].indexModele;
                 if (iModele>0) and InterpoleModele(i) then begin
                     if (xr>courbes[0].varX.valeur[pages[pageCourante].Debut[iModele]]) and
                        (xr<courbes[0].varX.valeur[pages[pageCourante].Fin[iModele]])
                     then begin
                          courbeModele := courbes[i];
                          indexCourbeModele := i;
                          break;
                     end;
                 end;
             end;
        end;
end;

procedure InterpoleY;
var distanceMin,distance : single;
    i : integer;
    Pi : TPointF;
    Lxr : double;
begin
          LindexCourbe := indexCourbeLigne;
          if LindexCourbe<0 then exit;
          yr := 1;
          xr := calculExp;
          with courbes[LindexCourbe] do begin
             if nbreExtrapole > 0 then begin
                windowRT(xr, yr,courbes[LindexCourbe].imondeC,Pi);
                distanceMin := 16;
                for i := 0 to NbreExtrapole-1 do begin
                    distance := abs(Pi.x - valExtrapole[i].x);
                    if distance < distanceMin then begin
                       distanceMin := distance;
                       Pi.y := valExtrapole[i].y;
                    end;
                end;
                mondeRT(Pi,courbes[LindexCourbe].imondeC,Lxr, yr);
                curseurModeleDlg.tableau.cells[1,curseurModeleDlg.ligne] := FormatReg(yr);
             end
             else begin
                yr := Nan;
                curseurModeleDlg.tableau.cells[1,curseurModeleDlg.ligne] := '?';
             end;
          end;
end;

procedure CalculModeles;

procedure CalculModele(im : codeIntervalle);
begin
         grandeurs[fonctionTheorique[im].indexX].valCourante := xr;
         yr := calcule(fonctionTheorique[im].calcul);
         curseurModeleDlg.tableau.cells[1,curseurModeleDlg.ligne] := FormatReg(yr);
end;

var i : integer;
    iModele : shortInt;
begin
     xr := calculExp;
     if nbreModele=1
        then begin
          calculModele(1);
          LindexCourbe := indexCourbeModele;
        end
        else begin
             for i := 0 to pred(courbes.count) do begin
                 iModele := courbes[i].indexModele;
                 if (iModele>0) then begin
                     CalculModele(iModele);
                     if (courbeModele<>nil) and
                        (xr>courbeModele.varX.valeur[pages[pageCourante].Debut[iModele]]) and
                        (xr<courbeModele.varX.valeur[pages[pageCourante].Fin[iModele]])
                     then begin
                          indexCourbeModele := i;
                          LindexCourbe := i;
                          courbeModele := courbes[indexCourbeModele];
                          break;
                     end;
                 end;
             end;
        end;
end;

begin with curseurModeleDlg do begin
    LindexCourbe := -1;
    if (nbreModele=0) or (indexCourbeModele<0)
    then if colonne=1
        then interpoleX  // on a donné y
        else interpoleY  // on a donné x
    else if colonne=1
       then interpoleModeles
       else calculModeles;
    if (LindexCourbe>=0) and not(isNan(xr)) then affecteCurseurModele;
end end; // CalculCurseurModele

Procedure TGrapheVariab.InitCurseurModele;
begin
   pages[pageCourante].affecteConstParam;
   ligneRappelCourante := lrXdeY;
   RemplitTableauEquivalence;
   setPenBrush(curSelect);
   curseurModeleDlg.show;
end;

procedure TGrapheVariab.RemplitTableauEquivalence;
var ligne,i : integer;
    codeDerivee : integer;
begin
     if LigneRappelCourante in [lrEquivalence,lrTangente]
        then codeDerivee := indexDerivee(monde[mondeDerivee].axe,monde[mondeX].axe,true,true)
        else codeDerivee := 0;
     if codeDerivee=grandeurInconnue then exit;
     if curseurModeleDlg=nil then
        Application.CreateForm(TcurseurModeleDlg,curseurModeleDlg);
     with curseurModeleDlg.tableau do begin
          rowCount := equivalences[pageCourante].count+3;
          cells[0,0] := monde[mondeX].axe.nom;
          Cells[0,1] := monde[mondeX].axe.NomUnite;
          cells[1,0] := monde[mondeDerivee].axe.nom;
          Cells[1,1] := monde[mondeDerivee].axe.NomUnite;
          Cells[2,0] := stCommentaire;
          ligne := 1;
          for i := 0 to pred(equivalences[pageCourante].count) do
          with equivalences[pageCourante][i] do begin
              inc(ligne);
              cells[0,ligne] := formatReg(ve);
              cells[1,ligne] := formatReg(phe);
              cells[2,ligne] := commentaire;
          end;
          inc(ligne);
          for i := 0 to 2 do cells[i,ligne] := ''
     end;
end;

procedure TGrapheVariab.BarreEspace;

Function Supprime(posSouris : TpointF;aMonde : indiceMonde) : boolean;
var i : integer;
    aEquivalence : Tequivalence;
    aPoint : TPointF;
    trouve,trouveI : boolean;
begin
     trouve := false;
     i := 0;
     while i<equivalences[pageCourante].count do begin
            aEquivalence := equivalences[pageCourante].items[i];
            with aEquivalence do if (lrReticule in ligneRappel) then begin
               WindowRT(x1,y1,aMonde,aPoint);
               trouveI := posSouris.distance(aPoint)<12;
               if not trouveI then begin
                  WindowRT(x2,y2,aMonde,aPoint);
                  trouveI := posSouris.distance(aPoint)<12;
               end;
               if not trouveI then begin
                  WindowRT(ve,pHe,aMonde,aPoint);
                  trouveI := posSouris.distance(aPoint)<12;
               end;
                // supprime
               if trouveI then begin
                  equivalences[pageCourante].Remove(aEquivalence);
                  trouve := true;
               end
               else inc(i);
            end
            else inc(i);
         end; // while
         if trouve then PaintBox.repaint;
         result := trouve;
end;

Procedure affecteXY(x,y : double);
var Lligne : integer;
begin
     if curseurModeleDlg=nil then
        Application.CreateForm(TcurseurModeleDlg,curseurModeleDlg);
     if curseurModeleDlg.visible then begin
         Lligne := equivalences[pageCourante].count+1; // ligne 0 nom, 1 unité
         if Lligne>(curseurModeleDlg.tableau.rowCount-2) then
            curseurModeleDlg.tableau.rowCount := Lligne+2;
         curseurModeleDlg.tableau.cells[0,Lligne] := FormatReg(x);
         curseurModeleDlg.tableau.cells[1,Lligne] := FormatReg(y);
     end;
end;

var posSouris : TpointF;
    xrS,yrS : double;
    NewEquivalence : Tequivalence;
    icourbe : integer;
    Lmonde : indiceMonde;
begin // BarreEspace
   case curseur of
   curReticule : begin
        PosSouris := curseurOsc[1].Pc;
        iCourbe := courbeProche(posSouris);
        if iCourbe<0
            then Lmonde := curseurOsc[1].mondeC
            else Lmonde := courbes[iCourbe].iMondeC;
        if supprime(posSouris,Lmonde) then exit;
        mondeRT(posSouris,Lmonde,xrS,yrS);
        NewEquivalence := Tequivalence.CreateEq(xrS,yrS,0,self);
        NewEquivalence.mondepH := Lmonde;
        NewEquivalence.ligneRappel := [lrReticule];
        equivalences[pageCourante].Add(NewEquivalence);
        PaintBox.repaint;
   end;// curReticule
   curReticuleData : begin
        PosSouris := curseurOsc[1].Pc;
        if supprime(posSouris,curseurOsc[1].mondeC) then exit;
        with curseurOsc[1] do
        if mondeC<>mondeX then begin
            NewEquivalence := Tequivalence.CreateEq(xr,yr,0,self);
            NewEquivalence.mondepH := mondeC;
            NewEquivalence.ligneRappel := [lrReticule];
            equivalences[pageCourante].Add(NewEquivalence);
         end;
         PaintBox.repaint;
   end;// curReticuleData
   curReticuleModele : begin
        PosSouris := curseurOsc[1].Pc;
        if supprime(posSouris,curseurOsc[1].mondeC) then exit;
        with curseurOsc[1] do
        if mondeC<>mondeX then begin
            NewEquivalence := Tequivalence.CreateEq(xr,yr,0,self);
            NewEquivalence.mondepH := mondeC;
            NewEquivalence.ligneRappel := [lrReticule];
            equivalences[pageCourante].Add(NewEquivalence);
            affecteXY(xr,yr);
         end;
         PaintBox.repaint;
   end;// curReticuleModele
   curSelect : if (not SpaceHeld) and (indexPointCourant>=0) then begin
         Pages[pageCourante].PointActif[indexPointCourant] :=
              not Pages[pageCourante].PointActif[indexPointCourant];
         FRegressiMain.WMRegMaj(MajSupprPoints);
   end;
   end;// case curseur
end; //Gestion barre d'espace

function TGrapheVariab.IndexCourbeLigne : integer;
var i : integer;
begin
      result := -1;
      if nbreModele>1
         then result := indexCourbeModele
         else for i := 0 to pred(courbes.Count) do
                  if (trLigne in courbes[i].trace) and
                     (courbes[i].page=pageCourante)
                        then begin
                          result := i;
                          break;
                        end;
end;

end.



