unit graphker;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.UIConsts,
  System.Math,
  System.Math.Vectors,
  System.Generics.Collections,

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
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Text,
  FMX.Platform,
  FMX.StdCtrls,
  FMX.TextLayout,
  FMX.Graphics,

  Xml.xmldom,
  Xml.XMLIntf,
  Xml.XMLDoc,

  compile,
  constreg,
  fft,
  maths,
  regutil,
  uniteker,
  modelenum,
  myShape;


const
  MaxOrdonnee   = 6;
  MaxMonde      = 10;
  indexLisse    = MaxIntervalles + 2;
  MondeVitesse  = 1;
  MondeAcc      = 2;
  NbreHarmoniqueAffMax = 32;
  maxCurseur = 2;
  couleurCurseurs: array[1..maxCurseur] of tAlphaColor = (claRed,claCrimson);
  LongueurTangente = 25;
  LargeurReticule = 3;

type
  indexCurseur = 1..maxCurseur;
  TreperePage     = (SPstyle, SPmotif, SPcouleur);
  Tmotif          = (mCroix, mCroixDiag, mCercle, mCarre, mLosange,
    mCerclePlein, mCarrePlein, mLosangePlein, mIncert, mHisto,
    mSpectre, mReticule, mBarreD, mBarreG, mLigneH);

// etoile, triangle, pentagone, asterisque, pentagonePlein, trianglePlein
  TetatModele     = (ModeleConstruit, ModeleLineaire, ModeleDefini,
                     SimulationDefinie, UniteParamDefinie, PasDeModele);
  setEtatModele   = set of TetatModele;
  indiceOrdonnee  = 1..MaxOrdonnee;
  Tcurseur        = (curSelect, curTexte, curLigne, curEfface,
    curReticule, curReticuleData, curOrigine, curZoomAv,
    curBornes, curMove, curEquivalence, curDebut, curFin, curDeplace,
    curFmaxi, curFmaxiSon);

const
  MargeCurseur     = 5;
  LongNombreAxe    = 5;
  NbreCouleur      = 17;
  mondeX           = 0;
  mondeY           = 1;
  mondeDroit       = 2;
  mondeSans        = 3;
  NbreGradMin      = 5;
  NbreGradMax      = 2 * NbreGradMin;
  NbreGradMaxMan   = 2 * NbreGradMax;
  coCadre          = 8;
  BrushCouleurSelect = claRed;
  CouleurAxeX        = claBlack;
  styleTangente      = TStrokeDash.Solid;
  NbreLigneDessin = 14;

var
  CouleurGrille:      TAlphaColor = claSilver;
  CouleurTexte:       TAlphaColor = claBlue;
  CouleurLigne:       TAlphaColor = claBlue;
  CouleurReticule:    TAlphaColor = claBlack;
  CouleurTangente:    TAlphaColor = claRed;
  FondReticule:       TAlphaColor = claBeige;

  OrdreLissage:       integer = 3;
  reperePage:         TReperePage = Spcouleur;
  UseFaussesCouleurs: boolean = True;
  DimPointVGA:        integer = 4; // dimension du point en pixel VGA
  PStyleReticule:     TStrokeDash = TStrokeDash.Solid;
  CouleurVitesseImposee: boolean = True;

  CouleurPages:     array[0..MaxPages] of  TAlphaColor =
   (claGray, claBlue, claRed, claOlive, claNavy, claPurple, claTeal, claGray,
    claBlack, claGreen, claBlue, claFuchsia, claAqua, claSilver, claBlue,
    claRed, claGray, claDarkCyan, claRed, claMagenta, claBlueViolet, claPurple,
    claTeal, claGray, claDimGray, claChartreuse, claBlue, claFuchsia, claAqua,
    claSilver, claSteelBlue, claChocolate, claRed);
  CouleurModele:    array[-MaxIntervalles..MaxIntervalles] of
  TAlphaColor = (claTeal, claMaroon, claNavy, claGray, claMagenta, claBlack,
                 claBlue, claRed, claGreen);
  CouleurMecanique: array[1..2] of TAlphaColor = (claBlue, claRed);
  PStylePages:      array[0..MaxPages] of
  TStrokeDash = (TStrokeDash.Solid, TStrokeDash.Dash, TStrokeDash.Dot,
    TStrokeDash.DashDot, TStrokeDash.DashDotDot, TStrokeDash.Solid,
    TStrokeDash.Dash, TStrokeDash.Dot, TStrokeDash.DashDot, TStrokeDash.DashDotDot,
    TStrokeDash.Solid, TStrokeDash.Dash, TStrokeDash.Dot, TStrokeDash.DashDot,
    TStrokeDash.DashDotDot, TStrokeDash.Solid, TStrokeDash.Solid,
    TStrokeDash.Dash, TStrokeDash.Dot, TStrokeDash.DashDot, TStrokeDash.DashDotDot,
    TStrokeDash.Solid, TStrokeDash.Dash, TStrokeDash.Dot, TStrokeDash.DashDot,
    TStrokeDash.DashDotDot, TStrokeDash.Solid, TStrokeDash.Dash, TStrokeDash.Dot,
    TStrokeDash.DashDot, TStrokeDash.DashDotDot, TStrokeDash.Solid, TStrokeDash.Dash);
  MotifPages:       array[0..MaxPages] of
  Tmotif = (mCroix, mCroixDiag, mCercle, mCarre, mLosange,
    mCerclePlein, mCarrePlein, mCroix, mCroixDiag, mCercle, mCarre,
    mLosange, mCerclePlein, mCarrePlein, mCroix, mCroixDiag, mCercle,
    mCroix, mCroixDiag, mCercle, mCarre, mLosange, mCerclePlein, mCarrePlein,
    mCroix, mCroixDiag, mCercle, mCarre, mLosange, mCerclePlein, mCarrePlein,
    mCroix, mCroixDiag);

  CouleurInit: array[indiceOrdonnee] of TAlphaColor =
     (claBlue, claRed, claGreen, claNavy, claPurple, claTeal);
  PStyleInit:  array[indiceOrdonnee] of
  TStrokeDash = (TStrokeDash.Solid, TStrokeDash.Solid, TStrokeDash.Solid,
     TStrokeDash.Solid,TStrokeDash.Solid,TStrokeDash.Solid);
  MotifInit:   array[indiceOrdonnee] of
  Tmotif = (mCroix, mCroixDiag, mCercle, mCarre, mLosange, mCerclePlein);
  NomCurseur:  array[curZoomAv..curBornes] of  string = ('Zoom', 'Bornes');

type
  Tidentification = (identNone, identAnimation, identRaie);
  TmodifGraphe       = (gmEchelle, gmOptions, gmXY, gmValeurs,
                        gmModele, gmPage, gmValeurModele);
  TselectLigne       = (sdNone, sdPoint1, sdPoint2, sdCentre);
  TmotifTexte        = (mtNone, mtCroix, mtFleche, mtVert, mtHoriz,
                        mtLigneRappel, mtDoubleFleche);
  TmotifLigne        = (mlNone, mlFlecheDebut, mlDoubleFleche, mlFlecheFin);
  TtexteLigne        = (tlNone, tlPente, tlEquation, tlEcartY, tlEcartX);
  TsetModifGraphe    = set of TmodifGraphe;
  ToptionGraphe      = (OgQuadrillage, OgPolaire, OgOrthonorme, OgMemeZero,
                        OgPseudo3D, OgAnalyseurLogique, OgMemeEchelle, OgZeroGradue);
  ToptionModele      = (OmEchelle, OmExtrapole);

  TsetOptionGraphe = set of ToptionGraphe;
  TsetOptionModele = set of ToptionModele;
  Ttrace           = (trLigne, trPoint, trResidus, trStat, trIntensite,
                      trVitesse, trAcceleration, trSonagramme, trIndicateur, trCouleursSpectre);

  TsetTrace        = set of Ttrace;
  Tligne           = (LiDroite, LiModele, LiSpline,LiSinc);
  indiceMonde      = mondeX..MaxMonde;
  TsetOptionCurseur = set of ToptionCurseur;

  TCoordonnee = record
    nomX, nomY:   string;
    codeX, codeY: integer;
    iMondeC:      indiceMonde;
    Trace:        TsetTrace;
    Ligne:        Tligne;
    couleur:      TAlphaColor;
    styleT:       TStrokeDash;
    Motif:        Tmotif;
  end;
  TListeY = array[indiceOrdonnee] of Tcoordonnee;

  TgrapheReg = class;

  TcurseurDonnees = class(TreticuleShape)
// 1 à 2 réticule
    public
    Pc:      TpointF;
    ic:      integer;
    numero: integer;
    xr, yr:  double;
    indexCourbe:     integer;
    mondeC:          indiceMonde;
    isData: boolean;
    graphe: TgrapheReg;
    procedure Paint; override;
    constructor CreateCurseur(Agraphe: TgrapheReg);
  end;

  TdessinText = class(Ttext)
    private
    x0,y0 : single;
    xReal,yReal : double;
    iMonde : indiceMonde;
    dataFile : boolean;
    isVertical,isCentre : boolean;
    public
    avecCadre: boolean;
    Agraphe : TgrapheReg;
    couleurFond : TAlphaColor;
    isOpaque : boolean;
    identification : Tidentification;
    constructor CreateText(gr : TgrapheReg);
    function LitOption : boolean;
    procedure Maj;
    procedure affecteXY(X,Y: single);
    procedure SetPourCent(var i: integer);
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton;
             Shift: TShiftState; X,Y: single);override;
    procedure MouseUp(Button: TMouseButton;
             Shift: TShiftState; X,Y: single);override;
    procedure MouseMove(
             Shift: TShiftState;X,Y: single);override;
    procedure MouseEnter;
    procedure MouseLeave;
    procedure DblClick; override;
    procedure LoadXML(ANode : IXMLNode);
    procedure StoreXML(ANode : IXMLNode);
  end;

  TdessinLine = class(TLine)
    private
    xReal,yReal : double;
    iMonde : indiceMonde;
    dataFile : boolean;
    public
    selection : TSelectLigne;
    motifLigne : TMotifLigne;
    texteLigne : TTexteLigne;
    DashLigne : TStrokeDash;
    Agraphe : TgrapheReg;
    procedure Paint; override;
    constructor CreateLine(gr : TgrapheReg);
    function LitOption : boolean;
    procedure Maj;
    procedure MouseDown(Button: TMouseButton;
             Shift: TShiftState; X,Y: single);override;
    procedure MouseUp(Button: TMouseButton;
             Shift: TShiftState; X,Y: single);override;
    procedure MouseEnter;
    procedure MouseLeave;
    procedure affectePoint1(X,Y: single);
    procedure affectePoint2(X,Y: single);
    procedure affecteXY(X,Y: single);
    procedure DblClick; override;
    procedure SetMoveDown(move : TMouseMoveEvent; down,up : TMouseEvent);
    procedure LoadXML(ANode : IXMLNode);
    procedure StoreXML(ANode : IXMLNode);
  end;

  TtamponTexteLigne = class
    x0,y0 : single;
    xReal,yReal : double;
    widthReal,heightReal : double; // à faire !
    layout: TTextLayout;
    iMonde : indiceMonde;
    avecCadre: boolean;
    Agraphe : TgrapheReg;
    couleurFond : TAlphaColor;
    color : TAlphaColor;
    vertTextAlign : TTextAlign;
    horzTextAlign : TTextAlign;
    autoSize : boolean;
    wordWrap : boolean;
    fontSize : integer;
    selection : TSelectLigne;
    motifLigne : TMotifLigne;
    texteLigne : TTexteLigne;
    DashLigne : TStrokeDash;
    Stroke : TStrokeBrush;
    strokeDash : TstrokeDash;
    textes : TstringList;
    isTitre : boolean;
    isOpaque : boolean;
    Souligne : Boolean;
    vertical : Boolean;
    centre  : Boolean;
    isTexte : Boolean;
    avecLigneRappel : Boolean;
    MotifTexte : TmotifTexte;
    numPoint,numPage : integer;
    hauteur : single;
    identification : TIdentification;
    procedure Load;
    constructor Create(gr : TgrapheReg);
    destructor Destroy; override;
  end;

  Tequivalence = class
    private
    pente: double;
    modelisee: boolean;
    varY: Tgrandeur;
    commentaire: string;
    aGraphe: TgrapheReg;
    couleur: TAlphaColor;
    index1,index2: integer;
    function TexteY : string;
    function TexteX : string;
    function TextePente : string;
    public
    x1,y1,x2,y2: double;
    ve, phe: double;
    mondepH: indiceMonde;
    LigneRappel: TSetLigneRappel;
    constructor CreateEq(v1, ph1, v2, ph2, v, ph, p: double; c: integer;gr : TgrapheReg);
    constructor Create(gr : TgrapheReg);
    procedure Paint;
    procedure SetValeurEquivalence(i: integer);
    Procedure modifDerivee(aGraphe : TgrapheReg);
    procedure Load;
    procedure Store;
    procedure LoadXML(ANode : IXMLNode);
    procedure StoreXML(ANode : IXMLNode);
  end;

  TlisteEquivalence = TList<TEquivalence>;

  Tpic = record
      valeurF,valeurH : double;
  end;

  TlistePic = class
      pics : array of Tpic;
      Nbre,NbreMax,index : integer;
      procedure Nettoie(fMax : double);
      procedure Tri;
      procedure Add(valF,valH : double);
      procedure removeLast;
      function proche(x,y : double;xmax,ymax : double) : integer;
      procedure Clear;
  end;

  Tmonde = class
    minDefaut, maxDefaut: double;
    mini, maxi:   double; // monde réel
    minInt,maxInt : single; // sur l'écran
    horizontal:   boolean;
    miniOrtho, maxiOrtho: double;
    MinidB:       double;
    a, b:         double; // écran = réel*a+b
    az,bz: double; // idem pour zoom
    Graduation:   Tgraduation;
    defini, zeroInclus, autoTick: boolean;
    Axe:          tgrandeur;
    deltaAxe, exposant, pointDebut: double;
    // deltaAxe = écart entre graduations sur les axes
    // Exposant=puissance de 10 multiple de 3
    Nticks, TickDebut: integer;
    // Nticks nombre de graduations sans valeur affichée 
    graduationPiActive: boolean;
    NbreChiffres: integer;
    TitreAxe: TstrListe;
    PTitre: TpointF;
    courbeBottom, courbeTop: single;
    formatDuree:  string;
    Arrondi:      double;
    Orthonorme, Polaire: boolean;
    constructor Create(aOwner : TpaintBox);
    procedure setDelta(grandAxe: boolean);
    procedure reset(IsPolaire: boolean);
    procedure affecteMinMax(x: double);
    procedure Trouve(V: vecteur; Debut, Fin: integer);
    function affecte(r: double): single;
    procedure setDefaut;
    function FormatMonde(x: double): string;
    destructor Destroy; override;
    procedure SetMinMaxDefaut(min, max: double);
  end;

  TmondeVecteur = class
    maxi:      double;
    ax, ay:    double; // entier = réel*a
    defini, vitesse, echelleTrace: boolean;
    Dimension: single;
    echelle:   double;
    MondeOrd:  indiceMonde;
    constructor Create;
    procedure Reset;
    procedure Trouve(Vx, Vy: vecteur; Nbre: integer);
    procedure GetEntier(x, y: double; var P : TpointF);
    procedure GetPolaire(r, teta, rp, tetap, rs, tetas: double; var x, y: double);
  end;

  TCourbe = class
    valX, valY, incertX, incertY: vecteur;
    valXder, valYder, valXder2, valYder2: vecteur;
    trace:       TsetTrace;
    DebutC:      integer;
    FinC:        integer;
    iMondeC:     indiceMonde;
    varX, varY:  tGrandeur;
    varXder, varYder: tGrandeur;
    varDer:      array[1..2] of tGrandeur; // vitesse accélération
    Couleur:     TAlphaColor;
    StyleT:      TStrokeDash;
    Motif:       Tmotif;
    IndexModele: integer;
    Adetruire, DetruireIncert, CourbeExp, PortraitDePhase,
    ModeleParametrique, ModeleParamX1: boolean;
    Page:        integer;
    valeurEff, valeurMoy, valeurMin, valeurMax: double;
    periode:     double;
    decalage:    single;
    PointSelect: set of byte;
    traceFin : boolean;
    optionLigne : TLigne;
    constructor Create(AX, AY: vecteur; D, F: integer;
      VX, VY: tgrandeur);
    procedure setStyle(Acouleur: TAlphaColor; Astyle: TStrokeDash; Amotif: Tmotif);
    procedure calcul;
    destructor Destroy; override;
  end;

  TTitreAxeY = record
    Texte: string;
    Couleur: TAlphaColor;
    Monde: indiceMonde;
    Largeur: single;
    Hauteur: single;
  end;

  TgrapheReg = class
    canvas:        Tcanvas;
    zoneClipBoard: Trectangle;
    paintBox:      TpaintBox;
    coordonnee:    TlisteY;
    dimPoint:      single;
    avecAxeX, avecAxeY: boolean;
    grandAxeX, grandAxeY: boolean;
    superposePage, empilePage: boolean;
    mondeDebut:    indiceMonde;
    mondeDerivee:  indiceMonde;
    monde:         array[indiceMonde] of Tmonde;
    mondeVecteur:  array[1..2] of TmondeVecteur;
    courbes:       Tlist<TCourbe>;
    DessinTexts:   Tlist<TDessinText>;
    DessinLines:   Tlist<TDessinLine>;
    LimiteCourbe, LimiteFenetre: TrectF;
    BorneFenetre: TrectF;
    LargCarac, HautCarac, Marge: single;
    CurseurOsc:  array[indexCurseur] of TcurseurDonnees;
    CurseurCourant : integer;
    optionCurseur:   TsetOptionCurseur;
    CurseurDebut:  TpointF;
    UnitePente:    Tunite;
    curseur : Tcurseur;
    grapheOK, verifierOrtho: boolean;
    modif:         TsetModifGraphe;
    OptionGraphe:  TsetOptionGraphe;
    OptionModele:  TsetOptionModele;
    AutoTick, useDefaut, useDefautX, GraduationZeroX, GraduationZeroY : boolean;
    NbreOrdonnee:  integer;
    penWidth:      single;
    MiniTemps, MaxiTemps: double;
    PasPoint:      integer;
    margeCaracY:   single;
    UnAxeX:        boolean;
    miniMod, maxiMod: double;
    indexHisto:    integer;
    DessinTextCourant : TdessinText;
    DessinLineCourant : TdessinLine;
    indexPointCourant : integer;

    TitresY: TList<TTitreAxeY>;
    FSonagrammeBitmap: TBitmap;
    FSonaNbreX, FSonaNbreY: integer;
    FSonaDecadeDB: integer;
    FSonaFaussesCouleurs: boolean;
    FSonaPage: integer;
    FSonaChecksum: double;
    ReticuleOrigine : TreticuleShape;
    Selection : TRectSelect;
    layout: TTextLayout;
    LineEcartX,LineEcartY : TLine;

    Equivalences:  array[codePage] of TlisteEquivalence;
    EquivalenceCourante: Tequivalence;
    indexCourbeEquivalence : integer;

    constructor Create(apaintBox : TPaintBox);
    procedure Draw;
    procedure TraceCourbe(index: integer);
    procedure Reset;
    procedure WindowXY(xr, yr: double; m: indiceMonde; var P: TPointF);
    procedure WindowRT(xr, yr: double; m: indiceMonde; var P: TPointF);
    procedure RTversXY(var xr, yr: double; m: indiceMonde);
    function WindowX(xr: double): single;
    function WindowY(yr: double;m : indiceMonde): single;
    procedure MondeXY(Pint: TPointF; m: indiceMonde; var xr, yr: double);
    procedure MondeRT(Pint: TPointF; m: indiceMonde; var xr, yr: double);
    procedure ChercheMonde;
    procedure SetMonde(m: indiceMonde; minX, minY, maxX, maxY: double);
    procedure AjoutePoint(m: indiceMonde; XX, YY: double);
    procedure DrawAxis(initialisation: boolean);
    procedure TraceTitreAxeY(g: Tgrandeur; m: indiceMonde;indexCourbe: integer);
    procedure DrawTitresAxeY;
    procedure TraceTitreAxeX(g: Tgrandeur;indexCourbe: integer);
    procedure VersImprimante(var Bas: single);
    procedure VersPressePapier;
    procedure ChercheDroite(x, y, pente: double; m: indiceMonde;var P1,P2: TpointF);
    destructor Destroy; override;
    procedure AffecteZoomAvant(avecY: boolean);
    procedure AffecteZoomGesture(const EventInfo: TGestureEventInfo);
    procedure AffecteZoomArriere;
    procedure TraceMotif(P:TpointF; motif: Tmotif);
    procedure GetCurseurProche(P:TpointF; force: boolean);
    function InitReticule : boolean;
    procedure SetSegmentInt(P:TPointF);
    function PointProche(var P: TpointF; indexCourbe: integer;
      limite, Xseul: boolean): integer;
    function PointProcheGrandeur(var P: TpointF;var indexCourbe : integer;var aMonde: indiceMonde): integer;
    function MondeProche(P:TPointF): indiceMonde;
    function CourbeProche(var P:TpointF): integer;
    function CourbeModeleProche(var P:TpointF): integer;
    function PointProcheReal(x, y: double; Acourbe: Tcourbe;
      m: indiceMonde): integer;
    function isAxeX(P:TpointF): boolean;
    function AjouteCourbe(AX, AY: vecteur; Am: indiceMonde;
      Nbre: integer; grandeurX, grandeurY: Tgrandeur;
      Apage: integer): Tcourbe;
    procedure LineGr(Arect: TrectF);
    procedure MajDessins;
    procedure MajNomGr;
    function AjusteMonde: boolean;
    procedure SetUnitePente(iMonde: indiceMonde);
    procedure chercheMinMax;
    procedure changeEchelleX(xnew, xold: single);
    procedure CreateSolidBrush(couleur : TAlphaColor);
    procedure CreatePen(aStyle : TStrokeDash;aWidth  : single;couleur : TAlphaColor);
    procedure SetTextAlign(alH,alV : TTextAlign);  //    taCenter, taLeading, taTrailing
    procedure MyDrawText(P : TpointF;S : string);
    procedure MyDrawRect(arect : TrectF);
    procedure MyDrawRectXY(x1,y1,x2,y2 : single);
    procedure MyDrawEllipse(x1,y1,x2,y2 : single);
    procedure MyFillText(P : TpointF;S : string;couleurFond : TAlphaColor);
    procedure MyFillRect(arect : TrectF);
    procedure MyFillRectXY(x1,y1,x2,y2 : single);
    procedure MyFillEllipse(x1,y1,x2,y2 : single);
    procedure setFontSize(asize : single);
    procedure Segment(P1, P2: TpointF);
    procedure SegmentXY(x1,y1,x2,y2: single);
    procedure ResetEquivalence;
    Procedure AjouteEquivalence(i : integer;effaceDouble : boolean);
    procedure traceUneCourbe(xvecteur,yvecteur : vecteur;N,Neq : integer;aColor : TAlphaColor);
    procedure NotifyText(sender:TObject;const item : TDessinText;action : TCollectionNotification);
    procedure NotifyLine(sender:TObject;const item : TDessinLine;action : TCollectionNotification);
  end;

  TtransfertGraphe = class
    Grad:       array[indiceMonde] of Tgraduation;
    Zero:       array[indiceMonde] of boolean;
    MinidB:     array[indiceMonde] of double;
    Trace:      array[indiceOrdonnee] of TsetTrace;
    Ligne:      array[indiceOrdonnee] of Tligne;
    nomX, nomY: array[indiceOrdonnee] of string;
    iMonde:     array[indiceOrdonnee] of indiceMonde;
    Couleur:    array[indiceOrdonnee] of TAlphaColor;
    Style:      array[indiceOrdonnee] of TStrokeDash;
    Motif:      array[indiceOrdonnee] of Tmotif;
    optionGr:   TsetOptionGraphe;
    optionModele:  TsetOptionModele;
    SuperPage:  boolean;
    UseDefaut, UseDefautX: boolean;
    PasPoint:   integer;
    AutoTick:   boolean;
    nbreCourbes: integer;
    agraphe: TgrapheReg;
    procedure AssignEntree;
    procedure AssignSortie;
    Procedure Ecrit(numero : integer);
    Procedure Lit;
    constructor Create;
  end;

