unit graphfft;

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
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.Printer,
  FMX.Platform,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.StdCtrls,
  FMX.Graphics,
  FMX.Spinbox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,

  compile,
  constreg,
  fft,
  graphker,
  maths,
  regutil,
  myShape,
  images;


const
  margeDebutFin = 6;
  minPeriodeFFT = 32;

type
  TFGrapheFFT = class(TForm)
    PanelCourbe: TPanel;
    PaintBoxTemps: TPaintBox;
    PaintBoxFrequence: TPaintBox;
    PopupMenuFFT: TPopupMenu;
    CouleursItem: TMenuItem;
    CopierGrapheItem: TMenuItem;
    FFTToolBar: TToolBar;
    OptionsBtn: TButton;
    ZoomBtn: TButton;
    TempsBtn: TButton;
    limitesBtn: TButton;
    PopupMenuTemps: TPopupMenu;
    CopierTempsWMF: TMenuItem;
    SplitterTemps: TSplitter;
    ZoomAutoBtn: TButton;
    Imprimer1: TMenuItem;
    SourisBtn: TButton;
    SourisMenu: TPopupMenu;
    StandardItem: TMenuItem;
    TexteItem: TMenuItem;
    ReticuleItem: TMenuItem;
    LigneItem: TMenuItem;
    SonagrammeBtn: TButton;
    Enregistrer1: TMenuItem;
    SaveDialog: TSaveDialog;
    SaveGraphItem: TMenuItem;
    NbreHarmAffSpin: TSpinBox;
    NraiesLabel: TLabel;
    Imprimer2: TMenuItem;
    ZoneClipBoard: TRectangle;
    EditBidon: TEdit;
    FenetreMenu: TPopupMenu;
    RectangleItem: TMenuItem;
    FenetreRectItem: TMenuItem;
    MenuItem3: TMenuItem;
    FenetreBtn: TButton;
    MenuItem1: TMenuItem;
    MenuItem4: TMenuItem;
    HelpBtn: TButton;
    procedure FrequenceMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: single);
    procedure ZoomAvantItemClick(Sender: TObject);
    procedure FrequenceMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: single);
    procedure FrequenceMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: single);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure zoomAutoItemClick(Sender: TObject);
    procedure TableauItemClick(Sender: TObject);
    procedure FrequencePaint(Sender: TObject; Canvas: TCanvas);
    procedure TempsPaint(Sender: TObject; Canvas: TCanvas);
    procedure FormDestroy(Sender: TObject);
    procedure OptionsFourierItemClick(Sender: TObject);
    procedure CouleursItemClick(Sender: TObject);
    procedure TempsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: single);
    procedure TempsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: single);
    procedure TempsMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: single);
    procedure PeriodeBtnClick(Sender: TObject);
    procedure PaintBoxFrequenceDblClick(Sender: TObject);
    procedure ToutBtnClick(Sender: TObject);
    procedure FrequenceReduiteCBClick(Sender: TObject);
    procedure ImprimeBtnClick(Sender: TObject);
    procedure DebutFFTspinDownClick(Sender: TObject);
    procedure DebutFFTspinUpClick(Sender: TObject);
    procedure FinFFTspinUpClick(Sender: TObject);
    procedure FinFFTspinDownClick(Sender: TObject);
    procedure CopierItemClick(Sender: TObject);
    procedure SourisBtnClick(Sender: TObject);
    procedure ReticuleBtnClick(Sender: TObject);
    procedure StandardItemClick(Sender: TObject);
    procedure ZoomDebutFinItemClick(Sender: TObject);
    procedure PasSonAffEditExit(Sender: TObject);
    procedure pasSonCalculEditExit(Sender: TObject);
    procedure SonagrammeBtnClick(Sender: TObject);
    procedure Enregistrer1Click(Sender: TObject);
    procedure SaveGraphItemClick(Sender: TObject);
    procedure TempsBtnClick(Sender: TObject);
    procedure SelectionTempsChange(Sender: TObject);
    procedure NbreHarmAffSpinChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SplitterTempsMouseLeave(Sender: TObject);
    procedure SplitterTempsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure EditBidonKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure TexteItemClick(Sender: TObject);
    procedure LigneItemClick(Sender: TObject);
    procedure FenetreBtnClick(Sender: TObject);
    procedure RectangleItemClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
      reelClick : boolean;
      listePic : TlistePic;
      indexFonction : integer;
      CourbeCourante : integer;
      avecPoint : boolean;
      ListeY : Tstrings;
      PointOld : TpointF;
      Frequence,Amplitude : vecteur;
      Xdeplace : single;
      CurMovePermis : boolean;
      xCurseurEchelleFreq : single;
      majRaiesAfaire : boolean;
      indexSonagramme : integer;
      origin : TPointF;
      enveloppeSpectre : boolean;
      continuInclus : boolean;
      ordonneeFFTgr : TordonneeFFT;
      Procedure SetCoordonnee;
      procedure SetCurseurF(c : Tcurseur);
      Procedure AffecteDebutFin;
      procedure TraceDebutFin;
      Procedure MajGrapheFFT;
      procedure changeEchelleSon(xnew, xold: single);
      procedure calculSonagramme;
      procedure ConvertitXY(sender : TObject;var x,y : single);
  protected
  public
      GrapheFrequence,GrapheTemps : TgrapheReg;
      procedure ecritConfig;
      procedure litConfig;
      procedure ecritConfigXML(ANode : IXMLNOde);
      procedure litConfigXML(ANode : IXMLNOde);
      procedure ImprimerGraphe(var bas : single);
      Procedure ResetTemps;
      procedure WMRegMaj(typeMaj : integer);
  end;

var FGrapheFFT : TFGrapheFFT;

implementation

uses Regmain, optFFT, Modif, options, optcolordlg, AideU, aidekey;

{$R *.FMX}

procedure TFGrapheFFT.FrequenceMouseMove(Sender: TObject;
    Shift: TShiftState; X,Y: single);

procedure AffichePosition;
var Xr,Yr : double;
    XX,YY : string;
    iProche : integer;
    P : TPointF;
begin with GrapheFrequence do begin
      if not(monde[mondeX].defini) or not(monde[mondeY].defini) then exit;
      if curseurCourant=0 then getCurseurProche(TPointF.create(X,Y),false);
      if curseurCourant=0 then exit;
      P := TPointF.create(X,Y);
      mondeRT(P,mondeY,Xr,Yr);
      if SonagrammeBtn.isPressed
      then begin
          XX := courbes.items[courbeCourante].varX.formatNomEtUnite(yr);
          yr := round(yr/pasFreqSonagramme)*pasFreqSonagramme;
          YY := courbes.items[courbeCourante].varY.formatNomEtUnite(yr);
      end
      else begin
          iProche := PointProche(P,CourbeCourante,true,true);
          // à la sortie P pointe sur le point proche
          yr := courbes.items[courbeCourante].valY[iProche];
          xr := courbes.items[courbeCourante].valX[iProche];
          if monde[mondeY].graduation=gdB
               then YY := courbes.items[courbeCourante].varY.nom+'='+
                   floatToStrF(20*log10(yr),ffGeneral,3,0)+' dB'
               else YY := courbes.items[courbeCourante].varY.formatNomEtUnite(yr);
          XX := grandeurs[cFrequence].formatNomEtUnite(xr);
      end;
      curseurOsc[1].texteX := ' '+XX+' ';
      curseurOsc[1].texteY := ' '+YY+' ';
      curseurOsc[1].Pc.x := P.x;
      curseurOsc[1].Pc.y := P.y;
      curseurOsc[1].repaint; // nouvelle position
end end;

var deplacement : boolean;
    deltaM : double;
begin  // FrequenceMouseMove
   if not grapheFrequence.grapheOK then exit;
   ConvertitXY(sender,x,y);
   deplacement := ssLeft in Shift;
   origin.x := x;
   origin.Y := y;
   with PaintBoxFrequence,grapheFrequence do
   case curseur of
        curZoomAv : if deplacement then begin
            selection.width := x-selection.Position.x;
            if SonagrammeBtn.isPressed
               then selection.height := y-selection.position.y;
        end;
        curFmaxi : if abs(x-xCurseurEchelleFreq)>8 then begin
             changeEchelleX(x,xCurseurEchelleFreq);
             xCurseurEchelleFreq := x;
             majRaiesAfaire := true;
             PaintBoxFrequence.repaint;
        end;
        curFmaxiSon : if abs(y-xCurseurEchelleFreq)>8 then begin
             changeEchelleSon(y,xCurseurEchelleFreq);
             xCurseurEchelleFreq := y;
        end;
        curReticule : affichePosition;
        curMove : if deplacement
        then begin
            with monde[mondeX] do begin
                 deltaM := (x-selection.position.x)/a;
                 if deltaM>mini then deltaM := mini; // ne pas dépasser f=0
                 mini := mini-deltaM;
                 maxi := maxi-deltaM;
                 defini := true;
            end;
            if abs(x-selection.Position.x)>8 then begin
               paintBox.repaint;
               selection.position.x := origin.x;
               selection.position.y := origin.y;
            end;
        end
        else setCurseurF(curSelect);
        curSelect : if deplacement
               then begin
                  if dessinTextCourant<>nil then
                     dessinTextCourant.affecteXY(x,y);
                  if (dessinLineCourant<>nil) then
                     dessinLineCourant.affecteXY(x,y);
               end
               else begin
               AffichePosition;
               if isAxeX(TpointF.Create(x,y)) and
                  not SonagrammeBtn.isPressed
               then cursor := crHsplit
               else if SonagrammeBtn.isPressed and
                      (x<limiteCourbe.left)
                     then cursor := crVsplit
                     else cursor := crDefault;
        end;
        curTexte:;
        curLigne : if (dessinLineCourant<>nil) then
            dessinLineCourant.affectePoint2(x,y);
   end; // case curseurF
