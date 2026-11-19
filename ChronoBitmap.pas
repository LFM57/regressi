unit ChronoBitmap;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Actions, System.Math.vectors, System.UIConsts, System.IOUtils, System.iniFiles,
  
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Objects, FMX.Layouts,
  FMX.Platform, FMX.clipBoard, FMX.StdCtrls, FMX.ActnList,
  FMX.Memo, FMX.ListBox, FMX.Graphics, FMX.Utils,
  FMX.Controls.Presentation, 
  FMX.Edit, FMX.EditBox, FMX.SpinBox, FMX.Colors,
  
  avProbe,
  
  FMX.TMSToolBar,
  FMX.TMSBitmapContainer,
  
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
    TMSFMXToolBar1: TTMSFMXToolBar;
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
    Label1: TLabel;
    LoupeSB: TSpinBox;
    TMSFMXBitmapContainer1: TTMSFNCBitmapContainer;
    EchelleLabel: TLabel;
    EchelleEdit: TEdit;
    Label2: TLabel;
    DeltatEdit: TEdit;
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
      AColor: TAlphaColor);
    procedure CouleurAxeCBColorSelected(Sender: TObject; AColor: TAlphaColor);
    procedure RazBtnClick(Sender: TObject);
    procedure TraceEchCBChange(Sender: TObject);
    procedure TracePointsCBChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PanelPreviewResize(Sender: TObject);
    procedure EchelleEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure LoupeSBChange(Sender: TObject);
  //  procedure TimerMoveTimer(Sender: TObject);
    procedure UndoBtnClick(Sender: TObject);
    procedure ImgPreviewClick(Sender: TObject);
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
    couleurPoint : TAlphaColor;
    couleurAxe : TAlphaColor;
    nomFichier : string;
    gainLoupe : integer;
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
    procedure CacheLoupe;
    procedure ConvertitXY(Sender: TObject;var X, Y: single);
    Function ImageClientToScreen : TpointF;
    procedure getValeur(i : integer;var valx,valy : double);
    procedure setEchelle;
  public
  end;

var
  ChronoBitmapForm: TChronoBitmapForm;

implementation

{$R *.fmx}

uses math, avcodec, avlib, loupeU,
     regutil, compile, valeurs, graphker, grapheVariabU, regmain;

procedure SetPixel(abitmap : tbitmap;i,j : integer;acolor : TAlphaColor);
 // example of setting a single pixel in a Tbitmap.
var
  vBitMapData  : TBitmapData;
begin
 // lock and get the bitmap pixels
      if aBitmap.Map(TMapAccess.Write, vBitMapData) then begin
          vBitmapData.SetPixel(i,j, aColor); // set the pixel colour at i, j
          aBitmap.Unmap(vBitMapData);         // unlock the bitmap
      end;
end;

function GetPixel(abitmap : tbitmap;i,j : integer) : TAlphaColor;
 // example of setting a single pixel in a Tbitmap.
var
  vBitMapData  : TBitmapData;
begin
 // lock and get the bitmap pixels
      if aBitmap.Map(TMapAccess.Read, vBitMapData) then begin
          result := vBitmapData.GetPixel(i,j); // set the pixel colour at i, j
          aBitmap.Unmap(vBitMapData);         // unlock the bitmap
      end
      else result := claWhite
end;

Function TChronoBitmapForm.ImageClientToScreen : TpointF;
var aPoint : TPointF;
begin
    aPoint := PointF(0,0); // Origine imgPreview
    {$IFDEF MACOS}
    aPoint.Offset(panelPreview.position.x,panelPreview.position.y); // Origine / fenêtre client
    {$ELSE}
    aPoint.Offset(panelPreview.position.x,panelPreview.position.y); // Origine / fenêtre client
    {$ENDIF}
    aPoint := clientToScreen(aPoint); // Origine / écran
    result := aPoint;
end;

procedure TChronoBitmapForm.ConvertitXY(Sender: TObject;var X, Y: single);
var PointImage : TPointF;
begin
    if sender=LoupeForm.image then begin
       PointImage := ImageClientToScreen;
       x := x+LoupeForm.left-PointImage.X;
       y := y+LoupeForm.top-PointImage.Y;
    end;
    if sender=self then begin
       x := x-panelPreview.Position.x;
       y := y-panelPreview.Position.y;
    end;
end;

procedure TChronoBitmapForm.CacheLoupe;
begin
     if loupeForm.visible then loupeForm.hide;
     FRegressiMain.timerLoupe.enabled := false;
end;

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
    cacheLoupe;
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
       cacheLoupe;
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
       ModeAcquisition := AcqBitmap;
       ModifFichier := true;
       FRegressiMain.WMRegMaj(MajFichier);
       FRegressiMain.windowTab.ActiveTab := FRegressiMain.grapheTab;
       FValeurs.feuillets.ActiveTab := Fvaleurs.VariabSheet;
       Close;
end; // SauveData

procedure TChronoBitmapForm.FormActivate(Sender: TObject);
begin
    setBoutons;
end;