function GetFausseCouleur(Niveau: double): TAlphaColor; // Niveau entre 0 et 1
function GetCouleurPages(index: integer): TAlphaColor;
function GetCouleurPale(color1: TAlphaColor): TAlphaColor;

var
  tailleEcran : single;
  NbrePointsMax : integer;
  NbreVecteurVitesseMax: integer = 32;
  EchelleVecteur:     double = 0.06;
  ProlongeVecteur:  boolean = False;
  ProjeteVecteur:  boolean = False;
  DecadeDB:        integer = 2;
  UseSelect:          boolean = False;
  DecalageFFT:        single = 2;
  PrecisionFFT:       single = 0.02;
  CoeffDecalage:      single = 1;
  OptionGrapheDefault: TsetOptionGraphe = [];
  verifierLog:        boolean = False;
  penWidthEcran:      single = 3;
  etatModele : setEtatModele;

implementation

uses lectText, optLine, options, valeurs;

function GetCouleurPale(color1: TAlphaColor): TAlphaColor;
const decale = 96;
      minC = 255-decale;
var r,g,b : System.byte;

function getDecale(aByte : byte) : byte;
begin
    if aByte<minC then result := aByte + decale else result := 255;
end;

begin
       r := getDecale(TAlphaColorRec(Color1).R);
       g := getDecale(TAlphaColorRec(Color1).G);
       b := getDecale(TAlphaColorRec(Color1).B);
       result := MakeColor(r,g,b);
end;

function GetFausseCouleur(Niveau: double): TAlphaColor; { Niveau entre 0 et 1 }

// BLEU bleu 255 vert 0 rouge 0  = 0
// bleu 255 vert augmente rouge 0
// bleu 255 vert 255 rouge 0 =0.25
// bleu diminue vert 255 rouge 0 
// VERT bleu 0 vert 255 rouge 0 =0.5
// bleu 0 vert 255 rouge augmente
// bleu 0 vert 255 rouge 255 =0.75
// bleu 0 vert diminue rouge 255
// ROUGE bleu 0 vert 0 rouge 255=1

// bleu 1/4 => 1 1/2 => 0
// rouge 1/2 => 0 3.4 => 1
// vert 0 => 0 1/4 => 1
// vert 3/4 => 1 1 => 0

  function C(valeurR: double): integer;
  begin
    Result := round(255 * valeurR);
    if Result < 0
       then Result := 0
       else if Result > 255
          then Result := 255;
  end;

var
  R, G, B: integer;
begin
  if niveau < 0 then niveau := 0;
  if niveau > 1 then niveau := 1;
  B := C(2 - 4 * niveau);
  if niveau < 0.5
     then G := C(4 * niveau)
     else G := C(4 - 4 * niveau);
  R := C(4 * niveau - 2);
  Result := MakeColor(R, G, B);
end; //  GetFausseCouleur

(*
    Aliceblue
    Antiquewhite
    Aqua, Aquamarine,  Azure
    Beige,  Bisque, Black
    Blanchedalmond
    Blue,   Blueviolet
    Brown,  Burlywood
    Cadetblue, Chartreuse, Chocolate
    Coral, Cornflowerblue
    Cornsilk, Crimson, Cyan
    Darkblue, Darkcyan, Darkgoldenrod, Darkgray
    Darkgreen, Darkgrey, Darkkhaki,  Darkmagenta
    Darkolivegreen, Darkorange, Darkorchid, Darkred
    Darksalmon,  Darkseagreen,  Darkslateblue, Darkslategray
    Darkslategrey, Darkturquoise,  Darkviolet
    Deeppink, Deepskyblue
    Dimgray, Dimgrey, Dodgerblue
    Firebrick,  Floralwhite,   Forestgreen
    Fuchsia, Gainsboro
    Ghostwhite,  Gold, Goldenrod
    Gray
    Green, Greenyellow, Grey
    Honeydew, Hotpink, Indianred
    Indigo,  Ivory, Khaki
    Lavender, Lavenderblush, Lawngreen
    Lemonchiffon,
    Lightblue,  Lightcoral, Lightcyan
    Lightgoldenrodyellow,  Lightgray, Lightgreen
    Lightgrey, Lightpink, Lightsalmon, Lightseagreen
    Lightskyblue, Lightslategray, Lightslategrey, Lightsteelblue =
    Lightyellow
    LtGray, MedGray, DkGray
    MoneyGreen, LegacySkyBlue
    Cream, Lime
*)

procedure TgrapheReg.Segment(P1,P2: TpointF);
begin
   canvas.DrawLine(P1, P2,1)
end;

procedure TgrapheReg.SegmentXY(x1,y1,x2,y2: single);
begin
   segment(TpointF.create(x1,y1),TpointF.create(x2,y2))
end;

destructor Tmonde.Destroy;
begin
  TitreAxe.Free;
  inherited Destroy;
end;

constructor Tmonde.Create;
begin
  inherited Create;
  MinidB := 1e-6; // -120 dB / 1 V
  Axe := nil;
  ZeroInclus := True;
  horizontal := False;
  MinDefaut := 0;
  MaxDefaut := 1;
  Orthonorme := False;
  Graduation := gLin;
  TitreAxe := TstrListe.Create;
  Ptitre := TpointF.Create(0,0);
  a := 1;
  reset(False);
end; // Tmonde.Create

procedure Tmonde.AffecteMinMax(x: double);
begin
  if x > Maxi
    then Maxi := x
    else if x < Mini
       then Mini := x;
end;

procedure Tmonde.SetDefaut;
begin
  if isNan(mini) then begin
    mini := 1;
    maxi := 2;
  end;
  case Graduation of
      gLog: if (maxi - mini) < 0.1 then Maxi := Mini + 1;  // 1 décade
      gdB:  if (maxi - mini) < 1 then Maxi  := Mini + 20; // 20 dB
      gLin:  if (maxi - mini) < 1E-30 then Maxi := Mini + 1; // mini = masse d'un proton
 end;
end;

procedure Tmonde.Trouve(V: vecteur; Debut, Fin: integer);
var
  VariabMin, VariabMax: double;
  Ajuste: boolean;
  margeR: double;
begin
  if debut > fin then exit;
  MaxiMini(V, variabMax, variabMin, Debut, Fin);
  if (graduation in [gLog,gdB]) and
     (variabMin < 1E-12) then begin
    Graduation  := gLin;
    verifierLog := True;
  end;
  Ajuste := False;
  case Graduation of
    gLog: begin
      if isNan(Mini) or (Log10(variabMin) < Mini) then
        Mini := Log10(variabMin);
      if (Mini - floor(Mini)) < 0.1 then
        Mini := floor(Mini) - 0.05;
      if isNan(Maxi) or (Log10(variabMax) > Maxi) then
        Maxi := Log10(variabMax);
      if (ceil(Maxi) - Maxi) < 0.1 then
        Maxi := ceil(Maxi) + 0.05;
    end;
    gdB: begin
      if (variabMin < minidB) then
        variabMin := minidB;
      if 20 * Log10(variabMin) < Mini then
        Mini := Log10(variabMin) * 20;
      if (variabMax < minidB) then
        variabMax := minidB * 100;
      if 20 * Log10(variabMax) > Maxi then
        Maxi := Log10(variabMax) * 20;
      if Mini < (Maxi - 120) then
        Mini := Maxi - 120;
    end;
    gLin: begin
      if isNan(Mini) or (variabMin < Mini) then begin
        Mini := variabMin;
        ajuste := True;
      end;
      if isNan(Maxi) or (variabMax > Maxi) then begin
        Maxi := variabMax;
        ajuste := True;
      end;
    end;
  end;
  if ajuste then begin
    margeR := (maxi - mini) / 25;
    if maxi > 0
       then maxi := maxi + margeR
       else begin
          maxi := maxi + margeR;
          if maxi > 0 then maxi := 0;
       end;
    if mini >= 0
       then begin
         mini := mini - margeR;
         if mini < 0 then mini := 0;
       end
       else mini := mini - margeR;
  end;
end; // Tmonde.Trouve

procedure Tmonde.SetMinMaxDefaut(min, max: double);
begin
  VerifMinMaxReal(Min, Max);
  MinDefaut := Min;
  MaxDefaut := Max;
  case Graduation of
    gLog: begin
      if MinDefaut<1e-12 then MinDefaut := 1;
      if MaxDefaut<MinDefaut then MaxDefaut := MinDefaut*100;
      try
        Mini := Log10(MinDefaut);
        Maxi := Log10(MaxDefaut);
      except
        MaxDefaut := 100;
        Maxi := 2;
        MinDefaut := 1;
        Mini := 0;
      end;
      zeroInclus := False;
    end;
    gdB: begin
      if MinDefaut<1e-12 then MinDefaut := 1;
      if MaxDefaut<MinDefaut then MaxDefaut := MinDefaut*100;
      try
        Mini := Log10(MinDefaut) * 20;
        Maxi := Log10(MaxDefaut) * 20;
        zeroInclus := False;
      except
        MaxDefaut := 100;
        Maxi := 40;
        MinDefaut := 1;
        Mini := 0;
      end;
    end;
    gLin: begin
      Maxi := MaxDefaut;
      Mini := MinDefaut;
      zeroInclus := mini * maxi <= 0;
    end;
  end;
end;

procedure Tmonde.Reset(isPolaire : boolean);
begin
  graduationPiActive := False;
  defini := False;
  autoTick := True;
  orthonorme := False;
  arrondi := 1;
  exposant := 1;
  a := 1;
  b := 0;
  polaire := isPolaire;
  if isPolaire then begin
    ZeroInclus := True;
  end;
  if Graduation <> gLin then
    ZeroInclus := False;
  if (axe <> nil) and (axe.formatU in [fDateTime, fDate, fTime]) then
    zeroInclus := False;
  if zeroInclus then begin
    Maxi := 0;
    Mini := 0;
  end
  else begin
    Maxi := nan;
    Mini := nan;
  end;
end; //  Tmonde.Reset

function Tmonde.affecte(r: double): single;
begin
  if isNan(r) then
    Result := -1
  else begin
    try
      Result := A * r + B;
      if (result>maxInt) or (result<minInt) then
         result := -1;
    except
      Result := -1
    end;
  end;
end;

constructor TmondeVecteur.Create;
begin
  inherited Create;
  defini  := False;
  vitesse := True;
  MondeOrd := mondeY;
end;

const
  Nbre125: array[1..3] of integer = (1, 2, 5);

procedure TmondeVecteur.Trouve(Vx, Vy: vecteur; Nbre: integer);

  procedure SetDelta;
  const
    indexMax = 4;
    coeff: array[0..indexMax] of double = (10, 5, 2, 1, 0.5);
  var
    largeur: double;
    Exponent, index: integer;
  begin
    Exponent := floor(Log10(Maxi));
    largeur := maxi * dix(-exponent);
    index := 0;
    while (largeur < coeff[index]) and (index < indexMax) do
      Inc(index);
    Echelle := coeff[index] * dix(exponent);
  end; // setDelta

var
  j: integer;
begin
  if (Vx = nil) or (Vy = nil) or (Nbre < 3) then
    exit;
  for j := 0 to pred(Nbre) do begin
    if isNan(vx[j]) or  isNan(vy[j]) then continue;
    if abs(vx[j]) > maxi then
      maxi := abs(vx[j]);
    if abs(vy[j]) > maxi then
      maxi := abs(vy[j]);
  end;
  Defini := maxi > 0;
  if defini then setDelta;
end;

procedure TmondeVecteur.Reset;
begin
  defini := False;
  Ax := 0;
  Ay := 0;
  maxi := 0;
  echelleTrace := False;
end;

procedure TmondeVecteur.getEntier(x, y: double; var P: TpointF);
begin
  if isNan(x) then
    P.x := -1
    else
    try
      P.x := round(Ax * x);
    except
      P.x := -1
    end;
  if isNan(y) then
    P.y := -1
  else
    try
      P.y := round(Ay * y);
    except
      P.y := -1
    end;
end;

procedure TmondeVecteur.GetPolaire(r, teta, rp, tetap, rs, tetas: double; var x, y: double);
var
  ar, ateta: double;
begin
  if vitesse then begin
    ar := rp;
    ateta := r * tetap;
  end
  else begin
    ar := rs - r * sqr(tetap);
    ateta := 2 * rp * tetap + r * tetas;
  end;
  x := ar * cos(teta) - ateta * sin(teta);
  y := ar * sin(teta) + ateta * cos(teta);
end;

procedure TGrapheReg.MondeXY(Pint: TPointF; m: indiceMonde; var xr, yr: double);
begin
  xr := (Pint.x - monde[mondeX].B) / monde[mondeX].A;
  yr := (Pint.y - monde[m].B) / monde[m].A;
end;

function GetCouleurPages(index: integer): TAlphaColor;
begin
    index  := index mod MaxPages;
    Result := couleurPages[index];
    if Result = claWhite then begin
      couleurPages[index] := claBlack;
      Result := claBlack;
  end;
end;

procedure TGrapheReg.MondeRT(Pint: TPointF; m: indiceMonde; var xr, yr: double);
var
  rayon, angle: double;
begin
  mondeXY(Pint, m, xr, yr);
  case monde[mondeX].graduation of
    gLog: xr := power(10,xr);
    gdB: xr  := power(10,xr/20);
  end;
  case monde[m].graduation of
    gLog: yr := power(10,yr);
    gdB: yr  := power(10,yr/20);
  end;
  if OgPolaire in OptionGraphe then begin
    angle := atan2(yr, xr);
    rayon := sqrt(xr * xr + yr * yr);
    xr := angle;
    yr := rayon;
  end;
end;

procedure TGrapheReg.VersImprimante(var bas: single);
var
  margeI, hauteur: single;
  SourceRect,DestRect : TRectF;
  coeff,haut : single;
  abitmap : Tbitmap;
begin
  aBitmap := ZoneClipBoard.MakeScreenshot;
  try
  margeI := printerParam.margeTexte;
  coeff := printer.PageWidth/paintBox.Width;
  hauteur := paintBox.Height*coeff;
  haut := bas + margeI;
  bas := haut + hauteur;
  if bas > Printer.PageHeight then begin
      Printer.NewPage;
      haut := margeI;
      bas := haut + hauteur;
  end;
  SourceRect.Create(0, 0, aBitmap.width, aBitmap.height);
  DestRect.Create(0, haut, aBitmap.width*coeff, bas);
  printer.Canvas.DrawBitmap(abitmap, SourceRect,DestRect,1);
  aBitmap.Free;
  except
    AfficheErreur(erPbImprimante,0)
  end;
end;

procedure TGrapheReg.RTversXY(var xr, yr: double; m: indiceMonde);
var
  angle: double;
begin
  if OgPolaire in OptionGraphe then
    if isNan(yr) then begin
      xr := 0;
      yr := 0;
    end
    else begin
      angle := xr;
      AngleEnRadian(angle);
      xr := yr * cos(angle);
      yr := yr * sin(angle);
    end
  else begin // non polaire
    case monde[mondeX].graduation of
      gLog: xr := Log10(xr);
    end;
    case monde[m].graduation of
      gLog: yr := Log10(yr);
      gdB: if yr < monde[m].minidB
         then yr := 20 * log10(monde[m].minidB)
         else yr := 20 * Log10(yr);
    end;
  end;
end;

procedure TGrapheReg.WindowRT(xr, yr: double; m: indiceMonde; var P: TpointF);
// raisonne suivant type de coordonnee
begin
  RTversXY(xr, yr, m);
  P.x := monde[mondeX].affecte(xr);
  P.y := monde[m].affecte(yr);
end; // windowRT

procedure TGrapheReg.WindowXY(xr, yr: double; m: indiceMonde; var P: TpointF);
begin
  P.y := monde[m].affecte(yr);
  P.x := monde[mondeX].affecte(xr);
end;

procedure TGrapheReg.ChercheMonde;

  procedure FindWorld(m: indiceMonde; XX, YY: vecteur; Debut, Fin: integer);

    procedure worldPolaire;
    var
      j: integer;
      angle, rayon: double;
    begin
      for j := Debut to Fin do begin
        angle := XX[j];
        rayon := YY[j];
        angleEnRadian(angle);
        monde[mondeX].affecteMinMax(rayon * cos(angle));
        monde[m].affecteMinMax(rayon * sin(angle));
      end;
    end; // worldPolaire

  begin // findworld
    if OgPolaire in OptionGraphe
       then worldPolaire
       else begin
            monde[mondeX].Trouve(XX, debut, fin);
            monde[m].Trouve(YY, debut, fin);
       end;
  end; // findworld

  procedure chercheProjectionY(m: indiceMonde);

    procedure ajusteOrthonorme;
    var rapport: double;
    begin
      if not (OgPolaire in OptionGraphe) and (monde[m].axe <> nil) and
        (monde[m].axe.nomUnite <> '') and (monde[mondeX].axe <> nil) and
        (monde[mondeX].axe.nomUnite <> '') then
        verifierOrtho := verifierOrtho or
          (monde[m].axe.nomUnite <> monde[mondeX].axe.nomUnite) or
          (monde[m].graduation <> gLin) or
          (monde[mondeX].graduation <> gLin);
      rapport := abs(monde[mondeX].a/monde[m].a);
      verifierOrtho := verifierOrtho or
        (((rapport > 100) or (rapport < 0.01)));
      if rapport > 1.002 then with monde[mondeX] do begin
          b := b + (maxi + mini) / 2 * (a - abs(monde[m].a));
          // On conserve le milieu
          a := -monde[m].a;
          miniOrtho := (limiteCourbe.left - b) / a;
          maxiOrtho := (limiteCourbe.right - b) / a;
          orthonorme := True;
          setDelta(grandAxeX);
      end;
      if rapport < 0.998 then with monde[m] do begin
          b := b + (maxi + mini) / 2 * (a + monde[mondeX].a);
          // On conserve le milieu
          a := -monde[mondeX].a;
          maxiOrtho := (CourbeTop - b) / a;
          miniOrtho  := (CourbeBottom - b) / a;
          orthonorme := True;
      end;
    end; // ajusteOrthonorme

  begin with monde[m] do begin
      case Graduation of
         gLog:  if (maxi - mini) < 0.1 then Maxi := Mini + 1;  // 1 décade
         gdB:  if (maxi - mini) < 1 then Maxi  := Mini + 20; // 20 dB
         gLin:  begin
            if (maxi - mini) < 1E-30 then Maxi := Mini + 1;  // limite = masse d'un proton = 1e-27
            if abs(Mini) < (Maxi - Mini) * 1e-2 then Mini := 0;
         end;
      end;
      A := (CourbeTop - CourbeBottom) / (Maxi - Mini);
      b := CourbeBottom - Mini * a;
      maxiOrtho := maxi;
      miniOrtho := mini;
      if (OgPolaire in OptionGraphe) or (OgOrthonorme in OptionGraphe) then
         ajusteOrthonorme;
      setDelta(grandAxeY);
  end end; // chercheProjectionY

  procedure chercheProjectionX;
  begin with monde[mondeX] do begin
      if abs(Mini) < (Maxi - Mini) * 1e-2 then Mini := 0;
      if (Maxi - Mini)<1E-9 then Maxi := Mini + 1e-6;
      if (axe <> nil) and (axe.formatU in [fDateTime, fDate, fTime]) then
        zeroInclus := False;
      A := (limiteCourbe.right - limiteCourbe.left) / (Maxi - Mini);
      B := limiteCourbe.left - Mini * A;
      maxiOrtho := maxi;
      miniOrtho := mini;
      setDelta(grandAxeX);
    end;
  end;

  procedure AjusteZero;

    procedure ajusteYNeg(m: indiceMonde; NouveauZero: single);
    begin with monde[m] do begin
        b := NouveauZero;
        if (a * Mini + b) > CourbeBottom then
          a := (CourbeBottom - b) / Mini;
        if (a * Maxi + b) < CourbeTop then
          a := (CourbeTop - b) / Maxi;
        mini := (CourbeBottom - b) / a;
        maxi := (CourbeTop - b) / a;
      end;
    end;

    procedure ajusteYPos(m: indiceMonde; NouveauZero: single);
    begin with monde[m] do begin
        b := NouveauZero;
        if (a * Mini + b) < CourbeBottom then
          a := (CourbeBottom - b) / Mini;
        if (a * Maxi + b) > CourbeTop then
          a := (CourbeTop - b) / Maxi;
        mini := (CourbeBottom - b) / a;
        maxi := (CourbeTop - b) / a;
      end;
    end;

  var
    m: indiceMonde;
    z, z1, zMilieu: single;
    n : integer;
  begin // ajusteZero
    n := 0;
    z := 0;
    for m := mondeY to high(indiceMonde) do with monde[m] do
        if defini and (graduation = gLin) then begin
          z1 := round(b);
            if z1 < CourbeTop then
              z1 := CourbeTop;
            if z1 > CourbeBottom then
              z1 := CourbeBottom;
          z := z + z1;
          inc(n);
        end;
    if n < 2 then exit;
    z := z/n;
    // On prend le zéro moyen
    with monde[mondeY] do
      zMilieu := (courbeTop + CourbeBottom)/2;
    for m := mondeY to high(indiceMonde) do with monde[m] do
        if defini and (graduation = gLin) and
          (abs(b - zMilieu) < abs(z - zMilieu)) then
          z := round(b);
    // On prend le zéro le plus proche du centre
    for m := mondeY to high(indiceMonde) do with monde[m] do
        if defini and (graduation = gLin) then ajusteYNeg(m, z);
  end; // ajusteZero

  procedure ChercheMondeVecteur;
  var
    i, j, indexXvar, indexXder, indexYder, m: integer;
    xx, yy: vecteur;
  begin
    for m := 1 to 2 do
        mondeVecteur[m].reset;
    for i := 0 to pred(courbes.Count) do
      with courbes[i] do begin
        if (trVitesse in trace) then begin
          try
            indexXvar := varX.indexG;
            indexXder := indexVitesse(varX.nom);
            indexYder := indexVitesse(varY.nom);
            varder[mondeVitesse] := grandeurs[indexXder];
            if pages[page].valeurVar[indexXvar] = valX then begin
               valXder := pages[page].valeurVar[indexXder];
               valYder := pages[page].valeurVar[indexYder];
            end
            else begin
               valXder := pages[page].valeurLisse[indexXder];
               valYder := pages[page].valeurLisse[indexYder];
            end;
            if OgPolaire in OptionGraphe then begin
               setLength(xx, pages[page].nmes);
               for j := 0 to pred(pages[page].nmes) do
                   xx[j] := valXder[j] * valY[j];// r d(teta)/dt
               mondeVecteur[MondeVitesse].trouve(xx, valYder, pages[page].nmes);
               xx := nil;
            end
            else
               mondeVecteur[MondeVitesse].trouve(valXder, valYder, pages[page].nmes);
            mondeVecteur[MondeVitesse].mondeOrd := iMondeC;
          except
            exclude(trace, trVitesse);
          end;
        end; // vitesse
        if trAcceleration in trace then begin
          try
            indexXvar := varX.indexG;
            indexXder := indexAcceleration(varX.nom);
            indexYder := indexAcceleration(varY.nom);
            varDer[mondeAcc] := grandeurs[indexXder];
            if pages[page].valeurVar[indexXvar] = valX then begin
               valXder2 := pages[page].valeurVar[indexXder];
               valYder2 := pages[page].valeurVar[indexYder];
            end
            else begin
               valXder2 := pages[page].valeurLisse[indexXder];
               valYder2 := pages[page].valeurLisse[indexYder];
            end;
            if OgPolaire in OptionGraphe then begin
              setLength(xx, pages[page].nmes);
              setLength(yy, pages[page].nmes);
              for j := 0 to pred(pages[page].nmes) do begin
                 xx[j] := 2 * valXder[j] * valYder[j] + valYder[j] * valXder2[j];
        // 2.dr/dt.d(teta)/dt+rd2tezta/dt2
                 yy[j] := valYder2[j] - valY[j] * sqr(valXder[j]);
       // d2r/dt2-r.d(teta)/dt
              end;
              mondeVecteur[mondeAcc].trouve(xx, yy, pages[page].nmes);
              xx := nil;
              yy := nil;
            end
            else
              mondeVecteur[mondeAcc].trouve(valXder2, valYder2, pages[page].nmes);
            mondeVecteur[mondeAcc].mondeOrd := iMondeC;
          except
            exclude(trace, trAcceleration);
          end;
        end; // acceleration
      end; // for i
  end; // ChercheMondeVecteur

  procedure setGraduationZero;

  function testZero(m : indiceMonde) : boolean;
  begin
      result := monde[m].mini*monde[m].maxi <= 0;
      if not result then
         if monde[m].maxi>0
            then begin
               result := monde[m].mini<monde[m].maxi/100;
               if result then monde[m].mini := 0;

            end
            else begin
              result := abs(monde[m].maxi)<abs(monde[m].mini)/100;
              if result then monde[m].maxi := 0;
            end;
  end;

  var
    m: indiceMonde;
    gradZero: boolean;
  begin
    gradZero := (OgZeroGradue in OptionGraphe) and not
      (OgAnalyseurLogique in OptionGraphe) and not (OgPolaire in OptionGraphe);
    graduationZeroY := gradZero and (monde[mondeY].graduation = gLin) and
      testZero(mondeY);
    if graduationZeroY and not (OgMemeZero in OptionGraphe) then
      for m := mondeDroit to high(IndiceMonde) do
        GraduationZeroY := GraduationZeroY and not (monde[m].defini);
    graduationZeroX := gradZero and (monde[mondeX].graduation = gLin) and
      testZero(mondeX);
  end;

