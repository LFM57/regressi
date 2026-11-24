unit newvar;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,

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

  aidekey,
  compile,
  constreg,
  maths,
  regutil,
  uniteker,
  images;


type
  TNewVarDlg = class(TForm)
    Panel1: TPanel;
    OKBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    Panel2: TPanel;
    PageControl: TTabControl;
    VarDeriveeYCB: TComboBox;
    VarDeriveeXCB: TComboBox;
    Label4: TLine;
    VarLisseCB: TComboBox;
    OrdreLissageSE: TSpinBox;
    Label11: TLabel;
    NomEdit: TEdit;
    Label1: TLabel;
    UniteEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    SignifEdit: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    NomDerivee: TLabel;
    LabelDiff: TLabel;
    VarIntgCB: TComboBox;
    IntegraleEdit: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    FonctionEdit: TEdit;
    Bevel1: TPanel;
    Label9: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    NomIntg: TLabel;
    NomFonction: TLabel;
    ExpVarSheet: TTabItem;
    ExpParSheet: TTabItem;
    FonctionSheet: TTabItem;
    DeriveeSheet: TTabItem;
    IntgSheet: TTabItem;
    LissageSheet: TTabItem;
    TexteVarSheet: TTabItem;
    CheckBox1: TCheckBox;
    ParametreDerivee: TCheckBox;
    OptionsDeriveeGB: TGroupBox;
    Label18: TLabel;
    Label19: TLabel;
    NbreSpinButton: TSpinBox;
    LissageRG: TSpinBox;
    GenreGrandeurPanel: TPanel;
    GenreGrandeurRG: TListBox;
    FonctionItem: TListBoxItem;
    DeriveeItem: TListBoxItem;
    IntgItem: TListBoxItem;
    LissageItem: TListBoxItem;
    TexteItem: TListBoxItem;
    VarExpItem: TListBoxItem;
    ParExpItem: TListBoxItem;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure GenreGrandeurPanelClick(Sender: TObject);
    procedure NomEditChange(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure EulerCBClick(Sender: TObject);
    procedure ParametreDeriveeClick(Sender: TObject);
    procedure GenreGrandeurRGClick(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
  public
    LigneInit,LigneCompile,LigneSignif : string;
    procedure Initialise(indexV : integer);
  end;

var
  NewVarDlg: TNewVarDlg;

const
    iVarExp = 0;
    iParamExp = 1;
    iFonction = 2;
    iDerivee = 3;
    iIntegrale = 4;
    iLissage = 5;
    iEquaDiff = 6;
    iVarTexte = 6;
    iParamTexte = 7;

implementation

uses RegMain, AideU;

{$R *.FMX}

type
    EcompileError = class(Exception);

procedure TNewVarDlg.FormCloseQuery(Sender: TObject;var CanClose: Boolean);
var g : tgrandeur;
    posErreur,longErreur,index : integer;
    NewNom : string;

procedure VerifExp(Agenre : TgenreGrandeur);
begin
    G.init(nomEdit.text,uniteEdit.text,'',Agenre);
    if codeErreurC<>'' then afficheErreur(codeErreurC,0);
    G.fonct.genreC := g_experimentale;
    G.genreG := Agenre;
end;

procedure VerifTexte(Agenre : TgenreGrandeur);
begin
    G.init(nomEdit.text,'','',Agenre);
    G.fonct.genreC := g_texte;
    G.genreG := Agenre;
    if not OKReg(OkNonNum,0)
       then CodeErreurC := erNonNum
end;

procedure VerifFonction;
var i : integer;
begin
     LigneCompile := NomEdit.text+'='+FonctionEdit.text;
     if uniteEdit.text<>'' then begin
        LigneCompile := LigneCompile + '_' +uniteEdit.text;
     end;
     G.Init(nomEdit.text,uniteEdit.text,FonctionEdit.text,variable);
     for i := 0 to pred(NbreGrandeurs) do include(G.fonct.depend,i);
     G.compileG(posErreur,longErreur,0);
     if (codeErreurC='') and (FonctionEdit.text='') then
         codeErreurC := erExpressionVide;
     if codeErreurC<>'' then begin
          afficheErreur(codeErreurC,0);
          FonctionEdit.setFocus;
          FonctionEdit.selStart := pred(posErreur);
          FonctionEdit.selLength := longErreur;
     end;
     if (codeErreurC='') and (G.nomUnite='') then G.setUnite;
end;

procedure VerifDerivee;
var xx,yy : codeGrandeur;
    i : integer;
begin
    xx := indexNom(VarDeriveeXCB.items[VarDeriveeXCB.itemIndex]);
    yy := indexNom(VarDeriveeYCB.items[VarDeriveeYCB.itemIndex]);
    LigneCompile := NomFonctionGlb[derivee]+
        '('+grandeurs[yy].nom+','+grandeurs[xx].nom;
    if ParametreDerivee.isChecked
      then LigneCompile := LigneCompile+','+intToStr(round(LissageRG.value)+1)+','+intToStr(round(NbreSpinButton.Value));
    LigneCompile := LigneCompile+')';
    G.Init(nomEdit.text,uniteEdit.text,LigneCompile,variable);
    for i := 0 to pred(NbreGrandeurs) do include(G.fonct.depend,i);
    if G.compileG(posErreur,longErreur,0)
       then begin
         LigneCompile := NomEdit.text+'='+LigneCompile;
         if G.nomUnite='' then
            G.AdUnite('-',grandeurs[yy],grandeurs[xx]);
       end
       else afficheErreur(codeErreurC,0);
end;

procedure VerifIntegrale;
var xx : codeGrandeur;
    i : integer;
begin
    xx := indexNom(VarIntgCB.items[VarIntgCB.itemIndex]);
    LigneCompile := NomFonctionGlb[integrale]+'('+IntegraleEdit.text+','+grandeurs[xx].nom+')';
    G.Init(nomEdit.text,uniteEdit.text,LigneCompile,variable);
    for i := 0 to pred(NbreGrandeurs) do include(G.fonct.depend,i);
    if G.compileG(posErreur,longErreur,0)
       then begin
          LigneCompile := NomEdit.text+'='+LigneCompile;
          if G.nomUnite='' then begin
             G.calcUnite(G.fonct.calcul.OperandGlb);
             G.PlusUnite(grandeurs[xx]);
          end;
       end
       else begin
          afficheErreur(codeErreurC,0);
          IntegraleEdit.setFocus;
          IntegraleEdit.selStart := pred(posErreur);
          IntegraleEdit.selLength := longErreur;
       end;
end;

procedure VerifLissage;
var xx : codeGrandeur;
begin
    xx := indexNom(VarLisseCB.items[VarLisseCB.itemIndex]);
    LigneCompile := NomFonctionGlb[lissage]+
       '('+grandeurs[xx].nom+','+IntToStr(round(OrdreLissageSE.value))+')';
    G.Init(nomEdit.text,'',LigneCompile,variable);
    if G.compileG(posErreur,longErreur,0)
       then begin
          G.recopieUnite(grandeurs[xx]);
          LigneCompile := NomEdit.text+'='+LigneCompile;
       end
       else afficheErreur(codeErreurC,0);
end;

Procedure MajOrdre; // à vérifier
var i,p,iCalc : integer;
    tampon : tgrandeur;
begin
    if (index < 0) or (index >= NbreGrandeurs) then exit;
    for i := 0 to pred(NbreVariab) do begin
        iCalc := indexVariab[i];
        if (iCalc <> index) and (grandeurs[iCalc].fonct.genreC<>g_experimentale) then begin
           for p := 1 to NbrePages do
               pages[p].transfereVariabP(index,iCalc);
           tampon :=  grandeurs[iCalc];
           grandeurs[iCalc] := grandeurs[index];
           grandeurs[index] := tampon;
           grandeurs[iCalc].indexG := iCalc;
           grandeurs[index].indexG := index;
           break;
        end;
    end;
end;

begin // FormCloseQuery
   if modalResult<>mrOK then begin
      canClose := true;
      exit;
   end;
   NewNom := NomEdit.text;
   trimComplet(NewNom);
   NomEdit.text := NewNom;
   LigneCompile := '';
   if signifEdit.text<>''
      then ligneSignif := ''''+NomEdit.text+'='+SignifEdit.text
      else ligneSignif := '';
   posErreur := 0;
   longErreur := 0;
   codeErreurC := '';
   if NomCorrect(NomEdit.text,grandeurInconnue)
       then begin
             G := Tgrandeur.create;
             G.NomUnite := UniteEdit.text;
             if not(G.correct) and not OKReg(OkUniteInconnue,HELP_Unites) then begin
                   G.free;
                   CanClose := false;
                   UniteEdit.setFocus;
                   exit;
             end;
      end
      else begin
            afficheErreur(codeErreurC,0);
            CanClose := false;
            NomEdit.setFocus;
            exit;
       end;
   codeErreurC := '';
   LigneInit := '';
   case GenreGrandeurRG.itemIndex of
         iVarExp : VerifExp(variable);
         iParamExp : VerifExp(constante);
         iFonction : VerifFonction;
         iDerivee : VerifDerivee;
         iIntegrale : VerifIntegrale;
         iLissage : VerifLissage;
         iVarTexte : VerifTexte(variable);
         iParamTexte : VerifTexte(constante);
   end;
   canClose := codeErreurC='';
   if canClose
      then begin
           index := ajouteGrandeurE(G);
           if (GenreGrandeurRG.itemIndex=iVarExp) and (index<>grandeurInconnue) then MajOrdre;
           if not (genreGrandeurRG.itemIndex in [iVarTexte,iParamTexte])
              then ReCalculE;
           ModifFichier := true;
      end
      else G.free;
end; //FormClosequery

procedure TNewVarDlg.Initialise(indexV : integer);
var i : integer;
begin
     NomEdit.text := '';
     UniteEdit.text := '';
     SignifEdit.text := '';
     IntegraleEdit.text := '';
     FonctionEdit.text := '';

     VarIntgCB.Clear;
     for i := 0 to pred(NbreVariab) do with grandeurs[indexVariab[i]] do
         VarIntgCB.Items.Add(nom);
     VarLisseCB.Items.Assign(VarIntgCB.Items);
     VarDeriveeXCB.Items.Assign(VarIntgCB.Items);
     VarDeriveeYCB.Items.Assign(VarIntgCB.Items);
     VarLisseCB.ItemIndex := pred(NbreVariab);
     VarDeriveeXCB.ItemIndex := 0;
     VarDeriveeYCB.ItemIndex := 1;
     VarIntgCB.ItemIndex := 0;
     GenreGrandeurRG.itemIndex := indexV;
     PageControl.TabIndex := indexV;
     OptionsDeriveeGB.visible := ParametreDerivee.ischecked;
     LissageRG.visible := ParametreDerivee.IsChecked
end;

procedure TNewVarDlg.GenreGrandeurPanelClick(Sender: TObject);
begin
     PageControl.TabIndex := GenreGrandeurRG.itemIndex;
end;

procedure TNewVarDlg.GenreGrandeurRGClick(Sender: TObject);
begin
     PageControl.ActiveTab := PageControl.Tabs[GenreGrandeurRG.itemIndex]
end;

procedure TNewVarDlg.NomEditChange(Sender: TObject);
var prompt : string;
begin
     prompt := NomEdit.Text+'''';
     NomDerivee.Text  := NomEdit.text+'=';
     NomIntg.Text  := NomEdit.text+'=';
     NomFonction.Text  := NomEdit.text+'=';
end;

procedure TNewVarDlg.FormActivate(Sender: TObject);
begin
    inherited;
    LissageRG.value := DegreDerivee-1;
end;

procedure TNewVarDlg.EulerCBClick(Sender: TObject);
begin
    NomFonction.Text  := NomEdit.text+'=';
    if pos('[',FonctionEdit.text)>0 then FonctionEdit.text := '';
end;

procedure TNewVarDlg.ParametreDeriveeClick(Sender: TObject);
begin
  inherited;
  OptionsDeriveeGB.visible := ParametreDerivee.ischecked;
  LissageRG.visible := ParametreDerivee.IsChecked   
end;


procedure TNewVarDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.

