unit regutil;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.UIConsts,
  System.Math,
  System.StrUtils,
  System.Generics.Collections,
  System.Character,
  System.Actions,
  System.IOUtils,
  System.IniFiles,

  FMX.Types,
  FMX.Utils,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.Printer,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.TreeView,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Text,
  FMX.Platform,
  FMX.TextLayout,
  FMX.StdCtrls,
  FMX.ActnList,
  FMX.Graphics,
  FMX.DialogService,

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

{$IFDEF MACOS}
  Macapi.ObjectiveC,
  Macapi.CoreFoundation,
  Macapi.CocoaTypes,
  Macapi.AppKit,
  Macapi.CoreGraphics,
  Macapi.Foundation,
{$ENDIF}

{$IFDEF POSIX}
   Posix.Stdlib,
{$ENDIF POSIX}

{$IFDEF MSWINDOWS}
   Winapi.ShellApi,
   Winapi.ShlObj,
   Winapi.Windows,
{$ENDIF}

  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,

  constreg,
  maths;

var
  finFichierWin : boolean;
  ligneWin : string;
  DocumentsPath,homePath,supportPath,cachePath,tempPath,exemplesPath,applicationPath : string;
  HelpFile,HelpHtml,HelpPath : string;
  ModifFichier : boolean;
  ImprimanteDisponible : boolean;
  nbreParamAnimation : integer;

