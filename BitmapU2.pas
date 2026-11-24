unit BitmapU2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Actions, System.Math.vectors, System.UIConsts,
  System.IOUtils, System.iniFiles,

  FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Dialogs, FMX.Objects, FMX.Layouts,
  FMX.Platform, FMX.clipBoard, 
  FMX.StdCtrls, FMX.ActnList,
  FMX.Memo, FMX.ListBox,
  FMX.Graphics, FMX.Utils,
  FMX.Controls.Presentation, FMX.Edit, 
  FMX.EditBox, FMX.SpinBox, FMX.Colors,

  FMX.TMSFNCToolBar,
  FMX.TMSFNCBitmapContainer,
  FMX.TMSFNCTypes,
  FMX.TMSFNCUtils, FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomComponent,
  FMX.TMSFNCCustomControl,

  maths;

const
    maxVecteurVideo = 1024;

type
  TstyleDrag = (bsNone,bsMesure,bsOrigine,bsEchelleX,bsEchelleY);
  TarrayPoint = array[TstyleDrag] of TpointF;
  Techelle = (eLin,eLog,ePolaire);

  TBitmapForm = class(TForm)
    OpenDialog: TOpenDialog;
    TracePointsCB: TCheckBox;
    TraceEchCB: TCheckBox;
    ToolBar1: TTMSFNCToolBar;
    OpenBtn: TTMSFNCToolBarButton;
    MesureBtn: TTMSFNCToolBarButton;
    CouleurPointCB: TTMSFNCToolBarColorPicker;
    CouleurAxeCB: TTMSFNCToolBarColorPicker;
    RegressiBtn: TTMSFNCToolBarButton;
    EchelleBtn: TTMSFNCToolBarButton;
    UndoBtn: TTMSFNCToolBarButton;
    RazBtn: TTMSFNCToolBarButton;
    Separator1: TTMSFNCToolBarSeparator;
    Separator2: TTMSFNCToolBarSeparator;
    Separator3: TTMSFNCToolBarSeparator;
    PanelPreview: TPanel;
    ImgPreview: TImage;
    TimerMove: TTimer;
    BitmapContainer1: TTMSFNCBitmapContainer;
    HelpBtn: TTMSFNCToolBarButton;
    procedure OpenButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure MesureBtnClick(Sender: TObject);
    procedure RegressiBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RazBtnClick(Sender: TObject);
    procedure TraceEchCBChange(Sender: TObject);
    procedure TracePointsCBChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PanelPreviewResize(Sender: TObject);
    procedure EchelleEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure EchelleBtnClick(Sender: TObject);
    procedure UndoBtnClick(Sender: TObject);
    procedure ImgPreviewClick(Sender: TObject);
    procedure ImgPreviewTap(Sender: TObject; const Point: TPointF);
    procedure CouleurPointCBColorSelected(Sender: TObject;
      AColor: TTMSFNCGraphicsColor);
    procedure HelpBtnClick(Sender: TObject);
  private
    XY : array[0..MaxVecteurVideo] of TpointF;
    PointRepere : TarrayPoint;
    e_PointRepere : TarrayPoint;
    BorneSelect : TstyleDrag;
    NmesVideo : integer;
    mesureEnCours : boolean;
    nouveauPoint : boolean;
    largeur, hauteur : integer;  // bitmap
    LargeurAff,HauteurAff : integer; // Affichée
    pasZoom : single; // conversion xy(video) vers xy(écran)
    nomFichier : string;
    PenteX,PenteY : double;
    bitmapCourant : tBitmap;
    procedure Dessine;
    procedure EcranVersImage;
    procedure SetCurseur(Acursor : Tcursor);
    function AppartientImage(var X, Y: single) : boolean;
    Function GetBorne(x,y : single) : TstyleDrag;
    procedure setBorne(aBorne : TStyleDrag);
    procedure setBoutons;
    procedure ImageVersEcran;
    procedure effectuerZoom;
    procedure getValeur(i : integer;var valx,valy : double);
    procedure setEchelle;
  public
    echelleX,echelleY : Techelle;
    MaxiX,MaxiY : double;
    MiniX,MiniY : double;
    deltat : double;
    nomT,nomX,nomY : string;
    uniteT,uniteX,uniteY : string;
    signifT,signifX,signifY : string;
    avecT : boolean;
    orthonorme : boolean;
  end;

