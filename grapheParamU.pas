unit grapheParamU;

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
  myShape,

  FMX.TMSFNCTypes,
  FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCGridCell,
  FMX.TMSFNCGridOptions,
  FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomScrollControl,
  FMX.TMSFNCGridData,
  FMX.TMSFNCCustomGrid,
  FMX.TMSFNCGrid;

type
   TgrapheParam = class(TgrapheReg)
   private
      derf : matriceFonction;   // Dérivées premières / aux paramètres
      erreurCalcul : boolean;
      ValeurDeriveeX,ValeurYDiff,ValeurYpDiff : TvecteurExtrapole;
      ValeurXDiff : vecteur;
      modeleEnCours : boolean;
      MajModelePermis : boolean;
      avecModele : boolean;
      min,max : double;
      FPanLastPos : TPointF;
      FPanPrevCurseur : Tcurseur;
      FPanActive : boolean;
      Procedure VerifCoordonnee;
      procedure AffecteModele;
      procedure ZoomModele;
      procedure RazCoordParam;
      procedure ConvertitXY(sender : TObject;var x,y : single);
  public
      modeleDependant : boolean;
      modeleErrone : boolean;
      CurMovePermis : boolean;
      IsModeleMagnum : boolean;
      verifGraphe : boolean;
      configCharge : boolean;
      mesureDelta : boolean;
      Origin : TpointF;
      MemoModele: TMemo;
      MemoResultat: TMemo;
      modeleCalcule : boolean;
      paramGrid : TTMSFNCGrid;
      constructor Create(apaintBox : TPaintBox);
      procedure PanelCentralKeyDown(Sender: TObject; var Key: Word;
          var KeyChar: Char; Shift: TShiftState);
      procedure CompileModele(var PosErreur,LongErreur : integer);
      procedure ConstruitModele;
      Procedure EffectueModele(Ajuste : boolean);
      procedure RazBornesClick;
      procedure ImprModeleBtnClick;
      procedure ChoixCurseurClick(sender : Tobject);
      procedure SetPenBrush(c : Tcurseur);
      Procedure SetCoordonnee;
      procedure EcritConfigXML(ANode : IXMLNOde);
      procedure LitConfigXML(ANode : IXMLNOde);
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
      procedure verifIntervalles;
      procedure verifParametres;
      procedure majParametres;
      procedure LanceCompileModele;
      destructor Destroy; override;
  end;

var
  grapheParam : TgrapheParam = nil;

implementation

uses
     fspec, regmain, cursData, options, choixModele,
     CoordPhys, Valeurs, optModele, modif;

const
    DecaleLabel = 5;

{$I modelCte.pas}

procedure TgrapheParam.RazCoordParam;
var i,j,cX : integer;
    m : indiceMonde;
    UnitePrec : string;
begin
    Curseur := curSelect;
    j := 1;
    m := mondeY;
    UnitePrec := '';
    if nbreConst>0
       then cX := indexConst[0]
       else if NbreParam > 0 then cX := ParamToIndex(1)
       else exit;
    for i := 1 to pred(NbreConst) do with Coordonnee[j] do begin
        codeY := indexConst[i];
        if codeY<>cX then begin
             codeX := cX;
             ligne := LiDroite;
             nomX := grandeurs[codeX].nom;
             nomY := grandeurs[codeY].nom;
             if (j>1) and (UnitePrec<>grandeurs[codeY].nomUnite) and (m < high(indiceMonde)) then inc(m);
             UnitePrec := grandeurs[codeY].nomUnite;
             iMondeC := m;
             monde[iMondeC].graduation := gLin;
             inc(j);
             if j>MaxOrdonnee then break;
        end
    end;
    for i := 1 to NbreParam do with Coordonnee[j] do begin
        codeY := ParamToIndex(i);
        if codeY<>cX then begin
          codeX := cX;
          ligne := LiDroite;
          nomX := grandeurs[codeX].nom;
          nomY := grandeurs[codeY].nom;
          if (j>1) and (UnitePrec<>grandeurs[codeY].nomUnite) and (m < high(indiceMonde)) then inc(m);
          UnitePrec := grandeurs[codeY].nomUnite;
          iMondeC := m;
          monde[iMondeC].graduation := gLin;
          inc(j);
          if j>MaxOrdonnee then break;
        end;
    end;
    useDefaut := false;
    DessinTexts.clear;
