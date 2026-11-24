unit OptiqueBitmap;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Actions, System.Math.vectors, System.UIConsts, System.IOUtils, System.iniFiles,

  FMX.Types, FMX.Controls, FMX.Forms,
  FMX.Dialogs, FMX.Objects, FMX.Layouts,
  FMX.Platform, FMX.clipBoard,
  FMX.StdCtrls, FMX.ActnList,
  FMX.Memo, FMX.ListBox,
  FMX.Graphics, FMX.Utils,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.EditBox, FMX.SpinBox,
  FMX.Colors,
  FMX.TMSFNCToolBar,
  FMX.TMSFNCBitmapContainer,
  maths,
  FMX.TMSFNCRadioGroup,

  grapheOptique, uniteker,

  FMX.TMSFNCTypes,
  FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics,
  FMX.TMSFNCGraphicsTypes,
  FMX.TMSFNCCustomControl;

type
  Taxe = (aX,aY,apX,apY);

  TOptiqueBitmapForm = class(TForm)
    OpenDialog: TOpenDialog;
    OpenBtn: TTMSFNCToolBarButton;
    RegressiBtn: TTMSFNCToolBarButton;
    PanelPreview: TPanel;
    Image: TImage;
    CouleurCB: TTMSFNCToolBarColorPicker;
    PanelParam: TPanel;
    EchelleGB: TGroupBox;
    CouleursGB: TGroupBox;
    EchelleRG: TComboBox;
    PanelCourbes: TPanel;
    IntensitePB: TPaintBox;
    RedBtn: TColorButton;
    GreenBtn: TColorButton;
    BlueBtn: TColorButton;
    LumBtn: TButton;
    MoyenneSE: TSpinBox;
    GammaSE: TSpinBox;
    StatusBar1: TStatusBar;
    largeurSE: TSpinBox;
    AideLabel: TLabel;
    UniteCB: TComboBox;
    EchelleEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    LongueurLabel: TLabel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label6: TLabel;
    LabelDeltax: TLabel;
    LabelX1: TLabel;
    LabelX2: TLabel;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label7: TLabel;
    HelpBtn: TTMSFNCToolBarButton;
    procedure OpenButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure RegressiBtnClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CouleurCBColorSelected(Sender: TObject; AColor: TTMSFNCGraphicsColor);
    procedure FormActivate(Sender: TObject);
    procedure PanelPreviewResize(Sender: TObject);
    procedure EchelleEditKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure IntensitePBPaint(Sender: TObject; Canvas: TCanvas);
    procedure IntensitePBMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure IntensitePBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure EchelleRGChange(Sender: TObject);
    procedure UniteCBChange(Sender: TObject);
    procedure LumBtnClick(Sender: TObject);
    procedure largeurSEChange(Sender: TObject);
    procedure MoyenneSEChange(Sender: TObject);
    procedure IntensitePBMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ImageMouseLeave(Sender: TObject);
    procedure IntensitePBMouseLeave(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    longueurRef,Gamma : double;
    PointRepere : TarrayPoint;
    e_PointRepere : TarrayPoint;
    BorneSelect : TstyleDragOptique;
    BorneX : TstyleDragX;
    largeur, hauteur : integer;  // bitmap
    LargeurAff,HauteurAff : integer; // Affichée
    pasZoom : single; // conversion xy(bitmap) vers xy(écran)
    couleurTrace : TAlphaColor;
    nomFichier : string;
    bitmapCourant : tBitmap;
    coeffUnite : double;
    axeI,axeE : Taxe;
    Pente,invCosa : double;
    grapheO : TgrapheOptique;
    debut,fin : integer;
    axeDesX : Tunite;
    magnetInterf : single;
    posDebut,posFin : single;
    procedure EcranVersImage;
    procedure SetCurseur(Acursor : Tcursor);
    procedure SetCurseurPB(Acursor : Tcursor);
    Function GetBorne(x,y : single) : TstyleDragOptique;
    Function GetBornePB(x,y : single) : TstyleDragX;
    procedure setBorne(aBorne : TStyleDragOptique);
    procedure setBornePB(aBorne : TStyleDragX);
    procedure setBoutons;
    procedure ImageVersEcran;
    procedure effectuerZoom;
    procedure setEchelle;
    procedure traceBorne;
    procedure calculIntensite;
    procedure cherchePente;
    procedure AffichePosition;
  public
  end;

var
  OptiqueBitmapForm: TOptiqueBitmapForm;

implementation

{$R *.fmx}

uses math, regutil, compile, valeurs, graphker, grapheVariabU, regmain, constreg;

const
    Titre = 'Optique';
    FormCaption = 'Lecture d''intensité lumineuse ';
    TickEchelle = 4;
    Magnet = 16;
    hintDrag : array[TstyleDragOptique] of string =
      ('',
       'Déplacer l''origine des mesures',
       'Modifier la direction de mesure',
       'Déplacer l''origine de l''échelle',
       'Déplacer l''extémité de l''échelle');

procedure TOptiqueBitmapForm.OpenButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then begin
    NomFichier := OpenDialog.FileName;
    setCurseur(crDefault);
    setCurseurPB(crDefault);
    pasZoom := 1;
    setBorne(bsNone);
    Caption := 'Lecture de '+extractFileName(NomFichier);
    bitmapCourant.LoadFromFile(NomFichier);
    largeur := bitmapCourant.Width;
    hauteur := bitmapCourant.Height;
    PointRepere[bsOrigine] := pointF(Largeur/2,Hauteur/2);
    PointRepere[bsDirection] := pointF(Largeur/3,Hauteur/2);
    PointRepere[bsEchelle1] := pointF(Largeur/4,3*Hauteur/4);
    PointRepere[bsEchelle2] := pointF(3*Largeur/4,3*Hauteur/4);
    EffectuerZoom;
    ImageVersEcran;
    traceBorne;
    calculIntensite;
    setBoutons;
  end;
end;

procedure TOptiqueBitmapForm.PanelPreviewResize(Sender: TObject);
begin
    effectuerZoom;
end;

procedure TOptiqueBitmapForm.RegressiBtnClick(Sender: TObject);

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

var i,i0 : integer;
    indexX,indexR,indexG,indexB,indexL : integer;
begin // SauveData
       indexX := ajoute('x','','');
       indexR := 0;indexB := 0;indexG := 0;indexL := 0;// pour le compilateur
       if echelleRG.itemIndex<2 then grandeurs[indexX].nomUnite := 'm';
       if echelleRG.itemIndex<2
          then grandeurs[indexX].fonct.expression := 'Distance'
          else grandeurs[indexX].fonct.expression := 'Numéro pixel';
       if blueBtn.isPressed then indexB := ajoute('B','','intensité bleue');
       if redBtn.isPressed then indexR := ajoute('R','','intensité rouge');
       if greenBtn.isPressed then indexG := ajoute('G','','intensité verte');
       if lumBtn.isPressed then indexL := ajoute('I','','intensité');
       ajoutePage;
       pages[pageCourante].nmes := fin-debut+1;
       for i := debut to fin do begin
           i0 := i-debut;
           pages[pageCourante].valeurVar[indexX,i0] := grapheO.valeurX[i];
           if blueBtn.isPressed then
              pages[pageCourante].valeurVar[indexB,i0] := grapheO.bleu[i];
           if redBtn.isPressed then
              pages[pageCourante].valeurVar[indexR,i0] := grapheO.rouge[i];
           if greenBtn.isPressed then
              pages[pageCourante].valeurVar[indexG,i0] := grapheO.vert[i];
           if lumBtn.isPressed then
              pages[pageCourante].valeurVar[indexL,i0] := grapheO.intensite[i];
       end;
       graphe.coordonnee[1].nomX := 'x';
       if lumBtn.isPressed then graphe.coordonnee[1].nomY := 'I'
       else if redBtn.isPressed then graphe.coordonnee[1].nomY := 'R'
       else if greenBtn.isPressed then graphe.coordonnee[1].nomY := 'G'
       else if blueBtn.isPressed then graphe.coordonnee[1].nomY := 'B'
       else graphe.coordonnee[1].nomY := 'I';
       graphe.coordonnee[1].Trace := [trLigne];
       graphe.coordonnee[1].Ligne := LiDroite;
       graphe.configCharge := true;
       graphe.useDefaut := false;
       NomFichierData := nomFichier;
       ModeAcquisition := AcqBitmap;
       FRegressiMain.WMRegMaj(MajFichier);
       ModifFichier := true;
       FRegressiMain.windowTab.ActiveTab := FRegressiMain.grapheTab;
  //     FValeurs.feuillets.ActiveTab := Fvaleurs.VariabSheet;
       Close;
end; // SauveData

procedure TOptiqueBitmapForm.FormActivate(Sender: TObject);
begin
    setBoutons;
end;

procedure TOptiqueBitmapForm.FormClose(Sender: TObject; var Action: TCloseAction);
var FichierIni : TInifile;
begin
     if pages[pageCourante].nmes=0 then FRegressiMain.FileNewSimulationItemClick(Sender);
     FichierIni := TIniFile.create(registreReg);
     FichierIni.writeInteger(Titre,'Largeur',round(LargeurSE.value));
     FichierIni.writeString(Titre,'Echelle',EchelleEdit.text);
     FichierIni.writeInteger(Titre,'Gamma',round(gamma*100));
     FichierIni.writeInteger(Titre,stUniteIni,uniteCB.itemIndex);
     FichierIni.writeInteger(Titre,'TypeEchelle',  echelleRG.itemIndex);
     FichierIni.writeInteger(Titre,'Moyenne',round(MoyenneSE.value));
     FichierIni.writeInteger(Titre,'FilterOpen', OpenDialog.filterIndex);
     FichierIni.free;
end;

procedure TOptiqueBitmapForm.FormCreate(Sender: TObject);
var i : TStyleDragOptique;
    FichierIni : TInifile;
begin
  LargeurAff := 640;
  HauteurAff := 480;
  Largeur := 640;
  Hauteur := 480;
  pasZoom := 1;
  bitmapCourant := tbitmap.Create;
  couleurTrace := couleurCB.SelectedColor;
  borneSelect := bsNone;
  for i := low(TstyleDragOptique) to High(TstyleDragOptique) do begin
        e_pointRepere[i].x := 0;
        e_pointRepere[i].y := 0;
  end;
  grapheO := TgrapheOptique.create;
  NomFichier := '';
  axeDesX := Tunite.Create;
  axeDesX.nom := 'x';
  axeDesX.nomUnite := 'm';
  lumBtn.isPressed := true;
  FichierIni := TIniFile.create(registreReg);
  LargeurSE.value := FichierIni.readInteger(Titre,'Largeur',2);
  EchelleEdit.text := FichierIni.readString(Titre,'Echelle','10');
  Gamma := FichierIni.readInteger(Titre,'Gamma',100)/100;
  GammaSE.value := gamma;
  uniteCB.itemIndex  := FichierIni.readInteger(Titre,stUniteIni,2);
  coeffUnite := power(10,-3*uniteCB.ItemIndex);
  echelleRG.itemIndex := FichierIni.readInteger(Titre,'TypeEchelle',0);
  setEchelle;
  MoyenneSE.value := FichierIni.readInteger(Titre,'Moyenne',3);
  OpenDialog.filterIndex := FichierIni.readInteger(Titre,'FilterOpen',0);
  FichierIni.free;
end;

procedure TOptiqueBitmapForm.FormDestroy(Sender: TObject);
begin
    bitmapCourant.free;
    grapheO.free;
    axeDesX.free;
end;

procedure TOptiqueBitmapForm.setBorne(aBorne : TStyleDragOptique);
begin
     borneSelect := aBorne;
     if BorneSelect=bsNone
         then setCurseur(crDefault)
         else setCurseur(crNone);
     aideLabel.Text := hintDrag[BorneSelect];
end;

procedure TOptiqueBitmapForm.setBornePB(aBorne : TStyleDragX);
begin
     borneX := aBorne;
     if BorneX=dxNone
         then setCurseurPB(crDefault)
         else setCurseurPB(crSizeWE);
end;

procedure TOptiqueBitmapForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    if nomFichier='' then exit;
    if borneSelect=bsNone then
       setBorne(GetBorne(x,y));
    e_pointRepere[BorneSelect].x := x;
    e_pointRepere[BorneSelect].y := y;
    ecranVersImage;
end;

procedure TOptiqueBitmapForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
var BS : TstyleDragOptique;
begin // MouseMove
  if nomFichier='' then exit;
  if borneSelect=bsNone
    then begin
       BS := GetBorne(x,y);
       if BS=bsNone
           then setCurseur(crDefault)
           else setCurseur(crSizeAll);
    end
    else begin
       e_pointRepere[BorneSelect].x := x;
       e_pointRepere[BorneSelect].y := y;
       ecranVersImage;
       traceBorne;
    end;
end;

procedure TOptiqueBitmapForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if nomFichier='' then exit;
  e_pointRepere[BorneSelect].x := x;
  e_pointRepere[BorneSelect].y := y;
  ecranVersImage;
  if BorneSelect<>bsNone then begin
      setBorne(bsNone);
      traceBorne;
      calculIntensite;
  end;
end;

procedure TOptiqueBitmapForm.UniteCBChange(Sender: TObject);
begin
     if echelleRG.itemIndex<2
        then coeffUnite := power(10,-3*uniteCB.ItemIndex)
        else coeffUnite := 1;
     CalculIntensite;
     if echelleRG.itemIndex<2
        then axeDesX.nomUnite := uniteCB.Items[uniteCB.itemIndex]
        else axeDesX.nomUnite := ''
end;

procedure TOptiqueBitmapForm.ImageVersEcran;
var i : TstyleDragOptique;
begin
    for i := low(TstyleDragOptique) to High(TstyleDragOptique) do
        e_pointRepere[i] := pointRepere[i]*pasZoom;
end;

procedure TOptiqueBitmapForm.ImageMouseLeave(Sender: TObject);
begin
    if BorneSelect<>bsNone then begin
       setBorne(bsNone);
       traceBorne;
       calculIntensite;
    end;
end;

procedure TOptiqueBitmapForm.IntensitePBMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
    if nomFichier='' then exit;
    if borneX=dxNone then
       setBornePB(GetBornePB(x,y));
    if borneX<>dxNone then begin
       grapheO.e_pointX[BorneX] := x;
       intensitePB.repaint
    end;
end;

procedure TOptiqueBitmapForm.IntensitePBMouseLeave(Sender: TObject);
begin
    setBornePB(dxNone);
end;

procedure TOptiqueBitmapForm.IntensitePBMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
var BS : TstyleDragX;
    oldX : single;
begin
    if nomFichier='' then exit;
    if borneX=dxNone then begin
       BS := GetBornePB(x,y);
       if BS=dxNone
          then setCurseurPB(crDefault)
          else setCurseurPB(crSizeWE);
    end
    else begin
       oldX := grapheO.e_PointX[borneX];
       grapheO.e_PointX[borneX] := x;
       if abs(oldX-x)>8 then intensitePB.Repaint;
    end;
end;

procedure TOptiqueBitmapForm.IntensitePBMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if nomFichier='' then exit;
  grapheO.e_pointX[BorneX] := x;
  if BorneX<>dxNone then begin
      setBornePB(dxNone);
      intensitePB.repaint;
      affichePosition;
  end;
end;

procedure TOptiqueBitmapForm.IntensitePBPaint(Sender: TObject; Canvas: TCanvas);
begin
        if (debut=fin) then exit;
        grapheO.LPaintBox := IntensitePB;
        grapheO.wR := RedBtn.isPressed;
        grapheO.wG := GreenBtn.isPressed;
        grapheO.wB := BlueBtn.isPressed;
        grapheO.wL := LumBtn.isPressed;
        grapheO.LimiteCourbe := rectF(posDebut*pasZoom,0,posFin*pasZoom,IntensitePB.height);
        grapheO.drawG;
end;

procedure TOptiqueBitmapForm.largeurSEChange(Sender: TObject);
begin
    traceBorne;
end;

procedure TOptiqueBitmapForm.LumBtnClick(Sender: TObject);
begin
    IntensitePB.Repaint;
end;

procedure TOptiqueBitmapForm.MoyenneSEChange(Sender: TObject);
begin
    calculIntensite;
end;

procedure TOptiqueBitmapForm.EchelleEditKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if not CharInSet(keyChar,['0'..'9','.',',',
                     crSupprArr,crCR,crTab,crGauche,crDroite]) then keyChar := #0
end;

procedure TOptiqueBitmapForm.EchelleRGChange(Sender: TObject);
begin
   setEchelle;
   traceBorne;
   calculIntensite;
end;

procedure TOptiqueBitmapForm.EcranVersImage;
var i : TstyleDragOptique;
begin
   for i := low(TstyleDragOptique) to High(TstyleDragOptique) do
         pointRepere[i] := e_pointRepere[i]/pasZoom;
end;

procedure TOptiqueBitmapForm.CouleurCBColorSelected(Sender: TObject;
  AColor: TTMSFNCGraphicsColor);
begin
  couleurTrace := Acolor;
  traceBorne;
end;

procedure TOptiqueBitmapForm.SetCurseur(Acursor : Tcursor);
begin
    image.Cursor := aCursor;
end;

procedure TOptiqueBitmapForm.SetCurseurPB(Acursor : Tcursor);
begin
    intensitePB.Cursor := aCursor;
end;

Function TOptiqueBitmapForm.GetBorne(x,y : single) : TstyleDragOptique;
var i,imax : TstyleDragOptique;
    aPoint : TPointF;
begin
    result := bsNone;
    aPoint := PointF(x,y);
    if echelleRG.itemIndex=0
         then imax := bsEchelle2
         else imax := bsDirection;
    for i := bsOrigine to imax do
        if e_PointRepere[i].distance(aPoint) < Magnet
              then begin
                 result := i;
                 exit;
              end;
end;

procedure TOptiqueBitmapForm.cherchePente;
var penteE : double;
begin
  if (PointRepere[bsOrigine].x=PointRepere[bsDirection].x)
        then begin
           axeI := aY;
           pente := 0;
           invCosA := 1;
        end
        else if (PointRepere[bsOrigine].y=PointRepere[bsDirection].y)
           then begin
              axeI := aX;
              pente := 0;
              invCosA := 1;
           end
           else begin
              pente := (PointRepere[bsOrigine].y-PointRepere[bsdirection].y)/
                       (PointRepere[bsOrigine].x-PointRepere[bsdirection].x);
              if abs(pente)<=1
                 then begin
                    axeI := apX;
                    invcosa := sqrt(1+sqr(pente));
                 end
                 else begin
                    axeI := apY;
                    invcosa := sqrt(1+sqr(1/pente));
                 end;
           end;
  if (PointRepere[bsEchelle1].x=PointRepere[bsEchelle2].x)
        then axeE := aY
        else if (PointRepere[bsEchelle1].y=PointRepere[bsEchelle2].y)
           then axeE := aX
           else begin
              penteE := (PointRepere[bsOrigine].y-PointRepere[bsdirection].y)/
                        (PointRepere[bsOrigine].x-PointRepere[bsdirection].x);
              if abs(penteE)<=1
                 then axeE := apX
                 else axeE := apY;
           end;
end;


Function TOptiqueBitmapForm.GetBornePB(x,y : single) : TstyleDragX;
var i : TstyleDragX;
begin
    result := dxNone;
    for i := dx1 to dx2 do
        if abs(grapheO.e_PointX[i]-x) < Magnet
              then begin
                 result := i;
                 exit;
              end;
end;

procedure TOptiqueBitmapForm.HelpBtnClick(Sender: TObject);
begin
    openHelp('Interferences')
end;

procedure TOptiqueBitmapForm.EffectuerZoom;
var zoomX,zoomY,zoom : single;
begin
    if (nomFichier='') then exit;
    zoomX := panelPreview.width / largeur;
    zoomY := panelPreview.height / hauteur;
    if zoomX>zoomY then zoom := zoomY else zoom := zoomX;
    if zoom>1 then pasZoom := floor(zoom) else pasZoom := zoom;
    hauteurAff := round(hauteur*pasZoom);
    largeurAff := round(largeur*pasZoom);
    Image.Height := hauteurAff;
    Image.Width := largeurAff;
    magnetInterf := magnet/pasZoom;
    imageVersEcran;
end;

procedure TOptiqueBitmapForm.setBoutons;
var OK : boolean;
begin
    OK := (nomFichier<>'');
    RegressiBtn.enabled := OK;
    if (borneSelect=bsNone) then setCurseur(crDefault);
    if (borneX=dxNone) then setCurseurPB(crDefault);
end; // setBoutons

Procedure TOptiqueBitmapForm.SetEchelle;
var EchelleEnPixel : single;
    longueurEchelle : single;
begin
       if PointRepere[bsEchelle2].y<0 then
            PointRepere[bsEchelle2].y := 0;
       if PointRepere[bsEchelle2].y>hauteur then
            PointRepere[bsEchelle2].y := hauteur;
       if PointRepere[bsEchelle1].x>largeur then
            PointRepere[bsEchelle1].x := largeur;
       if PointRepere[bsEchelle1].x<0 then
            PointRepere[bsEchelle1].x := 0;
       echelleEnPixel := PointRepere[bsEchelle1].distance(PointRepere[bsechelle2]);
       try
           LongueurEchelle := StrToFloatWin(EchelleEdit.text);
       except
           showMessage('Erreur lors de la lecture de l''échelle');
           EchelleEdit.text := '1.0';
           EchelleEdit.SetFocus;
           longueurEchelle := 1;
       end;
       try
       except
          showMessage('Erreur lors de la lecture de l''échelle');
       end;
       pente := LongueurEchelle/EchelleEnPixel;
end;

Procedure TOptiqueBitmapForm.CalculIntensite;
var dimPix : double;
    origineX,origineY : single;
    moyenneI : integer;

Procedure chercheEchelle;
var NbrePixelEchelle : double;
begin
   OrigineX := PointRepere[bsOrigine].x;
   OrigineY := PointRepere[bsOrigine].y;
   case echelleRG.itemIndex of
        1 : begin
           dimPix := LongueurRef;
           longueurLabel.Text := 'Dimension d''un pixel';
           axeDesX.nomUnite := uniteCB.Items[uniteCB.itemIndex];
        end;
        0 : begin
          longueurLabel.Text := 'Longueur de l''échelle';
          NbrePixelEchelle := sqrt(
             sqr(PointRepere[bsEchelle1].x-PointRepere[bsEchelle2].x)+
             sqr(PointRepere[bsEchelle1].y-PointRepere[bsechelle2].y));
          dimPix := LongueurRef/NbrePixelEchelle;
          axeDesX.nomUnite := uniteCB.Items[uniteCB.itemIndex];
          case axeI of
             aX : OrigineX := PointRepere[bsEchelle1].x;
             aY : OrigineY := PointRepere[bsEchelle1].y;
             else begin
                OrigineX := round((pente*(PointRepere[bsEchelle1].y-PointRepere[bsOrigine].y)+
                             sqr(pente)*PointRepere[bsOrigine].x+
                             PointRepere[bsEchelle1].x)/(1+sqr(pente)));
                OrigineY := round((pente*(PointRepere[bsEchelle1].x-PointRepere[bsOrigine].x)+
                             sqr(pente)*PointRepere[bsEchelle1].y+
                             PointRepere[bsOrigine].y)/(1+sqr(pente)));
             end;
          end;
        end;
        else begin
           dimPix := 1;
           axeDesX.nomUnite := '';
        end;
   end;
   case axeI of
      aX,apX : begin
           debut := round(-OrigineX);
           fin := round(largeur-OrigineX);
           dimPix := dimPix*invCosA;
      end;
      aY,apY : begin
           debut := round(-OrigineY);
           fin := round(hauteur-OrigineY);
           dimPix := dimPix*invCosA;
      end;
   end;
   debut := debut+moyenneI;
   fin := fin-moyenneI;
   if debut<-maxVecteurOptique then debut := -maxVecteurOptique;
   if fin>maxVecteurOptique then fin := maxVecteurOptique;
   grapheO.dimPix := dimPix;
end; // chercheEchelle

Procedure cherche(decale : integer); // sur l'image grâce au stretch
var i : integer;
    xi,yi : single;
    xx,yy : integer;
    x0,y0 : single;
    currentData : TBitmapData;
    couleur : TAlphaColorRec;

function LuminanceXY : double;
begin
    result := (0.299*couleur.R+0.587*couleur.G+0.114*couleur.B)/255;
end;

begin
     x0 := origineX;
     y0 := origineY;
     case axeI of
        aX,apX : y0 := origineY+decale;
        aY,apY : x0 := origineX+decale;
     end;
     xi := x0;yi := y0; // pour le compilateur
     if BitmapCourant.Map(TMapAccess.Read, CurrentData) then begin
     try
     for i := debut to fin do begin
         case axeI of
            aX,apX : begin
                 xi := x0+i;
                 yi := y0+i*pente;
            end;
            aY,apY : begin
                 yi := y0+i;
                 if pente<>0 then xi := x0+i/pente;
            end;
         end;
         xx := round(xi);
         yy := round(yi);
         if (xx>=0) and (xx<largeur) and
            (yy>=0) and (yy<hauteur) then begin
               couleur.color := CurrentData.getPixel(xx,yy);
               grapheO.rouge[i] := grapheO.rouge[i]+Couleur.R;
               grapheO.bleu[i] := grapheO.bleu[i]+Couleur.B;
               grapheO.vert[i] := grapheO.vert[i]+couleur.G;
               grapheO.intensite[i] := grapheO.intensite[i]+LuminanceXY;
            end
            else begin
               grapheO.intensite[i] := 0;
               grapheO.rouge[i] := 0;
               grapheO.bleu[i] := 0;
               grapheO.vert[i] := 0;
            end;
         if decale=0 then grapheO.valeurX[i] := dimPix*i;
     end; // for i
     finally
        BitmapCourant.Unmap(CurrentData);
     end;
     end;
end; // cherche

procedure getEchelle;
begin
     gamma := gammaSE.value;
     if echelleRG.itemIndex=2 then begin // index
        longueurRef := 1;
        coeffUnite := 1;
        exit;
     end;
     try
     longueurRef := StrToFloatWin(EchelleEdit.text)*coeffUnite;
     except
         showMessage('Erreur échelle');
         EchelleEdit.Text := '10';
         longueurRef := coeffUnite;
     end;
     setEchelle;
end; // getEchelle

var i,Nbre : integer;
    intensiteMax : single;
begin // CalculIntensite
     if nomFichier='' then exit;
     panelCourbes.cursor := crHourGlass;
     panelParam.cursor := crHourGlass;
     panelParam.Enabled := false;
     moyenneI := round(moyenneSE.value);
     getEchelle;
     for i := -maxVecteurOptique to maxVecteurOptique do begin
         grapheO.Intensite[i] := 0;
         grapheO.vert[i] := 0;
         grapheO.bleu[i] := 0;
         grapheO.rouge[i] := 0;
     end;
     cherchePente;
     chercheEchelle;
     cherche(0);
     for i := 1 to moyenneI do begin
        cherche(i);
        cherche(-i);
     end;
     Nbre := 1+2*moyenneI;
     while (debut<0) and (grapheO.intensite[debut]=0) do inc(debut);
     while (fin>0) and (grapheO.intensite[fin]=0) do dec(fin);
     grapheO.debutG := debut;
     grapheO.finG := fin;
     case axeI of
            aX,apX : begin
                 posDebut := origineX+debut;
                 posFin := origineX+fin;
            end;
            aY,apY : begin
                 if pente<>0 then begin
                    posDebut := origineX + debut/pente;
                    posFin := origineX + fin/pente;
                 end
                 else begin
                    posDebut := 0;
                    posFin := largeur;
                 end;
            end;
     end;
     IntensiteMax := 0;
     for i := Debut to Fin do begin
         grapheO.Intensite[i] := power(grapheO.Intensite[i]/nbre,gamma);
         if grapheO.Intensite[i]>intensiteMax then
            intensiteMax := grapheO.Intensite[i];
         grapheO.rouge[i] := power(grapheO.rouge[i]/255/Nbre,gamma);
         grapheO.vert[i] := power(grapheO.vert[i]/255/Nbre,gamma);
         grapheO.bleu[i] := power(grapheO.bleu[i]/255/Nbre,gamma);
     end;
     if intensiteMax>0 then
        for i := Debut to Fin do
            grapheO.Intensite[i] := grapheO.Intensite[i]/intensiteMax;
     intensitePB.repaint;
     affichePosition;
     panelParam.Enabled := true;
     panelCourbes.cursor := crDefault;
     panelParam.cursor := crDefault;
end; // CalculIntensite

Procedure TOptiqueBitmapForm.TraceBorne;
var imageCanvas : TCanvas;

procedure TraceFleche(P1,P2: TpointF);
var
   dx,dy: single;
   Points:  TPolygon;
   d : single;
begin // P2 = extrémité de la flèche ; P1-P2 = direction
      dx := P2.X-P1.X;
      dy := P2.y-P1.y;
      d := sqrt(sqr(dX) + sqr(dY));
      if d=0 then exit;
      d := Magnet/d;
      dX := round(d * dX);
      dY := round(d * dY);
      SetLength(Points, 3);
      Points[0] := P2;
      Points[1] := TPointF.create(P2.x - dX - (dY/3), P2.Y - dY + (dX/3));
      Points[2] := TPointF.create(P2.x - dX + (dY/3), P2.y - dY - (dX/3));
      imageCanvas.DrawPolygon(Points,1); // triangle 3 points
end;

Procedure TraceCroix(bsi : TstyleDragOptique);
begin with PointRepere[bsi],imageCanvas do begin
       if bsi=bsEchelle1
          then drawLine(TpointF.Create(x-MagnetInterf,y),
                        TpointF.Create(x,y),1)
          else drawLine(TpointF.Create(x-MagnetInterf,y),
                        TpointF.Create(x+Magnet,y),1);
       imageCanvas.drawLine(TpointF.Create(x,y-MagnetInterf),
                            TpointF.Create(x,y+MagnetInterf),1);
end end;

Procedure TraceEchelle;
var deltaX,deltaY : single;

Procedure TraceTick(i : integer);
var Kp : single;
    Xa,Ya,Xb,Yb : single;
    xx,yy : single;
begin
      if pasZoom>1
         then imageCanvas.stroke.thickness := 1/pasZoom
         else imageCanvas.stroke.thickness := pasZoom;
      xx := PointRepere[bsEchelle1].x+deltaX*i;
      yy := PointRepere[bsEchelle1].y+deltaY*i;
      if abs(deltaX)>abs(deltaY)
         then begin
              Ya := yy+tickEchelle;
              Yb := yy-tickEchelle;
              Kp := -tickEchelle*deltaY/deltaX;
              Xa := xx+Kp;
              Xb := xx-Kp;
         end
         else begin
              Xa := xx+tickEchelle;
              Xb := xx-tickEchelle;
              Kp := -tickEchelle*deltaX/deltaY;
              Ya := yy+Kp;
              Yb := yy-Kp;
         end;
    imageCanvas.drawLine(TpointF.Create(Xa,Ya),TpointF.Create(Xb,Yb),1);
end;// traceTick

var i : integer;
begin // traceEchelle
          TraceCroix(bsEchelle1);
          TraceCroix(bsEchelle2);
          traceFleche(pointRepere[bsEchelle1],pointRepere[bsEchelle2]);
          deltaX := (PointRepere[bsEchelle2].x-PointRepere[bsEchelle1].x)/10;
          deltaY := (PointRepere[bsEchelle2].y-PointRepere[bsEchelle1].y)/10;
          imageCanvas.drawLine(PointRepere[bsEchelle1],PointRepere[bsEchelle2],1);
          for i := 1 to 9 do TraceTick(i);
end; // traceEchelle

var p : single;
    xdroit,ydroit,xgauche,ygauche : single;
    decaleX,decaleY : single;
    moyenneI : integer;
begin // traceBorne
if nomFichier<>'' then begin
       longueurLabel.Visible := echelleRG.ItemIndex<2;
       echelleEdit.Visible := echelleRG.ItemIndex<2;
       Image.Bitmap.Assign(bitmapCourant);
       imageCanvas := Image.bitmap.Canvas;
       ImageCanvas.BeginScene;
       imageCanvas.stroke.color := couleurTrace;
       imageCanvas.stroke.thickness := LargeurSE.value/pasZoom;
       TraceCroix(bsDirection);
       with PointRepere[bsOrigine] do
            imageCanvas.DrawEllipse(TRectF.create(x-MagnetInterf,y-MagnetInterf,x+MagnetInterf,y+MagnetInterf),1);
       cherchePente;
       case axeI of
          aY : begin
               xdroit := PointRepere[bsOrigine].x;
               xgauche := xdroit;
               ydroit := 0;
               ygauche := hauteur;
          end;
          aX : begin
               ydroit := PointRepere[bsOrigine].y;
               ygauche := ydroit;
               xdroit := 0;
               xgauche := largeur;
          end;
          apX,apY : begin
               p := (PointRepere[bsOrigine].y-PointRepere[bsDirection].y)/
                    (PointRepere[bsOrigine].x-PointRepere[bsDirection].x);
               // intersection xmax
               xdroit := largeur;
               ydroit := round(p*(xdroit-PointRepere[bsOrigine].x)+PointRepere[bsOrigine].y);
               if (pente>0) and (ydroit>hauteur) then  begin
                   ydroit := hauteur;
                   xdroit := round((ydroit-PointRepere[bsOrigine].y)/p+PointRepere[bsOrigine].x);
               end;
               if (pente<0) and (ydroit<0) then  begin
                   xdroit := round((0-PointRepere[bsOrigine].y)/p+PointRepere[bsOrigine].x);
                   ydroit := 0;
               end;
               // intersection xmin
               xgauche := 0;
               ygauche := round(p*(0-PointRepere[bsOrigine].x)+PointRepere[bsOrigine].y);
               if (pente<0) and (ygauche>hauteur) then  begin
                  ygauche := hauteur;
                  xgauche := round((ygauche-PointRepere[bsOrigine].y)/p+PointRepere[bsOrigine].x);
               end;
               if (pente>0) and (ygauche<0) then  begin
                  xgauche := round((0-PointRepere[bsOrigine].y)/p+PointRepere[bsOrigine].x);
                  ygauche := 0;
               end;
          end
          else begin
               ydroit := hauteur;
               ygauche := 0;
               xdroit := 0;
               xgauche := largeur;
          end;
       end;
       imageCanvas.stroke.thickness := LargeurSE.value/pasZoom;
       imageCanvas.drawLine(TpointF.Create(xdroit,ydroit),
                            TpointF.Create(xgauche,ygauche),1);
       moyenneI := round(moyenneSE.value);
       if moyenneI>1 then begin
            decaleX := 0;
            decaleY := 0;
            case axeI of
               aX,apX: decaleY := moyenneI*invCosA;
               aY,apY: decaleX := moyenneI*invCosa;
            end;
            imageCanvas.drawLine(TpointF.Create(PointRepere[bsOrigine].x+decaleX,PointRepere[bsOrigine].y+decaleY),
                                 TpointF.Create(PointRepere[bsOrigine].x-decaleX,PointRepere[bsOrigine].y-decaleY),1);
       end;
       if echelleRG.itemIndex=0 then traceEchelle;
       ImageCanvas.EndScene;
end end;  // traceBorne

procedure TOptiqueBitmapForm.AffichePosition;
var xr1,xr2 : single;
begin
      grapheO.ecranVersPB;
      xr1 := grapheO.x1/coeffUnite;
      xr2 := grapheO.x2/coeffUnite;
      labelX1.text := '1 : '+axeDesX.formatNomEtUnite(Xr1);
      labelX2.text := '2 : '+axeDesX.formatNomEtUnite(Xr2);
      labelDeltaX.text := deltaMaj+axeDesX.formatNomEtUnite(xr2-xr1);
end;

end.

