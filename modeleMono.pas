// modeleMono.pas include de graphvar

Procedure TgrapheVariab.EffectueModeleMono(m : integer);
const LambdaMin = 1e-4;
      LambdaMax = 1e4;
var Lambda : double;
    diverge,stable : boolean;
    dependM : TsetGrandeur;

{------- boucle de recherche par méthode gradient-Newton -------}
var
   J,Jprecedent,chi2Precedent : double;
{ (FonctionTheorique(x,param)-FonctionExperimentale(x))^2
  coeffJ pour pondérer de manière égale deux modèles qqsoit les ordres de grandeur }
  derJ  : TableauParam;
{ derj = dérivée de J = (fonctionTheorique-Fexp)*dfonctionTheorique/dParam }
  der2J : MatriceParam;
{ der2j = dérivée seconde de J (approximative) =
  DfonctionTheorique/dparam*DfonctionTheorique/dparam
  on néglige (fonctionTheorique-Fexp)d2Fth/dparam*dparam }
  IncParam : TableauParam;

procedure calculPrecision;
var U,InvDer2j : MatriceParam;

procedure construireU;
var
   v : double;
   i,l,k : integer;
begin
 for i := 1 to NbreParam do
     for k := 1 to NbreParam do
         U[i,k] := 0;
 for i := 1 to NbreParam do
 if i in dependM then begin
     v := der2J[i,i]*(1+Lambda);
     try
     for k := 1 to pred(i) do v := v-sqr(U[k,i]);
     U[i,i] := sqrt(v);
     for l := succ(i) to NbreParam do begin
         v := der2J[l,i];
         for k := 1 to pred(i) do v:=v-U[k,i]*U[k,l];
         U[i,l] := v/U[i,i];
     end;
     except
        for l := 1 to NbreParam do begin
             U[i,l] := 0;
             U[l,i] := 0;
             der2J[l,i] := 0;
             der2J[i,l] := 0;
        end
      end
  end;
  for i := 1 to NbreParam do
  for k := 1 to NbreParam do
        invDer2J[i,k] := 0;
end;// construireU

procedure resoudreU(l : codeParam);
var i,k : integer;
    Y   : TableauParam;
    v   : double;
begin
    for i := 1 to NbreParam do
    if i in dependM then
    if U[i,i]= 0
        then Y[i] := 0
        else begin
           try
           if i=l then v := 1 else v := 0;
           for k := 1 to pred(i) do v := v-U[k,i]*Y[k];
           Y[i] := v/U[i,i];
           except
              Y[i] := 0
           end;
        end;
// passage à invder2J
     for i := NbreParam downto 1 do
     if i in dependM then begin
         v := Y[i];
         for k := succ(i) to NbreParam do
             v := v-U[i,k]*invDer2J[l,k];
         try
         invDer2J[l,i] := v/U[i,i];
         except
            invDer2J[l,i] := 0
         end;
    end;{i}
end;// resoudreU

var sigmaLoc : double;
    i,l : integer;
begin // calculPrecision
with pages[pageCourante],fonctionTheorique[m] do begin
  construireU;
  erreurCalcul := false;
  for i := 1 to NbreParam do
      if i in dependM then resoudreU(i);
  for i := 1 to NbreParam do if i in dependM then begin
     try
     if Chi2Actif
        then sigmaLoc := 1
        else sigmaLoc := sigmaY;
     ecartTypeParam[i] := sqrt(invDer2j[i,i])*sigmaLoc;
     if paramInverse[i] then
        ecartTypeParam[i] := ecartTypeParam[i]/sqr(parametres[i].valCourante);
     studentParam[i] := student95(NbrePointsModele);
     incertParam[i] := ecartTypeParam[i]*studentParam[i];
     incParam[i] := 0;
     for l := 1 to NbreParam do
         incParam[i] := incParam[i] - invDer2j[l,i]*derj[l];
     erreurCalcul := erreurCalcul or isNan(incParam[i]) or isInfinite(incParam[i]) or (abs(incParam[i])>MaxReal);
     except
         incertParam[i] := Nan;
         incParam[i] := 0;
         ecartTypeParam[i] := Nan;
     end;
  end;
  if chi2Actif then
     for i := 1 to NbreParam do
         if i in dependM then
            for l := 1 to NbreParam do
                if l in dependM then
                   CovarianceParam[i,l] := invDer2J[i,l];
