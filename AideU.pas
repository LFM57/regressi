// This software is Copyright (c) 2015 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

unit AideU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Edit,
  FMX.WebBrowser, FMX.Layouts, FMX.Controls.Presentation,
  regutil, aideKey;

type
  TAideForm = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure WebBrowser1DidFailLoadWithError(ASender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FHelpContext: Integer;
    procedure LoadHelp;
  public
    property HelpContext: Integer read FHelpContext write FHelpContext;
  end;

var
  AideForm: TAideForm;

procedure ShowAide(AContext: Integer = 0; AModal: Boolean = False);

implementation

{$R *.fmx}

function HelpTopicForContext(AContext: Integer): string;
begin
  case AContext of
    HELP_PageCalculee: Result := 'Pagecalculee.html';
    HELP_Animation: Result := 'Animation.html';
    HELP_BarreOutils: Result := 'Barredoutils.html';
    HELP_BarreEtat: Result := 'Barredetat.html';
    HELP_Bornes: Result := 'Bornes.html';
    HELP_Origine: Result := 'Origine.html';
    HELP_EditionCollerDonnees: Result := 'EditionCollerdonnees.html';
    HELP_Complexes: Result := 'Complexes.html';
    HELP_Coordonnees: Result := 'Coordonnees.html';
    HELP_PageCopie: Result := 'Pagecopiee.html';
    HELP_DeriveIntegrale: Result := 'Deriveeetintegrale.html';
    HELP_DivergenceModelisation: Result := 'Divergencedunemodelisation.html';
    HELP_Expressions: Result := 'Expressions.html';
    HELP_Constantes: Result := 'Constantes.html';
    HELP_Valeurs: Result := 'Valeurs.html';
    HELP_EcartModelisationExperience: Result := 'Ecartmodelisationexperience.html';
    HELP_Editeur: Result := 'Editeur.html';
    HELP_Equations: Result := 'Equations.html';
    HELP_ErreurDomaineDefinition: Result := 'Erreurdedomainededefinition.html';
    HELP_FenetreFourier: Result := 'FenetreFourier.html';
    HELP_FenetreGrandeurs2: Result := 'Fenetregrandeurs.html';
    HELP_FenetreGraphe: Result := 'Fenetregraphe.html';
    HELP_FenetreParametres: Result := 'Fenetreparametres.html';
    HELP_FenetreStatistique: Result := 'Fenetrestatistique.html';
    HELP_FichierAjouter: Result := 'FichierFusionner.html';
    HELP_EntreeDonneesClavier: Result := 'Entreededonneesauclavier.html';
    HELP_FichierNouveauSimulation: Result := 'FichierNouveauSimulation.html';
    HELP_FichierOuvrir: Result := 'FichierOuvrir.html';
    HELP_FichierImprimer: Result := 'FichierImprimer.html';
    HELP_Filtres: Result := 'Filtres.html';
    HELP_Fonctions: Result := 'Fonctions.html';
    HELP_FonctionsGestionDates: Result := 'Fonctionsdegestiondesdates.html';
    HELP_FonctionsParticulieres: Result := 'Fonctionsparticulieres.html';
    HELP_FonctionsStatistiques: Result := 'Fonctionsstatistiques.html';
    HELP_Grandeur: Result := 'Grandeurs.html';
    HELP_Impression: Result := 'Impression.html';
    HELP_IndexRegressi: Result := 'IndexRegressi.html';
    HELP_Liens: Result := 'Liens.html';
    HELP_ModelisationGraphique: Result := 'Modelisationgraphique.html';
    HELP_MenuEdition: Result := 'MenuEdition.html';
    HELP_MenuFichier: Result := 'MenuFichier.html';
    HELP_MenuPages: Result := 'MenuPages.html';
    HELP_Modelisation, HELP_ValeurModele: Result := 'Modelisation.html';
    HELP_Options: Result := 'Options.html';
    HELP_OptionsFourier: Result := 'OptionsFourier.html';
    HELP_OptionsGraphe: Result := 'Optionsgraphe.html';
    HELP_OptionsModelisation: Result := 'Optionsdemodelisation.html';
    HELP_OptionsStatistique: Result := 'Optionsstatistique.html';
    HELP_OptionsTexte: Result := 'Optionstexte.html';
    HELP_OptionsVecteurs: Result := 'Optionsdesvecteurs.html';
    HELP_OutilsGraphiques: Result := 'Outilsgraphiques.html';
    HELP_Residus: Result := 'Residus.html';
    HELP_SauvegardeModelisation: Result := 'Sauvegardedelamodelisation.html';
    HELP_SauvegardePosition: Result := 'SauvegardePosition.html';
    HELP_SuppressionPoints: Result := 'Suppressiondepoints.html';
    HELP_Timeout: Result := 'Timeout.html';
    HELP_Trigonometrie: Result := 'Trigonometrie.html';
    HELP_Unites: Result := 'Unites.html';
    HELP_ParametreVolatil: Result := 'Parametrevolatil.html';
    HELP_Calculs: Result := 'Calculs.html';
    HELP_Modelisation0: Result := 'Modelisation1.html';
    HELP_Graphique: Result := 'Graphique.html';
    HELP_Fourier: Result := 'Fourier.html';
    HELP_Statistiques: Result := 'Statistiques.html';
    HELP_Pages: Result := 'Pages.html';
    HELP_General: Result := 'General.html';
    HELP_Euler: Result := 'MethodedEulersimulation.html';
    HELP_FenetreGrandeurs0: Result := 'Fenetregrandeurs1.html';
  else
    Result := '';
  end;
end;

procedure ShowAide(AContext: Integer = 0; AModal: Boolean = False);
begin
  if AideForm = nil then
    Application.CreateForm(TAideForm, AideForm);
  AideForm.HelpContext := AContext;
  CentreForm(AideForm);
  if AModal then
    AideForm.ShowModal
  else begin
    if AideForm.Visible then
      AideForm.LoadHelp;
    AideForm.Show;
  end;
end;

procedure TAideForm.LoadHelp;
var
  BaseUrl, Topic: string;
begin
  BaseUrl := HelpHtml;
  if not FileExists(BaseUrl) then
    BaseUrl := TPath.Combine(applicationPath, TPath.Combine('Aide', 'Regressi.html'));
  if not FileExists(BaseUrl) then
    BaseUrl := HelpPath + '/Regressi.html';
  Topic := HelpTopicForContext(FHelpContext);
  if Topic <> '' then
    WebBrowser1.URL := BaseUrl + '?' + Topic
  else
    WebBrowser1.URL := BaseUrl;
end;

procedure TAideForm.FormShow(Sender: TObject);
begin
  LoadHelp;
end;

procedure TAideForm.WebBrowser1DidFailLoadWithError(ASender: TObject);
begin
  ShowMessage('Impossible de trouver ' + WebBrowser1.URL);
end;


end.