var
  i: integer;
  m: indiceMonde;
  margeCourbe, hauteurCourbe: single;
  NbreMonde: integer;
  MiniCommun, MaxiCommun: double;
  limite, decalage: single;
begin // ChercheMonde
  grapheOK := True;
  for m := low(indiceMonde) to high(indiceMonde) do
    monde[m].autoTick := autoTick;
  if not monde[mondeX].Defini then begin
    if not useDefautX
       then monde[mondeX].reset(OgPolaire in OptionGraphe);
    if not useDefaut then
      for m := mondeY to high(IndiceMonde) do
        monde[m].reset(OgPolaire in OptionGraphe);
    for i := 0 to pred(courbes.Count) do
      with courbes[i] do
        if (indexModele = 0) or courbeExp or
          ((OmEchelle in OptionModele) and (indexModele > 0)) then begin
          if not useDefaut then
            if useDefautX
               then monde[iMondeC].Trouve(valY, debutC, finC)
               else findWorld(iMondeC, valX, valY, DebutC, FinC);
          monde[iMondeC].Defini := True;
          monde[mondeX].Defini := True;
        end; // OmEchelle in OptionModele
    grapheOK := grapheOK and (Courbes.Count > 0);
  end; // not(monde[mondeX].Defini)
  ChercheMondeVecteur;
  for m := low(IndiceMonde) to high(IndiceMonde) do
      monde[m].setDefaut;
  if OgAnalyseurLogique in OptionGraphe then begin
    with monde[mondeY] do begin
        NbreMonde := 1;
        MondeDebut := mondeY;
        MiniCommun := Mini;
        MaxiCommun := Maxi;
    end;
    for m := succ(mondeY) to high(IndiceMonde) do
      with monde[m] do
        if defini then begin
          Inc(NbreMonde);
          if mini < miniCommun then
            miniCommun := mini;
          if maxi > maxiCommun then
            maxiCommun := maxi;
        end;
    if OgMemeEchelle in optionGraphe then
      for m := mondeY to high(IndiceMonde) do
        with monde[m] do
          if defini then begin
            mini := miniCommun;
            maxi := maxiCommun;
          end;
    if NbreMonde = 0 then NbreMonde := 1;
  end
  else NbreMonde := 1;
  with limiteFenetre do begin
    grapheOK  := (bottom - top) > succ(nbreMonde) * 20;
    avecAxeY  := (bottom - top)/5 > NbreGradMin * hautCarac * NbreMonde/4;
    avecAxeX  := (right - left) > NbreGradMin * 4 * largCarac;
    grandAxeY := (bottom - top)/5 > NbreGradMax * HautCarac * NbreMonde/4;
    grandAxeX := (right - left) > NbreGradMax * 4 * largCarac;
  end;
  limiteCourbe := limiteFenetre;
  limiteCourbe.left := limiteCourbe.Left+Marge;
  limiteCourbe.bottom := limiteCourbe.Bottom-Marge;
  if not (OgAnalyseurLogique in OptionGraphe) then
     limiteCourbe.top := limiteCourbe.Top+Marge;
  limiteCourbe.right := limiteCourbe.right-Marge;
  setGraduationZero;
  decalage := succ(monde[mondeY].NbreChiffres) * largCarac+hautCarac;
  if avecAxeY then begin
    if monde[mondeY].defini and
       not (OgPolaire in OptionGraphe) and
       not (graduationZeroX)
          then limiteCourbe.left := limiteCourbe.left+decalage
          else if GraduationZeroX then begin
      with monde[mondeX] do
        limite :=
          round((limiteCourbe.right - limiteCourbe.left) * mini /
          (mini - maxi)); { mini <=0 }
      if limite < decalage then
        limiteCourbe.left := limiteCourbe.left+decalage;
    end;
    if monde[mondeDroit].defini and not
      (OgAnalyseurLogique in OptionGraphe) then
      limiteCourbe.right := limiteCourbe.right-succ(monde[mondeDroit].NbreChiffres) * largCarac-hautCarac;
  end;
  if avecAxeX and not (OgPolaire in OptionGraphe) and not
    (GraduationZeroY) then
    limiteCourbe.bottom := limiteCourbe.bottom - 2 * HautCarac
  else if graduationZeroY then begin
    with monde[mondeY] do
      limite := round(
        (limiteCourbe.bottom - limiteCourbe.top) * mini /
        (mini - maxi));
    if limite < 2 * hautCarac then
      limiteCourbe.bottom := limiteCourbe.bottom- 2 * HautCarac;
  end;
  for m := mondeY to high(IndiceMonde) do
      with monde[m] do begin
         CourbeTop := LimiteCourbe.top;
         CourbeBottom := LimiteCourbe.bottom;
       end;
  for m := 1 to 2 do
    with mondeVecteur[m], limiteCourbe do
      Dimension := (bottom - top) + (right - left);
  if OgAnalyseurLogique in OptionGraphe then begin
    i := 0;
    if superposePage then begin
      margeCourbe := marge;
      limiteCourbe.top := limiteCourbe.top + hautCarac + Marge;
    end
    else margeCourbe := hautCarac + marge;
    hauteurCourbe := (LimiteCourbe.bottom - LimiteCourbe.top)/NbreMonde - margeCourbe;
      for m := mondeY to high(IndiceMonde) do
        with monde[m] do
          if defini then begin
            CourbeTop := LimiteCourbe.top + i * hauteurCourbe + succ(i) * margeCourbe;
            CourbeBottom := CourbeTop + hauteurCourbe;
            Inc(i);
          end;
  end;
  grapheOK := grapheOK and monde[mondeX].defini;
  if grapheOK then begin
    chercheProjectionX;
    for m := mondeY to high(indiceMonde) do
      if monde[m].defini then
        chercheProjectionY(m);
    if (OgOrthonorme in OptionGraphe) then
      setGraduationZero;
    for m := 1 to 2 do with mondeVecteur[m] do
        if defini then begin
          if -monde[mondeY].a > monde[mondeX].a then begin
            ax := dimension * EchelleVecteur / maxi;
            ay := ax * monde[mondeOrd].a / monde[mondeX].a;
          end
          else begin
            ay := -dimension * EchelleVecteur / maxi;
            ax := ay * monde[mondeX].a / monde[mondeOrd].a;
          end;
        end;
    if (OgMemeZero in OptionGraphe) and not
      (OgAnalyseurLogique in OptionGraphe) then
      ajusteZero;
  end;
end; // ChercheMonde

procedure TGrapheReg.SetMonde(m: indiceMonde; minX, minY, maxX, maxY: double);

  procedure chercheProjection;
  begin
    with monde[mondeX] do begin
      defini := True;
      Maxi := MaxX;
      Mini := MinX;
      A := (limiteCourbe.right - limiteCourbe.left) / (Maxi - Mini);
      B := limiteCourbe.left - Mini * A;
    end;
    with monde[m] do begin
      defini := True;
      Maxi := MaxY;
      Mini := MinY;
      A := (CourbeTop - CourbeBottom) / (Maxi - Mini);
      B := CourbeBottom - Mini * A;
    end;
  end;

begin // setMonde
  with limiteFenetre do begin
    avecAxeY  := (bottom - top) > NbreGradMin * hautCarac * 5/4;
    avecAxeX  := (right - left) > NbreGradMin * 4 * largCarac;
    grandAxeY := (bottom - top) > NbreGradMax * hautCarac * 5/4;
    grandAxeX := (right - left) > NbreGradMax * 4 * largCarac;
  end;
  limiteCourbe := limiteFenetre;
  limiteCourbe.left := limiteCourbe.left+ Marge;
  limiteCourbe.bottom := limiteCourbe.bottom-Marge;
  limiteCourbe.top := limiteCourbe.top + Marge;
  limiteCourbe.right := limiteCourbe.right- Marge;
  if avecAxeX then limiteCourbe.bottom := limiteCourbe.bottom- 2*hautCarac;
  if avecAxeY and monde[mondeY].defini then
    limiteCourbe.left := limiteCourbe.left+ succ(monde[mondeY].NbreChiffres) * largCarac+hautCarac;
  for m := mondeY to high(IndiceMonde) do
    with monde[m] do begin
      CourbeTop := LimiteCourbe.top;
      CourbeBottom := LimiteCourbe.bottom;
    end;
  chercheProjection;
  MajDessins;
end; // SetMonde

procedure TGrapheReg.AjoutePoint(m: indiceMonde; XX, YY: double);
begin
  with monde[mondeX] do begin
    case graduation of
      gLog: xx := Log10(xx);
    end;
    if XX > Maxi then
      Maxi := XX;
    if XX < Mini then
      Mini := XX;
  end;
  with monde[m] do begin
    case graduation of
      gLog: yy := Log10(yy);
      gdB: yy  := 20 * Log10(yy);
    end;
    if YY > Maxi then
      Maxi := YY;
    if YY < Mini then
      Mini := YY;
  end;
end;

procedure TGrapheReg.TraceCourbe(index: integer);
var
  couleurLoc: TAlphaColor;
  sincactif : boolean;

  procedure TracePoint;
  var
    decaleLoc: single;
    P0,P: TpointF;
    zeroSpectre : double;
    motifLoc: Tmotif;

    procedure InitSpectre;
    var P1,P2 : TpointF;
        zeroY : double;
    begin with courbes[index] do begin
        if monde[iMondeC].graduation = gLin
           then zeroY := 0
           else zeroY := monde[iMondeC].mini;
        WindowXY(valX[debutC], zeroY, iMondeC, P1);
        zeroSpectre := P1.Y;
        if OgAnalyseurLogique in OptionGraphe
           then decaleLoc := 0
           else decaleLoc := decalage * coeffDecalage;
        WindowRT(valX[finC], zeroY, iMondeC, P2);
        P1.offset(decaleLoc,-decaleLoc);
        P2.offset(decaleLoc,-decaleLoc);
        Segment(P1,P2); // ligne de base
    end end;

  var
    maxiY, miniY: single;
    P1, P2: TpointF;
    i : integer;
    largeurHisto: single;

    procedure InitHisto;
    var
      i: integer;
      larg : single;
    begin with courbes[index] do begin
        if (monde[iMondeC].graduation = gLin) and
           (monde[MondeX].graduation = gLin) then begin
          WindowXY(0, monde[iMondeC].mini, iMondeC, P0);
          WindowXY(valX[DebutC], valY[DebutC], iMondeC, P1);
          WindowXY(valX[FinC], valY[FinC], iMondeC, P2);
          largeurHisto := (abs(P2.x - P1.x)/(FinC - debutC))/2;
          if (FinC - debutC) < 64 then begin
            for i := DebutC to pred(FinC) do begin
              WindowXY(valX[i], valY[i], iMondeC, P1);
              WindowXY(valX[i + 1], valY[i + 1], iMondeC, P2);
              larg := abs(P2.x - P1.x)/2;
              if larg < largeurHisto then
                largeurHisto := larg;
            end;
          end;
          if largeurHisto > 1 then
            largeurHisto := largeurHisto - 1;
        end
        else motif := mCroix;
    end end;

    procedure TraceUnPoint;
    var Fpath : TPathData;
    begin with courbes[index] do begin
        WindowRT(valX[i], valY[i], iMondeC, P);
        if (P.x > 0) and (P.y >= miniY) and (P.y <= maxiY) then
          if pages[page].PointActif[i] then
            case MotifLoc of
              mCroix: begin
                SegmentXY(P.x-dimPoint,P.y, P.x+dimPoint, P.y);
                SegmentXY(P.x,p.y- dimPoint, P.x,p.Y+dimPoint);
              end;
              mCroixDiag: begin
                segmentXY(P.x- dimPoint,P.y - dimPoint,P.x+dimPoint,P.y+dimPoint);
                segmentXY(P.x+dimPoint,P.y - dimPoint,P.x- dimPoint,P.y+ dimPoint);
              end;
              mCercle:
                MyDrawEllipse(P.x- dimPoint,P.y - dimPoint,P.x+dimPoint + 1,P.Y+dimPoint + 1);
              mCerclePlein:
                MyFillEllipse(P.x- dimPoint,P.y - dimPoint,P.x+dimPoint + 1,P.Y+dimPoint + 1);
              mCarre: MyDrawRectXY(P.x- dimPoint,P.Y-dimPoint,P.x+dimPoint,P.Y+dimPoint);
              mCarrePlein: MyFillRectXY(P.x- dimPoint,P.Y-dimPoint,P.x+dimPoint,P.Y+dimPoint);
              mLosange,mLosangePlein: begin
                FPath := TPathData.Create;
                P1 := P;
                P1.Offset(-dimPoint,0);
                Fpath.moveTo(P1);
                P1 := P;
                P1.Offset(0,-dimPoint);
                Fpath.lineTo(P1);
                P1 := P;
                P1.Offset(dimPoint,0);
                Fpath.lineto(P1);
                P1 := P;
                P1.Offset(0,dimPoint);
                Fpath.lineTo(P1);
                Fpath.closePath;
                if motifLoc=mLosangePlein then Canvas.FillPath(FPath, 1);
                Canvas.DrawPath(FPath, 1);
                FPath.Free;
              end;
              mSpectre: begin
                segmentXY(P.x, zeroSpectre,P.x + decaleLoc,zeroSpectre-decaleLoc); // ligne de rappel
                segmentXY(P.x + decaleLoc, zeroSpectre - decaleLoc,P.x+decaleLoc,P.y-decaleLoc); // harmonique
              end;
              mBarreD: SegmentXY(P.x - 2, P0.y,P.x- 2,P.y);
              mBarreG: SegmentXY(P.x + 2, P0.y,P.x+2,P.y);
              mHisto: if largeurHisto = 0
                 then segment(TpointF.create(P.x, P0.y), P) // sinon windows ne trace rien !
                 else begin
                   MyFillRectXY(P.x - largeurHisto, P0.y, P.x + largeurHisto, P.y);
                   MyDrawRectXY(P.x - largeurHisto, P0.y, P.x + largeurHisto, P.y);
                 end;
              mReticule: begin
                WindowRT(monde[mondeX].mini,monde[iMondeC].mini, iMondeC, P0);
                WindowRT(monde[mondeX].maxi,monde[iMondeC].maxi, iMondeC, P1);
                if P.y<>P0.y then Segment(TpointF.create(P0.x, P.y), P);
                if P.x<>P0.x then Segment(TpointF.create(P.x, P0.y), P);
                MyDrawEllipse(P.x- dimPoint,P.y - dimPoint,P.x+dimPoint + 1,P.y+dimPoint + 1);
              end;
              mLigneH: Segment(TpointF.create(P.x - dimPoint, P.y), TpointF.create(P.x + dimPoint, P.y));
              mIncert: if (varX = nil) or
                          (IncertX = nil) or
                          (varY = nil) or
                          (IncertY = nil)
                then MyDrawRectXY(P.x- dimPoint,P.Y- dimPoint,P.x+dimPoint,P.Y+ dimPoint)
                else begin
                  WindowRT(valX[i] + CoeffEllipse * IncertX[i],
                    valY[i] - CoeffEllipse * IncertY[i], iMondeC, P2);
                  WindowRT(valX[i] - CoeffEllipse * IncertX[i],
                    valY[i] + CoeffEllipse * IncertY[i], iMondeC, P1);
                  if ((P1.x = P2.x) and (P2.y = P1.y)) or
                    (P1.x<0) or
                    (P2.x<0) or
                    (P1.y<0) or
                    (P2.y<0)
                  then MyDrawRectXY(P.x - dimPoint, P.y - dimPoint, P.x + dimPoint, P.y + dimPoint)
                  else if (P1.x = P2.x) or (P1.y = P2.y)
                    then begin
                         SegmentXY(P1.x, P.y,P2.x, P.y);
                         SegmentXY(P.x, P1.y,P.x, P2.y);
                    end
                    else begin
                    SegmentXY(P.x,P.y- 1, p.x,p.Y+1);
                    SegmentXY(P.x- 1,P.y, P.x+1,P.y);
                    MyDrawEllipse(P1.x,P1.Y,P2.x+1,P2.Y+1);
                    // +1 nécessaire pour centrer mais pourquoi ??
                  end;
                end // Incertitude
            end // case motif
          else begin // point inactif
            CreatePen(TStrokeDash.Solid, 1, claSilver);
            MyDrawEllipse(P.x- dimPoint,P.y- dimPoint,P.x+dimPoint + 1, P.y +dimPoint + 1);
            MyDrawEllipse(P.x- 2 * dimPoint,P.y - 2 * dimPoint,P.x+ 2 * dimPoint + 1, P.y + 2 * dimPoint + 1);
            CreatePen(TStrokeDash.Solid, penWidth, couleurLoc); // retour état initial
          end;
      end;
    end; // traceUnPoint

  var largeur: integer;
  begin with courbes[index] do begin
      if motif in [mHisto, mBarreD, mBarreG] then initHisto;
      maxiY := monde[iMondeC].courbeBottom + marge;
      miniY := monde[iMondeC].courbeTop - marge;
      if TraceEllipse and not
        (motif in [mSpectre, mHisto, mBarreD, mBarreG]) then
        motif := mIncert;
      CreatePen(TStrokeDash.Solid, penWidth, couleurLoc);// par défaut
      if superposePage and (motif <= mCarrePlein) and
         (page <> 0) and (SPmotif=reperePage)
            then motifLoc := motifPages[page mod MaxPages]
            else motifLoc := motif;
      case motifLoc of
        mCerclePlein, mCarrePlein, mLosangePlein:
          CreateSolidBrush(couleurLoc);
        mHisto: if largeurHisto < 11 then begin
            CreateSolidBrush(couleurLoc);
            Canvas.Stroke.Thickness := 1;
          end
          else begin
            largeurHisto := largeurHisto - 2; // pour la taille du crayon
            if (indexModele = 0) or courbeExp then begin
            case indexHisto of
                0: couleurLoc := couleurLoc;
                1: couleurLoc := getCouleurPale(couleurLoc);
                2: couleurLoc := getCouleurPale(couleurLoc);
                else couleurLoc := couleurLoc;
              end;
              Inc(indexHisto);
              indexHisto := indexHisto mod 3;
              largeur := 3;
            end
            else begin // modélisation
               largeur := 1;
               couleurLoc := couleurModele[indexModele];
               canvas.stroke.Color := couleurLoc;
            end;
            createSolidBrush(couleurLoc);
            canvas.stroke.Thickness := largeur;
          end;
        mBarreD, mBarreG: CreatePen(TStrokeDash.Solid, 3*penWidth, couleurLoc);
        mLigneH: ;
        mSpectre: initSpectre;
        mIncert: ;
      end;
      for i := DebutC to FinC do
          if ((i mod pasPoint) = 0) then
             traceUnPoint;
    end;
  end; // tracePoint

  procedure TraceFaussesCouleurs;
  var
    i, i0:  single;
    x1, x2: single;
    k, pas: integer;
    kmax : single;
    couleurT: TAlphaColor;
  begin
    i0 := monde[mondeY].CourbeBottom;
    kMax := abs(monde[mondeY].CourbeBottom - monde[mondeY].CourbeTop);
    pas := round(kMax/256);
    kmax := kmax/pas;
    x1 := LimiteFenetre.Left;
    x2 := x1 + largCarac;
    for k := 0 to round(kmax) do begin
      i := i0 - k * pas;
      couleurT := GetFausseCouleur(k / kmax);
      createPen(TStrokeDash.Solid, pas, couleurT);
      Segment(TpointF.create(x1, i), TpointF.create(x2, i));
    end; // for k
  end; // traceFaussesCouleurs

  procedure TraceSonagramme;
  var
    i, j, Int, NbreY, W, H, idxPrev, idxEnd: integer;
    xCourant, xSuivant, xStart, xEnd, yTop, yBottom, tmp: single;
    IntReal, deltay, checksum: double;
    couleurT: TAlphaColor;
    needRebuild: boolean;
    MapData: TBitmapData;
    SrcRect, DstRect: TRectF;
    SaveState: TCanvasSaveState;
  begin with courbes[index], pages[pageCourante] do begin
      deltay := valY[1] / 2;
      NbreY  := 0;
      repeat
        Inc(NbreY)
      until (valY[NbreY] = 0) or (NbreY = NbreFFT div 2);
// valY = valeur de fréquence
      W := pred(NbreSonagramme);
      H := pred(NbreY);
      if (W <= 0) or (H <= 0) then exit;
      checksum := son[1, 1] + son[W, H] + son[(W + 1) div 2, (H + 1) div 2];
      needRebuild := (FSonagrammeBitmap = nil) or
                     (FSonagrammeBitmap.Width <> W) or
                     (FSonagrammeBitmap.Height <> H) or
                     (FSonaNbreX <> W) or
                     (FSonaNbreY <> H) or
                     (FSonaDecadeDB <> DecadeDB) or
                     (FSonaFaussesCouleurs <> useFaussesCouleurs) or
                     (FSonaPage <> pageCourante) or
                     (FSonaChecksum <> checksum);
      if needRebuild then begin
        if FSonagrammeBitmap = nil then
          FSonagrammeBitmap := TBitmap.Create(W, H)
        else
          FSonagrammeBitmap.SetSize(W, H);
        if FSonagrammeBitmap.Map(TMapAccess.Write, MapData) then
        try
          for i := 1 to W do
            for j := 1 to H do begin
              IntReal := son[i, j]; // entre 0 et 1
              if DecadeDB > 0 then begin // logarithmique sur x décades
                if IntReal > 0 then begin
                  IntReal := 1 + log10(IntReal) / DecadeDB;
                  if IntReal < 0 then
                    IntReal := 0;
                end
                else
                  IntReal := 0;
              end;
              if useFaussesCouleurs then
                couleurT := GetFausseCouleur(IntReal)
              else begin
                Int := 255 - round(255 * IntReal);
                if Int < 0 then Int := 0
                else if Int > 255 then Int := 255;
                couleurT := MakeColor(Int, Int, Int);
              end;
              MapData.SetPixel(i - 1, H - j, couleurT);
            end; // j
        finally
          FSonagrammeBitmap.Unmap(MapData);
        end;
        FSonaNbreX := W;
        FSonaNbreY := H;
        FSonaDecadeDB := DecadeDB;
        FSonaFaussesCouleurs := useFaussesCouleurs;
        FSonaPage := pageCourante;
        FSonaChecksum := checksum;
      end;
      xCourant := monde[mondeX].affecte(valX[0]);
      xSuivant := monde[mondeX].affecte(valX[1]);
      xStart := (xCourant + xSuivant) / 2;
      if NbreSonagramme = 2 then
        xCourant := xSuivant
      else begin
        idxPrev := (NbreSonagramme - 1) * nbreSonagrammeAff;
        if idxPrev > finC then idxPrev := finC;
        xCourant := monde[mondeX].affecte(valX[idxPrev]);
      end;
      idxEnd := NbreSonagramme * nbreSonagrammeAff;
      if idxEnd > finC then idxEnd := finC;
      xSuivant := monde[mondeX].affecte(valX[idxEnd]);
      xEnd := (xCourant + xSuivant) / 2;
      yBottom := monde[mondeY].affecte(deltay);
      yTop := monde[mondeY].affecte(valY[H] + deltay);
      if xStart > xEnd then begin tmp := xStart; xStart := xEnd; xEnd := tmp; end;
      if yTop > yBottom then begin tmp := yTop; yTop := yBottom; yBottom := tmp; end;
      SrcRect := TRectF.Create(0, 0, W, H);
      DstRect := TRectF.Create(xStart, yTop, xEnd, yBottom);
      SaveState := Canvas.SaveState;
      try
        Canvas.IntersectClipRect(LimiteCourbe);
        Canvas.DrawBitmap(FSonagrammeBitmap, SrcRect, DstRect, 1, True);
      finally
        Canvas.RestoreState(SaveState);
      end;
  end end; // traceSonagramme