end end; // calculPrecision

function InitCalculJ : boolean;
// On calcule une valeur relative à l'étendue des mesures
var k : integer;
    i : integer;
    valeur : double;
begin with pages[pageCourante],fonctionTheorique[m] do begin
      InitCalculJ := false;
      if (nmes<3) or (debut[m]<0) or (fin[m]<0) then exit;
      if fin[m]<debut[m] then swap(fin[m],debut[m]);
      if fin[m]>=nmes then fin[m] := pred(nmes);
      NbrePointsModele := succ(fin[m]-debut[m]);
      if (NbrePointsModele<NbreParamModele) then begin
           afficheErreur(erNombrePetit,0);
           exit;
      end;
      NbrePointsModele := NbrePointsModele-NbreParamModele;
      if NbrePointsModele=0 then NbrePointsModele := 1;
      SommeCarreY := 0;
      for i := debut[m] to fin[m] do begin
         valeur := valeurVar[indexY,i];
         if isNan(valeur) or not PointActif[i]
            then dec(NbrePointsModele)
            else SommeCarreY := SommeCarreY + sqr(valeur);
      end;
      if NbrePointsModele<1 then begin
           afficheErreur(erNombrePetit,0);
           exit;
      end;
      jPrecedent := 2*sommeCarreY;
      chi2Precedent := NbrePointsModele*100.0;
   for k := 1 to MaxParametres do
       if k in dependM
          then incertParam[k] := Nan;
   InitCalculJ := (SommeCarreY>1E-22*nmes);
end end; // initCalculJ

procedure CalculJ;
// calcul de J; avecDerivee => calcul derj,der2j

var Y : MatriceVecteur;

procedure calculFonction;
var i : integer;
    k1 : integer;
    z : double;
begin with pages[pageCourante],fonctionTheorique[m] do begin
    setLength(ValeurDeriveeX[m],NmesMax+1);
    for i := debut[m] to fin[m] do
        if not isNan(valeurVar[indexY,i]) and
           PointActif[i] then begin
        AffecteVariableE(i);
        try
        z := calcule(calcul);
        if isNan(z) or isInfinite(z)
           then raise EMathError.Create('Erreur de calcul')
           else valeurTheorique[m,i] := z;
        for k1 := 1 to NbreParam do
            Y[m,k1,i] := calcule(derf[m,k1]);
        if Chi2Actif and (fchi2<>nil)
           then ValeurDeriveeX[m,i] := calcule(fchi2)
           else ValeurDeriveeX[m,i] := 0;
        except
            on E : exception do begin
               if ErreurModele then raise EMathError.Create(E.message);
// une erreur permise à la deuxième on réarme
               erreurModele := true;
               PosErreurModele := i;
               derniereErreur := E.message;
            end;
        end;
    end;// for i
end end;// calculFonction

procedure calculLoc;
var k1,k2 : integer;
    i : integer;
    ValDerf : TableauParam;// valeur de la dérivée première
    ecart : double; // valeur de l'écart entre la fonction théorique et expérimentale
    CoeffChi2 : double;
    dy,dt : double;
begin with pages[pageCourante],fonctionTheorique[m] do begin
    try
        setLength(ValeurDeriveeX[m],NmesMax+1);
        for i := debut[m] to fin[m] do
            if not isNan(valeurVar[indexY,i]) and
               PointActif[i] then begin
            if posErreurModele=i then continue;
            Ecart := valeurTheorique[m,i]-grandeurs[indexY].valeur[i];
            J := J + sqr(ecart);
            if Chi2Actif then begin
                     try
                     dy := incertVar[indexY,i];
                     if isNan(dy) then dy := 0;
                     try
                     dt := incertVar[indexX,i];
                     if isNan(dt)
                        then dt := 0
                        else dt := dt*valeurDeriveeX[m,i];
                     except
                         dt := 0;
                     end;
                     coeffChi2 := 1/(sqr(dy)+sqr(dt));
                     except
                       try
                       coeffChi2 := 1e6/sqr(grandeurs[indexY].valeur[i]);
                       { on force une incertitude de 0,1% }
                       except
                          coeffChi2 := 0;
                       end;
                     end;
                     chi2[m] := chi2[m] + coeffChi2*sqr(ecart);
                  end // chi2Actif
                  else coeffChi2 := 1;
        for k1 := 1 to NbreParam do
        if k1 in dependM then begin
            valDerf[k1] := Y[m,k1,i];
            derj[k1] := derj[k1]+coeffChi2*Ecart*valDerf[k1];
            for k2 := 1 to k1 do
                der2j[k1,k2] := der2j[k1,k2]+coeffChi2*valDerf[k2]*valDerf[k1];
         end
         else valDerf[k1] := 0;
     end;// for i
    except
          erreurParam := true
    end;
