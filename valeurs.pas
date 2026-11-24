unit valeurs;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
  System.Classes,
  System.Math,
  System.Rtti,
  System.Generics.Collections,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.ExtCtrls,
  FMX.StdCtrls,
  FMX.ListBox,
  FMX.Printer,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Graphics,
  FMX.TreeView,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Controls.Presentation,
  FMX.EditBox,
  FMX.SpinBox,

  aideKey,
  images,
  compile,
  constreg,
  graphker,
  maths,
  modif,
  regUtil, 
  
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


const
     ReperageConstGlb = '-->';
     largeurMinGrapheValeur = 50;

type
  TgrapheValeur = class(TgrapheReg)
  private
  public
      constructor Create(apaintBox : TPaintBox);
      Procedure SetCoordonnee;
      procedure PaintBoxPaint;
      procedure PaintBoxMouseMove(sender : Tobject;Shift: TShiftState;
         X,Y: single);
      procedure PaintBoxMouseDown(sender : Tobject;Button: TMouseButton;
         Shift: TShiftState; X, Y: single);
      procedure PaintBoxMouseUp(sender : Tobject;Button: TMouseButton;
         Shift: TShiftState; X, Y: single);
      procedure SetPenBrush(c : Tcurseur);
      destructor Destroy; override;
  end;

  TFValeurs = class(TForm)
    Feuillets: TTabControl;
    PopupMenuExpr: TPopupMenu;
    CompileItem: TMenuItem;
    CreerGrandeurItem: TMenuItem;
    CopierItem: TMenuItem;
    ParamSheet: TTabItem;
    VariabSheet: TTabItem;
    ExpSheet: TTabItem;
    CollerItem: TMenuItem;
    RazItem: TMenuItem;
    Phase: TMenuItem;
    PopupMenuGrid: TPopupMenu;
    CreerGrandeurGrid: TMenuItem;
    DelGrandeurItem: TMenuItem;
    TrierItem: TMenuItem;
    DelSelectItem: TMenuItem;
    CopierTableauItem: TMenuItem;
    PhaseItem: TMenuItem;
    Memo: TMemo;
    Panel1: TPanel;
    Expander1: TExpander;
    ListGrandeurs: TListBox;
    Expander3: TExpander;
    TreeView1: TTreeView;
    TreeViewItem1: TTreeViewItem;
    TreeViewItem2: TTreeViewItem;
    TreeViewItem3: TTreeViewItem;
    TreeViewItem4: TTreeViewItem;
    TreeViewItem5: TTreeViewItem;
    TreeViewItem6: TTreeViewItem;
    TreeViewItem7: TTreeViewItem;
    TreeViewItem8: TTreeViewItem;
    TreeViewItem9: TTreeViewItem;
    TreeViewItem10: TTreeViewItem;
    TreeViewItem11: TTreeViewItem;
    TreeViewItem12: TTreeViewItem;
    TreeViewItem13: TTreeViewItem;
    GrecExpander: TExpander;
    MenuItem1: TMenuItem;
    ImprimeMenu: TMenuItem;
    ImprimeGridMenu: TMenuItem;
    MajBtn: TButton;
    RazGridItem: TMenuItem;
    DeltaItem: TMenuItem;
    TreeViewItem14: TTreeViewItem;
    TreeViewItem15: TTreeViewItem;
    TreeViewItem16: TTreeViewItem;
    TreeViewItem17: TTreeViewItem;
    TreeViewItem18: TTreeViewItem;
    TreeViewItem19: TTreeViewItem;
    TreeViewItem20: TTreeViewItem;
    TreeViewItem21: TTreeViewItem;
    TreeViewItem22: TTreeViewItem;
    TreeViewItem23: TTreeViewItem;
    TreeViewItem24: TTreeViewItem;
    TreeViewItem25: TTreeViewItem;
    TreeViewItem26: TTreeViewItem;
    TreeViewItem27: TTreeViewItem;
    TreeViewItem28: TTreeViewItem;
    TreeViewItem29: TTreeViewItem;
    TreeViewItem30: TTreeViewItem;
    TreeViewItem31: TTreeViewItem;
    TreeViewItem32: TTreeViewItem;
    TreeViewItem33: TTreeViewItem;
    TreeViewItem34: TTreeViewItem;
    TreeViewItem35: TTreeViewItem;
    TreeViewItem36: TTreeViewItem;
    TreeViewItem37: TTreeViewItem;
    TreeViewItem38: TTreeViewItem;
    ExpressionsToolBar: TToolBar;
    AddBtn: TButton;
    SyntaxeBtn: TButton;
    ImprimerBtn: TButton;
    ZoomAutoBtn: TButton;
    RadDegExpBtn: TButton;
    ToolBar1: TToolBar;
    Button1: TButton;
    TriVarBtn: TButton;
    PrintVarBtn: TButton;
    IncertVarBtn: TButton;
    RadDegTabBtn: TButton;
    SimulationGB: TGroupBox;
    Label1: TLabel;
    NombreXSB: TSpinBox;
    LogBox: TCheckBox;
    nomXedit: TEdit;
    UniteXedit: TEdit;
    MiniXEdit: TEdit;
    MaxiXedit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ToolBar2: TToolBar;
    AddParamBtn: TButton;
    Lang1: TLang;
    IncertParamBtn: TButton;
    GridVariab: TTMSFNCGrid;
    GridParam: TTMSFNCGrid;
    GrecGrid: TTMSFNCGrid;
    SplitterExp1: TSplitter;
    SplitterExp2: TSplitter;
    Splitter1: TSplitter;
    GraphePanel: TPanel;
    GrapheToolBar: TToolBar;
    CoordonneesBtn: TButton;
    AutoBtn: TButton;
    ZoomBtn: TButton;
    ZoomArrBtn: TButton;
    PaintBox1: TPaintBox;
    Label6: TLabel;
    VarHelpBtn: TButton;
    parHelpBtn: TButton;
    procedure DeleteBtnClick(Sender: TObject);
    procedure CompileItemClick(Sender: TObject);
    procedure FeuilletsClick(Sender: TObject);
    procedure TriBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MajBtnClick(Sender: TObject);
    procedure MemoChange(Sender: TObject);
    procedure DelSelectItemClick(Sender: TObject);
    procedure AddBtnClick(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure pageNewItemClick(Sender: TObject);
    procedure FileAddItemClick(Sender: TObject);
    procedure ImprimeBtnClick(Sender: TObject);
    procedure DeltaBtnClick(Sender: TObject);
    procedure FeuilletsChanging(Sender: TObject; var AllowChange: Boolean);
    procedure FeuilletsChange(Sender: TObject);
    procedure PhaseItemClick(Sender: TObject);
    procedure CollerItemClick(Sender: TObject);
    procedure FonctionBtnClick(Sender: TObject);
    procedure RazBtnClick(Sender: TObject);
    procedure CopierItemClick(Sender: TObject);
    procedure CopierTableauItemClick(Sender: TObject);
    procedure SyntaxeBtnClick(Sender: TObject);
    procedure GridParamCellEditSetData(Sender: TObject; ACol, ARow: Integer;
      CellEditor: TControl; var CellString: string);
    procedure GridVariabFixedCellButtonClick(Sender: TObject; ACol,
      ARow: Integer);
    procedure GridParamFixedCellButtonClick(Sender: TObject; ACol,
      ARow: Integer);
    procedure FonctionBtnMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure MemoKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormDestroy(Sender: TObject);
    procedure MemoKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure GridVariabGetCellReadOnly(Sender: TObject; ACol, ARow: Integer;
      var AReadOnly: Boolean);
    procedure IncertVarBtnClick(Sender: TObject);
    procedure NombreXSBChange(Sender: TObject);
    function  VerifMinMax(Sender: TObject) : boolean;
    procedure NomXeditExit(Sender: TObject);
    procedure UniteXeditExit(Sender: TObject);
    procedure MinixEditExit(Sender: TObject);
    procedure MaxiXeditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure MaxiXeditChange(Sender: TObject);
    procedure nomXeditChange(Sender: TObject);
    procedure NombreXSBExit(Sender: TObject);
    procedure UniteXeditChange(Sender: TObject);
    procedure LogBoxChange(Sender: TObject);
    procedure RadDegTabBtnClick(Sender: TObject);
    procedure ListGrandeursChange(Sender: TObject);
    procedure GridVariabGetCellIsFixed(Sender: TObject; ACol, ARow: Integer;
      var ACellFixed: Boolean);
    procedure GridParamGetCellIsFixed(Sender: TObject; ACol, ARow: Integer;
      var ACellFixed: Boolean);
    procedure GridVariabGetCellEditorProperties(Sender: TObject; ACol,
      ARow: Integer; CellEditor: TControl);
    procedure GridVariabExit(Sender: TObject);
    procedure GridParamExit(Sender: TObject);
    procedure IncertParamBtnClick(Sender: TObject);
    procedure TMSFNCGrid1GetCellClass(Sender: TObject; ACol, ARow: Integer;
      var CellClassType: TTMSFNCGridCellClass);
    procedure TMSFNCGrid1GetCellEditorType(Sender: TObject; ACol, ARow: Integer;
      var CellEditorType: TTMSFNCGridEditorType);
    procedure TMSFNCGrid3GetCellClass(Sender: TObject; ACol, ARow: Integer;
      var CellClassType: TTMSFNCGridCellClass);
    procedure GridVariabCellEditSetData(Sender: TObject; ACol, ARow: Integer;
      CellEditor: TControl; var CellString: string);
    procedure GrecGridCellButtonClick(Sender: TObject; ACol, ARow: Integer;
      ACell: TTMSFNCGridCell);
    procedure GridParamCellEditGetData(Sender: TObject; ACol, ARow: Integer;
      CellEditor: TControl; var CellString: string);
    procedure GridParamGetCellData(Sender: TObject; ACol, ARow: Integer;
      var CellString: string);
    procedure GridVariabGetCellData(Sender: TObject; ACol, ARow: Integer;
      var CellString: string);
    procedure CoordonneesBtnClick(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Splitter1Paint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure AutoBtnClick(Sender: TObject);
    procedure ZoomBtnClick(Sender: TObject);
    procedure ZoomArrBtnClick(Sender: TObject);
    procedure VarHelpBtnClick(Sender: TObject);
    procedure parHelpBtnClick(Sender: TObject);
 private
     ColPermiseParam,ColPermiseVariab : TsetGrandeur;
     derniereColvariab : integer;
     ErreurCompile : boolean;
     aideFonction : TDictionary<String,String>;
     premierCR : boolean;
     MajSimulation : boolean;
     graphe : TgrapheValeur;
     Function FormatGridVariab(Acol,Arow : Integer) : string;
     Function FormatGridConst(Acol,Arow : Integer) : string;
     procedure MajValeurConstGlb(i,posDebutLigne : integer);
     procedure ajouteStrMemo(aString : string;offset : integer);
     function indexVariable(acol : integer) : integer;
     function indexConstante(acol : integer) : integer;
     Procedure CompileP;
     Procedure Remplit;
     Procedure ResetListeGrandeurs;
     procedure AppelCoordonnees;
  public
      prevenirPi : boolean;
      MesureCourante : integer;
      MajGridVariab : boolean;
      Procedure SupprimeGrandeurCalc(anom : string);
      procedure ChangeAngle(isDegre : boolean);
      procedure PassageEnRadian(force : boolean);
      Procedure TraceGridVariab;
      Procedure TraceGridParam;
      procedure Recalculer;
      procedure MajGraphe(typeMaj : integer);
  end;

var
  FValeurs: TFValeurs;

implementation

uses UniteKer, NewVar, varkeyb, coordphys,
     supprDlg, regmain, options, fft, optionsFiltrageU, AideU;

{$R *.FMX}

const
     TabParam = 0;
     TabVariab = 1;
     TabExpressions = 2;
     LettresGrecquesMin : array[0..23] of char = (
       alphaMin, betaMin, gammaMin, deltaMin, epsilonMin, zetaMin,
       etaMin, thetaMin, iotaMin, kappaMin, lambdaMin, muMin,
       nuMin, xiMin, omicronMin, piMin, rhoMin, sigmaMin,
       tauMin, upsilonMin, phiMin, chiMin, psiMin, omegaMin);
     LettresGrecquesMaj : array[0..23] of char = (
       alphaMaj, betaMaj, gammaMaj, deltaMaj, epsilonMaj, zetaMaj,
       etaMaj, thetaMaj, iotaMaj, kappaMaj, lambdaMaj, muMaj,
       nuMaj, xiMaj, omicronMaj, piMaj, rhoMaj, sigmaMaj,
       tauMaj, upsilonMaj, phiMaj, chiMaj, psiMaj, omegaMaj);

procedure TgrapheValeur.PaintBoxMouseMove(Sender: TObject;
     Shift: TShiftState; X,Y: single);
var deplacement : boolean;
begin // PaintBoxMouseMove
   if not grapheOK then exit;
   if ssRight in Shift then exit; // clic droit
   deplacement := ssLeft in Shift;
   if curseur=curZoomAv then if deplacement then begin
        selection.width := x-selection.Position.x;
        selection.height := y-selection.position.y;
   end;
end; // PaintBoxMouseMove

procedure TgrapheValeur.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: single);

procedure AfficheSelection;
begin
     selection.Position.x := x;
     selection.Position.y := y;
     selection.width := 0;
     selection.height := 0;
     selection.Visible := true;
     selection.BringToFront;
end;

begin // MouseDown
   if not grapheOK then exit;
   if curseur=curZoomAv
      then afficheSelection
      else selection.Visible := false;
end; // PaintBoxMouseDown

procedure TgrapheValeur.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: single);