var
  BitmapForm: TBitmapForm;

implementation

{$R *.fmx}

uses math,
     regutil, compile, valeurs, graphker, grapheVariabU,
     regmain, echelleBitmapU, constreg;

procedure TBitmapForm.OpenButtonClick(Sender: TObject);

procedure RecupereData;
begin
       largeur := bitmapCourant.Width;
       hauteur := bitmapCourant.Height;
       PointRepere[bsOrigine] := pointF(Largeur/3,2*Hauteur/3);
       PointRepere[bsEchelleX] := pointF(2*Largeur/3,2*Hauteur/3);
       PointRepere[bsEchelleY] := pointF(Largeur/3,Hauteur/3);
       EffectuerZoom;
       Deltat := 1/25;
end;

begin
  if OpenDialog.Execute then begin
    NomFichier := OpenDialog.FileName;
    setCurseur(crDefault);
    NmesVideo := 0;
    pasZoom := 1;
    setBorne(bsNone);
    Caption := 'Lecture de '+extractFileName(NomFichier);
    bitmapCourant.LoadFromFile(NomFichier);
    RecupereData;
    dessine;
    setBoutons;
  end;
end;

procedure TBitmapForm.PanelPreviewResize(Sender: TObject);
begin
    effectuerZoom;
end;

procedure TBitmapForm.RazBtnClick(Sender: TObject);
begin
      if OKReg('Suppression des données',0) then begin
         NmesVideo := 0;
         dessine;
         setBoutons;
     end;
end;

procedure TBitmapForm.RegressiBtnClick(Sender: TObject);

function Ajoute(nom,unite,signif : string) : codeGrandeur;
var  v : codeGrandeur;
begin
      v :=indexNom(nom);
      if v=grandeurInconnue then begin
         v := ajouteExperimentale(Nom,variable);
         grandeurs[v].fonct.expression := signif;
         grandeurs[v].NomUnite := unite;
      end;
      result := v;
end;

var i : integer;
    indexX,indexY,indexT : integer;
    valx,valy : double;
begin // SauveData
       setEchelle;
       MesureEnCours := false;
       setCurseur(crDefault);
       if avecT then indexT := ajoute(nomT,uniteT,signifT) else indexT := 0;
       indexX := ajoute(nomX,uniteX,signifX);
       indexY := ajoute(nomY,uniteY,signifY);
       ajoutePage;
       pages[pageCourante].nmes := nmesVideo;
       for i := 0 to pred(nmesVideo) do begin
           if avecT then pages[pageCourante].valeurVar[indexT,i] := i*deltat;
           getValeur(i,valx,valy);
           pages[pageCourante].valeurVar[indexX,i] := valx;
           pages[pageCourante].valeurVar[indexY,i] := valY;
       end;
       graphe.coordonnee[1].nomX := nomX;
       graphe.coordonnee[1].nomY := nomY;
       if orthonorme then include(graphe.OptionGraphe,OgOrthonorme);
       graphe.configCharge := true;
       graphe.useDefaut := false;
       NomFichierData := '';
       ModeAcquisition := AcqCourbes;
       FRegressiMain.WMRegMaj(MajFichier);
       ModifFichier := true;
       FRegressiMain.windowTab.ActiveTab := FRegressiMain.grapheTab;
 //      FValeurs.feuillets.ActiveTab := Fvaleurs.VariabSheet;
       Close;
end; // SauveData

procedure TBitmapForm.FormActivate(Sender: TObject);
begin
    setBoutons;
end;

procedure TBitmapForm.FormClose(Sender: TObject; var Action: TCloseAction);
var Rini : TMemIniFile;
begin
     if pages[pageCourante].nmes=0 then FRegressiMain.FileNewSimulationItemClick(Sender);
     Rini := TMemIniFile.create(registreReg);
     Rini.WriteString('Bitmap','nomX',nomX);
     Rini.WriteString('Bitmap','nomY',nomY);
     Rini.WriteString('Bitmap','nomT',nomT);
     Rini.WriteString('Bitmap',stuniteIni+'X',uniteX);
     Rini.writeString('Bitmap',stuniteIni+'Y',uniteY);
     Rini.writeString('Bitmap',stuniteIni+'T',uniteT);
     Rini.WriteBool('Bitmap','polaire',echelleX=ePolaire);
     Rini.writeBool('Bitmap','avecT',avecT);
     Rini.writeBool('Bitmap','logX',echelleX=eLog);
     Rini.writeBool('Bitmap','logY',echelleY=eLog);
     Rini.UpdateFile;
     Rini.free;