end; // FrequenceMouseMove

procedure TFGrapheFFT.ZoomAvantItemClick(Sender: TObject);
begin
    setCurseurF(curZoomAv);
end;

procedure TFGrapheFFT.SetCurseurF(c : Tcurseur);
begin with PaintBoxFrequence.Canvas do begin
  grapheFRequence.curseur := c;
  grapheFRequence.curseurOsc[1].Visible := c=curReticule;
  case c of
       curZoomAv : stroke.Dash := TStrokeDash.Dash;
       curFmaxi : PaintBoxFrequence.cursor := crHsplit;
       curFmaxiSon : PaintBoxFrequence.cursor := crVsplit;
       curTexte : ;
       curLigne : ;
       curReticule : begin
           PaintBoxFrequence.cursor := crNone;
           grapheFrequence.curseurCourant := 1;
           ligneRappelCourante := lrReticule;
       end;
       curSelect : begin
          PaintBoxFrequence.cursor := crDefault;
          StandardItem.IsChecked  := true;
       end;
       curMove : PaintBoxFrequence.cursor := crSizeAll;
    end;{case}
end end; // setCurseurF

procedure TFGrapheFFT.FrequenceMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: single);

procedure AffecteDessinText;
begin with grapheFrequence do begin
   if dessinTextCourant<>nil then
      dessinTextCourant.affecteXY(x,y);
   if dessinTextCourant.litOption
   then begin
      dessinTexts.Add(DessinTextCourant);
      ModifFichier := true;
   end
   else dessinTextCourant.free;
   dessinTextCourant := nil;
   setCurseurF(curSelect);
end end; // AffecteDessinText

var j : integer;
begin
   ConvertitXY(sender,x,y);
   origin.x := x;
   origin.Y := y;
   if grapheFrequence.grapheOK then with grapheFrequence do case curseur of
       curZoomAv : if (sender=PaintBoxFrequence) then begin
            if SonagrammeBtn.isPressed
               then begin
                  selection.position.x := origin.x;
                  selection.position.y := origin.y;
               end
               else begin
                  selection.position.x := x;
                  selection.position.y := 10;
                  selection.Height := PaintBoxFrequence.height-20;
               end;
            selection.visible := true;
       end;
       curFmaxi,curFmaxiSon : ;
       curReticule : ;
       curSelect : begin
          if (Button=TMouseButton.mbRight) then exit;
            // clic droit donc menu contextuel
          for j := 1 to grapheFrequence.NbreOrdonnee do
            if curMovePermis then begin
                  setCurseurF(curMove);
                  selection.Visible := true;
                  selection.position.x := origin.x;
                  selection.position.y := origin.y;
              end;
           if not SonagrammeBtn.isPressed and
               isAxeX(TpointF.Create(x,y)) then begin
                 xCurseurEchelleFreq := x;
                 SetCurseurF(curFmaxi);
            end;
           if SonagrammeBtn.isPressed and
              (x<limiteCourbe.left) then begin
                 xCurseurEchelleFreq := y;
                 SetCurseurF(curFmaxiSon);
            end;
       end;
       curTexte : affecteDessinText;
       curLigne : if (dessinLineCourant<>nil) then
          dessinLineCourant.affectePoint1(x,y);
  end
end; // FrequenceMouseDown

procedure TFGrapheFFT.FrequenceMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: single);

Procedure affecteZoom;
begin with grapheFrequence do begin
    setCurseurF(CurSelect);
    selection.Visible := false;
    if selection.Width<16 then exit;
    affecteZoomAvant(SonagrammeBtn.isPressed);
    monde[mondeX].ZeroInclus := false;
    monde[mondeX].defini := true;
    monde[mondeX].minDefaut := monde[mondeX].mini;
    monde[mondeX].maxDefaut := monde[mondeX].maxi;
    useDefautX := true;
    if SonagrammeBtn.isPressed then begin
        monde[mondeY].ZeroInclus := false;
        monde[mondeY].defini := true;
        monde[mondeY].minDefaut := monde[mondeY].mini;
        monde[mondeY].maxDefaut := monde[mondeY].maxi;
    end;
    curMovePermis := true;
    PaintBoxFrequence.repaint;
end end; // affecteZoom

procedure AffecteDessinLine;
begin with grapheFrequence do begin
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
   setCurseurF(curSelect);
end end; // AffecteDessinLine

begin // FrequenceMouseUp
with grapheFrequence do begin
   if not grapheOK then exit;
   if Button=TmouseButton.mbRight then exit;
   ConvertitXY(sender,x,y);
   case curseur of
       curZoomAv : affecteZoom;
       curFmaxi : begin
           changeEchelleX(x,xCurseurEchelleFreq);
           setCurseurF(curSelect);
           PaintBoxFrequence.repaint;
       end;
       curFmaxiSon : begin
           changeEchelleSon(y,xCurseurEchelleFreq);
           PaintBoxFrequence.repaint;
           setCurseurF(curSelect);
       end;
       curTexte:;
       curLigne : affecteDessinLine;
       curReticule : ;
       curMove : begin
          setCurseurF(curSelect);
          monde[mondeX].defini := true;
          monde[mondeX].minDefaut := monde[mondeX].mini;
          monde[mondeX].maxDefaut := monde[mondeX].maxi;
          useDefautX := true;
       end;
       curSelect : begin
          dessinLineCourant := nil;
          dessinTextCourant := nil;
       end;
  end;
  PointOld := TpointF.create(X,Y);
  reelClick := false;
end end; // FrequenceMouseUp

procedure TFGrapheFFT.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     grapheTemps.free;
     grapheFrequence.free;
  // avant destruction des paintBox
end;

procedure TFGrapheFFT.FormCreate(Sender: TObject);
var j : integer;
begin
  enveloppeSpectre := false;
  continuInclus := false;
  ordonneeFFTgr := oNormal;
  AvecPoint := true;
  reelClick := false;
  ListeY := TstringList.Create;
  listePic := TlistePic.Create;

  GrapheFrequence := TgrapheReg.create(paintBoxFrequence);
  GrapheFrequence.Selection.SetMoveDown(FrequenceMouseMove,FrequenceMouseDown,FrequenceMouseUp);
  grapheFrequence.zoneClipBoard := zoneClipBoard;
  GrapheFrequence.optionGraphe := [OgPseudo3D];
  GrapheFrequence.modif := [gmXY];
  MajRaiesAfaire := true;
  grapheFrequence.curseur := curSelect;

  GrapheTemps := TgrapheReg.create(paintBoxTemps);
  GrapheTemps.Selection.SetMoveDown(TempsMouseMove,TempsMouseDown,TempsMouseUp);
  grapheTemps.zoneClipBoard := zoneClipBoard;
  GrapheTemps.Monde[MondeX].zeroInclus := false;

  setLength(Frequence,MaxVecteurDefaut+1);
  setLength(Amplitude,MaxVecteurDefaut+1);
  if (NbreGrandeurs>0) and
     (nomGrandeurTri='') and
     (grandeurs[cFrequence].nom='f') then begin
         if grandeurs[indexTri].nom='f' then grandeurs[cFrequence].nom := 't';
         if grandeurs[indexTri].nom=lambdaMin then grandeurs[cFrequence].nom := sigmaMin;
   end;
   SplitterTemps.Visible := false;
   PaintBoxTemps.Visible := false;
   for j := 1 to MaxCurseur do begin
       grapheFrequence.CurseurOsc[j].SetMoveDown(FrequenceMouseMove,FrequenceMouseDown,FrequenceMouseUp);
       grapheTemps.CurseurOsc[j].SetMoveDown(TempsMouseMove,TempsMouseDown,TempsMouseUp);
   end;
   NbreHarmAffSpin.Value := nbreHarmoniqueAff;
   for j := 0 to pred(FenetreMenu.childrenCount) do
       if FenetreMenu.Items[j].Tag=ord(fenetre) then
          FenetreMenu.Items[j].isChecked := true;
   FenetreBtn.hint := nomFenetre[fenetre];
   FenetreBtn.imageIndex := indexFenetre[fenetre];
end;

procedure TFGrapheFFT.SetCoordonnee;

procedure SetCoordonneeFFT;
var indexY : integer;
    decale : single;
    avecEnveloppe : boolean;
    freqMax : double;

Procedure AjouteFFT(Acouleur : TAlphaColor;Apage,colF : integer;Amonde : indiceMonde);
var Ay,Ax : vecteur; // sert au graphe et au tableau
    AyMax : double;

Procedure RemplitColonne(colCourante : integer;nbre : integer);
var ligne,ligne0 : integer;
    z,zprecedent,zsuivant : double;
    maxiA : double;
    i0 : integer;
    miniPrec,maxiPrec,finesse : double;