Procedure affecteZoomAv;
begin
   if (selection.width=0) or
      (selection.Height=0) then exit;
   affecteZoomAvant(true);
   include(modif,gmEchelle);
end; // affecteZoomAvant

begin // MouseUp
  if (x<0) or (y<0) or not(grapheOK) then exit;
  if curseur=curZoomAv then begin
     affecteZoomAv;
     curseur := curSelect;
     selection.Visible := false;
  end;
  paintBox.repaint;
end; // MouseUp

constructor TgrapheValeur.Create(apaintBox : TPaintBox);
begin
  inherited create(aPaintBox);
  curseur := curSelect;
  Selection.SetMoveDown(PaintBoxMouseMove,PaintBoxMouseDown,PaintBoxMouseUp);
end; // TgrapheValeur.Create

procedure TgrapheValeur.SetCoordonnee;

Procedure AjouteVariab(m : TindiceMonde;i : indiceOrdonnee;page : codePage);
var courbeVariab : Tcourbe;
    iX,iY : integer;
    traceV : TsetTrace;
    ligneV : Tligne;

Procedure AddIncert(Acourbe : Tcourbe);
begin
      with pages[page] do begin
         Acourbe.IncertX := incertVar[iX];
         Acourbe.IncertY := incertVar[iY];
      end;
end;

begin with pages[page] do begin
      if m>=MaxMonde then exit;
      with Coordonnee[i] do begin
           iX := CodeX;
           iY := CodeY;
           exclude(trace,trSonagramme);
           TraceV := trace;
           LigneV := ligne;
           if (LigneV=LiModele) and (NbreModele=0) then LigneV := LiDroite;
      end;
      courbeVariab := AjouteCourbe(valeurVar[iX],valeurVar[iY],m,nmes,
                                   grandeurs[iX],grandeurs[iY],page);
      with coordonnee[i] do courbeVariab.setStyle(couleur,styleT,motif);
      AddIncert(courbeVariab);
      if traceV=[] then TraceV := [trPoint];
      courbeVariab.Trace := TraceV;
      if TrLigne in TraceV then case LigneV of
        LiSpline,LiSinc : if (pages[page].nmes<maxVecteurDefaut) then begin
              courbeVariab.courbeExp := true;
              courbeVariab.optionLigne := ligneV;
        end;
      end; // case ligneV
      if TraceV<>[] then
        courbeVariab.trace := courbeVariab.trace+traceV;
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
          iMondeC := mondeY;
          monde[mondeX].axe := grandeurs[codeX];
          monde[mondeY].axe := grandeurs[codeY];
        end;
        nbreOrdonnee := 1;
        if (nbreVariabExp>2) and (grandeurs[indexVariab[2]].fonct.genreC=g_experimentale) then begin
           with coordonnee[2] do begin
              codeX := 0; codeY := indexvariab[2];
              nomX := grandeurs[codeX].nom;
              nomY := grandeurs[codeY].nom;
              if grandeurs[1].uniteEgale(grandeurs[codeY])
                 then iMondeC := mondeY
                 else iMondeC := mondeDroit;
              monde[mondeX].axe := grandeurs[codeX];
              monde[iMondeC].axe := grandeurs[codeY];
           end;
           nbreOrdonnee := 2;
        end;
    end;
end;

var
  i,n : integer;
  p : codePage;
  Lmonde : TindiceMonde;
begin // SetCoordonnee
   VerifCoordonnee;
   Lmonde := mondeY;
   for p := 1 to NbrePages do Pages[p].tri;
   for i := 1 to maxOrdonnee do with Coordonnee[i] do
     if (codeX<>grandeurInconnue) and (codeY<>grandeurInconnue) then begin
        if superposePage and
           (NbrePages>1) and
           (OgAnalyseurLogique in OptionGraphe) then Lmonde := mondeY;
        if OgPolaire in OptionGraphe then begin
            iMondeC := mondeY;
            if (i=1) then if codeY=grandeurInconnue
                  then monde[mondeY].Axe := nil
                  else monde[iMondeC].Axe := grandeurs[codeY];
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
                          AjouteVariab(Lmonde,i,p);
                          inc(Lmonde);
                      end
                      else AjouteVariab(iMondeC,i,p)
           end
           else AjouteVariab(iMondeC,i,pageCourante);
     end;
   modif := [gmEchelle];
   grapheOK := true;
end; // SetCoordonnee

procedure TgrapheValeur.SetPenBrush(c : Tcurseur);
begin
     curseur := c;
     if curseur=curSelect then paintBox.cursor := crCross;
     selection.visible := curseur=curZoomAv;
end; // SetPenBrush

procedure TgrapheValeur.PaintBoxPaint;

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

Procedure FondBlanc;
begin with paintBox.canvas do begin
      Fill.kind := TBrushKind.Solid;
      Fill.Color := claWhite;
      stroke.Color := claBlack;
      stroke.kind := TBrushKind.Solid;
      with limiteFenetre do
           FillRect(TrectF.Create(0,0,Width,Height),0,0,[],1);
      Fill.kind := TBrushKind.None;
end  end;

Procedure Encadre;
begin with paintBox.canvas do begin
      stroke.Color := claBlack;
      stroke.kind := TBrushKind.Solid;
      with limiteFenetre do
           DrawRect(TrectF.Create(0,0,Width,Height),0,0,[],1);
end  end;

begin // PaintBoxPaint
        limiteFenetre := TRectF.create(0,0,paintBox.width,paintBox.height);
        if paintBox.Width<largeurMinGrapheValeur then begin
           FondBlanc;
           exit;
        end;
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
        if grapheOK then chercheMonde;
        draw;
        Encadre;
end; // PaintBoxPaint

destructor TgrapheValeur.Destroy;
begin
     inherited destroy;
end;

Function TFValeurs.FormatGridVariab(Acol,Arow : Integer) : string;
var isPrec : boolean;
    indexV : integer;
begin
    result := '';
    if Acol=0 then begin
       if Arow=0 then result := 'Nom'
       else if Arow=1 then result := stUnite
       else result := intToStr(Arow-2);
       exit;
    end;
    isPrec := DeltaItem.isChecked and (Acol mod 2=0);
    indexV := indexVariable(acol);
    if indexV=grandeurInconnue then exit;
    with grandeurs[indexV] do begin
         if Arow=0
            then if isPrec
            then result := nomIncertitude
            else result := nom;
         if Arow=1 then result := NomAff(PuissAff);
    end;
    if Arow<2 then exit;
    Arow := Arow-2;
    with grandeurs[indexV] do begin
        if fonct.genreC=g_texte
        then result := pages[pageCourante].texteVar[indexV,Arow]
        else if isPrec
           then result := FormatIncert(pages[pageCourante].incertVar[indexV,Arow],CoeffAff)
           else result := FormatNombre(pages[pageCourante].valeurVar[indexV,Arow],CoeffAff)
    end;