end end;// calculLoc

procedure calculDiff2;
var i : integer;
begin with pages[pageCourante] do begin
    genereLisseP(fonctionTheorique[m].indexYp);
    setLength(ValeurDeriveeX[m],NmesMax+1);
    for i := 0 to NmesMax do ValeurDeriveeX[m,i] := 0;
    SystemeDiff2(derf,Y,m,m)
end end; // calculDiff2

procedure calculDiff1;
var i : integer;
begin with pages[pageCourante] do begin
    setLength(ValeurDeriveeX[m],NmesMax+1);
    for i := 0 to NmesMax do ValeurDeriveeX[m,i] := 0;
    SystemeDiff1(derf,Y,m,m)
end end; // calculDiff1

Const
      PrecisionAbsolueJ = 0.001;
      PrecisionRelative = 0.001;
      PrecisionZero = 0.0000001; // prise en compte erreur arrondi dans comparaison à zéro
      PrecisionAbsolueChi2 = 0.1;
var k1,k2 : integer;
    Delta : double;
begin // calculJ
with pages[pageCourante],fonctionTheorique[m] do begin
// Initialisation
   AffecteConstParam;
   AffecteVariableP(false);
   erreurCalcul := false;
   erreurParam := false;
   Chi2Actif := chi2Permis and avecChi2;
   J := 0;
   chi2[m] := 0;
   ErreurModele := false;
   PosErreurModele := -1;
   for k1 := 1 to NbreParam do begin
       derJ[k1] := 0;
       for k2 := 1 to NbreParam do
           der2j[k1,k2] := 0;
   end;// for k1
   for k1 := 1 to NbreParam do
       setLength(y[m,k1],NmesMax+1);
   try
   case genreC of
        g_fonction,g_equation : calculFonction;
        g_diff1 : calculDiff1;
        g_diff2 : calculDiff2;
   end;
   except
       on E : exception do begin
          derniereErreur := E.message;
          erreurCalcul := true;
       end;
   end;
   if not erreurCalcul then CalculLoc;
   for k1 := 1 to NbreParam do
       y[m,k1] := nil;
   PrecisionModele[m] := sqrt(J/SommeCarreY);
   if Chi2Actif
           then begin
              chi2Relatif := chi2[m]/NbrePointsModele;
              Delta := chi2[m]-chi2Precedent;
              Stable := (abs(Delta)<(chi2Precedent*PrecisionRelative)) or
                        (chi2[m]<(NbrePointsModele*PrecisionAbsolueChi2));
              Diverge := Delta>chi2[m]*PrecisionZero;
           end
           else begin
              sigmaY := sqrt(J/NbrePointsModele);
              Delta := J-Jprecedent;
              Diverge := Delta>J*PrecisionZero;
              Delta := abs(Delta);
              Stable := (Delta<(Jprecedent*PrecisionRelative)) or
                        (PrecisionModele[m]<PrecisionAbsolueJ);
         end;
end end; // calculJ

procedure completeValTh;
var i : integer;
begin
   if (OmExtrapole in optionModele) and
       pages[pageCourante].ModeleCalcule then with pages[pageCourante] do begin
      if isModeleSysteme and
         (fonctionTheorique[m].genreC in [g_fonction,g_equation]) then begin
              for i := 0 to pred(nmes) do
                  if (i<debut[m]) or (i>fin[m]) then begin
                     AffecteVariableE(i);
                     valeurTheorique[m,i] := calcule(fonctionTheorique[m].calcul);
                  end;// calculPoint
      end // g_fonction
      else begin
               for i := 0 to pred(nmes) do
                   if (i<debut[1]) or (i>fin[1]) then
                       valeurTheorique[m,i] := Nan
      end;
      remplitVarLisse;
