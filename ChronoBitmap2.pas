unit ChronoBitmap2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,  System.Actions, System.Math.vectors, System.UIConsts,
  System.IOUtils, System.iniFiles,

  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Objects, FMX.Layouts,
  FMX.Platform, FMX.clipBoard, FMX.StdCtrls, FMX.ActnList,
  FMX.Memo, FMX.ListBox, FMX.Graphics, FMX.Utils,
  FMX.Controls.Presentation, FMX.Edit, 
  FMX.EditBox, FMX.SpinBox, FMX.Colors,

  FMX.TMSFNCToolBar, 
  FMX.TMSFNCBitmapContainer,
  FMX.TMSFNCTypes, FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomComponent,
  FMX.TMSFNCCustomControl,

  images, maths;

const
    maxVecteurVideo = 1024;

type
  TstyleDrag = (bsNone,bsMesure,bsOrigine,bsEchelleX,bsEchelleY);
  TarrayPoint = array[TstyleDrag] of TpointF;

  TChronoBitmapForm = class(TForm)
    OpenDialog: TOpenDialog;
    TracePointsCB: TCheckBox;
    TraceEchCB: TCheckBox;
    ToolBar1: TTMSFNCToolBar;
    OpenBtn: TTMSFNCToolBarButton;
    MesureBtn: TTMSFNCToolBarButton;
    CouleurPointCB: TTMSFNCToolBarColorPicker;
    CouleurAxeCB: TTMSFNCToolBarColorPicker;
    RegressiBtn: TTMSFNCToolBarButton;
    UndoBtn: TTMSFNCToolBarButton;
    RazBtn: TTMSFNCToolBarButton;
    Separator1: TTMSFNCToolBarSeparator;
    Separator2: TTMSFNCToolBarSeparator;
    Separator3: TTMSFNCToolBarSeparator;
    PanelPreview: TPanel;
    ImgPreview: TImage;
    BitmapContainer1: TTMSFNCBitmapContainer;
    EchelleLabel: TLabel;
    EchelleEdit: TEdit;
    Label2: TLabel;
    DeltatEdit: TEdit;
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
    procedure CouleurPointCBColorSelected(Sender: TObject;
      AColor: TTMSFNCGraphicsColor);
    procedure CouleurAxeCBColorSelected(Sender: TObject; AColor: TTMSFNCGraphicsColor);
    procedure RazBtnClick(Sender: TObject);
    procedure TraceEchCBChange(Sender: TObject);
    procedure TracePointsCBChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PanelPreviewResize(Sender: TObject);
    procedure EchelleEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure UndoBtnClick(Sender: TObject);
    procedure ImgPreviewClick(Sender: TObject);
    procedure ImgPreviewTap(Sender: TObject; const Point: TPointF);
    procedure HelpBtnClick(Sender: TObject);
  private
    XY : array[0..MaxVecteurVideo] of TpointF;
    signeY : integer;
    PointRepere : TarrayPoint;
    e_PointRepere : TarrayPoint;
    BorneSelect : TstyleDrag;
    NmesVideo : integer;
    mesureEnCours : boolean;
    largeur, hauteur : integer;  // bitmap
    LargeurAff,HauteurAff : integer; // Affichée
    pasZoom : single; // conversion xy(video) vers xy(écran)
    nomFichier : string;
    Pente : double;
    deltat : double;
    bitmapCourant : tBitmap;
    nouveauPoint : boolean;
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
  end;

var
  ChronoBitmapForm: TChronoBitmapForm;

implementation

{$R *.fmx}

uses math,
    regutil, compile, valeurs, graphker,
    grapheVariabU, regmain;

procedure TChronoBitmapForm.OpenButtonClick(Sender: TObject);

procedure RecupereData;
begin
       largeur := bitmapCourant.Width;
       hauteur := bitmapCourant.Height;
       PointRepere[bsOrigine] := pointF(Largeur/3,2*Hauteur/3);
       PointRepere[bsEchelleX] := pointF(Largeur/4,3*Hauteur/4);
       PointRepere[bsEchelleY] := pointF(3*Largeur/4,3*Hauteur/4);
       EffectuerZoom;
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