end;

Function TFValeurs.FormatGridConst(Acol,Arow : Integer) : string;
var indexC,iParam,page : integer;
    isPrec : boolean;
begin
    result := '';
    if Acol=0 then begin
       if Arow=0 then result := stPage
       else if Arow=1 then result := ''
       else result := intToStr(Arow-1);
       exit;
    end;
    isPrec := DeltaItem.isChecked and (Acol mod 2=0);
    indexC := indexConstante(Acol);
    if indexC=grandeurInconnue then exit;
    with grandeurs[indexC] do begin
         if Arow=0
            then if isPrec
            then result := nomIncertitude
            else result := nom;
         if Arow=1 then result := NomAff(PuissAff);
    end;
    if Arow<2 then exit;
    page := Arow-1;
    if (page<=NbrePages) then if indexC<parametre0
           then begin // constante
              if indexC<>grandeurInconnue then with  grandeurs[indexC] do
                 if fonct.genreC=g_texte
                    then result := pages[page].texteConst[indexC]
                    else if isPrec
                 then result := formatIncert(pages[page].incertConst[indexC],CoeffAff)
                 else result := formatNombre(pages[page].valeurConst[indexC],CoeffAff)
           end
           else begin // paramètre
               iParam := indexToParam(indexC);
               with parametres[iParam] do
               if isPrec
                   then result := formatIncert(pages[page].incertParam[iParam],coeffAff)
                   else result := formatNombre(pages[page].valeurParam[iParam],coeffAff)
           end;
end;

procedure TFValeurs.TraceGridVariab;

Procedure enTeteGridVariab;
var maximum,z : double;
    j : integer;
    indexVar,k,colonne : integer;
    modifiable : boolean;
begin with pages[PageCourante] do begin
    ColPermiseVariab := [];
    derniereColVariab := 0;
    for k := 0 to (NbreVariab-1) do begin
        indexVar := indexVariab[k];
        colonne := k;
        if DeltaItem.isChecked then colonne := 2*colonne;
        colonne := colonne+1;
        with grandeurs[indexVar] do begin
           Modifiable := (fonct.genreC=g_experimentale) and
                ((ModeAcquisition in [AcqClavier,AcqFichier,AcqClipBoard]));
           puissAff := 0;
           CoeffAff := 1;
           if fonct.genreC=g_texte then
              include(ColPermiseVariab,colonne);
           if (fonct.genreC=g_equation) or modifiable then begin
              include(ColPermiseVariab,colonne);
              if DeltaItem.isChecked and (incertCalc.expression='') then
                 include(ColPermiseVariab,succ(colonne));
           end;
           if modifiable then derniereColVariab := colonne;
           if not modifiable and
               correct and
               not(UniteDonnee) and
               not(UnitePart) and
               (fonct.genreC<>g_texte) and
               not(formatU in [fLongueDuree,fDateTime,fDate,fTime])
             then begin
               maximum := 0;
               for j := 0 to (nmes-1) do begin
                  z := abs(valeurVar[indexVar,j]);
                  if not isNan(z) and (z>maximum) then maximum := z;
               end;
               if (maximum>0) and
                  (nomUnite<>'') and
                  (formatU<>fDefaut) then begin
                  maximum := maximum*1.001;
                  puissAff := 3*floor(log10(maximum)/3);
                  if (puissAff<>0) and (puissance<>0) then
                     puissAff := 3*floor((puissAff+puissance)/3)-puissance;
                  coeffAff := dix(-puissAff);
               end;
         end;
       end
     end;
end end;// enTeteGridvariab

Procedure AffichePage;
var k,colonne : integer;
    LigneSup : boolean;
begin
      enTeteGridVariab;
      LigneSup := (ModeAcquisition=AcqClavier);
      with GridVariab,pages[PageCourante] do begin
           Colonne := NbreVariab;
           if DeltaItem.isChecked then Colonne := 2*Colonne;
           colonne := colonne+1;// numéro de ligne
           ColumnCount := colonne;
           if LigneSup
               then RowCount := Nmes+3
               else RowCount := Nmes+2;
           if RowCount<=2 then RowCount := 3; // ne devrait pas arriver ?
           for k := 0 to (NbreVariab-1) do begin
               colonne := k;
               if DeltaItem.isChecked then colonne := 2*colonne;
               colonne := colonne+1;
               comments[colonne,0] := 'Cliquer pour modifier l''affichage, l''incertitude ... de la variable';
           end;
end end; // AffichePage

begin
   if not GridVariab.visible then begin
      MajGridVariab := true;
      exit;
   end;
   GridVariab.BeginUpdate;
   if (NbreVariab>0) and (pageCourante>0) then affichePage;
   DelGrandeurItem.enabled := NbreVariabExp>0;
   DelSelectItem.enabled := true;
   GridVariab.EndUpdate;
   DeltaItem.text := hintIncert[DeltaItem.isChecked];
   incertVarBtn.Hint := hintIncert[DeltaItem.isChecked];
   MajGridVariab := false;
end; // TraceGridVariab

procedure TFValeurs.FonctionBtnMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
  var key : string;
begin
    try
    key := (sender as TtreeViewItem).text;
    if AideFonction.ContainsKey(key)
       then FRegressiMain.aide.Text := AideFonction.items[key]
       else FRegressiMain.aide.Text := '';
    except
         FRegressiMain.aide.Text := '';
    end;
end;

procedure TFValeurs.TMSFNCGrid1GetCellClass(Sender: TObject; ACol,
  ARow: Integer; var CellClassType: TTMSFNCGridCellClass);
begin
  if (acol=0)
       then CellClassType := TTMSFNCFixedGridCell
       else if (arow=1) then CellClassType := TTMSFNCFixedGridCell
       else if (arow=0) then CellClassType := TTMSFNCFixedGridCell;
end;

procedure TFValeurs.TMSFNCGrid1GetCellEditorType(Sender: TObject; ACol,
  ARow: Integer; var CellEditorType: TTMSFNCGridEditorType);
var indexV : integer;
begin
    indexV := grandeurInconnue;
    if sender=gridVariab then indexV := indexVariable(acol);
    if sender=gridParam then indexV := indexConstante(acol);
    if indexV=grandeurInconnue then exit;
    if grandeurs[indexV].fonct.genreC in
       [g_experimentale,g_equation] then
       //  (CellEditorType as TTMSFNCGridEdit).validChars := validCharsGrid;
end;

procedure TFValeurs.TMSFNCGrid3GetCellClass(Sender: TObject; ACol,
  ARow: Integer; var CellClassType: TTMSFNCGridCellClass);
begin
   CellClassType := TTMSFNCButtonGridCell
end;

procedure TFValeurs.TraceGridParam;

Procedure enTeteGridParam;
var maximum,z : double;
    page,i : integer;
    indexC,colonne : integer;
begin
    colPermiseParam := [];
    for i := 0 to (NbreConst-1) do begin
        indexC := indexConst[i];
        colonne := i;
        if DeltaItem.isChecked then colonne := 2*colonne;
        colonne := colonne+1;
        with grandeurs[indexC] do begin
        PuissAff := 0;
        CoeffAff := 1;
        if fonct.genreC=g_texte then
           include(ColPermiseParam,colonne);
        if fonct.genreC in [g_experimentale,g_equation] then begin
           include(ColPermiseParam,colonne);
           if DeltaItem.isChecked then include(ColPermiseParam,succ(colonne));
        end;
        if (fonct.genreC<>g_experimentale) and
           correct and
           not(UniteDonnee) and
           not(UnitePart) and
           not(formatU in [fLongueDuree,fDateTime,fdate,fTime]) then begin
              maximum := 0;
              for page := 1 to NbrePages do begin
                  z := pages[page].valeurConst[indexC];
                  if not isNan(z) then begin
                     z := abs(z);
                     if z>maximum then maximum := z;
                  end;
              end;
              if (maximum>0) and
                 (nomUnite<>'') and
                 (formatU<>fDefaut) then begin
                 maximum := maximum*1.001;
                 puissAff := 3*floor(log10(maximum)/3);
                 if (puissAff<>0) and (puissance<>0) then
                     puissAff := 3*floor((puissAff+puissance)/3)-puissance;
                 coeffAff := dix(-puissAff);
              end;
        end; // if not experimentale
        end { with grandeurs}
     end;//for i
     for i := 1 to NbreParam do with parametres[i] do begin
        PuissAff := 0;
        CoeffAff := 1;
        maximum := 0;
        for page := 1 to NbrePages do begin
               z := pages[page].valeurParam[i];
               if not isNan(z) then begin
                  z := abs(z);
                  if (z>maximum) then maximum := z;
               end;
        end;
        if (maximum>0) and
           (formatU<>fDefaut) then begin
            maximum := maximum*1.001;
            puissAff := 3*floor(log10(maximum)/3);
            if (puissAff<>0) and (puissance<>0) then
                puissAff := 3*floor((puissAff+puissance)/3)-puissance;
            coeffAff := dix(-puissAff);
        end;
     end;
end; // enTeteGridparam

Procedure AfficheConstantes;
var NCol : integer;
begin
      enTeteGridParam;
      Ncol := NbreConst + NbreParam;
      if DeltaItem.isChecked then Ncol := 2*Ncol;
      Ncol := Ncol+1; // Numéro de ligne
      GridParam.columnCount := Ncol;
end;// AfficheConstantes

begin
  // if not GridParam.visible then exit;
   GridParam.beginUpdate;
   GridParam.RowCount := NbrePages+2;
   if (NbreConst + NbreParam)>0
      then afficheConstantes
      else GridParam.columnCount := 1;
   TrierItem.enabled := NbrePages>2;
   DelGrandeurItem.enabled := NbreConstExp>0;
   incertParamBtn.Hint := hintIncert[DeltaItem.isChecked];
   GridParam.endUpdate;
