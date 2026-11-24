unit supprdlg;

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
  FMX.TreeView,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform,
  FMX.Controls.Presentation,

  compile,
  constreg,
  maths,
  regutil,
  images;

type
  Toperation = (oSuppression,oTriVariable,oPhase,oFFT);

  TSuppressionDlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    ListeVariableBox: TListBox;
    Label1: TLabel;
    Label2: TLabel;
    TriCB: TCheckBox;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
     nomDefaut : string;
     Operation : Toperation;
  end;

var
  SuppressionDlg: TSuppressionDlg;

implementation

uses valeurs, regmain;

{$R *.FMX}

procedure TSuppressionDlg.FormShow(Sender: TObject);
var i : codeGrandeur;
    ajoute : boolean;
begin
     inherited;
     TriCB.Visible := operation=oTriVariable;
     TriCB.IsChecked  := FichierTrie;
     ListeVariableBox.Items.Clear;
     ListeVariableBox.multiSelect := false;
     with grandeurs[0] do
         if fonct.genreC=g_experimentale then ListeVariableBox.Items.add(nom);
     label2.Text  := '';
     case operation of
              oTriVariable : begin
                 caption := stTriVariab;
                 label1.Text  := hTriDataDlg;
                 label2.Text  := hTriVariab;
              end;
              oSuppression : begin
                  caption := stSupprGrandeur;
                  label1.Text  := hSupprCalc;
                  label2.Text  := hSupprLigne;
              end;
              oPhase : begin
                  caption := stPhaseContinue;
                  label1.Text  := hTriPhase;
                  label2.Text  := hMod2Pi;
              end;
              oFFT : begin
                 caption := 'Fourier';
                 ListeVariableBox.multiSelect := true;
                 label1.Text  := 'Fourier';
              end;
     end;
     for i := 1 to pred(NbreGrandeurs) do with grandeurs[i] do begin
         case operation of
              oTriVariable : ajoute := (genreG=variable);
              oSuppression : ajoute := (fonct.genreC=g_experimentale) or
                                       (fonct.genreC=g_texte);
              oPhase : ajoute := (genreG=variable) and
                                 ((fonct.genreC=g_experimentale) or
                                  (isAngle));
              oFFT : ajoute := (genreG=variable) and
                               (fonct.genreC<>g_texte);
              else ajoute := false;
         end; // case operation
         if ajoute then ListeVariableBox.Items.add(nom);
     end;
     ListeVariableBox.itemIndex := ListeVariableBox.Items.indexOf(NomDefaut);
     ListeVariableBox.repaint;
end;

procedure TSuppressionDlg.OKBtnClick(Sender: TObject);
var i,index : integer;
    p : codePage;
    sauveGrandeur : Tgrandeur;
    DeuxPi : double;
    g : tgrandeur;
    posErreur,longErreur : integer;
    indexNew : integer;
begin
     try
     index := indexNom(ListeVariableBox.items[ListeVariableBox.itemIndex]);
     except
     index := grandeurInconnue;
     end;
     if index<>grandeurInconnue then
     case operation of
          oSuppression : if OKformat(trSupprVar,[grandeurs[index].nom]) then begin
              for i := succ(index) to pred(NbreGrandeurs) do with grandeurs[i].fonct do
                  if (genreC<>g_experimentale) and
                     (index in depend) then expression := '';
// désactiver toutes les grandeurs calculées fonction de grandeurs[index]
             SupprimeGrandeurE(index);
             ModifFichier := true;
             FRegressiMain.WMRegMaj(MajGrandeur);
          end;
          oPhase : if grandeurs[index].fonct.genreC=g_experimentale then begin
               if angleEnDegre then deuxPi := 360 else DeuxPi := 2*pi;
               for p := 1 to NbrePages do with Pages[p] do begin
                   for i := 1 to pred(nmes) do
                       ValeurVar[index,i] := ValeurVar[index,i]-
                             round((ValeurVar[index,i]-ValeurVar[index,pred(i)])/DeuxPi)*DeuxPi
              end;
          end
          else begin
              G := Tgrandeur.create;
              G.Init( grandeurs[index].nom+'C', grandeurs[index].nomUnite,'PhaseC('+grandeurs[index].nom+')',variable);
              include(G.fonct.depend,index);
              if G.compileG(posErreur,longErreur,0) then begin
                 indexNew := ajouteGrandeurE(G);
                 ReCalculE;
                 FValeurs.Memo.Lines.Add(grandeurs[indexNew].nom+'='+grandeurs[indexNew].fonct.expression);
                 FRegressiMain.WMRegMaj(MajGrandeur);
                 ModifFichier := true;
              end
              else begin
                 afficheErreur(codeErreurC,0);
                 G.free;
              end;
          end; // phase
          oTriVariable : begin
               FichierTrie := false;
               if index<>0 then if grandeurs[index].fonct.genreC=g_experimentale
                  then begin
                     NomGrandeurTri := '';
                     sauveGrandeur := grandeurs[0];
                     grandeurs[0] := grandeurs[index];
                     grandeurs[index] := sauveGrandeur;
                     grandeurs[0].indexG := 0;
                     grandeurs[index].indexG := index;
                     for p := 1 to NbrePages do
                         pages[p].TransfereVariabP(0,index);
                  end
                  else begin
                     NomGrandeurTri := grandeurs[index].nom;
                     indexTri := index;
                  end
               else begin
                    NomGrandeurTri := grandeurs[0].nom;
                    indexTri := 0;
               end;
               for p := 1 to NbrePages do begin
                   pages[p].TriAfaire := true;
                   pages[p].tri;
               end;
               Fvaleurs.MajGridVariab := true;
               FichierTrie := TriCB.isChecked;
               FRegressiMain.WMRegMaj(MajTri);
          end; {TriVariable}
     end; {case}
end;

procedure TSuppressionDlg.CancelBtnClick(Sender: TObject);
begin
  if TriCB.visible then FichierTrie := TriCB.isChecked
end;

end.