procedure TChronoBitmapForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
     if pages[pageCourante].nmes=0 then FRegressiMain.FileNewSimulationItemClick(Sender);
     cacheLoupe;
end;

procedure TChronoBitmapForm.FormCreate(Sender: TObject);

procedure CreerLoupe;
begin
    if LoupeForm=nil then
       Application.CreateForm(TLoupeForm, LoupeForm);
    LoupeForm.aForm := chronoBitmapForm;
    gainLoupe := 1;
    LoupeSB.Value := 1;
    LoupeForm.image.onMouseMove := FormMouseMove;
    LoupeForm.image.onClick := ImgPreviewClick;
    LoupeForm.image.onMouseUp := FormMouseUp;
    LoupeForm.image.onMouseDown := FormMouseDown;
    LoupeForm.onMouseUp := FormMouseUp;
    LoupeForm.onMouseDown := FormMouseDown;
    LoupeForm.Hide;
end;

var i : TStyleDrag;
begin
  LargeurAff := 640;
  HauteurAff := 480;
  Largeur := 640;
  Hauteur := 480;
  pasZoom := 1;
  signeY := -1;
  bitmapCourant := tbitmap.Create;
  couleurPoint := claRed;
  couleurPointCB.SelectedColor := claRed;
  couleurAxe := claBlue;
  couleurAxeCB.SelectedColor := couleurAxe;
  borneSelect := bsNone;
  for i := low(TstyleDrag) to High(TstyleDrag) do begin
        e_pointRepere[i].x := 0;
        e_pointRepere[i].y := 0;
  end;
  creerLoupe;
end;

procedure TChronoBitmapForm.FormDestroy(Sender: TObject);
begin
    if LoupeForm<>nil then begin
        LoupeForm.close;
        LoupeForm.free;
        LoupeForm := nil;
    end;
    bitmapCourant.free;
end;

procedure TChronoBitmapForm.setBorne(aBorne : TStyleDrag);
begin
     borneSelect := aBorne;
     if BorneSelect in [bsOrigine,bsEchelleX,bsEchelleY,bsMesure]
         then setCurseur(crNone)
         else begin
            setCurseur(crDefault); // bsNone
            cacheLoupe;
         end;
     FRegressiMain.timerLoupe.enabled := BorneSelect in [bsMesure,bsEchelleX,bsEchelleY,bsOrigine];
end;

procedure TChronoBitmapForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    convertitXY(sender,x,y);
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

procedure Loupe;
var LoupeSize : integer;
    demiHauteur : integer;
    demiHauteurLoupe : integer;

procedure reperage;
var ecart : integer;
    Fpath : TPathData;
begin
    ecart := LoupeSize div 3;
    FPath := TPathData.Create;
    LoupeForm.bitmapLoupe.canvas.stroke.thickness := 1;
    LoupeForm.bitmapLoupe.canvas.stroke.color := couleurAxeCB.selectedColor;
    LoupeForm.bitmapLoupe.canvas.stroke.dash :=  TStrokeDash.Solid;

    FPath.moveto(TPointF.Create(0,demiHauteurLoupe));
    FPath.lineto(TPointF.Create(ecart,demiHauteurLoupe));
    FPath.moveto(TPointF.Create(2*ecart,demiHauteurLoupe));
    FPath.lineto(TPointF.Create(LoupeSize,demiHauteurLoupe));

    FPath.moveto(TPointF.Create(demiHauteurLoupe,0));
    FPath.lineto(TPointF.Create(demiHauteurLoupe,ecart));
    FPath.moveto(TPointF.Create(demiHauteurLoupe,2*ecart));
    FPath.lineto(TPointF.Create(demiHauteurLoupe,LoupeSize));

    FPath.moveto(TPointF.Create(demiHauteurLoupe,demiHauteurLoupe-2));
    FPath.lineto(TPointF.Create(demiHauteurLoupe,demiHauteurLoupe+2));
    FPath.moveto(TPointF.Create(demiHauteurLoupe-2,demiHauteurLoupe));
    FPath.lineto(TPointF.Create(demiHauteurLoupe+2,demiHauteurLoupe));
    LoupeForm.bitmapLoupe.Canvas.DrawPath(FPath, 1);
    FPath.Free;
end;

var
   X1,Y1,X2,Y2 : single;
   decaleX,decaleY,margeX,margeY : integer;
   aPoint : TPointF;
   SourceRect,DestRect : TrectF;
