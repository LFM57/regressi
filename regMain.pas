unit regMain;

interface

Uses
  System.SysUtils,
  System.Types,
  System.IOUtils,
  System.UITypes,
  System.UIConsts,
  System.Classes,
  System.Math,
  System.Character,
  System.Actions,
  System.Generics.Collections,
  System.IniFiles,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
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
  FMX.Printer,
  FMX.ActnList,
  FMX.Gestures,
  FMX.Effects,
  FMX.Graphics,
  FMX.Filter.Effects,
  FMX.DialogService,
  FMX.ScrollBox,
  FMX.Controls.Presentation,
  
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
  FMX.TMSFNCGrid,

  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,

  compile,
  constreg,
  coordphys,
  fft,
  graphker,
  grapheVariabU,
  grapheParamU,
  maths,
  regutil,
  uniteker,
  valeurs,
{$IFDEF HAS_FFMPEG}
  avlib,
{$ENDIF}
  images,
  aideU,
  printPdfU,

  FMX.Memo.Types;

const
   maxMRU = 7;

type
  TFRegressiMain = class(TForm)
    FileItem: TMenuItem;
    FileNewItem: TMenuItem;
    FileOpenItem: TMenuItem;
    HelpItem: TMenuItem;
    FileSaveItem: TMenuItem;
    FileSaveAsItem: TMenuItem;
    EditionItem: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    PagesItem: TMenuItem;
    PageSuivItem: TMenuItem;
    PagePrecItem: TMenuItem;
    PageDelItem: TMenuItem;
    DeleteItem: TMenuItem;
    FilePrintItem: TMenuItem;
    FileNewClavierItem: TMenuItem;
    MruSeparator: TMenuItem;
    FileAddItem: TMenuItem;
    FileNewClipItem: TMenuItem;
    N1: TMenuItem;
    CollerPageItem: TMenuItem;
    CollerNewDocItem: TMenuItem;
    PageTrierItem: TMenuItem;
    PageSelectItem: TMenuItem;
    SaveDialog: TSaveDialog;
    PageNewClipItem: TMenuItem;
    UtilisateurSepar: TMenuItem;
    OpenDialog: TOpenDialog;
    UndoItem: TMenuItem;
    RecupItem: TMenuItem;
    WebItem: TMenuItem;
    ListeRegItem: TMenuItem;
    PanelPage: TPanel;
    PagePrecBtn: TSpeedButton;
    PagesBtn: TSpeedButton;
    PageSuivBtn: TSpeedButton;
    CommentaireEdit: TEdit;
    PageAddBtn: TSpeedButton;
    TOCitem: TMenuItem;
    PanelNumPage: TLabel;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem0: TMenuItem;
    PageNewItem: TMenuItem;
    WindowTab: TTabControl;
    ValeursTab: TTabItem;
    GrapheTab: TTabItem;
    FFTtab: TTabItem;
    StatTab: TTabItem;
    ValeursPanel: TPanel;
    GraphePanel: TPanel;
    FourierPanel: TPanel;
    StatistiquePanel: TPanel;
    MemoVocabulaire: TMemo;
    PanelValeursStat: TGroupBox;
    PaintBoxStat: TPaintBox;
    StatPopupMenu: TPopupMenu;
    CopyGrapheStatItem: TMenuItem;
    OptionsStatItem: TMenuItem;
    CopyGridItem: TMenuItem;
    ImprimeStatItem: TMenuItem;
    PanelCentral: TPanel;
    GrapheToolBar: TToolBar;
    CurseurBtn: TButton;
    CoordonneesBtn: TButton;
    ZoomAutoBtn: TButton;
    ZoomBtn: TButton;
    ZoomArrBtn: TButton;
    VecteursBtn: TButton;
    ModeleBtn: TButton;
    PaintBox1: TPaintBox;
    SplitterResidu: TSplitter;
    PaintBoxResidu: TPaintBox;
    PanelModele: TPanel;
    PanelAjuste: TPanel;
    ParamScrollBox: TScrollBox;
    Panel1: TPanel;
    AjusteBtn: TButton;
    TraceAutoCB: TCheckBox;
    MemoResultat: TMemo;
    ModeleToolBar: TToolBar;
    OptionsModeleBtn: TButton;
    ModeleGrBtn: TButton;
    BornesBtn: TButton;
    InitEquaDiffBtn: TButton;
    PopupMenuModele: TPopupMenu;
    FermerItem: TMenuItem;
    PrintModele: TMenuItem;
    RaZModele: TMenuItem;
    ResidusItem: TMenuItem;
    OptionsModele: TMenuItem;
    intersectionTer: TMenuItem;
    BornesMenu: TPopupMenu;
    Inter1: TMenuItem;
    Inter2: TMenuItem;
    Inter3: TMenuItem;
    Inter4: TMenuItem;
    RazBornes: TMenuItem;
    IntersectionItem: TMenuItem;
    CurseurMenu: TPopupMenu;
    SelectItem: TMenuItem;
    CurTexteItem: TMenuItem;
    CurLigneItem: TMenuItem;
    CurGommesItem: TMenuItem;
    CurReticuleItem: TMenuItem;
    curDataItem: TMenuItem;
    CurOrigineItem: TMenuItem;
    addModeleItem: TMenuItem;
    MenuAxes: TPopupMenu;
    CoordonneesItem: TMenuItem;
    ModeleItem: TMenuItem;
    IncertItem: TMenuItem;
    LegendeItem: TMenuItem;
    ProprieteCourbe: TMenuItem;
    SaveGraphItem: TMenuItem;
    PrintGraphItem: TMenuItem;
    IntersectionBis: TMenuItem;
    CopierGrapheItem: TMenuItem;
    VecteursMenu: TPopupMenu;
    VitesseItem: TMenuItem;
    AccelerItem: TMenuItem;
    VitesseAccItem: TMenuItem;
    NoVecteursItem: TMenuItem;
    OptionsVecteursMenu: TMenuItem;
    GrapheSaveDialog: TSaveDialog;
    ActionList1: TActionList;
    InitEquaDiffAction: TAction;
    Cercle: TCircle;
    TrigoBtn: TButton;
    BornesAction: TAction;
    ModelesAction: TAction;
    GrecItem: TMenuItem;
    GrecAction: TAction;
    StatusBar: TStatusBar;
    Aide: TLabel;
    LineTransitionEffect1: TLineTransitionEffect;
    LineX: TLine;
    LineY: TLine;
    MainMenu: TMainMenu;
    RegressiItem: TMenuItem;
    OptionsItem: TMenuItem;
    FiltreItem: TMenuItem;
    ExitItem: TMenuItem;
    AboutItem: TMenuItem;
    ControlAction: TAction;
    ModeleIncertItem: TMenuItem;
    Lang1: TLang;
    TangenteItem: TMenuItem;
    GestureManager1: TGestureManager;
    FileNewSimulationItem: TMenuItem;
    OptionStatBtn: TButton;
    RazTgItem: TMenuItem;
    fileCloseItem: TMenuItem;
    TimerDemarrage: TTimer;
    ZoneClipBoard: TRectangle;
    ZoneClipBoardStat: TRectangle;
    PrintPdfItem: TMenuItem;
    SaveGrapheStatItem: TMenuItem;
    LangItem: TMenuItem;
    FrenchMenu: TMenuItem;
    EnglishMenu: TMenuItem;
    MemoModele: TMemo;
    TimerStat: TTimer;
    EnglishAction: TAction;
    FrenchAction: TAction;
    EditBidon: TEdit;
    VideoItem: TMenuItem;
    timerLoupe: TTimer;
    ExemplesItem: TMenuItem;
    ImageItem: TMenuItem;
    ArduinoItem: TMenuItem;
    OscilloArduinoItem: TMenuItem;
    ChronoPhotoMenu: TMenuItem;
    PanelAnimation: TPanel;
    TimerAnimation: TTimer;
    AnimationTB: TTrackBar;
    StopAnimBtn: TButton;
    PlayAnimBtn: TButton;
    PrecedentAnimBtn: TButton;
    SuivantAnimBtn: TButton;
    AnimationBtn: TButton;
    TitreAnimCB: TCheckBox;
    AideItem: TMenuItem;
    StatGrid: TTMSFNCGrid;
    DistGrid: TTMSFNCGrid;
    PanelStatGrid: TPanel;
    ListeNom: TComboBox;
    SplitterStat: TSplitter;
    LayoutVocabulaire: TLayout;
    ParamGrid: TTMSFNCGrid;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    SaveCSVItem: TMenuItem;
    OptiqueItem: TMenuItem;
    CurModeleItem: TMenuItem;
    CurReticuleModeleItem: TMenuItem;
    Separ6: TMenuItem;
    Separ8: TMenuItem;
    OptionsVecteursBis: TMenuItem;
    LatexMenu: TMenuItem;
    CurModeleBis: TMenuItem;
    MonteCarloItem: TMenuItem;
    GrapheParamTab: TTabItem;
    GrapheParamTB: TToolBar;
    PanelModeleGlb: TPanel;
    MemoResultatGlb: TMemo;
    MemoModeleGlb: TMemo;
    Panel2: TPanel;
    ScrollBoxParam: TScrollBox;
    paramGlbGrid: TTMSFNCGrid;
    PaintBoxParam: TPaintBox;
    PanelCentralParam: TPanel;
    ModeleGlbBtn: TButton;
    ZoomArrGlbBtn: TButton;
    ZoomAutoGlbBtn: TButton;
    CoordonneesGlbBtn: TButton;
    ZoomGlbBtn: TButton;
    CurseurGlbBtn: TButton;
    AjusteGlbBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure UpdateMenuItems(Sender: TObject);
    procedure FileOpenItemClick(Sender: TObject);
    procedure FileExitItemClick(Sender: TObject);
    procedure FileSaveItemClick(Sender: TObject);
    procedure FileSaveAsItemClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AboutItemClick(Sender: TObject);
    procedure PageSuivClick(Sender: TObject);
    procedure PageAddClick(Sender: TObject);
    procedure PageDelClick(Sender: TObject);
    procedure FileNewClipItemClick(Sender: TObject);
    procedure FileNewClavierItemClick(Sender: TObject);
    procedure FileAddItemClick(Sender: TObject);
    procedure PagePrecClick(Sender: TObject);
    procedure PagesItemClick(Sender: TObject);
    procedure MruItemClick(Sender: TObject);
    procedure EditionItemClick(Sender: TObject);
    procedure CommentaireEditChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OptionsItemClick(Sender: TObject);
    procedure CollerPageItemClick(Sender: TObject);
    procedure PageSelectItemClick(Sender: TObject);
    procedure FilePrintItemClick(Sender: TObject);
    procedure FocusAcquisitionBtnClick(Sender: TObject);
    procedure UndoItemClick(Sender: TObject);
    procedure RecupItemClick(Sender: TObject);
    procedure EnregistreBtnClick(Sender: TObject);
    procedure PageAddBtnClick(Sender: TObject);
    procedure PageAddItemClick(Sender: TObject);
    procedure ListeNomChange(Sender: TObject);
    procedure CopyGrapheStatItemClick(Sender: TObject);
    procedure PaintBoxStatPaint(Sender: TObject; Canvas: TCanvas);
    procedure OptionsStatItemClick(Sender: TObject);
    procedure CopyGridItemClick(Sender: TObject);
    procedure ImprimeStatItemClick(Sender: TObject);
    procedure miniXeditExit(Sender: TObject);
    procedure miniYEditKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FiltreItemClick(Sender: TObject);
    procedure Inter1Click(Sender: TObject);
    procedure CoordonneesBtnClick(Sender: TObject);
    procedure ZoomAutoBtnClick(Sender: TObject);
    procedure IntersectionItemClick(Sender: TObject);
    procedure ModeleGrBtnClick(Sender: TObject);
    procedure ZoomBtnClick(Sender: TObject);
    procedure ZoomArrBtnClick(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
    procedure AjusteBtnClick(Sender: TObject);
    procedure RazBornesClick(Sender: TObject);
    procedure ResidusItemClick(Sender: TObject);
    procedure ModeleBtnClick(Sender: TObject);
    procedure CurseurBtnClick(Sender: TObject);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBox1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure PaintBox1DblClick(Sender: TObject);
    procedure RaZModeleClick(Sender: TObject);
    procedure InitEquaDiffBtnClick(Sender: TObject);
    procedure BornesBtnClick(Sender: TObject);
    procedure TrigoBtnClick(Sender: TObject);
    procedure ModeleItemClick(Sender: TObject);
    procedure ParamGridGetCellEditorType(Sender: TObject; ACol, ARow: Integer;
      var CellEditorType: TTMSFNCGridEditorType);
    procedure ParamGridCellEditSetData(Sender: TObject; ACol, ARow: Integer;
      CellEditor: TControl; var CellString: string);
    procedure ParamGridCellButtonClick(Sender: TObject; ACol, ARow: Integer;
      ACell: TTMSFNCGridCell);
    procedure IncertItemClick(Sender: TObject);
    procedure LegendeItemClick(Sender: TObject);
    procedure SelectItemClick(Sender: TObject);
    procedure VitesseItemClick(Sender: TObject);
    procedure OptionsModeleBtnClick(Sender: TObject);
    procedure CurOrigineItemClick(Sender: TObject);
    procedure MemoModeleChange(Sender: TObject);
    procedure SaveGraphItemClick(Sender: TObject);
    procedure CopyGraphItem(Sender: TObject);
    procedure PrintGraphItemClick(Sender: TObject);
    procedure PrintModeleClick(Sender: TObject);
    procedure OptionsVecteursMenuClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FermerItemClick(Sender: TObject);
    procedure ProprieteCourbeClick(Sender: TObject);
    procedure PaintBoxResiduPaint(Sender: TObject; Canvas: TCanvas);
    procedure WindowTabChange(Sender: TObject);
    procedure PaintBox1Gesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure GrecItemClick(Sender: TObject);
    procedure GrecActionExecute(Sender: TObject);
    procedure InitEquaDiffBtnMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure ListeRegItemClick(Sender: TObject);
    procedure WebItemClick(Sender: TObject);
    procedure TOCitemClick(Sender: TObject);
    procedure VecteursBtnClick(Sender: TObject);
    procedure ModelesActionExecute(Sender: TObject);
    procedure FileNewSimulationItemClick(Sender: TObject);
    procedure PaintBox1Click(Sender: TObject);
    procedure RazTgItemClick(Sender: TObject);
    procedure fileCloseItemClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure TimerDemarrageTimer(Sender: TObject);
    procedure PrintPdfItemClick(Sender: TObject);
    procedure SaveGrapheStatItemClick(Sender: TObject);
    procedure TimerStatTimer(Sender: TObject);
    procedure EnglishActionExecute(Sender: TObject);
    procedure FrenchActionExecute(Sender: TObject);
    procedure EditBidonKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure VideoItemClick(Sender: TObject);
    procedure TimerLoupeTimer(Sender: TObject);
    procedure ExemplesItemClick(Sender: TObject);
    procedure ImageItemClick(Sender: TObject);
    procedure ArduinoItemClick(Sender: TObject);
    procedure OscilloArduinoItemClick(Sender: TObject);
    procedure ChronoPhotoMenuClick(Sender: TObject);
    procedure GBAnimationClick(Sender: TObject);
    procedure GBAnimationDblClick(Sender: TObject);
    procedure TBAnimationChange(Sender: TObject);
    procedure CloseAnimBtnClick(Sender: TObject);
    procedure TimerAnimationTimer(Sender: TObject);
    procedure SuivantAnimBtnClick(Sender: TObject);
    procedure PrecedentAnimBtnClick(Sender: TObject);
    procedure PlayAnimBtnClick(Sender: TObject);
    procedure StopAnimBtnClick(Sender: TObject);
    procedure AnimationBtnClick(Sender: TObject);
    procedure TitreAnimCBClick(Sender: TObject);
    procedure AideItemClick(Sender: TObject);
    procedure ParamGridGetCellClass(Sender: TObject; ACol, ARow: Integer;
      var CellClassType: TTMSFNCGridCellClass);
    procedure ParamGridGetCellEditorProperties(Sender: TObject; ACol,
      ARow: Integer; CellEditor: TControl);
    procedure SaveCSVItemClick(Sender: TObject);
    procedure OptiqueItemClick(Sender: TObject);
    procedure CurModeleItemClick(Sender: TObject);
    procedure CurseurMenuPopup(Sender: TObject);
    procedure VecteursMenuPopup(Sender: TObject);
    procedure LatexMenuClick(Sender: TObject);
    procedure MenuAxesPopup(Sender: TObject);
    procedure PopupMenuModelePopup(Sender: TObject);
    procedure BornesMenuPopup(Sender: TObject);
    procedure OptionsModeleClick(Sender: TObject);
    procedure MonteCarloItemClick(Sender: TObject);
    procedure MemoModeleKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure CommentaireEditKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure PaintBoxParamPaint(Sender: TObject; Canvas: TCanvas);
    procedure PaintBoxParamMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBoxParamMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure PaintBoxParamMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ModeleGlbBtnClick(Sender: TObject);
    procedure CoordonneesGlbBtnClick(Sender: TObject);
    procedure AjusteGlbBtnClick(Sender: TObject);
    procedure ZoomAutoGlbBtnClick(Sender: TObject);
    procedure ZoomGlbBtnClick(Sender: TObject);
    procedure ZoomArrGlbBtnClick(Sender: TObject);
    procedure CurseurGlbBtnClick(Sender: TObject);
    procedure MemoModeleGlbChange(Sender: TObject);
    procedure paramGlbGridCellButtonClick(Sender: TObject; ACol, ARow: Integer;
      ACell: TTMSFNCGridCell);
    procedure paramGlbGridCellEditSetData(Sender: TObject; ACol, ARow: Integer;
      CellEditor: TControl; var CellString: string);
    procedure paramGlbGridGetCellClass(Sender: TObject; ACol, ARow: Integer;
      var CellClassType: TTMSFNCGridCellClass);
    procedure paramGlbGridGetCellEditorProperties(Sender: TObject; ACol,
      ARow: Integer; CellEditor: TControl);
    procedure paramGlbGridGetCellEditorType(Sender: TObject; ACol,
      ARow: Integer; var CellEditorType: TTMSFNCGridEditorType);
  private
    MruList : TStringList;
    MRUitem : array[0..maxMRU] of TMenuItem;
    majFichierEnCours : boolean;
    InitiationAfaire : boolean;
    FHandleDragDirectly : boolean;
    GrecActif : boolean;
    premiereFois : boolean;
    appelExterieur : boolean;
    MonteCarloActif : boolean;
    procedure OpenFile(const AFileName: string);
    procedure CloseAll;
    procedure ChangePage;
    procedure MajPages;
    procedure MruAdd(FileName: String);
    procedure MruDel(FileName: String);
    procedure EmbeddForm(AParent:TControl; AForm:TCustomForm);
    procedure compileModeles;
    Procedure MajParametres;
    procedure MajModeleGr(NumeroGr : integer);
    procedure SetPanelModele(NouvelEtat : boolean);
    procedure SetPanelModeleGlb(NouvelEtat : boolean);
    procedure UpdateResiduVisibility;
    procedure setMenu;
    procedure BarreEspace;
    procedure OnApplicationHint(Sender: TObject);
  public
    NbreGrandeursSauvees : integer;
    GrapheResidu : TgrapheResidu;
    GrapheStat : TgrapheReg;
    function VerifSauve : boolean;
    procedure FinOuvertureFichier(LectureOK : boolean);
    procedure StatistiqueOpen;
    procedure LanceCompileModele;
    procedure WMRegMaj(typeMaj : integer);
    procedure AjustePanelModele;
    procedure AjustePanelModeleGlb;
    procedure ModeleMagnum(changeDebut : boolean);
    procedure LanceModele(ajuste : boolean);
    procedure LanceModeleGlb(ajuste : boolean);
    procedure DragEnter(const Data: TDragObject; const Point: TPointF); override;
    procedure DragOver(const Data: TDragObject; const Point: TPointF;
                   var OPeration: TDragOperation); override;
    procedure DragDrop(const Data: TDragObject; const Point: TPointF); override;
    procedure MajResultat;
    procedure MajResultatGlb;
    procedure MajResultatLatex(p : codePage);
    procedure VerifGrec(Sender : TObject;var Key: Word;var KeyChar: Char;shift : TshiftState);
  end;

var
  FRegressiMain: TFRegressiMain;

implementation

uses about, varkeyb, options, newvar, supprDlg,
     graphFft, regPrint, reglatex, selPage, optStat, statCalc, optionsFiltrageU,
     optModele, optionsvitesse, PropCourbe, modif, modeleGr, choixmodele,
     optFFT, regFile, LoupeU, curModeleU, BitmapU2, chronoBitmap2, optiqueBitmap
{$IFDEF HAS_FFMPEG}
     , ffmpegU
{$ENDIF}
     ;

{$R *.FMX}

procedure TFRegressiMain.OnApplicationHint(Sender: TObject);
begin
  Aide.Text := Application.Hint;
end;


procedure TFRegressiMain.FormCreate(Sender: TObject);

Procedure InitMRU;

Procedure LitMRU;
var
  Rini : TIniFile;
  i : integer;
  zz : string;
begin
  if not FileExists(registreReg) then exit;
  Rini := TIniFile.create(registreReg);
  try
  for i := 0 to maxMRU do begin
      zz := Rini.ReadString('Fichier','MRU'+IntToStr(i),'');
      {$IFDEF MacOS}
      if pos(homePath,zz)=0 then zz := ''; // Sandbox
      {$ENDIF}
      if zz<>'' then MRUList.Add(zz);
  end;
  finally
  Rini.free;
  end;
end; // litMRU

var  i : integer;
begin
  MruList := TStringList.Create;
  Mruitem[0] := menuitem0;
  Mruitem[1] := menuitem1;
  Mruitem[2] := menuitem2;
  Mruitem[3] := menuitem3;
  Mruitem[4] := menuitem4;
  Mruitem[5] := menuitem5;
  Mruitem[6] := menuitem6;
  Mruitem[7] := menuitem7;
  for i := 0 to maxMRU do begin
       Mruitem[i].visible := false;
       MRUItem[i].Text := '';
  end;
  MRUSeparator.Visible := false;
  litMRU;
end; // initMRU

procedure createAnimation;
var i : integer;
    LgroupBox : TgroupBox;
    Ltrackbar : TtrackBar;
begin
     for i := 0 to maxParamAnimation do begin
         LgroupBox := TgroupBox.create(PanelAnimation);
         LgroupBox.Parent := PanelAnimation;
//         LgroupBox.StyledSettings := [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.Style, TStyledSetting.FontColor];
         LgroupBox.StyledSettings := [];
         LtrackBar := TtrackBar.Create(LgroupBox);
         LtrackBar.Parent := LgroupBox;
         LtrackBar.ControlType := TControlType.platform;
         LtrackBar.Tag := i;
         LgroupBox.Tag := i;
         LgroupBox.align := TAlignLayout.Bottom;
         LtrackBar.align := TAlignLayout.Bottom;
         paramAnimation[i].GroupBoxA := LgroupBox;
         paramAnimation[i].SliderA := LtrackBar;
         LgroupBox.OnClick := GBAnimationClick;
         LgroupBox.OnDblClick := GBAnimationDblClick;
         LtrackBar.OnChange := TBAnimationChange;
     end;
end;

begin  // FormCreate
{$IFDEF HAS_FFMPEG}
   avlib.ffmpeg_DLL_Path := includeTrailingBackSlash(applicationPath);
{$ENDIF}
   ModeAcquisition := AcqSimulation;
   Application.ShowHint := true;
   Application.OnHint := OnApplicationHint;
   monteCarloActif := false;
   appelExterieur := false;
   premiereFois := true;
   langue := fr;
   chaineLangue := 'fr';
   initMRU;
{$IFDEF Store}
   WebItem.Visible := false;
   LangItem.Visible := false;
{$ELSE}
   WebItem.Visible := true;
   LangItem.Visible := true;
{$ENDIF}
  PanelAnimation.Visible := false;
  ModifFichier := false;
  NomFichierData := '';
  UpDateMenuItems(nil);
  Application.CreateForm(TFValeurs, FValeurs);
  EmbeddForm(ValeursPanel, Fvaleurs);
  Application.CreateForm(TFGrapheFFT, FGrapheFFT);
  EmbeddForm(FourierPanel, FgrapheFFT);
  PanelAjuste.enabled := true;
  selectItem.IsChecked  := true;
  PanelModele.Visible := false;
  PanelModeleGlb.Visible := false;
  GlobalDisableFocusEffect := true;
  PanelPage.Visible := false;
  MajFichierEnCours := true;
  GrapheResidu := TgrapheResidu.create(paintBoxResidu);
  grapheResidu.zoneClipBoard := zoneClipBoard;
  Graphe := TgrapheVariab.create(paintBox1);
  graphe.zoneClipBoard := zoneClipBoard;
  createAnimation;
  GrapheParam := TgrapheParam.create(paintBoxParam);
  grapheParam.paramGrid := paramGlbGrid;
  grapheParam.MemoModele := MemoModeleGlb;
  grapheParam.MemoResultat := MemoResultatGlb;
  PanelCentral.OnKeyDown := graphe.PanelCentralKeyDown;
  graphe.LineEcartY := LineY;
  graphe.LineEcartX := LineX;
  openDialog.InitialDir := DocumentsPath;
  saveDialog.InitialDir := DocumentsPath;
  windowTab.activeTab := valeursTab;
  splitterResidu.visible := false;
  PaintBoxResidu.visible := false;
  GrapheStat := TgrapheReg.create(paintBoxStat);
  grapheStat.zoneClipBoard := zoneClipBoardStat;
//  visible := true;
end; // FormCreate

procedure TFRegressiMain.GrecActionExecute(Sender: TObject);
begin
    GrecActif := true
end;

procedure TFRegressiMain.AideItemClick(Sender: TObject);
begin
     if aideForm=nil then Application.createForm(TaideForm,aideForm);
     CentreForm(AideForm);
     AideForm.Show;
end;

procedure TFRegressiMain.AjusteBtnClick(Sender: TObject);
begin
    LanceModele(true)
end;

procedure TFRegressiMain.AjusteGlbBtnClick(Sender: TObject);
begin
    LanceModeleGlb(true)
end;

procedure TFRegressiMain.BornesBtnClick(Sender: TObject);
var i : integer;
    P : TpointF;
begin
     if not (ModeleDefini in graphe.etatModele) then LanceCompileModele;
     pages[pageCourante].VerifIntervalles;
     for i := 0 to BornesMenu.itemsCount-1 do with BornesMenu.items[i] do begin
         visible := (tag=0) or (tag<=nbreModele);
         if (tag>0) and (tag<=nbreModele) then begin
              text := stBorne+fonctionTheorique[tag].enTete+'='+copy(fonctionTheorique[tag].expression,1,10);
              FregressiMain.Aide.text := stBorneSelect;
         end;
         if (NbreModele<MaxIntervalles) and (tag=NbreModele+1) then begin
            text := stBornesModele;
            visible := true;
         end;
     end;
     P := TpointF.Create(bornesBtn.position.X,BornesBtn.position.y);
     P.Offset(0,3*bornesBtn.height+GrapheToolBar.Position.Y);
     P := ClientToScreen(P);
     bornesMenu.popup(P.x,P.y);
end;

procedure TFRegressiMain.BornesMenuPopup(Sender: TObject);
begin
  IntersectionItem.IsChecked := traceIntersection;
  IntersectionItem.visible := nbreModele>1;
end;

procedure TFRegressiMain.CloseAnimBtnClick(Sender: TObject);
begin
   AnimationBtn.isPressed := false;
   PanelAnimation.visible := false;
   panelModele.enabled := true;
   modeleBtn.Enabled := true;
   timerAnimation.enabled := false;
end;

procedure TFRegressiMain.CloseAll;
begin
     Caption := 'Regressi';
     BornesBtn.Enabled := false;
     ModeleBtn.IsPressed := false;
     setPanelModele(false);
     setPanelModeleGlb(false);
     MemoModele.lines.Clear;
     MemoResultat.lines.Clear;
     MemoModeleGlb.lines.Clear;
     MemoResultatGlb.lines.Clear;
     graphe.etatModele := [];
     splitterResidu.visible := false;
     PaintBoxResidu.visible := false;
     Fvaleurs.Feuillets.ActiveTab := FValeurs.ExpSheet;
     FValeurs.MesureCourante := 0;
     FValeurs.Memo.lines.Clear;
     windowTab.ActiveTab := ValeursTab;
     WMRegMaj(MajVide);
     resetEnTete;
end;

procedure TFRegressiMain.fileCloseItemClick(Sender: TObject);
begin
    FileNewSimulationItemClick(Sender);
    WindowState := TWindowState.wsMinimized;
end;

procedure TFRegressiMain.VecteursBtnClick(Sender: TObject);
var P : TPointF;
begin
     P := TpointF.Create(vecteursBtn.position.X,vecteursBtn.position.y);
     P.Offset(0,vecteursBtn.height+GrapheToolBar.Position.Y);
     P := ClientToScreen(P);
     vecteursMenu.popup(P.x,P.y);
end;

procedure TFRegressiMain.VecteursMenuPopup(Sender: TObject);
var codeX,codeY : integer;
    fildefer : boolean;
begin with graphe do begin
       filDeFer := (courbes.Count>1) and
       (coordonnee[1].nomX<>coordonnee[2].nomX) and
       (coordonnee[2].codeX<>grandeurInconnue);
       if filDeFer then begin
            codeX := coordonnee[1].codeX;
            codeY := coordonnee[1].codeY;
            OptionsVecteursMenu.text := 'Options '+grandeurs[codeX].nom+','+grandeurs[codeY].nom;
            codeX := coordonnee[2].codeX;
            codeY := coordonnee[2].codeY;
            OptionsVecteursBis.text := 'Options '+grandeurs[codeX].nom+','+grandeurs[codeY].nom;
            OptionsVecteursBis.visible := true;
       end
       else begin
            OptionsVecteursMenu.text := 'Options';
            OptionsVecteursBis.visible := false;
       end;
end end;

Function TFregressiMain.VerifSauve : boolean;
var zz : string;
    reponse : TModalResult;
begin
  if (pageCourante>0) and modifFichier then begin
        if NomFichierData=''
           then zz := stData
           else zz := stModif+ExtractFileName(nomFichierData);
        TDialogService.MessageDialog(stSauve+zz,TMsgDlgType.mtConfirmation,
        [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo,TMsgDlgBtn.mbCancel],TMsgDlgBtn.mbYes,0,
        procedure(const Aresult : TmodalResult) begin
                            reponse := Aresult;
                 end);
        case reponse of
           mrYes : begin
              if NomFichierData=''
                 then FileSaveAsItemClick(nil)
                 else FileSaveItemClick(nil);
              result := true;
           end;
           mrNo : result := true;
           else result := false;
        end; // case
  end // pageCourante>0
  else result := true;
  if result and (pageCourante>0) then closeAll;
end;

procedure TFRegressiMain.VideoItemClick(Sender: TObject);
begin
{$IFDEF HAS_FFMPEG}
      if not verifSauve then exit;
      majFichierEnCours := false;
      if ffmpegForm=nil then application.createForm(TffmpegForm,ffmpegForm);
      CentreForm(ffmpegForm);
      ffmpegForm.show;
{$ELSE}
      ShowMessage('Capture vidéo non disponible (HAS_FFMPEG non défini)');
{$ENDIF}
end;

procedure TFRegressiMain.VitesseItemClick(Sender: TObject);
begin
    graphe.vecteursItemClick(sender);
end;

procedure TFRegressiMain.FileOpenItemClick(Sender: TObject);
begin
  if not verifSauve then exit;
  OpenDialog.Title := stOuvrir;
  if OpenDialog.execute then begin
     OpenFile(openDialog.FileName);
     OpenDialog.initialDir := extractFilePath(openDialog.FileName);
  end;
end;

procedure TFRegressiMain.ListeNomChange(Sender: TObject);
begin
   if statOptDlg=nil then exit;
   if listeNom.enabled and
      (listeNom.itemIndex>=0) and
      (listeNom.items.count>listeNom.itemIndex) and
      (statOptDlg.NomStat<>listeNom.items[listeNom.itemIndex]) then begin
        statOptDlg.NomStat := listeNom.items[listeNom.itemIndex];
        indexStat := indexNom(StatOptDlg.nomStat);
        include(grapheStat.modif,gmXY);
        PaintBoxStat.repaint;
   end;
end;

procedure TFRegressiMain.ListeRegItemClick(Sender: TObject);
const FileName = 'https://framalistes.org/sympa/info/regressi';
begin
  if not ouvreURL(FileName) then ShowMessage(stNoAcces+Filename)
end;

procedure TFRegressiMain.OpenFile(const AFileName : string);
var verifLecture : boolean;
    extension : string;
begin
try
if FileExists(AFileName)
  then begin
     optionsDlg.litConfig;
     majFichierEnCours := true;
     modeAcquisition := AcqFichier;
     cursor := crHourGlass;
     nomFichierData := AFileName;
     ErreurDetectee := false;
     extension := AnsiUpperCase(extractFileExt(nomFichierData));
     if extension='' then begin
        extension := '.RW3';
        nomFichierData := ChangeFileExt(nomFichierData,extension);
     end;
     if extension='.RW3'
        then VerifLecture := FichierRegressi.litWin
        else if extension='.CSV'
             then VerifLecture := fichierRegressi.litCSV(nomFichierData,true)
             else if extension='.WAV'
             then VerifLecture := fichierRegressi.litWav(nomFichierData)
             else if extension='.RXML'
             then VerifLecture := FichierRegressi.litXML(nomFichierData,true)
             else verifLecture := FichierRegressi.litTableur(nomFichierData);
     FinOuvertureFichier(verifLecture);
     cursor := crDefault;
  end
  else begin
     codeErreurF := erFileNotExist+' : '+AFileName;
     FinOuvertureFichier(false);
  end;
  except
     codeErreurF := '';
     FinOuvertureFichier(false);
  end;
end;

procedure TFRegressiMain.FileSaveItemClick(Sender: TObject);
var extension : string;
begin
     if pageCourante>0 then if nomFichierData<>''
        then begin
           extension := AnsiUpperCase(extractFileExt(nomFichierData));
           if extension='.RW3'
              then FichierRegressi.EcritWin(NomFichierData)
              else begin
                 nomFichierData := changeFileExt(NomFichierData,'.RXML');
                 FichierRegressi.EcritXML(NomFichierData);
              end;
           modifFichier := false;
        end
        else FileSaveAsItemClick(sender);
end;

procedure TFRegressiMain.FileSaveAsItemClick(Sender: TObject);
var extension : string;
begin with saveDialog do begin
    FileName := extractFileName(nomFichierData);
    if fileName='' then fileName := 'azerty';
    fileName := changeFileExt(fileName,'.RXML');
    if Execute then begin
       extension := AnsiUpperCase(extractFileExt(FileName));
       if extension='' then begin
           extension := '.RXML';
           fileName := ChangeFileExt(FileName,extension)
       end;
       if extension='.RW3'
          then FichierRegressi.ecritWin(FileName)
          else if extension='.RXML'
            then FichierRegressi.ecritXML(FileName)
            else FichierRegressi.ecritTableur(FileName);
       MRUadd(FileName);
       modifFichier := false;
    end;
end end;

procedure TFRegressiMain.FileExitItemClick(Sender: TObject);
begin
    Close
end;

procedure TFRegressiMain.UpdateMenuItems(Sender: TObject);

procedure MruItemUpdate;
var i : integer;
begin
  while MruList.count > (maxMru+1) do
        MRUList.delete(MRUList.Count - 1);
  for i := 0 to pred(MRUList.count) do begin
      MRUItem[i].Text := ExtractFileName(MRUList[i]);
      MRUItem[i].visible := true;
  end;
  for i := MRUList.count to maxMRU do
      MRUItem[i].visible := false;
  MRUSeparator.Visible := MRUList.count>0;
end;

begin
   FileSaveItem.Enabled := pageCourante>0;
   FileSaveAsItem.Enabled := FileSaveItem.Enabled;
   FileAddItem.Enabled := FileSaveItem.Enabled;
   FilePrintItem.enabled := FileSaveItem.Enabled;
   PagesItem.Enabled := FileSaveItem.Enabled;
   PageSelectItem.Enabled := nbrePages>1;
   MruItemUpdate;
end;

procedure TFRegressiMain.FormDestroy(Sender: TObject);
begin
   MruList.free;
   grapheResidu.Free;
   graphe.Free;
   grapheParam.Free;
   GrapheStat.Free;
end;

// mot de passe Regressi022020
// cymh-xuep-szcp-sgjz

// ancien certificat
// Mac Developer: Jean-Michel Millet (TZDZH23SJG)

procedure TFRegressiMain.VerifGrec(Sender : TObject;var Key: Word;var KeyChar: Char;shift : TshiftState);
const
        GrecMaj : array[0..25] of char =
  (AlphaMaj,BetaMaj,ChiMaj,deltaMaj,EpsilonMaj,phiMaj,gammaMaj,etaMaj,
   iotaMaj,psiMaj,kappaMaj,lambdaMaj,MuMaj,NuMaj,omicronMaj,piMaj,thetaMaj,
   rhoMaj,sigmaMaj,tauMaj,upsilonMaj,'V',omegaMaj,xiMaj,'Y',zetaMaj);
        GrecMin : array[0..25] of char =
  (alphaMin,betaMin,chiMin,deltaMin,epsilonMin,phiMin,gammaMin,etaMin,iotaMin,psiMin,kappaMin,lambdaMin,
   muMin,nuMin,omicronMin,piMin,thetaMin,rhoMin,sigmaMin,tauMin,upsilonMin,'v',omegaMin,xiMin,'y',zetaMin);
var CaretMemo : TCaretPosition;
    LMemo : TMemo;
    LEdit : TEdit;
    Numero : integer;
    caretEdit : integer;
    texte : string;
    isGrec : boolean;
begin
{$IFDEF MacOS}
    Shift := KeyboardModifiers;
{$ENDIF}
    if (ssCtrl in Shift) then begin
       numero := key-ord('A');
       isGrec := (numero>0) and (numero<25) and not (numero in [2, 21, 23]); // preserve Ctrl+A/C/V/X/Z
       if isGrec then begin
          if (ssShift in Shift)
               then keyChar := GrecMaj[numero]
               else keyChar := GrecMin[numero];
          if (sender is TEdit) then begin
            LEdit := (sender as TEdit);
            caretEdit := LEdit.caretPosition;
            texte := LEdit.text;
            texte := texte.Insert(caretEdit,keyChar);
            LEdit.text := texte;
            LEdit.caretPosition := caretEdit+1;
          end;
          if (sender is TMemo) then begin
              LMemo := (sender as TMemo);
              CaretMemo := LMemo.CaretPosition;
              if LMemo.lines.count = 0 then begin
                 LMemo.lines.Add(keyChar);
                 CaretMemo := TCaretPosition.Create(0, 1);
                 Lmemo.caretPosition := CaretMemo;
              end
              else if (CaretMemo.line>=0) and (CaretMemo.line<LMemo.lines.count) then begin
                 texte := LMemo.lines[CaretMemo.line];
                 texte := texte.Insert(CaretMemo.Pos,keyChar);
                 LMemo.lines[CaretMemo.line] := texte;
                 CaretMemo.Pos := CaretMemo.Pos+1;
                 Lmemo.caretPosition := CaretMemo;
              end;
          end;
          keyChar := #0;
          key := 0;
       end;
    end;
end;

procedure TFRegressiMain.FormKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);

