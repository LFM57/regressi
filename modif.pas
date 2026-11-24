unit modif;

interface

Uses
  System.SysUtils,
  System.StrUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.math,

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
  FMX.Spinbox,
  FMX.EditBox,
  FMX.Controls.Presentation,

  aideKey,
  compile,
  constreg,
  maths,
  regutil,
  uniteker,
  images;


type
  TModifDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    Label1: TLabel;
    Label2: TLabel;
    EditNom: TEdit;
    EditUnite: TEdit;
    PrecisionCB: TComboBox;
    Label4: TLabel;
    RazIncertitudeBtn: TButton;
    AffSignifCB: TCheckBox;
    GenreLabel: TLabel;
    LabelPrecision: TLabel;
    PrecisionSE: TSpinBox;
    EditComm: TEdit;
    EditComm_LBL: TLabel;
    EditIncertitude: TEdit;
    EditIncertitude_LBL: TLabel;
    IncertitudeHelpBtn: TButton;
    procedure OKBtnClick(Sender: TObject);
    procedure PrecisionCBChange(Sender: TObject);
    procedure RazIncertitudeBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
      grandeurModif : Tgrandeur;
      indexV : integer;
      oldFormatU : TnombreFormat;
  end;

var
  ModifDlg: TModifDlg;

implementation

uses Valeurs, options, regmain, AideU;

{$R *.FMX}

procedure TModifDlg.FormShow(Sender: TObject);
begin
grandeurModif := grandeurs[indexV];
with grandeurModif do begin
     EditNom.text := nom;
     EditNom.enabled := fonct.genreC=g_experimentale;
     GenreLabel.Text  := NomGenreGrandeur[genreG]+' '+nomGenreCalcul[fonct.genreC];
     EditUnite.text := nomUnite;
     EditUnite.Enabled := (fonct.genreC=g_experimentale);
     EditUnite.Visible := (fonct.genreC<>g_texte);
     EditComm.text := fonct.expression;
     EditComm.enabled := EditNom.enabled;
     PrecisionCB.itemIndex := ord(formatU);
     oldFormatU := formatU;
     PrecisionSE.value := precisionU;
     PrecisionCBChange(nil);
     EditIncertitude.text := incertCalc.expression;
     EditIncertitude.visible := (indexV<maxGrandeurs) and
                    (fonct.genreC=g_experimentale);
     RazIncertitudeBtn.visible := EditIncertitude.visible;
     AffSignifCB.IsChecked  := AffSignif;
end end;

procedure TModifDlg.OKBtnClick(Sender: TObject);

Procedure SetNom;
var newNom,oldNom : string;
    longueurNom : integer;

Function ModifExpression(tampon : string) : string;
var posNom,suiteNom : integer;
    debutCorrect,FinCorrect : boolean;