procedure AffecteSplineSinc;
var
  k, n: integer;
  valeurX, valeurY: vecteur;
  Nvisible,ordreSinc : integer;
begin with courbes[index] do begin
        CopyVecteur(valeurX, pages[page].valeurVar[varX.indexG]);
        CopyVecteur(valeurY, pages[page].valeurVar[varY.indexG]);
        Nvisible := finC-debutC+1;
        ordreSinc := round(limiteCourbe.width) div Nvisible;
        if ordreSinc<3 then exit;
        if (pages[page].nmes < maxVecteurDefaut) then begin
          n := 0;
          for k := 0 to pred(pages[page].nmes) do
            if not isNan(valeurX[k]) and
               not isNan(valeurY[k]) and
              pages[page].pointActif[k] then begin
              valeurX[n] := valeurX[k];
              valeurY[n] := valeurY[k];
              Inc(n);
            end;
          if optionLigne=LiSpline
             then CalculBspline(valeurX, valeurY, OrdreSinc, n, valx, valy)
             else InterpoleSinc(valeurX, valeurY, OrdreLissage, n, valx, valy);
          finC := pred(n);
          debutC := 0;
          valeurX := nil;
          valeurY := nil;
          setLength(valYder, n);
          DeriveeGauss(valX, valY, n, valYder, NbrePointDerivee);
        end
        else begin
          debutC := 0;
          finC := pred(pages[page].Nmes);
        end;
        sincActif := true;
end; end; // AffecteSplineSinc

procedure RestaureSplineSinc; // pour récipérer les points expérimentaux
begin with courbes[index] do begin
        CopyVecteur(valX, pages[page].valeurVar[varX.indexG]);
        CopyVecteur(valY, pages[page].valeurVar[varY.indexG]);
        debutC := 0;
        finC := pred(pages[page].nmes);
end end; // restaureSplineSinc

  procedure traceLigneNormale;
  var
    P,oldP: TpointF;
    FPath : TPathData;

    function xNew(y: single): single;
    begin
      Result := round(P.x + (y - P.y) * (oldP.X - P.x) / (oldP.Y - P.y));
    end;

  type
    Tprecedent = (pOK, pHaut, pBas, pNone);
  var
    i: integer;
    Precedent, Courant: Tprecedent;
    yy, maxiY, miniY: single;
    idebut, ifin, lenofPath : integer;
  begin // traceLigneNormale
  FPath := TPathData.Create;
  with courbes[index] do begin
      maxiY := monde[iMondeC].courbeBottom + marge;
      miniY := monde[iMondeC].courbeTop - marge;
      Precedent := pNone;
      idebut := debutC;
      ifin := finC;
      if traceFin then Canvas.Stroke.Thickness := 1;
      lenofPath := 0;
      for i := iDebut to iFin do begin
        WindowRT(valX[i], valY[i], iMondeC, P);
        if (P.x>0) and (P.y>0) then begin
          if P.y < miniY
             then Courant := pBas
             else if P.y > maxiY
                then Courant := pHaut
                else Courant := pOK;
          inc(lenofpath);
          case Courant of
             pOK: case Precedent of
                pNone : Fpath.moveTo(P);
                pOK: begin
                   Fpath.lineTo(P);
                   if lenofpath>1024 then begin
                      Canvas.DrawPath(FPath, 1);
                      lenofpath := 1;
                      FPath.Clear;
                      Fpath.moveTo(P);
                   end;
                end;
                pHaut, pBas: begin
                  if Precedent = pHaut
                     then yy := maxiY
                     else yy := miniY;
                  Fpath.moveTo(TPointF.create(xNew(yy), yy));
                  Fpath.lineTo(P);
                end;
             end;
             pHaut: case Precedent of
                pOK: Fpath.lineTo(TpointF.create(xNew(maxiY), maxiY));
                pHaut: ;
                pBas: begin
                  FPath.moveTo(TpointF.create(xNew(miniY), miniY));
                  Fpath.lineTo(TPointF.create(xNew(maxiY), maxiY));
                end;
                pNone: Courant := pNone;
             end;
             pBas: case Precedent of
                pOK: Fpath.lineTo(TPointF.create(xNew(miniY), miniY));
                pBas: ;
                pHaut: begin
                  Fpath.moveTo(TPointF.create(xNew(maxiY), maxiY));
                  Fpath.lineTo(TPointF.create(xNew(miniY), miniY));
                end;
                pNone: Courant := pNone;
             end;
          end; // case courant
          Precedent := Courant;
          oldP := P;
        end; // point Correct
      end; // boucle i
  end;
  Canvas.DrawPath(FPath, 1);
  FPath.free;
  end; // traceLigne

  procedure traceLignes;
  var
    pas:  integer;
    P: TpointF;
    FPath : TPathData;
    i,j: integer;
    maxiY, miniY,maxi,mini: single;
    idebut, ifin: integer;
  begin // traceLignes
  with courbes[index] do begin
      maxiY := monde[iMondeC].courbeBottom + marge;
      miniY := monde[iMondeC].courbeTop - marge;
      idebut := debutC;
      ifin := finC;
      P.x := windowX(valX[idebut]);
      while (P.x<limiteCourbe.left) and (idebut < finC) do begin
          Inc(idebut);
          P.x := windowX(valX[idebut]);
      end;
      P.x := windowX(valX[ifin]);
      while (P.x<limiteCourbe.left) and (ifin > debutC) do begin
          Dec(ifin);
          P.x := windowX(valX[ifin]);
      end;
      pas := succ((ifin - idebut) div NbrePointsMax);
      if pas<3 then begin
         traceLigneNormale;
         exit;
      end;
      FPath := TPathData.Create;
      iFin := iFin-pas;
      if traceFin then Canvas.Stroke.Thickness := 1;
      i := iDebut;
      while i <= iFin do begin
         maxi := miniY;
         mini := maxiY;
         for j := 0 to pas-1 do begin
             WindowRT(valX[i+j], valY[i+j], iMondeC, P);
             if (P.Y>0) then begin
                if p.y < mini then mini := P.Y;
                if P.y > maxi then maxi := P.Y;
             end;
         end;
         Fpath.moveTo(TpointF.Create(P.X,mini));
         Fpath.lineTo(TpointF.Create(P.X,maxi));
         Inc(i, pas);
      end; // boucle i
    end;
    Canvas.DrawPath(FPath, 1);
    FPath.free;
  end; // traceLignes

  procedure traceLigneAvecDecalage;
  var
    P,oldP: TpointF;

    function xNew(y: single): single;
    begin
      Result := round(P.x + (y - P.y) * (oldP.X - P.x) / (oldP.Y - P.y));
    end;

  type
    Tprecedent = (pOK, pHaut, pBas, pNone);
  var
    i: integer;
    Precedent, Courant: Tprecedent;
    decaleLoc: single;
    yy, maxiY, miniY: single;
    iDebut, iFin: integer;
    FPath : TPathData;
  begin with courbes[index] do begin
      FPath := TPathData.Create;
      maxiY := monde[iMondeC].courbeBottom + marge;
      miniY := monde[iMondeC].courbeTop - marge;
      Precedent := pNone;
      decaleLoc := decalage * coeffDecalage;
      idebut := debutC;
      ifin := finC;
      if not (OgPolaire in OptionGraphe) then begin
        P.x := windowX(valX[idebut]);
        while (P.x<0) and (idebut < finC) do begin
          Inc(idebut);
          P.x := windowX(valX[idebut]);
        end;
        P.x := windowX(valX[ifin]);
        while (P.x<0) and (ifin > debutC) do begin
          Dec(ifin);
          P.x := windowX(valX[ifin]);
        end;
      end;
      for i := iDebut to iFin do begin
        WindowRT(valX[i], valY[i], iMondeC, P);
        if (P.x<0) or (P.y<0) then precedent := pNone
        else begin
          if P.y < miniY then
            Courant := pBas
          else if P.y > maxiY then
            Courant := pHaut
          else
            Courant := pOK;
          case Courant of
            pOK: case Precedent of
                pNone: Fpath.moveTo(TpointF.create(P.x + decaleLoc, P.y - decaleLoc));
                pOK: Fpath.lineTo(TPointF.create(P.x + decaleLoc, P.y - decaleLoc));
                pHaut, pBas: begin
                  if Precedent = pHaut
                     then yy := maxiY
                     else yy := miniY;
                  Fpath.moveTo(TPointF.create(xNew(yy) + decaleLoc, yy - decaleLoc));
                  Fpath.lineTo(TPointF.create(P.x + decaleLoc, P.y - decaleLoc));
                end;
              end;
            pHaut: case Precedent of
                pOK: Fpath.lineTo(TPointF.create(xNew(maxiY) + decaleLoc, maxiY - decaleLoc));
                pHaut: ;
                pBas: begin
                  Fpath.moveTo(TPointF.create(xNew(miniY) + decaleLoc, miniY - decaleLoc));
                  Fpath.lineTo(TPointF.create(xNew(maxiY) + decaleLoc, maxiY - decaleLoc));
                end;
                pNone: ;
              end;
            pBas: case Precedent of
                pOK: Fpath.lineTo(TPointF.create(xNew(miniY) + decaleLoc, miniY - decaleLoc));
                pBas: ;
                pHaut: begin
                  Fpath.moveTo(TPointF.create(xNew(maxiY) + decaleLoc, maxiY - decaleLoc));
                  Fpath.lineTo(TPointF.create(xNew(miniY) + decaleLoc, miniY - decaleLoc));
                end;
                pNone: ;
              end;
          end;// case courant
          Precedent := Courant;
          oldP := P;
        end;
      end;{boucle i}
    end;
    Canvas.DrawPath(FPath, 1);
    FPath.Free;
  end; // traceLigneAvecDecalage

  procedure traceVecteur(xx, yy: vecteur; m: integer);
  var
    Pcourant: TpointF;
    i: integer;
    h: single; // dimension en pixel de la flèche tq 1% de la largeur
    couleurV: TAlphaColor;

    procedure TraceProlongement(dX, dY: double);
    var
      coeff: double;
      Pdelta: TpointF;
      p1,p2 : TPointF;
    begin
      createPen(TStrokeDash.Dash, 1, couleurV);
      p1 := Pcourant;
      try
        if abs(dY) > abs(dX)
           then coeff := MondeVecteur[mondeAcc].maxi / dY
           else coeff := MondeVecteur[mondeAcc].maxi / dX;
        coeff := abs(coeff);
        if coeff > 1e+2 then coeff := 1e+2;
        coeff := coeff / EchelleVecteur;
        MondeVecteur[mondeAcc].getEntier(dX * coeff, dY * coeff, Pdelta);
        p2.offset(Pdelta.x, Pdelta.y);
      except // dX=0 ou dY=0
      end;
      createPen(TStrokeDash.Solid, penWidth, couleurV);
    end;

    procedure TraceFleche(dX, dY: double);
    var
      d: integer;
      Pdelta: TpointF;
      Points:  TPolygon;
      p1,p2 : TpointF;
    begin
      MondeVecteur[m].getEntier(dX, dY, Pdelta);
      p1 := Pcourant;
      p1.offset(Pdelta.X,Pdelta.Y);
// P1 = bout de la flèche
      canvas.drawLine(Pcourant,p1,1);
      d := round(sqrt(sqr(Pdelta.x) + sqr(Pdelta.y)));
      Pdelta := Pdelta*h/d;
// P2 = centre de la base de la flèche
      P2 := P1;
      P2.offset(- Pdelta.x,- Pdelta.y);
      Pdelta := Pdelta*1/3;
      SetLength(Points, 4);
      Points[0] := P1;
      Points[1] := TPointF.create(P2.x - Pdelta.y, P2.y + Pdelta.x);
      Points[2] := TPointF.create(P2.x + Pdelta.y, P2.y - Pdelta.x);
      Points[3] := P1;
      canvas.FillPolygon(Points,1);
      canvas.DrawPolygon(Points,1); // triangle 3 points
      Finalize(Points);
    end;

    Procedure TraceEchelle;
    var sauveAx : double;
        S: string;
        largeur : single;
    begin
          with limiteCourbe do begin
            largeur := (right - left)/5;
            if m=1
              then Pcourant.x := largeur
              else Pcourant.x := right-largeur;
            Pcourant.y := top + HautCarac;
          end;
          if (ogOrthonorme in optionGraphe) or
             (MondeVecteur[m].ax<MondeVecteur[m].ay)
             then traceFleche(MondeVecteur[m].echelle, 0)
             else begin
                sauveAx := MondeVecteur[m].ax;
                MondeVecteur[m].ax := abs(MondeVecteur[m].ay);
                traceFleche(MondeVecteur[m].echelle, 0);
                MondeVecteur[m].ax := sauveAx;
             end;
          couleurTexte := couleurV;
          S := courbes[index].varDer[m].formatValeurEtUnite(MondeVecteur[m].echelle);
          Pcourant.y := limiteFenetre.top;
          MyDrawText(Pcourant,S);
          MondeVecteur[m].EchelleTrace := True;
      end;

  var
    pas: integer;
    iDebut, iFin: integer;
    dXr, dYr: double;

    function PointATracer(i: integer): boolean;
    begin with courbes[index] do begin
        if m=1
           then result := not isNan(valYder[i]) and not isNan(valXder[i])
           else result := not isNan(valYder2[i]) and not isNan(valXder2[i]);
        if not Result then exit;
        if UseSelect
              then if i < 256
                then Result := i in PointSelect
                else Result := False
              else Result := ((i-iDebut) mod pas) = 0;
    end end;

  begin with courbes[index] do begin // traceVecteur
    if (xx = nil) or (yy = nil) then exit;
    if OgPolaire in OptionGraphe then begin
       if (m=1) and ((valYder=nil) or (valXder=nil)) then exit;
       if (m=2) and ((valYder=nil) or (valXder=nil)) then exit;
    end;
    if (couleurMecanique[1]=claWhite) then couleurMecanique[1] := claBlue;
    if (couleurMecanique[2]=claWhite) then couleurMecanique[2] := claRed;
      try
        if CouleurVitesseImposee
           then couleurV := CouleurMecanique[m]
           else if m = 1
              then couleurV := couleurLoc
              else couleurV := MakeColor(couleurLoc,0.5);
        h := (limiteCourbe.Right - LimiteCourbe.Left)/100;
        if h < 8 then h := 8;
        CreateSolidBrush(couleurV);
        createPen(TStrokeDash.Solid, penWidth, couleurV);
        pas := succ((finC - debutC) div NbreVecteurVitesseMax);
        iDebut := debutC;
        if iDebut < m then iDebut := m;
        iFin := finC;
        if iFin > (pages[page].Nmes - m) then
           iFin := pages[page].Nmes - m;
        for i := iDebut to iFin do
          if PointAtracer(i) then begin
            WindowRT(valX[i], valY[i], iMondeC, Pcourant);
            if (Pcourant.x > 0) and (Pcourant.y > 0) then begin
              if OgPolaire in OptionGraphe then
                MondeVecteur[m].getPolaire(
                  valY[i], valX[i],
                  valYder[i], valXder[i],
                  valYder2[i], valXder2[i], dXr, dYr)
              else begin
                dXr := xx[i];
                dYr := yy[i];
              end;
              traceFleche(dXr, dYr);
              if (m = mondeAcc) and prolongeVecteur then
                  traceProlongement(dXr, dYr);
              if (m = mondeVitesse) and projeteVecteur then begin
                  createPen(TStrokeDash.Solid, 1, couleurV);
                  traceFleche(0, dYr);
                  traceFleche(dXr, 0);
                  createPen(TStrokeDash.Solid, penWidth, couleurV);
              end;
            end;
          end; // for i
        if not MondeVecteur[m].EchelleTrace then traceEchelle;
      except
        if m = MondeVitesse then exclude(trace, trVitesse);
        if m = MondeAcc then exclude(trace, trAcceleration);
      end;
  end end; // traceVecteur

  procedure traceResidus;
  var
    i: integer;
    dxi, dyi: integer;
    P0,P : TpointF;
    Tracedeltax, Tracedeltay: boolean;
  begin with courbes[index] do begin
      WindowXY(0, 0, iMondeC, P0);
      traceDeltax := traceEllipse and (varX <> nil) and (IncertX <> nil);
      traceDeltay := traceEllipse and (varY <> nil) and (IncertY <> nil);
      for i := debutC to finC do if pages[page].pointActif[i] then begin
        WindowRT(valX[i], valY[i], iMondeC, P);
        if Tracedeltax
           then dxi := abs(round(CoeffEllipse * IncertX[i] * monde[MondeX].A))
           else dxi := 0;
        if Tracedeltay
           then dyi := abs(round(CoeffEllipse * IncertY[i] * monde[iMondeC].A))
           else dyi := 0;
        if dxi + dyi = 0 then begin
          segmentXY(P.x, P0.y, P.x, P.y);
          MyDrawRectXY(P.x - dimPoint, P.y - dimPoint, P.x + dimPoint, P.y + dimPoint);
        end
        else begin
          if dxi = 0
             then segmentXY(P.x, P.y - dyi, P.x, P.y + dyi)
             else if dyi = 0
                then segmentXY(P.x - dxi, P.y, P.x + dxi, P.y)
                else MyDrawEllipse(P.x - dxi, P.y - dyi, P.x + dxi + 1, P.y + dyi + 1);
        end;
      end; // for i
    end;
  end; // traceResidus 

  procedure traceStat;
  var
    i: integer;
    P: TpointF;
    largeur,y0,xpred: single;
  begin with courbes[index] do begin
      case indexHisto of
           0: couleurLoc := couleurLoc;
           1: couleurLoc := getCouleurPale(couleurLoc);
           2: couleurLoc := getCouleurPale(getCouleurPale(couleurLoc));
           else couleurLoc := couleurLoc;
      end;
      inc(indexHisto);
      indexHisto := indexHisto mod 3;
      createSolidBrush(couleurLoc);
      i := debutC;
      repeat
          WindowRT(valX[debutC], 0, iMondeC, P);
          y0 := P.y;
          xpred := P.x;
          inc(i);
      until (xpred>=0) or (i=finC);
      largeur := penWidth/2 + 1;
      repeat
        WindowRT(valX[i], valY[i], iMondeC, P);
        if P.X>=0 then begin
           if (valY[i] > 0) then begin
              MyFillRectXY(xpred, P.y, P.x - largeur, y0);
              MyDrawRectXY(xpred, P.y, P.x - largeur, y0);
           end;
           xpred := P.x + largeur;
           inc(i);
        end;
      until (i>finC) or (P.X<0);
    end;
  end; // traceStat

// TGrapheReg.TraceCourbe(index)
begin with courbes[index] do begin
    if monde[mondeX].Axe = nil then
      monde[mondeX].Axe := varX;
    if monde[iMondeC].Axe = nil then
      monde[iMondeC].Axe := varY;
    if FinC < DebutC then
      exit;
    sincActif := false;
    if superposePage and (page <> 0) and (SPcouleur=reperePage)
       then couleurLoc := GetCouleurPages(page)
       else couleurLoc := couleur;
    if trSonagramme in trace then begin
        traceSonagramme;
        if useFaussesCouleurs then
           traceFaussesCouleurs;
        exit;
    end;
    if (pages[page].nmes>4096) and
       (trPoint in trace) and
       (motif<>mSpectre) then begin
          include(trace,trLigne);
          exclude(trace,trPoint);
    end;
    if (trPoint in trace) then begin
       createPen(TStrokeDash.Solid, 1, couleurLoc);
       tracePoint;
    end;
    if superposePage and (page <> 0) and (SPstyle=reperePage)
       then createPen(PstylePages[page mod MaxPages],penWidth, couleurLoc)
       else createPen(styleT, penWidth, couleurLoc);
    if trLigne in trace then begin
      case OptionLigne of
           LiSinc : if grandeurs[indexTri] = varX then affecteSplineSinc;
           LiSpline : affecteSplineSinc;
      end;
      if decalage = 0
         then if (grandeurs[indexTri]=varX) and
                 not (OgPolaire in OptionGraphe)
            then traceLignes
            else traceLigneNormale
         else TraceLigneAvecDecalage;
    end;
    if trStat in trace then TraceStat;
    if trResidus in trace then traceResidus;
    if trVitesse in trace then
       traceVecteur(valXder, valYder, mondeVitesse);
    if trAcceleration in trace then
       traceVecteur(valXder2, valYder2, mondeAcc);
    if not (OgPolaire in OptionGraphe) and (varY <> nil) then begin
       if avecAxeY then TraceTitreAxeY(varY, iMondeC, index);
       if empilePage and (iMondeC = mondeDebut) then TraceTitreAxeY(varY, iMondeC, index);
       if avecAxeX then TraceTitreAxeX(varX, index);
    end;// not polaire
  end;
  if sincActif then restaureSplineSinc;
end;// TraceCourbe

