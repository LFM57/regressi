unit constreg;

interface

uses
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
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Platform;

Function stActive(isActive : boolean) : string;
Function stOuiNon(isOui : boolean) : string;

const
   captionTrigo : array[boolean] of string = ('rad',' ° ');

resourcestring

OkVarTri='Garder %s comme variable triée';
OkSauve='Sauvegarde de l''état courant ?';
OkMobile2='Deuxième mobile ?';
okPageVersCol = 'Transformer les pages en colonnes';
okNonNum = 'Utilisation d''une grandeur non numérique';
OkDelFile='Ecraser le fichier existant';
OkImprGr='Impression du graphe';
OkImprTab='Impression des tableaux';
OkDelData='Suppression des données sélectionnées';
OkDelAll='Effacement de la page courante';
OkUniteInconnue='Unité non reconnue vous confirmez ?';
OkNoParamAuto='Pas d''expression. Désactiver génération auto ?';
OkDelPage='Suppression de la page n°%s';
OkModifGr='Modification du graphe selon modèle ?';
OkImprModele='Impression de la modélisation';
OkInitParam='Initialisation des paramètres ?';
OkDelVariab='Ecraser l''ancienne variable %s';
OkBadDataNom='Données incompatibles (noms différents) on continue ?';
OkBadDataNewFile='Données incompatibles avec les données courantes => Créer un nouveau fichier ?';
OkImprTabVariab='Impression du tableau des variables';
OkModifOrigine='Effectuer le changement d''origine ?';
OkImprCurseur ='Impression des valeurs modélisées';
OkAngleDegre ='Angle en degré';
OkAngleRadian ='Angle en radian';
OkPaysage ='Impression avec orientation paysage';
okSupprIdentCoord ='Suppression des identifications de courbes';
okSupprAutresPages ='Suppresssion des points de toutes les pages actives';
okRazModele ='Remise à 1 des paramètres';
okRazParam ='Suppression de la modélisation';