begin with pages[Apage] do begin
      i0 := getFondamental(Nbre,Ay);
      maxiA := Ay[i0]*precisionFFT;
      ligne0 := i0 div 8;
      if ligne0=0 then ligne0 := 1;
      z := Ay[ligne0];
      zsuivant := Ay[ligne0+1];
      listePic.index := indexY;
      listePic.clear;
      finesse := precisionFFT*5;
      miniPrec := 0;
      maxiPrec := maxiA;
      for ligne := succ(ligne0) to (Nbre-2) do
           with grandeurs[indexY] do begin
                zprecedent := z;
                z := zsuivant;
                zsuivant := Ay[ligne+1];
                if avecPeriode and (fenetre=rectangulaire)
                   then if z>maxiA
                      then listePic.Add(ax[ligne],z)
                      else
                   else if (z>maxiA) and
                       (z>zprecedent) and
                       (z>zsuivant) and
                       ((z-miniPrec)>z*finesse) then begin
                           listePic.Add(ax[ligne],z);
                           maxiPrec := z;
                       end;
                if (z<zprecedent) and
                   (z<zsuivant) then  begin
                       miniPrec := z;
                       if ((maxiPrec-z)<z*finesse) then
                           listePic.removeLast;
                   end;
           end;
       listePic.Nettoie(FreqMax);
       listePic.Tri; // selon la valeur alors que le remplissage est selon la fréquence
end end; // RemplitColonne

Procedure AjouteCourbeFreq(var Nbre : integer);
var Acourbe : Tcourbe;

Procedure AddCourbe;
begin with GrapheFrequence do begin
     Acourbe := AjouteCourbe(Ax,Ay,Amonde,
         Nbre,
         grandeurs[cFrequence],grandeurs[indexY],Apage);
     monde[Amonde].graduation := monde[mondeY].graduation;
     monde[Amonde].MinidB := monde[mondeY].MinidB;
     Acourbe.setStyle(Acouleur,TStrokeDash.Solid,mCroix);
     if continuInclus
        then Acourbe.debutC := 0
        else Acourbe.debutC := 1;
     Acourbe.decalage := decale;
end end; // AddCourbe

var i : integer;
    harmMax : double;
begin // AjouteCourbeFreq
     if grandeurs[indexY].fonct.genreC<>g_definitionFiltre then begin
          if NbreHarmoniqueOptimise then begin
                harmMax := precisionFFT*Aymax;
                if Nbre > High(Ay) then Nbre := High(Ay);
                while (Nbre > 1) and (Ay[Nbre]<harmMax) do dec(Nbre);
                Nbre := Puiss2Sup(Nbre);
                if Nbre > Length(Ax) then Nbre := Length(Ax);
                if Nbre > Length(Ay) then Nbre := Length(Ay);
          end;
          if freqMax<Ax[pred(Nbre)] then freqMax := Ax[pred(Nbre)];
// en cas de zoom (avec non puissance de 2)
// avec zero padding, la période de calcul est plus grande que la période affichée
     end;
     if (ordonneeFFTgr=oReduite) and (AyMax>0) then
         for i := 1 to pred(Nbre) do
             Ay[i] := Ay[i]/AyMax;
     if ordonneeFFTgr=oPuissance then
         for i := 0 to pred(Nbre) do
             Ay[i] := sqr(Ay[i]);
     AddCourbe;
     Acourbe.Adetruire := true;
     if (grandeurs[indexY].fonct.genreC=g_definitionFiltre) or
        (grapheFrequence.monde[mondeY].graduation=gdB)
        then Acourbe.trace := [trLigne]
        else begin
           Acourbe.trace := [trPoint];
           Acourbe.motif := mSpectre;
        end;
end; // AjouteCourbeFreq

Procedure AjouteCourbeEnv;
var Acourbe : Tcourbe;
    i,Nbre,maxi : integer;
    Aa,Af : vecteur;

Procedure CherchePicEnv;
var ligne,i0 : integer;
    z,zprecedent,zsuivant : double;
    maxiA,miniPrec,maxiPrec,finesse : double;
    ligne0 : integer;
begin
      listePic.clear;
      listePic.index := indexY;
      i0 := getFondamental(Nbre,Aa);
      maxiA := Aa[i0]*precisionFFT;
      ligne0 := i0 div 8;
      if ligne0=0 then ligne0 := 1;
      z := Aa[ligne0];
      zsuivant := Aa[ligne0+1];
      miniPrec := 0;
      maxiPrec := maxiA;
      finesse := precisionFFT*5;
      for ligne := succ(ligne0) to (Nbre-2) do begin
          zprecedent := z;
          z := zsuivant;
          zsuivant := Aa[ligne+1];
          if (z>maxiA) and
             (z>zprecedent) and
             (z>zsuivant) and
             ((z-miniPrec)>z*finesse) then begin
                listePic.Add(Af[ligne],z);
                maxiPrec := z;
             end;
          if (z<zprecedent) and
             (z<zsuivant) then begin
                 miniPrec := z;
                 if ((maxiPrec-z)<z*finesse) then
                        listePic.removeLast;
             end;
      end;  // tous les pics plus grands que maxi*precision
      ListePic.Tri;
end; // Pics

const maxEnv = 32768;//8192;
begin // AjouteCourbeEnv
     with pages[Apage] do begin
         if NbreFFT>maxEnv then exit;
         Maxi := 8*NbreFFT;
         if Maxi>maxEnv then Maxi := maxEnv;
         if Maxi<2048 then Maxi := 2048; // 1 point / pixel
         setlength(Af,Maxi);
         setlength(Aa,Maxi);
         if fenetre=rectangleAjuste then begin
            fenetre := rectangulaire;
            genereSpectreFourierP(indexY);
            fenetre := rectangleAjuste;
         end;
         enveloppeFourier(NbreFFT,Maxi,PeriodeFFT,fenetreFourier[indexY],Af,Aa);
         Nbre := Maxi div 2;
         if fenetre=rectangleAjuste then
            genereSpectreFourierP(indexY);
     end;
     Acourbe := GrapheFrequence.AjouteCourbe(Af,Aa,Amonde,Nbre,
         grandeurs[cFrequence],grandeurs[indexY],Apage);
     Acourbe.setStyle(getCouleurPale(Acouleur),TStrokeDash.Solid,mLosange);
     if (ordonneeFFTgr=oReduite) and (AyMax>0) then
         for i := 0 to pred(Nbre) do
             Aa[i] := Aa[i]/AyMax;
     if ordonneeFFTgr=oPuissance then
         for i := 0 to pred(Nbre) do
             Aa[i] := sqr(Aa[i]);
     Acourbe.decalage := decale;
     i := 0;
     if not continuInclus then begin
        repeat inc(i)
        until (i>Nbre div 64) or (Aa[i]>Aa[i-1]) or (Aa[i]<aymax);
              // fin du pic continu
     end;
     Acourbe.debutC := i;
     Acourbe.trace := [trLigne];
     Acourbe.Adetruire := true;
     Acourbe.traceFin := true;
     if Apage=pageCourante then cherchePicEnv;
end; // AjouteCourbeEnv

Procedure AjouteCourbeTemps;
var Acourbe : Tcourbe;
begin
if grandeurs[indexY].fonct.genreC=g_definitionFiltre then exit;
with Pages[Apage] do begin
     If Fenetre in [Hamming,Flattop,Blackman] then begin
        Acourbe := GrapheTemps.AjouteCourbe(valeurLisse[indexTri],fenetreFourier[indexY],
            Amonde,NbreFFT,grandeurs[indexTri],grandeurs[indexY],Apage);
        Acourbe.setStyle(GetCouleurPale(Acouleur),TStrokeDash.Solid,mCroix);
        Acourbe.trace := [trLigne];
     end;
     Acourbe := GrapheTemps.AjouteCourbe(valeurVar[indexTri],valeurVar[indexY],
            Amonde,Nmes,grandeurs[indexTri],grandeurs[indexY],Apage);
     Acourbe.setStyle(Acouleur,TStrokeDash.Solid,mCroix);
     Acourbe.trace := [trLigne];
end end;

var i,nbre : integer; // ajouteFFT
begin with GrapheFrequence,pages[Apage] do begin
     tri;
     genereSpectreFourierP(indexY);
     if fftReel[indexY]=nil then exit;
     setLength(Ay,NbreFFT div 2 +1);
     for i := 0 to pred(NbreFFT div 2) do
         AY[i] := fftAmpl[indexY,i];
     setLength(Ax,NbreFFT div 2+1);
     copyVecteur(Ax,grandeurs[cFrequence].valeur);
     AYmax := getMaxiFFT(NbreFFT div 2,fftAmpl[indexY]);
     avecEnveloppe := enveloppeSpectre and
          (NbreFFT<(MaxMaxVecteur div 2));
     Nbre := NbreFFT div 2;
     AjouteCourbeFreq(nbre);
     AjouteCourbeTemps;
     if avecEnveloppe then AjouteCourbeEnv;
     if (not avecEnveloppe) and (Apage=pageCourante) then
        RemplitColonne(colF,nbre);
     decale := decale + decalageFFT;
end end; // ajouteFFT

var
  j : integer;
  page : integer;
  mondeLoc : indiceMonde;