procedure TGrapheReg.Draw;

  procedure AfficheEcart;

    procedure StrDeltaX;
    var
      st: string;
      dx: double;
      P,P1,P2 : TpointF;
      posTrait, signe: single;
    begin
        createPen(TStrokeDash.Solid, penWidth, couleurReticule);
        try
          windowRT((curseurOsc[1].xr + curseurOsc[2].xr) / 2,
                  (curseurOsc[1].yr + curseurOsc[2].yr) / 2, curseurOsc[1].mondeC, P);
          windowRT(curseurOsc[2].xr, curseurOsc[2].yr, curseurOsc[2].mondeC, P2);
          windowRT(curseurOsc[1].xr, curseurOsc[1].yr, curseurOsc[1].mondeC, P1);
          with monde[mondeX] do
              case Graduation of
                gLog: begin
                  dX := abs(curseurOsc[2].xr / curseurOsc[1].xr);
                  st := ' ' + axe.nom + '*' + formatReg(dX);
                end;
                gLin: begin
                  dX := abs(curseurOsc[1].xr - curseurOsc[2].xr);
                  st := Axe.FormatValeurEtUnite(dX);
                end;
              end; // case graduation
          posTrait := limiteCourbe.top + hautCarac/2;
          segmentXY(P1.x, posTrait, P2.x, posTrait);
          // fléche
          if P1.x < P2.x
               then signe := 1
               else signe := -1;
          SegmentXY(P1.x + signe * marge * 3, posTrait + marge, P1.x, posTrait);
          SegmentXY(P1.x + signe * marge * 3, posTrait - marge, P1.x, posTrait);
          signe := -signe;
          SegmentXY(P2.x + signe * marge * 3, posTrait + marge, P2.x, posTrait);
          SegmentXY(P2.x + signe * marge * 3, posTrait - marge, P2.x, posTrait);
          MyFillText(TpointF.Create( P.x - length(st) * largCarac/2,
                             limiteCourbe.top),st,BrushCouleurZoom);
        except
        end;
    end;

    procedure StrDeltaY;
    var
      st: string;
      dy: double;
      largeur: single;
      P,P1,P2 : TpointF;
      posTrait, signe: single;
    begin
        createPen(TStrokeDash.Solid, penWidth, couleurReticule);
        try
          windowRT((curseurOsc[1].xr + curseurOsc[2].xr) / 2,
                  (curseurOsc[1].yr + curseurOsc[2].yr) / 2, curseurOsc[1].mondeC, P);
          windowRT(curseurOsc[2].xr, curseurOsc[2].yr, curseurOsc[2].mondeC, P2);
          windowRT(curseurOsc[1].xr, curseurOsc[1].yr, curseurOsc[1].mondeC, P1);
          if (curseurOsc[1].mondeC = curseurOsc[2].mondeC) then begin
            with monde[curseurOsc[1].mondeC] do
              case Graduation of
                gLog: begin
                  dY := abs(curseurOsc[1].yr / curseurOsc[2].yr);
                  st := ' ' + axe.nom + '*' + formatReg(dY);
                end;
                gLin: begin
                  dY := abs(curseurOsc[1].yr - curseurOsc[2].yr);
                  st := axe.FormatValeurEtUnite(dY);
                end;
                gdB: begin
                  dY := 20 * abs(log10(curseurOsc[2].yr / curseurOsc[1].yr));
                  st := formatGeneral(dY, precisionMin) + ' dB';
                end;
              end;{case}
              largeur  := length(st) * largCarac/2;
              posTrait := LimiteCourbe.right - largeur;
              segmentXY(posTrait, P1.y, posTrait, P2.y);
              // fléches
              if P1.y < P2.y
                 then signe := 1
                 else signe := -1;
              SegmentXY(posTrait - marge, P1.y + 3 * signe * marge, posTrait, P1.y);
              SegmentXY(posTrait + marge, P1.y + 3 * signe * marge, posTrait, P1.y);
              signe := -signe;
              SegmentXY(posTrait - marge, P2.y + 3 * signe * marge, posTrait, P2.y);
              SegmentXY(posTrait + marge, P2.y + 3 * signe * marge, posTrait, P2.y);
              MyFillText(TpointF.Create(LimiteCourbe.right - largeur * 2, P.y),st,BrushCouleurZoom);
          end;
        except
        end;
    end;

    procedure StrPente;
    var
      st: string;
      dx, dy: double;
      largeur: single;
      P, P1, P2: TPointF;
    begin
        if (CurseurOsc[1].mondeC<>CurseurOsc[2].mondeC) then exit;
        if (CurseurOsc[1].mondeC = mondeX) or (CurseurOsc[2].mondeC = mondeX) then exit;
        createPen(TStrokeDash.Dash, penWidth, couleurReticule);
        windowRT(CurseurOsc[1].xr, CurseurOsc[1].yr, CurseurOsc[1].mondeC, P1);
        windowRT(CurseurOsc[2].xr, CurseurOsc[2].yr, CurseurOsc[1].mondeC, P2);
        segment(P1,P2);
        try
          dY := CurseurOsc[1].yr - CurseurOsc[2].yr;
          with monde[CurseurOsc[1].mondeC] do
              case Graduation of
                gLog: dY := log10(abs(dY));
                gLin: ;
                gdB: dY := 20 * abs(log10(curseurOsc[2].Yr / curseurOsc[1].Yr));
              end;{case}
          dX := CurseurOsc[1].xr - CurseurOsc[2].xr;
          if monde[mondeX].Graduation=gLog then dX := log10(abs(dX)); { décade }
          if dx<>0 then begin
            st := unitePente.formatPente(dY / dX);
            largeur := length(st) * largCarac / 2;
            P := P1.midPoint(P2);
            P.Offset(+largeur,0);
            MyFillText(P,st,BrushCouleurZoom);
          end;
        except
        end;
    end; // strPente

  begin
    if not(monde[mondeX].defini) then exit;
    if not(monde[mondeY].defini) and
       not(monde[mondeDroit].defini) then exit;
    setTextAlign(TTextAlign.Leading,TTextAlign.Leading);
    if not curseurOsc[1].isData
        then begin
           with curseurOsc[1] do mondeRT(Pc, mondeC, Xr, Yr);
           with curseurOsc[2] do mondeRT(Pc, mondeC, Xr, Yr);
        end;
    if coDeltaX in optionCurseur then strDeltaX;
    if coDeltaY in optionCurseur then strDeltaY;
    if coPente in optionCurseur then strPente;
    if curseurOsc[1].Pc.x>curseurOsc[2].Pc.x
    then begin
         curseurOsc[1].PositionX := Xdroit;
         curseurOsc[2].PositionX := Xgauche;
    end
    else begin
         curseurOsc[2].PositionX := Xdroit;
         curseurOsc[1].PositionX := Xgauche;
    end;
    if curseurOsc[1].Pc.y>curseurOsc[2].Pc.y
    then begin
         curseurOsc[1].PositionY := Ybas;
         curseurOsc[2].PositionY := Yhaut;
    end
    else begin
         curseurOsc[2].PositionY := Ybas;
         curseurOsc[1].PositionY := Yhaut;
    end;
  end; // AfficheEcart

  Procedure FondBlanc;
  begin
      canvas.Fill.kind := TBrushKind.Solid;
      canvas.Fill.Color := claWhite;
      canvas.stroke.Color := claWhite;
      canvas.stroke.kind := TBrushKind.Solid;
      with limiteFenetre do
           canvas.FillRect(TrectF.Create(0,0,Width,Height),0,0,[],1);
      canvas.Fill.kind := TBrushKind.None;
  end;

var
  c, i: integer;
  nX: string;
  m : indiceMonde;
  k : indexCurseur;
begin // graphe.draw
  canvas := paintBox.canvas;
  with limiteFenetre do begin
     right := paintBox.width;
     bottom := paintBox.height;
     if (right - left) < 50 then exit;
     dimPoint := (bottom - top) * dimPointVGA/480;
     if dimPoint = 0 then dimPoint := 1;
     marge := (bottom-top);
     BorneFenetre.top := top-marge;
     BorneFenetre.bottom := bottom+marge;
     marge := (right-left)/16;
     BorneFenetre.right := right+marge;
     BorneFenetre.left := left-marge;
     penWidth := width*penWidthEcran/1024;
     if penWidth<1 then penWidth := 1;
  end;
  monde[mondeX].minInt := borneFenetre.left;
  monde[mondeX].maxInt := borneFenetre.right;
  for m := mondeY to high(indiceMonde) do begin
      monde[m].minInt := borneFenetre.top;
      monde[m].maxInt := borneFenetre.bottom;
  end;
  reticuleOrigine.Position.X := limiteFenetre.left;
  reticuleOrigine.Position.Y := limiteFenetre.Top;
  reticuleOrigine.width := limiteFenetre.width;
  reticuleOrigine.height := limiteFenetre.height;
  fondBlanc;
  setFontSize(tailleEcran/32);
  NbrePointsMax := round(3*tailleEcran);
  if ReticuleOrigine.Visible
     then ReticuleOrigine.bringToFront;
  grapheOK := grapheOK and (courbes.Count > 0) and (pageCourante>0);
  if grapheOK then
     for i := 0 to Equivalences[pageCourante].Count-1 do
         equivalences[pageCourante][i].paint;
 // canvas.Font.Family := FonteRegressi;
  layout.layoutCanvas := canvas;
//  layout.Font.Family := FonteRegressi;
  CreatePen(TStrokeDash.Dot, penWidth, claBlack);
  canvas.stroke.kind := TBrushKind.Solid;
  LargCarac := canvas.textWidth('A');
  HautCarac := canvas.textHeight('A');
  Marge := hautCarac/5;
  margeCaracY := -hautCarac-marge;
  EmpilePage := (OgAnalyseurLogique in optionGraphe) and SuperposePage;
  if (OgOrthonorme in OptionGraphe) and
     not(OgPolaire in OptionGraphe) and
     (monde[mondeY].axe <> nil) and
     (monde[mondeX].axe <> nil) and
     (monde[mondeY].axe.nomUnite <> monde[mondeX].axe.nomUnite) then
        exclude(OptionGraphe, ogOrthonorme);
  if grapheOK then chercheMonde;
  if not grapheOK then begin
     MyDrawText(TpointF.Create(limiteFenetre.width/2,limiteFenetre.height/2),
                            erNoData);
     exit;
  end;
  UnAxeX := True;
  if (courbes[0].varx <> nil) then begin
    nX := courbes[0].varx.nom;
    for c := 1 to pred(Courbes.Count) do
      with courbes[c] do
        if (varX <> nil) and (varX.nom <> nX) then
          unAxeX := False;
  end;
  TitresY.Clear;
  for m := low(indiceMonde) to high(indiceMonde) do
      monde[m].TitreAxe.Clear;
  drawAxis(graduationZeroX or graduationZeroY);
  indexHisto := 0;
  for c := 0 to pred(Courbes.Count) do
      traceCourbe(c);
  MajDessins;
  if graduationZeroX or graduationZeroY then drawAxis(False);
  DrawTitresAxeY;
  for k := 1 to maxCurseur do begin
      curseurOsc[k].positionX := Xauto;
      curseurOsc[k].positionY := Yauto;
  end;
  if curseurOsc[1].visible and
     curseurOsc[2].visible then AfficheEcart;
  setTextAlign(TTextAlign.leading,TTextAlign.leading);
end; // graphe.draw

procedure TGrapheReg.Reset;
var c : integer;
begin
  courbes.Clear;
  for c := pred(dessinTexts.count) downto 0 do begin
      if dessinTexts[c].dataFile
         then dessinTexts[c].dataFile := false
         else dessinTexts.Delete(c);
  end;
  dessinLines.Clear;
  TitresY.Clear;
  FSonaNbreX := 0;
  FSonaNbreY := 0;
  monde[mondeX].defini := False;
  GrapheOK  := False;
  AutoTick  := True;
  UseDefaut := False;
  for c := mondeX to mondeSans do begin
      monde[c].reset(false);
      monde[c].axe := nil;
  end;
  Modif := [gmXY];
  resetEquivalence;
end;

destructor TGrapheReg.Destroy;
var m: indiceMonde;
    p: integer;
begin
  courbes.Free;
  dessinTexts.Free;
  dessinLines.Free;
  for p := 1 to MaxPages do
    equivalences[p].Free;
  TitresY.Free;
  FSonagrammeBitmap.Free;
  for m := low(indiceMonde) to high(IndiceMonde) do
      monde[m].Free;
  for m := 1 to 2 do
      mondeVecteur[m].Free;
  UnitePente.Free;
// les bornes et le reticule sont détruites par la paintBox
  layout.Free;
  inherited;
end;

constructor TGrapheReg.Create(aPaintBox : TPaintBox);
var
  m: indiceMonde;
  i: indiceOrdonnee;
  k: integer;
begin
  inherited Create;
  modif := [gmXY];
  paintBox := apaintBox;
  mondeDerivee := mondeY;
  UnitePente := Tunite.Create;
  for m := low(indiceMonde) to high(IndiceMonde) do
    monde[m] := Tmonde.Create(aPaintBox);
  monde[mondeX].horizontal := True;
  for m := 1 to 2 do
      mondeVecteur[m] := TmondeVecteur.Create;
  mondeVecteur[2].vitesse := False;
  for i := 1 to maxOrdonnee do
    with Coordonnee[i] do begin
      nomX  := '';
      nomY  := '';
      codeX := grandeurInconnue;
      codeY := grandeurInconnue;
      iMondeC := mondeY;
      Couleur := couleurInit[i];
      StyleT := PstyleInit[i];
      motif := motifInit[i];
      trace := [];
  end;
  for k := 1 to maxCurseur do begin
     curseurOsc[k] := TcurseurDonnees.createCurseur(self);
     curseurOsc[k].stroke.color := couleurCurseurs[k];
     curseurOsc[k].numero := k;
  end;
  optionCurseur := [coX, coY, coDeltax, coDeltay, coPente];
  reticuleOrigine := TreticuleShape.Create(paintBox);
  reticuleOrigine.Visible := false;
  selection := TRectSelect.Create(paintBox);
  selection.Visible := false;
  OptionGraphe := OptionGrapheDefault;
  OptionModele := [OmExtrapole];
  courbes := Tlist<TCourbe>.Create;
  dessinTexts := Tlist<TDessinText>.Create;
  dessinTexts.OnNotify := notifyText;
  dessinLines := Tlist<TDessinLine>.Create;
  dessinLines.OnNotify := notifyLine;
  for k := 1 to MaxPages do
      equivalences[k] := TlisteEquivalence.Create;
  TitresY := TList<TTitreAxeY>.Create;
  PasPoint := 1;
  UnAxeX := True;
  reset;
  avecAxeX := True;
  avecAxeY := True;
  layout := TTextLayoutManager.DefaultTextLayout.Create;
  limiteFenetre := TrectF.create(0,0,100,100);
end;  // TGrapheReg.Create

procedure Tcourbe.setStyle(Acouleur: TAlphaColor; Astyle: TStrokeDash; Amotif: Tmotif);
begin
  couleur := ACouleur;
  styleT := Astyle;
  motif := AMotif;
end;

constructor Tcourbe.Create(AX, AY: vecteur; D, F: integer; VX, VY: tgrandeur);
begin
  valX  := AX;
  valY  := AY;
  incertX := nil;
  incertY := nil;
  DebutC := D;
  FinC  := F;
  Decalage := 0;
  Trace := [trPoint];
  varY  := VY;
  varX  := VX;
  couleur := CouleurPages[1];
  styleT := PstylePages[1];
  Motif := MotifPages[1];
  IndexModele := 0;
  Adetruire := False;
  DetruireIncert := False;
  CourbeExp := False;
  iMondeC := MondeY;
  ModeleParametrique := False;
  PortraitDePhase := False;
  valXder := nil;
  valYder := nil;
  valXder2 := nil;
  valYder2 := nil;
  pointSelect := [];
  optionLigne := liDroite;
end;

destructor Tcourbe.Destroy;
begin
  if Adetruire then begin
    valX := nil;
    valY := nil;
    valYder := nil;
  end;
  if DetruireIncert then begin
    incertX := nil;
    incertY := nil;
  end;
  inherited Destroy;
end;

procedure TGrapheReg.AffecteZoomArriere;

  procedure CalcMinMax(NewMin, NewMax: single; m: indiceMonde);
  var absMax, absMin:  double;
  begin with monde[m] do begin
      a := a/2;
      b := b+a*(maxi+mini)/2;
      Mini := (NewMin - B)/a;
      Maxi := (NewMax - B)/a;
      AbsMax := abs(maxi);
      AbsMin := abs(mini);
      if AbsMax < AbsMin then AbsMax := AbsMin;
      graduationPiActive := graduationPiActive and
        ((not (AngleEnDegre) and (AbsMax > 0.8) and (AbsMax < 13)) or
        (AngleEnDegre and (AbsMax > 45) and (AbsMax < 720)));
  end end;

var
  m: indiceMonde;
begin
  CalcMinMax(limiteCourbe.left,limiteCourbe.right,mondeX);
  if OgAnalyseurLogique in OptionGraphe then exit;
  for m := mondeY to high(IndiceMonde) do
      if monde[m].defini then
         CalcMinMax(limiteCourbe.bottom,limiteCourbe.Top,m);
end;// zoomArriere

procedure TGrapheReg.AffecteZoomAvant(avecY: boolean);
var
  minX, maxX, minY, maxY: double;

  procedure AffecteZoomLoc(m: indiceMonde);
  begin with monde[m] do begin
      MondeXY(TpointF.create(selection.Position.x, selection.Position.y), m, minX, maxY);
      MondeXY(TpointF.Create(selection.Position.x+selection.width,
                             selection.Position.y+selection.height), m, maxX, minY);
      VerifMinMaxReal(MinY, MaxY);
      if MinY > Mini then Mini := MinY;
      if MaxY < Maxi then Maxi := MaxY;
  end end;

var
  m: indiceMonde;
begin
  with monde[mondeX] do begin
    MondeXY(TpointF.Create(selection.Position.x,selection.Position.y), mondeY, minX, maxY);
    MondeXY(TpointF.create(selection.Position.x+selection.width,
                           selection.Position.y+selection.height), mondeY, maxX, minY);
    verifMinMaxReal(MinX, maxX);
    if MinX > Mini then Mini := MinX;
    if MaxX < Maxi then Maxi := MaxX;
  end;
  if avecY then
    for m := mondeY to high(indiceMonde) do
      if monde[m].defini then begin
        affecteZoomLoc(m);
        break;
      end;
end; // AffecteZoomAvant

procedure TGrapheReg.AffecteZoomGesture(const EventInfo: TGestureEventInfo);
(* TGestureEventInfo = record
    GestureID: TGestureID;
    Location: TPointF;   point en cours
    Flags: TInteractiveGestureFlags;
    Angle: Double; par rapport au point de départ
    InertiaVector: TPointF;
    Distance: Integer; par rapport au point de départ
    TapLocation: TPointF;
  end;
  gfBegin Le mouvement interactif vient de commencer.
  gfInertia Le mouvement interactif se poursuit par inertie.
  gfEnd Le mouvement interactif se termine.
*)

var
  alphaX, alphaY: double;
  centre : TpointF;
  Xr0,Yr0 : double;

  procedure AffecteZoomLoc(m: indiceMonde);
  begin with monde[m] do begin
      MondeRT(centre,m,xr0, yr0);
      b := b+a*yr0*(1-alphaY);
      a := a*alphaY;
  end end;

var
  m: indiceMonde;
begin
  with eventInfo do begin
      alphaX := distance*cos(angle);
      alphaY := distance*sin(angle);
      centre := Location;
      centre.Offset(-alphaX,-alphaY);
      alphaX := 1-alphaX/paintBox.width;
      alphaY := 1-alphaY/paintBox.height;
  end;
  with monde[mondeX] do begin
     MondeRT(centre,mondeY,xr0, yr0);
     b := b+a*xr0*(1-alphaX);
     a := a*alphaX;
  end;
  for m := mondeY to high(indiceMonde) do
      if monde[m].defini then
         affecteZoomLoc(m);
end; // zoomGesture

procedure TGrapheReg.ChercheDroite(x, y, pente: double; m: indiceMonde;
  var P1, P2: TpointF);
var
  xr1, xr2, dX, dY: double;
begin
  case monde[mondeX].Graduation of
    gLog: pente := x * pente * ln(10);
    gdB: pente  := x * 20 * pente * ln(10);
  end;
  case monde[m].Graduation of
    gLog: pente := pente  / y/ln(10);
    gdB: pente  := 20 * pente  / y/ln(10);
  end;
  RTversXY(x, y, m);
  dX := (monde[mondeX].Maxi - monde[mondeX].Mini) / 6;
  dY := (monde[m].Maxi - monde[m].Mini) / 6;
  if abs(pente) < dY / dX then begin
    xr1 := x - dX;
    xr2 := x + dX;
  end
  else begin
    xr1 := x + dY / pente;
    xr2 := x - dY / pente;
  end;
  if xr1 < monde[mondeX].Mini then xr1 := monde[mondeX].Mini;
  if xr2 > monde[mondeX].Maxi then xr2 := monde[mondeX].Maxi;
  if xr2 < monde[mondeX].Mini then xr2 := monde[mondeX].Mini;
  if xr1 > monde[mondeX].Maxi then xr1 := monde[mondeX].Maxi;
  windowXY(xr1, y + pente * (xr1 - x), m, P1);
  windowXY(xr2, y + pente * (xr2 - x), m, P2);
end;

constructor TTamponTexteLigne.Create(gr : TgrapheReg);
begin
  inherited create;
  agraphe := gr;
  color := claBlue;
  couleurFond := claWhite;
  vertTextAlign := TTextAlign.Leading;
  horzTextAlign := TTextAlign.leading;
  autoSize := true;
  wordWrap := false;
  fontSize := 14;
  iMonde := mondeY;
  stroke := TStrokeBrush.create(TBrushKind.Solid,claBlue);
  stroke.Color := claBlue;
  dashLigne := TstrokeDash.Solid;
  strokeDash := TstrokeDash.Solid;
  texteLigne := tlNone;
  stroke.Thickness := 1;
  textes := TstringList.Create;
  identification := identNone;
end;

destructor TTamponTexteLigne.Destroy;
begin
  textes.free;
  stroke.Free;
  inherited destroy;
end;

procedure TDessinText.StoreXML(ANode : IXMLNode);
begin
  writeFloatXML(ANode,'x1',x0);
  writeFloatXML(ANode,'y1',y0);
  writeFloatXML(ANode,'x2',xReal);
  writeFloatXML(ANode,'y2',yReal);
  writeFloatXML(ANode,'FontSize',font.size);
  writeIntegerXML(ANode,'Monde',iMonde);
  writeIntegerXML(ANode,'CouleurFond',couleurFond);
  writeIntegerXML(ANode,'Couleur',color);
  writeBoolXML(ANode,'isOpaque',isOpaque);
  writeBoolXML(ANode,'withCadre',avecCadre);
  writeStringXML(ANode,'Texte',Text);
end;

procedure TDessinText.LoadXML(ANode : IXMLNode);

procedure LitEnfant(Anode : IXMLNode);
begin
   if ANode.NodeName='x1' then begin
      x0 := getFloatXML(ANode);
      exit;
   end;
   if ANode.NodeName='y1' then begin
      y0 := getFloatXML(ANode);
      exit;
   end;
   if ANode.NodeName='x2' then begin
       xReal := getFloatXML(ANode);
       exit;
   end;
   if ANode.NodeName='y2' then begin
      yReal := getFloatXML(ANode);
      exit;
   end;
   if ANode.NodeName='H' then begin
      exit;
   end;
   if ANode.NodeName='Page' then begin
      exit;
   end;
   if ANode.NodeName='Monde' then begin
     iMonde := getIntegerXML(ANode);
     exit;
   end;
   if ANode.NodeName='NumCoord' then begin
     exit;
   end;
   if ANode.NodeName='Ident' then begin
       exit;
   end;
   if ANode.NodeName='Ident' then begin
       exit;
   end;
   if ANode.NodeName='CouleurFond' then begin
      couleurFond := getColorXML(ANode);
      exit;
   end;
   if ANode.NodeName='Couleur' then begin
      color := getColorXML(ANode);
      exit;
   end;
   if ANode.NodeName='PenStyle' then begin
      exit;
   end;
   if ANode.NodeName='PenWidth' then begin
       exit;
   end;
   if ANode.NodeName='TexteLigne' then begin
       exit;
   end;
   if ANode.NodeName='isTitre' then begin
      exit;
   end;
   if ANode.NodeName='isOpaque' then begin
     isOpaque := getBoolXML(ANode);
     exit;
   end;
   if ANode.NodeName='isSouligne' then begin
      if getBoolXML(ANode) then
        font.Style := font.Style+[TFontstyle.fsUnderline];
      exit;
   end;
   if ANode.NodeName='isVertical' then begin
      isVertical := getBoolXML(ANode);
      exit;
   end;
    if ANode.NodeName='isCadre' then begin
      avecCadre := getBoolXML(ANode);
      exit;
    end;
    if ANode.NodeName='isCentre' then begin
        isCentre  := getBoolXML(ANode);
        exit;
    end;
    if ANode.NodeName='isTexte' then begin
      exit;
    end;
    if ANode.NodeName='withRappel' then begin
        exit;
    end;
    if ANode.NodeName='Motif' then begin
        exit;
    end;
    if ANode.NodeName='Texte' then begin
       Text := ANode.text;
       exit;
    end;
    if ANode.NodeName='FontSize' then begin
       font.Size := getFloatXML(ANode);
       exit;
    end;
end;

var i: Integer;
begin
if ANode.HasChildNodes then
   for I := 0 to ANode.ChildNodes.Count - 1 do
       LitEnfant(ANode.ChildNodes.Nodes[I]);
end;