begin
     posNom := system.strUtils.PosEx(oldNom,tampon,0);
     while posNom>0 do begin
           debutCorrect := (posNom=1) or
               charinset(tampon[pred(posNom)],['=',' ','(','''','*','+','-','/']);
           suiteNom := posNom+LongueurNom;
           finCorrect := (suiteNom=length(tampon)+1) or
                  charinset(tampon[suiteNom],['*','+','-','/',':',')','^',',']);
           if debutCorrect and finCorrect then begin
                delete(tampon,posNom,LongueurNom);
                insert(NewNom,tampon,posNom);
           end;
           posNom := PosEx(oldNom,tampon,posNom);
      end;
      result := tampon;
end;

var i : integer;
begin
       oldNom := grandeurModif.nom;
       newNom := editNom.text;
       LongueurNom := length(oldNom);
       for i := 0 to pred(Fvaleurs.memo.lines.count) do
           Fvaleurs.memo.lines[i] := ModifExpression(Fvaleurs.memo.lines[i]);
       for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
           incertCalc.expression := ModifExpression(incertCalc.expression);
       grandeurModif.nom := newNom;
       if indexV<MaxGrandeurs then begin
          FRegressiMain.WMregmaj(MajNom);
          oldFormatU := grandeurModif.formatU; { mise à jour faite par majNom }
       end;
end;

Function SetUnites : boolean;
var U : Tunite;
    UniteOK : boolean;
    i : integer;
begin
    result := true;
    if grandeurModif.nomUnite<>EditUnite.Text then begin
          U := Tunite.create;
          U.NomUnite := editUnite.text;
          UniteOK := U.correct;
          U.free;
          if not UniteOK and not OKReg(OkUniteInconnue,HELP_Unites) then begin
             EditUnite.setFocus;
             result := false;
             ModalResult := mrNone;
             exit;
          end;
          grandeurModif.NomUnite := EditUnite.text;
          if (IndexV<>cFrequence) then
             for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
                 if (nomUnite='') or not uniteDonnee then SetUnite;
          if indexV>maxGrandeurs
             then FRegressiMain.WMRegMaj(MajUnitesParam)
             else FRegressiMain.WMRegMaj(MajUnites);
     end;
end; // SetUnites

Function SetIncertitude : boolean;
var posErreur,LongErreur,k : integer;
    p : codePage;
begin
    result := true;
    if indexV=cFrequence then exit;
    if (indexV<maxGrandeurs) and
       (grandeurModif.IncertCalc.expression<>editIncertitude.text) then begin
           grandeurModif.IncertCalc.expression := editIncertitude.text;
           TrimComplet(grandeurModif.IncertCalc.expression);
           if grandeurModif.compileIncert(indexV,posErreur,LongErreur)
              then begin
                  for p := 1 to NbrePages do begin
                      for k := indexV to pred(NbreGrandeurs) do
                          pages[p].recalculIncert(k);
                  end;
                  FRegressiMain.WMRegMaj(MajIncertitude)
              end
              else begin
                 afficheErreur(codeErreurC,0);
                 editIncertitude.setFocus;
                 result := false;
                 ModalResult := mrNone;
              end;
       end; // if incert
end; // SetIncertitude

begin
     if not setIncertitude then exit;
     if not setUnites then exit;
     with grandeurModif do begin
         formatU := TnombreFormat(PrecisionCB.itemIndex);
         if editNom.enabled and (nom<>EditNom.Text) then setNom;
         fonct.expression := EditComm.text;
         precisionU := round(precisionSE.value);
         AffSignif := AffSignifCB.isChecked;
     end;
end; // OKBtnClick

procedure TModifDlg.PrecisionCBChange(Sender: TObject);
const
     text : array[1..5] of string =
          ('chiffres','décimales','chiffres',
           'bits','bits');
     Min : array[1..5] of integer = (2,0,2,1,1);
     Max : array[1..5] of integer = (12,12,12,8,8);
begin
     LabelPrecision.visible := (PrecisionCB.itemIndex>0) and
                               (PrecisionCB.itemIndex<6);
     PrecisionSE.visible := LabelPrecision.visible;
     if LabelPrecision.visible then begin
         LabelPrecision.Text  := 'Nombre de '+text[PrecisionCB.itemIndex];
         PrecisionSE.min := min[PrecisionCB.itemIndex];
         PrecisionSE.max := max[PrecisionCB.itemIndex];
     end;
end;

procedure TModifDlg.RazIncertitudeBtnClick(Sender: TObject);
var p : codePage;
    j : integer;
begin
     if indexV>=maxGrandeurs then exit;
     grandeurModif.IncertCalc.expression := '';
     editIncertitude.text := '';
     for p := 1 to NbrePages do with pages[p] do
         case grandeurModif.genreG of
              variable : for j := 0 to pred(nmes) do
                  incertVar[indexV,j] := Nan;
              constante : incertConst[indexV] := Nan;
              constanteGlb : grandeurModif.incertCourante := Nan;
         end;
end;


procedure TModifDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