begin // SetCoordonneeFFT
    freqMax := 0;
    mondeLoc := mondeY;
    with GrapheFrequence do begin
       decale := 0;
       for j := 1 to maxOrdonnee do
           Coordonnee[j].iMondeC := mondeY;
       NbreOrdonnee := listeY.count;
       if NbreOrdonnee>MaxOrdonnee then NbreOrdonnee := MaxOrdonnee;
       for j := 0 to pred(NbreOrdonnee) do begin
           coordonnee[succ(j)].nomY := ListeY[j];
           indexY := IndexNom(listeY[j]);
           if j=0 then indexFonction := indexY;
           if superposePage and (NbrePages>1) 
             then begin
                for page := 1 to NbrePages do
                  if pages[page].active then begin
                      AjouteFFT(getCouleurPages(page),page,page*j,mondeLoc);
                      if OgAnalyseurLogique in OptionGraphe then inc(mondeLoc);
                  end;
             end
             else begin
                AjouteFFT(couleurInit[succ(j)],pageCourante,j,MondeLoc);
                if OgAnalyseurLogique in OptionGraphe then inc(mondeLoc);
             end;
        end;
        grapheOK := true;
        if freqMax>0 then begin
           if (gmXY in modif)
              then begin
                 monde[mondeX].defini := false;
                 monde[mondeX].mini := 0;
                 monde[mondeX].maxi := freqMax;
                 monde[mondeX].minDefaut := 0;
                 monde[mondeX].maxDefaut := freqMax;
                 useDefautX := false;
              end
              else if not UseDefautX then begin
                  monde[mondeX].mini := 0;
                  monde[mondeX].maxi := freqMax;
              end;
           if not useDefautX then
              for j := 0 to pred(courbes.count) do with courbes[j] do
                  if (finC >= 0) and (finC <= High(valX)) and (valX[finC] > 0) then begin
                     finC := round(finC*freqMax/valX[finc]);
                     if finC > High(valX) then finC := High(valX);
                     if finC > High(valY) then finC := High(valY);
                  end;
        end;
        modif := [];
    end; // GrapheFrequence
    with grapheTemps do begin
       grapheOK := true;
       modif := [];
    end; // GrapheTemps
    optionsBtn.enabled := true;
    fenetreBtn.enabled := true;
    limitesBtn.enabled := true;
    NbreHarmAffSpin.enabled := true;
    zoomBtn.enabled := true;
    zoomAutoBtn.enabled := true;
end; // SetCoordonneeFFT

procedure SetCoordonneeSonagramme;
var indexY : integer;

Procedure AjouteCourbeSonagramme;
var Acourbe : Tcourbe;
begin with Pages[pageCourante] do begin
     if (grapheFrequence.monde[mondeY].graduation<>gdB)  then DecadeDB := 0; // linéaire
     finFFT := pred(nmes);
     debutFFT := 0;
     allDataFFT := true;
     indexSonagramme := indexY;
     calculSonagramme;
     Acourbe := GrapheFrequence.AjouteCourbe(
         valeurVar[indexTri],
         grandeurs[cFrequence].valeur,mondeY,Nmes,
         grandeurs[indexTri],grandeurs[cFrequence],pageCourante);
     grapheFrequence.monde[mondeY].graduation := gLin;
     Acourbe.trace := [trSonagramme];
     GrapheFrequence.useDefautX := false;
end end; // AjouteCourbeSonagramme;

var Acourbe : Tcourbe;
begin // SetCoordonneeSonagramme
    with GrapheFrequence do begin
       Coordonnee[1].iMondeC := mondeY;
       NbreOrdonnee := 1;
       coordonnee[1].nomY := ListeY[0];
       indexY := IndexNom(listeY[0]);
       AjouteCourbeSonagramme;
       exclude(OptionGraphe,OgAnalyseurLogique);
       grapheOK := true;
       courbes[0].finC := pred(pages[pageCourante].nmes);
       modif := [];
    end; // GrapheFrequence
    with grapheTemps do begin
       Acourbe := AjouteCourbe(pages[pageCourante].valeurVar[indexTri],
                  pages[pageCourante].valeurVar[indexY],
                  mondeY,pages[pageCourante].Nmes,
                  grandeurs[indexTri],grandeurs[indexY],pageCourante);
       Acourbe.setStyle(couleurInit[1],TStrokeDash.Solid,mCroix);
       Acourbe.trace := [trLigne];
       grapheOK := true;
       modif := [];
    end; // GrapheTemps
    MajRaiesAfaire := true;
    optionsBtn.enabled := false;
    fenetreBtn.enabled := false;
    limitesBtn.enabled := false;
    zoomBtn.enabled := false;
    zoomAutoBtn.enabled := false;
end; // SetCoordonneeSonagramme

procedure VerifListe;
var i,codeY : integer;
begin
   for i := pred(ListeY.count) downto 0 do begin
       codeY := indexNom(ListeY[i]);
       if (codeY=grandeurInconnue) or
          (codeY=0) or // 0=temps
          (grandeurs[codeY].genreG<>variable)
          then ListeY.delete(i)
   end;
   if ListeY.Count=0 then
      ListeY.add(grandeurs[indexVariab[1]].nom);
end;

begin // SetCoordonnee
     DefinitGrandeurFrequence;
     if gmXY in grapheFrequence.modif
        then begin
           if sonagrammeBtn.isPressed and not TempsBtn.IsPressed then begin
              tempsBtn.isPressed := true;
              resetTemps;
           end;
           GrapheTemps.reset;
           GrapheFrequence.reset;
           if sonagrammeBtn.isPressed then begin
              GrapheFrequence.monde[mondeX].zeroInclus := false;
              GrapheFrequence.monde[mondeY].zeroInclus := true;
           end;
        end
        else begin
           GrapheTemps.courbes.clear;
           GrapheFrequence.courbes.clear;
        end;
     if NbreVariab<2 then begin
        afficheErreur(erNombreVar,0);
        exit;
     end;
     VerifListe;
     if sonagrammeBtn.isPressed
        then SetCoordonneeSonagramme
        else SetCoordonneeFFT;
end; // SetCoordonnee

procedure TFGrapheFFT.FormResize(Sender: TObject);
begin
    majRaiesAfaire := true;
end;

procedure TFGrapheFFT.zoomAutoItemClick(Sender: TObject);
var i,j : integer;
begin with GrapheFrequence do begin
     monde[mondeX].defini := false;
     monde[mondeX].ZeroInclus := true;
     curMovePermis := false;
     useDefautX := false;
     useDefaut := false;
     for i := 0 to pred(courbes.count) do
         with courbes.items[i] do begin
           debutC := 1;
           j := High(valY);
           if High(valX) < j then j := High(valX);
           if j < 0 then begin
              finC := 0;
              continue;
           end;
           if trace=[trLigne] then begin
              while (j > debutC) and (valX[j] = 0) and (valY[j] = 0) do dec(j);
              finC := j;
           end else begin
              while (j > debutC) and (valY[j] = 0) do dec(j);
              finC := j;
           end;
     end;
     PaintBoxFrequence.repaint
end end;

procedure TFGrapheFFT.WMRegMaj(typeMaj: integer);
var c : integer;
begin
      GrapheFrequence.Modif := [];
      case TypeMaj of
          MajChangePage : if not grapheFrequence.superposePage then
              GrapheFrequence.Modif := [gmValeurs];
          MajSelectPage : GrapheFrequence.Modif := [gmValeurs];
          MajGrandeur : GrapheFrequence.Modif := [gmXY];
          MajNom : GrapheFrequence.MajNomGr;
          MajTri : if active then exit else GrapheFrequence.Modif := [gmValeurs];
          MajVide : begin
             grapheFrequence.reset;
             grapheTemps.reset;
             for c := 1 to maxOrdonnee do with grapheFrequence.Coordonnee[c] do begin
                  nomX  := '';
                  nomY  := '';
                  codeX := grandeurInconnue;
                  codeY := grandeurInconnue;
                  iMondeC := mondeY;
                  trace := [];
             end;
             sonagrammeBtn.IsPressed := false;
             tempsBtn.IsPressed := false;
             resetTemps;
          end;
          MajFichier : begin
             for c := 0 to pred(FenetreMenu.childrenCount) do
                 if FenetreMenu.Items[c].Tag=ord(fenetre) then
                    FenetreMenu.Items[c].isChecked := true;
             FenetreBtn.hint := nomFenetre[fenetre];
             FenetreBtn.imageIndex := indexFenetre[fenetre];
             GrapheFrequence.Modif := [gmXY];
             avecPeriode := false;
             imprimer1.visible := imprimanteDisponible;
             imprimer2.visible := imprimanteDisponible;
             resetTemps;
          end;
          MajValeur,MajValeurConst :  GrapheFrequence.Modif := [gmValeurs];
      end;
      if GrapheFrequence.Modif<>[] then begin
         GrapheTemps.Modif := GrapheFrequence.Modif;
         MajRaiesAfaire := true;
         MajGrapheFFT;
      end;
      if grapheFrequence.superposePage and
         (typeMaj in [MajChangePage,MajAjoutPage]) then
            courbeCourante := pred(pageCourante);
end; // WMRegMaj

procedure TFGrapheFFT.TableauItemClick(Sender: TObject);
begin
     GrapheFrequence.monde[mondeX].defini := false;
     paintBoxFrequence.repaint;
end;

procedure TFGrapheFFT.FrequencePaint(Sender: TObject; Canvas: TCanvas);

Procedure MajRaies;

Procedure TraceMarque(i : integer);
var Dessin : TdessinText;
    xx,yy : double;
