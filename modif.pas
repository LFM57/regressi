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
    procedure EditNomKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
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

procedure TModifDlg.EditNomKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
    FRegressiMain.VerifGrec(sender,key,keychar,shift);
end;

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

Function SetNom : boolean;
var newNom,oldNom : string;
    longueurNom : integer;

Function ModifExpression(tampon : string) : string;
var posNom,suiteNom : integer;
    debutCorrect,FinCorrect : boolean;
begin
     if LongueurNom=0 then begin
        result := tampon;
        exit;
     end;
     posNom := system.strUtils.PosEx(oldNom,tampon,1);
     while posNom>0 do begin
           debutCorrect := (posNom=1) or
               charinset(tampon[pred(posNom)],['=',' ','(','''','*','+','-','/']);
           suiteNom := posNom+LongueurNom;
           finCorrect := (suiteNom=length(tampon)+1) or
                  charinset(tampon[suiteNom],['*','+','-','/',':',')','^',',',' ']);
           if debutCorrect and finCorrect then begin
                delete(tampon,posNom,LongueurNom);
                insert(NewNom,tampon,posNom);
                posNom := system.strUtils.PosEx(oldNom,tampon,posNom+length(NewNom));
           end
           else posNom := system.strUtils.PosEx(oldNom,tampon,posNom+1);
      end;
      result := tampon;
end;

var i : integer;
begin
       result := true;
       oldNom := grandeurModif.nom;
       newNom := editNom.text;
       trimComplet(newNom);
       if newNom=oldNom then exit;
       if not NomCorrect(newNom,indexV) then begin
          afficheErreur(codeErreurC,0);
          editNom.setFocus;
          ModalResult := mrNone;
          result := false;
          exit;
       end;
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
     if editNom.enabled and (grandeurModif.nom<>EditNom.Text) and not setNom then exit;
     with grandeurModif do begin
         formatU := TnombreFormat(PrecisionCB.itemIndex);
         fonct.expression := EditComm.text;
         precisionU := round(precisionSE.value);
         AffSignif := AffSignifCB.isChecked;
     end;
end; // OKBtnClick

procedure TModifDlg.PrecisionCBChange(Sender: TObject);
begin
     if PrecisionCB.itemIndex<0 then begin
        LabelPrecision.visible := false;
        PrecisionSE.visible := false;
        exit;
     end;
     case TnombreFormat(PrecisionCB.itemIndex) of
          fExponent : begin
             LabelPrecision.visible := true;
             LabelPrecision.Text := 'Nombre de chiffres';
             PrecisionSE.min := 2;
             PrecisionSE.max := 12;
          end;
          fFixed : begin
             LabelPrecision.visible := true;
             LabelPrecision.Text := 'Nombre de décimales';
             PrecisionSE.min := 0;
             PrecisionSE.max := 12;
          end;
          fBinary, fHexa : begin
             LabelPrecision.visible := true;
             LabelPrecision.Text := 'Nombre de bits';
             PrecisionSE.min := 1;
             PrecisionSE.max := 8;
          end;
          else LabelPrecision.visible := false;
     end;
     PrecisionSE.visible := LabelPrecision.visible;
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