procedure TDessinLine.StoreXML(ANode : IXMLNode);
begin
  writeFloatXML(ANode,'x1',position.x);
  writeFloatXML(ANode,'y1',position.y);
  writeFloatXML(ANode,'x2',xReal);
  writeFloatXML(ANode,'y2',yReal);
  writeFloatXML(ANode,'H',height);
  writeFloatXML(ANode,'W',width);
  writeIntegerXML(ANode,'Monde',iMonde);
  writeIntegerXML(ANode,'TexteLigne',ord(TexteLigne));
  writeIntegerXML(ANode,'Couleur',stroke.color);
  writeIntegerXML(ANode,'PenStyle',ord(stroke.dash));
  writeIntegerXML(ANode,'PenWidth',round(stroke.thickness));
end;

procedure TDessinLine.LoadXML(ANode : IXMLNode);

procedure LitEnfant(Anode : IXMLNode);
begin
   if ANode.NodeName='x1' then begin
      position.x := getFloatXML(ANode);
      exit;
   end;
   if ANode.NodeName='y1' then begin
      position.y := getFloatXML(ANode);
      exit;
   end;
   if ANode.NodeName='x2' then begin
       xReal := getFloatXML(ANode);
       exit;
   end;
   if ANode.NodeName='y2' then begin
      yReal := getFloatXML(ANode);
      exit;
   end;
   if ANode.NodeName='H' then begin
      height := getIntegerXML(ANode);
      exit;
   end;
   if ANode.NodeName='W' then begin
      width := getIntegerXML(ANode);
      exit;
   end;
   if ANode.NodeName='Page' then begin
      exit;
   end;
   if ANode.NodeName='Monde' then begin
     iMonde := getIntegerXML(ANode);
     exit;
   end;
   if ANode.NodeName='NumCoord' then begin
     exit;
   end;
   if ANode.NodeName='Ident' then begin
       exit;
   end;
   if ANode.NodeName='CouleurFond' then begin
      exit;
   end;
   if ANode.NodeName='Couleur' then begin
      stroke.color := getColorXML(ANode);
      exit;
   end;
   if ANode.NodeName='PenStyle' then begin
      stroke.dash := TStrokeDash(getIntegerXML(ANode));
      exit;
   end;
   if ANode.NodeName='PenWidth' then begin
       stroke.Thickness := getIntegerXML(ANode);
       exit;
   end;
   if ANode.NodeName='isTitre' then begin
     exit;
   end;
   if ANode.NodeName='isOpaque' then begin
     exit;
   end;
   if ANode.NodeName='isSouligne' then begin
      exit;
   end;
   if ANode.NodeName='isVertical' then begin
      exit;
   end;
    if ANode.NodeName='isCadre' then begin
      exit;
    end;
    if ANode.NodeName='isCentre' then begin
        exit;
    end;
    if ANode.NodeName='isTexte' then begin
      exit;
    end;
    if ANode.NodeName='withRappel' then begin
        exit;
    end;
    if ANode.NodeName='Motif' then begin
        TexteLigne := TTexteLigne(getIntegerXML(ANode));
        exit;
    end;
    if ANode.NodeName='Texte' then begin
       exit;
    end;
end;

var i: Integer;
begin
if ANode.HasChildNodes then
   for I := 0 to ANode.ChildNodes.Count - 1 do
       LitEnfant(ANode.ChildNodes.Nodes[I]);
end;

procedure TTamponTexteLigne.Load;

procedure CreeLigne;
var Aligne : TDessinLine;
begin
  Aligne := TDessinLine.CreateLine(aGraphe);
  Aligne.dataFile := true;
  Aligne.xReal := xReal;
  Aligne.yReal := yReal;
  Aligne.iMonde := iMonde;
  Aligne.TexteLigne := texteLigne;
  Aligne.dashLigne := dashLigne;
  Aligne.motifLigne := motifLigne;
  Aligne.Stroke.color := Stroke.color;
  Aligne.stroke.kind := stroke.kind;
  ALigne.stroke.Thickness := stroke.Thickness;
  ALigne.selection := sdNone;
  aGraphe.dessinLines.add(ALigne);
end;

procedure CreeTexte;
var AText : TDessinText;
begin
  AText := TDessinText.CreateText(agraphe);
  Atext.dataFile := true;
  Atext.xReal := xReal;
  Atext.yReal := yReal;
  AText.font.size := fontSize;
  Atext.iMonde := iMonde;
  AText.color := color;
  AText.avecCadre := avecCadre;
  Atext.text := textes.text;
  Agraphe.dessinTexts.add(AText);
end;

var z : single;
    i,imax : integer;
    zint : integer;
    zLong : longWord;
    valeurs : TstringList;
begin
  valeurs := TstringList.create;
  valeurs.delimiter := ' ';
  imax := NbreLigneWin(ligneWin) - NbreLigneDessin;
  xReal := litFloatRW3; {1}
  yReal := litFloatRW3; {2}
  widthReal := litFloatRW3; {3}
  heightReal := litFloatRW3; {4}
  hauteur := litIntegerRW3;{5}
  litLigneWin; // 6
  valeurs.delimitedText := ligneWin;
  numPage := StrToInt(valeurs[0]);
  if valeurs.count>1 then
     iMonde := strToInt(valeurs[1]);
  if valeurs.count>2 then
    identification := Tidentification(strToInt(valeurs[1]));
  if valeurs.count>3 then begin
    zint := strToInt(valeurs[1]);
    TexteLigne := TtexteLigne(zint);
  end;
  if valeurs.count>4 then
     numPoint := strToInt(valeurs[1]);
  if valeurs.count>5 then begin
    zLong := strToInt(valeurs[1]);
    color := IntToColor(zLong);
  end;
  litLigneWin;// 7
  valeurs.clear;
  valeurs.delimitedText := ligneWin;
  zLong := StrToInt(valeurs[0]);
  Stroke.color := intToColor(zLong);
  if valeurs.count>1 then begin
    zint := strToInt(valeurs[1]);
    stroke.kind := TBrushKind(zint);
    z := strToInt(valeurs[2]);
    stroke.Thickness := z;
  end;
  if valeurs.count>3 then begin
    zint := strToInt(valeurs[3]);
    isTitre := zint <> 0;
  end;
  if valeurs.count>4 then begin
    zint := strToInt(valeurs[4]);
    isOpaque := zint <> 0;
  end;
  Souligne := litBooleanWin;{8}
  vertical := litBooleanWin;{9}
  avecCadre := litBooleanWin;{10}
  centre  := litBooleanWin;{11}
  isTexte := litBooleanWin;{12}
  avecLigneRappel := litBooleanWin; {13}
  zint := litIntegerRW3; {14}
  MotifTexte := TmotifTexte(zint);
  textes.Clear;
  for i := 1 to imax do begin {15 sqq}
      litLigneWinU;
      Textes.add(ligneWin);
  end;
  if isTexte
     then creeTexte
     else creeLigne;
end;

constructor TdessinText.CreateText(gr : TgrapheReg);
begin
  inherited Create(gr.paintBox);
  color := claBlue;
  couleurFond := claWhite;
  vertTextAlign := TTextAlign.Leading;
  horzTextAlign := TTextAlign.Leading;
  autoSize := true;
  wordWrap := false;
  font.Size := 14;
  identification := identNone;
  iMonde := mondeY;
  Agraphe := gr;
end;

procedure TdessinLine.SetMoveDown(move : TMouseMoveEvent; down,up : TMouseEvent);
begin
     OnMouseMove := move;
  //   OnMouseDown := down;
   //  OnMouseUp := up;
end;

constructor TdessinLine.CreateLine(gr : TgrapheReg);
begin
  inherited Create(gr.paintBox);
  stroke.Color := claBlue;
  dashLigne := TstrokeDash.Solid;
  stroke.Dash := TstrokeDash.Solid;
  texteLigne := tlNone;
  stroke.Thickness := 1;
  selection := sdNone;
  Agraphe := gr;
  rotationCenter.X := 0;
  rotationCenter.Y := 0;
  iMonde := mondeY;
end;

procedure TgrapheReg.LineGr(Arect: TrectF);
begin
    SegmentXY(Arect.left, Arect.top, Arect.right, Arect.bottom);
end;

function TdessinLine.LitOption: boolean;
begin
    if OptionLigneDlg = nil then
       Application.CreateForm(TOptionLigneDlg, OptionLigneDlg);
    OptionLigneDlg.DessinLoc := self;
    CentreForm(OptionLigneDlg);
    litOption := OptionLigneDlg.showModal = mrOk;
end;

function TdessinText.LitOption: boolean;
begin
    if LectureTexteDlg = nil then
       Application.CreateForm(TLectureTexteDlg, LectureTexteDlg);
    lectureTexteDlg.DessinLoc := self;
    centreForm(lectureTexteDlg);
    litOption := lectureTexteDlg.showModal = mrOk;
end;

procedure TGrapheReg.GetCurseurProche(P:TpointF; Force: boolean);
var i : integer;
begin
    curseurCourant := 0;
    for i := 1 to maxCurseur do
      if (curseurOsc[i].indexCourbe >= 0) and
         (P.distance(curseurOsc[i].Pc) < margeCurseur) and
          curseurOsc[i].visible
            then curseurCourant := i;
    if Force and (curseurCourant = 0) then
      if  curseurOsc[2].visible and
         (curseurOsc[2].indexCourbe >= 0) and
         (P.distance(curseurOsc[1].Pc) >
          P.distance(curseurOsc[2].Pc))
            then curseurCourant := 2
            else curseurCourant := 1;
end;

procedure Tmonde.SetDelta(grandAxe: boolean);
// Exposant=puissance de 10 multiple de 3 de manière à avoir entre
// NbreGradMax (10) et N/2.5 (4) graduations sur l'axes.
// ou NbreGradMin (5) et N/2.5 (2) graduations sur l'axes.
// Delta est l'intervalle entre les graduations qui commencent à PremiereGraduation

  procedure setDeltaLongueDuree;
  var
    N: integer;
  begin
    DeltaAxe := (maxi - mini) / 6;
    if DeltaAxe > UnJour then begin
      DeltaAxe := ceil(DeltaAxe / UnJour) * UnJour;
      FormatDuree := 'dd"j"';
      Arrondi  := UnJour;
    end
    else if DeltaAxe > UneHeure then begin
      N := trunc(DeltaAxe / UneHeure);
      case N of
        1, 2, 3, 4: ;
        5: N := 6;
        6: ;
        7: N := 8;
        8: ;
        9, 10, 11: N := 12;
        12: ;
        13, 14, 15, 16, 17: N := 12;
        18, 19, 20, 21, 22, 23, 24: N := 24;
      end;
      DeltaAxe := N * UneHeure;
      FormatDuree := 'dd"j "hh';
      Arrondi  := UneHeure;
    end
    else begin
      if DeltaAxe > QuartdHeure then
        DeltaAxe := ceil(DeltaAxe / QuartdHeure) * QuartdHeure
      else
        DeltaAxe := ceil(DeltaAxe / UneMinute) * UneMinute;
      FormatDuree := 'hh:mm';
      Arrondi := UneMinute;
    end;
    PointDebut := round(Mini / DeltaAxe) * deltaAxe;
    Exposant := 1;
    NbreChiffres := length(FormatDuree);
  end;// setDeltaLongueDuree

  procedure setDeltaDateTime;
  begin
    DeltaAxe := (Maxi - Mini);
    Arrondi  := 1;
    if deltaAxe > 30 { 1 mois } then begin
      FormatDuree := 'dd/mmm';
      deltaAxe := ceil(deltaAxe / 6);
      Arrondi  := 1;
    end
    else if deltaAxe > 1 { 1 jour } then begin
      FormatDuree := 'dd"j" hh';
      deltaAxe := ceil(deltaAxe / 6);
      Arrondi  := UneHeureWin;
    end
    else if deltaAxe > 6 * UneHeureWin { 6 heures } then begin
      deltaAxe := UneHeureWin * ceil(deltaAxe / 6 / UneHeureWin);
      FormatDuree := 'hh:mm';
      Arrondi  := UneMinuteWin;
    end
    else if deltaAxe > UneHeureWin { 1 heure } then begin
      deltaAxe := QuartdHeureWin * ceil(deltaAxe / 6 / QuartdHeureWin);
      FormatDuree := 'hh:mm';
      Arrondi  := UneMinuteWin;
    end
    else begin
      deltaAxe := UneMinuteWin * ceil(deltaAxe / 6 / UneMinuteWin);
      FormatDuree := 'mm:ss';
      Arrondi  := UneSecondeWin;
    end;
    PointDebut := round(Mini / DeltaAxe) * deltaAxe;
    NbreChiffres := length(formatDuree);
    Exposant := 1;
  end; // setDeltaDateTime

  procedure setDeltaDegre;
  var
    largeur: double;
    coeff: integer;
  begin
    largeur := (maxi - mini) / 9; { 9 graduations }
    coeff := 15 * ceil(largeur / 15);
    if (coeff = 75) or (coeff = 105) then
      coeff := 90;
    NbreChiffres := 3;
    DeltaAxe := coeff;
    if orthonorme then
      PointDebut := ceil(miniOrtho / deltaAxe) * deltaAxe
    else
      PointDebut := ceil(mini / deltaAxe) * deltaAxe;
    Exposant := 1;
  end; // setDeltaDegre

  procedure setDeltaRadian;
  var
    largeur: double;
    coeff, reste: integer;
  begin
    largeur := (maxi - mini) / 9;
    coeff := ceil(largeur * 12 / pi);
    reste := coeff mod 12;
    if (reste = 5) or (reste = 7) then
      coeff := 6 * ceil(largeur * 2 / pi);
// pi/2 plutôt que 5pi/12 ou 7pi/12
    if (reste = 10) or (reste = 11) then
      coeff := 12 * ceil(largeur / pi);
// pi plutôt que 11pi/12 ou 5pi/6
    deltaAxe := pi / 12 * coeff;
    NbreChiffres := 5;
    if orthonorme then
      PointDebut := ceil(miniOrtho / deltaAxe) * deltaAxe
    else
      PointDebut := ceil(mini / deltaAxe) * deltaAxe;
    Exposant := 1;
    GraduationPiActive := True;
  end; // setDeltaRadian

const
  indexMax = 5;
  coeff: array[0..indexMax] of double = (0.1, 0.2, 0.5, 1, 2, 5);
var
  AbsMax, AbsMin, largeur, deltaGrandAxe : double;
  Exponent, N, index, indexGrad, NGrad: integer;
begin
  graduationPiActive := False;
  Exponent := 0;
  Exposant := 1;
  if orthonorme
    then begin
      AbsMax := abs(maxiOrtho);
      AbsMin := abs(miniOrtho);
    end
    else begin
      AbsMax := abs(maxi);
      AbsMin := abs(mini);
    end;
  if AbsMax < AbsMin then AbsMax := AbsMin;
  Nticks := 1;
  try
    if (axe <> nil) and (axe.formatU = fLongueDuree) then begin
      setDeltaLongueDuree;
      exit;
    end;
    if (axe <> nil) and (axe.formatU in [fDateTime, fDate, fTime]) then begin
      setDeltaDateTime;
      exit;
    end;
  except
  end;
  indexGrad := 0;
  AutoTick  := AutoTick or (graduation = gLog);
  if not (AutoTick) then begin
    deltaAxe := abs(deltaAxe);
    N := round((maxi - mini) / deltaAxe);
    AutoTick := (N > 64) or (N < 2);
    if AutoTick then
      afficheErreur(erNbreGradManuel, 0)
    else begin
      Exponent := floor(Log10(deltaAxe));
      index := 0;
      largeur := (maxi - mini) * dix(-exponent);
      if largeur > NbreGradMaxMan * coeff[indexMax] then begin
        largeur := largeur / 10;
        Inc(exponent);
      end;
      while ((largeur / coeff[index]) >= NbreGradMaxMan) and
        (index < indexMax) do
        Inc(index);
      NTicks := ceil(coeff[index] * dix(exponent) / DeltaAxe);
    end;
  end;
  if AutoTick then begin
    if GraduationPi and (axe <> nil) and
      (axe.nomUnite = 'rad') and
      (AbsMax > 0.8) and (AbsMax < 100) then begin
      setDeltaRadian;
      exit;
    end;
    if GraduationPi and (axe <> nil) and
       (axe.nomUnite = '°') and
       (AbsMax > 45) and (AbsMax < 720) then begin
      setDeltaDegre;
      exit;
    end;
    if orthonorme then begin
      Exponent := floor(Log10(MaxiOrtho - MiniOrtho));
      largeur  := (maxiOrtho - miniOrtho) * dix(-exponent);
    end
    else begin
      Exponent := floor(Log10(Maxi - Mini));
      largeur  := (maxi - mini) * dix(-exponent);
    end;
    index := 0;
    if grandAxe
       then Ngrad := NbreGradMax
       else Ngrad := NbreGradMin;
    while ((largeur / coeff[index]) >= NGrad) and (index < indexMax) do
          Inc(index);
    DeltaAxe  := coeff[index] * dix(exponent);
    indexGrad := index mod 3;
  end; // autoTick
  NbreChiffres := ceil(Log10(AbsMax)) - floor(Log10(DeltaAxe));
  if autoTick then begin
    case indexGrad of
      0: Nticks := 5; { 1 -> 0.2 }
      1: Nticks := 4; { 2 -> 0.5 }
      2: Nticks := 5; { 5 -> 1 }
      else Nticks := 1;
    end;
    deltaAxe  := deltaAxe / Nticks;
  end;
  if exponent = -1 then exponent := 0;
// nombre <~1 écrit sous forme 0.8 plutôt que 800.10-3
  Index := Exponent div 3;
  if ((Exponent mod 3) < 0) then Dec(index);
//la division euclidienne des informaticiens <> div des maths !
  Exposant := Dix(3 * Index);
  if Graduation = gLog then begin
     NbreChiffres := longNombreAxe;
     Exposant := 1;
  end
  else begin
    N := ceil(Log10(AbsMax / Exposant));
    if N > NbreChiffres then NbreChiffres := N;
    if NbreChiffres < 3 then NbreChiffres := 3;
    if NbreChiffres > longNombreAxe then
      NbreChiffres := longNombreAxe;
  end;
  if Polaire then begin
    PointDebut := deltaAxe;
    TickDebut  := 1;
  end
  else begin
    deltaGrandAxe := NTicks*deltaAxe;
    if Orthonorme
       then PointDebut := ceil(miniOrtho / deltaGrandAxe) * deltaGrandAxe
       else PointDebut := ceil(mini / deltaGrandAxe) * deltaGrandAxe;
    TickDebut := ceil(PointDebut / deltaAxe); // ancien
    TickDebut := round(frac(PointDebut / deltaGrandAxe)*NTicks);  // nouveau
  end;
end; // setDelta

function Tmonde.FormatMonde(x: double): string;

  function FormatAxeLog: string;
  var
    unite: coefUnite;
  begin
    x := abs(x);
    unite := nulle;
    while (x >= 1000) and (unite < infini) do begin
      x := x / 1000;
      Inc(unite);
    end; { x<1000 ou infini }
    while (x < 1) and (unite > zero) do begin
      x := x * 1000;
      Dec(unite);
    end; { x>=1 ou zero }
    case unite of
       infini, zero: Result := '';
       nulle : Result := IntToStr(round(x));
       milli : Result := FloatToStrF(x/1000,ffGeneral,3,3);
       else Result := IntToStr(round(x)) + pointMedian+'10'+puissToStr(puissanceUnite[unite])
    end;
  end;

begin
  if (graduation = gLog)
    then Result := FormatAxeLog
    else if axe = nil
       then Result := FloatToStrF(x / exposant, ffGeneral, NbreChiffres, 0)
       else case axe.FormatU of
          fLongueDuree: Result := FormatLongueDureeAxe(x);
          fDateTime, fDate, fTime: Result :=
              FormatDateTime(FormatDuree, Arrondi * round(x / Arrondi));
          else if abs(x / deltaAxe) < 1e-5
             then Result := '0'
             else Result := FloatToStrF(x / exposant, ffGeneral, NbreChiffres, 0)
       end; // case
end; // FormatMonde

procedure TtransfertGraphe.AssignEntree;
var
  i: indiceOrdonnee;
  m: indiceMonde;
begin
  for i := 1 to MaxOrdonnee do begin
    nomY[i]  := Agraphe.Coordonnee[i].nomY;
    nomX[i]  := Agraphe.Coordonnee[i].nomX;
    iMonde[i] := Agraphe.Coordonnee[i].iMondeC;
    Trace[i] := Agraphe.Coordonnee[i].Trace;
    Ligne[i] := Agraphe.Coordonnee[i].Ligne;
    Couleur[i] := Agraphe.Coordonnee[i].couleur;
    Style[i] := Agraphe.Coordonnee[i].styleT;
    Motif[i] := Agraphe.Coordonnee[i].Motif;
  end;
  for m := low(IndiceMonde) to high(IndiceMonde) do begin
    Grad[m] := Agraphe.monde[m].Graduation;
    Zero[m] := Agraphe.monde[m].ZeroInclus;
    minidB[m] := Agraphe.monde[m].minidB;
  end;
  OptionGr  := Agraphe.OptionGraphe;
  OptionModele := Agraphe.OptionModele;
  SuperPage := Agraphe.superposePage;
  UseDefaut := Agraphe.UseDefaut;
  UseDefautX := Agraphe.UseDefautX;
  AutoTick  := Agraphe.AutoTick;
  PasPoint  := Agraphe.PasPoint;
end;

constructor TtransfertGraphe.Create;
var
  i: indiceOrdonnee;
  m: indiceMonde;
begin
  for i := 1 to MaxOrdonnee do begin
    nomY[i]  := 'Y';
    nomX[i]  := 'X';
    iMonde[i] := mondeY;
    Trace[i] := [trLigne];
    Ligne[i] := liDroite;
    Couleur[i] := claBlack;
    Style[i] := TStrokeDash.Solid;
    Motif[i] := mCroix;
  end;
  for m := low(IndiceMonde) to high(IndiceMonde) do begin
    Grad[m] := gLin;
    Zero[m] := True;
    minidB[m] := 0;
  end;
  OptionGr  := [];
  OptionModele := [];
  SuperPage := False;
  UseDefaut := False;
  UseDefautX := False;
  AutoTick  := True;
  PasPoint  := 1;
end;

procedure TtransfertGraphe.AssignSortie;
var
  i: indiceOrdonnee;
  m: indiceMonde;
begin
  for i := 1 to MaxOrdonnee do begin
    Agraphe.Coordonnee[i].nomY  := nomY[i];
    Agraphe.Coordonnee[i].nomX  := nomX[i];
    Agraphe.Coordonnee[i].iMondeC := iMonde[i];
    Agraphe.Coordonnee[i].Trace := Trace[i];
    Agraphe.Coordonnee[i].Ligne := Ligne[i];
    Agraphe.Coordonnee[i].Motif := Motif[i];
    Agraphe.Coordonnee[i].couleur := couleur[i];
    Agraphe.Coordonnee[i].styleT := Style[i];
  end;
  for m := low(indiceMonde) to high(indiceMonde) do begin
    Agraphe.monde[m].Graduation := Grad[m];
    zero[m] := zero[m] and (Grad[m]=gLin);
    Agraphe.monde[m].ZeroInclus := zero[m];
    Agraphe.monde[m].minidB := minidB[m];
  end;
  Agraphe.OptionGraphe := OptionGr;
  Agraphe.OptionModele := OptionModele;
  Agraphe.SuperposePage := SuperPage;
  Agraphe.UseDefaut := UseDefaut;
  Agraphe.UseDefautX := UseDefautX;
  Agraphe.AutoTick := AutoTick;
  Agraphe.PasPoint := PasPoint;
end;

function TgrapheReg.AjouteCourbe(AX, AY: vecteur; Am: indiceMonde;
  Nbre: integer; grandeurX, grandeurY: Tgrandeur; Apage: integer): Tcourbe;
var
  Acourbe: Tcourbe;
