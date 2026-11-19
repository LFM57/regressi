unit BitmapU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Actions, System.Math.vectors, System.UIConsts, System.IOUtils, System.iniFiles,
  
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.Objects, FMX.Layouts,
  FMX.Platform, FMX.clipBoard, FMX.StdCtrls, FMX.ActnList,
  FMX.Memo, FMX.ListBox, FMX.Graphics, FMX.Utils,
  FMX.Controls.Presentation, FMX.Edit, FMX.EditBox, FMX.SpinBox, FMX.Colors,
  
  avProbe, 
  
  FMX.TMSToolBar, FMX.TMSBitmapContainer,
  
  images, maths;

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
    TMSFMXToolBar1: TTMSFNCToolBar;
    OpenBtn: TTMSFMXToolBarButton;
    MesureBtn: TTMSFMXToolBarButton;
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
    Label1: TLabel;
    LoupeSB: TSpinBox;
    TimerMove: TTimer;
    TMSFNCBitmapContainer1: TTMSFNCBitmapContainer;
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
    procedure TimerMoveTimer(Sender: TObject);
    procedure EchelleBtnClick(Sender: TObject);
    procedure UndoBtnClick(Sender: TObject);
    procedure ImgPreviewClick(Sender: TObject);
  private
    XY : array[0..MaxVecteurVideo] of TpointF;
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
    procedure CacheLoupe;
    procedure ConvertitXY(Sender: TObject;var X, Y: single);
    Function ImageClientToScreen : TpointF;
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

uses math, avcodec, avlib, loupeU,
     regutil, compile, valeurs, graphker, grapheVariabU, regmain, echelleBitmapU;

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

Function TBitmapForm.ImageClientToScreen : TpointF;
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

procedure TBitmapForm.ConvertitXY(Sender: TObject;var X, Y: single);
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

procedure TBitmapForm.CacheLoupe;
begin
     if loupeForm.visible then loupeForm.hide;
     FRegressiMain.timerLoupe.enabled := false;
end;

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
       cacheLoupe;
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
       ModeAcquisition := AcqBitmap;
       ModifFichier := true;
       FRegressiMain.WMRegMaj(MajFichier);
       FRegressiMain.windowTab.ActiveTab := FRegressiMain.grapheTab;
       FValeurs.feuillets.ActiveTab := Fvaleurs.VariabSheet;
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
     cacheLoupe;
     Rini := TMemIniFile.create(registreReg);
     Rini.WriteString('Bitmap','nomX',nomX);
     Rini.WriteString('Bitmap','nomY',nomY);
     Rini.WriteString('Bitmap','nomT',nomT);
     Rini.WriteString('Bitmap','uniteX',uniteX);
     Rini.writeString('Bitmap','uniteY',uniteY);
     Rini.writeString('Bitmap','uniteT',uniteT);
     Rini.WriteBool('Bitmap','polaire',echelleX=ePolaire);
     Rini.writeBool('Bitmap','avecT',avecT);
     Rini.writeBool('Bitmap','logX',echelleX=eLog);
     Rini.writeBool('Bitmap','logY',echelleY=eLog);
     Rini.UpdateFile;
     Rini.free;
end;

procedure TBitmapForm.FormCreate(Sender: TObject);

procedure CreerLoupe;
begin
    if LoupeForm=nil then
       Application.CreateForm(TLoupeForm, LoupeForm);
    LoupeForm.aform := bitmapForm;
    gainLoupe := 1;
    LoupeSB.Value := 1;
    LoupeForm.image.onMouseUp := FormMouseUp;
    LoupeForm.image.onClick := ImgPreviewClick;
    LoupeForm.image.onMouseDown := FormMouseDown;
    LoupeForm.image.onMouseMove := FormMouseMove;
    LoupeForm.onMouseUp := FormMouseUp;
    LoupeForm.Hide;
end;

var i : TStyleDrag;
    Rini : TMemIniFile;