procedure TChronoBitmapForm.PanelPreviewResize(Sender: TObject);
begin
    effectuerZoom;
end;

procedure TChronoBitmapForm.RazBtnClick(Sender: TObject);
begin
      if OKReg('Suppression des données',0) then begin
         NmesVideo := 0;
         dessine;
         setBoutons;
     end;
end;

procedure TChronoBitmapForm.RegressiBtnClick(Sender: TObject);

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
       indexT := ajoute('t','s','temps');
       indexX := ajoute('x','m','abscisse');
       indexY := ajoute('y','m','ordonnée');
       ajoutePage;
       pages[pageCourante].nmes := nmesVideo;
       for i := 0 to pred(nmesVideo) do begin
           pages[pageCourante].valeurVar[indexT,i] := i*deltat;
           getValeur(i,valx,valy);
           pages[pageCourante].valeurVar[indexX,i] := valx;
           pages[pageCourante].valeurVar[indexY,i] := valY;
       end;
       graphe.coordonnee[1].nomX := 'x';
       graphe.coordonnee[1].nomY := 'y';
       include(graphe.OptionGraphe,OgOrthonorme);
       graphe.configCharge := true;
       graphe.useDefaut := false;
       NomFichierData := '';
       ModeAcquisition := AcqCourbes;
       FRegressiMain.WMRegMaj(MajFichier);
       ModifFichier := true;
       FRegressiMain.windowTab.ActiveTab := FRegressiMain.grapheTab;
//       FValeurs.feuillets.ActiveTab := Fvaleurs.VariabSheet;
       Close;
end; // SauveData

procedure TChronoBitmapForm.FormActivate(Sender: TObject);
begin
    setBoutons;
end;

procedure TChronoBitmapForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     if pages[pageCourante].nmes=0 then FRegressiMain.FileNewSimulationItemClick(Sender);
end;

procedure TChronoBitmapForm.FormCreate(Sender: TObject);
var i : TStyleDrag;
begin
  LargeurAff := 640;
  HauteurAff := 480;
  Largeur := 640;
  Hauteur := 480;
  pasZoom := 1;
  signeY := -1;
  bitmapCourant := tbitmap.Create;
  couleurPointCB.SelectedColor := claRed;
  couleurAxeCB.SelectedColor := claBlue;
  borneSelect := bsNone;
  for i := low(TstyleDrag) to High(TstyleDrag) do begin
        e_pointRepere[i].x := 0;
        e_pointRepere[i].y := 0;
  end;
end;

procedure TChronoBitmapForm.FormDestroy(Sender: TObject);
begin
    bitmapCourant.free;
end;

procedure TChronoBitmapForm.setBorne(aBorne : TStyleDrag);
begin
     borneSelect := aBorne;
     case BorneSelect of
         bsOrigine,bsEchelleX,bsEchelleY :  setCurseur(crSizeAll);
         bsMesure : setCurseur(crCross);
         else begin
            setCurseur(crDefault); // bsNone
         end;
     end;
end;

procedure TChronoBitmapForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    if (Button<>TMouseButton.mbLeft) or not appartientImage(x,y) then exit;
    if borneSelect=bsNone then
       setBorne(GetBorne(x,y));
    e_pointRepere[BorneSelect].x := x;
    e_pointRepere[BorneSelect].y := y;
    ecranVersImage;
    nouveauPoint := true;
end;

procedure TChronoBitmapForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
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
     bsOrigine, bsEchelleX, bsEchelleY : ;
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
end;