begin
  Acourbe := Tcourbe.Create(AX, AY, 0, pred(Nbre), grandeurX, grandeurY);
  Acourbe.page := Apage;
  Acourbe.couleur := GetCouleurPages(Apage);
  Acourbe.styleT := PstylePages[Apage];
  Acourbe.Motif := MotifPages[Apage];
  if Am <= maxMonde then
    Acourbe.iMondeC := Am;
  courbes.Add(Acourbe);
  monde[Am].defini := False;
  monde[mondeX].defini := False;
  Result := Acourbe;
end;

function TgrapheReg.InitReticule : boolean;
var mondeLoc : indiceMonde;
    i : integer;
begin
    result := false;
    if not (monde[mondeX].defini) then exit;
    if monde[mondeY].defini
       then mondeLoc := mondeY
       else if monde[mondeDroit].defini
          then mondeLoc := mondeDroit
          else exit;
    for i := 1 to maxCurseur do with curseurOsc[i] do begin
       Pc := TpointF.Create(paintBox.Width/2,paintBox.Height/2);
       isData := false;
       mondeC := mondeLoc;
    end;
    curseurCourant := 1;
    curseurOsc[1].bringToFront;
    curseurOsc[1].repaint;
    result := true;
end;

function TgrapheReg.MondeProche(P:TpointF): indiceMonde;
var
  m: indiceMonde;
begin
  Result := mondeY;
  for m := mondeY to high(indiceMonde) do
    with monde[m] do
      if defini and (P.y > courbeTop) and (P.y < courbeBottom) then
        Result := m;
end;

function TgrapheReg.PointProche(var P:TpointF; indexCourbe: integer;
  limite, Xseul: boolean): integer;
var
  i, idebut, ifin: integer;
  Pint,new: TpointF;
  distance, distanceMin: single;
begin
  Result := -1;
  if indexCourbe < 0 then exit;
  with courbes[indexCourbe] do begin
    if Limite then begin
       iDebut := DebutC;
       iFin := FinC;
    end
    else begin
       iDebut := 0;
       iFin := pred(pages[pageCourante].nmes);
    end;
    distanceMin := 64;
    for i := idebut to ifin do begin
      windowRT(valX[i], valY[i], iMondeC, Pint);
      if Xseul
         then distance := abs(P.X - Pint.x)
         else distance := P.distance(Pint);
      if distance < distanceMin then begin
        distanceMin := distance;
        Result := i;
        new := Pint;
      end;
    end;
    if Result >= 0 then P := new;
  end;
end;

function TgrapheReg.PointProcheGrandeur(var P:TpointF;var indexCourbe : integer;var aMonde: indiceMonde): integer;
var
  i,j,c: integer;
  Pint,new: TpointF;
  distance, distanceMin: single;
  m : indiceMonde;
begin
  Result := -pages[pageCourante].nmes;
  indexCourbe := -1;
  distanceMin := 64;
  m := mondeX;
  c := -1;
  new := P;
  for j := 0 to pred(courbes.Count) do with courbes[j] do begin
    if page<>pageCourante then continue;
    for i := debutC to finC do begin
      windowRT(valX[i], valY[i], iMondeC, Pint);
      distance := P.distance(Pint);
      if distance < distanceMin then begin
        distanceMin := distance;
        Result := i;
        c := j;
        new := Pint;
        m := iMondeC;
      end;
    end;// for i
  end;// for j
  P := new;
  indexCourbe := c;
  aMonde := m;
end;

function TgrapheReg.CourbeProche(var P:TpointF): integer;
var
  i: integer;
  Pint:TpointF;
  distance, distanceMin: single;
  indexCourbe: integer;
begin
  Result := -1;
  distanceMin := 64;
  for indexCourbe := 0 to pred(courbes.Count) do
    with courbes[indexCourbe] do
      if page = pageCourante then begin
        for i := debutC to finC do begin
          windowRT(valX[i], valY[i], iMondeC, Pint);
          distance := P.distance(Pint);
          if distance < distanceMin then begin
            distanceMin := distance;
            Result := indexCourbe;
          end;
        end;
      end;
end;

function TgrapheReg.CourbeModeleProche(var P :TpointF): integer;
var
  i: integer;
  Pint:Tpointf;
  distance, distanceMin: single;
  indexCourbe: integer;
begin
  Result := -1;
  distanceMin := 64;
  for indexCourbe := 0 to pred(courbes.Count) do
    with courbes[indexCourbe] do
      if (indexModele=1) and (page = pageCourante) and not courbeExp then begin
        for i := debutC to finC do begin
          windowRT(valX[i], valY[i], iMondeC,Pint);
          distance := P.distance(Pint);
          if distance < distanceMin then begin
            distanceMin := distance;
            Result := indexCourbe;
          end;
        end;
      end;
end;

procedure TgrapheReg.SetSegmentInt(P:TpointF);
var
  z : integer;
  i : integer;
  g : indiceMonde;
begin
    if not(monde[mondeX].defini) then exit;
    if not(monde[mondeY].defini) and
       not(monde[mondeDroit].defini)
           then exit;
    z := PointProcheGrandeur(P, i, g);
    if curseurOsc[2].visible then begin
    if (z>=0) and (abs(z-curseurOsc[2].Ic)<abs(z-curseurOsc[1].Ic))
      then begin
         CurseurOsc[2].Ic := z;
         CurseurOsc[2].Pc := P;
         CurseurOsc[2].indexCourbe := i;
         CurseurOsc[2].mondeC := g;
         curseurCourant := 2;
      end
      else if z>=0 then begin
         CurseurOsc[1].Ic := z;
         CurseurOsc[1].Pc := P;
         CurseurOsc[1].indexCourbe := i;
         CurseurOsc[1].mondeC := g;
         curseurCourant := 1;
      end;
    end
    else if z >= 0 then begin
       CurseurOsc[1].Ic := z;
       CurseurOsc[1].Pc := P;
       CurseurOsc[1].indexCourbe := i;
       CurseurOsc[1].mondeC := g;
       curseurCourant := 1;
    end;
    if curseurCourant>0 then curseurOsc[curseurCourant].repaint; // Màj
end; // setSegmentInt

function TgrapheReg.PointProcheReal(x, y: double; Acourbe: Tcourbe;
  m: indiceMonde): integer;
var
  distanceMin, delta: double;

  function PointProcheX: integer;
  var
    i: integer;
  begin with Acourbe, monde[mondeX] do begin
      Result := -1;
      case Graduation of
        gLog: distanceMin := power(10,maxi - 0.5);
        gLin: distanceMin := (maxi - mini) / 4;
      end;
      for i := DebutC to FinC do begin
        delta := abs(valX[i] - x);
        if delta < distanceMin then begin
          distanceMin := delta;
          Result := i;
        end;
      end;
    end;
  end;

  function PointProcheY: integer;
  var
    i: integer;
  begin with Acourbe, monde[mondeY] do begin
      Result := -1;
      case Graduation of
        gLog: distanceMin := power(10,maxi - 0.5);
        gdB: distanceMin  := power(10,maxi / 20 - 0.5) - power(10,mini / 20 - 0.5);
        gLin: distanceMin := (maxi - mini) / 4;
      end;
      for i := DebutC to FinC do begin
        delta := abs(valY[i] - y);
        if delta < distanceMin then begin
          distanceMin := delta;
          Result := i;
        end;
      end;
    end;
  end;

begin
  case m of
    mondeX: Result := pointProcheX;
    mondeY: Result := pointProcheY;
    else
      Result := -1;
  end;
end;

procedure TgrapheReg.TraceMotif(P:TpointF; motif: Tmotif);
var Fpath : TPathData;
begin
  case Motif of
    mCroix: begin
      segmentXY(P.x - dimPoint, P.y, P.x + dimPoint, P.y);
      segmentXY(P.x, P.y - dimPoint, P.x, P.y + dimPoint);
    end;
    mCroixDiag: begin
      segmentXY(P.x - dimPoint, P.y - dimPoint, P.x + dimPoint, P.y + dimPoint);
      segmentXY(P.x + dimPoint, P.y - dimPoint, P.x - dimPoint, P.y + dimPoint);
    end;
    mCercle: MyDrawEllipse(P.x - dimPoint, P.y - dimPoint,
        P.x + dimPoint + 1, P.y + dimPoint + 1);
    mCerclePlein: begin
      CreateSolidBrush(canvas.Stroke.Color);
      MyFillEllipse(P.x - dimPoint, P.y - dimPoint,
        P.x + dimPoint + 1, P.y + dimPoint + 1);
    end;
    mCarre: MyDrawRectXY(P.x - dimPoint, P.y - dimPoint,
        P.x + dimPoint, P.y + dimPoint);
    mCarrePlein: begin
      CreateSolidBrush(canvas.Stroke.Color);
      MyFillRectXY(P.x - dimPoint, P.y - dimPoint,
        P.x + dimPoint, P.y + dimPoint);
    end;
    mLosange, mLosangePlein: begin
      FPath := TPathData.Create;
      FPath.moveTo(TpointF.Create(P.x - dimPoint, P.y));
      FPath.lineTo(TpointF.Create(P.x, P.y - dimPoint));
      FPath.lineTo(TpointF.Create(P.x + dimPoint, P.y));
      FPath.lineTo(TpointF.Create(P.x,P.y + dimPoint));
      Fpath.closePath;
      if Motif = mLosangePlein then begin
        CreateSolidBrush(canvas.Stroke.Color);
        canvas.FillPath(Fpath, 1);
      end;
      canvas.drawPath(Fpath,1);
//      FPath.free;
    end;
  end;
end;

procedure TdessinText.Maj;
var P : TpointF;
begin
   agraphe.WindowRT(xReal, yReal, iMonde, p);
   if (Abs(position.X - p.X) > 0.5) or (Abs(position.Y - p.Y) > 0.5) then
      position.point := p;
end;

procedure TdessinLine.Maj;
var P : TpointF;
begin
   agraphe.WindowRT(xReal, yReal, iMonde, P);
   if (Abs(position.X - P.X) > 0.5) or (Abs(position.Y - P.Y) > 0.5) then
      position.point := P;
end;

procedure TGrapheReg.MajDessins;
var c : integer;
begin
   if not grapheOK then exit;
   for c := 0 to pred(DessinTexts.Count) do
       if DessinTexts[c] <> DessinTextCourant then
          DessinTexts[c].Maj;
   for c := 0 to pred(DessinLines.Count) do
       if DessinLines[c] <> DessinLineCourant then
          DessinLines[c].Maj;
end;

procedure TgrapheReg.majNomGr;
var
  i: indiceMonde;
begin
  for i := 1 to maxOrdonnee do
    with coordonnee[i] do begin
      if codeY<nbreGrandeurs then
        nomY := grandeurs[codeY].nom;
      if codeX<nbreGrandeurs then
        nomX := grandeurs[codeX].nom;
    end;
end;

function TgrapheReg.AjusteMonde: boolean;

  procedure AjusteMondeCartesien;

    procedure AjusteMondeLoc(amonde: indiceMonde; valeur: vecteur; Nbre: integer);
    var
      min, max: double;
    begin
      GetMinMax(valeur, Nbre, min, max);
      case monde[amonde].graduation of
        gLin: begin
          if monde[amonde].mini > min then begin
            monde[amonde].Mini := Min;
            Result := True;
          end;
          if monde[amonde].maxi < max then begin
            monde[amonde].Maxi := Max;
            Result := True;
          end;
        end;// linéaire
        gLog: begin
          try
            min := log10(min);
            if monde[amonde].mini > min then begin
              monde[amonde].Mini := Min;
              Result := True;
            end;
          except
          end;
          try
            max := log10(max);
            if monde[amonde].maxi < max then begin
              monde[amonde].Maxi := Max;
              Result := True;
            end;
          except
          end;
        end;{log}
        gdB: begin
          try
            min := log10(min) * 20;
            if monde[amonde].mini > min then begin
              monde[amonde].Mini := Min;
              Result := True;
            end;
          except
          end;
          try
            max := log10(max) * 20;
            if monde[amonde].maxi < max then begin
              monde[amonde].Maxi := Max;
              Result := True;
            end;
          except
          end;
        end;// décibel
      end; // case graduation
    end;

  var
    j: integer;
  begin
    for j := 0 to pred(Courbes.Count) do
      with courbes[j] do begin
        AjusteMondeLoc(imondeC, valY, finC - debutC + 1);
        AjusteMondeLoc(mondeX, valX, finC - debutC + 1);
      end;{j}
  end; // AjusteMondeCartesien

  procedure AjusteMondePolaire;
  var
    j, i: integer;
    rayon, angle, x, y: double;
  begin
    for j := 0 to pred(Courbes.Count) do
      with courbes[j] do begin
        for i := debutC to finC do begin
          angle := valX[i];
          rayon := valY[i];
          angleEnRadian(angle);
          x := rayon * cos(angle);
          with monde[mondeX] do
            if x > Maxi then begin
              Maxi := x;
              Result := True;
            end
            else if x < Mini then begin
              Mini := x;
              Result := True;
            end;
          y := rayon * sin(angle);
          with monde[iMondeC] do
            if y > Maxi then begin
              Maxi := y;
              Result := True;
            end
            else if y < Mini then begin
              Mini := y;
              Result := True;
            end;
        end;{i}
      end;{j}
  end; // AjusteMondePolaire

var
  margeMonde: double;
  j: indiceMonde;
begin
  Result := False;
  if OgPolaire in OptionGraphe
     then AjusteMondePolaire
     else AjusteMondeCartesien;
  if Result then
    for j := MondeY to High(indiceMonde) do begin
      MargeMonde := (monde[j].Maxi - monde[j].Mini) / 64;
      if monde[j].Mini * (monde[j].Mini - MargeMonde) > 0 then
        monde[j].Mini := monde[j].Mini - MargeMonde;
      if monde[j].Maxi * (monde[j].Maxi + MargeMonde) > 0 then
        monde[j].Maxi := monde[j].Maxi + MargeMonde;
    end;
end; // AjusteMonde

procedure TgrapheReg.SetUnitePente(iMonde: indiceMonde);
begin
  UnitePente.UniteDerivee(monde[mondeX].axe, monde[iMonde].axe,
                          monde[mondeX].graduation, monde[iMonde].graduation);
  UnitePente.CoeffAff := monde[mondeX].exposant / monde[iMonde].exposant;
end;

procedure TgrapheReg.chercheMinMax;
begin
  if OgPolaire in OptionGraphe then begin
    miniMod := 0;
    if angleEnDegre
       then maxiMod := 360
       else maxiMod := 2 * pi;
  end
  else with monde[mondeX] do
      case Graduation of
        gLog: begin
          maxiMod := power(10,Maxi);
          miniMod := power(10,Mini);
        end;
        else begin
          maxiMod := Maxi;
          miniMod := Mini;
        end;
      end;{case}
end; // chercheMinMax

function TgrapheReg.isAxeX(P:TpointF): boolean;
begin
  Result := (P.y > limiteCourbe.bottom) and
    (P.y < (limiteCourbe.bottom + hautCarac)) and
    (P.x > limiteCourbe.left) and (P.x <
    (limiteCourbe.right - 8 * largCarac));
end;

Procedure TTransfertGraphe.Ecrit(numero : integer);
var i : integer;
    codeY,Nbre : integer;
begin
    nbre := 0;
    for i := 1 to maxOrdonnee do begin
        codeY := indexNom(nomY[i]);
        if (codeY<>grandeurInconnue) and
           (grandeurs[codeY].genreG=variable)
           then begin
        codeY := indexNom(nomX[i]);
        if (codeY<>grandeurInconnue) and
           (grandeurs[codeY].genreG=variable)
           then inc(Nbre);
           end;
   end;
   if nbre=0 then exit;
   ecritSousSection(1,'DEBUT PAGE'+intTostr(numero));
   ecritIntegerRW3(numero);
   ecritSousSection(Nbre,'LIGNE');
   for i := 1 to Nbre do
       ecritIntegerRW3(ord(ligne[i]));
   ecritSousSection(Nbre,'COULEUR');
   for i := 1 to Nbre do
       ecritColorRW3(couleur[i]);
   ecritSousSection(Nbre,'MOTIF');
   for i := 1 to Nbre do
       ecritIntegerRW3(ord(motif[i]));
   ecritSousSection(Nbre,'X');
   for i := 1 to Nbre do
       ecritLigneRW3U(nomX[i]);
   ecritSousSection(Nbre,'Y');
   for i := 1 to Nbre do
       ecritLigneRW3U(nomY[i]);
   ecritSousSection(Nbre,'TRACE');
   for i := 1 to Nbre do
       ecritIntegerRW3(word(trace[i]));
   ecritSousSection(Nbre,'MONDE');
   for i := 1 to Nbre do
       ecritIntegerRW3(ord(iMonde[i]));
   ecritSousSection(succ(mondeDroit-mondeX),'GRADUATION');
   for i := mondeX to MondeDroit do
       ecritIntegerRW3(ord(grad[i]));
   ecritSousSection(succ(mondeDroit-mondeX),'ZERO');
   for i := mondeX to MondeDroit do
       ecritIntegerRW3(ord(zero[i]));
   ecritSousSection(13,'OPTIONS');
   ecritIntegerRW3(byte(optionGr));{1}
   ecritIntegerRW3(byte(optionModele));{2}
   ecritIntegerRW3(1);{3}
   ecritIntegerRW3(OrdreLissage);{4}
   ecritIntegerRW3(DimPointVGA);{5}
   ecritIntegerRW3(ord(UseDefaut));{6}
   ecritIntegerRW3(ord(UseDefautX));{7}
   ecritIntegerRW3(ord(SuperPage));{8}
   ecritIntegerRW3(ord(TraceEllipse));{9}
   ecritIntegerRW3(-1);{10}
   ecritIntegerRW3(ord(false));{11}
   ecritIntegerRW3(ord(false));{12}
   ecritIntegerRW3(pasPoint);{13}
   ecritSousSection(1,'FIN');
   ecritIntegerRW3(numero);
end;

Procedure TTransfertGraphe.Lit;
var imax : integer;
    i : integer;
    choix : integer;
    zByte : byte;
    zWord : word;
    lectureOK,termine : boolean;
begin // lit
   termine := false;
   while (Length(LigneWin)>0) and (ligneWin[1]=symbReg2) and not termine do begin
      choix := 0;
      imax := NbreLigneWin(ligneWin);
      if pos('X',ligneWin)<>0 then choix := 1;
      if pos('Y',ligneWin)<>0 then choix := 2;
      if pos('MONDE',ligneWin)<>0 then choix := 3;
      if pos('GRADUATION',ligneWin)<>0 then choix := 4;
      if pos('OPTIONS',ligneWin)<>0 then choix := 5;
      if pos('ZERO',ligneWin)<>0 then choix := 6;
      if pos('TRACE',ligneWin)<>0 then choix := 13;
      if pos('COULEUR',ligneWin)<>0 then choix := 16;
      if pos('LIGNE',ligneWin)<>0 then choix := 17;
      if pos('MOTIF',ligneWin)<>0 then choix := 18;
      if pos('FIN PAGE',ligneWin)<>0 then choix := 24;
      lectureOK := true;
      case choix of
           0 : for i := 1 to imax do litLigneWin;
           1 : for i := 1 to imax do begin
                litLigneWinU;
                nomX[i] := LigneWin;
           end;
           2 : for i := 1 to imax do begin
                litLigneWinU;
                nomY[i] := LigneWin;
           end;
           3 : for i := 1 to imax do begin
                litLigneWin;
                if ligneWin[1]=symbReg2
                   then begin
                       lectureOK := false;
                       break;
                   end
                   else begin
                       zByte := StrToInt(ligneWin);
                       iMonde[i] := indiceMonde(zByte);
                   end
           end;
           4 : for i := 1 to imax do begin
                litLigneWin;
                if ligneWin[1]=symbReg2
                   then begin
                       lectureOK := false;
                       break;
                   end
                   else begin
                       zByte := StrToInt(ligneWin);
                       grad[pred(i)] := Tgraduation(zByte);
                   end;    
           end;
           5 : begin
             litLigneWin; {1}
             optionGr := TsetOptionGraphe(byte(strToInt(ligneWin)));
             litLigneWin; {2}
             optionModele := TsetOptionModele(byte(strToInt(ligneWin)));
             litLigneWin; {3}
             litLigneWin; {4}
             OrdreLissage := strToInt(ligneWin);
             litLigneWin; {5}
             DimPointVGA := strToInt(ligneWin);
             useDefaut := litBooleanWin; {6}
             useDefautX := litBooleanWin; {7}
             superPage := litBooleanWin; {8}
             traceEllipse := litBooleanWin; {9}
             litLigneWin;{10}
             litBooleanWin; {11}
             litBooleanWin; {12}
             PasPoint := litIntegerRW3; {13 }
             for i := 14 to imax do litLigneWin;
           end;
           6 : for i := 1 to imax do
                zero[pred(i)] := litBooleanWin;
           13 : for i := 1 to imax do begin
                 zWord := litIntegerRW3;
                 trace[i] := TsetTrace(zWord);
           end;
           16 : for i := 1 to imax do
                couleur[i] := litColorRW3;
           17 : for i := 1 to imax do begin
               zByte := litIntegerRW3;
               ligne[i] := Tligne(zByte);
           end;
           18 : for i := 1 to imax do begin
               zByte := litIntegerRW3;
               motif[i] := Tmotif(zByte);
           end;
           24 : begin
                litLigneWin;
                termine := true;
           end;
       end; { case }
       if lectureOK then litLigneWin;
    end;
end; // lit

function TgrapheReg.WindowX(xr: double): single;
begin
  case monde[mondeX].graduation of
    gLog: xr := Log10(xr);
  end;
  Result := monde[mondeX].affecte(xr);
end;

function TgrapheReg.WindowY(yr: double;m : indiceMonde): single;
begin
  case monde[m].graduation of
      gLog: yr := Log10(yr);
      gdB: if yr < monde[m].minidB
         then yr := 20 * log10(monde[m].minidB)
         else yr := 20 * Log10(yr);
  end;
  Result := monde[m].affecte(yr);
end;

procedure TgrapheReg.CreateSolidBrush(couleur : TAlphaColor);
begin
     canvas.Fill.kind := TBrushKind.Solid;
     canvas.Fill.Color := couleur;
end;

procedure TgrapheReg.SetTextAlign(alH,alV : TTextAlign);
begin
   layout.HorizontalAlign := alH;
   layout.VerticalAlign := alV;
end;

procedure TgrapheReg.CreatePen(aStyle : TStrokeDash;aWidth  : single;couleur : TAlphaColor);
begin
   canvas.Stroke.Dash := astyle;
   canvas.stroke.Color := couleur;
   canvas.stroke.Thickness := awidth;
end;

procedure TgrapheReg.changeEchelleX(xnew, xold: single);
begin
  with monde[mondeX] do begin
    xnew := xnew - limiteCourbe.left;
    if xnew < 16 then
      exit;
    xold := xold - limiteCourbe.left;
    A := A * xnew / xold;
    Maxi := Mini + (limiteCourbe.right - limiteCourbe.left) / A;
    MaxDefaut := Maxi;
  end;
end;

procedure Tcourbe.Calcul;
var
  indexZero1, indexZero2,debut: integer;

  procedure CherchePeriode;
  var
    signe: double;
    iMax:  integer;
    indexZero : integer;
    t1,t2 : double;
  begin
    indexZero1 := debut;
    signe := valY[debut] - valeurMoy;
    if signe = 0 then
      signe := -1;
    iMax := debutC + (finC - debut) div 2;
    while (indexZero1 < iMax) and
          ((valY[indexZero1] - valeurMoy) * signe >= 0) do
         Inc(indexZero1);
    // Premier passage par "zéro" (vers le bas par ex.)
    signe := valY[indexZero1] - valeurMoy;
    if signe = 0 then signe := -1;
    indexZero2 := indexZero1 + 8;
    while (indexZero2 < (finC - 8)) and
          ((valY[indexZero2] - valeurMoy) * signe >= 0) do
      Inc(indexZero2);
    // On repasse par "zéro" dans le sens opposé
    indexZero2 := indexZero2 + 7;
    while (indexZero2 > finC) and
          ((valY[indexZero2] - valeurMoy) * signe <= 0) do
      Inc(indexZero2);
    // On repasse par "zéro" dans le même sens
    if indexZero2 < finC then
       periode := valX[indexZero2] - valX[indexZero1];
    try
    if indexZero1>debut // pred() possible
        then indexZero := pred(indexZero1)
        else indexZero := succ(indexZero1);
    t1 := valX[indexZero1] -
          (valX[indexZero1]-valX[indexZero])*
          (valY[indexZero1]-valeurMoy)/(valY[indexZero1]-valY[indexZero]);
    except
    t1 := Nan;
    end;
    try
    indexZero := pred(indexZero2);
    t2 := valX[indexZero2] -
           (valX[indexZero2]-valX[indexZero])*
           (valY[indexZero2]-valeurMoy)/(valY[indexZero2]-valY[indexZero]);
    except
    t2 := Nan
    end;
    if not isNan(t2) and  not isNan(t1) then periode := t2-t1;
  end;