const
        MaxParamAnimation = 5;
        MaxPasAnimation = 8192;
        longNombre = 10;
        MargeImprimante = 21;
        MargeImprimantePaysage = 30; // soit 1 cm
        PrecisionMin = 3;
        PrecisionMax = 15; // Precision double pour FloatToStrF
        PrecisionFichier = 15; // double
        SymbReg : Char = '£';
        SymbReg2 : Char = '&';
        UnJour = 24*3600;
        UneHeure = 3600;
        QuartdHeure = 15*60;
        UneMinute = 60;
        UneHeureWin = 1/24; { 1 jour = 1.000 }
        QuartdHeureWin = 1/(24*4);
        UneMinuteWin = 1/(24*60);
        UneSecondeWin = 1/(24*60*60);
        {$IFDEF MacOS}
  //      FonteRegressi = 'Heletica Neue';
        {$ELSE}
 //       FonteRegressi = 'Segoe UI';
        {$ENDIF}
        MajModele = 0; { modification de l'expresssion du modèle }
        MajGrandeur = 1; { modification de l'expression des grandeurs }
        MajValeur = 2;{ modification des valeurs expérimentales dans tableur }
        MajFichier = 3; { général après chargement de fichier ... }
        MajChangePage = 4; { changement de page }
        MajAjoutPage = 5; { ajout de page }
        MajSupprPage = 6; { suppression de page }
        MajVide = 7; { nettoyage }
        MajFFT = 8; { options Fenêtre et période }
        MajTri = 9; { modif de l'ordre }
        MajIncertitude = 10;
        MajUnites = 11;
        MajValeurAcq = 12;{ modification des valeurs expérimentales par acquisition }
        MajUnitesParam = 13;
        MajSupprPoints = 14;
        MajNom = 15; { Modif d'un nom }
        MajAjoutValeur = 16; { ajout d'un point en mode clavier }
        MajSelectPage = 17; { changement de sélection des pages }
        MajValeurGr = 18;{ modification des valeurs expérimentales dans le graphe }
        MajSauvePage = 19; { avant de changer de page }
        MajValeurConst = 20;{ modification des valeurs des paramètres dans tableur }

        alphaR =  AnsiChar(128);
        betaRW3 = AnsiChar(129); betaR = ANSIChar(129);
        chiR = AnsiChar(130);
        deltaR = AnsiChar(131); deltaMajR = AnsiChar(150);
        epsilonR = AnsiChar(132);
        phiR = AnsiChar(133); phiMajR = AnsiChar(151);
        gammaR = AnsiChar(134); gammaMajR = AnsiChar(152);
        etaR = AnsiChar(135);
        lambdaR = AnsiChar(136); lambdaMajR = AnsiChar(153);
        nuR = AnsiChar(138);
        piR = AnsiChar(139);piMajR = AnsiChar(154);
        thetaR = AnsiChar(140);thetaMajR = AnsiChar(155);
        rhoRW3 = AnsiChar(141); rhoR = AnsiChar(151);
        sigmaR = AnsiChar(142);sigmaMajR = AnsiChar(156);
        tauRW3 = AnsiChar(143);tauR = AnsiChar(154);
        omegaRW3 = AnsiChar(144);omegaMajRW3 = AnsiChar(157);
        omegaR = AnsiChar(158);omegaMajR = AnsiChar(155);
        xiR = AnsiChar(147);xiMajR = AnsiChar(158);
        psiR = AnsiChar(148);psiMajR = AnsiChar(159);
        zetaR = AnsiChar(149);
        muR = AnsiChar(181);

        MoinsExpR = AnsiChar(170); // idem pour Regressi fontes
        PlusExpR = AnsiChar(184);
        infEgalR = AnsiChar(250);
        supEgalR = AnsiChar(249);

        ChiffreExpR : array[0..9] of ansiChar =
  (AnsiChar(186),AnsiChar(185),AnsiChar(178),AnsiChar(179),
   AnsiChar(165),AnsiChar(169),AnsiChar(172),AnsiChar(173),
   AnsiChar(174),AnsiChar(188));

        alphaMin=Char($03B1);alphaMaj=Char($0391);
        betaMin=Char($03B2);betaMaj=Char($0392);
        gammaMin=Char($03B3);gammaMaj=Char($0393);
        deltaMin=Char($03B4);deltaMaj=Char($0394);
        chiMin=WideChar($03C7);chiMaj=Char($03A7);
        epsilonMin=Char($03B5);epsilonMaj=Char($0395);
        upsilonMin=Char($03C5);upsilonMaj=Char($03A5);
        iotaMin=Char($03B9);iotaMaj=Char($0399);
        phiMin=Char($03C6);phiMaj=Char($03A6);
        etaMin=Char($03B7);etaMaj=Char($0397);
        lambdaMin=Char($03BB);lambdaMaj=Char($039B);
        nuMin=Char($03BD);nuMaj=Char($039D);
        xiMin=Char($03BE);xiMaj=Char($039E);
        piMin=Char($03C0);piMaj=Char($03A0);
        thetaMin=Char($03B8);thetaMaj=Char($0398);
        rhoMin=Char($03C1);rhomaj=Char($03A1);
        sigmaMin=Char($03C3);sigmaMaj=Char($03A3);
        tauMin=Char($03C4); tauMaj=Char($03A4);
        omegaMin=Char($03C9);omegaMaj=Char($03A9);
        psiMin=Char($03C8);psiMaj=Char($03A8);
        zetaMin=Char($03B6);zetaMaj=Char($0396);
        muMin=Char($03BC);muMaj=Char($039C);
        kappaMin=Char($03BA);kappaMaj=Char($039A);
        omicronMin=Char($03Bf);omicronMaj=Char($039F);
        pourMille=Char(8240);cdot=Char($22C5);
        pointMedian=Char($00B7);puce=Char($2219);
        SymboleAngstrom=Char($00C5);


        ChiffreExp : array[0..9] of wideChar =
  (WideChar($2070),WideChar($00B9),WideChar($00B2),WideChar($00B3),
   WideChar($2074),WideChar($2075),WideChar($2076),WideChar($2077),
   WideChar($2078),WideChar($2079));
        ChiffreExpStr = WideChar($2070)+WideChar($00B9)+WideChar($00B2)+
               WideChar($00B3)+WideChar($2074)+WideChar($2075)+WideChar($2076)+
               WideChar($2077)+WideChar($2078)+WideChar($2079);

       MoinsExp = Char($207B);
       PlusExp = Char($207A);
       supEgal = Char($2265);
       infEgal = Char($2264);

       RepereConst = 'Cte:';
       SeparateurConst =  '________________';
       LettreAccent = 'éèêëàâùïüô';

type
    TLanguagePstCirc = (fr,en);
 //   TstyleDrag = (bsNone,bsMesure,bsOrigine,bsEchelle1,bsEchelle2);
    EGetFloatError = class(Exception);
    EIncertitudeError = class(Exception);
    EWaveError = class(Exception);
    TnombreFormat = (fDefaut,fExponent,fFixed,
          fLongueDuree,fDateTime,fDate,fTime,fDegreMinute,
          fBinary,fHexa);
    TligneRappel = (lrXdeY,lrReticule,lrX,lrY,lrPente,lrEquivalence,lrTangente);
    TsetLigneRappel = set of TligneRappel;
    Tgraduation = (gLin,gLog,gdB);

    TstrListe = class(TstringList)
         public
             function MyIndexOf(Item : string) : Integer;
    end;

    TPrinterRecord = record
        Cur: TPointF;
        MargeTexte : single;
        Finish: TPointF;  // End of the printable area
        HeightLine: single; // Height of the current line
    end;

    CoefUnite = (zero,yocto,zepto,atto,femto,pico,nano,micro,milli,
               nulle,kilo,mega,giga,tera,peta,exa,zetta,yotta,infini);
    TmodeAcquisition = (AcqClavier,AcqFichier,AcqClipBoard,AcqBitMap,
                        AcqSon,AcqSimulation,AcqVideo,AcqArduino,
                        AcqChrono,AcqCourbes,AcqCan);

{$IFDEF MACOS}
  TOpenFileEvent = reference to procedure (const AFileName: string);
{$ENDIF}

 TToolTipPanel = class(TPanel)
  private
    FMousePoint : TPointF ;
    FCounter : Cardinal;
    FActiveControl : TFmxObject ;
    FLabel : TLabel;
    FTimer : TTimer;
    FBorderWidth : Single;
    procedure OnTimer(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    property BorderWidth : Single read FBorderWidth write FBorderWidth;
  end;

  TparamAnimation = class
           groupBoxA : TgroupBox;
           sliderA : TtrackBar;
           nomA : string;
           codeA : integer;
           ValeurA,DebutA,FinA,PasA : double;
           Active,VariationLog,Ainitialiser : boolean;
           constructor create;
           procedure init;
           procedure litXML(ANode : IXMLNOde);
           procedure ecritXML(ANode : IXMLNOde);
  end;

const
        couleurCalc = claGray;
        crSupprArr = char(vkBack);
        crHaut = char(vkUp);
        crBas = char(vkDown);
        crGauche = char(vkLeft);
        crDroite = char(vkRight);
        crHome = char(vkHome);
        crEnd = char(vkEnd);
        crCR = #13;
        crLF = #10;
        crESC = #27;
        crTab = char(vkTab);
        ValidCharsGrid = '+-*/Ee0123456789,.mMnpGk°''"';
        Separateur : tSysCharSet = [' ',crTab,',',';'];
        NomModeAcq : array[TmodeAcquisition] of string =
            ('CLAVIER','FICHIER','PRESSE-PAPIER','BITMAP','WAV','SIMULATION','VIDEO','ARDUINO',
             'CHRONOPHOTO','COURBES','EXTERNE');
        Majuscule   : tSysCharSet = ['A'..'Z'];
        Minuscule   : tSysCharSet = ['a'..'z'];
        Grecque = alphaMin+betaMin+gammaMin+gammaMaj+deltaMin+deltaMaj+
              epsilonMin+chiMin+zetaMin+etaMin+thetaMin+thetaMaj+kappaMin+
              lambdaMin+lambdaMaj+muMin+nuMin+xiMin+xiMaj+
              piMin+piMaj+rhoMin+sigmaMin+sigmaMaj+tauMin+
              phiMin+phiMaj+chiMin+psiMin+psiMaj+omegaMin+omegaMaj;

        ChiffreEtc : tSysCharSet = ['0'..'9','+','-','e','E','.',','];
        CaracNombre : tSysCharSet = ['0'..'9','+','-','e','E','.',',','/',':'];
        CaracDateTime : tSysCharSet = ['0'..'9','/',':',' '];
        CharGetFloat : tSysCharSet = ['0'..'9','+','-','e','E','.',',','*','/','^',
            'P','p','I','i',piMin,piMaj,'m','µ','n','f','k','M','G','T',
            '(',')',crSupprArr,crTab,crCR];
        ChiffrePuiss = WideChar($2070)+WideChar($00B9)+WideChar($00B2)+
               WideChar($00B3)+WideChar($2074)+WideChar($2075)+WideChar($2076)+
               WideChar($2077)+WideChar($2078)+WideChar($2079)+MoinsExp+PlusExp;

        NChiffreSignif = 5;
        caracPrefixe : tSysCharSet = ['y','z','a','f','p','n','µ','m','k','M','G','T','P','E','Z','Y'];
        prefixeUnite : array[coefUnite] of char =
              ('0','y','z','a','f','p','n','µ','m',
               ' ','k','M','G','T','P','E','Z','Y','ì');
        valUnite : array[coefUnite] of double =
              (1E-27,1E-24,1E-21,1E-18,1E-15,1E-12,1E-9,1E-6,1E-3,
               1,1E+3,1E+6,1E+9,1E+12,1E+15,1E+18,1E+21,1E+24,1E+27);
        expUnite : array[coefUnite] of string =
              ('E-27','E-24','E-21','E-18','E-15','E-12','E-9','E-6','E-3',
                '','E+3','E+6','E+9','E+12','E+15','E+18','E+21','E+24','E+27');
        puissanceUnite : array[coefUnite] of integer =
              (-27,-24,-21,-18,-15,-12,-9,-6,-3,
                0,+3,+6,+9,+12,+15,+18,+21,+24,+27);
        NomLigneRappel : array[TligneRappel] of string =
            ('Valeurs du modèle','Réticules','Delta X','Delta Y','Pente','Equivalence','Tangente');

var
        NbreMC : integer = 1024;
        CoeffEllipse : double = 1.0;
        withReticule : boolean = true;
        traceIntersection : boolean = true;
        avecChi2 : boolean = false;
        LevenbergMarquardt : boolean = true;
        Recuit : boolean = false;
        withBandeConfiance : boolean = false;
        withBandePrediction : boolean = false;
        ModeleFacteurQualite : boolean = true; // sinon facteur d'amortissement Q=1/2m
        ModeleDecibel : boolean = false;
        FichierTrie : boolean = false;
        DataTrieGlb : boolean = false;
        modeleCosinus : boolean = true;
        OrdreBruit : integer = 3;
        ajusteOrigine : boolean = false;
        uniteParenthese : boolean = false;
        oCSV_vrai : boolean = true;
        oCSV_valeursSeules : boolean = false;
        codeErreurF : string;

        indexRW3 : integer;
        fichierRW3 : TStringList;
        ParamAnimation : array[0..MaxParamAnimation] of TparamAnimation;

Procedure VerifKilo(var exp : String);
Function TrimNomGrandeur(const s : String) : string;
function Compte(chaine,sousChaine : string) : integer;
Function OKReg(const strOk : string;const helpCtx : LongInt) : boolean;
Function OKformat(const strOk : string;args : array of const) : boolean;
Procedure afficheErreur(const strErreur : string;const HelpCtx : LongInt);
Procedure ValidateReel(Sender : Tedit;var z : double);
Function ToucheValidation(key : word) : boolean;
Procedure VerifKeyGetFloat(var key : char);
Procedure TrimComplet(var S : String);
Procedure TrimAscii127(var S : String);
Function Pad(S : String;Len : integer) : String;
Function ConvertitChaine(nombre : string;var valeur : double) : boolean;
Procedure ConvertitPrefixe(var nombre : string);
Function FormatGeneral(const nombre : double;const Nchiffres : integer) : string;
Function FormatRadian(nombre : double) : string;
Function FormatReg(const nombre : double) : string;
Function FormatCourt(const nombre : double) : string;
Function FormatIncert(const nombre : double;coeff : double) : string;
Function FormatLongueDureeAxe(const nombre : double) : string;
Function FormatPrec(valeur,sigma : double) : String;
Function ChainePrec(const prec : double) : String;
function litLigneWinU : string;
function litLigneWin : string;
procedure ConvertCell(var text : string);
procedure CentreForm(aForm : TForm);
procedure OpenHelp(Aurl : string);

function EnTeteRW3 : boolean;
procedure ecritLigneRW3(s : String);
procedure ecritLigneRW3U(s : String);
procedure ecritSousSection(nombre : integer;s : String);
procedure ecritSection(nombre : integer;s : String);
procedure ecritIntegerRW3(z : integer);
procedure ecritFloatRW3(z : double);
procedure ecritColorRW3(c : TAlphaColor);

function ColorToInt(c : TAlphaColor) : integer;
function IntToColor(i : integer) : TAlphaColor;
procedure litColor(Ini : TiniFile;chaine : string;var defaut : TAlphaColor);
procedure CouleurClaire(var Color : TAlphaColor);
procedure CouleurFoncee(var Color : TAlphaColor);
Function GetCouleurFond(Abitmap : FMX.Graphics.Tbitmap) : TAlphaColor;
procedure SetPixel(abitmap : FMX.Graphics.tbitmap;i,j : integer;acolor : TAlphaColor);
function GetPixel(abitmap : FMX.Graphics.tbitmap;i,j : integer) : TAlphaColor;
Function CouleurComplementaire(couleur : TAlphaColor) : TAlphaColor;
function litColorRW3 : TAlphaColor;
function litFloatRW3 : double;
function litBooleanWin : boolean;
function litBooleanRW3 : boolean;
function litIntegerRW3 : integer;

function writeStringXML(ANode : IXMLNOde;Nom,valeur : string) : IXMLNODE;
function writeIntegerXML(ANode : IXMLNOde;Nom : string;valeur : integer) : IXMLNOde;
function writeBoolXML(ANode : IXMLNOde;Nom : string;valeur : boolean) : IXMLNode;
function writeDateTimeXML(ANode : IXMLNOde;Nom : string;valeur : TDateTime) : IXMLNode;
function writeFloatXML(ANode : IXMLNOde;Nom : string;valeur : double) : IXMLNode;
function writeColorXML(ANode : IXMLNOde;Nom : string;aColor : TAlphaColor) : IXMLNode;
Function GetIntegerXML(ANode : IXMLNOde) : integer;
Function GetIntegerAttribute(ANode : IXMLNOde;genre : string) : integer;
Function GetBoolXML(ANode : IXMLNOde) : boolean;
Function GetFloatXML(ANode : IXMLNOde) : double;
Function GetColorXML(ANode : IXMLNOde) : TAlphaColor;

Function NbreLigneWin(const s : String) : LongInt;
Function PuissToStr(const puiss : integer) : string;
Function IsLigneComment(const ligneCourante : String) : boolean;
Function FloatToStrPoint(const valeur : double) : string;
Function StrToFloatWin(nombre : String) : double;
Function StrToFloatSex(degStr,minStr,secStr : string) : double;
Function StrSexaToDeci(Nombre : String) : double;
Function CaracToChiffre(carac : char) : integer;
Function GetFloat(Nombre : String) : double;
Function GetFloatDate(Nombre : String;Aformat : TnombreFormat) : double;
// Impression
Procedure VerifOrpheline(count : integer;var debut : single);
Procedure BeginPrintTxt(var haut : single);
Procedure BeginPrintGr(var bas : single);
Procedure NewLine;
Procedure PrintLine(const TextStr : String;var debut : single);
procedure PrintList(const aList: TStrings;const entete : string;var debut : single);
procedure printGrid(const aGrid : TTMSFNCGrid;var debut : single);
function CouleurLatex(color: TAlphaColor): string;
Function FloatToStrLatex(const valeur : double) : string;
Function FloatToStrFixedLatex(const valeur : double;Precision,Decimales : integer) : string;
Function PowerToStr(puiss : integer) : string;
function TranslateNomMath(const anom : string) : string;
function TranslateNomTexte(const anom : string) : string;

function valeur125(valInt : integer;down : boolean) : integer;
function getNomCoord(nom : string) : string;
Function isCaracGrandeur(carac : char) : boolean;
Function isLettre(carac : char) : boolean;
function ouvreURL(const myURL : string) : boolean;
function ShellOpen(const FileName: string) : boolean;
function isShift: boolean;
function KeyboardModifiers: TShiftState;
procedure Convert_RW3_to_Mac(NomRW3,NomMac : string);
procedure Convert_RMac_to_RW3(NomMac,NomRW3 : string);

{$IFDEF MACOS}
function RecupereInfo : string;
{$ENDIF}

var
     precision : integer;
     erreurDetectee : boolean;
     avecOptionsXY : boolean;
     ModeAcquisition : TModeAcquisition;
     LigneRappelCourante : TligneRappel;
     LigneRappelTangente : TligneRappel;
     TraceEllipse : boolean;
     GraduationPi : boolean;
     LectureFichier,LecturePage : boolean;
     PrinterParam : TprinterRecord;
     registreReg : string;
     nomFichierTampon,nomTamponPdf : string;
     langue : TLanguagePstCirc;
     chaineLangue : string;
     dateVerifVersion : TDateTime;

{$IFDEF Debug}
      fichierDebug : textFile;
      procedure ecritDebug(s : string);
{$ENDIF}

implementation

function CouleurLatex(color: TAlphaColor): string;
begin
  case color of
    claBlack: Result := 'black';
    claMaroon: Result := 'brown';
    claGreen: Result := 'green';
    claOlive: Result := 'olive';
    claNavy: Result := 'blue';
    claPurple: Result := 'red';
    claTeal: Result := 'teal';
    claGray: Result := 'gray';
    claSilver: Result := 'lightgray';
    claRed: Result  := 'red';
    claLime: Result := 'lime';
    claYellow: Result := 'yellow';
    claBlue: Result := 'blue';
    claFuchsia: Result := 'purple';
    claAqua: Result := 'blue';
    claWhite: Result := 'white';
    claSkyBlue: Result := 'blue';
    else Result := 'black';
  end;
end;

Function PowerToStr(puiss : integer) : string;
var tampon : string;
    i : integer;
    numero : integer;
begin
  if puiss=0
     then result := ''
     else begin
        tampon := IntToStr(puiss);
        result := '';
        for i := 1 to length(tampon) do
            case tampon[i] of
               '0'..'9' : begin
                  numero := strToInt(tampon[i]);
                  result := result+chiffreExp[numero];
               end;
               '+' : result := result+PlusExp;
               '-' : result := result+MoinsExp;
            end;
      end;
end;

Function FloatToStrLatex(const valeur : double) : string;
var posSeparator : integer;
begin
   if isNan(valeur) or isInfinite(valeur)
   then result := ''
   else begin
      result := FloatToStrF(valeur,ffGeneral,4,2);
      if FormatSettings.decimalSeparator<>'.' then begin
         posSeparator := pos(FormatSettings.decimalSeparator,result);
         if posSeparator>0 then result[posSeparator] := '.';
      end;
   end;
end;

Function FloatToStrFixedLatex(const valeur : double;Precision,Decimales : integer) : string;
var posSeparator : integer;
begin
   if isNan(valeur) or isInfinite(valeur)
   then result := ''
   else begin
      result := FloatToStrF(valeur,ffFixed,precision,decimales);
      if FormatSettings.decimalSeparator<>'.' then begin
         posSeparator := pos(FormatSettings.decimalSeparator,result);
         if posSeparator>0 then result[posSeparator] := '.';
      end;
   end;
end;

var avecExposantLatex : boolean;

Function UnicodeToLatexMath(carac : char) : string;
var j : integer;
begin
     avecExposantLatex := false;
     case carac of
                      alphaMin : result := '\alpha ';
                      betaMin : result := '\beta ';
                      gammaMin: result := '\gamma ' ;
                      gammaMaj: result := '\Gamma ';
                      deltaMin: result := '\delta ';
                      deltaMaj: result := '\Delta ';
                      epsilonMin: result := '\epsilon ';
                      zetaMin: result := '\zeta ';
                      etaMin: result := '\eta ';
                      kappaMin: result := '\kappa ';
                      lambdaMin: result := '\lambda ';
                      lambdaMaj: result := '\Lambda ';
                      muMin: result := '\mu ';
                      nuMin: result := '\nu ';
                      xiMin: result := '\xi ';
                      xiMaj: result := '\Xi ';
                      pimin: result := '\pi ';
                      piMaj: result := '\Pi ';
                      rhoMin: result := '\rho ';
                      sigmaMin: result := '\sigma ';
                      sigmaMaj: result := '\Sigma ';
                      tauMin: result := '\tau ';
                      thetaMin: result := '\theta ';
                      thetaMaj: result := '\Theta ';
                      phiMin: result := '\phi ';
                      phiMaj: result := '\Phi ';
                      chiMin: result := '\chi ';
                      psiMin: result := '\psi ';
                      psiMaj: result := '\Psi ';
                      omegaMin: result := '\omega ';
                      omegaMaj: result := '\Omega ';
                      '§' : result := '\S';
                      '&' : result := '\&';
                      '#' : result := '\#';
                      '°' : result := '°';
                      '±' : result := '\pm ';
                      '%' : result := '\%';
                      pourMille : result := '\textperthousand ';
                      MoinsExp : result := '-';
                      PlusExp : result := '+';
                      InfEgal : result := '\leq ';
                      SupEgal : result := '\geq ';
                      pointMedian : result := '\cdot ';
                      cdot : result := '\cdot ';
                      else begin
                         result := carac;
                         for j := 0 to 9 do
                            if carac=ChiffreExp[j] then begin
                               result := intToStr(j);
                               break;
                            end;
                      end;
     end;
end;

Function UnicodeToLatexTexte(carac : char) : string;
var j : integer;
begin
     avecExposantLatex := false;
     case carac of
                      alphaMin: result := '$\alpha$';
                      betaMin: result := '$\beta$';
                      gammaMin: result := '$\gamma$' ;
                      gammaMaj: result := '$\Gamma$';
                      deltaMin: result := '$\delta$';
                      deltaMaj: result := '$\Delta$';
                      epsilonMin: result := '$\epsilon$';
                      zetaMin: result := '$\zeta$';
                      etaMin: result := '$\eta$';
                      kappaMin: result := '$\kappa$';
                      lambdaMin: result := '$\lambda$';
                      lambdaMaj: result := '$\Lambda$';
                      muMin: result := '$\mu$';
                      nuMin: result := '$\nu$';
                      xiMin: result := '$\xi$';
                      xiMaj: result := '$\Xi$';
                      pimin: result := '$\pi$';
                      piMaj: result := '$\Pi$';
                      rhoMin: result := '$\rho$';
                      sigmaMin: result := '$\sigma$';
                      sigmaMaj: result := '$\Sigma$';
                      tauMin: result := '$\tau$';
                      thetaMin: result := '$\theta$';
                      thetaMaj: result := '$\Theta$';
                      phiMin: result := '$\phi$';
                      phiMaj: result := '$\Phi$';
                      chiMin: result := '$\chi$';
                      psiMin: result := '$\psi$';
                      psiMaj: result := '$\Psi$';
                      omegaMin: result := '$\omega$';
                      omegaMaj: result := '$\Omega$';
                      '%' : result := '\%';
                      pourmille : result := '\textperthousand';
                      '§' : result := '\S';
                      '&' : result := '\&';
                      '#' : result := '\#';
                      '°' : result := '\degres';
                      MoinsExp : begin
                         avecExposantLatex := true;
                         result := '-';
                      end;
                      PlusExp : begin
                         avecExposantLatex := true;
                         result := '+';
                      end;
                      InfEgal : result := '$\leq$';
                      SupEgal : result := '$\geq$';
                      '±' : result := '$\pm$';
                      pointMedian : result := '\cdot ';
                      cdot : result := '\cdot ';
                      else begin
                         result := carac;
                         for j := 0 to 9 do
                            if carac=ChiffreExp[j] then begin
                               avecExposantLatex := true;
                               result := intToStr(j);
                               break;
                            end;
                      end;
     end;
end;

function TranslateNomMath(const anom : string) : string;
var i : integer;
begin
    result := '';
    for i := 1 to length(anom) do
        result := result+unicodeToLatexMath(anom[i]);
end;

function TranslateNomTexte(const anom : string) : string;
var i : integer;
    tr : string;
    exposantEnCours : boolean;
begin
    result := '';
    exposantEnCours := false;
    for i := 1 to length(anom) do begin
        tr := unicodeToLatexTexte(anom[i]);
        if exposantEnCours
           then if avecExposantLatex
              then
              else begin
                 exposantEnCours := false;
                 result := result+'}$';
              end
           else if avecExposantLatex
              then begin
               result := result+'$^{';
               exposantEnCours := true;
              end;
        result := result+tr;
    end;
    if exposantEnCours then
        result := result+'}$';
end;

constructor TparamAnimation.create;
begin
    inherited create;
    init;
end;

procedure TparamAnimation.init;
begin
     nomA := '';
     codeA := 255;
     ValeurA := Nan;
     DebutA := Nan;
     FinA := Nan;
     PasA := Nan;
     active := false;
     variationLog := false;
     aInitialiser := false;
end;

Procedure TparamAnimation.ecritXML(ANode : IXMLNOde);
begin
      writeFloatXML(ANode,'Pas',pasA);
      writeStringXML(ANode,'Nom',nomA);
      writeFloatXML(ANode,'Debut',debutA);
      writeFloatXML(ANode,'Fin',finA);
      writeBoolXML(ANode,'Active',active);
      writeBoolXML(ANode,'Log',variationLog);
      writeFloatXML(ANode,'Valeur',valeurA);
end;

Procedure TparamAnimation.litXML(ANode : IXMLNOde);

procedure litUnElement(ANode : IXMLNOde);
begin
     if SameText(ANode.NodeName,'Pas') then pasA := GetFloatXML(ANode);
     if SameText(ANode.NodeName,'Nom') then nomA := ANode.nodeValue;
     if SameText(ANode.NodeName,'Debut') then DebutA := GetFloatXML(ANode);
     if SameText(ANode.NodeName,'Fin') then FinA := GetFloatXML(ANode);
     if SameText(ANode.NodeName,'Active') then active := GetBoolXML(ANode);
     if SameText(ANode.NodeName,'Log') then variationLog := GetBoolXML(ANode);
     if SameText(ANode.NodeName,'Valeur') then valeurA := GetFloatXML(ANode);
end;

var i : integer;
begin
    if ANode.HasChildNodes then
       for I := 0 to ANode.ChildNodes.Count - 1 do
           litUnElement(ANode.ChildNodes.Nodes[I]);
end;

var
     SuiteCaracGrandeur : TsysCharSet; // carac permis à l'interieur d'un nom de grandeur

procedure Convert_RW3_to_Mac(NomRW3,NomMac : string);
var fichierRW3,fichierMac : TBufferedFileStream;
    octet : AnsiChar;
    posMax : longword;
begin
    fichierRW3 := TBufferedFileStream.Create(nomRW3,fmOpenRead);
    try
    fichierMac := TBufferedFileStream.Create(nomMac,fmCreate or fmOpenWrite);
    try
    fichierRW3.position := 0;
    fichierMac.Position := 0;
    posMax := FichierRW3.Size;
    while (fichierRw3.Position<posMax) do begin
        FichierRW3.ReadBuffer(octet,1);
        case octet of
             betaRW3 : octet := betaR;
             rhoRW3 : octet := rhoR;
             tauRW3 : octet := tauR;
             omegaRW3 : octet := omegaR;
             omegaMajRW3 : octet := omegaMajR;
        end;
        FichierMac.WriteBuffer(octet,1);
    end;
    finally
    fichierMac.Free;
    end;
    finally
    fichierRW3.Free;
    end;
end;

Procedure VerifKilo(var exp : String);

function textePrefixe(pref : char) : String;
begin
case pref of
     'p' : textePrefixe := 'E-12';
     'n' : textePrefixe := 'E-9';
     'µ' : textePrefixe := 'E-6';
     'm' : textePrefixe := 'E-3';
     'k' : textePrefixe := 'E+3';
     'M' : textePrefixe := 'E+6';
     'G' : textePrefixe := 'E+9';
     else textePrefixe := '';
end end;

var j : integer;
begin
    j := 2;
    while j<=length(exp) do begin
        if charinset(exp[j],caracPrefixe) and
           exp[pred(j)].isDigit then begin
             insert(textePrefixe(exp[j]),exp,succ(j));
             delete(exp,j,1);
             inc(j,3);
        end;
        inc(j);
    end;
end;

procedure litColor(Ini : TiniFile;chaine : string;var defaut : TAlphaColor);
var i : integer;
begin
     try
     i := ini.ReadInteger('Color',chaine,0);
     if i<>0 then defaut := IntToColor(i);
     except
       defaut := claBlack;
     end;
end;

function litColorRW3 : TAlphaColor;
var couleur : TAlphaColor;
    i : integer;
begin
     try
     i := strToInt(ligneWin);
     couleur := IntToColor(i);
     except
       couleur := claBlack;
     end;
     result := couleur;
end;

Function TrimNomGrandeur(const s : String) : string;
var longueur,i : integer;
begin
      result := '';
      longueur := Length(s);
      for i := 1 to longueur do
          if s[i].isLetterOrDigit
             then result := result+s[i]
end;

function Compte(chaine,sousChaine : string) : integer;
var index : integer;
begin
     index := System.StrUtils.PosEx(sousChaine,chaine,1);
     result := 0;
     while index>0 do begin
           inc(result);
           index := System.StrUtils.PosEx(sousChaine,chaine,index+length(sousChaine));
     end;
end;

procedure Convert_RMac_to_RW3(NomMac,NomRW3 : string);
var fichierRW3,fichierMac : TBufferedFileStream;
    octet : AnsiChar;
begin
    fichierMac := TBufferedFileStream.Create(nomMac,fmOpenRead);
    try
    fichierRW3 := TBufferedFileStream.Create(nomRW3,fmCreate or fmOpenWrite);
    try
    fichierRW3.position := 0;
    fichierMac.Position := 0;
    while (fichierMac.Position<FichierMac.Size) do begin
        FichierMac.ReadBuffer(octet,1);
        case octet of
             betaR : octet := betaRW3;
             rhoR : octet := rhoRW3;
             tauR : octet := tauRW3;
             omegaR : octet := omegaRW3;
             omegaMajR : octet := omegaMajRW3;
        end;
        FichierRW3.WriteBuffer(octet,1);
    end;
    finally
    fichierRW3.Free;
    end;
    finally
    fichierMac.Free;
    end;
end;

Procedure TrimComplet(var s : string);
var longueur,posCourant : integer;
begin
	longueur := Length(s);
	posCourant := 1;
	while (posCourant<=longueur) do
		if ord(s[posCourant])<=32
			then begin
			   Delete(s,posCourant,1);
			   dec(longueur);
			end
			else inc(posCourant);
end;

Procedure TrimBlanc(var s : string);
var posCourant : integer;
begin
	posCourant := pos(' ',s);
	while (posCourant>0) do begin
	   Delete(s,posCourant,1);
     posCourant := pos(' ',s);
  end
end;

Function GetFloat(Nombre : String) : double;
Const
    MaxPile = 10;
    CaracCte : tSysCharSet = [piMin,piMaj,'P','I','p','i'];
type
    IndicePile  = 1..MaxPile;
Var
    Pile : Array[IndicePile] of double;
    IndicePileCourant : 0..MaxPile;
    CaracCourant : char;
    PointeurExp : integer;

Procedure suivant;
// Lit le prochain caractère et l'assigne à caracCourant
// Le caracCourant est toujours extrait avant appel d'un analyseur
begin
    inc(pointeurExp);
    if pointeurExp<=length(Nombre)
       then caracCourant := Nombre[pointeurExp]
       else caracCourant := #0;
end;

Procedure InitFonctor;
Begin
  pointeurExp := 0;
  indicePileCourant := 0;
  suivant;
end;

// Les procédures LireXXX extraient un XXX de la chaine Nombre à partir du pointeur courant

Function LireNombre : double;
    Var PointeurChiffre : integer;
        Valeur : double;
        NombreLoc : String;

    Procedure lireEntier;
    begin
       While caracCourant.isDigit do suivant
    end;

    Begin
        PointeurChiffre := PointeurExp; // pointe le premier chiffre du nombre
        If charinset(caracCourant,['-','+']) then suivant; // saute le signe
        lireEntier;
        If caracCourant='.' // C'est un nombre décimal
           Then begin
              suivant; // on saute le .
              lireEntier
           end;
        If ( upcase(caracCourant) = 'E' ) // puissance de 10
           then begin
              suivant; // on saute le E
              if (caracCourant='+') or (caracCourant='-')  then suivant;
              lireEntier
           end
           else if charinset(caracCourant,caracPrefixe) then suivant; // coeff unité
        NombreLoc := copy(nombre,pointeurChiffre,pointeurExp-PointeurChiffre);
        if not ConvertitChaine(nombreLoc,valeur)
           then raise EGetFloatError.Create(erNombre);
        LireNombre := valeur;
   end; // lireNombre

Function LireIdEnt : String;
Var PointeurIdent : integer;
Begin
  PointeurIdent := pointeurExp;
  While charinset(caracCourant,CaracCte) do suivant;
  if (pointeurExp-pointeurIdent)>16 then raise EGetFloatError.Create(erTropLong);
  LireIdent := copy(nombre,pointeurIdent,pointeurExp-pointeurIdent)
End;  // LireIdEnt

Procedure Depile(Var P : double);
Begin
  if indicePileCourant=0
    then raise EGetFloatError.Create(Erinterne)
    else begin
      P := Pile[indicePileCourant];
      dec(indicePileCourant);
   end;
End;

Procedure Empile(P : double);
Begin
  if indicePileCourant=MaxPile
    then raise EGetFloatError.Create(erTropcomplexe)
    else begin
      inc(indicePileCourant);
      Pile[indicePileCourant] := P;
   end;
End;

Function CalcOperateur(C : char;PG,PD : double) : double;
begin
   case C of
         '+'  : calcOperateur := PG+PD;
         '-'  : calcOperateur := PG-PD;
         '/'  : calcOperateur := PG/PD;
         '*'  : calcOperateur := PG*PD;
         '^'  : calcOperateur := Power(PG,PD);
         else CalcOperateur := 0;
   end;
end;

Procedure AnalyseExpression;Forward;

Procedure E; // E=(.Expression.)
Begin
  If caracCourant='('
    Then Begin
        suivant;
        AnalyseExpression;
        case caracCourant of
             ')'  : suivant;
             #0 : ; // fin => on ajoute ) manquante
             else raise EGetFloatError.Create('Erreur )');
        end;{case}
    End
    Else raise EGetFloatError.Create('Erreur (')
End;{E}

Procedure AnalyseElement; // Element = E/nombre
Var
  U : String;
Begin
  If charInSet(caracCourant,['P','p']) or (caracCourant=piMin) or (caracCourant=piMaj)
    Then Begin
        U := LireIdent;
        U := AnsiUpperCase(U);
        if (U=piMin) or (U='PI')or (U=piMaj)
           then Empile(pi)
           else raise EGetFloatError.Create('Erreur nombre')
    End
    Else If caracCourant.isDigit or charinset(caracCourant,['-','+','.'])
        Then Empile(LireNombre)
        Else E
End; // analyseElement

Procedure AnalyseFacteur; // facteur = Element.^.element
Var  T1,T2 : double;
Begin
  AnalyseElement;
  While (caracCourant='^') do Begin
     suivant;
     AnalyseElement;
     depile(T2);
     depile(T1);
     Empile(CalcOperateur('^',T1,T2));
  End {while}
End; // AnalyseFacteur

Procedure AnalyseTerme; // terme = facteur.[* ou /].facteur
Var
  C        : Char;
  T1,T2    : double;
Begin
  AnalyseFacteur;
  While (caracCourant='*') or (caracCourant='/') do Begin
       C:=caracCourant;
       suivant;
       AnalyseFacteur;
       depile(T2);
       depile(T1);
       Empile(CalcOperateur(C,T1,T2));
    End
End; // AnalyseTerme

Procedure AnalyseExpression;// Expression = [+ ou - ou rien].Terme.[+ ou -].terme
Var
  C      : Char;
  T1,T2  : double;
Begin
  If (caracCourant='+') or (caracCourant='-')
     Then Begin
        C:=caracCourant;
        suivant
     end
     Else C:='+';
  AnalyseTerme;
  If C='-' Then begin
         depile(T1);
         Empile(-T1)
  end;
  While (caracCourant='+') or (caracCourant='-') do Begin
      C:=caracCourant;
      suivant;
      AnalyseTerme;
      depile(T2);
      depile(T1);
      Empile(CalcOperateur(C,T1,T2));
  End // while
End; // AnalyseExpression

procedure VerifExposant;
var i,j : integer;
    acarac : char;
    expInsere : boolean;
begin
    i := 1;
    expInsere := false;
    while (i<=length(nombre)) do begin
        acarac := nombre[i];
        if pos(acarac,chiffrePuiss)>0 then begin
           for j := 0 to 9 do
               if acarac=ChiffreExp[j] then begin
                  if expInsere then begin
                     nombre[i] := char(ord('0')+j);
                     inc(i);
                  end
                  else begin
                     insert('^',nombre,i);
                     expInsere := true;
                     nombre[i+1] := char(ord('0')+j);
                     inc(i,2);
                  end;
                  break;
               end;
           if acarac=moinsExp then begin
              insert('^',nombre,i);
              expInsere := true;
              nombre[i+1] := '-';
              inc(i,2);
           end
           else if acarac=plusExp then begin
              insert('^',nombre,i);
              expInsere := true;
              nombre[i+1] := '+';
              inc(i,2);
           end;
        end
        else inc(i);
    end;
end;

var posVirgule : integer;
Begin // getFloat
  trimComplet(Nombre);
  if nombre='' then begin
     raise EGetFloatError.Create('chaine vide');
     exit; // ?!
  end;
  VerifExposant;
  if FormatSettings.decimalSeparator<>'.' then begin
     posVirgule := pos(',',nombre);
     while posVirgule>0 do begin
        Nombre[posVirgule] := '.';
        posVirgule := pos(',',nombre);
     end;
  end;
  InitFonctor;
  AnalyseExpression;
  if pred(pointeurExp)<>length(nombre) then begin
     raise EGetFloatError.Create('Erreur nombre');
     exit; // ?!
  end;
  if isInfinite(Pile[1]) then
     raise EGetFloatError.Create('Erreur nombre');
  result := Pile[1];
end; // getFloat

Function StrSexaToDeci(Nombre : String) : double;
var posDegre,posSeconde,posMinute,posPoint : integer;
    degre,minute : integer;
    seconde : double;
    negatif : boolean;
begin
     nombre := trim(nombre);
     posDegre := pos('°',nombre);
     if posDegre=0 then posDegre := pos(' ',nombre);
     posMinute := pos('''',nombre);
     if (posMinute=0) and (posDegre>0) then posMinute := PosEx(' ',nombre,posDegre+2);
     posSeconde := pos('"',nombre);
     if posSeconde=0 then posSeconde := pos('''''',nombre);
     if posSeconde>0 then delete(nombre,posSeconde,length(nombre)-posSeconde+1);
     if (posDegre>0) or (posMinute>0) then begin
             negatif := (length(nombre)>0) and (nombre[1]='-');
             if posDegre>0
                then degre := abs(strToInt(trim(copy(nombre,1,posDegre-1))))
                else degre := 0;
             if posMinute>0
                then minute := strToInt(trim(copy(nombre,posDegre+1,posMinute-posDegre-1)))
                else begin
                     posMinute := posDegre;
                     minute := 0;
                end;
             if posMinute<length(nombre)
                then begin
                   posPoint := pos('.',copy(nombre,posMinute+1,length(nombre)-posMinute));
                   if posPoint>0
                      then seconde := StrToFloatWin(trim(copy(nombre,posMinute+1,length(nombre)-posMinute)))
                      else seconde := strToInt(trim(copy(nombre,posMinute+1,length(nombre)-posMinute)));
                end
                else seconde := 0;
             result := degre+minute/60+seconde/3600;
             if negatif then result := -result;
     end
     else result := getFloat(nombre);
end; // StrSexaToDeci

Function StrLongueDureeToSecond(zz : string) : double;

function Extrait : integer;
var posSepar : integer;
begin
       posSepar := pos(':',zz);
       if posSepar=0
          then if zz=''
             then result := 0
             else begin
                result := strToInt(zz);
                zz := '';
             end
             else begin
                 result := strToInt(copy(zz,1,posSepar-1));
                 delete(zz,1,posSepar);
             end;   
end;

//  conversion d hh:mm:ss en secondes
var posJour,sec,min,hour,day : integer;
begin
    posJour := pos('j',zz);
    if posJour>0
       then begin
         try
         day := strToInt(copy(zz,1,posJour-1));
         except
         day := 0;
         end;
         delete(zz,1,posJour);
       end
       else day := 0;
    if (day=0) and (pos(':',zz)=0)
       then result := strToFloat(zz)  { donnée en seconde }
       else begin
          sec := 0;
          for min := 1 to length(zz) do
              if zz[min]=':' then inc(sec);
          if (day>0) or (sec>1)
             then begin
                hour := extrait;
                min := extrait;
                sec := extrait;
             end
             else begin
                min := extrait;
                sec := extrait;
                hour := 0;
             end;
          result := ((day*24+hour)*60+min)*60+sec;
      end;    
end;

Function GetFloatDate(Nombre : String;Aformat : TnombreFormat) : double;
var posDegre,posSeconde,posMinute,i : integer;
    degre,minute,seconde : integer;
    z : string;
begin
   case Aformat of
     fDateTime : result := StrToDateTime(nombre);
     fDate : result := StrToDate(nombre);
     fTime : result := StrToTime(nombre);     
     fLongueDuree : result := StrLongueDureeToSecond(nombre);
     fDegreMinute : begin
        posDegre := pos(':',nombre);
        if posDegre>0 then begin
           nombre[posDegre] := '°';
           posDegre := pos(':',nombre);
           if posDegre>0 then nombre[posDegre] := '''';
        end;
        posDegre := pos('°',nombre);
        posMinute := pos('''',nombre);
        posSeconde := pos('"',nombre);
        if posSeconde=0 then begin
           posSeconde := pos('''''',nombre);
           if posSeconde>0 then begin
              nombre[posSeconde] := '"';
              delete(nombre,posSeconde+1,1);
           end;
        end;
        if (posDegre>0) or (posMinute>0) or (posSeconde>0)
             then begin
                  minute := 0;
                  seconde := 0;
                  degre := 0;
                  z := '';
                  i := 1;
                  while i<=length(nombre) do begin
                        try
                        case nombre[i] of
                             '0'..'9' : z := z+nombre[i];
                             '°' : begin
                                 degre := strToInt(z);
                                 z := '';
                              end;
                             '''' : begin
                                 minute := strToInt(z);
                                 z := '';
                              end;
                             '"' : begin
                                 seconde := strToInt(z);
                                 z := '';
                              end;
                        end;
                        except
                        end;
                        inc(i);
                  end;
                  if z<>'' then
                     if posMinute=0 then minute := strToInt(z)
                     else if posSeconde=0 then seconde := strToInt(z);
                  if degre<0
                    then result := degre-minute/60-seconde/60/60
                    else result := degre+minute/60+seconde/60/60;
              end // posDegre <> 0
              else result := getFloat(nombre);
     end
     else result := getFloat(nombre);
  end;
end; // GetFloatDate

Function OKReg(const strOk : string;const helpCtx : LongInt) : boolean;
var reponse : boolean;
begin
     if HelpCtx>0
        then TDialogService.MessageDialog(strOK,TMsgDlgType.mtConfirmation,
                            [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo,TMsgDlgBtn.mbHelp],TMsgDlgBtn.mbYes,HelpCtx,
                            procedure(const Aresult : TmodalResult) begin
                            reponse := Aresult=mrYes;
                            end)
        else TDialogService.MessageDialog(strOK,TMsgDlgType.mtConfirmation,
                            [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo],TMsgDlgBtn.mbYes,0,
                            procedure(const Aresult : TmodalResult) begin
                            reponse := Aresult=mrYes;
                            end);
     result := reponse;
// TMsgDlgType = ( mtWarning, mtError,  mtInformation, mtConfirmation,  mtCustom);
// TMsgDlgBtn = (mbYes,mbNo,mbOK,TMsgDlgBtn.mbCancel,mbAbort,mbRetry,mbIgnore,mbAll,mbNoToAll,mbYesToAll,mbHelp,mbClose);
end;

Function OKformat(const strOk : string;args : array of const) : boolean;
var reponse : boolean;
begin
     TDialogService.MessageDialog(format(strOK,args),TMsgDlgType.mtConfirmation,
            [TMsgDlgBtn.mbYes,TMsgDlgBtn.mbNo],TMsgDlgBtn.mbYes,0,
             procedure(const Aresult : TmodalResult) begin
                            reponse := Aresult=mrYes;
                            end);
     result := reponse;
end;

Procedure TrimAscii127(var s : String);
var longueur,posCourant : integer;
begin
	longueur := Length(s);
  posCourant := 1;
	while (posCourant<=longueur) do
		if ((s[posCourant]<=' ') or (s[posCourant]>'z'))
			then begin
			   Delete(s,posCourant,1);
			   dec(longueur);
			end
			else inc(posCourant);
end;

Function StrToFloatWin(nombre : String) : double;
var posSeparator : integer;
    virgule : char;
begin
   if FormatSettings.decimalSeparator='.'
      then virgule := ','
      else virgule := '.';
   posSeparator := pos(virgule,nombre);
   if posSeparator>0 then Nombre[posSeparator] := FormatSettings.decimalSeparator;
   try
       result := strToFloat(nombre);
   except
       result := Nan
   end;
end;

Function StrToFloatSex(degStr,minStr,secStr : string) : double;
var deg,minute,seconde,valeur : double;
    negatif : boolean;
begin
   negatif := degStr[1]='-';
   if negatif then delete(degStr,1,1);
   deg := StrToInt(degStr);
   minute := StrToInt(minStr);
   seconde := StrToFloatWin(secStr);
   valeur := deg+minute/60+seconde/3600;
   if negatif then valeur := -valeur;
   result := valeur;
end;

Function FloatToStrPoint(const valeur : double) : string;
var nombre : string;
    posSeparator : integer;
begin
   if isNan(valeur) then result := ''
   else begin
   nombre := FloatToStr(valeur);
   if FormatSettings.decimalSeparator<>'.' then begin
      posSeparator := pos(FormatSettings.decimalSeparator,nombre);
      if posSeparator>0 then Nombre[posSeparator] := '.';
   end;
   result := nombre;
   end;
end;

Function ConvertitChaine(nombre : string;var valeur : double) : boolean;
begin
   convertitChaine := false;
   TrimComplet(nombre);
   valeur := Nan;
   if Length(nombre)=0 then exit;
   case nombre[1] of
        'e','E' : nombre := '1'+nombre;
        '.',',' : begin
           nombre[1] := FormatSettings.decimalSeparator;
           nombre := '0'+nombre
        end;
        '0'..'9','+','-' : ;
        else exit;
   end;
   convertitChaine := true;
   convertitPrefixe(nombre);
   try
   valeur := StrToFloatWin(nombre);
   except
      convertitChaine := false;
   end;
end;

Procedure ConvertitPrefixe(var nombre : string);
var u : coefUnite;
    c : char;
begin
   c := nombre[length(nombre)];
   if charInSet(c,caracPrefixe) then begin
      if c=muMin
         then u := micro
         else begin
         u := zero;
         repeat inc(u) until (c=prefixeUnite[u]);
      end;
      delete(nombre,length(nombre),1);
      nombre := nombre+expUnite[u];
   end;
end;

Function FormatIncert(const nombre : double;coeff : double) : string;
var longueur,i,posE : integer;
    puiss : string;
begin
     if isNan(nombre) then begin
        result := '';
        exit;
     end;
     result := FloatToStrF(nombre*coeff,ffFixed,2,18);
     posE := pos('E',result);
     longueur := length(result);
     if pos('E',result)>0 then begin
        puiss := copy(result,posE+1,longueur-posE);
        i := strToInt(puiss);
        puiss := pointMedian+'10'+puissToStr(i);
        result := copy(result,1,posE-1);
        longueur := length(result);
     end
     else puiss := '';
     i := 0;
     repeat inc(i);
     until charinset(result[i],['1'..'9']) or (i=longueur);
     if i<longueur then begin
        i := i+1; // on garde deux chiffres
        if Result[i]=formatSettings.DecimalSeparator
           then i := i+1;// on saute la virgule
     end;
     result := copy(result,1,i)+puiss;
end;

Function FormatPrec(valeur,sigma : double) : String;
var puissValeur : integer;
    CoeffValeur,valeurDix : double;
    Precision,Decimales : integer;
    tampon : String;
    PrecOk : boolean;
begin
   tampon := '';
   Precision := 0;
   try
      Precision := floor(log10(abs(valeur))-floor(log10(sigma)))+1;
      precOK := true;
   except
     precOK := false;
   end;
  if precOK
         then begin
            if Precision<=2
               then Precision := 3
               else if Precision>PrecisionMax
                  then Precision := PrecisionMax;
            PuissValeur := 3*floor(log10(abs(valeur))/3);
            CoeffValeur := dix(-puissValeur);
         end
         else begin
            Precision := PrecisionMax div 2;
            PuissValeur := 0;
            CoeffValeur := 1;
         end;
   Decimales := Precision-1;
   valeurDix := valeur*CoeffValeur;
   if valeurDix>=10 then dec(Decimales);
   if valeurDix>=100 then dec(Decimales);
   tampon := FloatToStrF(valeurDix,ffFixed,Precision,Decimales);
   if puissValeur<>0 then
      tampon:=tampon+pointMedian+'10'+puissToStr(puissValeur);
   result := tampon;
end; // FormatPrec

Function FormatMilli(Nombre : double;Precision : integer) : string;
var
   Longueur : integer;
   i : integer;
begin
     if isNan(Nombre) then result := ''
     else begin
     result := FormatGeneral(Nombre,Precision);
     longueur := precision-length(result)+1;// +1=decimalSeparator
     if (longueur>0) and
          (pos(FormatSettings.decimalSeparator,result)>0) and
          (pos('E',result)<=0) then begin
           for i := 1 to longueur do
               result := result+'0';
     end;
     end;
end; // FormatMilli

Function FormatGeneral(const Nombre : double;const Nchiffres : integer) : string;
var Nexp,posV,posE,i : integer;
    exposant : string;
begin
   if isNan(Nombre)
      then FormatGeneral := ''
      else begin
         if abs(Nombre)<1e-10
           then Nexp := 2
           else if abs(Nombre)<1e+10
              then Nexp := 1
              else Nexp := 2;
         result := FloatToStrF(nombre,ffGeneral,Nchiffres,Nexp);
         posV := pos(FormatSettings.decimalSeparator,result);
         if posV=0
            then begin
              posE := pos('E',result);
              if posE>0
                 then begin
                    exposant := copy(result,posE+1,length(result)-posE);
                    result := copy(result,1,posE-1);
                    Nexp := Nchiffres-posE+1;
                 end
                 else begin
                    exposant := '';
                    Nexp := Nchiffres-length(result);
                 end;
             if Nexp>0 then begin
                result := result+FormatSettings.decimalSeparator;
                for i := 1 to Nexp do result := result+'0';
             end;
          end
          else begin
             posE := pos('E',result);
             if posE>0
                then begin
                   exposant := copy(result,posE+1,length(result)-posE);
                   result := copy(result,1,posE-1);
                   Nexp := Nchiffres-posE+2;
                end
                else begin
                   exposant := '';
                   Nexp := Nchiffres-length(result)+1;
                end;
             if result[1]='-' then begin
                inc(Nexp);
                if result[2]='0' then inc(Nexp);
             end
             else if result[1]='0' then inc(Nexp);
             for i := 1 to Nexp do result := result+'0';
        end;
     end;
     if exposant<>'' then begin
         Nexp := strToInt(exposant);
         result := result+pointMedian+'10'+puissToStr(Nexp);
     end;
end; // FormatGeneral

Function FormatRadian(Nombre : double) : string;
var num,denom : integer;
    strNum,strDenom : string;
begin
   if nombre<0 then strNum := '-' else strNum := '';
   nombre := abs(nombre);
   if AngleEnDegre then nombre := DegToRad(nombre);
   if nombre<pi/12
      then result := '0'
      else begin
          denom := 12;
          num := round(nombre*12/pi);
          if num mod 2 = 0 then begin
             num := num div 2;
             denom := denom div 2;
          end;
          if num mod 2 = 0 then begin
             num := num div 2;
             denom := denom div 2;
          end;
          if num mod 3 = 0 then begin
             num := num div 3;
             denom := denom div 3;
          end;
          if AngleEnDegre
             then result := StrNum+IntToStr(180*num div denom)
             else begin
                if denom=1 then strDenom := '' else strDenom := '/'+intToStr(Denom);
                if num<>1 then strNum := strNum + intToStr(Num);
                result := strNum+piMin+strDenom;
             end;
     end;
end; // FormatRadian

Function FormatReg(const Nombre : double) : string;
begin
       result := FormatMilli(Nombre,Precision)
end;

Function FormatCourt(const Nombre : double) : string;
begin
       result := FormatMilli(Nombre,PrecisionMin)
end;

Function ChainePrec(const Prec : double) : String;
begin
   if prec>=1
       then result := '???'
       else if prec>1e-3
          then result := FloatToStrF(prec*100,ffGeneral,1,0)+' %'
          else result := '<0,1%';
    result := ' '+result;
end;

procedure ConvertCell(var text : string);
var ValeurF : double;
begin
     if text='' then exit;
     try
     valeurF := GetFloat(Text);
     text := floatToStr(valeurF);
     except
     text := '';
     end;
end;

Function NbreLigneWin(const s : String) : LongInt;
var fin : integer;
    StValeur : string;
begin
     fin := 2;
     while (s[fin]>='0') and
     	   (s[fin]<='9') do inc(fin);
     stValeur := copy(s,2,fin-2);
     try
     NbreLigneWin := StrToInt(stValeur)
     except
        on EConvertError do NbreLigneWin := 0
     end
end;

procedure afficheErreur(const strErreur : string;const HelpCtx : LongInt);
var Boutons : TMsgDlgButtons;
begin
     if HelpCtx=0
        then boutons := [TMsgDlgBtn.mbOk]
        else boutons := [TMsgDlgBtn.mbOK,TMsgDlgBtn.mbHelp];
     TDialogService.MessageDialog(strErreur,TMsgDlgType.mtError,boutons,TMsgDlgBtn.mbOK,HelpCtx,nil);
end;

Function PuissToStr(const puiss : integer) : string;
var dest : string;
    i : integer;
    numero : integer;
begin
      if puiss=0
         then dest := ''
         else dest := IntToStr(puiss);
      for i := 1 to length(dest) do
          case dest[i] of
               '0'..'9' : begin
                  numero := strToInt(dest[i]);
                  dest[i] := chiffreExp[numero];
               end;
               '+' : dest[i] := PlusExp;
               '-' : dest[i] := MoinsExp;
          end;
      PuissToStr := dest
end;

Function IsLigneComment(const ligneCourante : String) : boolean;
// ligne vide ou ligne de commentaire
var PosBlanc : integer;
begin
    posBlanc := 1;
    while (posBlanc<=length(ligneCourante)) and
          (ligneCourante[posBlanc]=' ') do inc(posBlanc);
    IsLigneComment :=
        (posBlanc>length(ligneCourante)) or
        charinset(ligneCourante[posBlanc],['''',';'] )
end;

function EnTeteRW3 : boolean;
begin
   result := false;
   ligneWin := '';
   try
   ligneWin := fichierRW3[0];
   result := Pos('REGRESSI WINDOWS',ligneWin)>0;
   except
        FinFichierWin := true;
   end;
   indexRW3 := 1;
   finFichierWin := finFichierWin or (fichierRW3.Count<5);
end;

function litLigneWinU : string;
const
  NouveauCode : array[128..188] of Char =
    (alphaMin,betaMin,
     chiMin,deltaMin,epsilonMin,phiMin,gammaMin,etaMin,lambdaMin,char(#137),nuMin,piMin,
     thetaMin,rhoMin,sigmaMin,tauMin,omegaMin,char(#145),char(#146),xiMin,psiMin,zetaMin,
     deltaMaj,rhoMin,gammaMaj,lambdaMaj,tauMin,omegaMaj,sigmaMaj,omegaMaj,omegaMin,psiMaj,
     char(#160),char(#161),char(#162),char(#163),Char($00B3),char(#165),char(#166),char(#167),char(#168),Char($2074),
     MoinsExp,#171,Char($2076),Char($2077),Char($2078),char(#175),char(#176),#177,Char($00B2),Char($00B3),
     char(#180),muMin,char(#182),char(#183),PlusExp,Char($00B9),Char($2070),#187,Char($0079));

var ligneShort : AnsiString;

Procedure RW3versUnicode;
var i : integer;
    numero : integer;
    carac : AnsiChar;
    caracAccent : boolean;
begin
     ligneWin := '';
     caracAccent := false;
     for i := 1 to length(ligneShort) do begin
         carac := ligneShort[i];
         numero := ord(carac);
         if caracAccent then begin
            case carac of
                    '©' : ligneWin := ligneWin+'é';

                    '¨' : ligneWin := ligneWin+'è';
                    ' ' : ligneWin := ligneWin+'à';

                    '¢' : ligneWin := ligneWin+'â';
                    'ª' : ligneWin := ligneWin+'ê';
                    '®' : ligneWin := ligneWin+'î';
                  //  '¼' : ligneWin := ligneWin+'ô';
                    '»' : ligneWin := ligneWin+'û';

                    '¤' : ligneWin := ligneWin+'ä';
                    '«' : ligneWin := ligneWin+'ë';
                    '¯' : ligneWin := ligneWin+'ï';
                    '¶' : ligneWin := ligneWin+'ö';
                    '¼' : ligneWin := ligneWin+'ü';

                    '§' : ligneWin := ligneWin+'ç';
            end;
            caracAccent := false;
            continue;
         end;
         caracAccent := carac='Ã';
         if caracAccent then begin
            continue;
         end;
// Les caractères au-delà de 7 bits sont différents selon l'encodage...
// £ encodé en UTF-8 donne (194)(163) ce qui, lu en latin-1, fait Â£.
         if (numero<128) or (numero>188)
            then ligneWin := ligneWin+char(carac)
            else ligneWin := ligneWin+NouveauCode[numero]
     end;
end;

Procedure RW3versUnicodeBis;
var i : integer;
    numero : integer;
    caracAccent : boolean;
    carac : char;
begin
     caracAccent := false;
     for i := 1 to length(ligneWin) do begin
         carac := LigneWin[i];
         if caracAccent then begin
            case carac of
                    '©' : ligneWin[i] := 'é'; // A9 169
            end;
            caracAccent := false;
            continue;
         end;
         caracAccent := carac='Ã';
         if caracAccent then begin
            ligneWin[i] := ' ';
            continue;
         end;
         numero := ord(carac);
         if (numero>128) and (numero<188)
            then ligneWin[i] := NouveauCode[numero]
     end;
end;

begin
   try
   litLigneWin;
   ligneShort := AnsiString(ligneWin);
// Conversion acsii regressi vers unicode
   RW3versUnicode;
   result := ligneWin;
   except
       FinFichierWin := true;
       ligneWin := '';
       result := '';
   end;
end; // litLigneWinU

function litLigneWin : string;
begin
   try
   finFichierWin := finFichierWin or (indexRW3>=fichierRW3.count);
   if finFichierWin
      then ligneWin := ''
      else begin
          ligneWin := fichierRW3[indexRW3];
          inc(indexRW3);
      end;
{$IFDEF MACOS}
   if (length(ligneWin)>0) and (ligneWin[1]='#')
      then ligneWin[1] := SymbReg;
{$ENDIF}
   if pos('Â£',ligneWin)=1 then delete(ligneWin,1,1);
   result := ligneWin;
 //  if (length(ligneWin)>0) and (ligneWin[1]='#')  then ligneWin[1]=SymbReg2;
   except
       FinFichierWin := true;
       ligneWin := '';
       result := '';
   end;
end;

function litFloatRW3;
begin
    try
    litLigneWin;
    result := strToFloatWin(ligneWin);
    if result=1e-26 then result := nan;
    except
        result := nan;
    end;
end;

function litBooleanWin : boolean;
begin
   litLigneWin;
   result := (length(ligneWin)>0) and (ligneWin[1]<>'0')
end;

function litBooleanRW3 : boolean;
begin
   result := litBooleanWin;
end;

function litIntegerRW3 : integer;
begin
   litLigneWin;
   result := StrToInt(ligneWin)
end;

Function ToucheValidation(key : word) : boolean;
begin
    ToucheValidation := key in [vkTab,vkLeft,vkRight,vkDown,vkUp,vkReturn]
end;

Procedure VerifKeyGetFloat(var key : char);
begin
     if charinset(key,[',','.'])
        then key := FormatSettings.decimalSeparator
        else if not charinset(key,CharGetFloat) then key := #0
end;

Procedure ValidateReel(Sender : Tedit;var z : double);
begin
     try
         z := StrToFloatWin(sender.text)
     except
         sender.text := FloatToStr(z);
         raise EGetFloatError.Create(erNombre)
     end;
end;

function PadChar(S : String;Len : integer;Achar : char) : String;
// Return a string right-padded to length len with Achar
var i,Slen : integer;
begin
   SLen := length(S); 
   if SLen>=Len
      then result := copy(S,1,Len)
      else begin
         result := S;
         for i := Slen+1 to len do
             result := result + Achar;
      end;
end;

function Pad(S : String;Len : integer) : String;
// Return a string right-padded to length len with ' '
begin
     result := PadChar(S,len,' ')
end;

Function CaracToChiffre(carac : char) : integer;
var i : integer;
begin
      if carac.isDigit
         then result := ord(carac)-ord('0')
         else begin
            result := 0;
            for i := 0 to 9 do
                if carac=ChiffreExp[i] then begin
                   result := i;
                   break;
                end;
         end
end;

procedure NewPage;
begin with PrinterParam do begin
    Cur.X := MargeTexte;
    Cur.Y := MargeTexte;
    Printer.NewPage;
end end;

Procedure VerifOrpheline(count : integer;var debut : single);
var hauteur : single;
begin
    Hauteur := succ(count)*PrinterParam.HeightLine;
    if (debut+hauteur)>Printer.PageHeight
        then begin
             Printer.NewPage;
             debut := 0;
             BeginPrintTxt(debut);
        end
        else begin
             BeginPrintTxt(debut);
             PrintLine('',debut);
        end;
end;

// Start a new line on the current page, if no more lines left start a new page
procedure NewLine;
begin with printerParam do begin
    Cur.X := MargeTexte;
    Cur.Y := Cur.Y + HeightLine;
    if Cur.Y > (Finish.Y - HeightLine) then NewPage;
end end;

procedure PrintList(const aList: TStrings;const entete :string;var debut : single);
var i : integer;
begin
    if enTete<>'' then PrintLine(enTete,debut);
    for i := 0 to pred(aList.count) do
        PrintLine(aList[i],debut);
end;

procedure printGrid(const aGrid : TTMSFNCGrid;var debut : single);
var col,row : integer;
    texte : string;
begin
     for row := 0 to aGrid.RowCount-1 do begin
         texte := '';
         for col := 0 to aGrid.ColumnCount-1 do begin
             texte := texte+aGrid.Cells[col,row]+' ';
         end;
         printLine(texte,debut);
     end;
end;

procedure PrintLine(const TextStr : string;var debut : single);
var L : single;
    arect : TrectF;
begin with PrinterParam do begin
    try
    L := Printer.Canvas.TextWidth(TextStr);
    arect.Create(Cur.X,Cur.Y,Cur.X+L,Cur.Y+HeightLine);
    printer.Canvas.FillText(arect,TextStr,true,1,[],TTextAlign.Leading);
    Cur.X := Cur.X + L;
    NewLine;
    debut := printerParam.Cur.Y;
    except
       ImprimanteDisponible := false;
    end;
end end;

Procedure BeginPrintTxt(var haut : single);
{$IFDEF Windows}
var dpi : TPoint;
{$ENDIF}
begin with printerParam do begin
 //    Printer.ActivePrinter.SelectDPI(1200, 1200);
 //    Printer.ActivePrinter.ActiveDPIIndex := 0;
{$IFDEF Windows}
     dpi := printer.ActivePrinter.DPI[0];
     printer.canvas.Font.Size := 12*dpi.x div 50;
{$ENDIF}
{$IFDEF MacOS}
     printer.canvas.Font.Size := 12;
{$ENDIF}
  //   printer.canvas.Font.Family := FonteRegressi;
     MargeTexte := printer.PageWidth/MargeImprimante;
     Finish.X := printer.PageWidth-margeTexte;
     Finish.Y := printer.PageHeight-margeTexte;
     Cur.X := MargeTexte;
     if haut<margeTexte then haut := MargeTexte;
     if haut>Finish.Y
       then NewPage
       else Cur.Y := haut;
     HeightLine := printer.canvas.TextHeight('A')*1.1;
end end;

Procedure BeginPrintGr(var bas : single);
begin
     with printerParam do begin
        MargeTexte := printer.PageWidth/MargeImprimante;
        Finish.X := printer.PageWidth-margeTexte;
        Finish.Y := printer.PageHeight-margeTexte;
        Cur.X := MargeTexte;
        Cur.Y := MargeTexte;
        HeightLine := printer.Canvas.TextHeight('A')*1.1;
     end;
     bas := 0;
     printer.beginDoc;
end;

Function FormatLongueDureeAxe(const nombre : double) : string;
var t : longInt;
    min,hour,day : integer;
begin
    result := '';
    t := round(nombre);
    day := t div UnJour;
    if day>0 then result := intToStr(day)+'j';
    t := t-day*UnJour;
    hour := t div UneHeure;
    if hour>0 then result := result+IntToStr(hour)+'h';
    if day=0 then begin
       t := t-hour*UneHeure;
       min := t div UneMinute;
       result := result+IntToStr(min);
    end;
end;

function valeur125(valInt : integer;down : boolean) : integer;
var mantisse,exposant,coeff : double;
    valeur : double;
begin
     if down
        then Valeur := ValInt/2.15
        else Valeur := ValInt*2.15;
     exposant := log10(valeur);
     coeff := Int(exposant);
     if (exposant<0) and (coeff<>exposant) then coeff := coeff-1;
     coeff := power(10,coeff);
     mantisse := Int(valeur/coeff);
     if mantisse>2 then if mantisse<6
           then mantisse := 5
           else mantisse := 10;
     result := round(mantisse*coeff);
end;

    function TstrListe.MyIndexOf(Item : string) : Integer;
    var i : integer;
        zut : string;
    begin
        result := -1;
        for i := 0 to pred(count) do begin
            zut := strings[i];
            if pos(RepereConst,zut)>0 then
               system.delete(zut,1,length(RepereConst));
            if Item=zut then begin
               if Item=SeparateurConst
                  then result := i-1
                  else result := i;
               exit;
            end;
        end;
    end;

    function getNomCoord(nom : string) : string;
    begin
       if pos(RepereConst,nom)>0 then
          system.delete(nom,1,length(RepereConst));
       result := nom;
    end;

Function isLettre(carac : char) : boolean;
begin
    result := carac.isLetter;
    if not result then result := pos(carac,grecque)>0;
end;

Function isCaracGrandeur(carac : char) : boolean;
begin
    result := isLettre(carac);
    if not result then result :=
       charInset(carac,SuiteCaracGrandeur);
end;

procedure ecritLigneRW3(s : String);
begin
    fichierRW3.Add(s)
end;

procedure ecritLigneRW3U(s : string);
var sRW3 : ansiString;

Procedure UnicodeVersRW3;
var i,j : integer;
    carac : char;
    caracR : AnsiChar;
begin
     sRW3 := '';
     for i := 1 to length(s) do begin
         carac := s[i];
         if (pos(carac,grecque)>0) or
            (pos(carac,lettreAccent)>0) or
            (pos(carac,chiffrePuiss)>0)
            then case carac of
                      alphaMin: caracR := alphaR;
                      betaMin: caracR := betaR;
                      gammaMin: caracR := gammaR;
                      gammaMaj: caracR := gammaMajR;
                      deltaMin: caracR := deltaR;
                      deltaMaj: caracR := deltaMajR;
                      epsilonMin: caracR := epsilonR;
                      zetaMin: caracR := zetaR;
                      etaMin: caracR := etaR;
                      kappaMin: caracR := 'k';
                      lambdaMin: caracR := lambdaR;
                      lambdaMaj: caracR := lambdaMajR;
                      muMin: caracR := muR;
                      nuMin: caracR := nuR;
                      xiMin: caracR := xiR;
                      xiMaj: caracR := xiMajR;
                      pimin: caracR := piR;
                      piMaj: caracR := piMajR;
                      rhoMin: caracR := rhoR;
                      sigmaMin: caracR := sigmaR;
                      sigmaMaj: caracR := sigmaMajR;
                      tauMin: caracR := tauR;
                      thetaMin: caracR := thetaR;
                      thetaMaj: caracR := thetaMajR;
                      phiMin: caracR := phiR;
                      phiMaj: caracR := phiMajR;
                      chiMin: caracR := chiR;
                      psiMin: caracR := psiR;
                      psiMaj: caracR := psiMajR;
                      omegaMin: caracR := omegaR;
                      omegaMaj: caracR := omegaMajR;
                      'é' : caracR := AnsiChar(233);
                      'è' : caracR := AnsiChar(232);
                      'ê' : caracR := AnsiChar(234);
                      'ë' : caracR := AnsiChar(235);
                      'ï' : caracR := AnsiChar(239);
                      'à' : caracR := AnsiChar(224);
                      'â' : caracR := AnsiChar(226);
                      'ù' : caracR := AnsiChar(249);
                      'û' : caracR := AnsiChar(251);
                      'ü' : caracR := AnsiChar(252);
                      'ô' : caracR := AnsiChar(252);
                      MoinsExp: caracR := moinsExpR;
                      PlusExp: caracR := plusExpR;
                      InfEgal: caracR := infEgalR;
                      SupEgal: caracR := supEgalR;
                      else begin
                         caracR := '?';
                         for j := 0 to 9 do
                            if carac=ChiffreExp[j] then begin
                               caracR := ChiffreExpR[j];
                               break;
                            end;
                      end;
                 end
            else caracR := AnsiChar(carac);
            sRW3 := sRW3+caracR;
     end;
end;

begin
    UnicodeVersRW3;
    ecritLigneRW3(string(sRw3));
end;

procedure ecritSousSection(nombre : integer;s : String);
begin
    s := symbReg2+intToStr(nombre)+' '+s;
    fichierRW3.Add(s)
end;

procedure ecritSection(nombre : integer;s : String);
begin
    s := symbReg+intToStr(nombre)+' '+s;
    fichierRW3.Add(s)
end;

procedure ecritIntegerRW3(z : integer);
begin
    fichierRW3.Add(intToStr(z))
end;

procedure ecritFloatRW3(z : double);
begin
    fichierRW3.Add(FloatToStrPoint(z))
end;

function ColorToInt(c : TAlphaColor) : integer;
var couleur : TAlphaColorRec;
begin
    couleur.color := c;
    couleur.A := $00;
    result := integer(couleur);
end;

procedure ecritColorRW3(c : TAlphaColor);
begin
    fichierRW3.add(IntToStr(ColorToInt(c)))
end;

function _GetMousePos : TPointF;
begin
   result := IFMXMouseService(TPlatformServices.Current.GetPlatformService(IFMXMouseService)).getMousePos;
end;

procedure _SetMousePos(P : TPointF); // n'existe pas !
begin
end;

function IntToColor(i : integer) : TAlphaColor;
var red,green,blue : integer;
    couleur : TAlphaColorRec;
begin
    couleur.color := TAlphaColor(i);
    try
    red := Couleur.R;
    green := Couleur.G;
    blue := Couleur.B;
    if (red+green+blue)>650 then couleur.color := claBlack; // trop proche du blanc
    Couleur.A := $FF; // pas de transparence
    result := couleur.color;
    except
       result := claBlack;
    end;
end;

Function GetCouleurFond(Abitmap : FMX.Graphics.Tbitmap) : TAlphaColor;
var i,j : integer;
    rouge,vert,bleu : integer;
    pasY,pasX : integer;
    vBitMapData : TBitmapData;
    couleur : TAlphaColorRec;
begin
       rouge := 0;
       vert := 0;
       bleu := 0;
       pasY := Abitmap.height div 9;
       pasX := Abitmap.width div 9;
       if (pasX>0) and (pasY>0) and ABitmap.Map(TMapAccess.Read, vBitMapData) then begin
           try
           for i := 1 to 8 do begin
              for j := 1 to 8 do begin
                couleur.color := vBitmapData.GetPixel(j*pasX,i*pasY);
                rouge := rouge+(couleur.R);
                vert := vert+(couleur.G);
                bleu := bleu+(couleur.B);
              end;
           end;
           finally
           aBitmap.Unmap(vBitMapData);
           end;
       end;
       result := MakeColor(rouge div 64,vert div 64,bleu div 64);
end;

procedure SetPixel(abitmap : FMX.Graphics.tbitmap;i,j : integer;acolor : TAlphaColor);
var
  vBitMapData : TBitmapData;
begin
      if aBitmap.Map(TMapAccess.Write, vBitMapData) then begin
          try
          vBitmapData.SetPixel(i,j, aColor);
          finally
          aBitmap.Unmap(vBitMapData);
          end;
      end;
end;

function GetPixel(abitmap : FMX.Graphics.tbitmap;i,j : integer) : TAlphaColor;
var
  vBitMapData : TBitmapData;
begin
      if aBitmap.Map(TMapAccess.Read, vBitMapData) then begin
          try
          result := vBitmapData.GetPixel(i,j);
          finally
          aBitmap.Unmap(vBitMapData);
          end;
      end
      else result := claWhite;
end;

Function CouleurComplementaire(couleur : TAlphaColor) : TAlphaColor;
var H,L,S : single;
    rr,gg,bb : byte;
    c : TAlphaColorRec;
begin
       System.UIConsts.RGBToHSL(couleur,H,S,L); // 0..1 pour H, S, L
       if H>0.5
          then H := H-0.5
          else H := H+0.5;
       if S<0.5 then begin
          if L<0.5
             then L := 1.0
             else L := 0.0;
       end;
       S := 1.0;
       couleur := System.UIConsts.HSLToRGB(H,S,L);
       c.Color := couleur;
       rr := 64*(c.R div 64);
       gg := 64*(c.G div 64);
       bb := 64*(c.B div 64);
       result := makeColor(rr,gg,bb);
end;

function OuvreURL(const myURL: string) : boolean;
const SW_SHOWNORMAL = 1;
begin
{$IFDEF MSWINDOWS}
  result := ShellExecute(0, 'OPEN', PChar(myURL), '', '', SW_SHOWNORMAL)>32;
{$ENDIF}
{$IFDEF MACOS}
  result := _system(PAnsiChar('open ' + AnsiString(myURL)))=0;
{$ENDIF}
end;

function ShellOpen(const FileName: string) : boolean;
const SW_SHOWNORMAL = 1;
begin
{$IFDEF MSWINDOWS}
  result := ShellExecute(0, nil, PChar(FileName), nil, nil, SW_SHOWNORMAL)>32;
{$ENDIF}
{$IFDEF MACOS}
  result := _system(PAnsiChar(UTF8String('open "' +
    ReplaceStr(ReplaceStr(FileName, '\', '\\'), '"', '\"') + '"')))=0;
{$ENDIF}
end;

procedure OpenHelp(Aurl : string);
var Lfile : string;
begin
    if (HelpPath<>'') and (HelpPath[length(HelpPath)]='/')
       then Lfile := HelpPath+Aurl+'.html'
       else Lfile := HelpPath+'/'+Aurl+'.html';
{$IFDEF MSWINDOWS}
    if ShellExecute(0, 'open', PChar(Lfile), nil, nil, SW_SHOWNORMAL) <= 32 then
       ShowMessage('Site Regressi non trouvé');
{$ENDIF MSWINDOWS}
{$IFDEF MACOS}
    _system(PAnsiChar('open ' + '"' + AnsiString(Lfile) + '"'));
{$ENDIF MACOS}
end;

procedure CouleurClaire(var Color : TAlphaColor);
var red,green,blue : byte;
begin
    red := TAlphaColorRec(Color).R; // red
    green := TAlphaColorRec(Color).G; // blue
    blue := TAlphaColorRec(Color).B; // green
    if (red+green+blue)<512 then color := claBeige;
end;

procedure CouleurFoncee(var Color : TAlphaColor);
var red,green,blue : byte;
begin
    red := TAlphaColorRec(Color).R; // red
    green := TAlphaColorRec(Color).G; // blue
    blue := TAlphaColorRec(Color).B; // green
    if (red+green+blue)>256 then color := claMaroon;
end;

{$IFDEF MACOS}
function RecupereBundle : string;
var
   AppBundle: NSBundle;
begin
   AppBundle := TNSBundle.Wrap(TNSBundle.OCClass.mainBundle);
   result := AppBundle.bundlePath.UTF8String+'/Contents/Resources';
end;

function RecupereInfo : string;
var
   AppBundle: NSBundle;
begin
   AppBundle := TNSBundle.Wrap(TNSBundle.OCClass.mainBundle);
   result := AppBundle.bundlePath.UTF8String+'/Contents/Info.plist';
end;

{$ENDIF}

constructor TToolTipPanel.Create(AOwner: TComponent);
begin
  inherited;
  Visible := False;
  StyleLookup := 'tooltippanel' ;
  FLabel := TLabel.Create(AOwner);
  FLabel.Parent := Self ;
  FLabel.StyleLookup := 'tooltiplabel' ;
  FLabel.Text := Self.ToString;
  if assigned(FLabel.Canvas) then
    Height := FLabel.Canvas.TextHeight(FLabel.Text);
  FLabel.Align := TAlignLayout.Client ;
  FLabel.TextAlign := TTextAlign.Center ;
  FLabel.VertTextAlign := TTextAlign.Center ;
  FTimer := TTimer.Create(AOwner);
  FTimer.OnTimer := OnTimer;
  FTimer.Enabled := True ;
  FTimer.Interval := 500;
  FActiveControl := nil;
  FCounter := 1000;
  FBorderWidth := 10 ;
end;

procedure TToolTipPanel.OnTimer;
var
  LMousePos : TPointF;
  LObject : IControl;
  FText : string;
begin
    if Screen.MousePos <> FMousePoint then begin
      FMousePoint := Screen.MousePos ;
      FCounter := 0;
    end ;
    Inc(FCounter);
    case FCounter of
      0..2: Visible := False ;
      3: begin
        FText := '';
        if Parent is TForm then begin
           LObject := (Parent as TForm).ObjectAtPoint(FMousePoint) ;
           if Assigned(LObject) then
              FText := LObject.GetObject.TagString;
        end;
        visible := FText<>'';
        if visible then begin
          LMousePos := (Parent as TForm).ScreenToClient(FMousePoint);
          Position.Point := LMousePos;
          Height := FLabel.Canvas.TextHeight(FText) + 2 * FBorderWidth;
          Width  := FLabel.Canvas.TextWidth(FText) + 2 * FBorderWidth;
          FLabel.text := Ftext;
        end;
      end;
    else begin
      FCounter := 1000;
      Visible := False ;
    end;
    end;
end;

function KeyboardModifiers: TShiftState;
const
  kVK_Shift                     = $38;
  kVK_RightShift                = $3C;
  kVK_Control                   = $3B;
  kVK_Command                   = $37;
  kVK_Option                    = $3A;
begin
  result := [];
{$IFDEF MACOS}
  if (CGEventSourceKeyState(0, kVK_Shift) <> 0) or
     (CGEventSourceKeyState(0, kVK_RightShift) <> 0) then Include(result, ssShift);
  if CGEventSourceKeyState(0, kVK_Command) <> 0 then Include(result, ssCommand);
  if CGEventSourceKeyState(0, kVK_Option) <> 0 then Include(result, ssAlt);
  if CGEventSourceKeyState(0, kVK_Control) <> 0 then Include(result, ssCtrl);
{$ENDIF}
{$IFDEF MSWINDOWS}
  if GetKeyState(VK_Shift)<0 then Include(result, ssShift);
  if GetKeyState(VK_Menu)<0 then Include(result, ssAlt);
  if GetKeyState(VK_Control) <> 0 then Include(result, ssCtrl);
{$ENDIF}
{$IFDEF Android}
  if GetKeyState(VK_Shift)<0 then Include(result, ssShift);
  if GetKeyState(VK_Menu)<0 then Include(result, ssAlt);
  if GetKeyState(VK_Control) <> 0 then Include(result, ssCtrl);
{$ENDIF}
end;

function isShift: boolean;
const
  kVK_Shift                     = $38;
  kVK_RightShift                = $3C;
begin
{$IFDEF MACOS}
  result := (CGEventSourceKeyState(0, kVK_Shift) <> 0) or
            (CGEventSourceKeyState(0, kVK_RightShift) <> 0);
{$ENDIF}
{$IFDEF MSWINDOWS}
  result := GetKeyState(VK_Shift)<0
{$ENDIF}
{$IFDEF Android}
  result := GetKeyState(VK_Shift)<0
{$ENDIF}
end;

procedure CentreForm(aForm : TForm);
begin
    aForm.left := (Application.MainForm.Width - aForm.Width) div 2 + Application.MainForm.Left;
    aForm.top := (Application.MainForm.Height - aForm.Height) div 2 + Application.MainForm.Top;
end;

(************** XML *************)

function writeStringXML(ANode : IXMLNOde;Nom,valeur : string) : IXMLNODE;
var newNode : IXMLNode;
begin
    newNode := Anode.AddChild(Nom);
    newNode.nodeValue := valeur;
    result := newNode;
end;

function writeIntegerXML(ANode : IXMLNOde;Nom : string;valeur : integer) : IXMLNOde;
var newNode : IXMLNode;
begin
    newNode := Anode.AddChild(Nom);
    newNode.nodeValue := intToStr(valeur);
    result := NewNode;
end;

function writeColorXML(ANode : IXMLNOde;Nom : string;AColor : TAlphaColor) : IXMLNode;
var newNode : IXMLNode;
begin
    newNode := Anode.AddChild(Nom);
    newNode.nodeValue := intToStr(colorToInt(AColor));
    result := newNode;
end;

function writeBoolXML(ANode : IXMLNOde;Nom : string;valeur : boolean) : IXMLNode;
var newNode : IXMLNode;
begin
    newNode := Anode.AddChild(Nom);
    if valeur
       then newNode.nodeValue := '1'
       else newNode.nodeValue := '0';
    result := newNode;
end;

function writeDateTimeXML(ANode : IXMLNOde;Nom : string;valeur : TDateTime) : IXMLNode;
var newNode : IXMLNode;
begin
    newNode := Anode.AddChild(Nom);
    newNode.nodeValue := valeur;
    result := newNode;
end;

function writeFloatXML(ANode : IXMLNOde;Nom : string;valeur : double) : IXMLNode;
var newNode : IXMLNode;
begin
    newNode := Anode.AddChild(Nom);
    newNode.nodeValue := FloatToStrPoint(valeur);
    result := newNode;
end;

Function GetIntegerXML(ANode : IXMLNOde) : integer;
var s : string;
begin
     s := ANode.NodeValue;
     result := StrToInt(s);
end;

Function GetIntegerAttribute(ANode : IXMLNOde;genre : string) : integer;
var s : string;
begin
     try
     s := ANode.Attributes[genre];
     result := StrToInt(s);
     except
        result := 0;
     end;
end;

Function GetBoolXML(ANode : IXMLNOde) : boolean;
var s : string;
begin
     s := ANode.NodeValue;
     result := s<>'0';
end;

Function GetFloatXML(ANode : IXMLNOde) : double;
var s : string;
begin
     try
     s := ANode.NodeValue;
     result := StrToFloatWin(s);
     except
         result := Nan;
     end;
end;

function getColorXML(ANode : IXMLNOde) : TAlphaColor;
var i : longWord;
begin
     try
     i := strToInt(ANode.NodeValue);
     result := IntToColor(i);
     except
       result := claBlack;
     end;
end;

{$IFDEF Debug}

procedure ecritDebug(s : string);
begin
{$IFDEF  MSWINDOWS}
      append(fichierDebug);
      writeln(fichierDebug,s);
      flush(fichierDebug);
      closeFile(fichierDebug);
{$ENDIF}
end;
{$ENDIF}

// permet de retrouver un repertoire d'après sa valeur CSIDL
{$IFDEF  MSWINDOWS}

Procedure AddBackSlash(var aPath : String);
Begin
  If (aPath <> '') and
     (aPath[Length(aPath)] <> '\') Then
         aPath := aPath + '\';
End;

Procedure RemoveBackSlash(var aPath : String);
var long : integer;
Begin
  Long := Length(aPath);
  If (aPath <> '') and
     (aPath[Long] = '\') Then
         delete(aPath,Long-1,1);
End;

{$ENDIF}

Initialization
     applicationPath := System.IOUtils.TPath.GetDirectoryName(ParamStr(0));
     HomePath := System.IOUtils.TPath.getHomePath;
     DocumentsPath := System.IOUtils.TPath.getDocumentsPath;
     DocumentsPath := System.IOUtils.TPath.combine(DocumentsPath,'Regressi');
     system.sysUtils.forceDirectories(DocumentsPath); // création si nécessaire
     supportPath := System.IOUtils.TPath.GetLibraryPath;
     tempPath := System.IOUtils.TPath.GetTempPath;
     cachePath := System.IOUtils.TPath.GetCachePath;
     supportPath := System.IOUtils.TPath.combine(supportPath,'Regressi');
     system.sysUtils.forceDirectories(supportPath); // création si nécessaire
     HelpPath := 'https://regressi.fr/Regressihtml';
{$IFDEF MACOS}
     HelpFile := System.IOUtils.TPath.combine(recupereBundle,'Regressi.Help/Regressi.pdf');
     HelpHtml := System.IOUtils.TPath.combine(recupereBundle,'Aide/Regressi.html');
     ExemplesPath := System.IOUtils.TPath.combine(recupereBundle,'StartUp');
{$ELSE} // Windows
     HelpFile := System.IOUtils.TPath.combine(homePath,'regressi.pdf');
     HelpHtml := System.IOUtils.TPath.combine(DocumentsPath,'Aide');
     HelpHtml := System.IOUtils.TPath.combine(helpHtml,'Regressi.html');
     ExemplesPath := System.IOUtils.TPath.combine(homePath,'Exemples');
{$ENDIF}
     RegistreReg := System.IOUtils.TPath.combine(supportPath,'Regressi.ini');
     NomFichierTampon := System.IOUtils.TPath.combine(supportPath,'regWinMac.rw3');  // tampon conversion regressi Mac -> Win
     NomTamponPdf := System.IOUtils.TPath.combine(supportPath,'regWinMac.bmp');  // tampon image fenêtres vers pdf
     precision := 4;
     GraduationPi := false;
     SuiteCaracGrandeur := ['''','%','"','0'..'9']; // '_' utilisé pour unité
     avecOptionsXY := true;
     ImprimanteDisponible := true;

{$IFDEF Debug}
{$IFDEF MACOS}
{$ELSE} // Windows
      assignFile(fichierDebug,DocumentsPath+'\Regressi.txt');
      rewrite(fichierDebug);
      writeln(fichierDebug,'Regressi ffmpeg 25/06/2019');
      flush(fichierDebug);
      closeFile(fichierDebug);
{$ENDIF}
{$ENDIF}

end.


