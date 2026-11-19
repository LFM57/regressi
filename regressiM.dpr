program regressiM;

uses
  System.StartUpCopy,
  FMX.Forms,
  about in 'about.pas' {AboutBox},
  choixmodele in 'choixmodele.pas' {ChoixModeleDlg},
  compile in 'compile.pas',
  constreg in 'constreg.pas',
  coordphys in 'coordphys.pas' {FcoordonneesPhys},
  cursdata in 'cursdata.pas' {ReticuleDataDlg},
  fft in 'fft.pas',
  fmath in 'fmath.pas',
  fspec in 'fspec.pas',
  graphfft in 'graphfft.pas' {FGrapheFFT},
  graphker in 'graphker.pas',
  lecttext in 'lecttext.pas' {LectureTexteDlg},
  maths in 'maths.pas',
  modelegr in 'modelegr.pas',
  modif in 'modif.pas' {ModifDlg},
  newvar in 'newvar.pas' {NewVarDlg},
  optcolordlg in 'optcolordlg.pas' {OptionCouleurDlg},
  optfft in 'optfft.pas' {OptionsFFTDlg},
  options in 'options.pas' {OptionsDlg},
  optionsFiltrageU in 'optionsFiltrageU.pas' {OptionsFiltreDlg},
  optionsvitesse in 'optionsvitesse.pas' {OptionsVitesseDlg},
  optline in 'optline.pas' {OptionLigneDlg},
  optModele in 'optModele.pas' {OptionModeleDlg},
  PropCourbe in 'PropCourbe.pas' {PropCourbeForm},
  regMain in 'regMain.pas' {FRegressiMain},
  regprint in 'regprint.pas' {PrintDlg},
  regutil in 'regutil.pas',
  selpage in 'selpage.pas' {SelectPageDlg},
  statCalc in 'statCalc.pas',
  supprdlg in 'supprdlg.pas' {SuppressionDlg},
  systdiff in 'systdiff.pas',
  uniteker in 'uniteker.pas',
  valeurs in 'valeurs.pas' {FValeurs},
  varkeyb in 'varkeyb.pas' {NewClavierDlg},
  MyShape in 'MyShape.pas',
  optStat in 'optStat.pas' {StatOptDlg},
  graphevariabU in 'graphevariabU.pas',
  Images in 'Images.pas' {ImagesData: TDataModule},
  grapheParamU in 'grapheParamU.pas',
  regfile in 'regfile.pas',
  modeleNum in 'modeleNum.pas',
  aideKey in 'aideKey.pas',
  ChoixParamAnim in 'ChoixParamAnim.pas' {ParamAnimationDlg},
  AideU in 'AideU.pas' {AideForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFRegressiMain, FRegressiMain);
  Application.CreateForm(TImagesData, ImagesData);

  Application.Run;
end.