end; // RazCoordParam

procedure TgrapheParam.PaintBoxMouseMove(Sender: TObject;
     Shift: TShiftState; X,Y: single);

procedure AffichePosition;
var icourbe : integer;
begin
    if not(monde[mondeX].defini) or (courbes.count=0) then exit;
    iCourbe := courbeProche(origin);
    if iCourbe<0 then iCourbe := 0;
    with courbes[iCourbe] do begin
         if (varY<>nil) then curseurOsc[1].mondeC := iMondeC;
    end;
    curseurOsc[1].Repaint;
end; // AffichePosition

var deplacement : boolean;
    deltaM : double;
    hintLoc : string;
    m : indiceMonde;
begin // PaintBoxMouseMove
   if not grapheOK then exit;
   if ssRight in Shift then exit; // clic droit
   hintLoc := '';
   convertitXY(sender,x,y);
   deplacement := ssLeft in Shift;
   mesureDelta := false;
   origin.x := x;
   origin.Y := y;
   case curseur of
        curZoomAv : if deplacement
           then begin
               selection.width := x-selection.Position.x;
               selection.height := y-selection.position.y;
           end
           else ;
        curSelect : begin
            if deplacement
               then begin
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
                end;
        end;
        curLigne : if (dessinLineCourant<>nil) then
            dessinLineCourant.affectePoint2(x,y);
        curTexte : ;
        curReticule : begin
           curseurOsc[1].Pc := origin;
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
        curReticuleData : if deplacement and (curseurCourant>0)
           then begin
               setSegmentInt(origin);
               hintLoc := '';
           end
           else begin
                GetCurseurProche(origin,false);
                if curseurCourant=0
                   then paintBox.cursor := crDefault
                   else paintBox.cursor := crHandPoint;
           end;
        curEquivalence : hintLoc := hEquivalence;
   end;
   FregressiMain.Aide.text := hintLoc;
   paintBox.hint := hintLoc;
end; // PaintBoxMouseMove

procedure TgrapheParam.SetPenBrush(c : Tcurseur);
begin
     curseur := c;
     case curseur of
         curZoomAv : ;
         curTexte : ;
         curLigne : ;
         curReticule : paintBox.cursor := crNone;
         curReticuleData : ;
         curMove : paintBox.cursor := crSizeAll;
         else paintBox.cursor := crCross;
     end;// case curseur
     curseurOsc[1].visible := curseur in [curReticule,curReticuleData];
     if curseur=curSelect then FRegressiMain.SelectItem.IsChecked  := true;
end; // SetPenBrush

procedure TgrapheParam.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
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

begin // MouseDown
   if not grapheOK then exit;
   origin.x := x;
   origin.Y := y;
   convertitXY(sender,X,Y);
   origin.x := x;
   origin.Y := y;
   if Button = TMouseButton.mbMiddle then begin
      FPanActive := True;
      FPanPrevCurseur := curseur;
      FPanLastPos := origin;
      setPenBrush(curMove);
      exit;
   end;
   case curseur of
       curZoomAv : begin
          selection.Position.x := origin.X;
          selection.Position.y := origin.Y;
          selection.Visible := true;
       end;
       curLigne : if (dessinLineCourant<>nil) then
          dessinLineCourant.affectePoint1(x,y);
       curTexte : affecteDessinText;
       curReticule : ;
       curSelect : if curMovePermis then begin
              FPanActive := True;
              FPanPrevCurseur := curSelect;
              FPanLastPos := origin;
              setPenBrush(curMove);
       end; // curSelect
       curReticuleData : begin
          GetCurseurProche(origin,true);
          setSegmentInt(origin);
       end;
  end // case curseur