const
        GrecMaj : array[0..25] of char =
  (AlphaMaj,BetaMaj,ChiMaj,deltaMaj,EpsilonMaj,phiMaj,gammaMaj,etaMaj,
   iotaMaj,psiMaj,kappaMaj,lambdaMaj,MuMaj,NuMaj,omicronMaj,piMaj,thetaMaj,
   rhoMaj,sigmaMaj,tauMaj,upsilonMaj,'V',omegaMaj,xiMaj,'Y',zetaMaj);

        GrecMin : array[0..25] of char =
  (alphaMin,betaMin,chiMin,deltaMin,epsilonMin,phiMin,gammaMin,etaMin,iotaMin,psiMin,kappaMin,lambdaMin,
   muMin,nuMin,omicronMin,piMin,thetaMin,rhoMin,sigmaMin,tauMin,upsilonMin,'v',omegaMin,xiMin,'y',zetaMin);

begin
    if GrecActif then begin
       if keyChar=#0 then exit; // un premier appel pour Shift
       if (keyChar<='Z') and (keyChar>='A')
           then keyChar := GrecMaj[ord(keyChar)-ord('A')]
           else if (keyChar<='z') and (keyChar>='a')
                then keyChar := GrecMin[ord(keyChar)-ord('a')];
       GrecActif := false;
    end
    else if (windowTab.ActiveTab=GrapheTab) and ((key=vkSpace) or (keyChar=' ')) and
            ((activeControl=nil) or (not (activeControl is TEdit) and not (activeControl is TMemo))) then begin
        if (graphe<>nil) and (graphe.curseur=curSelect) and (graphe.indexPointCourant<0) then begin
           graphe.SpaceHeld := True;
           PaintBox1.Cursor := crSizeAll;
        end
        else BarreEspace;
        keyChar := #0;
        key := 0;
    end;