begin
    XX := listePic.pics[i].valeurF;
    YY := ListePic.pics[i].valeurH;
    Dessin := TdessinText.createText(grapheFrequence);
    with Dessin do begin
          font.size := 16;
          color := claBlue;
          text := grandeurs[cFrequence].formatValeurEtUnite(xx);
          width := PaintBoxFrequence.canvas.textWidth(text);
          height := PaintBoxFrequence.canvas.textHeight(text);
          affecteXY(grapheFrequence.windowX(xx)-width/2,
                    grapheFrequence.windowY(yy,mondeY)-height);
          identification := identRaie;
    end;
    grapheFrequence.dessinTexts.add(Dessin);
end; // TraceMarque

var i : integer;
begin // MajRaies
    for i := pred(grapheFrequence.dessinTexts.count) downto 0 do begin
        if grapheFrequence.dessinTexts[i].identification=identRaie
           then grapheFrequence.dessinTexts.Delete(i);
    end;
    if (NbreHarmoniqueAff=0) or
       SonagrammeBtn.isPressed then exit;
    if NbreHarmoniqueAff>listePic.Nbre then begin
       NbreHarmAffSpin.value := listePic.Nbre;
       NbreHarmoniqueAff := listePic.Nbre;
    end;
    for i := 0 to pred(NbreHarmoniqueAff) do traceMarque(i);
    MajRaiesAfaire := false;
end; // MajRaies

var i,indexMax : integer;
begin // FrequencePaint
if not PaintBoxFrequence.enabled then exit;
if pageCourante>0 then begin
   SonagrammeBtn.Enabled := pages[pageCourante].nmes >  NbrePointsSonagramme*8;
   if not SonagrammeBtn.Enabled then SonagrammeBtn.isPressed := false;
end;
tailleEcran := PanelCourbe.Height;
courbeCourante := 0;
with grapheFrequence do begin
        grapheOK := (pageCourante>0) and
                    (nbrePages>0) and
                    not(lectureFichier) and
                    not(lecturePage);
        superposePage :=  superposePage and (NbrePages>1);
        grapheOK := grapheOK and (pages[pageCourante].nmes>8) and (NbreVariab>1);
        if modif<>[] then curseur := curSelect;
        if grapheOK and
           ((gmXY in modif) or
           (gmEchelle in modif) or
           (gmValeurs in modif) or
           (pages[pageCourante].periodeFFT=0))
              then setCoordonnee;
        grapheOK := grapheOK and (courbes.count>0);
        if (pages[pageCourante].periodeFFT=0) and
           not (sonagrammeBtn.isPressed) then
           grapheFrequence.grapheOK := false;
        if grapheOK and SonagrammeBtn.isPressed then begin
           indexMax := round(FreqMaxSonagramme/pasFreqSonagramme);
           for i := 0 to indexMax do
               grandeurs[cFrequence].valeur[i] := i*pasFreqSonagramme;
           for i := succ(indexMax) to high(grandeurs[cFrequence].valeur) do
               grandeurs[cFrequence].valeur[i] := 0;
           NbreHarmAffSpin.enabled := false;
        end;
        draw;
        if grapheOK then begin
        if MajRaiesAfaire then MajRaies;
        if curseur=curReticule
           then begin
               curseurOsc[1].bringToFront;
               curseurOsc[1].repaint;
           end
           else setCurseurF(curseur);
        end;
    FFTToolBar.Enabled := grapheOK;
    editBidon.SetFocus;
end end; // FrequencePaint

procedure TFGrapheFFT.TempsPaint(Sender: TObject; Canvas: TCanvas);

procedure TraceBorneFFT;
var
  Pdebut, Pfin: TpointF;
begin
  with pages[pageCourante] do begin
    if (debutFFT = 0) and (finFFT > nmes - 8) then
      exit;
    grapheTemps.windowXY(valeurVar[0, finFFT], 0, mondeY, Pfin);
    grapheTemps.windowXY(valeurVar[0, debutFFT], 0, mondeY, Pdebut);
  end;
  with grapheTemps do begin
  if Pdebut.x < LimiteCourbe.left then
     Pdebut.x := LimiteCourbe.left;
  if Pfin.x >= LimiteCourbe.right then
     Pfin.x := LimiteCourbe.right-1;
  if (Pfin.x-Pdebut.x)<(3*LimiteCourbe.right/4)
     then begin
        canvas.Stroke.Thickness := 3*penWidth;
        canvas.Stroke.Color := claGray;
        canvas.stroke.color := claBeige;
        MyDrawRectXY(Pdebut.x,LimiteCourbe.bottom-marge,Pfin.x,LimiteFenetre.top+marge);
     end
     else begin
        createPen(TStrokeDash.Solid, 3*penWidth, GetCouleurPages(1));
        segmentXY(Pdebut.x, LimiteCourbe.bottom, Pdebut.x, LimiteCourbe.top);
        segmentXY(Pfin.x, LimiteCourbe.bottom, Pfin.x, LimiteCourbe.top);
     end;
  canvas.stroke.ThickNess := 1;
  end;
end;

begin
if (PaintBoxTemps.height<8) then exit;
with grapheTemps do begin
    grapheOK := (pageCourante>0) and
         not(lectureFichier) and
        (pages[pageCourante].nmes>8);
    if grapheOK and
         ((gmXY in modif) or
         (gmEchelle in modif) or
         (gmValeurs in modif)) then setCoordonnee;
    limiteFenetre.right := paintBoxTemps.width;
    limiteFenetre.bottom := paintBoxTemps.height;
    draw;
    if grapheOK then TraceDebutFin;
end end; // TempsPaint

procedure TFGrapheFFT.RectangleItemClick(Sender: TObject);
begin
    Fenetre := Tfenetre((sender as TMenuItem).tag);
    FenetreBtn.hint := nomFenetre[fenetre];
    FenetreBtn.imageIndex := indexFenetre[fenetre];
    recalculFourierE;
    GrapheFrequence.modif := [gmEchelle];
    GrapheTemps.modif := [gmEchelle];
    MajRaiesAfaire := true;
    FRegressiMain.WMRegMaj(MajValeur);
    MajGrapheFFT;
end;

procedure TFGrapheFFT.ResetTemps;
begin
     if TempsBtn.isPressed and not PaintBoxTemps.Visible then begin // pas le même ordre !
             PaintBoxTemps.Visible := true;
             SplitterTemps.Visible := true;
             if (PaintBoxTemps.Height<=Height div 3)
                 then PaintBoxTemps.Height := Height div 3;
             grapheTemps.selection.visible := not(sonagrammeBtn.isPressed);
     end;
     if not TempsBtn.isPressed and PaintBoxTemps.Visible then begin
             SplitterTemps.Visible := false;
             PaintBoxTemps.Visible := false;
     end;
     grapheTemps.curseur := curSelect;
end;

procedure TFGrapheFFT.FormDestroy(Sender: TObject);
begin
    ListeY.Free;
    Frequence := nil;
    Amplitude := nil;
    listePic.Clear;
    listePic.Free;
    inherited
end;

Procedure TFgrapheFFT.ecritConfigXML(ANode : IXMLNode);
var i : integer;
    optionsXML : IXMLNode;
begin
   listeY.delimiter := ' ';
   writeStringXML(ANode,'Y',listeY.DelimitedText);
   writeStringXML(ANode,'X',grandeurs[cFrequence].nom);
   writeBoolXML(ANode,'SuperPage',grapheFrequence.SuperposePage);
   writeIntegerXML(ANode,'Graduation',ord(grapheFrequence.monde[mondeY].graduation));
   writeIntegerXML(ANode,'Fenetre',ord(fenetre));
   writeFloatXML(ANode,'MinidB',grapheFrequence.monde[mondeY].MinidB);
   writeFloatXML(ANode,'PrecisionFFT',PrecisionFFT);
   writeBoolXML(ANode,'EnveloppeSpectre',enveloppeSpectre);
   writeBoolXML(ANode,'SonagrammeBtn',SonagrammeBtn.isPressed);
   writeBoolXML(ANode,'NbreHarmOpt',NbreHarmoniqueOptimise);
   writeIntegerXML(ANode,'TypeOrdonnee',ord(ordonneeFFTgr));
   writeBoolXML(ANode,'ContinuInclus',continuInclus);
   writeBoolXML(ANode,'TempsBtn',TempsBtn.isPressed);
   writeIntegerXML(ANode,'DecadedB',DecadeDB);
   writeIntegerXML(ANode,'NbreHarmAff',NbreHarmoniqueAff);
//   writeFloat('PasTempsSonagramme',pasTempsSonagramme);
//   writeInteger('PasSonCalcul',PasSonCalcul);
//   writeFloat('FreqMaxSonagramme',FreqMaxSonagramme);{18}
   for i := 0 to pred(GrapheFrequence.DessinTexts.count) do begin
       optionsXML := ANode.AddChild('TEXTE');
       GrapheFrequence.dessinTexts[i].storeXML(optionsXML);
   end;
end; // ecritConfigXML