end;

procedure TBitmapForm.FormCreate(Sender: TObject);
var i : TStyleDrag;
    Rini : TMemIniFile;
begin
  LargeurAff := 640;
  HauteurAff := 480;
  Largeur := 640;
  Hauteur := 480;
  pasZoom := 1;
  bitmapCourant := tbitmap.Create;
  couleurPointCB.SelectedColor := claRed;
  couleurAxeCB.SelectedColor := claBlue;
  borneSelect := bsNone;
  for i := low(TstyleDrag) to High(TstyleDrag) do begin
           e_pointRepere[i].x := 0;
           e_pointRepere[i].y := 0;
  end;
  Rini := TMemIniFile.create(registreReg);
  nomX := Rini.ReadString('Bitmap','nomX','x');
  nomY := Rini.ReadString('Bitmap','nomY','y');
  nomT := Rini.ReadString('Bitmap','nomT','t');
  uniteX := Rini.ReadString('Bitmap',stuniteIni+'X','m');
  uniteY := Rini.ReadString('Bitmap',stuniteIni+'Y','m');
  uniteT := Rini.ReadString('Bitmap',stuniteIni+'T','s');
  if Rini.ReadBool('Bitmap','polaire',false) then begin
     echelleX := ePolaire;
     echelleY := ePolaire;
  end;
  avecT := Rini.readBool('Bitmap','avecT',true);
  if Rini.readBool('Bitmap','logX',false) then echelleX := eLog;
  if Rini.readBool('Bitmap','logY',false) then echelleY := eLog;
  miniX := 0;
  miniY := 0;
  maxiX := 1;
  maxiY := 1;
  Rini.free;
end;

procedure TBitmapForm.FormDestroy(Sender: TObject);
begin
    bitmapCourant.free;
end;

procedure TBitmapForm.setBorne(aBorne : TStyleDrag);
begin
     borneSelect := aBorne;
     case BorneSelect of
         bsOrigine,bsEchelleX,bsEchelleY : setCurseur(crSizeAll);
         bsMesure : setCurseur(crCross);
         else begin
            setCurseur(crDefault); // bsNone
         end;
     end;
end;

procedure TBitmapForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    if (Button<>TMouseButton.mbLeft) or not appartientImage(x,y) then exit;
    if borneSelect=bsNone then
       setBorne(GetBorne(x,y));
    e_pointRepere[BorneSelect].x := x;
    e_pointRepere[BorneSelect].y := y;
    nouveauPoint := true;
    ecranVersImage;
end;

procedure TBitmapForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);

var BS : TstyleDrag;
    redessin : boolean;
begin  // MouseMove
if not appartientImage(x,y) then begin
   setCurseur(crDefault);
   exit;
end;
Redessin := borneSelect in [bsOrigine,bsEchelleX,bsEchelleY];
e_pointRepere[BorneSelect].x := x;
e_pointRepere[BorneSelect].y := y;
case BorneSelect of
        bsOrigine : begin
           e_PointRepere[bsEchelleX].y := e_PointRepere[bsOrigine].y;
           e_PointRepere[bsEchelleY].x := e_PointRepere[bsOrigine].x;
        end;
        bsEchelleX : begin
           e_PointRepere[bsOrigine].y := e_PointRepere[bsEchelleX].y;
           if orthonorme then e_PointRepere[bsEchelleY].y :=
              e_PointRepere[bsOrigine].y-
              e_PointRepere[bsOrigine].Distance(e_PointRepere[bsEchelleX]);
        end;
        bsEchelleY : begin
           e_PointRepere[bsOrigine].x := e_PointRepere[bsEchelleY].x;
           if orthonorme then e_PointRepere[bsEchelleX].x :=
              e_PointRepere[bsOrigine].x+
              e_PointRepere[bsOrigine].Distance(e_PointRepere[bsEchelleY]);
        end;
     bsMesure : ;
     bsNone : begin
           BS := GetBorne(x,y);
           if BS in [bsEchelleX,bsEchelleY,bsOrigine]
              then setCurseur(crSizeAll)
              else setCurseur(crDefault);
     end;