end;

procedure TFRegressiMain.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
    if (Key = vkSpace) or (KeyChar = ' ') then begin
       if graphe <> nil then begin
          graphe.SpaceHeld := False;
          if graphe.curseur = curSelect then
             PaintBox1.Cursor := crDefault;
       end;
    end;
end;

procedure TFRegressiMain.BarreEspace;

procedure CreerXY(c1,c2 : integer;typeXY : TSetLigneRappel);
var NewEquivalence : Tequivalence;
begin with graphe do begin
     NewEquivalence := Tequivalence.CreateEq(
                 curseurOsc[c1].xr,curseurOsc[c1].yr,
                 curseurOsc[c2].xr,curseurOsc[c2].yr,
                 0,0,0,pageCourante,graphe);
     NewEquivalence.mondepH := curseurOsc[c1].mondeC;
     NewEquivalence.ligneRappel := typeXY ;
     equivalences[pageCourante].Add(NewEquivalence);
end end;

Function Supprime(posSouris : TpointF;aMonde : indiceMonde) : boolean;
var i : integer;
    aEquivalence : Tequivalence;
    aPoint : TPointF;
    trouve,trouveI : boolean;
begin with graphe do begin
     trouve := false;
     i := 0;
     while i<equivalences[pageCourante].count do begin
            aEquivalence := equivalences[pageCourante].items[i];
            with aEquivalence do if (ligneRappel*[lrReticule,lrX,lrY,lrPente]<>[]) then begin
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
                  if equivalenceCourante = aEquivalence then
                     equivalenceCourante := nil;
                  equivalences[pageCourante].Remove(aEquivalence);
                  aEquivalence.Free;
                  trouve := true;
               end
               else inc(i);
            end
            else inc(i); // with newEq
         end; // while
         if trouve then PaintBox.repaint;
         result := trouve;
end end;

var posSouris : TpointF;
    j : integer;
    xrS,yrS : double;
    NewEquivalence : Tequivalence;
    icourbe,mondeLoc : integer;
    aset : TsetLigneRappel;
begin // BarreEspace
   case graphe.curseur of
   curReticule : with graphe do begin
        PosSouris := curseurOsc[1].Pc;
        iCourbe := courbeProche(posSouris);
        if iCourbe<0
            then mondeLoc := curseurOsc[1].mondeC
            else mondeLoc := courbes[iCourbe].iMondeC;
        if supprime(posSouris,mondeLoc) then exit;
        if curseurCourant=3 then begin
              aset := [lrX,lrY,lrPente];
              CreerXY(1,3,aset);
         end
         else begin
            mondeRT(posSouris,mondeLoc,xrS,yrS);
            NewEquivalence := Tequivalence.CreateEq(0,0,0,0,xrS,yrS,
                   0,pageCourante,graphe);
            NewEquivalence.mondepH := mondeLoc;
            NewEquivalence.ligneRappel := [lrReticule];
            equivalences[pageCourante].Add(NewEquivalence);
         end;
         PaintBox.repaint;
   end;// curReticule
   curReticuleData : with graphe do begin
        if (curseurCourant >= 1) and (curseurCourant <= 2) then
           posSouris := curseurOsc[curseurCourant].Pc
        else
           posSouris := curseurOsc[1].Pc;
        if supprime(posSouris,curseurOsc[1].mondeC) then exit;
        for j := 1 to 2 do with curseurOsc[j] do
        if mondeC<>mondeX then begin
            NewEquivalence := Tequivalence.CreateEq(0,0,0,0,
                         xr,yr,
                         0,pageCourante,graphe);
            NewEquivalence.mondepH := mondeC;
            NewEquivalence.ligneRappel := [lrReticule];
            equivalences[pageCourante].Add(NewEquivalence);
         end;
         if ([coDeltaX, coDeltaY] * optionCurseur <> []) and
            (curseurOsc[1].mondeC=curseurOsc[2].mondeC) then begin
                aset := [];
                if coDeltax in optionCurseur then aset := [lrX];
                if coDeltay in optionCurseur then aset := aset+[lrY];
                if aset<>[] then CreerXY(1,2,aset);

         end;
         PaintBox.repaint;
   end;// curReticuleData
   curReticuleModele : graphe.BarreEspace;
   curSelect : if (graphe.indexPointCourant>=0) then begin
         Pages[pageCourante].PointActif[graphe.indexPointCourant] :=
              not Pages[pageCourante].PointActif[graphe.indexPointCourant];
         WMRegMaj(MajSupprPoints);
   end;
   end;// case curseur
end; //Gestion barre d'espace

procedure TFRegressiMain.FormResize(Sender: TObject);
begin
    if panelModele.visible then AjustePanelModele;
    if panelModeleGlb.visible then AjustePanelModeleGlb;
    if PaintBoxResidu.visible
       then PaintBoxResidu.height := panelCentral.height/3;
    tailleEcran := PanelCentral.Height;
end;

procedure TFRegressiMain.ChangePage;
begin
     if (pageCourante>0) then with pages[pageCourante] do begin
       affecteConstParam;
       affecteVariableP(false);
       WMRegMaj(MajChangePage)
     end;
end;

procedure TFRegressiMain.ChronoPhotoMenuClick(Sender: TObject);
begin
      if not verifSauve then exit;
      majFichierEnCours := false;
      if ChronoBitmapForm=nil then application.createForm(TChronoBitmapForm,ChronoBitmapForm);
      CentreForm(ChronoBitmapForm);
      ChronoBitmapForm.show;
end;

procedure TFRegressiMain.MajPages;
var i : integer;
begin
     lectureFichier := false;
     lecturePage := false;
     if pageCourante>NbrePages then pageCourante := NbrePages;
     PanelPage.Visible := NbrePages>1;
     if pageCourante>0 then
        CommentaireEdit.text := pages[pageCourante].commentaireP;
     for i := 1 to NbrePages do pages[i].numero := i;
     PanelNumPage.Text  := IntToStr(PageCourante)+'/'+IntToStr(NbrePages);
     CommentaireEdit.FontColor := couleurPages[pageCourante];
end;

procedure TFRegressiMain.AboutItemClick(Sender: TObject);
begin
     AboutBox := TaboutBox.create(self);
     CentreForm(AboutBox);
     AboutBox.ShowModal;
     AboutBox.free;
end;

procedure TFRegressiMain.WebItemClick(Sender: TObject);
{$IFNDEF Store}
const FileName = 'https://regressi.fr/';
{$ENDIF}
begin
{$IFNDEF Store}
  if ouvreURL(FileName) then else ShowMessage(stNoAcces+Filename)
{$ENDIF}
end;

procedure TFRegressiMain.WMRegMaj(typeMaj : integer);

procedure MajGraphe;

procedure RazCoord;
var i,j,m : integer;
    UnitePrec : string;
begin with graphe do begin
    Curseur := curSelect;
    IsModeleMagnum := false;
    j := 1;
    m := mondeY;
    UnitePrec := '';
    for i := 1 to pred(NbreVariab) do with Coordonnee[j] do begin
        codeY := indexVariab[i];
        ligne := LiDroite;
        if grandeurs[codeY].fonct.genreC=g_experimentale then begin
             codeX := indexVariab[0];
             nomX := grandeurs[codeX].nom;
             nomY := grandeurs[codeY].nom;
             if (j>1) and (UnitePrec<>grandeurs[codeY].nomUnite) then inc(m);
             UnitePrec := grandeurs[codeY].nomUnite;
             iMondeC := m;
             monde[iMondeC].graduation := gLin;
             inc(j);
             if j>MaxOrdonnee then exit;
        end
    end;
    useDefaut := false;
    DessinTexts.clear;
end end;

Procedure FaireMajFichier;
var i : integer;
    ouvrirModele : boolean;