Procedure TFgrapheFFT.ecritConfig;
var i,NbreOrdonnee : integer;
begin
   NbreOrdonnee := listeY.count;
   if NbreOrdonnee>MaxOrdonnee then NbreOrdonnee := MaxOrdonnee;
   ecritSousSection(NbreOrdonnee,'Y');
   for i := 1 to nbreOrdonnee do
       ecritLigneRW3(grapheFrequence.coordonnee[i].nomY);
   ecritSousSection(1,'F');
   ecritLigneRW3(grandeurs[cFrequence].nom);
   ecritSousSection(18,'OPTIONS');
   ecritIntegerRW3(ord(grapheFrequence.SuperposePage));{1}
   ecritIntegerRW3(ord(grapheFrequence.monde[mondeY].graduation));{2}
   ecritIntegerRW3(ord(false));{3}
   ecritFloatRW3(grapheFrequence.monde[mondeY].MinidB);{4}
   ecritIntegerRW3(Pages[pageCourante].nmes);{5}
   ecritIntegerRW3(round(PrecisionFFT*100));{6}
   ecritIntegerRW3(ord(enveloppeSpectre));{7}
   ecritIntegerRW3(ord(SonagrammeBtn.isPressed));{8}
   ecritIntegerRW3(ord(NbreHarmoniqueOptimise));{9}
   ecritIntegerRW3(ord(ordonneeFFTgr));{10}
   ecritIntegerRW3(ord(continuInclus));{11}
   ecritIntegerRW3(ord(TempsBtn.isPressed));{12}
   ecritFloatRW3(SplitterTemps.position.y);{13}
   ecritIntegerRW3(DecadeDB);{14}
   ecritIntegerRW3(NbreHarmoniqueAff);{15}
   ecritFloatRW3(pasTempsSonagramme);{16}
   ecritIntegerRW3(PasSonCalcul);{17}
   ecritFloatRW3(FreqMaxSonagramme);{18}
end;

procedure TFGrapheFFT.EditBidonKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
var xi : single;

Procedure TraceMarque;
var Dessin : TdessinText;
    xx,yy : double;
    ystr : string;
begin
    grapheFrequence.mondeRT(grapheFrequence.curseurOsc[1].Pc,mondeY,xx,yy);
    Dessin := TdessinText.createText(grapheFrequence);
    with Dessin do begin
          font.size := 16;
          color := claBlue;
          horzTextAlign := TTextAlign.Center;
          vertTextAlign := TTextAlign.Trailing;
          if grapheFrequence.monde[mondeY].graduation=gdB
             then Ystr := floatToStrF(20*log10(yy),ffGeneral,3,0)+' dB'
             else Ystr := grapheFrequence.courbes.items[courbeCourante].varY.formatValeurEtUnite(yy);
          text := grandeurs[cFrequence].formatValeurEtUnite(xx);
          width := PaintBoxFrequence.canvas.textWidth(text);
          height := PaintBoxFrequence.canvas.textHeight(text);
          affecteXY(grapheFrequence.windowX(xx)-width/2,
                    grapheFrequence.windowY(yy,mondeY)-3*height/2);
    end;
    grapheFrequence.dessinTexts.add(Dessin);
end; // TraceMarque

var existe : boolean;
    i : integer;
begin
if (keyChar=' ') and (grapheFRequence.curseur=curReticule) then
    with grapheFrequence do begin
        xi := curseurOsc[1].Pc.x;
        existe := false;
        for i := pred(grapheFrequence.dessinTexts.count) downto 0 do begin
            existe := (dessinTexts[i].position.X=Xi);
            if existe then begin
               dessinTexts.Delete(i);
               break;
            end;
        end;
        if not existe then traceMarque;
        PaintBoxFrequence.repaint;
    end;
    keyChar := #0;
    key := 0;
end;

procedure TFGrapheFFT.Enregistrer1Click(Sender: TObject);
var abitmap : Tbitmap;
    nomFichier : string;
begin
    if saveDialog.Execute then begin
       aBitmap := ZoneClipBoard.MakeScreenshot;
       nomFichier := SaveDialog.fileName;
       nomFichier := changeFileExt(nomFichier,'.png');
       ABitmap.saveToFile(nomFichier);
    end;
end;

procedure TFGrapheFFT.TexteItemClick(Sender: TObject);
begin
      grapheFrequence.DessinTextCourant := TdessinText.createText(grapheFrequence);
      grapheFrequence.DessinTextCourant.color := couleurTexte;
      setCurseurF(curTexte);
end;  // CurseurTexteClick

procedure TFGrapheFFT.SaveGraphItemClick(Sender: TObject);
var abitmap : Tbitmap;
    nomFichier : string;
begin
   if saveDialog.Execute then begin
       aBitmap := ZoneClipBoard.MakeScreenshot;
       nomFichier := SaveDialog.fileName;
       nomFichier := changeFileExt(nomFichier,'.png');
       abitmap.saveToFile(nomFichier)
   end;
end;

Procedure TFgrapheFFT.litConfig;
var i,imax,zint : integer;
    lignesLues : boolean;
begin
  while (Length(LigneWin)>0) and (ligneWin[1]=symbReg2) do begin
      imax := NbreLigneWin(ligneWin);
      lignesLues := false;
      if pos('Y',ligneWin)<>0 then for i := 1 to imax do begin
             litLigneWinU;
             if listeY.count<maxOrdonnee then listeY.add(ligneWin);
             lignesLues := true;
      end;
      if pos('OPTIONS',ligneWin)<>0 then begin
         grapheFrequence.SuperposePage := litBooleanRW3;    //1
         grapheTemps.SuperposePage := grapheFrequence.SuperposePage;
         zint := litIntegerRW3; //2
         grapheFrequence.monde[mondeY].graduation := Tgraduation(zint);
         litBooleanRW3; //3
         grapheFrequence.monde[mondeY].MinidB := litFloatRW3; //4
         if imax>=5 then litLigneWin;
         if imax>=6 then begin
            PrecisionFFT := litIntegerRW3;
            precisionFFT := precisionFFT/100;
         end;
         if imax>=7 then enveloppeSpectre := litBooleanRW3;
         if imax>=8 then SonagrammeBtn.isPressed := litBooleanRW3;
         if imax>=9 then NbreHarmoniqueOptimise := litBooleanRW3;
         if imax>=10 then begin
            zint := litIntegerRW3;
            if (zint >= ord(low(TordonneeFFT))) and (zint <= ord(high(TordonneeFFT))) then
              ordonneeFFTgr := TordonneeFFT(zint);
         end;
         if imax>=11 then continuInclus := litBooleanRW3;
         if imax>=12 then TempsBtn.isPressed := litBooleanRW3;
         if imax>=13 then begin
            zint := litIntegerRW3;
            PaintBoxTemps.height := zint;
         end;
         if imax>=14 then decadeDB := litIntegerRW3;
         if imax>=15 then NbreHarmoniqueAff := litIntegerRW3;
         if imax>=16 then litLigneWin;
         if imax>=17 then litLigneWin;
         if imax>=18 then FreqMaxSonagramme := litFloatRW3;
         for i := 19 to imax do litLigneWin;
         lignesLues := true;
      end;
      if pos('FENETRE',ligneWin)<>0 then begin
          for i := 1 to imax do zint := litIntegerRW3;
          lignesLues := true;
      end;
      if not(lignesLues) and (pos('F',ligneWin)<>0) then begin
             litLigneWin;
             grandeurs[cFrequence].nom := ligneWin;
             lignesLues := true;
      end;
      if not(lignesLues) and (pos('MEMO',ligneWin)<>0) then
         for i := 1 to imax do begin
             litLigneWin;
             lignesLues := true;
         end;
      if not lignesLues then for i := 1 to imax do litLigneWin;
      litLigneWin
   end;
end; // litConfig

Procedure TFgrapheFFT.litConfigXML;

procedure LoadXMLInReg(ANode: IXMLNode);

procedure Suite;
var i: Integer;
begin
if ANode.HasChildNodes then
   for I := 0 to ANode.ChildNodes.Count - 1 do
       LoadXMLInReg(ANode.ChildNodes.Nodes[I]);
end;

var zint : integer;
    Adessin : TdessinText;