var
  i, N : integer;
  sommeEff, sommeMoy, zz: double;
begin
  debut := debutC;
  while (debut<finC) and isNan(valY[debut]) do inc(debut);
  N := succ(finC - debut);
  valeurEff := Nan;
  periode := Nan;
  valeurMax := valY[debut];
  valeurMin := valY[debut];
  for i := succ(debut) to finC do begin
    zz := valY[i];
    if zz > valeurMax then
      valeurMax := zz
    else if zz < valeurMin then
      valeurMin := zz;
  end;
  valeurMoy := (valeurMax + valeurMin) / 2;
  if N < 16 then
    exit;
  CherchePeriode;
  if indexZero2 >= finC then
    exit;
  SommeEff := 0;
  SommeMoy := 0;
  N := succ(indexZero2 - indexZero1);
  for i := indexZero1 to indexZero2 do begin
    zz := valY[i];
    SommeEff := SommeEff + sqr(zz);
    SommeMoy := SommeMoy + zz;
  end;
  valeurEff := sqrt(SommeEff / N);
  valeurMoy := sommeMoy / N;
end; // Tcourbe.Calcul

procedure TDessinText.SetPourCent(var i: integer);
  var
    posPourCent: integer;
    LigneTexte:  string;

    procedure SetLoc(Agrandeur: Tgrandeur; valeur: double; Nbre: integer);
    begin
      Delete(LigneTexte, posPourCent, Nbre);
      Insert(Agrandeur.formatNomEtUnite(valeur), LigneTexte, posPourCent);
    end;

    procedure SetParam(i,nbre : integer);
    begin
      Delete(LigneTexte, posPourCent, Nbre);
      Insert(pages[PageCourante].paramEtPrec(i,false), LigneTexte, posPourCent);
    end;

    procedure PosCode(code: string; numero: integer);
    begin
      code := '%' + code;
      if numero >= 0 then
         code := code + char(Ord('0') + numero);
      posPourCent := pos(code, AnsiUpperCase(LigneTexte));
    end;

  var
   j: integer;
   posEt: integer;
   LignePrec: string;
  begin
    posCode('X', -1);
    posCode('Y', -1);
    posCode('S', -1);
    if posPourCent > 0 then begin
      Delete(LigneTexte, posPourCent, 3);
      Insert(pages[PageCourante].commentaireP, LigneTexte, posPourCent);
    end;
    for j := 1 to NbreParam do begin
      posCode('P', j);
      if posPourCent > 0 then
        SetParam(j,3);
    end;
    for j := 1 to NbreModele do with FonctionTheorique[j] do begin
      posCode('M', j);
      if posPourCent > 0 then begin
         Delete(LigneTexte, posPourCent, 3);
         Insert(grandeurs[indexY].nom+'('+grandeurs[indexX].nom+')='+expression, LigneTexte, posPourCent);
         // cdot nécessite Arial Unicode
         // mais les lettres grecques sont atroces
         repeat
               posEt := pos('*',ligneTexte);
               if posEt>0 then ligneTexte[posEt] := pointMedian;
         until posEt=0;
         repeat
               posEt := pos('+',ligneTexte);
               if posEt>0 then  ligneTexte[posEt] := '@';
         until posEt=0;
         repeat
               posEt := pos('@',ligneTexte);
               if posEt>0 then begin
                  delete(ligneTexte,posET,1);
                  insert(' + ',ligneTexte,posEt);
               end;
         until posEt=0;
         with pages[pageCourante] do LignePrec := stSigmaY+
                        addrY.formatNomEtUnite(sigmay);
      end;
    end;
    for j := 0 to pred(NbreConst) do begin
      posCode('C', j + 1);
      if posPourCent > 0 then
        setLoc(
          Grandeurs[indexConst[j]],
          Pages[PageCourante].ValeurConst[indexConst[j]], 3);
    end;
    if lignePrec<>'' then begin
       inc(i);
    end;
end; // SetPourCent

Procedure TlistePic.Nettoie(fMax : double);

procedure supprime(k : integer);
var i : integer;
begin
     dec(nbre);
     for i := k to pred(nbre) do
         pics[i] := pics[i+1];

end;

var deltaf : double;
    k : integer;
begin
    deltaf := fMax / 64;
    k := 0;
    while (k<nbre) do begin
        if (pics[k+1].valeurF-pics[k].valeurF)<deltaf
           then if (pics[k+1].valeurH>pics[k].valeurH)
               then supprime(k)
               else supprime(k+1)
        else inc(k);
    end;
end;

Procedure TlistePic.Tri;
// Tri Shell Meyer-Baudoin p 456 selon valeurH
var increment : integer;
    cle : double;
    sauvePic : Tpic;
    i,j,k : integer;
Begin
   increment := 1;
   while ( increment<(Nbre div 3) ) do increment := succ(3*increment);
   repeat
	  for k := 0 to pred(increment) do begin
		  i := increment+k;
		  while (i<Nbre) do begin
			  sauvePic := pics[i];
			  cle := pics[i].valeurH;
			  j := i-increment;
			  while (j>=0) and (pics[j].valeurH<cle) do begin
				  pics[j+increment] := pics[j];
				  dec(j,increment);
			  end;
			  pics[j+increment] := sauvePic;
			  inc(i,increment);
		   end;
	  end;
	  increment := increment div 3;
   Until increment=0;
   if nbre>NbreHarmoniqueAffMax then nbre := NbreHarmoniqueAffMax;
end;

procedure TListePic.Add(valF,valH : double);
begin
    if Nbre>=NbreMax then begin
       NbreMax := Nbre+128;
       setLength(pics,NbreMax);
    end;
    pics[Nbre].valeurF := valF;
    pics[Nbre].valeurH := valH;
    inc(Nbre);
end;

procedure TListePic.RemoveLast;
begin
    if Nbre>0 then dec(nbre);
end;

procedure TListePic.Clear;
begin
  setLength(pics,0);
  nbre := 0;
  nbreMax := 0;
end;

function TListePic.proche(x,y : double;xmax,ymax : double) : integer;
var i : integer;
    ecart,ecartMin,coeffX : double;
begin
    result := -1;
    coeffX := 1/xmax; // >0 !
    ecartMin := 0.02;
    for i := 0 to nbre - 1 do begin
        ecart := abs(x-pics[i].valeurF)*coeffX;
        if ecart<ecartMin then begin
           ecartMin := ecart;
           result := i;
        end;
    end;
end;

procedure TGrapheReg.MyDrawText(P : tpointF;S : string);
const
   PadW = 6;
   PadH = 4;
var L,H,dX,dY : single;
begin
   if S = '' then Exit;
   layout.BeginUpdate;
   layout.WordWrap := False;
   layout.MaxSize := TPointF.Create(10000, 10000);
   layout.Color := couleurTexte;
   layout.Text := S;
   layout.EndUpdate;
   L := layout.TextWidth;
   H := layout.TextHeight;
   if L < Canvas.TextWidth(S) then L := Canvas.TextWidth(S);
   if H < Canvas.TextHeight(S) then H := Canvas.TextHeight(S);
   L := L + PadW;
   H := H + PadH;
   if layout.verticalAlign=TTextAlign.Trailing
       then dY := - H
       else if layout.verticalAlign=TTextAlign.Center
            then dY := - H/2
            else dY := 0;
   if layout.horizontalAlign=TTextAlign.Trailing
       then dX := - L
       else if layout.horizontalAlign=TTextAlign.Center
            then dX := - L/2
            else dX := 0;
   P.Offset(dX,dY);
   layout.BeginUpdate;
   layout.TopLeft := P;
   layout.MaxSize := TPointF.Create(L, H);
   layout.EndUpdate;
   layout.RenderLayout(Canvas);
end;

procedure TGrapheReg.MyFillText(P : tpointF;S : string;couleurFond : TAlphaColor);
const
   PadW = 6;
   PadH = 4;
var L,H : single;
begin
   if S = '' then Exit;
   layout.BeginUpdate;
   layout.WordWrap := False;
   layout.MaxSize := TPointF.Create(10000, 10000);
   layout.Color := couleurTexte;
   layout.Text := S;
   layout.EndUpdate;
   L := layout.TextWidth;
   H := layout.TextHeight;
   if L < Canvas.TextWidth(S) then L := Canvas.TextWidth(S);
   if H < Canvas.TextHeight(S) then H := Canvas.TextHeight(S);
   L := L + PadW;
   H := H + PadH;
   canvas.Fill.kind := TBrushKind.Solid;
   canvas.Fill.Color := couleurFond;
   MyFillRectXY(P.X,P.Y,P.X+L,P.Y+H);
   canvas.Fill.kind := TBrushKind.None;
   layout.BeginUpdate;
   layout.TopLeft := P;
   layout.MaxSize := TPointF.Create(L, H);
   layout.EndUpdate;
   layout.RenderLayout(Canvas);
end;

procedure TGrapheReg.MyDrawRect(arect : TrectF);
(*
procedure DrawRect(const ARect: TRectF; const XRadius, YRadius: Single;
const ACorners: TCorners;  const AOpacity: Single; const ACornerType:
TCornerType = TCornerType.ctRound); virtual; abstract;
*)

begin
     canvas.DrawRect(Arect,0,0,AllCorners,1);
end;

procedure TGrapheReg.MyDrawRectXY(x1,y1,x2,y2 : single);
var t : single;
begin
     if x1 > x2 then begin t := x1; x1 := x2; x2 := t; end;
     if y1 > y2 then begin t := y1; y1 := y2; y2 := t; end;
     canvas.DrawRect(TrectF.Create(x1,y1,x2,y2),0,0,AllCorners,1)
end;

procedure TGrapheReg.MyDrawEllipse(x1,y1,x2,y2 : single);
begin
     canvas.DrawEllipse(TrectF.create(x1,y1,x2,y2),1)
end;

procedure TGrapheReg.MyFillRect(arect : TrectF);
begin
     canvas.FillRect(Arect,0,0,AllCorners,1)
end;

procedure TGrapheReg.MyFillRectXY(x1,y1,x2,y2 : single);
var t : single;
begin
     if x1 > x2 then begin t := x1; x1 := x2; x2 := t; end;
     if y1 > y2 then begin t := y1; y1 := y2; y2 := t; end;
     canvas.FillRect(TrectF.Create(x1,y1,x2,y2),0,0,AllCorners,1)
end;

procedure TGrapheReg.MyFillEllipse(x1,y1,x2,y2 : single);
begin
     canvas.FillEllipse(TrectF.create(x1,y1,x2,y2),1);
end;

procedure TGrapheReg.setFontSize(asize : single);
begin
     asize := 2*round(asize/2);
     if asize<10 then asize := 10;
     if asize>20 then asize := 20;
     canvas.font.size := asize;
     layout.font.Size := asize;
end;

Procedure TGrapheReg.NotifyText(sender:TObject;const item :TDessinText;action : TCollectionNotification);
begin
   if action=cnRemoved then begin
      paintBox.RemoveObject(item);
   end;
   if action=cnAdded then begin
      paintBox.AddObject(item);
      item.bringToFront;
      paintBox.Repaint;
   end;
   if action=cnExtracted then begin
      paintBox.RemoveObject(item);
   end;
end;

Procedure TGrapheReg.NotifyLine(sender:TObject;const item :TDessinLine;action : TCollectionNotification);
begin
   if action=cnRemoved then begin
      paintBox.RemoveObject(item);
   end;
   if action=cnAdded then begin
      paintBox.AddObject(item);
      item.bringToFront;
      paintBox.Repaint;
   end;
   if action=cnExtracted then begin
      paintBox.RemoveObject(item);
   end;
end;

procedure TDessinText.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
   x0 := x;
   y0 := y;
   opacity := 0.5;
   aGraphe.dessinTextCourant := self;
   inherited;
end;

procedure TDessinText.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    aGraphe.mondeRT(position.point, iMonde, xReal, yReal);
    inherited;
end;

procedure TDessinText.MouseMove(Shift: TShiftState;
         X,Y: single);
begin
    if ssLeft in Shift then begin
       position.x := position.x + (x-x0);
       position.y := position.y + (y-y0);
       x0 := x;
       y0 := y;
    end
    else begin
       agraphe.paintBox.cursor := crHandPoint;
    end;
    inherited;
end;

procedure TDessinText.MouseEnter;
begin
   x0 := 0;
   y0 := 0;
   agraphe.paintBox.cursor := crHandPoint;
end;

procedure TDessinText.MouseLeave;
begin
   aGraphe.paintBox.cursor := crDefault;
   opacity := 1;
   agraphe.DessinTextCourant := nil;
end;

procedure TDessinText.DblClick;
begin
    if litOption then aGraphe.paintBox.Repaint;
end;

procedure TDessinLine.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var ecartX,ecartY : single;
begin
   opacity := 0.5;
   stroke.thickness :=  stroke.thickness+3;
   ecartX := x/width;
   ecarty := y/height;
   selection := sdNone;
   if (ecartX<0.2) and (ecartY<0.2)
      then selection := sdPoint1
      else if (ecartX>0.8) and (ecartY>0.8)
          then selection := sdPoint2;
          (*
          else if (ecartX<0.6) and (ecartX>0.4) and
                  (ecartY<0.6) and (ecartY>0.4) then selection := sdCentre; *)
   aGraphe.dessinLineCourant := self;
   inherited;
end;

procedure TDessinLine.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    selection := sdNone;
    opacity := 1;
    stroke.thickness :=  stroke.thickness-3;
    aGraphe.dessinLineCourant := nil;
    inherited;
end;

procedure TDessinLine.MouseEnter;
begin
    aGraphe.paintBox.cursor := crHandPoint;
end;

procedure TDessinLine.MouseLeave;
begin
    aGraphe.paintBox.cursor := crDefault;
    opacity := 1;
    aGraphe.dessinLineCourant := nil;
end;

procedure TDessinLine.affecteXY(X,Y: single);
begin
    case selection of
       sdPoint1 : affectePoint1(x,y);
       sdPoint2 : affectePoint2(x,y);
       sdCentre : ;
    end;
end;

procedure TDessinLine.DblClick;
begin
    if litOption then aGraphe.paintBox.Repaint;
end;

procedure TDessinLine.AffectePoint1(X,Y: single);
begin
    position.x := x;
    position.y := y;
    aGraphe.mondeRT(position.point,iMonde,xReal,yReal)
end;

procedure TDessinLine.AffectePoint2(X,Y: single);
var aWidth,aheight : single;
begin
    awidth := x-position.x;
    aheight := y-position.y;
   // Ne trace rien si width or height < 0 !
    if aWidth<0
       then if aHeight<0
          then begin
              rotationAngle := 180;
              width := abs(aWidth);
              height := abs(aHeight);
          end
          else begin
              rotationAngle := 90;
              width := aHeight;
              height := abs(aWidth);
          end
       else if aHeight<0
          then begin
              rotationAngle := -90;
              width := abs(aHeight);
              height := aWidth;
          end
          else begin
              rotationAngle := 0;
              width := aWidth;
              height := aHeight;
          end;
end;

procedure TDessinText.AffecteXY(X,Y: single);
begin
    position.x := x;
    position.y := y;
    aGraphe.mondeRT(position.point,iMonde,xReal,yReal)
end;

procedure TDessinText.Paint;
var R : TrectF;
begin
   R := TrectF.create(0,0,width,height);
   if avecCadre then begin
      canvas.Stroke.Color := color;
      canvas.Stroke.Thickness := 1;
      canvas.drawRect(R,0,0,AllCorners,1);
   end;
   if couleurFond<>claWhite then begin
      canvas.Fill.Color := couleurFond;
      canvas.Fill.kind := TBrushKind.Solid;
      canvas.fillRect(R,0,0,AllCorners,1);
   end
   else canvas.Fill.kind := TBrushKind.None;
   inherited;
end;

procedure TDessinLine.Paint;

 procedure TraceFleche(debut: boolean);
    var
      Points:  TPolygon;
      p1,p,pDelta : TpointF;
      signe : single;
    begin
// P = bout de la flèche
      pDelta := TpointF.create(width,height).normalize;
      if debut
         then begin
            p := TPointF.create(0,0);
            signe := 1;
         end
         else begin
            p := TPointF.create(width,height);
            signe := -1;
         end;
      P1 := P;
      P1.offset(signe*Pdelta.X*12,signe*Pdelta.Y*12);
// P1 = centre de la base de la flèche
      setLength(Points,4);
      Points[0] := P;
      Points[1] := TPointF.create(P1.x - signe*Pdelta.y*4, P1.y + signe*Pdelta.x*4);
      Points[2] := TPointF.create(P1.x + signe*Pdelta.y*4, P1.y - signe*Pdelta.x*4);
      Points[3] := P;  // on ferme
      canvas.DrawPolygon(Points,1); // triangle 3 points
      Finalize(Points);
    end;

var dX,dY,a,b : double;
    str : string;
    pfin : TpointF;
    L,H : single;
    x1,y1,x2,y2 : double;
begin
    inherited;
    Agraphe.windowRT(xReal,yReal, iMonde, pfin);
    x1 := xReal;
    y1 := yReal;
    pfin.Offset(width,height);
    Agraphe.mondeRT(pfin, iMonde, x2, y2);
    case TexteLigne of
      tlNone : str := '';
      tlEcartY: if height<>0 then begin
            with Agraphe.monde[MondeY] do
              case Graduation of
                gLog: dY := log10(y2 / y1);
                gLin: dY := y2 - y1;
                gdB: dY  := 20 * log10(y2 / y1);
                else dY := 0;
              end;
            str := DeltaMaj+Agraphe.monde[mondeY].axe.formatNomEtUnite(dY);
      end;
      tlEcartX: if width<>0 then begin
            with Agraphe.monde[mondeX] do
              case Graduation of
                gLog: dX := log10(x2 / x1);
                gLin: dX := x2 - x1;
                else dX := 0;
              end;
            str := DeltaMaj+Agraphe.monde[mondeX].axe.formatNomEtUnite(dX);
      end;
      tlPente: if width<>0 then begin
            Agraphe.setUnitePente(MondeY);
            with Agraphe.monde[MondeY] do
              case Graduation of
                gLog: dY := log10(y2 / y1);
                gLin: dY := y2 - y1;
                gdB: dY  := 20 * log10(y2 / y1);
                else dY := 0;
              end;
            with Agraphe.monde[mondeX] do
              case Graduation of
                gLog: dX := log10(x2 / x1);
                gLin: dX := x2 - x1;
                else dX := 1;
              end;
            str := Agraphe.unitePente.formatPente(dY / dX);
          end;
      tlEquation: if width < 1
          then str := Agraphe.monde[mondeX].axe.formatNomEtUnite((x1 + x2) / 2)
          else if height < 1
          then str := Agraphe.monde[MondeY].axe.formatNomEtUnite((y1 + y2) / 2)
          else begin
            a := (y2 - y1) / (x2 - x1);
            b := y2 - a * x2;
            str := Agraphe.monde[MondeY].axe.nom + '=' +
              formatReg(b) + '+' +
              formatReg(a) + pointMedian + Agraphe.monde[mondeX].axe.nom;
          end;
      end; // case TexteLigne
  if str<>'' then begin
     agraphe.layout.BeginUpdate;
     agraphe.layout.WordWrap := False;
     agraphe.layout.MaxSize := TPointF.Create(10000, 10000);
     agraphe.layout.Color := couleurLigne;
     agraphe.layout.Text := Str;
     agraphe.layout.EndUpdate;
     L := agraphe.layout.TextWidth;
     H := agraphe.layout.TextHeight;
     if L < Canvas.TextWidth(Str) then L := Canvas.TextWidth(Str);
     if H < Canvas.TextHeight(Str) then H := Canvas.TextHeight(Str);
     agraphe.layout.BeginUpdate;
     agraphe.layout.TopLeft := TPointF.Create(width/2, Height/2);
     agraphe.layout.MaxSize := TPointF.Create(L + 6, H + 4);
     agraphe.layout.EndUpdate;
     agraphe.layout.RenderLayout(Canvas);
  end;
  case motifLigne of
       mlNone: ;
       mlFlecheDebut: traceFleche(false);
       mlFlecheFin: traceFleche(true);
       mlDoubleFleche: begin
          traceFleche(true);
          traceFleche(false);
       end;
  end;
end;

function Tequivalence.TexteX : string;
var XNom,XVal : string;
begin
    XNom := agraphe.monde[mondeX].axe.nom;
    XVal := agraphe.monde[mondeX].axe.formatValeurEtUnite(ve);
    result := XNom+'='+XVal+' ';
end; // TexteX

function Tequivalence.TexteY : string;
var YNom,YVal : string;
    yr : double;
begin
    YNom := agraphe.monde[mondepH].axe.nom;
    if agraphe.monde[mondepH].graduation=gdB
         then begin
            yr := 20*log10(phe);
            YVal := FloatToStrF(Yr,ffGeneral,3,0)+' dB';
         end
         else YVal := agraphe.monde[mondepH].axe.formatValeurEtUnite(phe);
    result := YNom+'='+YVal+' ';
end; // TextY

procedure TGrapheReg.ResetEquivalence;
var p: codePage;
begin
  for p := 1 to MaxPages do
      equivalences[p].Clear;
end;

procedure TgrapheReg.VersPressePapier;
var
  Svc: IFMXClipboardService;
  abitmap : Tbitmap;
begin
    if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc) then
    begin
      try
        aBitmap := ZoneClipBoard.MakeScreenshot;
        Svc.SetClipboard(Abitmap);
        abitmap.free;
      finally
      end;
    end;
end;

procedure TcurseurDonnees.paint;

   procedure AffecteCurseurData;
   begin
          if indexCourbe<0 then indexCourbe := 0;
          with graphe.courbes[indexCourbe] do begin
            mondeC := imondeC;
            if (Ic < debutC) or (Ic > finC) then Ic := numero*(finC + debutC) div 3;
            Xr := valX[Ic];
            Yr := valY[Ic];
            graphe.windowRT(Xr, Yr, iMondeC, Pc);
          end;
   end;

   begin
     if (mondeC=mondeX) or not graphe.grapheOK then exit;
     width := graphe.limiteFenetre.width;
     height := graphe.limiteFenetre.height;
     if isData
        then affecteCurseurData
        else graphe.mondeRT(Pc, mondeC, Xr, Yr);
     if coY in graphe.OptionCurseur then begin
        if graphe.monde[mondeC].graduation = gdB
            then texteY := graphe.monde[mondeC].Axe.nom + '=' + formatGeneral(
                 20 * log10(yr), precisionMin) + ' dB'
            else texteY := graphe.monde[mondeC].Axe.formatValeurEtUnite(Yr);
     end
     else texteY := '';
     if coX in graphe.OptionCurseur
        then texteX := graphe.monde[mondeX].Axe.formatValeurEtUnite(Xr)
        else texteX := '';
     centre := Pc;
     inherited paint;
end;

constructor TcurseurDonnees.CreateCurseur(Agraphe: TgrapheReg);
begin
    inherited create(agraphe.paintBox);
    graphe := aGraphe;
    indexCourbe := 0;
    mondeC := mondeY;
    Visible := false;
    Complet := true;
    isVert := true;
    isHoriz := true;
    Ic := -1;
end;

{$I axes}

{$I equival}

end.

