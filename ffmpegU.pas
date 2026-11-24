unit ffmpegU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Actions, System.Math.vectors, System.UIConsts,
  System.IOUtils, system.inifiles,

  FMX.Types, FMX.Controls,
  FMX.Forms, FMX.Dialogs,
  FMX.Objects, FMX.Layouts,
  FMX.Platform, FMX.clipBoard,
  FMX.StdCtrls, FMX.ActnList,
  FMX.Memo, FMX.ListBox,
  FMX.Graphics, FMX.Utils,
  FMX.Controls.Presentation,
  FMX.Edit, FMX.EditBox,
  FMX.SpinBox, FMX.Colors,

  FMX.TMSFNCToolBar,   
  FMX.TMSFNCBitmapContainer,
  FMX.TMSFNCTypes, FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomComponent,
  FMX.TMSFNCCustomControl,

  images, maths, rollingShutterCalc,

  avProbe;

type
  TstyleDrag = (bsNone,bsMesure,bsOrigine,bsEchelle1,bsEchelle2,bsChrono,bsChronoInit,bsAxeX,bsAxeY);
  TarrayPointF = array[TstyleDrag] of TpointF;

  TffmpegForm = class(TForm)
    OpenDialog: TOpenDialog;
    TrackBar: TTrackBar;
    TracePointsCB: TCheckBox;
    TraceEchCB: TCheckBox;
    EchelleEdit: TEdit;
    TimerPlay: TTimer;
    ToolBar1: TTMSFNCToolBar;
    OpenBtn: TTMSFNCToolBarButton;
    MesureBtn: TTMSFNCToolBarButton;
    CouleurPointCB: TTMSFNCToolBarColorPicker;
    CouleurAxeCB: TTMSFNCToolBarColorPicker;
    RegressiBtn: TTMSFNCToolBarButton;
    NextBtn: TTMSFNCToolBarButton;
    PreviousBtn: TTMSFNCToolBarButton;
    RazBtn: TTMSFNCToolBarButton;
    PlayBtn: TTMSFNCToolBarButton;
    EchelleLabel: TLabel;
    Separator2: TTMSFNCToolBarSeparator;
    Separator3: TTMSFNCToolBarSeparator;
    ChronoBtn: TTMSFNCToolBarButton;
    PanelPreview: TPanel;
    ImgPreview: TImage;
    BitmapContainer1: TTMSFNCBitmapContainer;
    RotationLabel: TLabel;
    GaucheBtn: TTMSFNCToolBarButton;
    DroiteBtn: TTMSFNCToolBarButton;
    RetardLabel: TLabel;
    RollingShutterSB: TSpinBox;
    NpointsLabel: TLabel;
    NbrePointsSB: TSpinBox;
    trigoCB: TCheckBox;
    IncertLabel: TLabel;
    incertSB: TSpinBox;
    TrackbarPanel: TPanel;
    DebutBtn: TButton;
    OptionsPanel: TPanel;
    EditBidon: TEdit;
    HelpBtn: TTMSFNCToolBarButton;
    SaveDialog: TSaveDialog;
    procedure OpenButtonClick(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure acPreviousExecute(Sender: TObject);
    procedure acNextExecute(Sender: TObject);
    procedure VideoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure VideoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure VideoMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure MesureBtnClick(Sender: TObject);
    procedure RegressiBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TimerPlayTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure RazBtnClick(Sender: TObject);
    procedure ChronoBtnClick(Sender: TObject);
    procedure TraceEchCBChange(Sender: TObject);
    procedure TracePointsCBChange(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure PanelPreviewResize(Sender: TObject);
    procedure EchelleEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
//    procedure TimerMoveTimer(Sender: TObject);
    procedure DroiteBtnClick(Sender: TObject);
    procedure trigoCBChange(Sender: TObject);
    procedure NbrePointsSBChange(Sender: TObject);
    procedure VideoClick(Sender: TObject);
    procedure DebutBtnClick(Sender: TObject);
    procedure PanelPreviewKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure VideoTap(Sender: TObject; const Point: TPointF);
    procedure CouleurAxeCBEChange(Sender: TObject);
    procedure CouleurPointCBColorSelected(Sender: TObject;
      AColor: TTMSFNCGraphicsColor);
    procedure CouleurAxeCBColorSelected(Sender: TObject;
      AColor: TTMSFNCGraphicsColor);
    procedure HelpBtnClick(Sender: TObject);
  private
    iDebug : integer;
    PointRepere : TarrayPointF;
    LongueurEchelle,echelle : double;
    e_PointRepere : TarrayPointF;
    BorneSelect : TstyleDrag;
    NmesVideo : integer;
    mesureEnCours : boolean;
    largeur, hauteur : integer;  // video
    LargeurAff,HauteurAff : integer; // Affichée
    DureeImage : double;
    pasZoom : single; // conversion xy(video) vers xy(écran)
    FProbe:TAVProbe;
    couleurPoint : array[indicePoint] of TAlphaColor;
    NbrePoints,pointCourant : indicePoint;
    bitmapCourant,bitmapFin,bitmapInit : Tbitmap;
    BlueCibleChrono, redCibleChrono,GreenCibleChrono : TColor;
    nomFichierChrono : string;
    ChronoPhotoEnCours : boolean;
    rotation : integer;
    signeY : integer;
    nouveauPoint : boolean;
    procedure Dessine;
    procedure EcranVersImage;
    procedure calcEchelle;
    procedure SetCurseur(Acursor : Tcursor);
    procedure EnregistrePoint(Sender: TObject;x,y : single);
    function AppartientImage(var X, Y: single) : boolean;
    Function GetBorne(x,y : single;deplace : boolean) : TstyleDrag;
    procedure setBorne(aBorne : TStyleDrag);
    procedure setBoutons;
    procedure ImageVersEcran;
    procedure sauveImage(index : single);
    procedure effectuerZoom;
    procedure AffecteChrono;
    procedure InitChronoPhoto;
    procedure SaveChronoPhoto;
    procedure videRepertoire;
    function getNomImage(index : single) : string;
    procedure afficheImage(index : single);
    procedure upDateImage(NomImage : string);
  public
  end;

var
  ffmpegForm: TffmpegForm;

implementation

{$R *.fmx}

uses math, avcodec, avlib,
  {$IFDEF MacOS}
     Posix.Unistd,   // pour deleteFile
  {$ENDIF}
     regutil, compile, valeurs, graphker, grapheVariabU, regmain, chronoViewU;

const  // Pour chronoPhoto
    pasCouleur = 16;
    resolution = 192;
    resolutionCibleMin = 32;
    resolutionCibleMax = 6*pasCouleur;
    Magnet = 8;

procedure TffmpegForm.acNextExecute(Sender: TObject);
var nomImage : string;
    sauveTimer : boolean;
begin
   if (FProbe<>nil) and FProbe.Active and (TrackBar.Value<trackBar.Max) then begin
       sauveTimer := timerPlay.Enabled;
       TimerPlay.Enabled := false;
       NextBtn.Enabled := false;
       PreviousBtn.Enabled := false;
       nomImage := getNomImage(trackBar.Value+1);
       if (nomImage='') or not FileExists(nomImage)
          then begin
               FProbe.NextFrame; // marche pour toutes les videos sauf .mov
               sauveImage(trackBar.Value+1);
          end
          else TrackBar.Value := trackBar.Value+1; // trackBarChange fait le travail
       TimerPlay.Enabled := sauveTimer and (trackBar.Value<trackBar.Max);
       if sauveTimer and not TimerPlay.Enabled then trackBar.value := 0;
   end;
end;

procedure TffmpegForm.acPreviousExecute(Sender: TObject);
begin
   if (TrackBar.Value>0) and (FProbe<>nil) and FProbe.Active then begin
       NextBtn.Enabled := false;
       PreviousBtn.Enabled := false;
       TrackBar.Value := round(trackBar.Value)-1;
   end;
end;

procedure TffmpegForm.OpenButtonClick(Sender: TObject);

procedure RecupereDataProbe;
begin
     try
          trackBar.tag := 1;
          TrackBar.Max := FProbe.Duration*FProbe.videoframeRate-1;
          trackbar.Min := 0;
          trackBar.Value := 0;
          trackBar.tag := 0;
          largeur := FProbe.VideoWidth;
          hauteur := FProbe.VideoHeight;
          PointRepere[bsOrigine] := pointF(Largeur/2,Hauteur/2);
          PointRepere[bsEchelle1] := pointF(Largeur/4,3*Hauteur/4);
          PointRepere[bsEchelle2] := pointF(3*Largeur/4,3*Hauteur/4);
          EffectuerZoom;
          DureeImage := 1/FProbe.videoframeRate;
          // FProbe.StartTime;
     except
        cursor := crDefault;
     end;
end;

begin
  if OpenDialog.Execute then begin
    iDebug := 0;
    setCurseur(crDefault);
    NmesVideo := 0;
    pasZoom := 1;
    setBorne(bsNone);
    Caption := 'Acquisition video ['+extractFileName(OpenDialog.FileName)+']';
    FProbe.Active := false;
    videRepertoire;
    FProbe.FileName := OpenDialog.FileName;
    FProbe.Active := true;
    RecupereDataProbe;
    setBoutons;
    FProbe.NextFrame;
    sauveImage(0);
    PlayBtnClick(sender);
  end;
end;

procedure TffmpegForm.PanelPreviewKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
var pointCourant : TPointF;
begin
    if (keyChar=' ') and (borneSelect=bsMesure) then begin
        pointCourant := Screen.MousePos;
        pointCourant := ScreenToClient(pointCourant);
        pointCourant.Offset(-PanelPreview.position.X,-PanelPreview.position.y);
        EnregistrePoint(PanelPreview,pointCourant.x,pointCourant.y);
    end;
end;

procedure TffmpegForm.PanelPreviewResize(Sender: TObject);
begin
      effectuerZoom;
end;

procedure TffmpegForm.PlayBtnClick(Sender: TObject);
begin
  if timerPlay.enabled then begin
     timerPlay.Enabled := false;
     PlayBtn.Text:='Play';
  end
  else begin
     timerPlay.Enabled := true;
     PlayBtn.Text:='Pause';
  end;
end;

procedure TffmpegForm.VideRepertoire;
var info : TSearchRec;
    recherche,nomFichier : string;
begin
  recherche := System.IOUtils.Tpath.combine(supportPath,'*.bmp');
  if findFirst(recherche,faAnyFile,Info)=0 then begin
      repeat
         if (Info.attr and faDirectory)<>faDirectory then begin
            nomFichier := System.IOUtils.Tpath.combine(supportPath,Info.Name);
            // si temp  test début du fichier = temp
            deleteFile(nomFichier);
         end;
      until FindNext(Info)<>0;
      FindClose(info);
  end;
end;

procedure TffmpegForm.RazBtnClick(Sender: TObject);
begin
      if OKReg('Suppression des données',0) then begin
         NmesVideo := 0;
         afficheImage(trackBar.value);
         setBoutons;
     end;
end;

procedure TffmpegForm.RegressiBtnClick(Sender: TObject);
begin
       calcEchelle;
       MesureEnCours := false;
       correctionRS.x0 := pointRepere[bsOrigine].X;
       correctionRS.y0 := pointRepere[bsOrigine].Y;
       correctionRS.RSvalue := RollingShutterSB.value;
       correctionRS.nmes := nmesVideo;
       correctionRS.NbrePoints := NbrePoints;
       correctionRS.hauteur := hauteur;
       correctionRS.echelle := echelle;
       correctionRS.angleX := 0;
       correctionRS.signeY := signeY;
       correctionRS.incertXY := round(incertSB.value);
       correctionRS.sauveData;
       NomFichierData := FProbe.FileName;
       ModifFichier := true;
       include(graphe.Modif,gmXY); // le + général
{$IFDEF Debug}
       EcritDebug('Sortie video début activeTab');
       FRegressiMain.AppelVideo := true;
{$ENDIF}
       FRegressiMain.windowTab.ActiveTab := FRegressiMain.grapheTab;
       FValeurs.feuillets.ActiveTab := Fvaleurs.VariabSheet;
{$IFDEF Debug}
       EcritDebug('Sortie video fin ActiveTab');
{$ENDIF}
       Close;
{$IFDEF Debug}
       EcritDebug('Sortie video Fin');
{$ENDIF}
end; // SauveData

procedure TffmpegForm.FormActivate(Sender: TObject);
begin
    setBoutons;
end;

procedure TffmpegForm.FormClose(Sender: TObject; var Action: TCloseAction);
var Rini : TMemIniFile;
begin
     Rini := TMemIniFile.create(registreReg);
     Rini.WriteString('Video','Echelle',EchelleEdit.text);
     Rini.WriteBool('Video','TracePoints',tracePointsCB.isChecked);
     Rini.WriteBool('Video','TraceEch',traceEchCB.isChecked);
     Rini.WriteInteger('Video','IncertXY',round(incertSB.Value));
     Rini.WriteBool('Video','Trigo',trigoCB.isChecked);
     Rini.writeInteger('Video','NbrePoints',round(NbrePointsSB.value));
     Rini.writeInteger('Video','RollingShutter',round(RollingShutterSB.value));
     Rini.UpdateFile;
     Rini.Free;
     if pages[pageCourante].nmes=0 then FRegressiMain.FileNewSimulationItemClick(Sender);
     if FProbe<>nil then FProbe.Active := false;
     videRepertoire;
     if ChronoForm<>nil then ChronoForm.Free;
     setBorne(bsNone);
     timerPlay.Enabled := false;
     PlayBtn.Text := 'Play';
end;

procedure TffmpegForm.FormCreate(Sender: TObject);

procedure litIni;
var Rini : TmemInifile;
begin
     Rini := TMemIniFile.create(registreReg);
     EchelleEdit.text := Rini.ReadString('Video','Echelle','1');
     longueurEchelle := strToFloatWin(EchelleEdit.text);
     tracePointsCB.isChecked := Rini.ReadBool('Video','TracePoints',true);
     traceEchCB.isChecked := Rini.ReadBool('Video','TraceEch',true);
     incertSB.Value := Rini.ReadInteger('Video','IncertXY',1);
     trigoCB.isChecked := Rini.ReadBool('Video','Trigo',true);
     if trigoCB.isChecked
          then signeY := -1
          else signeY := 1;
     NbrePointsSB.value := Rini.ReadInteger('Video','NbrePoints',1);
     NbrePoints := round(NbrePointsSB.Value);
     RollingShutterSB.value := Rini.ReadInteger('Video','RollingShutter',0);
     Rini.Free;
end;

var i : TStyleDrag;
    j : indicePoint;
begin
  litIni;
  DureeImage := 1/30;
  LargeurAff := 640;
  HauteurAff := 480;
  Largeur := 640;
  Hauteur := 480;
  pasZoom := 1;
  FProbe := TAVProbe.Create;
  for j := 1 to NPointsMax do
      couleurPoint[j] := claRed;
  couleurPointCB.SelectedColor := claRed;
  couleurAxeCB.SelectedColor := claBlue;
  PointCourant := 1;
  borneSelect := bsNone;
  bitmapCourant := Tbitmap.create;
  for i := low(TstyleDrag) to High(TstyleDrag) do begin
           e_pointRepere[i].x := 0;
           e_pointRepere[i].y := 0;
  end;
end;

procedure TffmpegForm.FormDestroy(Sender: TObject);
begin
    FProbe.Free;
    bitmapCourant.Free;
end;

procedure TffmpegForm.setBorne(aBorne : TStyleDrag);
begin
     borneSelect := aBorne;
     case BorneSelect of
         bsOrigine,bsEchelle1,bsEchelle2 : setCurseur(crSizeAll);
         bsMesure,bsChronoInit : setCurseur(crCross);
         else setCurseur(crDefault); // bsChrono, bsNone
     end;
end;

procedure TffmpegForm.VideoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    if (Button<>TMouseButton.mbLeft) or not appartientImage(x,y) then exit;
    if borneSelect=bsNone then
       setBorne(GetBorne(x,y,true));
    e_pointRepere[BorneSelect].x := x;
    e_pointRepere[BorneSelect].y := y;
    ecranVersImage;
    nouveauPoint := true;
end;

procedure TffmpegForm.VideoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
var BS : TstyleDrag;
begin
if not appartientImage(x,y) then begin
   setCurseur(crDefault);
   exit;
end;
e_pointRepere[BorneSelect].x := x;
e_pointRepere[BorneSelect].y := y;
ecranVersImage;
case BorneSelect of
     bsEchelle1,bsEchelle2,bsOrigine : afficheImage(trackBar.value); // retrace
     bsMesure,bsChrono,bsChronoInit : ;
     bsNone : begin
         BS := GetBorne(x,y,false);
         if BS in [bsEchelle1,bsEchelle2,bsOrigine]
             then setCurseur(crSizeAll)
             else setCurseur(crDefault);
     end;
end;
end;

procedure TffmpegForm.VideoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var xinit,yinit : single;
begin
  xinit := x;
  yinit := y;
  if (Button<>TMouseButton.mbLeft) or not appartientImage(x,y) then exit;
  e_pointRepere[BorneSelect].x := x;
  e_pointRepere[BorneSelect].y := y;
  ecranVersImage;
  case BorneSelect of
     bsNone : ;
     bsEchelle1,bsEchelle2,bsOrigine : begin
         setBorne(bsNone);
         afficheImage(trackBar.value);
     end;
     bsChrono : ;
     bsMesure : begin
        EnregistrePoint(sender,xinit,yinit);
        nouveauPoint := false;
     end;
     bsChronoInit : InitChronoPhoto;
  end;
end;

procedure TffmpegForm.TimerPlayTimer(Sender: TObject);
begin
    if trackBar.value>=trackBar.Max
       then begin
          timerPlay.Enabled := false;
          trackBar.Value := 0;
       end
       else acNextExecute(sender);
end;

procedure TffmpegForm.TraceEchCBChange(Sender: TObject);
begin
    afficheImage(trackBar.value)
end;

procedure TffmpegForm.TracePointsCBChange(Sender: TObject);
begin
    afficheImage(trackBar.value)
end;

procedure TffmpegForm.TrackBarChange(Sender: TObject);
begin
     if (TrackBar.Tag = 0) and (FProbe<>nil) and FProbe.Active
       then afficheImage(trackBar.Value);
end;

procedure TffmpegForm.AfficheImage(index : single);
var nomImage : string;
begin
    nomImage := getNomImage(index);
    if (nomImage='') or not FileExists(nomImage)
       then begin
           FProbe.TimeStamp := Round(index*dureeImage*AV_TIME_BASE);
           sauveImage(index);
       end
       else updateImage(nomImage);
end;

procedure TffmpegForm.ImageVersEcran;
var i : TstyleDrag;
begin
       for i := low(TstyleDrag) to High(TstyleDrag) do
           e_pointRepere[i] := pointRepere[i]*pasZoom;
end;

procedure TffmpegForm.VideoTap(Sender: TObject; const Point: TPointF);
begin
  case BorneSelect of
     bsNone : ;
     bsEchelle1,bsEchelle2,bsOrigine : begin
         setBorne(bsNone);
         dessine;
     end;
     bsMesure : begin
        EnregistrePoint(sender,Point.x,Point.y);
        nouveauPoint := false;
     end;
     bsChrono : ;
     bsChronoInit : InitChronoPhoto;
  end;
end;

procedure TffmpegForm.VideoClick(Sender: TObject);
begin
 case BorneSelect of
     bsNone : ;
     bsEchelle1,bsEchelle2,bsOrigine : begin
         setBorne(bsNone);
         dessine;
     end;
     bsMesure : ;
  end;
end;

procedure TffmpegForm.EchelleEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if not CharInSet(keyChar,['0'..'9','.',',','m',
                     crSupprArr,crCR,crTab,crGauche,crDroite]) then keyChar := #0
end;

procedure TffmpegForm.EcranVersImage;
var i : TstyleDrag;
begin
       for i := low(TstyleDrag) to High(TstyleDrag) do
           pointRepere[i] := e_pointRepere[i]/pasZoom;
end;

procedure TffmpegForm.calcEchelle;
var EchelleEnPixel : double;
begin
     if (FProbe=nil) or not FProbe.Active then exit;
     echelleEnPixel := PointRepere[bsEchelle1].distance(PointRepere[bsechelle2]);
     try
        LongueurEchelle := StrToFloatWin(EchelleEdit.text);
     except
         showMessage('Erreur lors de la lecture de l''échelle');
         EchelleEdit.text := FormatReg(LongueurEchelle);
         EchelleEdit.SetFocus;
     end;
     Echelle := LongueurEchelle/EchelleEnPixel;
end;

procedure TffmpegForm.CouleurAxeCBColorSelected(Sender: TObject;
  AColor: TTMSFNCGraphicsColor);
begin
    dessine; // mise à jour
end;

procedure TffmpegForm.CouleurAxeCBEChange(Sender: TObject);
begin
     dessine
end;

procedure TffmpegForm.CouleurPointCBColorSelected(Sender: TObject;
  AColor: TTMSFNCGraphicsColor);
begin
   couleurPoint[PointCourant] := Acolor; // or System.UITypes.TAlphaColorRec.Alpha
   dessine;
end;

procedure TffmpegForm.SetCurseur(Acursor : Tcursor);
begin
   imgPreview.Cursor := aCursor;
end;

procedure TffmpegForm.EnregistrePoint(Sender: TObject;x,y : single);
begin
         correctionRS.XY[PointCourant,NmesVideo] := pointRepere[bsMesure];
         inc(PointCourant);
         correctionRS.Temps[NmesVideo] := nmesVideo*dureeImage;
         if PointCourant>NbrePoints then begin
            inc(NmesVideo);
            PointCourant := 1;
         end;
         RegressiBtn.enabled := nmesVideo>2;
         if PointCourant=1 then if trackBar.value<trackBar.Max
                then begin
                   acNextExecute(nil);
                   VideoMouseMove(sender,[],x,y);
                   editBidon.setFocus;
                end
                else begin
                   setBorne(bsNone);
                   MesureEnCours := false;
                   setBoutons;
                   dessine;
                end;
end;

function TffmpegForm.AppartientImage(var X, Y: single) : boolean;
begin
    result := (x>0) and (y>0) and (y<hauteurAff) and (x<largeurAff)
end;

procedure TffmpegForm.DroiteBtnClick(Sender: TObject);
var nomImage : string;
    signe : integer;
begin
    if (FProbe=nil) or not FProbe.Active then exit;
    if sender=droiteBtn then signe := 1 else signe := -1;
    rotation := rotation+signe;
    swap(largeur,hauteur);
    droiteBtn.Enabled := rotation<1;
    gaucheBtn.Enabled := rotation>-1;
    effectuerZoom;
    if PointRepere[bsOrigine].X>Largeur/2 then PointRepere[bsOrigine].X := Largeur/2;
    if PointRepere[bsOrigine].Y>Hauteur/2 then PointRepere[bsOrigine].Y := Hauteur/2;
    if PointRepere[bsEchelle1].X>Largeur then PointRepere[bsEchelle1].X := Largeur/4;
    if PointRepere[bsEchelle1].Y>Hauteur then PointRepere[bsEchelle1].Y := 3*Hauteur/4;
    if PointRepere[bsEchelle2].X>Largeur then PointRepere[bsEchelle2].X := 3*Largeur/4;
    if PointRepere[bsEchelle2].Y>Hauteur then PointRepere[bsEchelle2].Y := 3*hauteur/4;
    nomImage := getNomImage(trackBar.Value);
    if (nomImage='') or not FileExists(nomImage)
        then begin
           FProbe.TimeStamp := Round(trackBar.Value*dureeImage*AV_TIME_BASE);
           sauveImage(trackBar.Value);
        end
        else updateImage(nomImage);
end;

Function TffmpegForm.GetBorne(x,y : single;deplace : boolean) : TstyleDrag;
var i : TstyleDrag;
    aPoint : TPointF;
begin
      result := bsNone;
      aPoint := PointF(x,y);
      for i in [bsOrigine,bsEchelle1,bsEchelle2] do
          if e_PointRepere[i].distance(aPoint) < Magnet
              then begin
                 result := i;
                 exit;
              end;
end;

procedure TffmpegForm.EffectuerZoom;
var zoomX,zoomY,zoom : single;
begin
    if (FProbe=nil) or not FProbe.Active then exit;
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

procedure TffmpegForm.MesureBtnClick(Sender: TObject);
begin
  mesureEnCours := not mesureEnCours;
  if MesureEnCours
  then begin
     setBorne(bsMesure);
     NmesVideo := 0;
     PointCourant := 1;
     MesureBtn.text := 'STOP';
     editBidon.SetFocus;
  end
  else begin
     setBorne(bsNone);
     MesureBtn.text := 'Mesurer';
  end;
  setBoutons;
end;

procedure TffmpegForm.NbrePointsSBChange(Sender: TObject);
begin
    NbrePoints := round(NbrePointsSB.value);
end;

procedure TffmpegForm.DebutBtnClick(Sender: TObject);
begin
    trackBar.value := 0;
end;

procedure TffmpegForm.Dessine;
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
         imageCanvas.stroke.color :=  couleurAxeCB.SelectedColor;
         imageCanvas.stroke.color :=  claBlue;
         TraceFleche(0,signeY);
         TraceFleche(1,0);
         imageCanvas.drawLine(PointRepere[bsEchelle1],PointRepere[bsechelle2],1);
         TraceCroix(PointRepere[bsEchelle1]);
         TraceCroix(PointRepere[bsechelle2]);
end;

var i : integer;
    j : indicePoint;
begin // Dessine
    if (FProbe=nil) or not FProbe.Active then exit;
    if (borneSelect in [bsChrono,bsChronoInit]) then exit;
    imageCanvas := ImgPreview.bitmap.Canvas;
    ImageCanvas.BeginScene;
    imageCanvas.stroke.thickness := 1/pasZoom;
    imageCanvas.stroke.kind := TBrushKind.solid;
    couleurAxeCB.Visible := traceEchCB.isChecked;
    if traceEchCB.isChecked then TraceOrigine;
    couleurPointCB.Visible := tracePointsCB.isChecked;
    if tracePointsCB.isChecked then begin
       for i := 0 to nmesVideo-1 do begin
           for j := 1 to NbrePoints do begin
              imageCanvas.stroke.color := CouleurPoint[j]; // or System.UITypes.TAlphaColorRec.Alpha;
              TraceCroix(correctionRS.XY[j,i]);
           end;
       end;
       for j := 1 to PointCourant do begin
           imageCanvas.stroke.color := CouleurPoint[j]; // or System.UITypes.TAlphaColorRec.Alpha;
           TraceCroix(correctionRS.XY[j,pred(nmesVideo)]);
       end;
    end; // tracePoints
    ImageCanvas.EndScene;
end; // Dessine

procedure TffmpegForm.setBoutons;
var OK : boolean;
begin
    OK := (FProbe<>nil) and FProbe.Active;
    EchelleEdit.enabled := OK;
    PlayBtn.Enabled := OK;
    trackBar.Enabled := OK;
    RegressiBtn.enabled := nmesVideo>2;
    NextBtn.Enabled := OK and (trackBar.value<trackBar.Max);
    PreviousBtn.Enabled := OK and (trackBar.value>trackBar.Min);
    MesureBtn.enabled := OK;
    RazBtn.enabled := OK and not MesureEnCours and (nmesVideo>2);
    if MesureEnCours
       then mesureBtn.text := 'Stop'
       else mesureBtn.text := 'Mesurer';
    if (borneSelect in [bsNone,bsChrono]) then begin
       setCurseur(crDefault);
    end;
    if ChronoPhotoEnCours
       then ChronoBtn.Text := 'Stop chrono'
       else ChronoBtn.Text := 'ChronoPhoto';
end; // setBoutons

procedure TffmpegForm.SauveImage(index : single);
var nomImage : string;
begin
   imgPreview.Bitmap.Assign(FProbe.Bitmap);
   trackbar.Tag := 1;
   trackBar.Value := index;
   trackbar.Tag := 0;
   nomImage := getNomImage(index);
   if (nomImage<>'') and not FileExists(nomImage)
        then imgPreview.Bitmap.SaveToFile(nomImage);
   // PixelFormat=BGRA
end;

procedure TffmpegForm.AffecteChrono;
var couleurC,couleurInit : TAlphaColorRec;
    bitmapDataC,bitmapDataInit : TBitmapData;
    xPrec,yPrec : integer;
    xAttendu,yAttendu : integer;
    DeltaX,DeltaY : integer;
    x0,y0 : integer;
    ecartMin : integer;

procedure EnregistrePointChrono;
// on affine autour de x0, y0
var xMin,xMax : integer;
    yMin,yMax : integer;
    xc,yc,x1,y1,x2,y2 : integer;
    ecartCible,ecart : integer;
    largeurCible,hauteurCible : integer;
begin
    largeurCible := largeur div 24; // zone de recherche
    hauteurCible := hauteur div 24;
    correctionRS.XY[1,NmesVideo].x := x0;  // par défaut
    correctionRS.XY[1,NmesVideo].y := y0;
    xMin := x0+hauteurCible;
    xMax := x0-hauteurCible;
    yMin := y0+largeurCible;
    yMax := y0-largeurCible;
    y1 := yMax;y2 := yMin;
    if y1<0 then y1 := 0;
    if y2>=hauteur then y2 := pred(hauteur);
    x1 := xMax;x2 := xMin;
    if x1<0 then x1 := 0;
    if x2>=largeur then x2 := pred(largeur);
    if BitmapCourant.Map(TMapAccess.Read, bitmapDataC) and
       BitmapInit.Map(TMapAccess.Read, bitmapDataInit)
    then begin
    try
    for yc := y1 to y2 do begin
        for xc := x1 to x2 do begin
            couleurC.color := bitmapDataC.getPixel(xc,yc);
            couleurInit.color := bitmapDataInit.getPixel(xc,yc);
            ecart := abs(integer(couleurInit.B)-
                         integer(couleurC.B))+
                     abs(integer(couleurInit.G)-
                     integer(couleurC.G))+
                     abs(integer(couleurInit.R)-
                     integer(couleurC.R));
            ecartCible := abs(BlueCibleChrono-integer(couleurC.B))+
                          abs(GreenCibleChrono-integer(couleurC.G))+
                          abs(RedCibleChrono-integer(couleurC.R));
            if ecartCible<resolution then setPixel(bitmapFin,xc,yc,TAlphaColor(couleurC));
            if (ecart>resolution) and (ecartCible<ecartMin) then begin
            // différent de l'état initial et proche couleur cible
               if xc<xMin then xMin := xc;
               if yc<yMin then yMin := yc;
               if xc>xMax then xMax := xc;
               if yc>yMax then yMax := yc;
            end;
        end;// for xc
    end;// for yc
    finally
        BitmapCourant.Unmap(bitmapDataC);
        BitmapInit.Unmap(bitmapDataInit);
    end;
    end;
    correctionRS.Temps[NmesVideo] := trackBar.value*dureeImage;
    correctionRS.XY[1,NmesVideo].x := (xMin+xMax) div 2;
    correctionRS.XY[1,NmesVideo].y := (yMin+yMax) div 2;
    correctionRS.Temps[NmesVideo] := trackbar.value*dureeImage;
    inc(NmesVideo);
end; // EnregistrePointChrono

function chercheMobile : boolean;
var resolutionCible : integer;
    ecart,ecartCible : integer;
    xc,yc : integer;
    procheAttendu,prochePrec : boolean;
    ligneProcheAttendu,ligneProchePrec : boolean;
begin
resolutionCible := resolutionCibleMin;
result := false;
if BitmapCourant.Map(TMapAccess.Read, bitmapDataC) and
   BitmapInit.Map(TMapAccess.Read, bitmapDataInit) then begin
try
   repeat
      EcartMin := resolutionCible;
      for yc := 0 to pred(hauteur) do begin
         ligneProcheAttendu := abs(yc-yAttendu)<deltaY;
         ligneProchePrec := abs(yc-yPrec)<deltaY;
         if ligneProcheAttendu or ligneProchePrec then begin
           for xc := 0 to pred(largeur) do begin
              procheAttendu := (abs(xc-xAttendu)<deltaX) and ligneProcheAttendu;
              prochePrec := (abs(xc-xPrec)<deltaX) and ligneProchePrec;
              if (procheAttendu or prochePrec) then begin
                 couleurC.color := bitmapDataC.getPixel(xc,yc);
                 couleurInit.color := bitmapDataInit.getPixel(xc,yc);
                 ecart := abs(integer(couleurInit.B)-integer(couleurC.B))+
                          abs(integer(couleurInit.G)-integer(couleurC.G))+
                          abs(integer(couleurInit.R)-integer(couleurC.R));
                 if (ecart>resolution)  then begin
                 // On cherche là où il y eu changement
                    ecartCible := abs(BlueCibleChrono-integer(couleurC.B))+
                                  abs(GreenCibleChrono-integer(couleurC.G))+
                                  abs(RedCibleChrono-integer(couleurC.R));
                    if ecartCible<ecartMin then begin // couleur proche couleurCible
                       ecartMin := ecartCible;
                       x0 := xc;y0 := yc;
                    end;
                 end;  // changement
              end; // point proche
           end;// for xc
         end;// ligne proche
      end;// for yc
    result := (x0>0) and (y0>0);
    inc(resolutionCible,pasCouleur);
   until result or (resolutionCible>resolutionCibleMax);
finally
    BitmapCourant.Unmap(bitmapDataC);
    BitmapInit.Unmap(bitmapDataInit);
end;
end;
end; // chercheMobile

function chercheFixe : boolean;
var ecartCible : integer;
    xc,yc : integer;
    resolutionCible : integer;
    xMin,xMax : integer;
    yMin,yMax : integer;
    bitmapDataC : TbitmapData;
begin
    resolutionCible := resolutionCibleMin;
    xMin := xPrec-deltaX;
    xMax := xPrec+deltaX;
    yMin := yPrec-deltaY;
    yMax := yPrec+deltaY;
    if yMin<0 then yMin := 0;
    if yMax>=hauteur then yMax := pred(hauteur);
    if xMin<0 then xMin := 0;
    if xMax>=largeur then xMax := pred(largeur);
    result := false;
    if BitmapCourant.Map(TMapAccess.Read, bitmapDataC) then begin
    try
    repeat
    EcartMin := resolutionCible;
    for yc := ymin to ymax do begin
        for xc := xmin to xmax do begin
            couleurC.color := bitmapDataC.getPixel(xc,yc);
            ecartCible := abs(BlueCibleChrono-integer(TAlphaColorRec(couleurC).B))+
                          abs(GreenCibleChrono-integer(TAlphaColorRec(couleurC).G))+
                          abs(RedCibleChrono-integer(TAlphaColorRec(couleurC).R));
            if ecartCible<ecartMin then begin // couleur proche couleurCible
               ecartMin := ecartCible;
               x0 := xc;y0 := yc;
            end;
        end;// for xc
    end;// for yc
    result := (x0>0) and (y0>0);
    inc(resolutionCible,pasCouleur);
    until result or (resolutionCible>resolutionCibleMax);
    finally
        BitmapCourant.Unmap(bitmapDataC);
    end;
    end;
end; // chercheFixe

var
    trouve : boolean;
begin // affecteChrono
    timerPlay.Enabled := false;
    DeltaX := largeur div 16; // zone de recherche
    DeltaY := hauteur div 16;
    x0 := 0;
    y0 := 0;
    xPrec := round(correctionRS.XY[1,pred(nmesVideo)].x);
    yPrec := round(correctionRS.XY[1,pred(nmesVideo)].y);
    if nmesVideo>1 then begin // Nouvelle position en supposant la vitesse constante
       xAttendu := 2*xPrec-round(correctionRS.XY[1,nmesVideo-2].x);
       yAttendu := 2*yPrec-round(correctionRS.XY[1,nmesVideo-2].y);
    end
    else begin
       xAttendu := xPrec;
       yAttendu := yPrec;
    end;
    trouve := chercheMobile; // on cherche là où l'image a changé
    if not trouve then trouve := chercheFixe; // on cherche la couleur de la cible
    if trouve then begin
       inc(ecartMin,pasCouleur);
       enregistrePointChrono;
       if trackBar.value<trackBar.Max
          then timerPlay.Enabled := true
          else saveChronoPhoto;
    end
    else saveChronoPhoto;
end; // AffecteChrono

procedure TffmpegForm.trigoCBChange(Sender: TObject);
begin
       if trigoCB.isChecked
          then signeY := -1
          else signeY := 1;
       e_pointRepere[bsAxeY].x := 2*e_pointRepere[bsOrigine].x-e_pointRepere[bsAxeY].x;
       e_pointRepere[bsAxeY].y := 2*e_pointRepere[bsOrigine].y-e_pointRepere[bsAxeY].y;
       dessine;
end;

procedure TffmpegForm.SaveChronoPhoto;
begin
       setBorne(bsNone);
       bitmapFin.saveToFile(nomFichierChrono);
       bitmapFin.free;
       bitmapInit.free;
       if ChronoForm=nil then
          ChronoForm := TChronoForm.Create(self);
       ChronoForm.image.bitmap.loadFromFile(NomFichierChrono);
       if not chronoForm.Visible then ChronoForm.show;
       TimerPlay.Enabled := false;
       ChronoPhotoEnCours := false;
       setBoutons;
end;

procedure TffmpegForm.ChronoBtnClick(Sender: TObject);
begin
    if ChronoPhotoEnCours
    then begin // fin chrono
         if (borneSelect=bsChrono) and (trackBar.value>10)
            then saveChronoPhoto;
         setBorne(bsNone);
    end
    else begin // début chrono
        SaveDialog.DefaultExt := 'png';
        SaveDialog.Filter := 'Images PNG (*.png)|*.png';
        SaveDialog.Title := 'Sauvegarde chronophotographie';
        if SaveDialog.Execute
           then begin
              nomFichierChrono := ChangeFileExt(SaveDialog.FileName,'.png');
              if (NbrePoints>1) then begin
                  showMessage('Un seul mobile');
                  NbrePointsSB.value := 1;
                  NbrePoints := 1;
              end;
              showMessage('Cliquer sur la cible à suivre');
              setBorne(bsChronoInit);
           end
           else setBorne(bsNone);
    end;
    TimerPlay.enabled := false;
    ChronoPhotoEnCours :=  BorneSelect = bsChronoInit;
    if ChronoPhotoEnCours
       then ChronoBtn.Text := 'Stop chrono'
       else ChronoBtn.Text := 'ChronoPhoto';
end;

procedure TffmpegForm.InitChronoPhoto;

procedure InitMesure;
var
    i,j : integer;
    couleur : TAlphaColorRec;
    bitmapDataC : TbitmapData;
    xCibleChrono,yCibleChrono : integer;
begin
     PointCourant := 1;
     correctionRS.Temps[0] := trackBar.value*dureeImage;
     correctionRS.XY[1,0] := pointRepere[bsChronoInit];
     NmesVideo := 1;
     xCibleChrono := round(pointRepere[bsChronoInit].x);
     yCibleChrono := round(pointRepere[bsChronoInit].y);
     RedCibleChrono := 0;
     BlueCibleChrono := 0;
     GreenCibleChrono := 0;
     if (xCibleChrono>=1) and (xCibleChrono<=largeur-2) and
        (yCibleChrono>=1) and (yCibleChrono<=hauteur-2) and
        BitmapCourant.Map(TMapAccess.Read, bitmapDataC) then begin
       try
         for j := yCibleChrono-1 to yCibleChrono+1 do begin
              for i := xCibleChrono-1 to xCibleChrono+1 do begin
                couleur.color := bitmapDataC.getPixel(i,j);
                RedCibleChrono := RedCibleChrono+integer(couleur.R);
                BlueCibleChrono := BlueCibleChrono+integer(couleur.B);
                GreenCibleChrono := GreenCibleChrono+integer(couleur.G);
              end;
         end;
         RedCibleChrono := RedCibleChrono div 9;
         BlueCibleChrono := BlueCibleChrono div 9;
         GreenCibleChrono := GreenCibleChrono div 9;
       finally
         BitmapCourant.Unmap(bitmapDataC);
       end;
     end;
     setBoutons;
end; // InitMesure

begin
     bitmapInit := Tbitmap.create;
     bitmapFin := Tbitmap.create;
     bitmapInit.assign(bitmapCourant);
     bitmapFin.assign(bitmapCourant);
     setBorne(bsChrono);
     initMesure;
     timerPlay.enabled := true;
end; // InitChronoPhoto

function TffmpegForm.getNomImage(index : single) : string;
var nomL : string;
      indexInt : integer;
begin
     result := '';
     if (index<TrackBar.Min) or (index>TrackBar.max) then exit;
     indexInt := round(index);
     nomL := system.SysUtils.format('test%3d.bmp',[indexInt]);
     result := System.IOUtils.Tpath.combine(supportPath,nomL);
end;

procedure TffmpegForm.HelpBtnClick(Sender: TObject);
begin
    openHelp('Video')
end;

procedure TffmpegForm.updateImage(nomImage : string);
begin
    bitmapCourant.loadFromFile(nomImage);
    if rotation<>0 then bitmapCourant.Rotate(rotation*90);
    imgPreview.Bitmap.Assign(bitmapCourant);
    case borneSelect of
       bsChrono : AffecteChrono;
       bsChronoInit : ;
       else dessine;
    end;
    NextBtn.Enabled := TrackBar.Value<TrackBar.Max;
    PreviousBtn.Enabled := TrackBar.Value>0;
end; // updateImage

end.