end end; // completeValTh

var sauveValeurParam,ValeurParamInit,BestValeurParam : tableauParam;
    BestPrecision : double;

Function EffectueLevenbergMarquardt : boolean;
const Maxi_i1 = 32; // time out
var i1 : integer;
    k : codeParam;
begin with pages[pageCourante] do begin
    Lambda := 1e-3; // calcul quasi Gauss Newton
    i1 := 0;
    result := false;
    repeat
        inc(i1);
        Jprecedent := J;
        chi2Precedent := chi2[m];
        sauveValeurParam := ValeurParam;
        calculPrecision;
        if erreurCalcul then begin
           TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
           TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_ErreurDomaineDefinition,nil);
           valeurParam := sauveValeurParam;
           exit;
        end;
        for k := 1 to NbreParam do if k in dependM then
            if paramInverse[k]
               then valeurParam[k] := 1/(1/valeurParam[k]+incParam[k])
               else valeurParam[k] := valeurParam[k]+incParam[k];
        CalculJ;
        if erreurParam then begin
           TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
           TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_ErreurDomaineDefinition,nil);
           valeurParam := sauveValeurParam;
           exit;
        end;
        if diverge or ErreurCalcul then begin // retour en arrière
           valeurParam := sauveValeurParam;
           // on tend vers méthode du gradient
           if Lambda<LambdaMax
              then Lambda := 10*Lambda
              else begin
                 CalculJ;
                 break;
              end;
           CalculJ;
           stable := false;
           inc(i1);
        end
        else if Lambda>LambdaMin then // on tend vers Méthode de Gauss Newton
           Lambda := Lambda/10;
    until (i1>Maxi_i1) or stable;
    if diverge then begin
       ValeurParam := sauveValeurParam;
       CalculJ;
       if not stable then begin
          afficheErreur(erDivergence,HELP_DivergenceModelisation);
          exit;
       end;
    end;
    if (i1>Maxi_i1) then afficheErreur(erTimeOut,HELP_Timeout);
    result := true;
    Lambda := 0;
    calculPrecision;
end end; // EffectueLevenbergMarquardt

Function EffectueGaussNewton : boolean;
const
    Maxi_i1 = 32; // time out
    Maxi_i2 = 6; // µ mini =(1/2)^7=1%
var k : codeParam;
    i1,i2 : integer;
    mu : double;
// boucle de recherche par méthode gradient-Newton
begin with pages[pageCourante] do begin
    i1 := 0;
    Lambda := 0;
    result := false;
    repeat
        inc(i1);
        Jprecedent := J;
        chi2Precedent := chi2[m];
        calculPrecision;
        if erreurCalcul then begin
           TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
           TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_ErreurDomaineDefinition,nil);
           valeurParam := sauveValeurParam;
           exit;
        end;
        for k := 1 to NbreParam do if k in dependM then
            if paramInverse[k]
               then valeurParam[k] := 1/(1/valeurParam[k]+incParam[k])
               else valeurParam[k] := valeurParam[k]+incParam[k];
        CalculJ;
        if erreurParam then begin
           TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
           TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_ErreurDomaineDefinition,nil);
           valeurParam := sauveValeurParam;
           exit;
        end;
      mu := 1;i2 := 0;
      while (Diverge or ErreurCalcul) and (i2<Maxi_i2) do begin
        inc(i2);
        mu := mu/2;
        for k := 1 to NbreParam do if k in dependM then
            if paramInverse[k]
               then valeurParam[k] := 1/(1/valeurParam[k]-incParam[k]*mu)
               else valeurParam[k] := valeurParam[k]-incParam[k]*mu;
        CalculJ;
      end; // while diverge
      if diverge and (stable or (i1<=1)) then begin
         ValeurParam := sauveValeurParam;
         calculJ; // calcul dans l'état initial
         diverge := false;
         stable := true;
         i2 := 0;
      end;
      if erreurCalcul or erreurParam or diverge
           then begin
              ValeurParam := sauveValeurParam;
              if erreurCalcul or erreurParam
                 then TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
                 TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_EcartModelisationExperience,nil)
                 else afficheErreur(erDivergence,HELP_DivergenceModelisation);
               exit;
           end
           else sauveValeurParam := ValeurParam;
      if (i2>0) and not stable then begin
           inc(i1); // prise en compte du temps de calcul du retour en arrière
           calculJ;
      end;
   until (i1>Maxi_i1) or stable;
   if (i1>Maxi_i1) then afficheErreur(erTimeOut,HELP_Timeout);
   result := true;
   calculPrecision;