begin
      if ANode.NodeName='Y' then begin
         listeY.Delimiter := ' ';
         listeY.DelimitedText := ANode.Text;
         exit;
      end;
      if ANode.NodeName='SuperPage' then begin
         grapheFrequence.SuperposePage := GetBoolXML(ANode);
         grapheTemps.SuperposePage := grapheFrequence.SuperposePage;
         exit;
      end;
      if ANode.NodeName='Graduation' then begin
         zint := GetIntegerXML(ANode);
         grapheFrequence.monde[mondeY].graduation := Tgraduation(zInt);
         exit;
      end;
      if ANode.NodeName='MinidB' then begin
         grapheFrequence.monde[mondeY].MinidB := getFloatXML(ANode);
         exit
      end;
      if ANode.NodeName='PrecisionFFT' then begin
          PrecisionFFT := getFloatXML(ANode);
          exit
      end;
      if ANode.NodeName='EnveloppeSpectre' then begin
          enveloppeSpectre := getBoolXML(ANode);
          exit
      end;
      if ANode.NodeName='SonagrammeBtn' then begin
          SonagrammeBtn.isPressed := getBoolXML(ANode);
          exit
      end;
      if ANode.NodeName='NbreHarmOpt' then begin
            NbreHarmoniqueOptimise := getBoolXML(ANode);
            exit
      end;
      if ANode.NodeName='TypeOrdonnee' then begin
            zint := getIntegerXML(ANode);
            if (zint >= ord(low(TordonneeFFT))) and (zint <= ord(high(TordonneeFFT))) then
              ordonneeFFTgr := TordonneeFFT(zint);
            exit;
      end;
      if ANode.NodeName='ContinuInclus' then begin
          continuInclus := getBoolXML(ANode);
          exit;
      end;
      if ANode.NodeName='TempsBtn' then begin
            TempsBtn.isPressed := getBoolXML(ANode);
            exit
      end;
     if ANode.NodeName='azerty' then begin
           PaintBoxTemps.height := getIntegerXML(ANode);
           exit
     end;
     if ANode.NodeName='DecadedB' then begin
            DecadeDB := getIntegerXML(ANode);
            exit
     end;
     if ANode.NodeName='NbreHarmAff' then begin
           NbreHarmoniqueAff := getIntegerXML(ANode);
           exit;
     end;
     if ANode.NodeName='Fenetre' then begin
           Fenetre := TFenetre(getIntegerXML(ANode));
           exit;
     end;
     (*
     if ANode.NodeName='PasTempsSonagramme' then begin
         pasTempsSonagramme := GetFloat;
         exit
     end;
     if ANode.NodeName='PasSonCalcul' then begin
          pasSonCalcul := getInteger;
          if pasSonCalcul<1 then pasSonCalcul := 1;
          if pasSonCalcul>3 then pasSonCalcul := 3;
          exit
     end;
     *) // Constantes non affectables
     if ANode.NodeName='FreqMaxSonagramme' then begin
           FreqMaxSonagramme := getFloatXML(ANode);
           exit;
     end;
     if ANode.NodeName='X' then begin
          grandeurs[cFrequence].nom := ANode.text;
          exit;
     end;
     if ANode.NodeName='DESSIN' then begin
         Adessin := TdessinText.create(paintBoxFrequence);
         Adessin.aGraphe := grapheFrequence;
         Adessin.loadXML(ANode);
         grapheFrequence.dessinTexts.add(Adessin);
         exit;
     end;
end;

var i : integer;
begin
    if ANode.HasChildNodes then
       for I := 0 to ANode.ChildNodes.Count - 1 do
          LoadXMLInReg(ANode.ChildNodes.Nodes[I]);
end; // litConfigXML

procedure TFGrapheFFT.OptionsFourierItemClick(Sender: TObject);

Procedure SetCoordonneeFFT;
var i : integer;
    OldListeY : Tstrings;
    ModifListe : boolean;
begin with GrapheFrequence do begin
           oldListeY := TstringList.Create;
           oldListeY.assign(listeY);
           ListeY.Clear;
           with OptionsFFTDlg.ListeVariableBox do begin
                for i := 0 to pred(items.count) do
                    if ListItems[i].isChecked and (listeY.count<maxOrdonnee)
                       then ListeY.Add(items[i]);
                if listeY.count=0 then ListeY.add(Items[0]);
           end;
           ModifListe := oldListeY.count<>listeY.count;
           if not modifListe then for i := 0 to pred(listeY.count)
              do if listeY[i]<>oldListeY[i] then modifListe := true;
           if modifListe then
              include(modif,gmXY);
           oldListeY.Free;
end end;

var i : integer;
begin
    if OptionsFFTDlg=nil then
       application.createForm(TOptionsFFTdlg,OptionsFFTDlg);
     OptionsFFTDlg.DecibelCB.IsChecked  := not SonagrammeBtn.isPressed and
                   (grapheFrequence.monde[mondeY].graduation=gdB);
     OptionsFFTDlg.EnveloppeCB.IsChecked := enveloppeSpectre;
     with OptionsFFTDlg.ListeVariableBox do begin
               Items.Clear;
               for i := 1 to pred(NbreGrandeurs) do with grandeurs[i] do
                  if (genreG=variable) and
                     (fonct.genreC<>g_texte) then Items.add(nom);
               for i := 0 to pred(items.count) do
                   ListItems[i].isChecked := listeY.indexOf(items[i])>=0;
     end;
     OptionsFFTDlg.init;
     CentreForm(OptionsFFTDlg);
     if OptionsFFTDlg.showModal=mrOK then begin
          EnveloppeSpectre := OptionsFFTDlg.enveloppeCB.isChecked;
          recalculFourierE;
          GrapheFrequence.modif := [gmEchelle];
          if OptionsFFTDlg.DecibelCB.IsChecked and not SonagrammeBtn.isPressed
                then begin
                   grapheFrequence.monde[mondeY].graduation := gdB;
                   DecadeDB := round(OptionsFFTDlg.DecadeSE.value);
                end
                else grapheFrequence.monde[mondeY].graduation := gLin;
          SetCoordonneeFFT;
          GrapheTemps.modif := GrapheFrequence.modif;
          MajGrapheFFT;
     end;
end;

procedure TFGrapheFFT.CouleursItemClick(Sender: TObject);
begin
     OptionCouleurDlg := TOptionCouleurDlg.create(self);
     OptionCouleurDlg.Graphe := GrapheFrequence;
     CentreForm(OptionCouleurDlg);
     if optionCouleurDlg.ShowModal=mrOK then paintBoxFrequence.repaint;
     OptionCouleurDlg.free;
end;

procedure TFGrapheFFT.TempsBtnClick(Sender: TObject);
begin
    ResetTemps
end;

procedure TFGrapheFFT.TempsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: single);
var xdebut,xfin : double;
begin
   if Button=TMouseButton.mbRight then exit;
   grapheTemps.curseur := curSelect;
   xdebut := grapheTemps.selection.position.x;
   xfin := grapheTemps.selection.position.x+grapheTemps.selection.width;
   if sender=grapheTemps.selection then x := x+xdebut;
   if abs(x-xfin)<margeDebutFin then grapheTemps.curseur := curFin;
   if abs(x-xdebut)<margeDebutFin then grapheTemps.curseur := curDebut;
   if (grapheTemps.curseur=curSelect) and
      (x>xdebut) and
      (x<xfin) then grapheTemps.curseur := curDeplace;
   case grapheTemps.curseur of
       curSelect : PaintBoxTemps.Cursor := crDefault;
       curDeplace : PaintBoxTemps.Cursor := crHandPoint;
       else PaintBoxTemps.Cursor := crHsplit;
   end;
   Xdeplace := X;
end;

procedure TFGrapheFFT.TempsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: single);
begin
   grapheTemps.curseur := curSelect;
   pages[pageCourante].recalculFourierP;
   GrapheFrequence.modif := [gmEchelle];
   MajGrapheFFT;
end;

procedure TFGrapheFFT.TempsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: single);

procedure ChercheDebutFin;
var x,y : double;
    ifin,idebut : integer;
    aPoint : TpointF;
begin with grapheTemps,PaintBoxTemps.Canvas,pages[pageCourante] do begin
       Apoint := selection.position.point;
       mondeXY(Apoint,mondeY,x,y);
       idebut := 0;
       while (idebut<pred(nmes)) and (valeurVar[indexTri,idebut]<x) do inc(idebut);
       Apoint.Offset(selection.width,0);
       mondeXY(Apoint,mondeY,x,y);
       ifin := pred(nmes);
       while (ifin>idebut) and (valeurVar[indexTri,ifin]>x) do dec(ifin);
       debutFFT := iDebut;
       finFFT := iFin;
end end;

var xdebut,xfin : single;
begin
     xdebut := grapheTemps.selection.position.x;
     xfin := grapheTemps.selection.position.x+grapheTemps.selection.width;
     if sender=grapheTemps.selection then x := x+xdebut;
     case grapheTemps.curseur of
        curSelect : begin
           if (abs(X-xfin)<margeDebutFin) or (abs(X-xdebut)<margeDebutFin)
             then PaintBoxTemps.cursor := crHsplit
             else if (x>xDebut) and (x<xFin)
                  then PaintBoxTemps.cursor := crHandPoint
                  else PaintBoxTemps.cursor := crDefault;
        end;
        curDebut : begin
           grapheTemps.selection.position.x := x;
           grapheTemps.selection.width := xfin-x;
        end;
        curFin : grapheTemps.selection.width := (x-xDebut);
        curDeplace : grapheTemps.selection.position.x := x;
     end;
     if grapheTemps.curseur<>curSelect then ChercheDebutFin;
end; // TempsMouseMove

procedure TFgrapheFFT.AffecteDebutFin;
begin with pages[pageCourante] do begin
    recalculFourierP;
    GrapheFrequence.modif := [gmEchelle];
    MajRaiesAfaire := true;
    grapheTemps.modif := [gmEchelle];
    MajGrapheFFT;
end end;

procedure TFgrapheFFT.TraceDebutFin;
var FinIntMax,FinTemps,DebutTemps : TpointF;
    finLoc : integer;
begin with grapheTemps,pages[pageCourante] do begin
    //  selection.stroke.Color := claGray;
     // selection.stroke.Thickness := 3;
      if finFFT<(nmes-2)
         then finLoc := finFFT+1
         else finLoc := pred(nmes);
      windowXY(valeurVar[indexTri,finLoc],valeurVar[indexFonction,finLoc],mondeY,FinTemps);
      windowXY(valeurVar[indexTri,debutFFT],valeurVar[indexFonction,debutFFT],mondeY,DebutTemps);
      selection.Position.X := DebutTemps.X;
      selection.Position.Y := 2;
      selection.Width := FinTemps.x-DebutTemps.X;
      selection.Height := paintBoxTemps.Height-4;
      windowXY(valeurVar[indexTri,pred(nmes)],0,mondeY,finIntMax);
      if selection.Position.x<LimiteCourbe.left
          then selection.position.x := LimiteCourbe.left;
      if selection.width+selection.Position.x>finIntMax.x
          then selection.width := finIntMax.x-selection.Position.x;
      if (selection.width)<(3*LimiteCourbe.right/4) then begin
      end;