end; // PaintBoxMouseDown

procedure TgrapheParam.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
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

Procedure affecteZoomAv;
begin
   setPenBrush(curSelect);
   selection.Visible := false;
   if (selection.width=0) or
      (selection.Height=0) then exit;
   affecteZoomAvant(true);
   curMovePermis := true;
   include(modif,gmEchelle);
end; // affecteZoomAvant

begin // MouseUp
  if (x<0) or (y<0) or not(grapheOK) then exit;
  convertitXY(sender,x,y);
  origin.x := x;
  origin.Y := y;
  case curseur of
       curZoomAv : affecteZoomAv;
       curTexte : ;
       curLigne : affecteDessinLine;
       curSelect : begin
          dessinLineCourant := nil;
          dessinTextCourant := nil;
       end;
       curReticuleData : ;
       curReticule : ;
       curEquivalence : if (ligneRappelTangente=lrTangente) then ;
       curMove : begin FPanActive := False; setPenBrush(FPanPrevCurseur); end;
  end;
  paintBox.repaint;
end; // MouseUp

procedure TgrapheParam.PaintBoxMouseWheel(Sender: TObject; Shift: TShiftState;
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

constructor TgrapheParam.Create(apaintBox : TPaintBox);
var m : codeIntervalle;
begin
  inherited create(aPaintBox);
  curseur := curSelect;
  FPanActive := False;
  FPanPrevCurseur := curSelect;
  VerifGraphe := true;
  for m := 1 to MaxIntervalles do  begin
      valeurDeriveeX[m] := nil;
  end;
  CurseurOsc[1].SetMoveDown(PaintBoxMouseMove,PaintBoxMouseDown,PaintBoxMouseUp);
  ReticuleOrigine.SetMoveDown(PaintBoxMouseMove,PaintBoxMouseDown,PaintBoxMouseUp);
  Selection.SetMoveDown(PaintBoxMouseMove,PaintBoxMouseDown,PaintBoxMouseUp);
end; // grapheVariab.Create

procedure TgrapheParam.SetCoordonnee;

procedure SetCoordonneeParam;

Procedure AjouteParam(i : integer);
var x,y,xspline,yspline,xincert,yincert : vecteur;
    n,p : integer;
    Acourbe,courbeAdd : Tcourbe;
    iX,iY : integer;
    ligneC : Tligne;
    traceC : TsetTrace;
    m : codeIntervalle;
    mondeLoc : indiceMonde;
    c,cc : integer;
    CouleurModeleActive : boolean;
    couleurLoc : Tcolor;
begin
      with Coordonnee[i] do begin
           iX := codeX;
           iY := codeY;
           TraceC := trace;
           LigneC := ligne;
           if (ligneC=liModele) and (NbreModeleGlb=0) then LigneC := LiDroite;
           MondeLoc := iMondeC;
      end;
      if avecModele then begin
         include(traceC,trLigne);
         ligneC := liModele;
         include(traceC,trPoint);
      end;
      if traceC=[] then traceC := [trPoint];
      if (grandeurs[iY].genreG in [constante,constanteGlb,paramNormal]) and
         (grandeurs[iX].genreG in [constante,constanteGlb,paramNormal]) then begin
              setLength(y, NbrePages);
              setLength(x, NbrePages);
              if traceEllipse then begin
                 setlength(xIncert, NbrePages);
                 setLength(yIncert, NbrePages);
              end;
              for p := 1 to NbrePages do with pages[p] do begin
                  n := p - 1;
                  case grandeurs[iY].genreG of
                    constanteGlb : begin
                      y[n] := grandeurs[iY].valCourante;
                      if traceEllipse then yIncert[n] := 0;
                    end;
                    constante : begin
                      y[n] := valeurConst[iY];
                      if traceEllipse then yIncert[n] := 0;
                    end;
                    paramNormal : begin
                      y[n] := valeurParametre(iY);
                      if traceEllipse then yIncert[n] := precisionParametre(iY);
                    end;
                  end;
                  case grandeurs[iX].genreG of
                    constanteGlb : begin
                      x[n] := grandeurs[iX].valCourante;
                      if traceEllipse then xIncert[n] := 0;
                    end;
                    constante : begin
                      x[n] := valeurConst[iX];
                      if traceEllipse then xIncert[n] := 0;
                    end;
                    paramNormal : begin
                      x[n] := valeurParametre(iX);
                      if traceEllipse then xIncert[n] := precisionParametre(iX);
                    end;
                  end;
              end;
      end else
      begin
        setLength(y, NbrePages);
        setLength(x, NbrePages);
        if traceEllipse then begin
           setlength(xIncert, NbrePages);
           setLength(yIncert, NbrePages);
        end;
        n := 0;
        for p := 1 to NbrePages do with pages[p] do begin
               x[n] := valeurParametre(iX);
               y[n] := valeurParametre(iY);
               if traceEllipse then begin
                  xIncert[n] := precisionParametre(iX);
                  yIncert[n] := precisionParametre(iY);
               end;
               inc(n);
        end;
      end;
      n := NbrePages;
      Acourbe := AjouteCourbe(x,y,MondeLoc,NbrePages,
         grandeurs[iX],grandeurs[iY],0);
      if (i=1) then begin
         Monde[mondeX].axe := grandeurs[iX];
         Monde[mondeX].axe.valeur := x;
         Monde[mondeLoc].axe := grandeurs[iY];
         Monde[mondeLoc].axe.valeur := y;
      end;
      Acourbe.couleur := coordonnee[i].couleur;
      Acourbe.motif := coordonnee[i].motif;
      Acourbe.styleT := coordonnee[i].styleT;
      if traceEllipse then begin
         Acourbe.IncertX := xIncert;
         Acourbe.IncertY := yIncert;
         Acourbe.DetruireIncert := true;
      end;
      Acourbe.Adetruire := true;
      Acourbe.Trace := TraceC;
      if (Coordonnee[i].motif=mSpectre) and (trPoint in TraceC)
         then Acourbe.decalage := (i-1)*decalageFFT;
// 2 modeles différents => on force des couleurs différentes
      CouleurModeleActive := false;
      for c := 2 to NbreModeleGlb do
          for cc := 1 to pred(c) do
              if (fonctionTheoriqueGlb[c].indexY)=
                 (fonctionTheoriqueGlb[cc].indexY) then begin
                     CouleurModeleActive := true;
                     break;
               end;
      if trLigne in traceC then case ligneC of
           liModele : if ModeleCalcule and (ModeleDefini in etatModele) then
              for m := 1 to NbreModeleGlb do with fonctionTheoriqueGlb[m] do
                  if (iY=indexY) and (iX=indexX) and not(implicite) then begin
                       exclude(Acourbe.Trace,trLigne);
                       setLength(x,MaxVecteurDefaut+1);
                       setLength(y,MaxVecteurDefaut+1);
                       courbeAdd := AjouteCourbe(x,y,MondeLoc,NbrePages,
                             Grandeurs[iX],grandeurs[iY],1);
                       if couleurModeleActive
                          then couleurLoc := couleurModele[m]
                          else couleurLoc := coordonnee[i].couleur;
                       courbeAdd.couleur := couleurLoc;
                       courbeAdd.StyleT := TStrokeDash.Solid;
                       courbeAdd.IndexModele := m;
                       courbeAdd.Trace := [trLigne];
                       courbeAdd.Adetruire := true;
         end;
         liSpline : begin
              exclude(Acourbe.trace,trLigne);
              CalculBspline(x,y,OrdreLissage,n,xspline,yspline);
              Acourbe := AjouteCourbe(xspline,yspline,MondeLoc,n,
                   Grandeurs[iX],grandeurs[iY],0);
              with coordonnee[i] do
                   Acourbe.setStyle(couleur,TStrokeDash.Solid,mCroix);
              Acourbe.Adetruire := true;
              Acourbe.trace := [trLigne];
         end;
      end;{case}
      if (SimulationDefinie in etatModele) and
         avecModele then
         for m := 1 to NbreFonctionSuperGlb do with fonctionSuperposeeGlb[m] do
           if (iY=indexY) and (iX=indexX) then begin
                 setLength(x,MaxVecteurDefaut+1);
                 setLength(y,MaxVecteurDefaut+1);
                 exclude(Acourbe.Trace,trLigne);
                 courbeAdd := AjouteCourbe(x,y,mondeLoc,NbrePages,
                    grandeurs[iX],grandeurs[iY],0);
                 courbeAdd.IndexModele := -m;
                 courbeAdd.setStyle(couleurModele[-m],TstrokeDash.Solid,mCroix);
                 courbeAdd.Trace := [trLigne];
                 courbeAdd.Adetruire := true;
           end; // for c de SimulationDefini
end; // AjouteParam

var  i : indiceOrdonnee;
begin
     MajModelePermis := false;
     NbreOrdonnee := 0;
     for i := 1 to maxOrdonnee do with Coordonnee[i] do
         if nomY<>'' then  begin
                AjouteParam(i);
                inc(NbreOrdonnee);
         end;
     grapheOK := true;
     MajModelePermis := true;
end; // SetCoordonneeParam

begin
     reset;
     if NbreConst+NbreParam<2 then exit;
     VerifCoordonnee;
     SetCoordonneeParam;
     modif := [gmEchelle];
end; // setCoordonnees

procedure TgrapheParam.VerifCoordonnee;
var i : integer;
    avecAxe : boolean;
begin
    for i := 1 to maxOrdonnee do with coordonnee[i] do begin
        codeY := indexNom(nomY);
        if (codeY<>grandeurInconnue) and
           not (grandeurs[codeY].genreG in [constante,constanteGlb,paramNormal])
           then codeY := grandeurInconnue;
        codeX := indexNom(nomX);
        if (codeX<>grandeurInconnue) and
           not (grandeurs[codeX].genreG in [constante,constanteGlb,paramNormal])
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
    if nbreOrdonnee=0 then
       RazCoordParam
    else begin
        AvecAxe := false;
        for i := 1 to NbreOrdonnee do with coordonnee[i] do
            if iMondeC<>mondeSans then avecAxe := true;
        if not AvecAxe then coordonnee[1].iMondeC := mondeY;
    end;
end;

procedure TgrapheParam.ImprimerGraphe(var bas : single);
begin
     versImprimante(bas);
end;

procedure TgrapheParam.PaintBoxPaint;

procedure affecteSuperpose;
var i : integer;
begin
  ChercheMinMax;
  for i := 0 to pred(courbes.count) do with courbes.items[i] do
      if (indexModele<0) and (-indexModele<=NbreFonctionSuperGlb) then
          with fonctionSuperposeeGlb[-indexModele] do begin
             DebutC := 0;
             GenereMGlb(valX,valY,miniMod,maxiMod,monde[mondeX].graduation=gLog,FinC);
      end;
end; // affecteSuperpose

begin // PaintBoxPaint
        if (pageCourante=0) or ((not grapheOK) and (not configCharge)) then exit;
        tailleEcran := PaintBox.Height;
        if ([gmXY,gmModele]*modif)<>[] then setCoordonnee;
        if not grapheOK then exit;
        chercheMonde;
        if not monde[mondeX].defini then exit;
        if ModeleCalcule and
          (ModeleDefini in etatModele)
           then AffecteModele;
        ModeleEnCours := true;
        if (NbreFonctionSuperGlb>0) and
            ModeleCalcule and
           (ModeleDefini in etatModele)
           then affecteSuperpose;
        if (NbreModeleGlb>0) and
           (omExtrapole in OptionModele) and
            ModeleCalcule and
           (ModeleDefini in etatModele)
           then zoomModele;
        draw;
        setPenBrush(curseur);
        if curseur=curReticule then begin
           curseurOsc[1].bringToFront;
           curseurOsc[1].repaint;
        end;
        modif := [];
        ModeleEnCours := false;
        paintBox.Cursor := crDefault;
end; // PaintBoxPaint

destructor TgrapheParam.Destroy;
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

Procedure TGrapheParam.EcritConfigXML(Anode : IXMLNode);
var i : integer;
    OptionsXML,CoordXML : IXMLNode;
begin
   writeIntegerXML(ANode,'GRADUATIONX',ord(monde[mondeX].Graduation));
   writeIntegerXML(ANode,'ZEROX',ord(monde[mondeX].ZeroInclus));
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
   OptionsXML := ANode.addChild('OPTIONS');
   writeIntegerXML(optionsXML,'OptGraphe',byte(optionGraphe));{1}
   writeIntegerXML(optionsXML,'OptModele',byte(optionModele));{2}
   writeBoolXML(optionsXML,'Ellipse',traceEllipse);
   writeIntegerXML(optionsXML,'ReperePage',ord(reperePage));
   for i := 0 to pred(DessinTexts.count) do begin
       OptionsXML := ANode.addChild('TEXTE');
       dessinTexts[i].StoreXML(OptionsXML);
   end;
   for i := 0 to pred(DessinLines.count) do begin
         OptionsXML := ANode.addChild('SHAPE');
         dessinLines[i].StoreXML(OptionsXML);
   end;
end;  // ecritConfigXML

Procedure TgrapheParam.litConfigXML(ANode : IXMLNode);
var CoordCourante : integer;

procedure ResetCoord;
var i : integer;
begin
    for i := mondeX to mondeSans do with monde[i] do begin
        defini := false;
        axe := nil;
    end;
    for i := 1 to maxOrdonnee do with coordonnee[i] do begin
        nomX := '';
        nomY := '';
        exclude(trace,trSonagramme);
    end;
    modif := [];
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
begin // loadXMLInReg
      if ANode.NodeName='COORD' then begin
         coordCourante := ANode.Attributes[stIndex];
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
      if ANode.NodeName='GRADUATIONX' then begin
         zByte := GetIntegerXML(ANode);
         monde[mondeX].graduation := Tgraduation(zByte);
         exit;
      end;
      if ANode.NodeName='ZEROX' then begin
         zBool := GetBoolXML(ANode);
         monde[mondeX].zeroInclus := zBool;
         exit;
      end;
      if ANode.NodeName='GRADUATION' then begin
         zByte := GetIntegerXML(ANode);
         if (coordCourante>=1) and (coordCourante<=MaxOrdonnee) then
            monde[coordonnee[coordCourante].iMondeC].graduation := Tgraduation(zByte);
         exit;
      end;
      if ANode.NodeName='OPTIONS' then begin
         suite;
         exit;
      end;
      if ANode.NodeName='ZERO' then begin
         zBool := GetBoolXML(ANode);
         if (coordCourante>=1) and (coordCourante<=MaxOrdonnee) then
            monde[coordonnee[coordCourante].iMondeC].zeroInclus := zBool;
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
         AdessinText := TdessinText.createText(TGrapheParam(self));
         AdessinText.loadXML(ANode);
         dessinTexts.add(AdessinText);
         exit;
      end;
      if ANode.NodeName='SHAPE' then begin
         AdessinLine := TdessinLine.createLine(TGrapheParam(self));
         AdessinLine.loadXML(ANode);
         dessinLines.add(AdessinLine);
         exit;
      end;
      if ANode.NodeName='MODELECALC' then begin;
         modeleCalcule := getBoolXML(ANode);
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
         exit;
      end;
      if ANode.NodeName='SuperPage' then begin
         exit;
      end;
      if ANode.NodeName='ProjeteVect' then begin
         exit;
      end;
      if ANode.NodeName='FilDeFer' then begin
         exit;
      end;
      if ANode.NodeName='Ellipse' then begin
         TraceEllipse := GetBoolXML(ANode);
         exit;
      end;
      if ANode.NodeName='ProlongeVect' then begin
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
      if ANode.NodeName='TANGENTE' then begin
         exit;
      end;
end; // LoadXMLInReg

var i: Integer;
begin
   Curseur := curSelect;
   configCharge := true;
   resetCoord;
   if ANode.HasChildNodes then
      for I := 0 to ANode.ChildNodes.Count - 1 do
          LoadXMLInReg(ANode.ChildNodes.Nodes[I]);
   verifCoordonnee;
end; // litConfigXML

procedure TgrapheParam.RazBornesClick;
begin
         ModeleCalcule := false;
         ModeleErrone := false;         
         include(modif,gmModele);
         PaintBox.repaint;
end;

procedure TgrapheParam.ImprModeleBtnClick;
var bas : single;

procedure ImprimeModele;
begin
         BeginPrintTxt(bas);
         PrintList(TexteModele,stModelisation,bas);
         PrintList(MemoResultat.lines,stModelisation,bas)
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

procedure TgrapheParam.ChoixCurseurClick(sender : TObject);
var  newCurseur : Tcurseur;
     codeDerivee : integer;
begin // ChoixCurseurClick
     newCurseur := Tcurseur((sender as Tcomponent).tag);
     if (newCurseur=curEquivalence) then begin
         codeDerivee := indexDerivee(monde[mondeY].axe,monde[mondeX].axe,true,true);
         if codeDerivee=grandeurInconnue
            then setPenBrush(curSelect)
            else setPenBrush(curEquivalence);
        ligneRappelCourante := lrTangente;
        ligneRappelTangente := lrTangente;
        exit;
     end;
     if NewCurseur=curReticuleData then begin
        ReticuleDataDlg := TReticuleDataDlg.create(FregressiMain);
        ReticuleDataDlg.Agraphe := self;
        CentreForm(ReticuleDataDlg);
        if ReticuleDataDlg.showModal<>mrOK then
           newCurseur := curSelect;
        ReticuleDataDlg.free;
     end;
     (sender as TmenuItem).IsChecked  := true;
     setPenBrush(NewCurseur);
     dessinTextCourant := nil;
     dessinLineCourant := nil;
     case curseur of
          curReticule : begin
              Origin := FRegressiMain.ScreenToClient(Origin);
              Origin.Offset(paintBox.Position.x,PaintBox.Position.y);
              if not InitReticule then setPenBrush(curSelect);
              //affecteConstParam;
              ligneRappelCourante := lrReticule;
          end;
          curReticuleData,curSelect : paintBox.repaint;
          curLigne : begin
               DessinLineCourant := TdessinLine.createLine(self);
               DessinLineCourant.stroke.color := couleurLigne;
               DessinLineCourant.SetMoveDown(PaintBoxMouseMove,nil,nil);
          end;
          curTexte : begin
               DessinTextCourant := TdessinText.createText(self);
               DessinTextCourant.color := couleurTexte;
          end;
     end;
end;  // ChoixCurseurClick

procedure TgrapheParam.AffecteModele;
var i : integer;
begin
    ChercheMinMax;
    for i := 0 to pred(courbes.count) do with courbes.items[i] do
    if (indexModele>0) then begin
        with fonctionTheoriqueGlb[indexModele] do begin
             DebutC := 0;
             GenereMGlb(valX,valY,miniMod,maxiMod,monde[mondeX].graduation=gLog,FinC);
        end;
    end;
end; // affecteModele

procedure TgrapheParam.ZoomModele;
var i : integer;
begin
    ChercheMinMax;
    for i := 0 to pred(courbes.count) do with courbes.items[i] do
           if (indexModele>0) then with fonctionTheoriqueGlb[indexModele] do begin
              DebutC := 0;
              GenereMGlb(valX,valY,miniMod,maxiMod,monde[mondeX].graduation=gLog,FinC);
           end;
end; // zoomModele

procedure TgrapheParam.PanelCentralKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
     case curseur of
       curReticuleData : begin
            if key=vkEscape then begin
               setPenBrush(CurSelect);
               exit;
            end;
            GetCurseurProche(Origin,true);
        end;
        curTexte : ;
        curLigne : ;
        curReticule : if key=vkEscape then begin
           setPenBrush(CurSelect);
           exit;
        end;
     end; // case
end; // keyDown

procedure TgrapheParam.ConvertitXY(sender : TObject;var x,y : single);
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
end;

procedure TgrapheParam.VerifIntervalles;
var i,N : integer;
begin
     N := 0;
     for i := 1 to nbrePages do
         if pages[i].active then inc(N);
     if N<3 then begin
        i := 1;
        repeat
            if not pages[i].active then begin
               pages[i].active := true;
               inc(N);
            end;
            inc(i);
        until (N>3) or (i>NbrePages);
     end;
end;

procedure TgrapheParam.VerifParametres;
var i : integer;
begin
    for i := 1 to NbreParamGlb do
        if isNan(parametresGlb[i].valCourante)
           then parametresGlb[i].valCourante := parametresGlb[i].ordreDeGrandeur;
end;

procedure TgrapheParam.LanceCompileModele;
var PosErreur,longErreur,i : integer;
begin
     etatModele := [];
     NbreModeleGlb := 0;
     NbreFonctionSuperGlb := 0;
     NbreParamGlb := 0;
     PosErreur := 0;
     LongErreur := 0;
     while (MemoModele.lines.count>0) and
           (MemoModele.lines[0]='') do MemoModele.lines.delete(0);
     while (MemoModele.lines.count>2) and
           (MemoModele.lines[MemoModele.lines.count-1]='') and
           (MemoModele.lines[MemoModele.lines.count-2]='')
          do MemoModele.lines.delete(MemoModele.lines.count-1);
     compileModele(posErreur,longErreur);
     if ModeleDefini in etatModele
        then begin
             ConstruitModele;
             for i := 1 to NbreParamGlb do
                 nomParamGlb[i] := parametresGlb[i].nom;
             for i := succ(NbreParamGlb) to maxParametres do
                 nomParamGlb[i] := '';
        end
        else if not (PasDeModele in etatModele) then with memoModele do begin
             selStart := pred(posErreur);
             selLength := longErreur;
             if isVisible then setFocus;
        end;
end; // LanceCompileModele


Procedure TgrapheParam.MajParametres;
var i,acol,arow : integer;
begin with ParamGrid do begin
       VerifIntervalles;
       verifParametres;
       ColumnCount := 7;
       RowCount := NbreParamGlb;
       for i := 1 to pred(columnCount) do // Button de size 24
           ColumnWidths[i] := 28;
       ColumnWidths[3] := 64;
       ColumnWidths[0] := 40;
       for i := 1 to NbreParamGlb do begin
           Cells[0,i-1] := ParametresGlb[i].nom;
           Cells[3,i-1] := formatGeneral(parametresGlb[i].valCourante,3);
           AddButton(1,i-1,'/2');
           AddButton(5,i-1,'*2');
           AddButton(2,i-1,'↓');
           AddButton(4,i-1,'↑');
           AddButton(6,i-1,'±');
       end;
       for acol := 0 to pred(columnCount) do
           for arow := 0 to pred(RowCount) do begin
               FontSizes[aCol,aRow]:= 13;
               if (acol<>3) and (acol<>0) then begin // button
                  FontStyles[aCol,aRow] := [TFontStyle.fsBold];
                  FontColors[aCol,aRow]:= claBlue;
                  FontSizes[aCol,aRow]:= 17;
               end;
         //      FontNames[aCol,aRow]:= FonteRegressi;
           end;
end end; // MajParametres

end.