begin
  LargeurAff := 640;
  HauteurAff := 480;
  Largeur := 640;
  Hauteur := 480;
  pasZoom := 1;
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
  Rini := TMemIniFile.create(registreReg);
  nomX := Rini.ReadString('Bitmap','nomX','x');
  nomY := Rini.ReadString('Bitmap','nomY','y');
  nomT := Rini.ReadString('Bitmap','nomT','t');
  uniteX := Rini.ReadString('Bitmap','uniteX','m');
  uniteY := Rini.ReadString('Bitmap','uniteY','m');
  uniteT := Rini.ReadString('Bitmap','uniteT','s');
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
    if LoupeForm<>nil then begin
        LoupeForm.close;
        LoupeForm.free;
        LoupeForm := nil;
    end;
    bitmapCourant.free;
end;

procedure TBitmapForm.setBorne(aBorne : TStyleDrag);
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

procedure TBitmapForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    convertitXY(sender,x,y);
    if (Button<>TMouseButton.mbLeft) or not appartientImage(x,y) then exit;
    if borneSelect=bsNone then
       setBorne(GetBorne(x,y));
    e_pointRepere[BorneSelect].x := x;
    e_pointRepere[BorneSelect].y := y;
    ecranVersImage;
end;

procedure TBitmapForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
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
   loupeForm.image.OnMouseMove := formMouseMove;
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
//timerMove.Enabled := true;
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
if (borneSelect in [bsMesure,bsOrigine,bsEchelleX,bsEchelleY])
      then Loupe
      else cacheLoupe;
imgPreview.OnMouseMove := formMouseMove;
timerMove.Enabled := false;
end;

procedure TBitmapForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  orthonorme := (echelleX=eLin) and (echelleY=eLin) and orthonorme;
  convertitXY(sender,x,y);
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
     bsMesure : begin
         XY[NmesVideo] := pointRepere[bsMesure];
         inc(NmesVideo);
         RegressiBtn.enabled := nmesVideo>2;
         dessine;
         FormMouseMove(ImgPreview,[],e_pointRepere[bsMesure].x,e_pointRepere[bsMesure].y); // pour voir la trace sur la loupe.
     end;
  end;
end;

procedure TBitmapForm.TimerMoveTimer(Sender: TObject);
begin
   timerMove.enabled := false;
   exit;
   imgPreview.OnMouseMove := formMouseMove;
   loupeForm.image.OnMouseMove := formMouseMove;
   loupeForm.Active := true;
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
     bsMesure : begin
         XY[NmesVideo] := pointRepere[bsMesure];
         inc(NmesVideo);
         RegressiBtn.enabled := nmesVideo>2;
         dessine;
         FormMouseMove(ImgPreview,[],e_pointRepere[bsMesure].x,e_pointRepere[bsMesure].y); // pour voir la trace sur la loupe.
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

procedure TBitmapForm.CouleurAxeCBColorSelected(Sender: TObject;
  AColor: TAlphaColor);
begin
  couleurAxe := Acolor;
  dessine;
end;

procedure TBitmapForm.CouleurPointCBColorSelected(Sender: TObject;
  AColor: TAlphaColor);
begin
  couleurPoint := Acolor;
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
         imageCanvas.stroke.color := couleurAxe;
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

procedure TBitmapForm.LoupeSBChange(Sender: TObject);
begin
    gainLoupe := round(loupeSB.value)
end;

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
       if echelleX=eLog
            then  penteX := log10(MaxiX/MiniX)/PixelX
            else  penteX := (MaxiX-MiniX)/PixelX;
       if echelleY=eLog
            then penteY := log10(MaxiY/MiniY)/PixelY
            else penteY := (MaxiY-MiniY)/PixelY;
       if orthonorme then penteX := penteY;
end;


procedure TBitmapForm.getValeur(i : integer;var valx,valy : double);
begin
    if i>=NmesVideo then begin
    valx := 0;
    valy := 0;
    end
    else begin
    valx := penteX*(xy[i].x-pointRepere[bsOrigine].x);
    valy := -penteY*(xy[i].y-pointRepere[bsOrigine].y);
    case echelleX of
       eLog : valx := MiniX*power(10,valx);
       eLin : valx := MiniX+valx;
       ePolaire : begin
            valx := arcTan2(valy,valx);
            if uniteX='°' then valx := radToDeg(valx);
       end;
    end;
     case echelleY of
       eLog : valy := MiniY*power(10,valy);
       eLin : valy := MiniY+valy;
       ePolaire : valy := sqrt(sqr(valx)+sqr(valy));
    end;
    end;