end;
ecranVersImage;
if Redessin then dessine;
timerMove.Enabled := false;
end;

procedure TBitmapForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  orthonorme := (echelleX=eLin) and (echelleY=eLin) and orthonorme;
  if not appartientImage(x,y) then exit;
  e_pointRepere[BorneSelect].x := x;
  e_pointRepere[BorneSelect].y := y;
  case BorneSelect of
        bsOrigine : begin
           e_PointRepere[bsEchelleX].y := e_PointRepere[bsOrigine].y;
           e_PointRepere[bsEchelleY].x := e_PointRepere[bsOrigine].x;
        end;
        bsEchelleX : begin
           e_PointRepere[bsOrigine].y := e_PointRepere[bsEchelleX].y;
           if orthonorme then e_PointRepere[bsEchelleY].y :=
              e_PointRepere[bsOrigine].y-
              e_PointRepere[bsOrigine].Distance(e_PointRepere[bsEchelleX]);
        end;
        bsEchelleY : begin
           e_PointRepere[bsOrigine].x := e_PointRepere[bsEchelleY].x;
           if orthonorme then e_PointRepere[bsEchelleX].x :=
              e_PointRepere[bsOrigine].x+
              e_PointRepere[bsOrigine].Distance(e_PointRepere[bsEchelleY]);
        end;
  end; // case
  ecranVersImage;
  case BorneSelect of
     bsNone : ;
     bsEchelleX,bsEchelleY,bsOrigine : begin
         setBorne(bsNone);
         dessine;
     end;
     bsMesure : if nouveauPoint and (NmesVideo <= MaxVecteurVideo) then begin
         XY[NmesVideo] := pointRepere[bsMesure];
         inc(NmesVideo);
         nouveauPoint := false;
         UndoBtn.enabled := nmesVideo > 0;
         RegressiBtn.enabled := nmesVideo>2;
         dessine;
     end;
  end;
end;

procedure TBitmapForm.TraceEchCBChange(Sender: TObject);
begin
    dessine;
end;

procedure TBitmapForm.TracePointsCBChange(Sender: TObject);
begin
    dessine;
end;

procedure TBitmapForm.UndoBtnClick(Sender: TObject);
begin
     if NmesVideo>0 then dec(nmesVideo);
     UndoBtn.enabled := nmesVideo>0;
     dessine;
end;

procedure TBitmapForm.ImageVersEcran;
var i : TstyleDrag;
begin
       for i := low(TstyleDrag) to High(TstyleDrag) do
           e_pointRepere[i] := pointRepere[i]*pasZoom;
end;

procedure TBitmapForm.ImgPreviewClick(Sender: TObject);
begin
  case BorneSelect of
     bsNone : ;
     bsEchelleX,bsEchelleY,bsOrigine : begin
         setBorne(bsNone);
         dessine;
     end;
     bsMesure : if nouveauPoint and (NmesVideo <= MaxVecteurVideo) then begin
         XY[NmesVideo] := pointRepere[bsMesure];
         inc(NmesVideo);
         nouveauPoint := false;
         UndoBtn.enabled := nmesVideo > 0;
         RegressiBtn.enabled := nmesVideo>2;
         dessine;
     end;
  end;
end;

procedure TBitmapForm.ImgPreviewTap(Sender: TObject; const Point: TPointF);
begin
   e_pointRepere[BorneSelect].x := Point.x;
   e_pointRepere[BorneSelect].y := Point.y;
   ecranVersImage;
   case BorneSelect of
      bsNone : ;
      bsEchelleX,bsEchelleY,bsOrigine : begin
         setBorne(bsNone);
         dessine;
      end;
      bsMesure : if nouveauPoint and (NmesVideo <= MaxVecteurVideo) then begin
         XY[NmesVideo] := pointRepere[bsMesure];
         inc(NmesVideo);
         nouveauPoint := false;
         UndoBtn.enabled := nmesVideo > 0;
         RegressiBtn.enabled := nmesVideo>2;
         dessine;
      end;
   end;
end;