begin  // loupe
   LoupeSize := LoupeForm.Width;
   demiHauteurLoupe := LoupeSize div 2;
   demiHauteur := demiHauteurLoupe div gainLoupe;
   X1 := X-demiHauteur;
   Y1 := Y-demiHauteur;
   X2 := X+demiHauteur;
   Y2 := Y+demiHauteur;
   if Y1<0 then begin
      decaleY := -round(Y1*gainLoupe);
      Y1 := 0;
      margeY := 0;
   end
   else begin
      decaleY := 0;
      margeY := LoupeSize - demiHauteur*2*gainLoupe;
   end;
   if X1<0 then begin
      decaleX := -round(X1*gainLoupe);
      X1 := 0;
      margeX := 0;
   end
   else begin
      decaleX := 0;
      margeX := LoupeSize - demiHauteur*2*gainLoupe;
   end;
   if Y2>hauteurAff then Y2 := hauteurAff;
   if X2>largeurAff then X2 := largeurAff;
   aPoint := ImageClientToScreen; // position de imgPreview / écran
   aPoint.offset(x,y); // position / écran
   LoupeForm.left := round(aPoint.X-demiHauteurLoupe);
   LoupeForm.top := round(aPoint.Y-demiHauteurLoupe);
   sourceRect := TrectF.create(X1/pasZoom,Y1/pasZoom,X2/pasZoom,Y2/pasZoom);
   destRect := TrectF.create(decaleX,decaleY,
                  decaleX+(X2-X1)*gainLoupe+margeX,
                  decaleY+(Y2-Y1)*gainLoupe+margeY);
   LoupeForm.bitmapLoupe.canvas.beginScene;
   LoupeForm.bitmapLoupe.Canvas.Clear(claNull);
   LoupeForm.bitmapLoupe.canvas.DrawBitmap(imgPreview.bitmap,
             sourceRect,destRect,1);
   Reperage;
   LoupeForm.bitmapLoupe.canvas.endScene;
   loupeForm.avecLoupe := true;
   if not loupeForm.visible then loupeForm.show;
   loupeForm.Active := true;
   FRegressiMain.timerLoupe.enabled := true;
   setCurseur(crNone);
   loupeForm.Image.invalidateRect(destRect);
   loupeForm.Image.Repaint;
end; // loupe

var BS : TstyleDrag;
    redessin : boolean;
begin  // MouseMove
convertitXY(sender,x,y);
if not appartientImage(x,y) then begin
   cacheLoupe;
   setCurseur(crDefault);
   exit;
end;
Redessin := borneSelect in [bsOrigine,bsEchelleX,bsEchelleY];
imgPreview.OnMouseMove := nil;
loupeForm.image.OnMouseMove := nil; // mise à jour longue ...
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
if (borneSelect in [bsMesure,bsOrigine,bsEchelleX,bsEchelleY])
    then Loupe
    else cacheLoupe;
imgPreview.OnMouseMove := formMouseMove;
loupeForm.image.OnMouseMove := formMouseMove;
end;

procedure TChronoBitmapForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  convertitXY(sender,x,y);
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
         FormMouseMove(ImgPreview,[],e_pointRepere[bsMesure].x,e_pointRepere[bsMesure].y);
         nouveauPoint := false;
     end;
  end;
end;

(*
procedure TChronoBitmapForm.TimerMoveTimer(Sender: TObject);
begin
   imgPreview.OnMouseMove := formMouseMove;
   loupeForm.image.OnMouseMove := formMouseMove;
   loupeForm.Active := true;
   timerMove.enabled := false;
end;
*)

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
         FormMouseMove(ImgPreview,[],e_pointRepere[bsMesure].x,e_pointRepere[bsMesure].y); // pour voir la trace sur la loupe.
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
  AColor: TAlphaColor);
begin
  couleurAxe := Acolor;
  dessine;
end;

procedure TChronoBitmapForm.CouleurPointCBColorSelected(Sender: TObject;
  AColor: TAlphaColor);
begin
  couleurPoint := Acolor;
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

Procedure TraceEchelle;
begin
      imageCanvas.drawLine(PointRepere[bsEchelleX],PointRepere[bsechelleY],1);
      TraceCroix(PointRepere[bsEchelleX]);
      TraceCroix(PointRepere[bsechelleY]);
end;

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
         imageCanvas.stroke.color := couleurAxe;
         TraceFleche(0,signeY);
         TraceFleche(1,0);
         TraceEchelle;
end; // traceOrigine

var i : integer;
begin // Dessine
    if (nomFichier='') then exit;
    ImgPreview.Bitmap.Assign(bitmapCourant);
    imageCanvas := ImgPreview.bitmap.Canvas;
    ImageCanvas.BeginScene;
    imageCanvas.stroke.thickness := ceil(1/pasZoom);
    couleurAxeCB.Visible := traceEchCB.isChecked;
    if traceEchCB.isChecked then TraceOrigine;
    couleurPointCB.Visible := tracePointsCB.isChecked;
    if tracePointsCB.isChecked then begin
       imageCanvas.stroke.color := CouleurPoint;
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
       cacheLoupe;
       setCurseur(crDefault);
    end;
end; // setBoutons


function GetScanline(ABitmap: TBitmap; ligne : integer): PAlphaColorArray;
var
  bitdata1: TBitmapData;
begin
  if ABitmap.Map(TMapAccess.Read, bitdata1) then begin
    try
      result := bitdata1.getScanLine(ligne);
    finally
      ABitmap.Unmap(bitdata1);
    end;
  end
  else result := nil
end;

procedure TChronoBitmapForm.LoupeSBChange(Sender: TObject);
begin
    gainLoupe := round(loupeSB.value)
end;

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

end.

