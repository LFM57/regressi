unit regLatex;

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
  FMX.Graphics,
  FMX.Controls.Presentation,

  aidekey,
  compile,
  constreg,
  graphker,
  regutil,
  valeurs,
  latex,
  grapheVariabU;

type
  TLatexDlg = class(TForm)
    PanelOption: TPanel;
    PrintBtn: TButton;
    CancelBtn: TButton;
    HelpBtn: TButton;
    Panel1: TPanel;
    GrandeursCB: TCheckBox;
    ModeleVariabCB: TCheckBox;
    GrapheVariabCB: TCheckBox;
    GrapheFourierCB: TCheckBox;
    GrapheStatCB: TCheckBox;
    GridParamCB: TCheckBox;
    SaveDialog: TSaveDialog;
    procedure PrintBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    nomFichier : string;
  public
  end;

var
  LatexDlg: TLatexDlg;

implementation

uses graphFft, optStat, regmain, uniteker, AideU;

{$R *.FMX}

procedure TLatexDlg.PrintBtnClick(Sender: TObject);

Procedure ImprimeParam;
begin
    if GridParamCB.isChecked then begin
        Fvaleurs.TraceGridParam;
        AjouteGrid(Fvaleurs.GridParam)
    end;
end;

Procedure ImprimeStat;
begin
      FRegressiMain.grapheStat.versLatex(NomFichier,'S');
      AjouteGrid(FRegressiMain.StatGrid);
      AjouteGrid(FRegressiMain.DistGrid)
end;

Procedure ImprimeFourier;
begin
      FgrapheFFT.grapheFrequence.versLatex(NomFichier,'F');
end;

procedure imprimeVariables;
var i : integer;
    nbreItem : integer;
    aligne : string;
    posEgal : integer;
    nomLu : string;
    indexG : codegrandeur;
begin
     for i := 0 to pred(Fvaleurs.memo.lines.count) do begin
           aligne := Fvaleurs.Memo.lines[i];
           if IsLigneComment(aligne)
              then AjouteLigne(copy(aligne,2,length(aligne)))
              else begin
                   posEgal := Pos('=',aligne);
                   nomLu := copy(aligne,1,pred(posEgal)); // extrait le nom
                   aligne := copy(aligne,succ(posEgal),length(aligne));// pour test forward
                   trimComplet(nomLu);
                   if nomLu[length(nomLu)]='''' then delete(nomLu,length(nomLu),1);
                   if nomLu[length(nomLu)]='''' then delete(nomLu,length(nomLu),1);
                   indexG := IndexNom(nomLu);
                   if (indexG<>GrandeurInconnue) and (aligne<>'') then AjouteGrandeur(indexG);
              end; // ligneCalcul
      end; // for i memo
      NbreItem := 0;
      for i := 0 to pred(NbreVariab) do with grandeurs[i] do
            if (fonct.genreC=g_experimentale) and
               (fonct.expression<>'') then
                   inc(NbreItem);
            if NbreItem>0 then begin
                if nbreItem>1 then AjouteLigne('\begin{itemize}') else ajouteLigne('');
                for i := 0 to pred(NbreVariab) do with grandeurs[i] do
                    if (fonct.genreC=g_experimentale) and
                       (fonct.expression<>'') then begin
                      if nbreItem>1
                         then AjouteLigneItem(nom+' : '+fonct.expression)
                         else AjouteLigne(nom+' : '+fonct.expression);
                    end;
                if nbreItem>1 then ajouteLigne('\end{itemize}') else ajouteLigne('');
            end;
end;// printVariables

Procedure ImprimerTableauVariab;
begin
      Fvaleurs.TraceGridVariab;
      AjouteParagraphe(pages[pageCourante].TitrePage);
//  AjouteGrid(Fvaleurs.GridVariab);
end;

var i : integer;
    page : integer;
    avecCouleur : boolean;
begin
    SaveDialog.DefaultExt := 'tex';
    SaveDialog.Filter := 'Fichiers LaTeX (*.tex)|*.tex';
    SaveDialog.Title := 'Sauvegarde au format Latex';
    if SaveDialog.Execute then begin
       nomFichier := ChangeFileExt(SaveDialog.FileName,'.tex');
       isUniteLatex := true;
       debutDoc('');
       try
       if GrandeursCB.IsChecked  then imprimeVariables;
// Modélisation
       if GridParamCB.isChecked then AjouteGrid(FValeurs.GridParam);
       if ModeleVariabCB.IsChecked then begin
              AjouteLigne(stModelisation);
              avecCouleur := (NbreModele+NbreFonctionSuper)>1;
              for i := 1to NbreModele do
                  ajouteModele(FonctionTheorique[i],avecCouleur);
              for i := 1 to NbreFonctionSuper do
                  ajouteModele(fonctionSuperposee[i],avecCouleur);
              AjouteLigne('');
              for page := 1 to NbrePages do
                 if pages[page].active then begin
                    AjouteLigne(pages[page].TitrePage);
                    FRegressiMain.MajResultatLatex(page); // pour mettre TexteResultatModele au format Latex
                    AjouteLigne('\begin{itemize}');
                    for i := 0 to pred(pages[page].TexteResultatModele.Count) do
                        AjouteLigneItem(pages[page].TexteResultatModele[i]);
                    AjouteLigne('\end{itemize}');
                 end;
          end;
// Graphe
       if GrapheVariabCB.ischecked then graphe.versLatex(NomFichier,'V');
       if GrapheFourierCB.IsChecked then ImprimeFourier;
       if GrapheStatCB.IsChecked then imprimeStat;
       finDoc;
       saveFile(NomFichier);
       except
            on E: Exception do begin
                showMessage(E.message);
                try
                except
                end;
            end;
       end;
       close;
       isUniteLatex := false;
    end;
end;

procedure TLatexDlg.FormActivate(Sender: TObject);
begin
    grapheFourierCB.Visible := FgrapheFFT<>nil;
    if not grapheFourierCB.Visible then grapheFourierCB.isChecked := false;
    grapheStatCB.Visible := statOptDlg<>nil;
    if not grapheStatCB.Visible then grapheStatCB.isChecked := false;
    ModeleVariabCB.Visible := (NbreModele+NbreFonctionSuper>0) and
                              (FRegressiMain.panelModele.visible or
                              (ModeleDefini in graphe.etatModele));
    if not ModeleVariabCB.Visible then modeleVariabCB.isChecked := false;
    GridParamCB.visible := (NbrePages>1) and ((NbreConst+NbreParam)>0);
    if not gridParamCB.Visible then gridParamCB.isChecked := false;
end;

procedure TLatexDlg.HelpBtnClick(Sender: TObject);
begin
  if Sender is TButton then
    ShowAide(TButton(Sender).HelpContext, True)
  else
    ShowAide(0, True);
end;

end.