procedure TBitmapForm.EchelleEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if not CharInSet(keyChar,['0'..'9','.',',','m',
                     crSupprArr,crCR,crTab,crGauche,crDroite]) then keyChar := #0
end;

procedure TBitmapForm.EcranVersImage;
var i : TstyleDrag;
begin
       for i := low(TstyleDrag) to High(TstyleDrag) do
           pointRepere[i] := e_pointRepere[i]/pasZoom;
end;

procedure TBitmapForm.CouleurPointCBColorSelected(Sender: TObject;
  AColor: TTMSFNCGraphicsColor);
begin
    dessine;
end;

procedure TBitmapForm.SetCurseur(Acursor : Tcursor);
begin
      imgPreview.Cursor := aCursor;
end;

function TBitmapForm.AppartientImage(var X, Y: single) : boolean;
begin
    result := (x>0) and (y>0) and (y<hauteurAff) and (x<largeurAff)
end;

Function TBitmapForm.GetBorne(x,y : single) : TstyleDrag;
const
    Magnet = 16;
var i : TstyleDrag;
    aPoint : TPointF;
begin
      result := bsNone;
      aPoint := PointF(x,y);
      for i in [bsOrigine,bsEchelleX,bsEchelleY] do
          if e_PointRepere[i].distance(aPoint) < Magnet
              then begin
                 result := i;
                 exit;
              end;
end;

procedure TBitmapForm.EffectuerZoom;
var zoomX,zoomY,zoom : single;
begin
    if (nomFichier='') then exit;
    zoomX := panelPreview.width / largeur;
    zoomY := panelPreview.height / hauteur;
    if zoomX>zoomY then zoom := zoomY else zoom := zoomX;
    if zoom>1 then pasZoom := floor(zoom) else pasZoom := zoom;
    //ZoomLabel.text := 'x'+FloatToStr(pasZoom);
    hauteurAff := round(hauteur*pasZoom);
    largeurAff := round(largeur*pasZoom);
    ImgPreview.Height := hauteurAff;
    ImgPreview.Width := largeurAff;
    imageVersEcran;
end;

procedure TBitmapForm.MesureBtnClick(Sender: TObject);
begin
  mesureEnCours := not mesureEnCours;
  if MesureEnCours
  then begin
     setBorne(bsMesure);
     NmesVideo := 0;
     MesureBtn.text := 'STOP';
  end
  else begin
     setBorne(bsNone);
     MesureBtn.text := 'Mesurer';
  end;
  setBoutons;
end;

procedure TBitmapForm.EchelleBtnClick(Sender: TObject);
begin
    if EchelleBitmapDlg=nil then application.createForm(TEchelleBitmapDlg,EchelleBitmapDlg);
    if EchelleBitmapDlg.showModal=mrOK then begin
       setEchelle;
       BorneSelect := bsNone;
       setCurseur(crDefault);
    end;
end;

procedure TBitmapForm.Dessine;
const tailleCroix = 3;
var imageCanvas : TCanvas;

Procedure TraceCroix(Apoint : TpointF);
var point1,point2 : TPointF;
begin
       point1 := Apoint;
       point2 := Apoint;
       point1.Offset(-tailleCroix,0);
       point2.Offset(+tailleCroix,0);
       imageCanvas.drawLine(point1,point2,1);
       point1 := Apoint;
       point2 := Apoint;
       point1.offset(0,-tailleCroix);
       point2.offset(0,+tailleCroix);
       imageCanvas.drawLine(point1,point2,1);
end;

Procedure TraceOrigine;
var rayon : single;

procedure TraceFleche(aBorne : TStyleDrag);
    var
      PC: TPointF; // centre de la base de la flèche
      deltaX, deltaY: single;
      Points:  TPolygon; // Flèche
      PE : TPointF; // extrémité de l'axe
    begin
       imageCanvas.drawLine(PointRepere[bsOrigine],PointRepere[aborne],1);
       PC := PointRepere[aborne];
       PE := PointRepere[aborne];  // extrémité flèche
       if aBorne=bsEchelleX then begin
          deltaX := -rayon;
          deltaY := 0;
       end
       else begin
          deltaY := rayon;
          deltaX := 0;
       end;
       PC.Offset(deltaX,deltaY);// base de la flèche
       if aBorne=bsEchelleX then begin
          deltaY := deltaX/3;
          deltaX := 0;
       end
       else begin
          deltaX := deltaY/3;
          deltay := 0;
       end;
       setLength(Points,3);
       Points[0] := PE;
       PC.offset(deltaX,deltaY);
       Points[1] := PC;
       PC.offset(-2*deltaX,-2*deltaY);
       Points[2] := PC;
       imageCanvas.DrawPolygon(Points,1);
    end;