begin
       graphe.etatModele := [];
       Fvaleurs.prevenirPi := true;
       MajFichierEnCours := false;
       OuvrirModele := false;
       MemoModele.lines.Clear;
       for i := 0 to pred(TexteModele.count) do begin
           MemoModele.Lines.Add(TexteModele[i]);
           if TexteModele[i]<>'' then OuvrirModele := true;
       end;
       if TexteModele.Count=0 then begin
          MemoModele.Lines.Add('''Tapez votre fonction sous la forme');
          MemoModele.Lines.Add('''y(t)=a*t+b');
       end;
       for i := 1 to NbrePages do pages[i].modeleErrone := false;
       if not graphe.configCharge then RazCoord;
       setPanelModele(OuvrirModele);
       setPanelModeleGlb(false);
       FValeurs.Feuillets.ActiveTab := FValeurs.ExpSheet;
       FValeurs.SimulationGB.visible := modeAcquisition=AcqSimulation;
       Fvaleurs.expressionsToolBar.enabled := (pageCourante>0) and (nbrePages>0);
       TrigoBtn.Text := captionAngle[angleEnDegre];
       TrigoBtn.hint := hintAngle[angleEnDegre];
       if modeAcquisition=AcqSimulation then begin
          with grandeurs[0] do begin
               FValeurs.MaxiXEdit.text := formatNombre(maxiSimulation,1);
               FValeurs.MiniXEdit.text := formatNombre(miniSimulation,1);
               FValeurs.nomXEdit.text := nom;
               FValeurs.uniteXEdit.text := nomUnite;
               FValeurs.nombreXSB.value := pages[pageCourante].nmes;
          end;
       end;
       if NbrePages>0 then begin
          FValeurs.Memo.visible := true;
          FValeurs.recalculer;
       end;
       if AnimationBtn.isPressed then begin
          PanelAnimation.visible := true;
          panelModele.enabled := false;
          modeleBtn.Enabled := false;
          timerAnimation.enabled := false;
          paintBox1.repaint;
       end;
       modifFichier := false;
end; // faireMajFichier

procedure ResetForme;
var c : integer;
begin
    with graphe do begin
        majFichierEnCours := true;
        configCharge := false;
        curseur := curSelect;
        Modif := [gmXY];
        grapheOK := false;
        OptionGraphe := OptionGrapheDefault;
        graphe.etatModele := [];
        VerifGraphe := true;
        IsModeleMagnum := false;
        reset;
        for c := 1 to maxOrdonnee do with Coordonnee[c] do begin
            nomX  := '';
            nomY  := '';
            codeX := grandeurInconnue;
            codeY := grandeurInconnue;
            iMondeC := mondeY;
            trace := [];
        end;
        cercle.Visible := false;
    end;
    with Fvaleurs do begin
       prevenirPi := true;
       Feuillets.ActiveTab := FValeurs.ExpSheet;
       MesureCourante := 0;
       Memo.lines.Clear;
    end;
    MemoModele.Lines.Add('''Tapez votre fonction sous la forme');
    MemoModele.Lines.Add('''y(t)=a*t+b');
    if ModeleItem.isChecked then setPanelModele(false);
end;

Procedure WmRegInitMagnum;
var i : integer;
begin
     if ModeleGraphique[1].nX='' then
        ModeleGraphique[1].nX := graphe.monde[mondeX].axe.nom;
     if ModeleGraphique[1].nY='' then
        ModeleGraphique[1].nY := graphe.monde[mondeY].axe.nom;
     for i := 1 to NbreModele do begin
        ModeleGraphique[i].initialiseParametre(
          Pages[pageCourante].debut[i],
          Pages[pageCourante].fin[i],true);
        if not ModeleGraphique[i].ModeleOK then begin
          afficheErreur(erModeleGr,0);
          NbreModele := i-1;
          exit;
        end;
        MajModeleGr(i);
     end;
     LanceModele(true);
end;

var m : integer;
    modifParametre : boolean;
begin // WMRegMaj
      include(graphe.Modif,gmXY); // le + général
      case TypeMaj of
          MajNom : graphe.MajNomGr;
          MajSauvePage : graphe.modif := [];
          MajChangePage : begin
              if (graphe.curseur in [curReticuleData]) or
                 not graphe.superposePage
                    then include(graphe.Modif,gmPage)
                    else graphe.Modif := [];
              if FCoordonneesPhys.ModeleEnCours then begin
                 MajParametres;
                 include(graphe.Modif,gmValeurModele);
                 if ([ModeleDefini,ModeleConstruit] <= graphe.etatModele) and
                    (pages[pageCourante].ModeleCalcule) then MajResultat;
              end;
              if ([ModeleDefini,ModeleConstruit] <= graphe.etatModele)
                 and not(pages[pageCourante].ModeleCalcule)
                 and not(pages[pageCourante].ModeleErrone)
                 and FCoordonneesPhys.ModeleEnCours
                 then if graphe.isModeleMagnum
                     then WmRegInitMagnum
                     else if pages[1].ModeleCalcule
                          then lanceModele(true);
             pages[pageCourante].AffecteVariableP(false);
             Fvaleurs.TraceGridVariab;
          end;
          MajAjoutPage : begin
              if (graphe.curseur in [curReticuleData]) or
                  not graphe.superposePage
                    then include(graphe.Modif,gmPage)
                    else graphe.Modif := [];
              pages[PageCourante].modeleErrone := pages[1].modeleErrone;
              if FCoordonneesPhys.ModeleEnCours then begin
                 MajParametres;
                 include(graphe.Modif,gmValeurModele);
              end;
              if ([ModeleDefini,ModeleConstruit] <= graphe.etatModele) and
                 not(pages[1].ModeleErrone) and
                 FCoordonneesPhys.ModeleEnCours
                 then if graphe.isModeleMagnum
                     then WmRegInitMagnum
                     else if pages[1].ModeleCalcule
                         then lanceModele(true)
          end;
          MajSupprPage : if graphe.superposePage then ;
          MajSelectPage : graphe.modif := [gmXY,gmOptions];
          MajValeurAcq,MajValeur,MajIncertitude : graphe.Modif := [gmValeurs];
          MajValeurConst : graphe.Modif := [gmValeurs];
          MajSupprPoints : begin
             graphe.Modif := [gmValeurs];
             FValeurs.TraceGridVariab;
          end;
          MajValeurGr : begin
             graphe.Modif := [gmValeurs];
             FValeurs.TraceGridVariab;
          end;
          MajAjoutValeur : begin
              graphe.Modif := [gmValeurs];
              for m := 1 to NbreModele do with pages[pageCourante] do
                  if (debut[m]=0) and
                     ((fin[m]=-1) or (fin[m]=nmes-2)) then
                     fin[m] := pred(nmes)
          end;
          MajTri : begin
             grandeurs[cDeltat].nom := DeltaMaj+grandeurs[0].nom;
             FValeurs.traceGridVariab;
             exit;
          end;
          MajModele : begin
             Fvaleurs.TraceGridParam;
             UpdateResiduVisibility;
             if panelModele.visible and residusItem.IsChecked  then
                grapheResidu.setCoordonnee(graphe.monde[mondex].mini,graphe.monde[mondex].maxi);
          end;
          MajVide : ResetForme;
          MajGrandeur : if not majFichierEnCours
                    and (graphe.etatModele<>[])
                    and not ajoutDerivee then begin
                       graphe.etatModele := [];
                    // pour prévenir modif etatModele
                    end;
          MajUnites : exclude(graphe.etatModele,UniteParamDefinie);
          MajUnitesParam : begin
             MajResultat;
             FValeurs.traceGridParam;
          end;
          MajFichier : if majFichierEnCours then FaireMajFichier else exit;
      end;
      AnimationBtn.Visible := NbreConstExp>0;
      if NbreConstExp=0 then AnimationBtn.isPressed := false;
      ModifParametre := TypeMaj in [MajSupprPage,MajModele];
      if TypeMaj in [MajIncertitude,MajValeur,MajValeurAcq]
          then begin
             pages[PageCourante].modeleCalcule := false;
             pages[PageCourante].modeleErrone := false;
          end;
      if ModifParametre and FCoordonneesPhys.ModeleEnCours then begin
           MajParametres;
           MajResultat;
           include(graphe.Modif,gmValeurModele);
      end;
      case typeMaj of
           MajSupprPoints : if [ModeleConstruit,ModeleLineaire] <= graphe.etatModele
               then LanceModele(true);
           MajChangePage,MajAjoutPage,MajModele,MajSauvePage : ; // déjà fait
           else begin
                pages[pageCourante].ModeleCalcule := false;
                graphe.etatModele := [];
           end;
      end;
      if (graphe.Modif<>[]) and not MajFichierEnCours then
          paintBox1.repaint;
      if (typeMaj in [MajChangePage,MajAjoutPage,MajSelectPage,MajSupprPage]) and
         (WindowTab.activeTab=valeursTab) and
         (Fvaleurs.Feuillets.activeTab=Fvaleurs.variabSheet)
      then Fvaleurs.Majgraphe(typeMaj);
end; // MajGraphe

procedure MajGrapheParam;

procedure ResetForme;
var c : integer;
begin
    with grapheParam do begin
        curseur := curSelect;
        Modif := [gmXY];
        grapheOK := false;
        OptionGraphe := OptionGrapheDefault;
        grapheParam.etatModele := [];
        VerifGraphe := true;
        reset;
        for c := 1 to maxOrdonnee do with Coordonnee[c] do begin
            nomX  := '';
            nomY  := '';
            codeX := grandeurInconnue;
            codeY := grandeurInconnue;
            iMondeC := mondeY;
            trace := [];
        end;
    end;
    MemoModeleGlb.Lines.Clear;
    MemoModeleGlb.Lines.Add('Tapez votre fonction sous la forme');
    MemoModeleGlb.Lines.Add('y(t)=a*t+b');
    if ModeleGlbBtn.isPressed then setPanelModeleGlb(false);
end;// ResetForme

var modifParametre : boolean;
begin // MajGrapheParam
with grapheParam do begin
      include(Modif,gmXY); // le + général
      case TypeMaj of
          MajNom : MajNomGr;
          MajSauvePage,MajSelectPage : modif := [];
          MajAjoutPage,MajSupprPage : include(Modif,gmPage);
          MajValeurAcq,MajValeur,MajIncertitude,MajValeurConst : Modif := [gmValeurs];
          MajSupprPoints : ;
          MajValeurGr : ;
          MajAjoutValeur : ;
          MajTri : ;
          MajModele : ;
          MajVide : ResetForme;
          MajGrandeur : etatModele := [];
          MajUnites : exclude(etatModele,UniteParamDefinie);
          MajUnitesParam : MajResultatGlb;
          MajFichier : exit;
      end;
      ModifParametre := TypeMaj in [MajSupprPage,MajModele];
      if TypeMaj in [MajIncertitude,MajValeur,MajValeurAcq]
          then begin
             grapheParam.modeleCalcule := false;
             grapheParam.modeleErrone := false;
          end;
      if ModifParametre and FCoordonneesPhys.ModeleEnCours then begin
           MajParametres;
           MajResultatGlb;
           include(Modif,gmValeurModele);
      end;
      case typeMaj of
           MajSupprPoints : if [ModeleConstruit,ModeleLineaire] <= etatModele
               then LanceModeleGlb(true);
           MajChangePage,MajAjoutPage,MajModele,MajSauvePage : ; // déjà fait
           else begin
                grapheParam.ModeleCalcule := false;
                etatModele := [];
           end;
      end;
      if TypeMaj=MajModele then begin
         MajParametres;
         include(Modif,gmValeurModele);
         if ([ModeleDefini,ModeleConstruit] <= etatModele) and
            ModeleCalcule then MajResultatGlb;
      end;
      if (Modif<>[]) and not MajFichierEnCours then
          paintBoxParam.repaint;
end end; // MajGrapheParam

procedure MajStat;

procedure majNomStat;
var i : integer;
begin
     grapheStat.majNomGr;
     if indexStat<NbreGrandeurs then statOptDlg.NomStat := grandeurs[indexStat].nom;
     ListeNom.enabled := false;
     ListeNom.Items.Clear;
     for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
         if genreG=variable then
            ListeNom.Items.add(nom);
     listeNom.itemIndex := ListeNom.items.indexOf(statOptDlg.NomStat);
     if listeNom.itemIndex<0 then
        listeNom.itemIndex := 1;
     listeNom.enabled := true;
     listeNomChange(nil);
end;

begin if (statOptDlg<>nil) and (pageCourante>0) then begin
     grapheStat.modif := [gmXY];
     case typeMaj of
          MajVide : begin
             statOptDlg.nomStat := '';
             statCourante.statOK := false;
          end;
          MajGrandeur : begin
             statCourante := pages[1].Stat;
             statCourante.statOK := false;
          end;
          MajAjoutValeur,MajValeurConst,MajValeurAcq,MajSupprPoints : begin
             paintBoxStat.repaint;
          end;
          MajChangePage,MajSupprPage,MajSelectPage,MajAjoutPage : begin
             paintBoxStat.repaint;
          end;
          MajUnites,MajUnitesParam,MajNom,MajFichier : MajNomStat;
    end;
    end;
end;

begin
    if typeMaj in [MajChangePage,MajSupprPage,MajSelectPage,
                   MajAjoutPage,MajFichier]
         then majPages;
    UpDateMenuItems(nil);
    MajGraphe;
    if windowTab.activeTab=statTab then MajStat;
    FgrapheFFT.WMRegMaj(typeMaj);
    grapheParamTab.visible := (NbrePages>2) and ((NbreConst+NbreParam)>1);
    if grapheParamTab.visible then
       MajGrapheParam;
end;

procedure TFRegressiMain.ZoomAutoBtnClick(Sender: TObject);
begin with graphe do begin
     curMovePermis := false;
     if not grapheOK then exit;
     include(modif,gmEchelle);
     monde[mondeX].defini := false;
     useDefaut := false;
     useDefautX := false;
     autoTick := true;
     paintBox1.repaint
end end;

procedure TFRegressiMain.ZoomAutoGlbBtnClick(Sender: TObject);
begin with grapheParam do begin
     curMovePermis := false;
     if not grapheOK then exit;
     include(modif,gmEchelle);
     monde[mondeX].defini := false;
     useDefaut := false;
     useDefautX := false;
     autoTick := true;
     paintBoxParam.repaint
end end;

procedure TFRegressiMain.PageSuivClick(Sender: TObject);
begin
  WMRegMaj(MajSauvePage);
  if pageCourante<NbrePages
     then inc(PageCourante)
     else pageCourante := 1;
  ChangePage;
end;

procedure TFRegressiMain.PagePrecClick(Sender: TObject);
begin
    WMRegMaj(MajSauvePage);
    if pageCourante>1
       then dec(pageCourante)
       else pageCourante := NbrePages;
    ChangePage
end; // PagePrecedente

procedure TFRegressiMain.PageAddClick(Sender: TObject);
var i : integer;
begin
     case ModeAcquisition of
          AcqClavier,acqSimulation : if ajoutePage then begin
             for i := 1 to NbreConstExp do
                Pages[NbrePages].valeurConst[i] := pages[pred(NbrePages)].valeurConst[i];
             if modeAcquisition=acqSimulation then
                Pages[NbrePages].nmes := pages[pred(NbrePages)].nmes;// ??
             pageCourante := nbrePages;
             WMRegMaj(MajAjoutPage);
             ModifFichier := true;
             if NbreConstExp>0 then begin
                windowTab.ActiveTab := valeursTab;
                FValeurs.Feuillets.ActiveTab := Fvaleurs.paramSheet;
             end
             else if FValeurs.Feuillets.ActiveTab=Fvaleurs.variabSheet then FValeurs.traceGridVariab;
          end;
          AcqFichier : FileAddItemClick(sender);
          AcqVideo : VideoItemClick(sender);
          AcqCourbes : ImageItemClick(Sender);
          AcqBitMap : OptiqueItemClick(sender);
          AcqClipBoard : ;
          AcqChrono : ChronoPhotoMenuClick(sender);
          AcqSon : ;
     end;
end;

procedure TFRegressiMain.PageAddItemClick(Sender: TObject);
begin
  inherited;
  CollerPageItem.Visible := ModeAcquisition=AcqClipBoard;
  PageNewItem.Visible := true;
  case ModeAcquisition of
       AcqClavier : PageNewItem.Text := 'Créer page vierge';
       AcqSimulation : PageNewItem.Text := 'Créer page simulée';
       AcqFichier : PageNewItem.Text := 'Fusionner';
       AcqBitmap,AcqClipBoard,AcqVideo,AcqChrono,AcqCourbes : PageNewItem.Text := 'Ajouter';
       else PageNewItem.Visible := false;
  end;
end;

procedure TFRegressiMain.PageDelClick(Sender: TObject);
begin
     if OKformat(OkDelPage,[IntToStr(pageCourante)]) then begin
        supprimePage(pageCourante,true);
        WMRegMaj(MajSupprPage);
     end;
end;

procedure TFRegressiMain.FileNewClipItemClick(Sender: TObject);
begin
    if not verifSauve then exit;
    ModifFichier := true;
    // tout de suite avant que le presse papiers change
    if FichierRegressi.LitPressePapier
       then FregressiMain.FinOuvertureFichier(true);
    PanelPage.Visible := NbrePages>1;
    WMRegMaj(MajFichier);
end;

procedure TFRegressiMain.FileNewClavierItemClick(Sender: TObject);
begin
      if not verifSauve then exit;
      if NewClavierDlg=nil then application.createForm(TNewClavierDlg,NewClavierDlg);
      CentreForm(newClavierDlg);
      if NewClavierDlg.showModal=mrOK then begin
         optionsDlg.litConfig;
         graphe.configCharge := true;
         graphe.useDefaut := false;
         WMRegMaj(MajFichier);
         windowTab.ActiveTab := valeursTab;
         FValeurs.feuillets.ActiveTab := Fvaleurs.VariabSheet;
      end
      else FileNewSimulationItemClick(Sender);
end;

procedure TFRegressiMain.FrenchActionExecute(Sender: TObject);
begin
    LoadLangFromStrings(Lang1.LangStr['fr']);
    langue := fr;
    setMenu;
    chaineLangue := 'fr';
end;

procedure TFRegressiMain.GrecItemClick(Sender: TObject);
begin
    GrecActif := true;
end;

procedure TFRegressiMain.GBAnimationClick(Sender: TObject);
begin
     graphe.GBAnimationClick(sender);
end;

procedure TFRegressiMain.GBAnimationDblClick(Sender: TObject);
begin
     graphe.GBAnimationDblClick;
end;

procedure TFRegressiMain.FermerItemClick(Sender: TObject);
begin
    setPanelModele(false);
    setPanelModeleGlb(false)
end;

procedure TFRegressiMain.FileAddItemClick(Sender: TObject);

procedure AddFichier(NomFichier : string);
var extension : string;
    p,pageDebut : codePage;
begin
       extension := AnsiUpperCase(extractFileExt(NomFichier));
       if extension='' then begin
          extension := '.RW3';
          nomFichier := ChangeFileExt(nomFichier,extension);
       end;
       PageDebut := nbrePages;
       if extension = '.RW3'
          then FichierRegressi.AjouteWin(NomFichier)
          else if extension = '.CSV'
               then FichierRegressi.LitCSV(NomFichier,false)
               else if FichierRegressi.AjouteTableur(NomFichier)
                    and (nbrePages>pageDebut) then WMRegMaj(MajAjoutPage);
       for p := succ(pageDebut) to NbrePages do pages[p].recalculP;
end;

var i : integer;
begin
   OpenDialog.Title := 'Fusionner';
   lecturePage := true;
   if OpenDialog.execute then if OpenDialog.Files.count>1
        then for i := 0 to OpenDialog.Files.Count - 1 do
             AddFichier(OpenDialog.Files.Strings[I])
        else AddFichier(openDialog.FileName);
    WMRegMaj(MajFichier);
    modifFichier := true;
end;

procedure TFRegressiMain.SelectItemClick(Sender: TObject);
begin
     if WindowTab.ActiveTab = GrapheParamTab
        then grapheParam.ChoixCurseurClick(sender)
        else graphe.ChoixCurseurClick(sender);
end;

procedure TFRegressiMain.StatistiqueOpen;
begin
     if statOptDlg=nil then
        application.createForm(TstatOptDlg,statOptDlg);
end;

procedure TFRegressiMain.StopAnimBtnClick(Sender: TObject);
begin
      TimerAnimation.enabled := false;
end;

procedure TFRegressiMain.SuivantAnimBtnClick(Sender: TObject);
begin
  graphe.paramSuivant
end;

procedure TFRegressiMain.ZoomArrBtnClick(Sender: TObject);
begin
    if not graphe.grapheOK then exit;
    graphe.affecteZoomArriere;
    include(graphe.modif,gmEchelle);
    paintBox1.repaint;
end;

procedure TFRegressiMain.ZoomArrGlbBtnClick(Sender: TObject);
begin
    if not grapheParam.grapheOK then exit;
    grapheParam.affecteZoomArriere;
    include(grapheParam.modif,gmEchelle);
    paintBoxParam.repaint;
end;

procedure TFRegressiMain.ZoomBtnClick(Sender: TObject);
begin
    if graphe.grapheOK then graphe.setPenBrush(curZoomAv)
end;

procedure TFRegressiMain.ZoomGlbBtnClick(Sender: TObject);
begin
    if grapheParam.grapheOK then grapheParam.setPenBrush(curZoomAv)
end;

procedure TFRegressiMain.WindowTabChange(Sender: TObject);
var i : integer;
begin
     if (windowTab.ActiveTab<>ValeursTab) and recompiler then
        Fvaleurs.recalculer;
     if windowTab.ActiveTab=GrapheTab then ;
     if windowTab.ActiveTab=GrapheParamTab then ;
     if windowTab.ActiveTab=StatTab then begin
        statistiqueOpen;
        ListeNom.enabled := false;
        ListeNom.Items.Clear;
        for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
            if genreG=variable then
               ListeNom.Items.add(nom);
        listeNom.itemIndex := ListeNom.items.indexOf(statOptDlg.NomStat);
        if listeNom.itemIndex<0 then
           listeNom.itemIndex := 1;
        listeNom.enabled := true;
        listeNomChange(nil);
        timerStat.enabled := true;
     end;
     if windowTab.ActiveTab=FFTTab then begin
        FgrapheFFT.resetTemps;
        FourierPanel.Repaint;
     end;
     if windowTab.ActiveTab=ValeursTab then begin
        Fvaleurs.expressionsToolBar.enabled := (pageCourante>0) and (nbrePages>0);
        Fvaleurs.imprimeMenu.enabled := imprimanteDisponible;
        Fvaleurs.imprimeGridMenu.enabled := imprimanteDisponible;
        Fvaleurs.SimulationGB.visible := modeAcquisition=AcqSimulation;
        if Fvaleurs.majGridVariab and
           (Fvaleurs.feuillets.ActiveTab=Fvaleurs.variabSheet) then
           Fvaleurs.traceGridVariab;
     end;
end;

procedure TFRegressiMain.TimerLoupeTimer(Sender: TObject);
begin
{$IFDEF MSWindows}
      if (loupeForm<>nil) and
          loupeForm.visible and
          not loupeForm.avecSouris then
            loupeForm.aForm.Active := true
{$ENDIF}
end;

procedure TFRegressiMain.TimerAnimationTimer(Sender: TObject);
begin
    timerAnimation.enabled := false;
    timerAnimation.interval := round(AnimationTB.value);
    timerAnimation.enabled := graphe.paramSuivant;
end;

procedure TFRegressiMain.TimerDemarrageTimer(Sender: TObject);
begin
   timerDemarrage.Enabled := false;
   if not appelExterieur then
      FileNewSimulationItemClick(Sender);
end;

procedure TFRegressiMain.TimerStatTimer(Sender: TObject);
begin
     timerStat.enabled := false;
     PanelValeursStat.repaint;
end;

procedure TFRegressiMain.TitreAnimCBClick(Sender: TObject);
var indexCourant : integer;

procedure AjouteTitre;
var Dessin : TdessinText;
    i : integer;
    atexte : string;
begin
       Dessin := TdessinText.createText(graphe);
       aTexte := '';
       with Dessin do begin
          avecCadre := true;
          identification := identAnimation;
          isOpaque := true;
          affecteXY(graphe.paintBox.width/2,graphe.paintBox.height/20);
          couleurFond := couleurPages[pageCourante];
          color := claWhite;
       end;
       for i := 0 to pred(NbreParamAnimation) do
           if paramAnimation[i].active then
              if aTexte=''
                 then aTexte := ' %C'+intToStr(succ(i))
                 else aTexte := aTexte+' ; %C'+intToStr(succ(i));
       dessin.text := aTexte+' ';
       dessin.texteBrut := aTexte+' ';
       graphe.dessinTexts.add(Dessin);
end; // ajouteTitre

var i : integer;
begin
     indexCourant := -1;
     for i := 0 to pred(graphe.dessinTexts.count) do
       if graphe.dessinTexts[i].identification=identAnimation
          then begin
             indexCourant := i;
             if not titreAnimCB.isChecked then with graphe do
                Dessintexts.remove(dessinTexts[i]);
             break;
          end;
     if not titreAnimCB.enabled then exit;
     if (indexCourant<0) and titreAnimCB.isChecked
        then ajouteTitre;
     if (pageCourante>0) then graphe.paintBox.repaint;
end; // TitreAnimCBClick

procedure TFRegressiMain.TOCitemClick(Sender: TObject);
begin
     if not ShellOpen(HelpFile) then showMessage(stNoAcces+'Aide Regressi')
end;

procedure TFRegressiMain.TBAnimationChange(Sender: TObject);
begin
     if majFichierEnCours then exit;
     AnimationTB.hint := 'Intervalle : '+IntToStr(round(AnimationTB.value))+'ms';
     graphe.SliderAnimationChange(sender);
     paintBox1.repaint;
end;

procedure TFRegressiMain.TrigoBtnClick(Sender: TObject);
var modif : boolean;
begin
     if angleEnDegre
        then Modif := OKreg(OkAngleRadian,0)
        else Modif := OKreg(OkAngleDegre,0);
     if modif then Fvaleurs.ChangeAngle(not AngleEnDegre);
     TrigoBtn.Text := captionAngle[angleEnDegre];
     TrigoBtn.hint := hintAngle[angleEnDegre];
end;

procedure TFRegressiMain.FinOuvertureFichier(LectureOK : boolean);
var p : integer;
begin
     LectureFichier := false;
     LecturePage := false;
     ModifFichier := false;
     if LectureOK
         then begin
           p := 1;
           while (p<NbrePages) and not pages[p].active do inc(p);
           if not pages[p].active then pages[1].active := true;
           MruAdd(nomFichierData);  // Update MRUList
           Caption := 'Regressi ['+nomFichierData+']';
           for p := 1 to NbrePages do
               pages[p].NbrePointsSauves := pages[p].nmes;
        end
        else begin
           MruDel(nomFichierData);
           nomFichierData := '';
           if codeErreurF<>'' then AfficheErreur(codeErreurF,0);
           Caption := 'Regressi';
           FileNewSimulationItemClick(nil);
        end;
     if NbrePages>0
         then PageCourante := 1
         else PageCourante := 0;
     PanelPage.Visible := NbrePages>1;
     WMRegMaj(MajFichier); // fait également majPages
     NbreGrandeursSauvees := NbreGrandeurs;
     UpDateMenuItems(nil);
     if lectureOK then if erreurDetectee or (NbreVariab<2)
        then windowTab.ActiveTab := valeursTab
        else windowTab.ActiveTab := grapheTab;
     Fvaleurs.radDegTabBtn.ImageIndex := indexImageAngle[angleEnDegre];
     Fvaleurs.RadDegExpBtn.imageIndex := Fvaleurs.radDegTabBtn.ImageIndex;
end;

procedure TFRegressiMain.PagesItemClick(Sender: TObject);
begin
     PageSuivItem.enabled := NbrePages>1;
     PagePrecItem.enabled := NbrePages>1;
     PageDelItem.enabled := NbrePages>1;
     PageNewClipItem.Visible := ModeAcquisition=AcqClipBoard;
     PageNewItem.Visible := ModeAcquisition in [AcqClavier,AcqFichier,AcqBitmap,AcqClipBoard,
                             AcqSimulation,AcqVideo,AcqChrono,AcqCourbes];
end;

procedure TFRegressiMain.miniXeditExit(Sender: TObject);
begin
     grapheStat.modif := [gmEchelle];
     PaintBoxStat.repaint;
end;

procedure TFRegressiMain.miniYEditKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
   if key=vkReturn then miniXeditExit(Sender)
end;

procedure TFRegressiMain.MruItemClick(Sender: TObject);
var index : Integer;
    nom : string;
begin
  if not verifSauve then exit;
  Index := TMenuItem(Sender).Tag;
  nom := MruList[Index];
  if FileExists(nom)
     then OpenFile(nom)
     else begin
        afficheErreur(TMenuItem(Sender).Text+erNotExists,0);
        MRUList.delete(index);
        UpdateMenuItems(nil);
     end;
end;

procedure TFRegressiMain.ModeleBtnClick(Sender: TObject);
begin
   setPanelModele(ModeleBtn.IsPressed)
end;

procedure TFRegressiMain.ModeleGlbBtnClick(Sender: TObject);
begin
   setPanelModeleGlb(ModeleGlbBtn.IsPressed)
end;

procedure TFRegressiMain.ModeleGrBtnClick(Sender: TObject);
var p : codePage;
    m : indiceMonde;
begin
    if ChoixModeleDlg=nil then
       Application.createForm(TChoixModeleDlg,ChoixModeleDlg);
    if NbreModele=maxIntervalles then NbreModele := maxIntervalles-1;
    with fonctionTheorique[succ(NbreModele)] do begin
       if graphe.monde[mondeX].axe<>nil then
           indexX := indexNom(graphe.monde[mondeX].axe.nom);
       for m := mondeY to mondeSans do
           if graphe.monde[m].axe<>nil then begin
              indexY := indexNom(graphe.monde[m].axe.nom);
              break;
           end;
    end;
    ChoixModeleDlg.appelMagnum := true;
    ChoixModeleDlg.appelRGS := false;
    ChoixModeleDlg.coordonnee := graphe.coordonnee;
    ChoixModeleDlg.PageControl.ActiveTab := ChoixModeleDlg.ModMagnum;
    centreForm(choixModeleDlg);
    if ChoixModeleDlg.showModal=mrOk then begin
       for p := 1 to NbrePages do
                pages[p].resetDebutFin(NbreModele);
       if ChoixModeleDlg.modeleChoisi=mgManuel
           then begin
              graphe.IsModeleMagnum := false;
              if ChoixModeleDlg.effaceModele then MemoModele.lines.clear;
              with FonctionTheorique[NbreModele] do
                if enTete<>'' then begin
                      MemoModele.lines.Add(enTete+'='+expression);
                      graphe.etatModele := [];
                      lanceModele(genreC=g_fonction);
                      PaintBox1.repaint;
                      exit;
                end
           end
           else ModeleMagnum(true);
    end;
end;

procedure TFRegressiMain.ModeleItemClick(Sender: TObject);
begin
    setPanelModele(ModeleItem.isChecked);
end;

procedure TFRegressiMain.MruAdd(FileName: String);
begin
  if FileName='' then exit;
  MruDel(FileName);
  MruList.Insert(0,Filename);
end;

procedure TFRegressiMain.MruDel(FileName: String);
var i: Integer;
    nomCourt,nomCourtListe : string;
begin
  nomCourt := AnsiUpperCase(extractFileName(FileName));
  for i := pred(MRUList.count) downto 0 do begin
      nomCourtListe := AnsiUpperCase(extractFileName(MRUList[I]));
      if nomCourt = nomCourtListe then MRUList.delete(i);
  end;
end;

procedure TFRegressiMain.MemoModeleChange(Sender: TObject);
var i : codePage;
begin
     if monteCarloActif then exit;
     graphe.etatModele := [];
     MemoResultat.lines.clear;
     if length(MemoModele.text)>5 then
        MemoResultat.Lines.Add(stTest4);
     for i := 1 to NbrePages do begin
         pages[i].ModeleCalcule := false;
         pages[i].ModeleErrone := false;
     end;
end;

procedure TFRegressiMain.MemoModeleGlbChange(Sender: TObject);
begin
     grapheParam.etatModele := [];
     grapheParam.ModeleCalcule := false;
     grapheParam.ModeleErrone := false;
     MemoResultatGlb.lines.clear;
     if length(MemoModeleGlb.text)>5 then
        MemoResultatGlb.Lines.Add(stTest4);
end;

procedure TFRegressiMain.MemoModeleKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
    VerifGrec(MemoModele,key,keyChar,shift)
end;

procedure TFRegressiMain.MenuAxesPopup(Sender: TObject);
begin
  IntersectionBis.IsChecked  := traceIntersection;
  IntersectionBis.visible := NbreModele>1;
end;

procedure TFRegressiMain.EditBidonKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
    if (keyChar=' ')  then BarreEspace;
    keyChar := #0;
    key := 0;
end;

procedure TFRegressiMain.EditionItemClick(Sender: TObject);
var S : tsauvegarde;
begin
   CollerPageItem.enabled := NbrePages>0;
   UndoItem.Visible := PileSauvegarde.count>0;
   If UndoItem.isVisible then begin
      S := PileSauvegarde.peek;
      case S.undo of
           UsupprPage : undoItem.Text  := stUndo+'page';
           UsupprPoint : undoItem.Text  := stUndo+'points';
           UsupprConst,UsupprVariab :
              undoItem.Text  := stUndo+S.GrandeurSauvee.nom;
      end;
   end;
end;

procedure TFRegressiMain.FileNewSimulationItemClick(Sender: TObject);
var   v : codeGrandeur;
begin
      if not verifSauve then exit;
      majFichierEnCours := true;
      optionsDlg.litConfig;
      graphe.configCharge := true;
      graphe.useDefaut := false;
      FichierTrie := true;
      NomFichierData := '';
      ModeAcquisition := AcqSimulation;
      v := ajouteExperimentale('t',variable);
      FValeurs.nomXedit.text := 't';
      grandeurs[v].fonct.expression := 'Variable de contrôle';
      grandeurs[v].NomUnite := 's';
      FValeurs.uniteXedit.text := 's';
      FValeurs.miniXedit.text := FloatToStr(miniSimulation);
      FValeurs.maxiXedit.text := FloatToStr(maxiSimulation);
      AjoutePage;
      pages[pageCourante].nmes := round(Fvaleurs.NombreXSB.value);
      pages[pageCourante].AffecteVariableP(false);
      ModifFichier := true;
      LectureFichier := false;
      LecturePage := false;
      ModifFichier := false;
      majFichierEnCours := true;
      WMRegMaj(MajFichier);
      FValeurs.Memo.Lines.Add('''Tapez sur une ligne des expressions du type');
      FValeurs.Memo.Lines.Add('''y=3*sin(t)');
      FValeurs.Memo.Lines.Add('''ou sélectionner Fichier/Ouvrir');
      Aide.text := 'Sélectionner Fichier Nouveau ou Ouvrir';
      windowTab.activeTab := valeursTab;
end;

procedure TFRegressiMain.FiltreItemClick(Sender: TObject);
var sauveFenetre : Tfenetre;
begin
  inherited;
  sauveFenetre := fenetre;
  optionsFiltreDlg := ToptionsFiltreDlg.Create(self);
  CentreForm(optionsFiltreDlg);
  if (optionsFiltreDlg.showModal=mrOK) and
     (fenetre<>sauveFenetre) then begin
        recalculE;
        WMRegMaj(MajValeur);
  end;
  optionsFiltreDlg.free;
end;

procedure TFRegressiMain.CopyGraphItem(Sender: TObject);
begin
    graphe.VersPressePapier;
end;

procedure TFRegressiMain.PrecedentAnimBtnClick(Sender: TObject);
begin
    graphe.paramPrecedent;
end;

procedure TFRegressiMain.PrintGraphItemClick(Sender: TObject);
var bas : single;
begin
     if not graphe.grapheOK then exit;
     try
     beginPrintGr(bas);
     graphe.versImprimante(bas);
     Printer.EndDoc;
     except
        on E: Exception do begin
              showMessage(E.message);
              try
              printer.abort;
              except
              end;
        end;
     end;
end;

procedure TFRegressiMain.PrintPdfItemClick(Sender: TObject);
begin
     PrintPdfForm := TPrintPdfForm.Create(self);
     CentreForm(printPDFForm);
     PrintPdfForm.showModal;
     PrintPdfForm.Free;
end;

procedure TFRegressiMain.ImageItemClick(Sender: TObject);
begin
      if not verifSauve then exit;
      majFichierEnCours := false;
      if BitmapForm=nil then application.createForm(TBitmapForm,bitmapForm);
      CentreForm(bitmapForm);
      bitmapForm.show;
end;

procedure TFRegressiMain.PrintModeleClick(Sender: TObject);
begin
    Graphe.ImprModeleBtnClick
end;

procedure TFRegressiMain.ImprimeStatItemClick(Sender: TObject);
begin
    statOptDlg.imprimerBeginEnd
end;

procedure TFRegressiMain.IncertItemClick(Sender: TObject);
begin
  if Sender is TMenuItem then
    TraceEllipse := (Sender as TMenuItem).IsChecked
  else
    TraceEllipse := not TraceEllipse;
  IncertItem.IsChecked := TraceEllipse;
  ModeleIncertItem.IsChecked := TraceEllipse;
  paintBox1.repaint;
end;

procedure TFRegressiMain.LegendeItemClick(Sender: TObject);
begin
  graphe.ShowLegend := LegendeItem.IsChecked;
  paintBox1.repaint;
end;

procedure TFRegressiMain.InitEquaDiffBtnClick(Sender: TObject);
const Maxi = 2;
var pente : double;
    k,j : integer;
    i,iDebut,iFin : integer;
begin with pages[pageCourante] do begin
     if FonctionTheorique[1].genreC in [g_diff1,g_diff2] then begin
          for k := 1 to NbreModele do with FonctionTheorique[k] do begin
               if calcul^.varx<>nil
                  then j := GrandeurToIndex(calcul^.varx)
                  else j := 0;
               if (j>parametre0) then begin // origine est bien un paramètre
                     j := IndexToParam(j);
                     ValeurParam[j] := valeurVar[indexY,debut[k]]; // inverse ?
                     paramGrid.cells[3,j-1] := formatGeneral(valeurParam[j],3);
               end;
          end; // origine
          if FonctionTheorique[1].genreC=g_diff2 then
             for k := 1 to NbreModele do with FonctionTheorique[k] do begin
                 if calcul^.vary<>nil
                    then j := GrandeurToIndex(calcul^.vary)
                    else j := 0;
                 if (j>parametre0) and (j<=parametre0+maxParametres) then begin
                 // pente est bien un paramètre
                       j := IndexToParam(j);
                       Pente := 0;
                       i := 0;
                       iDebut := debut[k];
                       iFin := debut[k]+Maxi;
                       while (i<Maxi) and (iDebut>0) do begin dec(iDebut);inc(i) end;
                        // on essaye de centrer
                       for i := iDebut to iFin do
                           Pente := Pente + valeurVar[indexYp,i];
                       Pente := Pente/succ(iFin-iDebut);
                       ValeurParam[j] := pente;
                       paramGrid.cells[3,j-1] := formatGeneral(valeurParam[j],3);
                  end;
          end; // pente initiale
     end;// diff
end end;

procedure TFRegressiMain.InitEquaDiffBtnMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  FregressiMain.Aide.text := InitEquaDiffAction.hint
end;

procedure TFRegressiMain.Inter1Click(Sender: TObject);
begin
   graphe.BorneActive := (sender as Tcomponent).tag;
   graphe.setPenBrush(curBornes);
   activeControl := panelCentral;
end;

procedure TFRegressiMain.IntersectionItemClick(Sender: TObject);
begin
  traceIntersection := not traceIntersection;
  paintBox1.repaint;
end;

procedure TFRegressiMain.CopyGridItemClick(Sender: TObject);
begin
     StatGrid.CopyToClipBoard
end;

procedure TFRegressiMain.CurModeleItemClick(Sender: TObject);
begin
    if curseurModeleDlg=nil then
       curseurModeleDlg := TcurseurModeleDlg.create(self);
    graphe.initCurseurModele;
end;

procedure TFRegressiMain.CurOrigineItemClick(Sender: TObject);
begin
     graphe.setPenBrush(curOrigine);
     graphe.curseur := curOrigine;
     graphe.origin.Offset(paintBox1.position.X,paintBox1.position.Y);
     graphe.ReticuleOrigine.centre := graphe.origin;
     graphe.ReticuleOrigine.isHoriz := false;
     graphe.ReticuleOrigine.visible := true;
end;

procedure TFRegressiMain.CurseurBtnClick(Sender: TObject);
var P : TPointF;
begin
     addModeleItem.enabled := pages[pageCourante].modeleCalcule;
     CurOrigineItem.enabled := not graphe.superposePage;
     P := TpointF.Create(curseurBtn.position.X,curseurBtn.position.y);
     P.Offset(0,3*curseurBtn.height+GrapheToolBar.Position.Y);
     P := ClientToScreen(P);
     curseurMenu.popup(P.x,P.y);
     editBidon.setFocus;
end;

procedure TFRegressiMain.CurseurGlbBtnClick(Sender: TObject);
var P : TPointF;
begin
     addModeleItem.enabled := false;
     CurOrigineItem.enabled := false;
     P := TpointF.Create(CurseurGlbBtn.position.X,CurseurGlbBtn.position.y);
     P.Offset(0,3*CurseurGlbBtn.height);
     P := ClientToScreen(P);
     curseurMenu.popup(P.x,P.y);
     editBidon.setFocus;
end;

procedure TFRegressiMain.CurseurMenuPopup(Sender: TObject);
var i : integer;
begin
    curModeleItem.Visible := nbreModele>0;
    curReticuleModeleItem.Visible := nbreModele>0;
    if nbreModele=0 then begin
    for i := 0 to graphe.courbes.Count-1 do
        if trLigne in graphe.courbes[i].trace then begin
           curReticuleModeleItem.Visible := true;
           curReticuleModeleItem.text := 'Réticule données';
           break;
        end;
    end
    else curReticuleModeleItem.text := 'Réticule modèle'
end;

procedure TFRegressiMain.OptionsStatItemClick(Sender: TObject);
begin
  if statOptDlg = nil then
       Application.CreateForm(TStatOptDlg, statOptDlg);
  CentreForm(statOptDlg);
  if statOptDlg.showModal=mrOK then begin
     include(grapheStat.modif,gmXY);
     PaintBoxStat.repaint;
  end;
end;

procedure TFRegressiMain.CopyGrapheStatItemClick(Sender: TObject);
begin
    grapheStat.VersPressePapier;
end;

procedure TFRegressiMain.CommentaireEditChange(Sender: TObject);
begin
    if pageCourante>0 then
       pages[pageCourante].commentaireP := CommentaireEdit.text
end;

procedure TFRegressiMain.CommentaireEditKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
    VerifGrec(sender,key,keychar,shift);
end;

procedure TFRegressiMain.CoordonneesBtnClick(Sender: TObject);
var oldnomx,oldnomy : string;
begin with FcoordonneesPhys do begin
        if not graphe.grapheOK then exit;
        agraphe := graphe;
        listeConst := false;
        oldNomX := graphe.coordonnee[1].nomX;
        oldNomY := graphe.coordonnee[1].nomY;
        modelePermis := NbreModele>0;
        centreForm(FcoordonneesPhys);
        if FcoordonneesPhys.ShowModal=mrOK then begin
           graphe.Curseur := curSelect;
           include(graphe.modif,gmXY);
           if (graphe.coordonnee[1].nomX<>oldNomX) or
              (graphe.coordonnee[1].nomY<>oldNomY) then begin
              if not graphe.UseDefaut then graphe.DessinTexts.clear;
              if graphe.curseur in [curReticuleData] then graphe.curseur := curSelect;
           end;
           OptionGrapheDefault := graphe.OptionGraphe;
           if not(ModeleItem.isChecked) and
              not modeleEnCours then begin
                 nbreModele := 0;
                 graphe.etatModele := [];
                 setPanelModele(false);
           end;
           paintBox1.Repaint;
      end;
end end;

procedure TFRegressiMain.CoordonneesGlbBtnClick(Sender: TObject);
var oldNomX,oldNomY : string;
begin with FcoordonneesPhys do with grapheParam do begin
        if not grapheOK then exit;
        agraphe := grapheParam;
        listeConst := true;
        oldNomX := coordonnee[1].nomX;
        oldNomY := coordonnee[1].nomY;
        modelePermis := NbreModeleGlb>0;
        centreForm(FcoordonneesPhys);
        if FcoordonneesPhys.ShowModal=mrOK then begin
           Curseur := curSelect;
           include(modif,gmXY);
           if (coordonnee[1].nomX<>oldNomX) or
              (coordonnee[1].nomY<>oldNomY) then begin
              if not UseDefaut then DessinTexts.clear;
           end;
           if (ModeleGlbBtn.isPressed) and
              not modeleEnCours then begin
                 nbreModeleGlb := 0;
                 grapheParam.etatModele := [];
                 setPanelModeleGlb(false);
           end;
           paintBoxParam.Repaint;
      end;
end end;

procedure TFRegressiMain.FormActivate(Sender: TObject);
begin
if premiereFois then begin
     premiereFois := false;
     Application.createForm(TstatOptDlg,statOptDlg);
     Application.CreateForm(TFcoordonneesPhys, FcoordonneesPhys);
     Application.CreateForm(TOptionsDlg, OptionsDlg);
     PrintGraphItem.enabled := imprimanteDisponible;
     FilePrintItem.Enabled := imprimanteDisponible;
     TimerDemarrage.Enabled := true;
end;
end;

procedure TFRegressiMain.FormClose(Sender: TObject;var Action: TCloseAction);
var i : integer;
    Rini : TIniFile;
begin
    if not VerifSauve then exit;
    if Fvaleurs<>nil then Fvaleurs.Close;
    if FgrapheFFT<>nil then FgrapheFFT.Close;
    graphe.Reset;
    grapheResidu.Reset;
    if StatOptDlg<>nil then StatOptDlg.Close;
    Rini := TIniFile.create(registreReg);
    for i := 0 to pred(mruList.Count) do
          Rini.WriteString('Fichier','MRU'+IntToStr(i),MRUList[i]);
    Rini.Free;
    inherited;
end; // FormClose

procedure TFRegressiMain.OptionsVecteursMenuClick(Sender: TObject);
var code, num : integer;
begin
     num := (sender as TMenuItem).tag;
     if (num<1) or (num>MaxOrdonnee) then num := 1;
     OptionsVitesseDlg := TOptionsVitesseDlg.create(self);
     try
        code := graphe.coordonnee[num].codeX;
        OptionsVitesseDlg.grandeurX := grandeurs[code];
        code := graphe.coordonnee[num].codeY;
        OptionsVitesseDlg.grandeurY := grandeurs[code];
        centreForm(OptionsVitesseDlg);
        if OptionsVitesseDlg.showModal=mrOK then PaintBox1.repaint;
     finally
        OptionsVitesseDlg.free;
     end;
end;

procedure TFRegressiMain.OptiqueItemClick(Sender: TObject);
begin
      if not verifSauve then exit;
      majFichierEnCours := false;
      if OptiqueBitmapForm=nil then application.createForm(TOptiqueBitmapForm,optiquebitmapForm);
      CentreForm(optiqueBitmapForm);
      optiqueBitmapForm.show;
end;

procedure TFRegressiMain.OscilloArduinoItemClick(Sender: TObject);
begin
      if not verifSauve then exit;
      (*
      if ArduinoOscilloForm=nil then
         application.createForm(TArduinoOscilloForm,arduinoOscilloForm);
      CentreForm(arduinoOscilloForm);
      arduinoOscilloForm.show;
      *)
end;

procedure TFRegressiMain.OptionsItemClick(Sender: TObject);
var i : integer;
begin
     if optionsDlg = nil then
        Application.CreateForm(TOptionsDlg, optionsDlg);
     CentreForm(optionsDlg);
     if OptionsDlg.showModal=mrOK then begin
        for i := 0 to pred(NbreGrandeurs) do with grandeurs[i]
            do if formatU=fDefaut then precisionU := precision;
        if OptionsDlg.modifDerivee then begin
              recalculE;
              WMRegMaj(MajValeur);
        end;
        if OptionsDlg.modifGraphe and (graphe<>nil) then begin
             if OgQuadrillage in optionGrapheDefault
                  then include(graphe.optionGraphe,OgQuadrillage)
                  else exclude(graphe.optionGraphe,OgQuadrillage);
             if OgZeroGradue in optionGrapheDefault
                  then include(graphe.optionGraphe,OgZeroGradue)
                  else exclude(graphe.optionGraphe,OgZeroGradue);
        end;
     end
end;

procedure TFRegressiMain.OptionsModeleBtnClick(Sender: TObject);
var P : TpointF;
begin
   P := TpointF.Create(optionsModeleBtn.position.X,optionsModeleBtn.position.y);
   P.Offset(0,3*OptionsModeleBtn.height+GrapheToolBar.Position.Y);
   P := ClientToScreen(P);
   popupMenuModele.popup(P.x,P.y);
end;

procedure TFRegressiMain.OptionsModeleClick(Sender: TObject);
begin
   OptionModeleDlg := TOptionModeleDlg.create(self);
   OptionModeleDlg.DlgGraphique := graphe;
   CentreForm(optionModeleDlg);
   if optionModeleDlg.ShowModal=mrOK then begin
       include(graphe.modif,gmOptions);
       paintBox1.repaint;
       compileModeles;
   end;
   OptionModeleDlg.free;
end;

procedure TFRegressiMain.CollerPageItemClick(Sender: TObject);
begin
  if FichierRegressi.ajoutePressePapier then
        FRegressiMain.windowTab.ActiveTab := FregressiMain.grapheTab;
end;

procedure TFRegressiMain.PaintBox1Click(Sender: TObject);
begin
     if graphe.DessinTextCourant<>nil then begin
        graphe.DessinTextCourant.opacity := 1;
        graphe.DessinTextCourant := nil;
     end;
     if (graphe.DessinLineCourant<>nil) then begin
     end;
end;

procedure TFRegressiMain.PaintBox1Gesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
var gesture_name : string;
begin
    GestureToIdent(EventInfo.GestureID, gesture_name);
    if gesture_name='igZoom' then
       graphe.AffecteZoomGesture(EventInfo);
end;

procedure TFRegressiMain.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var P : TPointF;
begin
   if (ssRight in Shift) then begin
      P := PaintBox1.LocalToScreen(TPointF.Create(X, Y));
      MenuAxes.popup(P.x, P.y);
   end
   else graphe.PaintBoxMouseDown(Sender,Button,Shift,X, Y)
end;

procedure TFRegressiMain.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
begin
  graphe.PaintBoxMouseMove(Sender,Shift,X,Y)
end;

procedure TFRegressiMain.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
   Graphe.PaintBoxMouseUp(Sender,Button,Shift,X, Y);
end;

procedure TFRegressiMain.PaintBox1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
begin
   Graphe.PaintBoxMouseWheel(Sender, Shift, WheelDelta, Handled);
end;

procedure TFRegressiMain.PaintBox1DblClick(Sender: TObject);
begin
   if (graphe <> nil) and graphe.grapheOK and (graphe.curseur = curSelect) and
      (not graphe.LegendHitTest(graphe.Origin)) then
      ZoomAutoBtnClick(Sender);
end;

procedure TFRegressiMain.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
begin
  if majFichierEnCours then exit;
  graphe.grapheOK := (pageCourante>0);
  graphe.paintBoxPaint;
  with graphe do VecteursBtn.visible :=
     (courbes.Count>0) and graphe.grapheOK and
     (courbes[0].varX<>nil) and (courbes[0].varY<>nil) and
     (courbes[0].varX<>grandeurs[0]) and (courbes[0].varY<>grandeurs[0]);
  incertItem.isChecked := traceEllipse;
  LegendeItem.IsChecked := graphe.ShowLegend;
  modeleIncertItem.isChecked := traceEllipse;
  grapheToolBar.enabled := graphe.grapheOK;
end;

procedure TFRegressiMain.PaintBoxParamMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
   grapheParam.PaintBoxMouseDown(Sender,Button,Shift,X, Y)
end;

procedure TFRegressiMain.PaintBoxParamMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
   grapheParam.PaintBoxMouseMove(Sender,Shift,X, Y)
end;

procedure TFRegressiMain.PaintBoxParamMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
   grapheParam.PaintBoxMouseUp(Sender,Button,Shift,X, Y)
end;

procedure TFRegressiMain.PaintBoxParamPaint(Sender: TObject; Canvas: TCanvas);
begin
  if majFichierEnCours then exit;
  grapheParam.grapheOK := (NbrePages>2) and ((NbreConst+nbreParam)>1);
  grapheParam.paintBoxPaint;
  grapheParamTB.enabled := grapheParam.grapheOK;
end;

procedure TFRegressiMain.PaintBoxResiduPaint(Sender: TObject; Canvas: TCanvas);
begin
   PanelAjuste.enabled := false;
   grapheResidu.paintBoxPaint(graphe.monde[mondex].mini,graphe.monde[mondex].maxi);
   PanelAjuste.enabled := true;
end;

procedure TFRegressiMain.PaintBoxStatPaint(Sender: TObject; Canvas: TCanvas);
begin
     if statOptDlg=nil then exit;
     with grapheStat do begin
         if (gmXY in modif) or not(grapheOK)
             then statOptDlg.setCoordonnee;
         grapheOK := statCourante.statOK;
      //   paintBox.canvas.Stroke.kind := TBrushKind.None;
         UseDefautX := false;
         draw;
         if statOptDlg.erreurStat<>'' then begin
            aide.text := statOptDlg.erreurStat;
            statOptDlg.erreurStat := '';
         end;
     end;
end;

procedure TFRegressiMain.UpdateResiduVisibility;
begin
  if ResidusItem.IsChecked and PanelModele.Visible then begin // pas le même ordre
    PaintBoxResidu.Visible := True;
    SplitterResidu.Visible := True;
  end else begin
    SplitterResidu.Visible := False;
    PaintBoxResidu.Visible := False;
  end;
end;

procedure TFRegressiMain.paramGlbGridCellButtonClick(Sender: TObject; ACol,
  ARow: Integer; ACell: TTMSFNCGridCell);

procedure ModifParam(paramCourant : integer;coeff : double);
begin
     ParametresGlb[paramCourant].valCourante :=
              ParametresGlb[paramCourant].valCourante*coeff;
     ParamGlbGrid.Cells[3,paramCourant-1] :=
              formatGeneral(ParametresGlb[paramCourant].valCourante,3);
     ParamGlbGrid.Enabled := not TraceAutoCB.isChecked;
     if TraceAutoCB.isChecked then lanceModeleGlb(false)
end;

const
   CoeffParam = 1.023;
   CoeffParamRapide = 2;
var numParam : integer;
begin
    numParam := Arow+1;
    case acol of
         0 : ;
         1 : ModifParam(numParam,1/CoeffParamRapide);
         2 : ModifParam(numParam,1/CoeffParam);
         3 : begin
              ParamGlbGrid.FocusedCell := makeCell(Acol,Arow);
              ParamGlbGrid.EditCell(ParamGlbGrid.focusedCell);
         end;
         4 : ModifParam(numParam,CoeffParam);
         5 : ModifParam(numParam,CoeffParamRapide);
         6 : ModifParam(numParam,-1);
    end;
end;

procedure TFRegressiMain.paramGlbGridCellEditSetData(Sender: TObject; ACol,
  ARow: Integer; CellEditor: TControl; var CellString: string);
begin
    try
       convertCell(cellString);
       if cellString<>'' then ParametresGlb[Arow+1].valCourante := getFloat(cellString);
       lanceModeleGlb(false);
    except
       paramGlbGrid.FocusedCell := MakeCell(Acol,Arow)
    end;
end;

procedure TFRegressiMain.paramGlbGridGetCellClass(Sender: TObject; ACol,
  ARow: Integer; var CellClassType: TTMSFNCGridCellClass);
begin
    if Acol in [1,2,4,5,6] then
       CellClassType := TTMSFNCButtonGridCell;
    if Acol = 0 then
       CellClassType := TTMSFNCFixedGridCell;
end;

procedure TFRegressiMain.paramGlbGridGetCellEditorProperties(Sender: TObject;
  ACol, ARow: Integer; CellEditor: TControl);
begin
    if (Acol=3) and (CellEditor is TTMSFNCGridEdit) then
       (CellEditor as TTMSFNCGridEdit).validChars := '0123456789,.Ee+-';
end;

procedure TFRegressiMain.paramGlbGridGetCellEditorType(Sender: TObject; ACol,
  ARow: Integer; var CellEditorType: TTMSFNCGridEditorType);
begin
    if Acol=3 then CellEditorType := etValidCharsEdit
end;

procedure TFRegressiMain.ParamGridCellButtonClick(Sender: TObject; ACol,
  ARow: Integer; ACell: TTMSFNCGridCell);

procedure ModifParam(paramCourant : integer;coeff : double);
begin
     with pages[pageCourante] do begin
         ValeurParam[paramCourant] :=
              ValeurParam[paramCourant]*coeff;
         ParamGrid.Cells[3,paramCourant-1] :=
              formatGeneral(valeurParam[paramCourant],3);
     end;
     ParamGrid.Enabled := not TraceAutoCB.isChecked;
     if TraceAutoCB.isChecked then lanceModele(false)
end;

const
   CoeffParam = 1.023;
   CoeffParamRapide = 2;
var numParam : integer;
begin
    numParam :=  Arow+1;
    case acol of
         0 : ;
         1 : ModifParam(numParam,1/CoeffParamRapide);
         2 : ModifParam(numParam,1/CoeffParam);
         3 : begin
              paramGrid.FocusedCell := makeCell(Acol,Arow);
              paramGrid.EditCell(paramGrid.focusedCell);
         end;
         4 : ModifParam(numParam,CoeffParam);
         5 : ModifParam(numParam,CoeffParamRapide);
         6 : ModifParam(numParam,-1);
    end;
end;

procedure TFRegressiMain.ParamGridCellEditSetData(Sender: TObject; ACol,
  ARow: Integer; CellEditor: TControl; var CellString: string);
begin
    try
       convertCell(cellString);
       if cellString<>'' then Pages[pageCourante].valeurParam[Arow+1] := getFloat(cellString);
       lanceModele(false);
    except
       paramGrid.FocusedCell := MakeCell(Acol,Arow)
    end;
end;

procedure TFRegressiMain.ParamGridGetCellClass(Sender: TObject; ACol,
  ARow: Integer; var CellClassType: TTMSFNCGridCellClass);
begin
    if Acol in [1,2,4,5,6] then
       CellClassType := TTMSFNCButtonGridCell;
    if Acol = 0 then
       CellClassType := TTMSFNCFixedGridCell;
end;

procedure TFRegressiMain.ParamGridGetCellEditorProperties(Sender: TObject; ACol,
  ARow: Integer; CellEditor: TControl);
begin
    if (Acol=3) and (CellEditor is TTMSFNCGridEdit) then
       (CellEditor as TTMSFNCGridEdit).validChars := '0123456789,.Ee+-';
end;

procedure TFRegressiMain.ParamGridGetCellEditorType(Sender: TObject; ACol,
  ARow: Integer; var CellEditorType: TTMSFNCGridEditorType);
begin
    if Acol=3 then CellEditorType := etValidCharsEdit
end;

procedure TFRegressiMain.PlayAnimBtnClick(Sender: TObject);
begin
    TimerAnimation.enabled := true;
end;

procedure TFRegressiMain.PopupMenuModelePopup(Sender: TObject);
begin
  IntersectionTer.IsChecked := traceIntersection;
  IntersectionTer.visible := nbreModele>1;
end;

procedure TFRegressiMain.ProprieteCourbeClick(Sender: TObject);
begin
  if PropCourbeForm=nil then application.CreateForm(TPropCourbeForm,PropCourbeForm);
  if (graphe.iPropCourbe>=graphe.courbes.Count) or
     (graphe.iPropCourbe<0) then graphe.iPropCourbe := 0;
  PropCourbeForm.Acourbe := graphe.courbes[Graphe.iPropCourbe];
  PropCourbeForm.Agraphe := graphe;
  PropCourbeForm.maj;
  PropCourbeForm.show;
end;

procedure TFRegressiMain.PageSelectItemClick(Sender: TObject);
begin
     selectPageDlg := TselectPageDlg.Create(self);
     SelectPageDlg.caption := stChoixPages;
     SelectPageDlg.appelPrint := false;
     CentreForm(SelectPageDlg);
     SelectPageDlg.showModal;
     selectPageDlg.free;
end;

procedure TFRegressiMain.FilePrintItemClick(Sender: TObject);
begin
     PrintDlg := TPrintDlg.Create(self);
     CentreForm(PrintDlg);
     PrintDlg.showModal;
     PrintDlg.Free;
end;

procedure TFRegressiMain.FocusAcquisitionBtnClick(Sender: TObject);
begin
     PageAddClick(sender);
end;

procedure TFRegressiMain.RazBornesClick(Sender: TObject);
begin
    graphe.RazBornesClick
end;

procedure TFRegressiMain.RaZModeleClick(Sender: TObject);
var p : codePage;
    i : integer;
begin
     if OKreg(okRazParam,0) then
     for p := 1 to NbrePages do with pages[p] do begin
         ModeleCalcule := false;
         ModeleErrone := false;
         TexteResultatModele.clear;
         for i := 1 to MaxParametres do
             ValeurParam[i] := parametres[i].ordreDeGrandeur;
     end;
     if OKreg(okRazModele,0) then begin
           MemoModele.lines.clear;
           MemoResultat.lines.clear;
           graphe.IsModeleMagnum := false;
           graphe.EtatModele := [PasDeModele];
           exclude(graphe.modif,gmModele);
     end;
end;

procedure TFRegressiMain.RazTgItemClick(Sender: TObject);
begin
     graphe.resetEquivalence;
     graphe.paintBox.repaint;
end;

procedure TFRegressiMain.ResidusItemClick(Sender: TObject);
begin
     ResidusItem.IsChecked  := not ResidusItem.IsChecked ;
     UpdateResiduVisibility;
     if ResidusItem.IsChecked  then begin
        WMRegMaj(MajModele);
        paintBoxResidu.height := panelCentral.height/3;
     end;
     invalidate;
end;

procedure TFRegressiMain.UndoItemClick(Sender: TObject);
var S : tsauvegarde;
begin
   S := PileSauvegarde.pop;
   S.restaure;
   case S.undo of
      UsupprPage : WMRegMaj(MajAjoutPage);
      UsupprPoint : WMRegMaj(MajAjoutValeur);
      UsupprConst : WMRegMaj(MajGrandeur);
      UsupprVariab : WMRegMaj(MajGrandeur);
   end;
   S.free;
end;

procedure TFRegressiMain.RecupItemClick(Sender: TObject);
begin
    closeAll;
    FinOuvertureFichier(FichierRegressi.litWin);
    NomFichierData := '';
    modifFichier := true;
end;

procedure TFRegressiMain.EnglishActionExecute(Sender: TObject);
begin
   LoadLangFromStrings(Lang1.LangStr['en']);
   langue := en;
   setMenu;
   chaineLangue := 'en';
end;

procedure TFRegressiMain.EnregistreBtnClick(Sender: TObject);
begin
   FileSaveItemClick(Sender)
end;

procedure TFRegressiMain.ExemplesItemClick(Sender: TObject);
begin
  OpenDialog.Title := stOuvrir;
  OpenDialog.InitialDir := ExemplesPath;
  if OpenDialog.execute then
     OpenFile(openDialog.FileName);
end;

procedure TFRegressiMain.SaveCSVItemClick(Sender: TObject);
var oldFilter, oldExt, oldFile, nomFichier : string;
begin with SaveDialog do begin
    oldFilter := Filter;
    oldExt := DefaultExt;
    oldFile := FileName;
    try
       Filter := 'Tableur csv|*.csv';
       DefaultExt := 'csv';
       FileName := extractFileName(nomFichierData);
       if FileName='' then FileName := 'donnees';
       FileName := changeFileExt(FileName,'.csv');
       if Execute then begin
          nomFichier := changeFileExt(FileName,'.csv');
          FichierRegressi.ecritTableur(nomFichier);
       end;
    finally
       Filter := oldFilter;
       DefaultExt := oldExt;
       FileName := oldFile;
    end;
end end;

procedure TFRegressiMain.SaveGrapheStatItemClick(Sender: TObject);
var abitmap : Tbitmap;
    nomFichier : string;
begin
    if grapheSaveDialog.Execute then begin
       aBitmap := ZoneClipBoardStat.MakeScreenshot;
       nomFichier := grapheSaveDialog.fileName;
       nomFichier := changeFileExt(nomFichier,'.png');
       abitmap.saveToFile(nomFichier);
    end;
end;

procedure TFRegressiMain.SaveGraphItemClick(Sender: TObject);
var abitmap : Tbitmap;
    nomFichier : string;
begin
    if grapheSaveDialog.Execute then begin
       aBitmap := ZoneClipBoard.MakeScreenshot;
       nomFichier := grapheSaveDialog.fileName;
       nomFichier := changeFileExt(nomFichier,'.png');
       abitmap.saveToFile(nomFichier);
    end;
end;

procedure TFRegressiMain.PageAddBtnClick(Sender: TObject);
begin
   PageAddClick(Sender);
end;

procedure TFRegressiMain.EmbeddForm(AParent:TControl; AForm:TCustomForm);
begin
    while AForm.ChildrenCount>0 do
          AForm.Children[0].Parent := AParent;
end;

procedure TFRegressiMain.SetPanelModele(NouvelEtat : boolean);
var i : integer;
begin
   if not graphe.grapheOK then NouvelEtat := false;
   PanelModele.Visible := NouvelEtat;
   UpdateResiduVisibility;
   FcoordonneesPhys.modeleEnCours := NouvelEtat;
   ModeleItem.IsChecked := NouvelEtat;
   ModeleBtn.IsPressed := NouvelEtat;
   if NouvelEtat
      then begin
           PanelModele.repaint;
           graphe.VerifGraphe := false;
           if not(ModeleDefini in graphe.etatModele)
               then begin
                  LanceCompileModele;
                  MajParametres;
               end;
      end
      else begin
        if ModeleDefini in graphe.etatModele then
        for i := 1 to Graphe.NbreOrdonnee do
            with Graphe.Coordonnee[i] do begin
                 include(trace,trLigne);
                 ligne := liModele;
                 include(trace,trPoint);
            end;
     end;
end;

procedure TFRegressiMain.SetPanelModeleGlb(NouvelEtat : boolean);
var i : integer;
begin
   if not grapheParam.grapheOK then NouvelEtat := false;
   PanelModeleGlb.Visible := NouvelEtat;
   FcoordonneesPhys.modeleEnCours := NouvelEtat;
   ModeleGlbBtn.IsPressed := NouvelEtat;
   if NouvelEtat
      then begin
           PanelModeleGlb.repaint;
           grapheParam.VerifGraphe := false;
           if not(ModeleDefini in grapheParam.etatModele)
               then begin
                  grapheParam.LanceCompileModele;
                  grapheParam.MajParametres;
               end;
      end
      else begin
        if ModeleDefini in grapheParam.etatModele then
        for i := 1 to GrapheParam.NbreOrdonnee do
            with GrapheParam.Coordonnee[i] do begin
                 include(trace,trLigne);
                 ligne := liModele;
                 include(trace,trPoint);
            end;
     end;
end;

procedure TFRegressiMain.CompileModeles;
var memoActif : boolean;
    i,posFin : integer;
begin
     memoActif := memoModele=activeControl;
     LanceCompileModele;
     if ModeleDefini in graphe.etatModele
        then begin
          if (ModeleLineaire in graphe.etatModele)
          then lanceModele(true)
          else begin
             WMRegMaj(MajModele);
             if memoActif then begin
                posFin := 0;
                for i := 0 to pred(MemoModele.Lines.count) do
                   posFin := posFin+Length(MemoModele.Lines[i])+2;
                memoModele.selStart := posFin;
                memoModele.selLength := 0;
             end
             else if panelModele.visible then AjustePanelModele;
          end;
      end
      else if PasDeModele in graphe.etatModele then
           WMRegMaj(MajModele);
end;

procedure TFRegressiMain.AjustePanelModele;
const HauteurMini = 76;
var hauteurAjuste,hauteurPanel,hauteurResultat : single;
begin
     hauteurPanel := ClientHeight-ModeleToolbar.height;
// valeurs par défaut
     HauteurAjuste := NbreParam*ParamGrid.defaultRowHeight+Panel1.height+16;
     hauteurResultat := hauteurPanel-MemoModele.height-HauteurAjuste;
// on teste si résultat pas trop petit
     if (hauteurResultat<HauteurMini) then
        if ((HauteurPanel-MemoModele.height-HauteurMini)>HauteurMini)
           then HauteurAjuste := HauteurPanel-MemoModele.height-HauteurMini
 // on ajuste panelAjuste résultat à mini
           else HauteurAjuste := HauteurPanel/3; // on divise en trois
// on affecte
     PanelAjuste.height := hauteurAjuste;
end;

procedure TFRegressiMain.AjustePanelModeleGlb;
const HauteurMini = 76;
var hauteurAjuste,hauteurPanel,hauteurResultat : single;
begin
     hauteurPanel := PanelModeleGlb.height;
     if hauteurPanel<=0 then hauteurPanel := ClientHeight-GrapheParamTB.height;
// valeurs par défaut
     HauteurAjuste := NbreParamGlb*ParamGlbGrid.defaultRowHeight+Panel2.height+16;
     hauteurResultat := hauteurPanel-MemoModeleGlb.height-HauteurAjuste;
// on teste si résultat pas trop petit
     if (hauteurResultat<HauteurMini) then
        if ((HauteurPanel-MemoModeleGlb.height-HauteurMini)>HauteurMini)
           then HauteurAjuste := HauteurPanel-MemoModeleGlb.height-HauteurMini
 // on ajuste ScrollBoxParam résultat à mini
           else HauteurAjuste := HauteurPanel/3; // on divise en trois
// on affecte
     ScrollBoxParam.height := hauteurAjuste;
end;

procedure TFRegressiMain.AnimationBtnClick(Sender: TObject);
begin
   if (pageCourante=0) or (NbreConstExp=0) or majFichierEnCours then exit;
 //  AnimationBtn.isPressed := not (AnimationBtn.isPressed);
   if AnimationBtn.isPressed then graphe.setAnimation;
   PanelAnimation.visible := animationBtn.isPressed;
   panelModele.enabled := not AnimationBtn.isPressed;
   modeleBtn.Enabled := not AnimationBtn.isPressed;
   timerAnimation.enabled := false;
   graphe.modif := [gmXY];
   paintBox1.repaint;
end;

procedure TFRegressiMain.ArduinoItemClick(Sender: TObject);
begin
      if not verifSauve then exit;
      (*
      if ArduinoForm=nil then
         application.createForm(TArduinoForm,arduinoForm);
      CentreForm(arduinoForm);
      arduinoForm.show;
      *)
end;

procedure TFregressiMain.LanceCompileModele;
var PosErreur,longErreur,i : integer;
begin
     graphe.etatModele := [];
     NbreModele := 0;
     NbreFonctionSuper := 0;
     NbreParam := 0;
     PosErreur := 0;
     LongErreur := 0;
     while (MemoModele.lines.count>0) and
           (MemoModele.lines[0]='') do MemoModele.lines.delete(0);
     while (MemoModele.lines.count>2) and
           (MemoModele.lines[MemoModele.lines.count-1]='') and
           (MemoModele.lines[MemoModele.lines.count-2]='')
          do MemoModele.lines.delete(MemoModele.lines.count-1);
     graphe.compileModele(posErreur,longErreur);
     if ModeleDefini in graphe.etatModele
        then begin
             graphe.ConstruitModele;
             InitEquaDiffBtn.visible := (fonctionTheorique[1].genreC=g_diff2) or
              ( ajusteOrigine and (fonctionTheorique[1].genreC=g_diff1) );
             if InitEquaDiffBtn.visible then
             InitEquaDiffAction.hint := hInitialise+fonctionTheorique[1].addrYp.nom+'0 ';
             for i := 1 to NbreParam do
                 pages[pageCourante].nomParam[i] := parametres[i].nom;
             for i := succ(NbreParam) to maxParametres do
                 pages[pageCourante].nomParam[i] := '';
        end
        else if not (PasDeModele in graphe.etatModele) then with memoModele do begin
             selStart := pred(posErreur);
             selLength := longErreur;
             InitEquaDiffBtn.visible := false;
             if isVisible then setFocus;
        end;
    AjustePanelModele;
    ParamGrid.enabled := true;
end; // LanceCompileModele

Procedure TFregressiMain.MajParametres;
var i,acol,arow : integer;
begin with pages[pageCourante],ParamGrid do begin
       VerifIntervalles;
       verifParametres;
       ColumnCount := 7;
       RowCount := NbreParam;
       for i := 1 to pred(columnCount) do // Button de size 24
           ColumnWidths[i] := 28;
       ColumnWidths[3] := 64;
       ColumnWidths[0] := 40;
       for i := 1 to NbreParam do begin
           Cells[0,i-1] := Parametres[i].nom;
           Cells[3,i-1] := formatGeneral(valeurParam[i],3);
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
       //        FontNames[aCol,aRow]:= FonteRegressi;
           end;
end end; // MajParametres

procedure TFregressiMain.MajModeleGr(NumeroGr : integer);
var sauveParam : tableauParam;
begin with pages[pageCourante] do begin
     sauveParam := valeurParam;
     ModeleGraphique[NumeroGr].GetParametres(valeurParam);
     if ModeleGraphique[NumeroGr].ModeleOK
        then begin
            graphe.EffectueModele(false,false);
            MajParametres;
            MajResultat;
        end
        else valeurParam := sauveParam;
     include(graphe.modif,gmEchelle);
     include(graphe.modif,gmValeurModele); // ?
     PaintBox1.repaint;
end end;

procedure TFregressiMain.ModeleMagnum(changeDebut : boolean);
var j : integer;
begin with ModeleGraphique[NbreModele] do begin
     init(ChoixModeleDlg.ModeleChoisi,graphe,NbreModele);
     initialiseParametre(
        Pages[pageCourante].debut[NbreModele],
        Pages[pageCourante].fin[NbreModele],
        changeDebut);
     if not ModeleOK then begin
        afficheErreur(erModeleGr,0);
        NbreModele := 0;
        exit;
     end;
     if ChoixModeleDlg.effaceModele then MemoModele.lines.clear;
     for j := 0 to pred(expression.count) do
         MemoModele.lines.Add(expression[j]);
     graphe.etatModele := [];
     graphe.IsModeleMagnum := true;
     LanceCompileModele;
     include(Graphe.modif,gmModele);
     graphe.setPenBrush(curSelect);
     pages[pageCourante].resetDebutFin(NbreModele);
     MajModeleGr(NbreModele);
     LanceModele(true);
end end; // modeleMagnum

procedure TFRegressiMain.ModelesActionExecute(Sender: TObject);
var p : codePage;
    m : indiceMonde;
begin
    if choixModeleDlg=nil then
       Application.CreateForm(TChoixModeleDlg, choixModeleDlg);
        if NbreModele=maxIntervalles then NbreModele := maxIntervalles-1;
    with graphe,fonctionTheorique[succ(NbreModele)] do begin
       if monde[mondeX].axe<>nil then
           indexX := indexNom(monde[mondeX].axe.nom);
       for m := mondeY to mondeSans do
           if monde[m].axe<>nil then begin
              indexY := indexNom(monde[m].axe.nom);
              break;
           end;
    end;
    ChoixModeleDlg.appelMagnum := true;
    ChoixModeleDlg.coordonnee := graphe.coordonnee;
    ChoixModeleDlg.PageControl.ActiveTab := ChoixModeleDlg.ModMagnum;
    centreForm(ChoixModeleDlg);
    if ChoixModeleDlg.showModal=mrOk then begin
       for p := 1 to NbrePages do
                pages[p].resetDebutFin(NbreModele);
       if ChoixModeleDlg.modeleChoisi=mgManuel
           then begin
            //  IsModeleMagnum := false;
              if ChoixModeleDlg.effaceModele then MemoModele.Lines.clear;
              with FonctionTheorique[NbreModele] do
                if enTete<>'' then begin
                      MemoModele.lines.Add(enTete+'='+expression);
                      graphe.etatModele := [];
                      lanceModele(genreC=g_fonction);
                      PaintBox1.repaint;
                      exit;
                end
           end
           else ModeleMagnum(true);
    end;
end;

procedure TFregressiMain.MajResultat;

Procedure Ajoute(const Aligne : string);
begin
    MemoResultat.Lines.add(Aligne);
    Pages[pageCourante].TexteResultatModele.add(Aligne);
end;

var m : integer;
    i : integer;
    PourCent : string;
    DebutCalcul : integer;
    setParam : TsetGrandeur;
begin
if monteCarloActif then exit;
with pages[pageCourante] do begin
    MemoResultat.lines.Clear;
    TexteResultatModele.clear;
    setParam := [];
    if ModeleCalcule then begin
    Ajoute(stIntervalle95);
    for m := 1 to NbreModele do with fonctionTheorique[m] do begin
        PourCent := chainePrec(PrecisionModele[m]);
        Ajoute(stEcartRelatif);
        Ajoute(PourCent+' sur '+enTete);
        if Chi2Actif
           then Ajoute('Chi2/(N-p)='+formatGeneral(chi2Relatif,precisionMin))
           else Ajoute(stSigmaY+addrY.formatNomEtUnite(sigmay));
        if (PrecisionModele[m]>0.5) and InitiationAfaire then begin
           InitiationAfaire := false;
           afficheErreur(erEcart,0);
        end;
        if ErreurModele then Ajoute(erPointModele+IntToStr(PosErreurModele));
    end;
    for m := 2 to NbreModele do with fonctionTheorique[m] do
        if not isNan(Y_inter[m]) and not isNan(X_inter[m]) then begin
             Ajoute(stIntersection+' '+
                    IntToStr(pred(m))+'-'+IntToStr(m)+' : ');
             Ajoute(grandeurs[indexX].formatNomEtUnite(X_inter[m])+'  '+
                    grandeurs[indexY].formatNomEtUnite(Y_inter[m]));
             Ajoute('');
        end;
    if ParamAjustes
       then begin
          for i := 1 to NbreParam do begin
             Ajoute(ParamEtPrec(i,true));
             paramGrid.cells[3,i-1] := FormatGeneral(ValeurParam[i],3);
             include(setParam,ParamToIndex(i));
          end;
       end
       else Ajoute(stTest1);
    debutCalcul := 0;
    for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do begin
        if (fonct.genreC<>g_experimentale) and
           ((setParam * fonct.depend) <> [] ) then begin
           debutCalcul := i;
           break;
        end;
    end;
    if debutCalcul>0 then RecalculP;
    end; // ModeleCalcule
end end; // MajResultat

procedure TFRegressiMain.MajResultatGlb;
var m, i : integer;
    PourCent : string;
begin
     MemoResultatGlb.lines.Clear;
     if grapheParam.ModeleCalcule then begin
        MemoResultatGlb.Lines.Add(stIntervalle95);
        for m := 1 to NbreModeleGlb do with fonctionTheoriqueGlb[m] do begin
            PourCent := chainePrec(PrecisionModeleGlb[m]);
            MemoResultatGlb.Lines.Add(stEcartRelatif);
            MemoResultatGlb.Lines.Add(PourCent+' sur '+enTete);
            if Chi2ActifGlb
               then MemoResultatGlb.Lines.Add('Chi2/(N-p)='+formatGeneral(chi2Relatif,precisionMin))
               else MemoResultatGlb.Lines.Add(stSigmaY+addrY.formatNomEtUnite(sigmay));
        end;
        for i := 1 to NbreParamGlb do with parametresGlb[i] do begin
            if isNan(studentParamGlb[i])
               then MemoResultatGlb.Lines.Add(nom+' = '+formatValeurEtUnite(valCourante))
               else MemoResultatGlb.Lines.Add(nom+' = '+formatValeurEtUnite(valCourante)+
                    ' '#$00B1' '+formatValeurEtUnite(studentParamGlb[i]));
            if (i - 1) < ParamGlbGrid.RowCount then
               ParamGlbGrid.Cells[3, i - 1] := FormatGeneral(valCourante, 3);
        end;
     end;
end; // MajResultatGlb

procedure TFRegressiMain.MajResultatLatex(p : codePage);

Procedure Ajoute(Aligne : string;Acolor : TAlphaColor);
begin
    if (Acolor<>claBlack) and (NbreModele>1) then Aligne := '{\color{'+couleurLatex(Acolor)+'} '+Aligne+'}';
    Pages[p].TexteResultatModele.add(Aligne);
end;

var m : shortInt;
    i : integer;
    hintOrigine : string;
begin with pages[p] do begin
   TexteResultatModele.clear;
   if not ModeleCalcule then exit;
   for m := 1 to NbreModele do with fonctionTheorique[m] do
       Ajoute(stEcartRelatif+'  '+enTete+' : '+chainePrec(PrecisionModele[m]),couleurM);
   for m := 1 to NbreModele do with fonctionTheorique[m] do begin
       if Chi2Actif
          then Ajoute('Chi2/(N-p)='+formatGeneral(chi2Relatif,precisionMin),couleurM)
          else Ajoute(stSigmaY+' '+addrY.formatNomEtUnite(sigmaY),couleurM);
       if ErreurModele then Ajoute(erPointModele+IntToStr(PosErreurModele),couleurM);
   end; // for m
   for m := 2 to NbreModele do with fonctionTheorique[m] do
       if not(isNan(Y_inter[m])) and not(isNan(X_inter[m])) then begin
           hintOrigine := stIntersection+IntToStr(pred(m))+'-'+IntToStr(m)+' : ';
           hintOrigine := hintOrigine+grandeurs[indexX].formatValeuretUnite(X_inter[m]);
           hintOrigine := hintOrigine+', ';
           hintOrigine := hintOrigine+grandeurs[indexY].formatValeurEtUnite(Y_inter[m]);
           Ajoute(hintOrigine,claBlack);
   end;
   if ParamAjustes then begin
        Ajoute('Les incertitudes sont des incertitudes types',claBlack);
        for i := 1 to NbreParam do begin
            hintOrigine := ParamEtPrec(i,true);
            if abs(incertParam[i]/ValeurParam[i])<PrecisionMaxParam
                then Ajoute(hintOrigine+ ' '+stTropPrecis,claRed)
                else Ajoute(hintOrigine,claBlack);
        end;
   end;
end end; // MajResultatLatex

procedure TFregressiMain.LanceModele(ajuste : boolean);
var m : integer;
label finProc;
begin
     if not(FCoordonneesPhys.ModeleEnCours) then exit;
     PanelAjuste.enabled := true;
     if not (ModeleDefini in graphe.etatModele) then begin
        lanceCompileModele;
        if not (ModeleDefini in graphe.etatModele) then begin
           goto finProc;
        end;
     end;
     if not (ModeleConstruit in graphe.etatModele) then begin
        graphe.ConstruitModele;
        if not (ModeleConstruit in graphe.etatModele) then begin
        // erreur ?
           goto finProc;
        end;
     end;
     if not (UniteParamDefinie in graphe.etatModele) then begin
         chercheUniteParametre;
         include(graphe.etatModele,UniteParamDefinie);
     end;
     pages[pageCourante].VerifIntervalles;
     VerifParametres;
     if graphe.modeleDependant or not ajuste
        then graphe.EffectueModele(ajuste,true)
        else begin
          for m := 1 to NbreModele do
              graphe.EffectueModeleMono(m);
          graphe.calcIntersection;
        end;
     if ajuste and not pages[pageCourante].modeleCalcule then graphe.EffectueModele(false,true);
     if (OmEchelle in graphe.OptionModele) then
        graphe.monde[mondeX].Defini := false;
     finProc :
     PanelAjuste.enabled := true;
     if ajuste then ModifFichier := true;
     if not monteCarloActif then WMRegMaj(MajModele);
     ParamGrid.enabled := true;
     BornesBtn.Enabled := nbreModele>0;
end;// LanceModele

procedure TFregressiMain.LanceModeleGlb(ajuste : boolean);
label finProc;
begin
     if not(FCoordonneesPhys.ModeleEnCours) then exit;
     if not (ModeleDefini in grapheParam.etatModele) then begin
        grapheParam.lanceCompileModele;
        AjustePanelModeleGlb;
        ParamGlbGrid.enabled := true;
        if not (ModeleDefini in grapheParam.etatModele) then begin
           goto finProc;
        end;
     end;
     if not (ModeleConstruit in grapheParam.etatModele) then begin
        grapheParam.ConstruitModele;
        if not (ModeleConstruit in grapheParam.etatModele) then begin
        //  erreur ?
           goto finProc;
        end;
     end;
     if not (UniteParamDefinie in grapheParam.etatModele) then begin
         chercheUniteParametreGlb;
         include(grapheParam.etatModele,UniteParamDefinie);
     end;
     grapheParam.VerifIntervalles;
     grapheParam.VerifParametres;
     grapheParam.EffectueModele(ajuste);
     if (OmEchelle in grapheParam.OptionModele) then
        grapheParam.monde[mondeX].Defini := false;
     finProc :
     if ajuste then ModifFichier := true;
     WMRegMaj(MajModele);
     ParamGlbGrid.enabled := true;
end;// LanceModeleGlb

procedure TFregressiMain.DragEnter(const Data: TDragObject; const Point: TPointF);
begin
  FHandleDragDirectly := (Data.Files <> nil);
  if not FHandleDragDirectly then inherited;
end;

procedure TFregressiMain.DragOver(const Data: TDragObject; const Point: TPointF;
  var OPeration: TDragOperation);
begin
 // if FHandleDragDirectly  then Accept := True  else inherited;
end;

procedure TFregressiMain.DragDrop(const Data: TDragObject; const Point: TPointF);
var
  S: string;
begin
  if FHandleDragDirectly
     then for S in Data.Files do
        OpenFile(S)
     else inherited;
end;

procedure TFRegressiMain.SetMenu;
 // TLang ne traduit pas les menus ni les tab !?
begin
  if Langue=en then begin
     exitItem.Text := 'Quit Regressi';
     optionsItem.Text := 'Preferences…';
     aboutItem.Text := 'About…';

     FileItem.text := 'File';
     fileSaveItem.Text := 'Save';
     fileCloseItem.Text := 'Close';
     fileSaveasItem.Text := 'Save as…';
     fileOpenItem.Text := 'Open…';
     filePrintItem.Text := 'Print…';
     fileNewItem.Text := 'New';
     fileNewClipItem.Text := 'Clipboard';
     fileNewSimulationItem.Text := 'Simulation';
     fileNewClavierItem.Text := 'Keyboard…';
     printPdfItem.Text := 'to PDF…';

     HelpItem.Text := 'Help';
     TOCItem.Text := 'Help';

     EditionItem.Text := 'Edit';
     copyItem.Text := 'Copy';
     cutItem.Text := 'Cut';
     deleteItem.Text := 'Delete';
     pasteItem.Text := 'Paste';
     collerPageItem.Text := 'Paste sheet';
     collerNewDocItem.Text := 'Paste data';
     grecItem.text := 'Greek';
     filtreItem.text := 'Filter options';

     pageDelItem.Text := 'Delete';
     pageNewClipItem.Text := 'Clipboard';
     pageNewItem.Text := 'New';
     pagePrecItem.Text := 'Previous';
     pageSuivItem.Text := 'Next';
     pageSelectItem.Text := 'Select';
     pageTrierItem.Text := 'Sort';
     pagesItem.Text := 'Sheets';

     valeursTab.Text := 'Quantities';
     grapheTab.Text := 'Graph';
     FFTTab.Text := 'Fourier';
     StatTab.Text := 'Statistics';
     GrapheParamTab.Text := 'Param. graph';

     SaveCSVItem.Text := 'Export CSV…';
     OptiqueItem.Text := 'Diffraction…';
     LatexMenu.Text := 'Export LaTeX…';
     MonteCarloItem.Text := 'Monte-Carlo';

  end;
  if langue=fr then begin
     exitItem.Text := 'Quitter Regressi';
     optionsItem.Text := 'Préférences…';
     aboutItem.Text := 'A propos…';

     FileItem.text := 'Fichier';
     fileSaveItem.Text := 'Enregistrer';
     fileSaveasItem.Text := 'Enregistrer sous…';
     FilePrintItem.Text := 'Imprimer…';
     fileOpenItem.Text := 'Ouvrir…';
     fileCloseItem.Text := 'Fermer';
     fileNewItem.Text := 'Nouveau';
     fileNewClipItem.Text := 'Presse-papiers';
     fileNewSimulationItem.Text := 'Simulation';
     fileNewClavierItem.Text := 'Clavier…';
     printPdfItem.Text := 'Exporter PDF…';

     HelpItem.Text := 'Aide';
     TOCItem.Text := 'Aide';

     EditionItem.Text := 'Edition';
     copyItem.Text := 'Copier';
     pasteItem.Text := 'Coller';
     cutItem.Text := 'Couper';
     deleteItem.Text := 'Supprimer';
     collerPageItem.Text := 'Coller page';
     collerNewDocItem.Text := 'Coller document';
     grecItem.text := 'Grec';
     filtreItem.text := 'Options filtrage';

     pageDelItem.Text := 'Supprimer';
     pageNewClipItem.Text := 'Presse-papiers';
     pageNewItem.Text := 'Nouvelle';
     pagePrecItem.Text := 'Précédente';
     pageSuivItem.Text := 'Suivante';
     pageSelectItem.Text := 'Sélectionner';
     pageTrierItem.Text := 'Trier';
     pagesItem.Text := 'Pages';

     valeursTab.Text := 'Grandeurs';
     grapheTab.Text := 'Graphe';
     FFTTab.Text := 'Fourier';
     StatTab.Text := 'Statistique';
     GrapheParamTab.Text := 'Graphe param.';

     SaveCSVItem.Text := 'Exporter CSV…';
     OptiqueItem.Text := 'Optique…';
     LatexMenu.Text := 'Exporter LaTeX…';
     MonteCarloItem.Text := 'Monte-Carlo';
  end;
end;

procedure TFRegressiMain.LatexMenuClick(Sender: TObject);
begin
     LatexDlg := TLatexDlg.Create(self);
     CentreForm(LatexDlg);
     LatexDlg.showModal;
     LatexDlg.Free;
end;

procedure TFRegressiMain.MonteCarloItemClick(Sender: TObject);
var i,j,k,m : integer;
    StatParam : array of TcalculStatistique;
    sauveValeur : array of Tvecteur;
    g : TGrandeur;
    somme,z,coeffChi2 : double;
    incertitudeConnue : array[codeGrandeur] of boolean;
    dy,dt : double;
    indexG : codeGrandeur;
begin
    for j := 0 to pred(NbreVariab) do
        incertitudeConnue[j] := pages[pageCourante].isIncertitudeDefinie(j);
    for j := 1 to NbreModele do with fonctionTheorique[j] do begin
        if not(incertitudeConnue[indexY]) or
           not(incertitudeConnue[indexX]) then begin
               afficheErreur('Incertitudes non définies',0);
               exit;
         end;
    end;
    MonteCarloActif := true;
    setLength(statParam,NbreParam+1);
    for j := 1 to NbreParam do begin
        statParam[j] := TcalculStatistique.create;
        statParam[j].nbre := NbreMC;
        setLength(statParam[j].Donnees,NbreMC);
    end;
    setLength(sauveValeur, NbreGrandeurs);
    pages[pageCourante].affecteVariableP(false);
    for j := 0 to pred(NbreVariabExp) do begin
        indexG := indexVariabExp[j];
        copyVecteur(sauveValeur[indexG],grandeurs[indexG].valeur);
    end;
    for i := 0 to pred(NbreMC) do begin
         for j := 0 to pred(NbreVariabExp) do begin
             indexG := indexVariabExp[j];
             if incertitudeConnue[indexG] then begin
                G := grandeurs[indexG];
                for k := 0 to pred(pages[pageCourante].nmes) do
                    G.valeur[k] := randG(sauveValeur[indexG][k],G.ValIncert[k]);
             end;
         end;
         pages[pageCourante].recalculP; // MonteCarlo sur grandeurs calculées
         LanceModele(true);
         for j := 1 to NbreParam do
             statParam[j].donnees[i] := parametres[j].valCourante;
    end;
    for j := 0 to pred(NbreVariabExp) do begin
        indexG := indexVariabExp[j];
        for k := 0 to pred(pages[pageCourante].nmes) do
            grandeurs[indexG].valeur[k] := sauveValeur[indexG][k];
        sauveValeur[indexG] := nil;
    end;
    pages[pageCourante].recalculP; // les grandeurs calculées reprennent leur valeurs iniitiales
    memoResultat.Lines.Clear;
    memoResultat.Lines.Add('Méthode de Monte-Carlo');
    memoResultat.Lines.Add(intToStr(NbreMC)+' itérations');
    memoResultat.Lines.Add('u(x)=incertitude-type sur x');
    for j := 1 to NbreParam do begin
        statParam[j].calcul;
        memoResultat.Lines.add(parametres[j].nom+'='+parametres[j].formatValeurEtUnite(statParam[j].moyenne));
        memoResultat.Lines.add('u('+parametres[j].nom+')='+parametres[j].formatValeurEtUnite(statParam[j].sigma));
        pages[pageCourante].valeurParam[j] := statParam[j].moyenne;
        parametres[j].valCourante := statParam[j].moyenne;
        statParam[j].free;
    end;
    for m := 1 to NbreModele do with fonctionTheorique[m] do begin
        somme := 0;
        for k := pages[pageCourante].debut[m] to pages[pageCourante].fin[m] do begin
           AffecteVariableE(k);
           z := calcule(calcul);
           try
              dy := grandeurs[indexY].ValIncert[k];
              if isNan(dy) then dy := 0;
              dt := grandeurs[indexX].ValIncert[k];
              if isNan(dt)
                 then dt := 0
                 else dt := dt*graphe.valeurDeriveeX[m,k];
              coeffChi2 := 1/(sqr(dy)+sqr(dt));
           except
              coeffChi2 := 1;
           end;
           z := sqr(z-grandeurs[indexY].valeur[k])*coeffChi2;
           somme := somme+z;
        end;
        somme := somme/NbrePointsModele;
        memoResultat.Lines.add('Chi2/(N-p)='+formatGeneral(somme,precisionMin))
    end;
    MonteCarloActif := false;
end;

end.