procedure TChronoBitmapForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if not appartientImage(x,y) then exit;
  e_pointRepere[BorneSelect].x := x;
  e_pointRepere[BorneSelect].y := y;
  ecranVersImage;
  case BorneSelect of
     bsNone : ;
     bsEchelleX,bsEchelleY,bsOrigine : begin
         setBorne(bsNone);
         dessine;
     end;
     bsMesure : if nouveauPoint then begin
         XY[NmesVideo] := pointRepere[bsMesure];
         inc(NmesVideo);
         RegressiBtn.enabled := nmesVideo>2;
         dessine;
         nouveauPoint := false;
     end;
  end;
end;

procedure TChronoBitmapForm.TraceEchCBChange(Sender: TObject);
begin
    dessine;
end;

procedure TChronoBitmapForm.TracePointsCBChange(Sender: TObject);
begin
    dessine;
end;

procedure TChronoBitmapForm.UndoBtnClick(Sender: TObject);
begin
     if NmesVideo>0 then dec(nmesVideo);
     UndoBtn.enabled := nmesVideo>0;
     dessine;
end;

procedure TChronoBitmapForm.ImageVersEcran;
var i : TstyleDrag;
begin
       for i := low(TstyleDrag) to High(TstyleDrag) do
           e_pointRepere[i] := pointRepere[i]*pasZoom;
end;

procedure TChronoBitmapForm.ImgPreviewClick(Sender: TObject);
begin
  case BorneSelect of
     bsNone : ;
     bsEchelleX,bsEchelleY,bsOrigine : begin
         setBorne(bsNone);
         dessine;
     end;
     bsMesure : if nouveauPoint then begin
         XY[NmesVideo] := pointRepere[bsMesure];
         inc(NmesVideo);
         RegressiBtn.enabled := nmesVideo>2;
         dessine;
         nouveauPoint := false;
     end;
  end;
end;

procedure TChronoBitmapForm.ImgPreviewTap(Sender: TObject;
  const Point: TPointF);
var XX,YY : single;
begin
  xx := Point.x;
  yy := Point.y;
  if not appartientImage(xx,yy) then exit;
  e_pointRepere[BorneSelect].x := xx;
  e_pointRepere[BorneSelect].y := yy;
  ecranVersImage;
  case BorneSelect of
     bsNone : ;
     bsEchelleX,bsEchelleY,bsOrigine : begin
         setBorne(bsNone);
         dessine;
     end;
     bsMesure : if nouveauPoint then begin
         XY[NmesVideo] := pointRepere[bsMesure];
         inc(NmesVideo);
         RegressiBtn.enabled := nmesVideo>2;
         dessine;
         nouveauPoint := false;
     end;
  end;
end;

procedure TChronoBitmapForm.EchelleEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if not CharInSet(keyChar,['0'..'9','.',',',
                     crSupprArr,crCR,crTab,crGauche,crDroite]) then keyChar := #0
end;

procedure TChronoBitmapForm.EcranVersImage;
var i : TstyleDrag;
begin
       for i := low(TstyleDrag) to High(TstyleDrag) do
           pointRepere[i] := e_pointRepere[i]/pasZoom;
end;

procedure TChronoBitmapForm.CouleurAxeCBColorSelected(Sender: TObject;
  AColor: TTMSFNCGraphicsColor);
begin
  dessine;
end;

procedure TChronoBitmapForm.CouleurPointCBColorSelected(Sender: TObject;
  AColor: TTMSFNCGraphicsColor);
begin
  dessine;
end;

procedure TChronoBitmapForm.SetCurseur(Acursor : Tcursor);
begin
      imgPreview.Cursor := aCursor;
end;

function TChronoBitmapForm.AppartientImage(var X, Y: single) : boolean;
begin
    result := (x>0) and (y>0) and (y<hauteurAff) and (x<largeurAff)
end;

Function TChronoBitmapForm.GetBorne(x,y : single) : TstyleDrag;
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