begin // traceOrigine
         imageCanvas.stroke.color := couleurAxeCB.SelectedColor;
         rayon := min(largeur,hauteur)/25;
         TraceFleche(bsEchelleX);
         TraceFleche(bsEchelleY);
end;

var i : integer;
begin // Dessine
    if (nomFichier='') then exit;
    ImgPreview.Bitmap.Assign(bitmapCourant);
    imageCanvas := ImgPreview.bitmap.Canvas;
    ImageCanvas.BeginScene;
    imageCanvas.stroke.kind := TBrushKind.solid;
    imageCanvas.stroke.thickness := ceil(1/pasZoom);
    couleurAxeCB.Visible := traceEchCB.isChecked;
    if traceEchCB.isChecked then TraceOrigine;
    couleurPointCB.Visible := tracePointsCB.isChecked;
    if tracePointsCB.isChecked then begin
       imageCanvas.stroke.color := couleurPointCB.SelectedColor;
       for i := 0 to nmesVideo-1 do
           TraceCroix(XY[i]);
    end; // tracePoints
    ImageCanvas.EndScene;
end; // Dessine

procedure TBitmapForm.setBoutons;
var OK : boolean;
begin
    OK := (nomFichier<>'');
    RegressiBtn.enabled := nmesVideo>2;
    MesureBtn.enabled := OK;
    RazBtn.enabled := OK and not MesureEnCours and (nmesVideo>2);
    if MesureEnCours
       then mesureBtn.text := 'Stop'
       else mesureBtn.text := 'Mesurer';
    if (borneSelect=bsNone) then begin
       setCurseur(crDefault);
    end;
end; // setBoutons

Procedure TBitmapForm.SetEchelle;
var PixelX,PixelY : single;
begin
       if PointRepere[bsEchelleY].y<0 then
            PointRepere[bsEchelleY].y := 0;
       if PointRepere[bsEchelleY].y>hauteur then
            PointRepere[bsEchelleY].y := hauteur;
       if PointRepere[bsEchelleX].x>largeur then
            PointRepere[bsEchelleX].x := largeur;
       if PointRepere[bsEchelleX].x<0 then
            PointRepere[bsEchelleX].x := 0;
       PixelX := PointRepere[bsEchelleX].distance(PointRepere[bsOrigine]);
       PixelY := PointRepere[bsEchelleY].distance(PointRepere[bsOrigine]);
       if PixelX>0 then begin
          if echelleX=eLog
               then  penteX := log10(MaxiX/MiniX)/PixelX
               else  penteX := (MaxiX-MiniX)/PixelX;
       end
       else penteX := 1;
       if PixelY>0 then begin
          if echelleY=eLog
               then penteY := log10(MaxiY/MiniY)/PixelY
               else penteY := (MaxiY-MiniY)/PixelY;
       end
       else penteY := 1;
       if orthonorme then penteX := penteY;
end;


procedure TBitmapForm.getValeur(i : integer;var valx,valy : double);
var rx, ry : double;
begin
    if i>=NmesVideo then begin
    valx := 0;
    valy := 0;
    end
    else begin
    rx := penteX*(xy[i].x-pointRepere[bsOrigine].x);
    ry := -penteY*(xy[i].y-pointRepere[bsOrigine].y);
    valx := rx;
    valy := ry;
    case echelleX of
       eLog : valx := MiniX*power(10,rx);
       eLin : valx := MiniX+rx;
       ePolaire : begin
            valx := arcTan2(ry,rx);
            if uniteX='°' then valx := radToDeg(valx);
       end;
    end;
     case echelleY of
       eLog : valy := MiniY*power(10,ry);
       eLin : valy := MiniY+ry;
       ePolaire : valy := sqrt(sqr(rx)+sqr(ry));
    end;
    end;
end;

procedure TBitmapForm.HelpBtnClick(Sender: TObject);
begin
    openHelp('Numerisationdunecourbe')
end;

end.