end;// TraceGridParam


procedure TFValeurs.GridVariabGetCellData(Sender: TObject; ACol, ARow: Integer;
  var CellString: string);
begin
    if nbreVariab=0
       then CellString := ''
       else cellString := formatGridVariab(Acol,ARow);
end;

procedure TFValeurs.GridVariabGetCellEditorProperties(Sender: TObject; ACol,
  ARow: Integer; CellEditor: TControl);
var indexV : integer;
begin
    indexV := grandeurInconnue;
    if sender=gridVariab then indexV := indexVariable(acol);
    if sender=gridParam then indexV := indexConstante(acol);
    if indexV=grandeurInconnue then exit;
    if (grandeurs[indexV].fonct.genreC in [g_experimentale,g_equation]) and
       (CellEditor is TTMSFNCGridEdit) then
         (CellEditor as TTMSFNCGridEdit).validChars := validCharsGrid;
end;


procedure TFValeurs.GridVariabGetCellIsFixed(Sender: TObject; ACol,
  ARow: Integer; var ACellFixed: Boolean);
begin
    AcellFixed := (ARow<=1) or not (Acol in colPermiseVariab)
end;

procedure TFValeurs.GridVariabGetCellReadOnly(Sender: TObject; ACol,
  ARow: Integer; var AReadOnly: Boolean);
var indexV : integer;
begin
    indexV := grandeurInconnue;
    if sender=gridVariab then indexV := indexVariable(acol);
    if sender=gridParam then indexV := indexConstante(acol);
    AReadOnly := (indexV=grandeurInconnue) or (arow<2) or
        not (grandeurs[indexV].fonct.genreC in [G_texte,G_experimentale,G_equation]);
end;

procedure TFValeurs.AddBtnClick(Sender: TObject);
begin
     NewVarDlg := TNewVarDlg.Create(self);
     with NewVarDlg do begin
        Initialise(0);
        if sender=AddParamBtn then GenreGrandeurRG.itemIndex := 1;
        CentreForm(newvarDlg);
        if NewVarDlg.showModal=mrOK then begin
           if LigneInit<>'' then Memo.Lines.Add(LigneInit);
           if LigneCompile<>'' then Memo.Lines.Add(LigneCompile);
         // grandeur calculée
           if LigneSignif<>'' then Memo.Lines.Add(LigneSignif);
           FRegressiMain.WMRegMaj(MajGrandeur);
           Recompiler := not ErreurCompile;
           ModifFichier := true;
        end;
     end;
     NewVarDlg.free;
     FeuilletsChange(nil);
end; // AddBtn

procedure TFValeurs.DeleteBtnClick(Sender: TObject);
var indexVar : integer;
    Acol : integer;
begin
     MajBtnClick(sender);
     indexVar := grandeurInconnue;
     if feuillets.ActiveTab=paramSheet then begin
         Acol := GridParam.FocusedCell.col-1;
         if DeltaItem.isChecked then Acol := Acol div 2;
         if (Acol>=0) and (Acol<NbreConst) then
            indexVar := indexConst[Acol];
     end;
     if feuillets.ActiveTab=variabSheet then begin
         Acol := GridVariab.FocusedCell.col-1;
         if DeltaItem.isChecked then Acol := Acol div 2;
         if (Acol>=0) and (Acol<NbreVariab) then
            indexVar := indexVariab[Acol];
     end;
     suppressionDlg := TSuppressionDlg.Create(self);
     SuppressionDlg.operation := oSuppression;
     if (indexVar>=0) and (indexVar<NbreGrandeurs)
        then SuppressionDlg.nomDefaut := grandeurs[indexVar].nom
        else SuppressionDlg.nomDefaut := '';
     CentreForm(SuppressionDlg);
     if SuppressionDlg.showModal=mrOK then begin
        reCompiler := true;
        compileP;
// en particulier les fonctions pouvant contenir la grandeur supprimée
     end;
     suppressionDlg.Free;
end; // DeleteBtn

procedure TFValeurs.CompileP;
var i : integer;
    posErreurLigne,posErreur,longErreur : integer;
    indexHelp : integer;

Function ErreurConstante : boolean;
type
    tdepend = (dInit,dFonction,dNone);
var i,j,iConst : integer;
    depend : Tdepend;
    strErreur : string;
begin
      result := false;
      for i := 0 to (NbreConstExp-1) do with pages[pageCourante] do begin
          iConst := indexConstExp[i];
          if isNan(valeurConst[iConst]) then begin
                depend := dNone;
                for j := 0 to (NbreGrandeurs-1) do
                    if iConst in grandeurs[j].fonct.depend then begin
                       depend := dFonction;
                       if grandeurs[j].fonct.genreC in [g_diff1,g_diff2,g_euler] then
                          depend := dInit;
                       break;
                    end;
                case depend of
                    dInit : strErreur := erInitAdefinir;
                    dNone : strErreur := erConstNonDef;
                    dFonction : strErreur := erParamAdefinir;
                end;
                result := depend<>dNone;
                if result then begin
                   ErreurDetectee := true;
                   AfficheErreur(strErreur,0);
                   Feuillets.ActiveTab := ParamSheet;
                   TraceGridParam;
                   GridParam.setFocus;
                   break;
                end;
             end;
      end;       
end; // ErreurConstante

Function ErreurForward : boolean;
begin
      result := false;
end; // ErreurForward

Function CompileLigneG(NumLigne : integer;
          var posErreur,longErreur : integer) : boolean;
var NomLu : string;
    LigneCourante : string;

Procedure VerifCrochets;
var posOuvre : integer;
begin // identifier z et z[i] ou z[i+1]
        posOuvre := pos('[i]',nomLu);
        if (posOuvre>1) and
           (posOuvre=length(nomLu)-2) then begin
            nomLu := copy(nomLu,1,posOuvre-1);
            exit;
        end;
        posOuvre := pos('[i+1]',nomLu);
        if (posOuvre>1) and
           (posOuvre=length(nomLu)-4) then result := false;
end;

Procedure VerifValeurInit;
var posOuvre,indexVar : integer;
    newNom : string;
    newAddr : tgrandeur;
begin // z[0]
    posOuvre := pos('[0]',nomLu);
    if (posOuvre>1) and
       (posOuvre=length(nomLu)-2) then begin
        newNom := copy(nomLu,1,posOuvre-1);
        indexVar := IndexNom(newNom);
        if (indexVar<>GrandeurInconnue) and
           (grandeurs[indexVar].fonct.genreC=g_forward) then exit;
        if nomCorrect(newNom,grandeurInconnue) then begin
             newAddr := tgrandeur.Create;
             newAddr.Init(newNom,'','',variable);
             newAddr.fonct.genreC := g_forward;
             ajouteGrandeurE(newAddr);
         end;
    end;
end;

var PosEgal : integer;
    expressionLu : string;
    AddrLu : tgrandeur;
    ordreEqua : integer;
    indexV,k : integer;
    oldNbre : integer;
begin
    PrevenirFonctionDeParam := false;
    ligneCourante := memo.lines[numLigne];
    posErreur := 1;
    longErreur := 1;
    oldNbre := NbreGrandeurs;
    result := true;
    if IsLigneComment(ligneCourante) then exit;
    PosEgal := Pos('=',ligneCourante);
    if PosEgal=0 then begin
        posEgal := pos(reperageConstGlb,ligneCourante);
        if posEgal>0 then ligneCourante := copy(ligneCourante,1,posEgal-1);
        grandeurImmediate.fonct.expression := ligneCourante;
        if grandeurImmediate.compileG(posErreur,longErreur,0)
           then memo.lines[numLigne] := ligneCourante+reperageConstGlb