end end; // EffectueGaussNewton

var iParam : integer;
    i,l,iRecuit : integer;
begin // effectueModeleMono
with pages[pageCourante],fonctionTheorique[m] do begin
    dependM := [];
    for iParam := 1 to NbreParam do
        if ParamToIndex(iParam) in depend then include(dependM,iParam);
// boucle de recherche par méthode gradient-Newton / Levenberg-Marquardt
    ModeleCalcule := false;
    ModeleErrone := true;
    if not InitCalculJ then exit;
    CalculJ;
    if erreurCalcul or ErreurParam then begin
       TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
       TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_ErreurDomaineDefinition,nil);
       exit;
    end;
    sauveValeurParam := ValeurParam;
    ValeurParamInit := ValeurParam;
    if LevenbergMarquardt
       then modeleErrone := not EffectueLevenbergMarquardt
       else modeleErrone := not EffectueGaussNewton;
    if modeleErrone then exit;
    if Recuit and (PrecisionModele[m]>0.2) then begin
       BestValeurParam := ValeurParam;
       BestPrecision := PrecisionModele[m];
       iRecuit := 1;
       repeat
          ValeurParam := ValeurParamInit;
          if IsSinusoide then begin
             valeurParam[amplitude] := valeurParam[amplitude]*(0.5+random);
             valeurParam[Phase] := (random*2-1)*AngleUtilisateur(pi);
             if (periodeOuFrequence<>grandeurInconnue) then
                valeurParam[PeriodeOuFrequence] :=
                   valeurParam[PeriodeOuFrequence]*(0.5+random);
          end
          else for iParam := 1 to NbreParam do if iParam in dependM then
               valeurParam[iParam] := valeurParam[iParam]*(0.8+0.4*random);
          CalculJ;
          if not (erreurCalcul or ErreurParam) then begin
             if LevenbergMarquardt
                then modeleErrone := not EffectueLevenbergMarquardt
                else modeleErrone := not EffectueGaussNewton;
             if (not modeleErrone) and (PrecisionModele[m]<BestPrecision) then begin
                BestPrecision := PrecisionModele[m];
                BestValeurParam := ValeurParam;
             end;
          end;
          inc(iRecuit);
       until (BestPrecision<0.2) or (iRecuit=6);
       ValeurParam := BestValeurParam;
       CalculJ;
       Lambda := 0;
       calculPrecision;
       modeleErrone := false;
    end; // recuit
    ParamAjustes := stable;
    ModeleCalcule := true;
    CompleteValTh;
    calculResidu(m,csSigma);
    if IsSinusoide then with pages[pageCourante] do begin
        if (amplitude in dependM) and
           (valeurParam[amplitude]<0) then begin
              valeurParam[amplitude] := -valeurParam[amplitude];
              valeurParam[Phase] := valeurParam[Phase]+
                                                AngleUtilisateur(pi);
        end;
        if (periodeOuFrequence<>grandeurInconnue) and
           (valeurParam[PeriodeOuFrequence]<0) then begin
// Période peut être commune à deux modèles donc ne modifier T qu'après
            if IsCosinus
               then valeurParam[Phase] := -valeurParam[Phase]
               else valeurParam[Phase] := -valeurParam[Phase]+
                                                         AngleUtilisateur(pi);
           valeurParam[Phase] := Atan2(MySin(valeurParam[Phase]),
                                       MyCos(valeurParam[Phase]));
           valeurParam[PeriodeOuFrequence] := -valeurParam[PeriodeOuFrequence];
        end;
    end;
    if not chi2Actif then
       for i := 1 to NbreParam do
           for l := 1 to NbreParam do
               CovarianceParam[i,l] := 0;
end end; // EffectueModeleMono