end end;

procedure TFGrapheFFT.PasSonAffEditExit(Sender: TObject);
begin
    if SonagrammeBtn.isPressed then begin
       calculSonagramme;
       PaintBoxFrequence.repaint;
    end;
end;

procedure TFGrapheFFT.pasSonCalculEditExit(Sender: TObject);
begin
    if SonagrammeBtn.isPressed then begin
       calculSonagramme;
       PaintBoxFrequence.repaint;
    end;
end;

procedure TFGrapheFFT.PeriodeBtnClick(Sender: TObject);
begin with pages[pageCourante] do begin
    cherchePeriode(valeurVar[indexFonction],nmes,debutFFT,finFFT);
    if PaintBoxTemps.isVisible then traceDebutFin;
    avecPeriode := true;
    MajRaiesAfaire := true;
    AffecteDebutFin;
end end;

procedure TFGrapheFFT.PaintBoxFrequenceDblClick(Sender: TObject);
begin
    reelClick := true
end;

procedure TFGrapheFFT.ToutBtnClick(Sender: TObject);
begin with pages[pageCourante] do begin
    debutFFT := 0;
    finFFT := pred(nmes);
    if PaintBoxTemps.isVisible then traceDebutFin;
    AffecteDebutFin;
    avecPeriode := false;
    MajRaiesAfaire := true;
end end;

procedure TFGrapheFFT.MajGrapheFFT;
begin
      if pageCourante=0 then exit;
      PaintBoxFrequence.repaint;
      if tempsBtn.isPressed then PaintBoxTemps.repaint;
end;

procedure TFGrapheFFT.SonagrammeBtnClick(Sender: TObject);
begin
     include(grapheFrequence.modif,gmXY);
     if pageCourante>0 then setCoordonnee
end;

procedure TFGrapheFFT.FrequenceReduiteCBClick(Sender: TObject);
begin
     include(GrapheFrequence.Modif,gmXY);
     MajGrapheFFT
end;

procedure TFGrapheFFT.HelpBtnClick(Sender: TObject);
begin
    ShowAide(HELP_FenetreFourier);
end;

procedure TFGrapheFFT.ImprimeBtnClick(Sender: TObject);
var bas : single;
begin
    if OKreg(OkImprGr,0) then begin
        try
          BeginPrintGr(bas);
          grapheFrequence.versImprimante(bas);
          Printer.EndDoc;
        except
        end;
     end;
end;

procedure TFGrapheFFT.FenetreBtnClick(Sender: TObject);
var P : TPointF;
begin
     P := TpointF.Create(fenetreBtn.position.x,2*fenetreBtn.height);
     P := FRegressiMain.ClientToScreen(P);
     FenetreMenu.popup(P.x,P.y);
end;

procedure TFgrapheFFT.ImprimerGraphe(var bas : single);
begin
       grapheFrequence.versImprimante(bas);
end;

procedure TFGrapheFFT.LigneItemClick(Sender: TObject);
begin
     grapheFrequence.DessinLineCourant := TdessinLine.createLine(grapheFrequence);
     grapheFrequence.DessinLineCourant.stroke.color := couleurLigne;
     grapheFrequence.DessinLineCourant.SetMoveDown(FrequenceMouseMove,nil,nil);
     setCurseurF(curLigne);
end;   // CurseurLigneClick

procedure TFGrapheFFT.SplitterTempsMouseLeave(Sender: TObject);
begin
    PaintBoxTemps.repaint
end;

procedure TFGrapheFFT.SplitterTempsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  PaintBoxTemps.repaint
end;

procedure TFGrapheFFT.DebutFFTspinDownClick(Sender: TObject);
begin
     if pages[pageCourante].debutFFT>0 then
        dec(pages[pageCourante].debutFFT);
     affecteDebutFin;
end;

procedure TFGrapheFFT.DebutFFTspinUpClick(Sender: TObject);
begin
     if pages[pageCourante].debutFFT<(pages[pageCourante].finFFT-minPeriodeFFT) then
        inc(pages[pageCourante].debutFFT);
     affecteDebutFin;
end;

procedure TFGrapheFFT.FinFFTspinUpClick(Sender: TObject);
begin
     if pages[pageCourante].finFFT<pred(pages[pageCourante].nmes) then
        inc(pages[pageCourante].finFFT);
     affecteDebutFin;
end;

procedure TFGrapheFFT.FinFFTspinDownClick(Sender: TObject);
begin
     if pages[pageCourante].finFFT>(pages[pageCourante].debutFFT+minPeriodeFFT) then
        dec(pages[pageCourante].finFFT);
     affecteDebutFin;
end;

procedure TFGrapheFFT.CopierItemClick(Sender: TObject);
begin
    grapheFrequence.VersPressePapier;
end;

procedure TFGrapheFFT.SourisBtnClick(Sender: TObject);
var P : TPointF;
begin
     P := TpointF.Create(0,2*sourisBtn.height);
     P := FRegressiMain.ClientToScreen(P);
     sourisMenu.popup(P.x,P.y);
end;

procedure TFGrapheFFT.SelectionTempsChange(Sender: TObject);
var point1,point2 : TpointF;
    xf,xd,yy : double;
begin
      PaintBoxTemps.Cursor := crDefault;
      with GrapheTemps do begin
          case curseur of
            curDebut : begin
               if (selection.position.x<grapheTemps.limiteCourbe.left) then
                   selection.position.x := grapheTemps.limiteCourbe.left;
            end;
            curFin : begin
               if (selection.width>grapheTemps.limiteCourbe.right-selection.position.x) then
                   selection.width := grapheTemps.limiteCourbe.right-selection.position.x;
            end;
            curDeplace : ;
          end;
          curseur := curSelect;
          point1 := tpointF.Create(selection.Position.x,0);
          mondeXY(point1,mondeY,xd,yy);
          point2 := tpointF.Create(selection.Position.x+selection.width,0);
          mondeXY(point2,mondeY,xf,yy);
      end;
      with pages[pageCourante] do begin
          periodeFFT := xf-xd;
          DebutFFT := 0;
          while (debutFFT<pred(nmes)) and
                (valeurVar[indexTri,debutFFT]<xd) do inc(debutFFT);
// point(debutFFT) >= debut
          xf := valeurVar[indexTri,debutFFT] + periodeFFT;
          FinFFT := pred(nmes);
          while (finFFT>debutFFT) and
                (valeurVar[indexTri,finFFT]>=xf) do dec(finFFT);
// point(finFFT) < fin
          if finFFT<(debutFFT+minPeriodeFFT) then
             if debutFFT<nmes div 2
                then begin
                   finFFT := debutFFT+minPeriodeFFT;
                   grapheTemps.windowXY(valeurVar[indexTri,debutFFT],0,mondeY,point2);
                end
                else begin
                   debutFFT := finFFT-minPeriodeFFT;
                   grapheTemps.windowXY(valeurVar[indexTri,debutFFT],0,mondeY,point1);
                end;
          if finFFT > debutFFT then
            periodeFFT := ((valeurVar[indexTri,finFFT] - valeurVar[indexTri,debutFFT]) / (finFFT - debutFFT)) * (finFFT - debutFFT + 1);
      end;
      AffecteDebutFin;
end;

procedure TFGrapheFFT.ReticuleBtnClick(Sender: TObject);
begin
      setCurseurF(curReticule);
      PaintBoxFrequence.repaint;
end;

procedure TFGrapheFFT.StandardItemClick(Sender: TObject);
begin
     setCurseurF(curSelect);
     PaintBoxFrequence.repaint;
end;

procedure TFGrapheFFT.ZoomDebutFinItemClick(Sender: TObject);
begin
      paintBoxFrequence.repaint
end;

procedure TFGrapheFFT.NbreHarmAffSpinChange(Sender: TObject);
begin
   NbreHarmoniqueAff := round(NbreHarmAffSpin.value);
   MajRaiesAfaire := true;
   paintBoxFrequence.repaint;
end;

procedure TFGrapheFFT.changeEchelleSon(xnew, xold: single);
begin with grapheFrequence do begin
    xnew := limiteCourbe.bottom - xnew;
    if xnew < 16 then exit;
    xold := limiteCourbe.bottom - xold;
    with monde[mondeY] do begin
       A := A * xnew / xold;
       Maxi := Mini + (limiteCourbe.top - limiteCourbe.bottom) / A;
       FreqMaxSonagramme := Maxi;
       if FreqMaxSonagramme>pasFreqSonagramme*NbrePointsSonagramme
          then freqMaxSonagramme := pasFreqSonagramme*NbrePointsSonagramme;
    end;
    PaintBoxFrequence.repaint;
end end;

procedure TFGrapheFFT.CalculSonagramme;
var freqEch : double;
begin with pages[pageCourante] do begin
     FreqEch := pred(Nmes)/(valeurVar[indexTri][pred(Nmes)]-valeurVar[indexTri][0]);
     Sonagramme(Nmes,valeurVar[indexSonagramme],FreqEch);
     PeriodeFFT := valeurVar[indexTri,pred(nmes)];
     nbreFFT := NbrePointsSonagramme;
end end;

procedure TFgrapheFFT.ConvertitXY(sender : TObject;var x,y : single);
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

end.