// calcul fait à la fin quand les autres grandeurs sont connues
           else memo.lines[numLigne] := ligneCourante+' ?';
        exit;
    end;
    trimComplet(ligneCourante);
    PosEgal := Pos('=',ligneCourante);
    nomLu := copy(ligneCourante,1,posEgal-1); // extrait le nom
    trimComplet(nomLu);
    ordreEqua := 0;
    if (length(nomLu)>0) and (nomLu[length(nomLu)]='''') then begin
       delete(nomLu,length(nomLu),1);
       inc(ordreEqua);
       if (length(nomLu)>0) and (nomLu[length(nomLu)]='''') then begin
           delete(nomLu,length(nomLu),1);
           inc(ordreEqua)
       end;
    end;
    if (length(nomLu)>0) and (nomLu[length(nomLu)]='"') then begin
       delete(nomLu,length(nomLu),1);
       ordreEqua := 2;
    end;
    if VerifCreneau(ligneCourante) then memo.lines[numLigne] := ligneCourante;
    if ordreEqua=0 then verifCrochets;
    if not result then begin
       codeErreurC := erIndiceEuler;
       indexHelp := HELP_Euler;
       longErreur := length(nomLu);
       exit;
    end;
    expressionLu := copy(ligneCourante,succ(posEgal),Length(ligneCourante)-posEgal);
    posEgal := pos(reperageConstGlb,expressionLu);
    if posEgal>0 then expressionLu := copy(expressionLu,1,posEgal-1);
    result := NomCorrect(nomLu,grandeurInconnue);
    if not result then begin
          longErreur := length(nomLu);
          exit;
    end;
    indexV := IndexNom(nomLu);
    if (indexV<>GrandeurInconnue) and
       (grandeurs[indexV].fonct.genreC=g_forward)
          then begin
               AddrLu := grandeurs[indexV];
               AddrLu.fonct.expression := expressionLu;
               while indexV<(NbreGrandeurs-1) do begin
                     TransfereVariabE(indexV,indexV+1);
                     inc(indexV);
// pour que le calcul d'un sytème se fasse dans l'ordre de définition des fonctions
               end;
          end
          else begin
               AddrLu := tgrandeur.Create;
               AddrLu.Init(nomLu,'',expressionLu,variable);
               ajouteGrandeurE(AddrLu);
          end;
    if AddrLu.compileG(posErreur,longErreur,ordreEqua)
       then VerifValeurInit
       else begin
           result := false;
           posEgal := Pos('=',ligneCourante);
           posErreur := posErreur+posEgal;
           for k := (NbreGrandeurs-1) downto oldNbre do libereGrandeurE(k);
// grandeur créée plus dérivée ou grandeur init éventuelle créée par équa diff
       end;
     if prevenirFonctionDeParam and
        ((numLigne=(memo.Lines.count-1)) or
         (pos(erParamModeleVersExp,memo.Lines[numLigne+1])<=0))
         then memo.Lines.Insert(numLigne+1,''''+erParamModeleVersExp);
end; // CompileLigneG

var indexVar,posDebutLigne : integer;
    debutReperage,posEgal : integer;
    ligne : string;
    nomLu : string;
    memoActif,compileOK : boolean;
    oldNbreGrandeurs : integer;
begin // CompileP
     erreurDetectee := false;
     oldNbreGrandeurs := NbreGrandeurs;
     memoActif := active and (memo=activeControl);
     compilationEnCours := true;
     DebutCompileG;
     posErreur := 0;
     indexHelp := 0;
     codeErreurC := '';
     compileOK := true;
     while (memo.lines.count>0) and
           (memo.lines[0]='') do memo.lines.delete(0);
     while (memo.lines.count>2) and
           (memo.lines[memo.lines.count-1]='') and
           (memo.lines[memo.lines.count-2]='')
          do memo.lines.delete(memo.lines.count-1);
     i := 0;
     while i<memo.lines.count do begin
         ligne := memo.lines[i];
         compileOK := compileLigneG(i,posErreurLigne,longErreur);
         if compileOK
            then posErreur := posErreur + length(ligne) + 1 // 1=CR+LF
            else begin
                 posErreur := posErreur + posErreurLigne;
                 break;
            end;
         inc(i);   
     end; // for memo.lines
     if compileOK then for i := 0 to (NbreGrandeurs-1) do
         if grandeurs[i].fonct.genreC=g_forward then
            codeErreurC := erForward;
     finCompileG;
     FRegressiMain.TrigoBtn.Text := captionAngle[angleEnDegre];
     FRegressiMain.TrigoBtn.hint := hintAngle[angleEnDegre];
     RadDegTabBtn.ImageIndex := indexImageAngle[AngleEnDegre];
     RadDegExpBtn.ImageIndex := RadDegTabBtn.ImageIndex;
     ResetListeGrandeurs;
     recompiler := false;
     compilationEnCours := false;
     if compileOK
        then begin
          ErreurCompile := false;
          for i := 0 to (memo.lines.count-1) do begin
              ligne := memo.lines[i];
              PosEgal := Pos('=',ligne);
              if (PosEgal>0) and (ligne[1]<>'''') then begin
                  nomLu := copy(ligne,1,posEgal-1);
                  trimComplet(nomLu);
                  indexVar := IndexNom(nomLu);
                  debutReperage := pos(reperageConstGlb,ligne);
                  if (indexVar<>grandeurInconnue) and
                     (grandeurs[indexVar].genreG<>ConstanteGlb) and
                     (debutReperage>0) then begin
                         delete(ligne,debutReperage,length(ligne)-debutReperage+1);
                         memo.lines[i] := ligne;
                  end;
               end; // x=expression
          end; // for i
          posDebutLigne := 0;
          for i := 0 to (memo.lines.count-1) do begin
              MajValeurConstGlb(i,posDebutLigne);
              posDebutLigne := posDebutLigne+length(memo.lines[i])+1; // +1=LF
          end;
          if memoActif and (FRegressiMain.windowTab.ActiveTab = FRegressiMain.ValeursTab) then begin // curseur en fin de mémo
             memo.setFocus;
             Memo.gotoTextEnd;
          end;
          memo.selLength := 0;
          memo.repaint; // ??
          if ErreurConstante or ErreurForward then exit;  // ??
          if (FRegressiMain.windowTab.ActiveTab = FRegressiMain.ValeursTab) and
             (feuillets.ActiveTab=ExpSheet) then memo.setFocus;
          modifFichier := modifFichier or (NbreGrandeurs<>oldNbreGrandeurs);
          FregressiMain.WMRegMaj(MajGrandeur);
        end
        else begin // erreur
             FregressiMain.windowTab.ActiveTab := FregressiMain.valeursTab;
             afficheErreur(codeErreurC,indexHelp);
             ErreurDetectee := true;
             memo.setFocus;
             memo.selStart := posErreur-1;
             memo.selLength := longErreur;
             ErreurCompile := true;
        end;
     recompiler := false;
// car modif du format du texte a remis recompiler à true
end; // CompileP

procedure TFValeurs.MajValeurConstGlb(i,posDebutLigne : integer);
var nomLu,ligne,ajout : string;
    indexConst,posEgal : integer;
    debutReperage : integer;
    posErreur,longErreur : integer;
begin
     ligne := memo.lines[i];
     PosEgal := Pos('=',ligne);
     debutReperage := pos(reperageConstGlb,ligne);
     if (PosEgal>0) and (ligne[1]<>'''') then begin
          nomLu := copy(ligne,1,posEgal-1);
          trimComplet(nomLu);
          indexConst := IndexNom(nomLu);
          if (indexConst<>grandeurInconnue) and
             (grandeurs[indexConst].genreG=ConstanteGlb)
                  then begin // ajouter résultat si constanteGlb
                     if debutReperage>0 then
                        ligne := copy(ligne,1,debutReperage-1);
                     with grandeurs[indexConst] do
                        ajout := FormatNomEtUnite(valCourante);
                     ligne := ligne+reperageConstGlb+ajout;
                     memo.Lines[i] := ligne;
                  end;
          end;
     if (PosEgal=0) and (debutReperage>0) then begin
      // valeur immédiate globale 
          ligne := copy(ligne,1,debutReperage-1);
          grandeurImmediate.fonct.expression := ligne;
          if grandeurImmediate.compileG(posErreur,longErreur,0) then begin
             if not grandeurImmediate.uniteDonnee then grandeurImmediate.SetUnite;
             grandeurs[cIndice].valCourante := 0;
             grandeurImmediate.valCourante := calcule(grandeurImmediate.fonct.calcul);
             ligne := ligne+reperageConstGlb+
               grandeurImmediate.FormatValeurEtUnite(grandeurImmediate.valCourante);
             memo.lines[i] := Ligne;
          end;
     end;
end;

procedure TFValeurs.MaxiXeditChange(Sender: TObject);
begin
     MajSimulation := true;
end;

procedure TFValeurs.MaxiXeditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
     if keyChar=crCR
        then begin
           if verifMinMax(Sender)
              then MajBtnClick(sender);
           key := 0;
           keyChar := #0;
        end
        else if keyChar<>crTab
             then VerifKeyGetFloat(keyChar)
end;

procedure TFValeurs.CompileItemClick(Sender: TObject);
begin
     CompileP
end;

procedure TFValeurs.FeuilletsClick(Sender: TObject);
begin
    if pageCourante=0 then exit;
    with pages[pageCourante] do if modifiedP then begin
       RecalculP;
       if Feuillets.activeTab=VariabSheet then traceGridVariab;
    end;
end;

procedure TFValeurs.TriBtnClick(Sender: TObject);
var indexV, colIdx : integer;
begin
     indexV := grandeurInconnue;
     if feuillets.activeTab=variabSheet then begin
        colIdx := gridVariab.FocusedCell.col-1;
        if DeltaItem.isChecked then colIdx := colIdx div 2;
        if (colIdx>=0) and (colIdx<NbreVariab) then
           indexV := indexVariab[colIdx];
     end;
     if (indexV=grandeurInconnue) or (indexV<0) or (indexV>=NbreGrandeurs) then exit;
     suppressionDlg:=TSuppressionDlg.Create(self);
     SuppressionDlg.operation := oTriVariable;
     SuppressionDlg.nomDefaut := grandeurs[indexV].nom;
     centreForm(suppressionDlg);
     if SuppressionDlg.showModal=mrOK then traceGridVariab;
     suppressionDlg.free;
end;

procedure TFValeurs.UniteXeditChange(Sender: TObject);
begin
    recompiler := true;
end;

procedure TFValeurs.UniteXeditExit(Sender: TObject);
begin
       grandeurs[0].NomUnite := UniteXEdit.text;
       if pos('°', grandeurs[0].nomUnite)>0 then changeAngle(true);
       if pos('rad', grandeurs[0].nomUnite)>0 then changeAngle(false);
       if not grandeurs[0].correct and
          not OKReg(OkUniteInconnue,HELP_Unites) then
              UniteXEdit.setFocus;
end;

procedure TFValeurs.FormCreate(Sender: TObject);
var col,row,idx : integer;
begin
   GlobalDisableFocusEffect := True;
   compilationEnCours := false;
   MesureCourante := 0;
   MajGridVariab := false;
   Recompiler := false;
   GridVariab.columnWidths[0] := 45;
   GridParam.columnWidths[0] := 45;
   prevenirPi := true;
   Graphe := TgrapheValeur.create(paintBox1);
   GrecGrid.ColumnCount := 5;
   GrecGrid.RowCount := 5;
   for col := 0 to GrecGrid.columnCount-1 do
       GrecGrid.ColumnWidths[col] := 26;
   for row := 0 to GrecGrid.rowCount-1 do
       for col := 0 to GrecGrid.columnCount-1 do begin
           idx := col + row * GrecGrid.columnCount;
           if idx <= High(LettresGrecquesMin) then begin
              GrecGrid.AddButton(col,row,LettresGrecquesMin[idx]);
              GrecGrid.FontStyles[Col,Row] := [TFontStyle.fsBold];
              GrecGrid.FontSizes[Col,Row]:= 14;
           end;
       end;
   AideFonction := TDictionary<String,String>.create;
   AideFonction.Add('Sin','sinus');
   AideFonction.Add('Cos','cosinus');
   AideFonction.Add('Tan','tangente');
   AideFonction.Add('Acos','arccosinus');
   AideFonction.Add('Asin','arcsinus');
   AideFonction.Add('Frac','partie fractionnaire');
   AideFonction.Add('Log','logarithme décimal');
   AideFonction.Add('Ln','logarithme népérien');
   AideFonction.Add('Exp','exponentielle');
   AideFonction.Add('Noise','noise(x)= valeur aléatoire gaussienne centré d''écart-type x');
   AideFonction.Add('Atan','arctangente à valeur entre -'+piMin+'/2 et +'+piMin+'/2 (voir Arg pour -'+piMin+' et +'+piMin);
   AideFonction.Add('Arg','arg(x+j*y)=argument de z = x+j*y');
   AideFonction.Add('Phase','phase(x,y)=phase(y)-phase(x)');
   AideFonction.Add('Filtre','filtre(x,G(f))=x filtré par G(f) : gain complexe');
   AideFonction.Add('Triangle','triangle(t,f,r)=triangle de fréquence f et de rapport cyclique r (durée pente positive / période)');
   AideFonction.Add('Creneau','creneau(t,f,r)=créneau de fréquence f et de rapport cyclique r (durée état haut / période)');
   AideFonction.Add('Lisse','lisse(y,N)=ôte les points "incorrects" puis filtre avec tau=N*Tech');
   AideFonction.Add('Ech','échelon');
   AideFonction.Add('CH','cosinus hyperbolique');
   AideFonction.Add('SH','sinus hyperbolique');
   AideFonction.Add('Re','partie réelle');
   AideFonction.Add('Im','partie imaginaire');
   AideFonction.Add('Env','enveloppe');
   AideFonction.Add('Sign','signe');
   AideFonction.Add('Sqrt','racine carrée');
   AideFonction.Add('Sinc','sinus cardinal');
   AideFonction.Add('RMS','valeur efficace sur une période');
   AideFonction.Add('Min','minimum');
   AideFonction.Add('Max','maximum');
   AideFonction.Add('Erf','error function');
   AideFonction.Add('Freq','');
   AideFonction.Add('Moy','moyenne');
   AideFonction.Add('Avg','moyenne sur une période');
end;

procedure TFValeurs.CopierItemClick(Sender: TObject);
begin
  Memo.CopyToClipBoard
end;

procedure TFValeurs.CopierTableauItemClick(Sender: TObject);
begin
  if Feuillets.ActiveTab = ParamSheet then
    GridParam.CopyToClipBoard
  else if Feuillets.ActiveTab = VariabSheet then
    GridVariab.CopyToClipBoard
  else
    Memo.CopyToClipBoard;
end;

procedure TFValeurs.SyntaxeBtnClick(Sender: TObject);
begin
  FRegressiMain.AideItemClick(Sender);
end;

procedure TFValeurs.MajBtnClick(Sender: TObject);
begin
  if (sender=RazItem) or (sender=MajBtn) or (sender=nil)
    then begin
        Memo.beginUpdate;
        if majSimulation and
           (modeAcquisition=AcqSimulation)
           then remplit
           else if recompiler then compileP;
        Memo.EndUpdate
    end;
end; // Mise à jour

procedure TFValeurs.Recalculer;
begin
        Memo.beginUpdate;
        recompiler := true;
        compileP;
        Memo.EndUpdate
end;

procedure TFValeurs.GridVariabFixedCellButtonClick(Sender: TObject; ACol,
  ARow: Integer);
var indexV : integer;
begin
// modif du nom, de l'unité et du format
        if (ARow>1) or (ACol<1) then exit;
        indexV := indexVariable(Acol);
        if indexV=grandeurInconnue then exit;
        if gridVariab.editing then gridVariab.CancelEdit;
        modifDlg := TmodifDlg.create(self);
        modifDlg.indexV := indexV;
        CentreForm(modifDlg);
        if modifDlg.showModal=mrOk then begin
           if Acol=1 then definitGrandeurFrequence;
           traceGridVariab;
        end;
        modifDlg.Free;
end;

procedure TFValeurs.MemoChange(Sender: TObject);
begin
     if (pageCourante>0) and
        not(LectureFichier) and
        not(LecturePage) then
           Recompiler := true;
end;

procedure TFValeurs.MemoKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
const vk_return=13; // comme CR
begin
   if key=vk_return
      then if premierCR
           then begin
             key := 0;
             keyChar := char(0);
             compileP
           end
           else premierCR := true
      else begin
         premierCR := false;
         FregressiMain.FormKeyDown(sender,key,keychar,shift);
      end;
end;

procedure TFValeurs.MemoKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
{$IFDEF MACOS}
    if (ssCommand in Shift)
{$ELSE}
    if (ssCtrl in Shift)
{$ENDIF}
       and ((char(key)='C') or (char(key)='c')) then begin
       Memo.copyToClipBoard;
       exit;
    end;
{$IFDEF MACOS}
    if (ssCommand in Shift)
{$ELSE}
    if (ssCtrl in Shift)
{$ENDIF}
       and ((char(key)='V') or (char(key)='v')) then begin
       Memo.pasteFromClipBoard;
       exit;
    end;
    FRegressiMain.VerifGrec(memo,key,keychar,shift);
end;

procedure TFValeurs.MinixEditExit(Sender: TObject);
begin
     if VerifMinMax(sender)
        then MajBtnClick(sender)
        else with Sender as Tedit do SetFocus
end;

procedure TFValeurs.NombreXSBChange(Sender: TObject);
begin
     MajSimulation := true;
     VerifMinMax(nil);
end;

procedure TFValeurs.NombreXSBExit(Sender: TObject);
begin
    remplit;
end;

procedure TFValeurs.nomXeditChange(Sender: TObject);
begin
   Recompiler := true;
end;

procedure TFValeurs.NomXeditExit(Sender: TObject);
begin
    if NomCorrect(NomXEdit.text,0)
       then begin
          grandeurs[0].nom := NomXEdit.Text;
          grandeurs[cDeltat].nom := deltaMaj+NomXEdit.Text;
          MajBtnClick(sender)
       end
       else begin
            afficheErreur(codeErreurC,0);
            NomXEdit.setFocus;
       end;
end;

procedure TFValeurs.DelSelectItemClick(Sender: TObject);
begin
      if not OKreg(OkDelData,0) then exit;
      if gridVariab.editing then GridVariab.CancelEdit; // Pour ne pas garder le contenu de cellEdit
      with GridVariab.selection do begin
         Pages[pageCourante].SupprimeLignes(StartRow-2,EndRow-2);
         FRegressiMain.WMRegMaj(MajAjoutValeur);
      end;
      traceGridVariab;
      ModifFichier := true;
end;

procedure TFValeurs.FormDeactivate(Sender: TObject);
begin
     if not compilationEnCours and
        (pageCourante>0) then
         MajBtnClick(sender);
end;

procedure TFValeurs.FormDestroy(Sender: TObject);
begin
    AideFonction.free;
    graphe.Free;
end;

procedure TFValeurs.pageNewItemClick(Sender: TObject);
begin
    FregressiMain.PageAddClick(Sender)
end;

procedure TFValeurs.FileAddItemClick(Sender: TObject);
begin
    FRegressiMain.FileAddItemClick(sender)
end;

procedure TFValeurs.ImprimeBtnClick(Sender: TObject);
var
  bas : single;

  procedure PrintGrid(AGrid : TTMSFNCGrid);
  var r, c : integer;
      ligne : string;
  begin
    if AGrid = nil then exit;
    PrintLine('', bas);
    for r := 0 to AGrid.RowCount - 1 do begin
      ligne := '';
      for c := 0 to AGrid.ColumnCount - 1 do begin
        if c > 0 then ligne := ligne + '   ';
        ligne := ligne + AGrid.Cells[c, r];
      end;
      PrintLine(ligne, bas);
    end;
  end;

begin
    try
    Printer.Orientation := TPrinterOrientation.poPortrait;
    Printer.BeginDoc;
    bas := 0;
    beginPrintTxt(bas);
    PrintList(Memo.Lines,DateToStr(Now)+'  '+NomFichierData,bas);
    if (NbrePages>1) and
       ((NbreConst+NbreParam)>0) then begin
         TraceGridParam;
         PrintGrid(GridParam);
    end;
    if (pages[pageCourante].nmes<60)
         then begin
            TraceGridVariab;
            PrintGrid(GridVariab);
         end
         else afficheErreur(erGrandTableau,0);
    printer.endDoc;
    except

    end;
end;

procedure TFValeurs.IncertParamBtnClick(Sender: TObject);
begin
    DeltaItem.isChecked := not DeltaItem.isChecked;
    TraceGridParam;
end;

procedure TFValeurs.IncertVarBtnClick(Sender: TObject);
begin
    DeltaItem.isChecked := not DeltaItem.isChecked;
    TraceGridVariab;
end;

procedure TFValeurs.DeltaBtnClick(Sender: TObject);
begin
     if feuillets.ActiveTab=paramSheet then incertParamBtnClick(sender);
     if feuillets.ActiveTab=variabSheet then incertVarBtnClick(sender);
end;

procedure TFValeurs.GridParamGetCellData(Sender: TObject; ACol, ARow: Integer;
  var CellString: string);
begin
    cellString := formatGridConst(Acol,ARow);
end;

procedure TFValeurs.GridParamCellEditGetData(Sender: TObject; ACol,
  ARow: Integer; CellEditor: TControl; var CellString: string);
begin
    cellString := formatGridConst(Acol,ARow);
end;

procedure TFValeurs.GridParamCellEditSetData(Sender: TObject; ACol,
  ARow: Integer; CellEditor: TControl; var CellString: string);
var i,ii,page : integer;
    valeur : double;
    vide,isPrec : boolean;
    creation,addPage : boolean;
    indexV : integer;
begin with GridParam do begin
     if cellString=FormatGridConst(acol,arow) then exit;
     if cellString='' then exit;
     indexV := indexConstante(aCol);
     if indexV=grandeurInconnue  then exit;
     page := arow-1;
     isPrec := DeltaItem.isChecked and (acol mod 2=0);
     if (grandeurs[indexV].fonct.genreC=g_experimentale) and
        (isPrec or not (grandeurs[indexV].formatU in [fLongueDuree,fDateTime,fDate,fTime,fDegreMinute])) then begin
         convertCell(cellString);
         if cellString='' then begin
            cellString := FormatGridConst(acol,arow);// erreur donc ancienne valeur
            exit;
         end;
     end;
     AddPage := (ModeAcquisition=AcqSimulation) and
                (page=NbrePages+1) and
                (cellString<>'');
     if AddPage then begin
        if not ajoutePage then exit else FRegressiMain.WMRegMaj(MajAjoutPage);
        pages[page].nmes := pages[1].nmes;
        copyVecteur(pages[page].valeurVar[0],pages[1].valeurVar[0]);
        if page<maxPages then begin
           rowCount := rowCount+1;
           Cells[0,Arow] := IntToStr(page);
        end;
     end;
     Creation := false;
     case grandeurs[indexV].fonct.genreC of
         g_texte : begin
            pages[page].texteConst[indexV] := cellString;
            pages[page].valeurConst[indexV] := 0;
         end;
         g_experimentale,g_equation : begin
           try
           valeur := GetFloatDate(cellString,grandeurs[indexV].formatU);
           if isPrec
              then pages[page].incertConst[indexV] := valeur
              else begin
                  creation := isNan(pages[page].valeurConst[indexV]);
                  pages[page].valeurConst[indexV] := valeur;
              end;
           vide := false;
           for i := 0 to (NbreConst-1) do begin
               ii := indexConst[i];
               if (grandeurs[ii].fonct.genreC=g_experimentale) and
                  isNan(pages[page].ValeurConst[ii])
                     then vide := true;
           end;
           creation := creation and not vide and erreurDetectee;
           if creation
              then CompileP
              else begin
           if not vide then begin
               pages[page].recalculP;
             // Reconstruire les unités : exposants ?
               for i := Acol to (columnCount-1) do
                    Cells[i,arow] := FormatGridConst(i,arow);
           end;
           FRegressiMain.WMRegMaj(MajValeurConst);
           end;
           except
               on E:EGetFloatError do if E.message='chaine vide'
                 then begin
                    if grandeurs[indexV].fonct.genreC in [g_experimentale,g_equation] then
                      if isPrec
                         then pages[page].incertConst[indexV] := Nan
                         else pages[page].valeurConst[indexV] := Nan;
                 end
           end;
           end;
        end; // experimentale
     end; // case genreC
end;

procedure TFValeurs.GridParamExit(Sender: TObject);
begin
    if feuillets.activeTab<>ParamSheet then begin
       if gridParam.editing then gridParam.cancelEdit;
    end
end;

procedure TFValeurs.GridParamFixedCellButtonClick(Sender: TObject; ACol,
  ARow: Integer);
var indexC : integer;
begin // modif du nom, de l'unité et du format
        if (ARow>1) or (ACol<1) then exit;
        indexC := indexConstante(acol);
        if indexC=grandeurInconnue then exit;
        if gridParam.editing then gridParam.CancelEdit;
        modifDlg := TmodifDlg.create(self);
        modifDlg.indexV := indexC;
        CentreForm(modifDlg);
        if modifDlg.showModal=mrOk then begin
           resetListeGrandeurs;
           traceGridParam;
        end;
        modifDlg.free
end;


procedure TFValeurs.GridParamGetCellIsFixed(Sender: TObject; ACol,
  ARow: Integer; var ACellFixed: Boolean);
begin
    AcellFixed := (ARow<=1) or not (Acol in colPermiseParam)
end;

procedure TFValeurs.GridVariabCellEditSetData(Sender: TObject; ACol,
  ARow: Integer; CellEditor: TControl; var CellString: string);
var i,ii : integer;
    isPrec,ajoutValeur,ligneSuivante : boolean;
    indexV : integer;
begin with pages[PageCourante],GridVariab do begin
     if cellString=formatGridVariab(Acol,Arow) then exit;
     AjoutValeur := false;
     isPrec := DeltaItem.isChecked and (acol mod 2=0);
     indexV := indexVariable(acol);
     if (indexV=grandeurInconnue) or (arow<=1) then exit;
     if (grandeurs[indexV].fonct.genreC=g_texte) then begin
        TexteVar[indexV,arow-2] := cellString;
//        FRegressiMain.WMRegMaj(MajValeur,0);
        exit;
     end
     else if isPrec or not (grandeurs[indexV].formatU in [fLongueDuree,fDateTime,fDate,fTime,fDegreMinute]) then begin
         convertCell(cellString);
         if cellString='' then begin
            cellString := formatGridVariab(Acol,Arow);// erreur donc ancienne valeur
            exit;
         end;
     end;
     triAfaire := triAfaire or (indexV=0);
     if (grandeurs[indexV].fonct.genreC in [g_experimentale,g_equation]) then begin
           try
           if isPrec
              then incertVar[indexV,arow-2] := GetFloat(cellString)
              else valeurVar[indexV,arow-2] := GetFloatDate(cellString,grandeurs[indexV].formatU);
           if not isPrec and
              (ModeAcquisition in [AcqClavier,AcqFichier,AcqClipBoard]) then begin
              ligneSuivante := false;
              if acol>=derniereColvariab then begin
                 for i := 0 to pred(NbreVariab) do begin
                     ii := indexVariab[i];
                     if (grandeurs[ii].fonct.genreC=g_experimentale) and
                        not(isNan(ValeurVar[ii,arow-2]))
                        then ligneSuivante := true;
                 end;
              end;
              if ligneSuivante then begin
                 ModifFichier := true;
                 if (ModeAcquisition=AcqClavier) and (arow=rowCount-1) and (nmes<MaxMaxVecteur) then begin
                    nmes := nmes+1;
                    AjoutValeur := true;
                    RowCount := nmes+3;
                    cells[0,nmes+2] := intToStr(nmes);
                    for i := 1 to (columnCount-1) do
                        Cells[i,nmes+2] := '';
                    editCell(makeCell(1,nmes+2));
                 end
                 else if arow<rowCount-1 then
                    editCell(makeCell(1,arow+1));
              end;
           end;
           calculLigne(arow-2);
           for i := acol to (columnCount-1) do
               Cells[i,arow] := FormatGridVariab(i,arow);
           if isPrec
               then begin
                  FRegressiMain.WMRegMaj(MajIncertitude);
                  MajGraphe(MajIncertitude);
               end
               else if ajoutValeur
                  then begin
                     FRegressiMain.WMRegMaj(MajAjoutValeur);
                     MajGraphe(MajAjoutValeur);
                  end
                  else begin
                     FRegressiMain.WMRegMaj(MajValeur);
                     MajGraphe(MajValeur);
                  end;
           except
           end;
     end;
end end;

procedure TFValeurs.GridVariabExit(Sender: TObject);
begin
    if feuillets.activeTab<>VariabSheet then begin
       if gridVariab.editing then gridVariab.cancelEdit;
    end
end;

procedure TFValeurs.FeuilletsChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
     AllowChange := pageCourante<>0;
     if feuillets.ActiveTab=expSheet then begin
        if AllowChange and
           not compilationEnCours then majBtnClick(sender)
     end;
     if feuillets.ActiveTab=paramSheet then begin
        if gridParam.editing then GridParam.CancelEdit;
     end;
     if feuillets.ActiveTab=variabSheet then begin
        if gridVariab.editing then GridVariab.CancelEdit;
     end;
end;

procedure TFValeurs.FeuilletsChange(Sender: TObject);
begin
    if recompiler then compileP;
    if feuillets.ActiveTab=expSheet then begin
    end;
    if feuillets.ActiveTab=paramSheet then begin
       gridParam.enabled := (pageCourante>0) and
                            ((NbreConst+NbreParam)>0);
       traceGridParam;
    end;
    if feuillets.ActiveTab=variabSheet then begin
       gridVariab.enabled := pageCourante>0;
       traceGridVariab;
    end;
end;

procedure TFValeurs.PhaseItemClick(Sender: TObject);
var indexV : integer;
begin
     indexV := indexVariable(GridVariab.focusedCell.col);
     if (indexV=grandeurInconnue) or (indexV<0) or (indexV>=NbreGrandeurs) then exit;
     suppressionDlg := TSuppressionDlg.Create(self);
     SuppressionDlg.operation := oPhase;
     SuppressionDlg.nomDefaut := grandeurs[indexV].nom;
     centreForm(suppressionDlg);
     if SuppressionDlg.showModal=mrOK then traceGridVariab;
     suppressionDlg.free;
end;

procedure TFValeurs.ChangeAngle(isDegre : boolean);
var i : integer;
begin
       if AngleEnDegre=isDegre then exit;
       AngleEnDegre := isDegre;
       recalculE;
       for i := 0 to (NbreGrandeurs-1) do with grandeurs[i] do
           if fonct.genreC<>g_experimentale then setRadianDegre;
       TraceGridVariab;
       FRegressiMain.WMRegMaj(MajValeur);
end;

procedure TFValeurs.CollerItemClick(Sender: TObject);
begin
    Memo.PasteFromClipBoard;
end;

procedure TFValeurs.ListGrandeursChange(Sender: TObject);
var AText : string;
begin
     if ListGrandeurs.ItemIndex<0 then exit;
     Atext := ListGrandeurs.Items[ListGrandeurs.ItemIndex];
     ajouteStrMemo(atext,length(atext));
end;

procedure TFValeurs.LogBoxChange(Sender: TObject);
begin
     MajSimulation := true;
end;

procedure TFValeurs.FonctionBtnClick(Sender: TObject);
var syntaxe : string;
    code,i,l : integer;
begin
   syntaxe := (sender as TTreeViewItem).text;
   l := length(syntaxe);
   code := (sender as TTreeViewItem).tag;
   if code>0 then begin
      syntaxe := syntaxe +'(';
      inc(l);
   end;
   for i := 2 to code do syntaxe := syntaxe + ',';
   if code>0 then syntaxe := syntaxe + ')';
   ajouteStrMemo(syntaxe,l);
end;

procedure TFValeurs.GrecGridCellButtonClick(Sender: TObject; ACol,
  ARow: Integer; ACell: TTMSFNCGridCell);
var idx : integer;
    carac : char;
begin
     idx := acol + arow * GrecGrid.columnCount;
     if (idx < 0) or (idx > High(LettresGrecquesMin)) then exit;
     if isShift
        then carac := LettresGrecquesMaj[idx]
        else carac := LettresGrecquesMin[idx];
     ajouteStrMemo(carac,1);
end;

procedure TFValeurs.RazBtnClick(Sender: TObject);
begin
    if OKreg(OkDelAll,0) then begin
       pages[pageCourante].nmes := 0;
       FRegressiMain.WMRegMaj(MajAjoutValeur);
       traceGridVariab;
       ModifFichier := true;
    end;
end;

Procedure TFValeurs.SupprimeGrandeurCalc(anom : string);
var i,posN : integer;
    ligne : string;
begin
     for i := 0 to (memo.lines.count-1) do begin
         ligne := memo.lines[i];
         if (length(ligne)>1) and (ligne[1]<>'''') then begin
            posN := pos(anom,ligne);
            if (posN=1) and (length(ligne)>length(anom)) and (ligne[posN+length(anom)]='=') then begin
                memo.Lines.delete(i);
                CompileP;
                break;
            end;
         end;
     end;
end;

procedure TFValeurs.PassageEnRadian;
begin
      if angleEnDegre then if force
      then begin
         if prevenirPi then afficheErreur(erRadian,0);
         changeAngle(false);
         prevenirPi := false;
      end
      else if prevenirPi then begin
          if OKReg(erVerifRadian,0) then changeAngle(false);
          prevenirPi := false;
      end;
end;

Procedure TFValeurs.ResetListeGrandeurs;
var i : integer;
begin
     ListGrandeurs.clear;
     ListGrandeurs.Items.Add(grandeurs[cIndice].nom);
     ListGrandeurs.Items.Add('['+grandeurs[cIndice].nom+']');
     ListGrandeurs.Items.Add('['+grandeurs[cIndice].nom+'+1]');
     ListGrandeurs.Items.Add('['+grandeurs[cIndice].nom+'-1]');
     for i := 0 to (NbreGrandeurs-1) do
         ListGrandeurs.Items.Add(grandeurs[i].nom);
     if (modeAcquisition = AcqSimulation) then
         ListGrandeurs.Items.Add(grandeurs[cDeltat].nom);
     ListGrandeurs.Items.Add(grandeurs[cNombre].nom);
end;

procedure TFValeurs.ajouteStrMemo(aString : string;offset : integer);
var str : string;
    caret : TcaretPosition;
begin
   caret := Memo.caretPosition;
   if Memo.lines.count=0 then begin
      Memo.lines.add(aString);
      caret.line := 0;
      caret.pos := 0;
   end
   else begin
      if caret.line >= Memo.lines.count then caret.line := Memo.lines.count - 1;
      if caret.line < 0 then caret.line := 0;
      str := Memo.Lines[caret.line];
      str := str.Insert(caret.Pos,aString);
      Memo.Lines[caret.line] := str;
   end;
   if offset>0 then begin
      caret.pos := caret.pos+offset;
      memo.caretPosition := caret;
   end;
   Memo.setFocus;
end;

procedure TFValeurs.RadDegTabBtnClick(Sender: TObject);
begin
    if OKReg('Passage en '+captionAngle[not AngleEnDegre],0) then begin
       ChangeAngle(not AngleEnDegre);
       radDegTabBtn.ImageIndex := indexImageAngle[angleEnDegre];
       RadDegExpBtn.imageIndex := radDegTabBtn.ImageIndex;
       FRegressiMain.TrigoBtn.Text := captionAngle[angleEnDegre];
       FRegressiMain.TrigoBtn.hint := hintAngle[angleEnDegre];
    end;
end;

function TFValeurs.indexConstante(acol : integer) : integer;
begin
     result := grandeurInconnue;
     if acol<1 then exit;
     if DeltaItem.isChecked then acol := (acol+1) div 2;
     if (acol>=1) and (acol<=NbreConst)
        then result := indexConst[acol-1]
        else begin
             Acol := Acol-NbreConst;
             if (acol>=1) and (acol<=NbreParam) then
                result := ParamToIndex(acol);
        end;
end;

function TFValeurs.indexVariable(acol : integer) : integer;
begin
    result := grandeurInconnue;
    if acol<1 then exit;
    if DeltaItem.isChecked then acol := (acol+1) div 2;
    if (acol>=1) and (acol<=NbreVariab) then
       result := indexVariab[acol-1];
end;

function TFValeurs.VerifMinMax(Sender: TObject) : boolean;
var  N : integer;
label fin;
begin
     result := true;
     try
     with pages[pageCourante] do begin
        maxiSimulation := GetFloat(MaxiXEdit.text);
        miniSimulation := GetFloat(MiniXEdit.text);
        if (sender=NombreXSB) or MajSimulation then begin
            N := round( NombreXSB.value);
            if N<16 then N := 16;
            Nmes := N;
        end;
        if sender=MiniXEdit then begin
           valeurVar[0,0] := miniSimulation;
           if maxiSimulation<=miniSimulation
              then maxiSimulation := 2*miniSimulation;
           if maxiSimulation=miniSimulation
              then maxiSimulation := 1;
        end;
        if sender=MaxiXEdit then begin
           if maxiSimulation<=miniSimulation
              then miniSimulation := maxiSimulation/2;
           if maxiSimulation=miniSimulation
              then miniSimulation := -1;
           valeurVar[0,pred(Nmes)] := maxiSimulation-(maxiSimulation-miniSimulation)/nmes;
        end;
     end; // with pageCourante
     fin:
     MajSimulation := true;
     except
         result := false
     end;
end;

procedure TFValeurs.Remplit;
var p,Nbre : integer;
    MiniSimul,MaxiSimul : double;
begin
     compilationEnCours := true;
     Nbre := round( NombreXSB.value);
     try
     MiniSimul := GetFloat(MiniXEdit.Text);
     except
     MiniSimul := pages[pageCourante].valeurVar[0,0];
     end;
     try
     MaxiSimul := GetFloat(MaxiXEdit.Text);
     except
     MaxiSimul := pages[pageCourante].valeurVar[0,pred(pages[pageCourante].nmes)];
     MaxiSimul := MaxiSimul+(maxiSimul-miniSimul)/pred(pages[pageCourante].nmes);
     end;
     for p := 1 to NbrePages do with pages[p] do begin
           numero := p;
           nmes := Nbre;
           maxiSimulation := maxiSimul;
           miniSimulation := miniSimul;
     end;
     logSimulation := logBox.isChecked;
     MajSimulation := false;
     if recompiler
        then CompileP
        else begin
             for p := 1 to NbrePages do begin
                   pages[p].recalculP;
                   pages[p].changeAdresse := false;
             end;
             FRegressiMain.WMRegMaj(MajValeur);
        end;
     compilationEnCours := false;
     MajSimulation := false;
end;

procedure TFValeurs.AppelCoordonnees;
begin
if FCoordonneesPhys = nil then
        Application.CreateForm(TFcoordonneesPhys, FCoordonneesPhys);
with FcoordonneesPhys do begin
        agraphe := graphe;
        listeConst := false;
        modelePermis := false;
        centreForm(FcoordonneesPhys);
        if FcoordonneesPhys.ShowModal=mrOK then begin
           include(graphe.modif,gmXY);
           graphe.curseur := curSelect;
           graphe.etatModele := [];
           paintBox1.Repaint;
      end;
end end;

procedure TFValeurs.CoordonneesBtnClick(Sender: TObject);
begin
    AppelCoordonnees;
end;

procedure TFValeurs.AutoBtnClick(Sender: TObject);
begin with graphe do begin
     if not grapheOK then exit;
     include(modif,gmEchelle);
     monde[mondeX].defini := false;
     useDefaut := false;
     useDefautX := false;
     autoTick := true;
     paintBox1.repaint;
end end;

procedure TFValeurs.ZoomArrBtnClick(Sender: TObject);
begin
    if not graphe.grapheOK then exit;
    graphe.affecteZoomArriere;
    include(graphe.modif,gmEchelle);
    paintBox1.repaint;
end;

procedure TFValeurs.ZoomBtnClick(Sender: TObject);
begin
    if graphe.grapheOK then graphe.setPenBrush(curZoomAv);
end;

procedure TFValeurs.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    graphe.PaintBoxMouseDown(Sender,Button,Shift,X,Y);
end;

procedure TFValeurs.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
    graphe.PaintBoxMouseMove(Sender,Shift,X,Y);
end;

procedure TFValeurs.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    graphe.PaintBoxMouseUp(Sender,Button,Shift,X,Y);
end;

procedure TFValeurs.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
begin
    if pageCourante>0 then graphe.paintBoxPaint;
end;

procedure TFValeurs.Splitter1Paint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
begin with canvas do begin
      Fill.kind := TBrushKind.Solid;
      Fill.Color := claBlue;
      stroke.Color := claPurple;
      stroke.kind := TBrushKind.Solid;
      FillRect(Arect,0,0,[],1);
      Fill.kind := TBrushKind.None;
end end;

procedure TFValeurs.VarHelpBtnClick(Sender: TObject);
begin
    if Sender is TButton then
      ShowAide(TButton(Sender).HelpContext, True)
    else
      ShowAide(HELP_Valeurs, True);
end;

procedure TFValeurs.parHelpBtnClick(Sender: TObject);
begin
    if Sender is TButton then
      ShowAide(TButton(Sender).HelpContext, True)
    else
      ShowAide(HELP_Constantes, True);
end;

procedure TFValeurs.MajGraphe(typeMaj : integer);
begin
      if graphePanel.Width<largeurMinGrapheValeur then begin
         paintBox1.repaint;
         exit;
      end;
      include(graphe.Modif,gmXY); // le + général
      case TypeMaj of
          MajNom : graphe.MajNomGr;
          MajChangePage,MajAjoutPage,MajSupprPage : include(graphe.Modif,gmPage);
          MajSelectPage : graphe.modif := [gmXY,gmOptions];
          MajValeur,MajIncertitude,MajAjoutValeur : graphe.Modif := [gmValeurs];
          MajSupprPoints : graphe.Modif := [gmValeurs];
          else graphe.modif := [];
      end;
      if (graphe.Modif<>[]) then paintBox1.repaint;
end;

end.