procedure TChronoBitmapForm.EffectuerZoom;
var zoomX,zoomY,zoom : single;
begin
    if (nomFichier='') then exit;
    zoomX := panelPreview.width / largeur;
    zoomY := panelPreview.height / hauteur;
    if zoomX>zoomY then zoom := zoomY else zoom := zoomX;
    if zoom>1 then pasZoom := floor(zoom) else pasZoom := zoom;
    hauteurAff := round(hauteur*pasZoom);
    largeurAff := round(largeur*pasZoom);
    ImgPreview.Height := hauteurAff;
    ImgPreview.Width := largeurAff;
    imageVersEcran;
end;

procedure TChronoBitmapForm.MesureBtnClick(Sender: TObject);
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

procedure TChronoBitmapForm.Dessine;
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

procedure TraceFleche(dX,dY : single);
    var
      PC: TPointF; // centre de la base de la flèche
      deltaX, deltaY: single;
      Points:  TPolygon; // Flèche
      PE : TPointF; // extrémité de l'axe
      rayon : single;
    begin
       rayon := min(largeur,hauteur)/3;
       PE := PointRepere[bsOrigine];
       deltaX := rayon*dX;
       deltaY := rayon*dY;
       PE.offset(deltaX,deltaY);
       imageCanvas.drawLine(PointRepere[bsOrigine],PE,1);
       rayon := rayon/10;
       PC := PE;
       deltaX := rayon*dX;
       deltaY := rayon*dY;
       PC.Offset(-deltaX,-deltaY);
       deltaX := deltaX/3;
       deltaY := deltaY/3;
       setLength(Points,3);
       Points[0] := PE;
       PC.offset(-deltaY,+deltaX);
       Points[1] := PC;
       PC.offset(+2*deltaY,-2*deltaX);
       Points[2] := PC;
       imageCanvas.DrawPolygon(Points,1);
    end;

begin // traceOrigine
         imageCanvas.stroke.color := couleurAxeCB.SelectedColor;
         TraceFleche(0,signeY);
         TraceFleche(1,0);
         imageCanvas.drawLine(PointRepere[bsEchelleX],PointRepere[bsechelleY],1);
         TraceCroix(PointRepere[bsEchelleX]);
         TraceCroix(PointRepere[bsechelleY]);
end; // traceOrigine

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

procedure TChronoBitmapForm.setBoutons;
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

Procedure TChronoBitmapForm.SetEchelle;
var EchelleEnPixel : single;
    longueurEchelle : single;
begin
       if PointRepere[bsEchelleY].y<0 then
            PointRepere[bsEchelleY].y := 0;
       if PointRepere[bsEchelleY].y>hauteur then
            PointRepere[bsEchelleY].y := hauteur;
       if PointRepere[bsEchelleX].x>largeur then
            PointRepere[bsEchelleX].x := largeur;
       if PointRepere[bsEchelleX].x<0 then
            PointRepere[bsEchelleX].x := 0;
        echelleEnPixel := PointRepere[bsEchelleX].distance(PointRepere[bsechelleY]);
        try
           LongueurEchelle := StrToFloatWin(EchelleEdit.text);
        except
           showMessage('Erreur lors de la lecture de l''échelle');
           EchelleEdit.text := '1.0';
           EchelleEdit.SetFocus;
           longueurEchelle := 1;
        end;
        try
           deltat := StrToFloatWin(DeltatEdit.text);
        except
           showMessage('Erreur lors de la lecture de l''échelle');
           DeltatEdit.text := '0.04';
           DeltatEdit.SetFocus;
           deltat := 0.04; // 25 images / s
        end;
        pente := LongueurEchelle/EchelleEnPixel;
end;

procedure TChronoBitmapForm.getValeur(i : integer;var valx,valy : double);
begin
    if i>=NmesVideo then begin
    valx := 0;
    valy := 0;
    end
    else begin
    valx := pente*(xy[i].x-pointRepere[bsOrigine].x);
    valy := signeY*pente*(xy[i].y-pointRepere[bsOrigine].y);
    end;
end;

procedure TChronoBitmapForm.HelpBtnClick(Sender: TObject);
begin
    openHelp('Chronophotographie')
end;

end.