erNotExists = ' n''existe plus';
erNonNum = 'Variable non numérique';
erEffectifNotInt = 'Effectif non entier !';
erPourCent = 'Somme des fréquences différente de 100 !'; // Sum of frequencies other than 100
erEchelle  = 'Echelle incorrecte'; // Incorrect scale
erPbImprimante='Impossible de se connecter à l''imprimante';
erPageModele='Syntaxe : y[numero de page]=f(x)';
erNomVide='Nom vide';
erDebutNom='Un nom doit commencer par une lettre'; // A name must begin with a letter
erNomInterdit='Nom interdit (j^2=-1 pi=3.1416)';
erNomFonction='Nom interdit (nom de fonction : Im Re Arg Min Max...)';
erNomExistant='Nom interdit (déjà existant)';
erMuette='Nom interdit pour une variable muette (déjà existant)';
erVarTexte='Calcul impossible avec une grandeur texte';
erUnite='Unité incorrecte';
erAire='''->La fonction aire(x,y) détermine l''aire d''une surface fermée';
erFileNotExist='Fichier non trouvé';
erCaracNom='Caractère interdit dans un nom';
erParamModeleVersExp='Utilisation d''un paramètre de modélisation (donc susceptible de disparaître)';  // Use of a modeling parameter (so that it may disappear)
erNbreGradManuel='Nombre de graduations <2 ou >64 => retour au mode automatique';
erOrtho='Vérifier l''option orthonormé dans la boite de dialogue coordonnées'; //  Check the orthonorm option in the Coordinate dialog box
erExpressionVide='Expression vide';
erTexteNotTest='Texte en dehors d''un IF';
erFonctionNil='Fonction non initialisée';
erNombrePetit='Modélisation impossible : nombre de valeurs < nombre de paramètres'; // Modeling not possible: number of values < number of parameters
erVide='Expression vide';
erNombre='Nombre mal écrit';
erTropLong='Identificateur trop long';
erInterne='Erreur interne';
erTropComplexe='Expression trop compliquée';
erParF='Manque )';
erParO='Manque (';
erParamSolve='Manque un paramètre : solve(equation,min,max)';
erParamMoyenne='Manque un paramètre : mean(variable,debut,fin)';
erVarInterdite='Variable interdite';
erParamInterdit='Paramètre interdit';
erTropParam='Trop de paramètres';
erVirgule='Manque ,';
erVarAttendue='Variable attendue';
erFonctNonCpx='Fonction interdite dans les complexes';
erOperNonCpx='Operateur interdit dans les complexes';
erReel='Le résultat doit être réel (Re;Im;Arg;Abs)';
erSyntaxe='Erreur de syntaxe';
erSyntaxeModele='Syntaxe du modèle : Y(X)=f(X)';
erVarInconnue='Variable non reconnue';
erDomaine='Fonction hors de son domaine de définition';
erDivergence='Divergence de la modélisation';
erTimeOut='Arrêt de la modélisation au bout de 32 itérations';
erNoData='Pas de données';
erPageCalc='Pas de zone commune entre les différentes pages';
erNombreVar='Pas assez de variables';
erDerNonDef='Dérivée non définie';
erSyst1Var='Système d''équa diff nécessite la même variable explicative';
erNonInstallee ='Fonction non installée';
erVarDef='Grandeur déjà définie';
erMaxModele='Nombre maximum de modèles : 4';
erEgalAbsent='Syntaxe des fonctions : nom=''expression';
erCaracInterdit='Caractère interdit'; // forbidden charac
erGenreModele='Les modèles doivent être de même type : fonction OU équa. diff. d''ordre 1 OU 2';
erVarOrNombre='Doit être un paramètre ou une valeur numérique';
erModeleGlb='Modélisation par fonction uniquement dans l''espace des paramètres';
erCurseurModele='Modélisation non accessible';
erNmesInf8='Nombre de points trop faibles';
erFormat='Format fichier incorrect';
erValeurNoDef = 'Valeur non définie dans la page n° ';
erOneCol = 'Une seule colonne à la fois';
erConst3D ='Crochets non permis'; // Hooks not permitted
erFonctionPageNonPermis ='Fonction page[n] non permise';
erParamInconnu ='Paramètre inconnu';
erGrandTableau ='Impression de grand tableau interdite';
erXOR='Opérateur interdit en dehors de IF';
erFileAdd='Erreur à la lecture du fichier';
erFileLoad='Impossible d''ajouter le fichier';
erModeleGr='Données non cohérentes avec le modèle';
erInitAdefinir='Donnez une valeur initiale dans l''onglet paramètres';
erConstNonDef='Valeur de paramètre expérimental absente';
erParamAdefinir='Donnez une valeur aux paramètres';
erSuperGlb='Superposition de fonction en construction';
erCurseurTangente='Impossible : abscisse<>première variable';
erGradNonLineaire='Impossible : graduations non linéaires';
erPrimeRRR='Caractère '' interdit dans les variables (réservé aux équa. différentielles)';
erDiffSimul='Le nombre maxi d''équations dans un système est de 4';
erEcart='Ecart modèle-expérience très grand vérifier vos paramètres';
erFonctionGlbIsole ='Les fonctions Intg Diff Harm Filtre ... doivent être utilisées isolément';
erVarFreq='Nom réservé pour les séries de Fourier';
erColPrinter='Nombre de colonnes trop grand : penser au mode paysage ou au couper-coller';
erBadDataNom='Données incompatibles : noms différents';
erSuperposePage='Positionnement de l''origine une page à la fois';
erBadDataInf='Données incompatibles : trop de grandeurs';
erBadDataSup='Données incompatibles : trop de grandeurs';
erSyntaxeDDE='Syntaxe Macro DDE : Fonction(Paramètre)';
erPuissEnt='Puissance non entière';
erPointModele='Un point non pris en compte : n°';
erDiff0='La variable explicative des équa. diff. est la première colonne';
erRemplitLog='Remplissage exponentiel avec valeur <= 0';
erModeleSystDiff='Système diff. uniquement';
erFileData='Données du fichier incorrectes';
erReadVotable ='N''est pas un fichier Votable';
erDOMXML = 'Parser XML non trouvé';
erProgAcq='Programme d''acquisition inconnu';
erDDE='Liaison DDE impossible avec ';
erIndexNotVariab ='Interdit en dehors des variables';
erCrochetF ='] attendu';
erPosMin ='Posmin; posmax remplacés par pos(variable;équation;[up|down|mini|maxi])';
erTangenteAgauche ='L''axe doit être à gauche';
erOrigineExp ='Modification uniquement pour grandeur expérimentale';
erModeleIncorrect ='Désactiver le mode superposition de pages';
erWriteFile ='Erreur d''écriture du fichier';
erReadFile ='Erreur de lecture du fichier';
erReadFileRXML ='N''est pas un fichier XML Regressi';
erFonctionPage ='page(nombre)';
erOriginePage ='Nécessite une seule page active';
erExposantCpx ='Exposant uniquement entier à l''intérieur des complexes';
erPrefixe ='Essayer de travailler en S.I. sans préfixe m k ... (sauf kg !)';
erUneLigneSurN ='Impression d''une ligne sur %s';
erAxeLog ='Axe log. ou dB impossible : valeurs <= 0 ?';
erDiff2 ='Equation différentielle d''ordre 1 ou 2';
erMotdepasse='Suppression du mot de passe';
erBoucleFor ='Syntaxe de boucle for i:=exp to exp do';
erFinBoucle ='end permis en fin de boucle';
erDataCan ='Données non modifiables (voir Options Acquisition)';
erChargeOldReg ='Rechargement du dernier fichier';
erForward ='Définir la grandeur prédéfinie par x= ou x[0]=a';
erGommeStat ='Sélectionnez les points sur l''axe des abscisses';
erLigneNulle ='Définition de ligne par glisser';
erFileCalc ='Nom de variables non compatibles';
erNbreData ='Pas assez de données';
erIndiceEuler = 'Syntaxe : x[i]= et non x[i+1]=';
erPeigneSimul = 'Peigne disponible uniquement en mode simulation';
erParamIF = 'UN argument manquant à IF(condition,si vraie,sifausse)';
erParamPW = 'Syntaxe PieceWise([test,then],else)';
erRadian = 'Passage en radian';
erVerifRadian = 'Actuellement en degré. Passage en radian ?';
erSyntaxeIncert='Syntaxe de l''incertitude type : u(X)';

stMoyenne = 'Moyenne ';  // Mean
stAideValide = '(validez avec Entrée)';
stMediane = 'Médiane ';
stEcartType = 'Ecart-type '; // Standard deviation
stMini = 'Mini';
stMaxi = 'Maxi';
stValeur = 'Valeur ';
stMinimum = 'Minimum';
stMaximum = 'Maximum';
stCible = 'Cible ';
stTaille = 'Taille ';
stOuvrir = 'Ouvrir';
hInitialise = 'Initialise';
stEtendue = 'Etendue : ';
stNom = 'Nom';
stSymbole = 'Symbole';
stUnite = 'Unité';
stSignif = 'Signification';
stBornesModele = 'Bornes et nouveau modèle';
stPente = 'Pente';
stPvaleur='P-valeur(';
stIntersection = 'Intersection' ;
stAngle = 'Angle';
stRayon = 'Rayon';
stAbscisse = 'Abscisse';
stOrdonnee = 'Ordonnée';
stInexactitude = 'Inexactitude';
stEquivalence = 'Equivalence';
stBorne = 'Bornes de ';
stBornes = 'Bornes';
stCourbe = 'Courbe ';
stReticule = 'Réticule';
stStatistique = 'Statistique : ';
stTableau = 'Tableau ';
stNbrePas = 'Nombre de pas : ';
stPage = 'Page';
stIncertitude = 'Incertitude'; // Uncertainty
stPages = 'Pages';
stOption = 'Option';
stPhase = 'Phase';
stPhaseContinue = 'Phase continue';
stContinu = 'Continu ';
stCouleur = 'Couleur';
stTest1 = 'Résultat d''un réglage manuel des paramètres. Pour optimiser, cliquer sur "ajuster"'; // Result of manual parameter adjustment. To optimize, click on "adjust".
stTest4 = 'Optimisation des paramètres à effectuer, cliquer sur "ajuster"'; // Optimization of the parameters to be carried out, click on "adjust".
stVariables = 'Variables';
stGrandeurs = 'Grandeurs';
stModelisation = 'Modélisation';
stAxes = 'Axes';
stIteration = 'Itération n°';
stIntervalle = 'ème intervalle';
stDerivee = 'Dérivée';
stAbsolue='absolue';
stRelative='relative';
stDbDecade = 'dB/décade';
stNbreDec ='Nombre de décimales';
stNbreChiffres ='Nombre de chiffres';
stNbreBits ='Nombre de bits';
stDebutDe = ' le début de ';
stFinDe = ' la fin de ';
stEcartQuad = 'Ecart quad. ';
stCoeffCorrel = 'Coeff. corrélation';
stGrad = 'Grad.';
stClicVecteur = 'Cliquer sur un point pour tracer (ou effacer) un vecteur';
stCaracStat = 'Caractéristique statistique de ';
stNomVariab = 'Nom des variables :';
stFinModele = 'Fin modélisation';
stValeurReticule = 'Valeurs du réticule';
stValeurModele = 'Valeurs modélisées';
stCommentaire = 'Commentaire';
stCalcVitesse = 'Calculer la vitesse !';
stCalcAcceleration = 'Calculer l''accélération !';
stCopiePage = 'Recopie de la page';
stGridValeurs = '&Tableau valeurs';
stRazValeurs = 'Rà&Z des valeurs';
stResultModele = 'Résultat de la modélisation';
stEcartRelatif = 'Ecart expérience-modèle';
stSigmay = 'Incert. (95%) sur ';
stTriVariab = 'Tri des données selon une variable';
stTriPages = 'Tri des pages selon un paramètre';
stSupprGrandeur = 'Suppression d''une grandeur';
stBorneSelect = 'Bornes à la souris|Définir les bornes en traçant un rectangle';
stBarreReticuleFFT = 'Barre d''espace: marque le pic proche';
stBarreReticule = 'Barre d''espace:laisse une trace (cf. clic droit tableau) ; ESC:fin';
stExper = ' expérimentale';
stVariable = 'Variable';
stConstante = 'Paramètre';
stParam = 'Paramètre de modélisation';
stTexte = ' texte';
stSigmaResidu = '(sigma des résidus)';
stEcart = 'écart = ';
stComment = 'Commentaires';
stAcqBy = 'Acquisition par ';
stEchantillon = 'Echantillonnage';
stCaracde = 'Caractéristiques de ';
stPrint = 'Impression';
stEnTete = 'En-tête';
stCibleAuto = 'Cliquer sur la cible à suivre';
stAjouteMod = '&Ajouter modèle';
stRemplaceMod = '&Remplacer modèle';
stModif = 'modifications de ';
stData = 'données';  // data
stSauve  = 'Sauvegarde des ';
stChoixPages = 'Choix des pages actives';
stUndo = 'Annuler suppression de ';
stNoAcces = 'Impossible d''accéder à ';
stMajImpossible = 'Impossible d''accéder au site de mise à jour';
stPageActive = 'Page active';
stPageInactive = 'Page inactive';
stOui = 'Oui';
stNon = 'Non';
stNewPage = 'Nouvelle page';
stIntervalle95 = 'Intervalle de confiance à 95%'; // 95% confidence interval
stOrigine  = 'Origine';
stExtremite = 'Extrémité';
staxeLog = 'Axe log.';
stAxeX = 'Axe horiz.';
stAxeY = 'Axe vert.';
stAxeT = 'index';

hSupprPoint ='Suppr : suppression du point cliqué ; barre : désactivation du point';
hMove ='Cliquer/déplacer pour modification de la position du zoom';
hValeurModele ='Entrez une valeur et validez pour calculer';
hGommeStat = 'Sélectionner à la souris (cliquer  déplacer) les points à supprimer'; // Select with the mouse (click move) the points to delete
hTriDataDlg = 'tri des données'; // Sort data
hTriVariab = 'selon la variable sélectionnée';
hSupprCalc = 'les variables calculées sont supprimées'; // the calculated variables are suppressed
hSupprLigne = 'en supprimant la ligne du mémo expression'; // by deleting the line in the expression memo
hTriPhase = 'rend continue la variable sélectionnée';
hMod2Pi = 'en effectuant un modulo 360°';
hZoomManuelDebloq = 'Echelle bloquée|Modification de l''échelle ou déblocage de celle-ci';
hZoomManuelBloq = 'Echelle manuelle|Définition manuelle de l''échelle et blocage de celle-ci';
hZoomAutoBloq = 'Echelle bloquée => retour à l''échelle automatique';
hCopyExpressions = 'Copier expressions|Copier l''ensemble du texte dans le presse-papiers';
hCopyGrid = 'Copier tableau|Copier le tableau dans le presse-papiers';
hTriData = 'Trier données|Trier les données selon la grandeur courante';
hDelta = 'Affiche, si enfoncé, l''incertitude sur les ';
hCurseurOrigine ='Placer le curseur sur la nouvelle origine';
hSelectPageMod = 'Choix des pages prises en compte dans la modélisation';
hReticuleModele ='Cliquer à l''intersection du réticule puis faire glisser ; F10:enregistre la position courante ; ESC=fin';
hClicDroit ='Utiliser le clic droit pour ouvrir le menu local';
hHistoResidu ='Histogramme des résidus';
hExpFFT ='Tapez une expression fonction de %s uniquement';
hIndice ='%s va de 0 à %s-1';
hEuler =' signifie valeur de x au point i';
hMoyenne = 'Abscisse=moyenne ; ordonnée=maximum';
hEcartType = 'Abscisse=moyenne+(ecart type)';
hDemiLargeur = 'Abscisse=moyenne+(demi largeur)';
hDebutModele ='Modéliser|Ouvrir le volet de modélisation';
hFinModele ='Fin modélisation|Fermer le volet de modélisation';
hGlisser ='Glisser pour déplacer';
hDbleTexte ='Clic droit pour modifier le texte ou supprimer';
hDbleCouleur ='Clic droit pour choix de couleur/style de la ligne ou suppression';
hOrigine ='Positionner la verticale à la nouvelle origine puis cliquer';
hSegment ='Cliquer à l''intersection du réticule puis faire glisser ; F10:enregistre la position courante ; ESC=fin';
trSupprVar ='Suppression de %s';
hRowUnit ='Double-clic dans l''en-tête pour modifier unité; incertitude';
hMovePoint ='Déplacer le point de référence';
hPeriode ='Abscisse=période ordonnée=décalage de zéro';
hMaxi ='Maximum du sinus : position et valeur';
hCteTemps ='Abscisse=constante de temps';
hAsymptote ='; ordonnée=asymptote';
hDirection = 'Direction';
hFinGomme ='Arrêt de suppression de points';
hEchelle = 'Echelle';
hOrigineXY = 'Origine des coordonnées';
hValeur0 ='; ordonnée=valeur initiale';
hClicPage ='(double clic sur le point pour changer l''état)';
hFreqCoupure ='abscisse : fréquence caractéristique';
hGainMax ='ordonnée : gain maximal';
hEchelleFreq = 'Cliquer déplacer les graduations pour changer l''échelle';
hValeurAsymptote =' 	Intersection des asymptotes';
hBornes = 'Bornes PUIS expression|Définir un nouveau modèle par un rectangle (bornes) PUIS taper la fonction';
hLigneRappel='Ligne de rappel|Style de trait des lignes de rappel';

implementation

Function stActive(isActive : boolean) : string;
begin
    if isActive then result := stPageActive else result := stPageInactive
end;

Function stOuiNon(isOui : boolean) : string;
begin
    if isOui then result := stOui else result := stNon
end;

end.