end;

end.

(*
procedure DrawRotatedBitmap(const Canvas : TCanvas; const Bitmap : TBitmap;
  const PointA, PointB : TPointF; const Offset : TPointF; const Scale : Single);
var
  OldMatrix, TranslationAlongLineMatrix, RotationMatrix, TranslationMatrix,
    ScaleMatrix, FinalMatrix: TMatrix;
  W, H : Single;
  SrcRect, DestRect: TRectF;
  Corner: TPointF;
  LineLength : Single;
  LineAngleDeg : Integer;
begin
  OldMatrix := Canvas.Matrix; // Original, to restore
  try
    {$ifdef DRAW_HELPERS}
      Canvas.Fill.Color := TAlphaColorRec.Black;
      Canvas.DrawLine(PointA, PointB, 0.5);
    {$endif}

    W := PointB.X - PointA.X;
    H := PointA.Y - PointB.Y;
    LineLength := abs(PointA.Distance(PointB));

    // Looking for the middle of the task line
    // and the coordinates of the image left upper angle
    // solving the proportion width/linelength=xo/0.5requireddimensions
    Corner := TPointF.Create((PointB.X + PointA.X) / 2, (PointA.Y + PointB.Y) / 2);// Middle
    {$ifdef DRAW_HELPERS}
      Canvas.Stroke.Color := TAlphaColorRec.Red;
      Canvas.DrawEllipse(TRectF.Create(Corner,2,2),1);
    {$endif}
    Corner.X := Corner.X - Bitmap.Width / 2 * W / LineLength;
    Corner.Y := Corner.Y + Bitmap.Width / 2 * H / LineLength;
    {$ifdef DRAW_HELPERS}
      Canvas.Stroke.Color := TAlphaColorRec.Green;
      Canvas.DrawEllipse(TRectF.Create(Corner,2,2),1);
    {$endif}

    // Account for scale (if the FMX control is scaled / zoomed); translation
    // (the control may not be located at (0, 0) in its parent form, so its canvas
    // is offset) and rotation
    ScaleMatrix := TMatrix.CreateScaling(Scale, Scale);
    TranslationMatrix := TMatrix.CreateTranslation(Offset.X, Offset.Y);
    RotationMatrix := TMatrix.CreateRotation(-ArcTan2(H, W));
    TranslationAlongLineMatrix := TMatrix.CreateTranslation(Corner.X, Corner.Y);
    FinalMatrix := ((RotationMatrix * ScaleMatrix) * TranslationMatrix) * TranslationAlongLineMatrix;

    // If in the top left or top right quadrants, the image will appear
    // upside down. So, rotate the image 180 degrees
    // This is useful when the image contains text, ie is an annotation or similar,
    // or needs to always appear "under" the line
    LineAngleDeg := Round(RadToDeg(-Arctan2(H, W)));
    case LineAngleDeg of
      -180..-90,
      90..180 : FinalMatrix := TMatrix.CreateRotation(DegToRad(180)) * TMatrix.CreateTranslation(Bitmap.Width, 0) * FinalMatrix;
    end;

    Canvas.SetMatrix(FinalMatrix);

    // And finally draw the bitmap
    DestRect := TRectF.Create(PointF(0, 0), Bitmap.Width, Bitmap.Height);
    SrcRect := TRectF.Create(0, 0, Bitmap.Width, Bitmap.Height);
    {$ifdef DRAW_HELPERS}
      Canvas.DrawBitmap(Bitmap, SrcRect, DestRect, 0.5);
    {$else}
      Canvas.DrawBitmap(Bitmap, SrcRect, DestRect, 1);
    {$endif}
  finally
    // Restore the original matrix
    Canvas.SetMatrix(OldMatrix);
  end;
end;
*)
