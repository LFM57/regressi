// modele.pas include de graphevariabU

Procedure TgrapheVariab.EffectueModele(Ajuste,withMessage : boolean);
const LambdaMin = 1e-4;
      LambdaMax = 1e4;
var Lambda : double;
    diverge,stable : boolean;

{------- boucle de recherche par méthode gradient-Newton -------}
var
   J,Jprecedent,chi2Precedent,coeffJ : tableauReal;
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
const MaxReal = 1e36;
var U,InvDer2j : MatriceParam;

procedure construireU;
var
   v : double;
   i,l,k : integer;
begin
 for i := 1 to NbreParam do begin
     v := der2J[i,i]*(1+Lambda);
     try
     for k := 1 to pred(i) do v := v-sqr(U[k,i]);
     U[i,i] := sqrt(v);
     for l := succ(i) to NbreParam do begin
         v := der2J[l,i];
         for k := 1 to pred(i) do v:=v-U[k,i]*U[k,l];
         U[i,l] := v/U[i,i];
     end;{l}
     except
        for l := 1 to NbreParam do begin
             U[i,l] := 0;
             U[l,i] := 0;
             der2J[l,i] := 0;
             der2J[i,l] := 0;
// erreur sur param[i] mais on veut trouver les autres
        end {l}
      end
  end;{i}
end;{construireU}

procedure resoudreU(l : codeParam);
{ Inversion de der2J = symétrique définie positive par  Méthode de Choleski
  Trigeassou p 105 }
var i,k : integer;
    Y   : TableauParam;
    v   : double;
begin
    for i := 1 to NbreParam do if U[i,i]= 0
        then Y[i] := 0
        else begin
           try
           if i=l then v := 1 else v := 0;
           for k := 1 to pred(i) do v := v-U[k,i]*Y[k];
           Y[i] := v/U[i,i];
           except
              Y[i] := 0
           end;
        end;{else}
{ passage à invder2J }
     for i := NbreParam downto 1 do begin
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

{ Trigeassou p 267 }
var coeffInvDer2j : double;
    m,i,l : integer;
    N : integer;
    sigmaLoc : double;
begin // calculPrecision
with pages[pageCourante] do begin
  construireU; { résolution successive avec B=(1..0) jusqu'à (0..1) }
  erreurCalcul := false;
  for i := 1 to NbreParam do resoudreU(i);
//  invMat(der2J,NbreParam,invDer2j);
  for i := 1 to NbreParam do begin
     try
     sigmaLoc := 0;N := 0;coeffInvDer2j := 0;
     for m := 1 to NbreModele do with fonctionTheorique[m] do
         if ParamToIndex(i) in depend then begin
            { prise en compte de l'influence de coeffJ[m]
            dans sqr car 1 pour N*coeff et 1 pour inver2j }
            if not chi2Actif then sigmaLoc := sigmaLoc+sqr(sigmaY*coeffJ[m])*NbrePointsModele;
            N := N + NbrePointsModele;
            coeffInvDer2j := NbrePointsModele*coeffJ[m]+coeffInvDer2j;
         end; {if}
     if chi2actif
        then sigmaLoc := 1
        else sigmaLoc := sqrt(sigmaLoc/coeffInvDer2j);
// pas d'incertitude => on évalue celle-ci comme écart data-fit
// avec incertitude, prise en compte dans der2J
// deltaReg est pondéré par Npoints et coeffJ
     ecartTypeParam[i] := sqrt(invDer2j[i,i])*sigmaLoc;
     if paramInverse[i] then
        ecartTypeParam[i] := ecartTypeParam[i]/sqr(parametres[i].valCourante);
     studentParam[i] := student95(N);
     incertParam[i] := ecartTypeParam[i]*studentParam[i];
// covariance param(i,l) = invder2J[i,l]
     incParam[i] := 0;
     for l := 1 to NbreParam do
         incParam[i] := incParam[i] - invDer2j[l,i]*derj[l];
     erreurCalcul := erreurCalcul or isNan(incParam[i]) or isInfinite(incParam[i]) or (abs(incParam[i])>MaxReal);
     except
         incertParam[i] := Nan;
         incParam[i] := 0;
         ecartTypeParam[i] := Nan;
     end;
  end;{i}
  if chi2Actif then
     for i := 1 to NbreParam do
         for l := 1 to NbreParam do
             CovarianceParam[i,l] := invDer2J[i,l];
end end; // calculprecision

function InitCalculJ : boolean;
// On calcule une valeur relative à l'étendue des mesures
var m,k : integer;
    i : integer;
    valeur : double;
begin with pages[pageCourante] do begin
   InitCalculJ := false;
   if nmes<3 then exit;
   for m := 1 to NbreModele do with fonctionTheorique[m] do begin
      if (debut[m]<0) or (fin[m]<0) then exit;
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
      jPrecedent[m] := 2*sommeCarreY;
      chi2Precedent[m] := NbrePointsModele*100.0;
   end;
   if Chi2Actif
     then // dèjà pris en compte par incertitude
        for m := 1 to NbreModele do coeffJ[m] := 1
     else for m := 1 to NbreModele do
        if Jprecedent[m]>0
           then coeffJ[m] := Jprecedent[1]/Jprecedent[m]
           else coeffJ[m] := 1;
   for k := 1 to MaxParametres do incertParam[k] := Nan;
   InitCalculJ := (fonctionTheorique[1].SommeCarreY>1E-22*nmes);
end end; // initCalculJ

procedure CalculJ(avecDerivee : boolean);
// calcul de J; avecDerivee => calcul derj,der2j

var Y : MatriceVecteur;

procedure calculFonction(mDebut,mFin : codeIntervalle);
var i : integer;
    m,k1 : integer;
    z : double;
begin with pages[pageCourante] do begin
for m := mDebut to mFin do with fonctionTheorique[m] do begin
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
        if avecDerivee then
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
    end;{i}
 end;{m}
end end;{calculFonction}

procedure calculLoc;
var k1,k2,m : integer;
    i : integer;
    ValDerf : TableauParam;// valeur de la dérivée première
    ecart : double; // valeur de l'écart entre la fonction théorique et expérimentale
    CoeffChi2 : double;
    dy,dt : double;
begin with pages[pageCourante] do begin
    try
    for m := 1 to NbreModele do with fonctionTheorique[m] do begin
        setLength(ValeurDeriveeX[m],NmesMax+1);
        for i := debut[m] to fin[m] do
            if not isNan(valeurVar[indexY,i]) and
               PointActif[i] then begin
            if posErreurModele=i then continue;
            Ecart := valeurTheorique[m,i]-grandeurs[indexY].valeur[i];
            J[m] := J[m] + sqr(ecart);
            if avecDerivee then begin
               if Chi2Actif
                  then begin
                     try
                     dy := incertVar[indexY,i];
                     if isNan(dy) then dy := 0;
                     try
                     dt := incertVar[indexX,i];
                     if isNan(dt)
                        then dt :=0
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
                  else coeffChi2 := coeffJ[m];
        for k1 := 1 to NbreParam do begin
            valDerf[k1] := Y[m,k1,i];
            derj[k1] := derj[k1]+coeffChi2*Ecart*valDerf[k1];
            for k2 := 1 to k1 do
                der2j[k1,k2] := der2j[k1,k2]+coeffChi2*valDerf[k2]*valDerf[k1];
         end;// for k1
         end;// dérivée
     end;// for i
    end;// for m
    except
          erreurParam := true
    end;
end end;// calculLoc

procedure calculDiff2(mDebut,mFin : codeIntervalle);
// calcul_J pour équation diff d'ordre 2
var m : integer;
    i : integer;
begin
    if mDebut<>mFin then for m := 2 to mFin do
       with pages[pageCourante] do begin
         debut[m] := debut[1];
         fin[m] := fin[1];
       end;
    for m := mDebut to mFin do with pages[pageCourante] do begin
        genereLisseP(fonctionTheorique[m].indexYp);
        setLength(ValeurDeriveeX[m],NmesMax+1);
        for i := 0 to NmesMax do ValeurDeriveeX[m,i] := 0;
    end;
    if avecDerivee
        then SystemeDiff2(derf,Y,mDebut,mFin)
        else EquationDiff2(mDebut,mFin)
end; // calculDiff2

procedure calculDiff1(mDebut,mFin : codeIntervalle);
// calcul_J pour équation diff d'ordre 1 
var m : integer;
    i : integer;
begin
    if mDebut<>mFin then for m := 2 to mFin do
       with pages[pageCourante] do begin
         debut[m] := debut[1];
         fin[m] := fin[1];
       end;
    for m := mDebut to mFin do with pages[pageCourante] do begin
        setLength(ValeurDeriveeX[m],NmesMax+1);
        for i := 0 to NmesMax do ValeurDeriveeX[m,i] := 0;
    end;
    if avecDerivee
       then SystemeDiff1(derf,Y,mDebut,mFin)
       else EquationDiff1(mDebut,mFin);
end; // calculDiff1

Const
      PrecisionAbsolueJ = 0.001;
      PrecisionRelative = 0.001;
      PrecisionZero = 0.0000001; // prise en compte erreur arrondi dans comparaison à zéro
      PrecisionAbsolueChi2 = 0.1;
var k1,k2,m : integer;
    Delta : double;
begin // calculJ
with pages[pageCourante] do begin
// Initialisation
   AffecteConstParam;
   AffecteVariableP(false);
   erreurCalcul := false;
   erreurParam := false;
   Chi2Actif := avecChi2;
   for m := 1 to NbreModele do with fonctionTheorique[m] do begin
       J[m] := 0;
       chi2[m] := 0;
       ErreurModele := false;
       PosErreurModele := -1;
       Chi2Actif := chi2Actif and chi2Permis;
   end;
   for k1 := 1 to NbreParam do begin
       derJ[k1] := 0;
       for k2 := 1 to NbreParam do
          der2j[k1,k2] := 0;
   end;// for k1
   if avecDerivee then
      for m := 1 to NbreModele do
          for k1 := 1 to NbreParam do
              setLength(y[m,k1],NmesMax+1);
   try
   if isModeleSysteme
      then case fonctionTheorique[1].genreC of
           g_fonction,g_equation : calculFonction(1,NbreModele);
           g_diff1 : calculDiff1(1,NbreModele);
           g_diff2 : calculDiff2(1,NbreModele);
      end
      else for m := 1 to NbreModele do
        case fonctionTheorique[m].genreC of
           g_fonction,g_equation : calculFonction(m,m);
           g_diff1 : calculDiff1(m,m);
           g_diff2 : calculDiff2(m,m);
        end;
   except
       on E : exception do begin
          derniereErreur := E.message;
          erreurCalcul := true;
       end;
   end;
   if not erreurCalcul then CalculLoc;
   if avecDerivee then
      for m := 1 to NbreModele do
          for k1 := 1 to NbreParam do
              y[m,k1] := nil;
   stable := true;
   diverge := false;
   for m := 1 to NbreModele do with fonctionTheorique[m] do begin
        PrecisionModele[m] := sqrt(J[m]/SommeCarreY);
        if Chi2Actif
           then begin
              chi2Relatif := chi2[m]/NbrePointsModele;
              Delta := chi2[m]-chi2Precedent[m];
              Stable := Stable and
                    ( (abs(Delta)<(chi2Precedent[m]*PrecisionRelative)) or
                     (chi2[m]<(NbrePointsModele*PrecisionAbsolueChi2)) );
              Diverge := Diverge or (Delta>chi2[m]*PrecisionZero);
           end
           else begin
              sigmay := sqrt(J[m]/NbrePointsModele);
              Delta := J[m]-Jprecedent[m];
              Diverge := Diverge or (Delta>J[m]*PrecisionZero);
              Delta := abs(Delta);
              Stable := Stable and
                  ( (Delta<(Jprecedent[m]*PrecisionRelative)) or
                    (PrecisionModele[m]<PrecisionAbsolueJ) );
         end;
   end; // m
end end; // calculJ

procedure completeValTh;
var m : integer;
    i : integer;
begin
   if (OmExtrapole in optionModele) and
       pages[pageCourante].ModeleCalcule then with pages[pageCourante] do begin
      if isModeleSysteme and
         (fonctionTheorique[1].genreC in [g_fonction,g_equation]) then begin
         for m := 1 to NbreModele do
              for i := 0 to pred(nmes) do
                  if (i<debut[m]) or (i>fin[m]) then begin
                     AffecteVariableE(i);
                     valeurTheorique[m,i] := calcule(fonctionTheorique[m].calcul);
                  end;// calculPoint
      end // g_fonction
      else begin
         for m := 1 to NbreModele do
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
        chi2Precedent := chi2;
        sauveValeurParam := ValeurParam;
        calculPrecision;
        if erreurCalcul then begin
           if withMessage then TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
           TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_ErreurDomaineDefinition,nil);
           valeurParam := sauveValeurParam;
           exit;
        end;
        for k := 1 to NbreParam do
            if paramInverse[k]
               then valeurParam[k] := 1/(1/valeurParam[k]+incParam[k])
               else valeurParam[k] := valeurParam[k]+incParam[k];
        CalculJ(true);
        if erreurParam then begin
           if withMessage then TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
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
                 CalculJ(true);
                 break;
              end;
           CalculJ(true);
           stable := false;
           inc(i1);
        end
        else if Lambda>LambdaMin then // on tend vers Méthode de Gauss Newton
           Lambda := Lambda/10;
    until (i1>Maxi_i1) or stable;
    if diverge then begin
       ValeurParam := sauveValeurParam;
       CalculJ(true);
       if not stable then begin
          if withMessage then afficheErreur(erDivergence,HELP_DivergenceModelisation);
          exit;
       end;
    end;
    if (i1>Maxi_i1) and withMessage then afficheErreur(erTimeOut,HELP_Timeout);
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
        chi2Precedent := chi2;
        calculPrecision;
        if erreurCalcul then begin
           if withMessage then TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
           TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_ErreurDomaineDefinition,nil);
           valeurParam := sauveValeurParam;
           exit;
        end;
        for k := 1 to NbreParam do
            if paramInverse[k]
               then valeurParam[k] := 1/(1/valeurParam[k]+incParam[k])
               else valeurParam[k] := valeurParam[k]+incParam[k];
        CalculJ(true);
        if erreurParam then begin
           if withMessage then TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,
           TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_ErreurDomaineDefinition,nil);
           valeurParam := sauveValeurParam;
           exit;
        end;
      mu := 1;i2 := 0;
      while (Diverge or ErreurCalcul) and (i2<Maxi_i2) do begin
        inc(i2);
        mu := mu/2;
        for k := 1 to NbreParam do
            if paramInverse[k]
               then valeurParam[k] := 1/(1/valeurParam[k]-incParam[k]*mu)
               else valeurParam[k] := valeurParam[k]-incParam[k]*mu;
        CalculJ(false);
      end; // while diverge
      if diverge and (stable or (i1<=1)) then begin
         ValeurParam := sauveValeurParam;
         calculJ(not stable); // calcul dans l'état initial
         diverge := false;
         stable := true;
         i2 := 0;
      end;
      if erreurCalcul or erreurParam or diverge
           then begin
              ValeurParam := sauveValeurParam;
              if withMessage then if erreurCalcul or erreurParam
                 then TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_EcartModelisationExperience,nil)
                 else afficheErreur(erDivergence,HELP_DivergenceModelisation);
               exit;
           end
           else sauveValeurParam := ValeurParam;
      if (i2>0) and not stable then begin
           inc(i1); // prise en compte du temps de calcul du retour en arrière
           calculJ(true);
      end;
   until (i1>Maxi_i1) or stable;
   if (i1>Maxi_i1) and withMessage then afficheErreur(erTimeOut,HELP_Timeout);
   result := true;
   calculPrecision;
end end;

var iModele,iParam,i,l,iRecuit : integer;
begin // effectueModele
with pages[pageCourante] do begin
// boucle de recherche par méthode gradient-Newton / Levenberg-Marquardt
    ModeleCalcule := false;
    ModeleErrone := true;
    if not InitCalculJ then exit;
    CalculJ(ajuste);
    if erreurCalcul or ErreurParam then begin
       if withMessage then TDialogService.MessageDialog(ErDomaine+' : '+derniereErreur,TMsgDlgType.mtError,[TMsgDlgBtn.mbOk],TMsgDlgBtn.mbOk,HELP_ErreurDomaineDefinition,nil);
       exit;
    end;
    sauveValeurParam := ValeurParam;
    ValeurParamInit := ValeurParam;
    if ajuste
       then if LevenbergMarquardt
          then modeleErrone := not EffectueLevenbergMarquardt
          else modeleErrone := not EffectueGaussNewton
       else modeleErrone := false;
    if modeleErrone then exit;
    if Recuit and (PrecisionModele[1]>0.2) and ajuste then begin
       BestValeurParam := ValeurParam;
       BestPrecision := PrecisionModele[1];
       iRecuit := 0;
       repeat
          inc(iRecuit);
          ValeurParam := ValeurParamInit;
          for iModele := 1 to NbreModele do with fonctionTheorique[iModele] do
              if IsSinusoide then begin
                 valeurParam[amplitude] := valeurParam[amplitude]*(0.5+random);
                 valeurParam[Phase] := (random*2-1)*AngleUtilisateur(pi);
                 if (periodeOuFrequence<>grandeurInconnue) then
                    valeurParam[PeriodeOuFrequence] :=
                       valeurParam[PeriodeOuFrequence]*(0.5+random);
              end
              else for iParam := 1 to NbreParam do
                       if ParamToIndex(iParam) in depend then
                          valeurParam[iParam] := valeurParam[iParam]*(0.5+2*random);
          CalculJ(true);
          if not (erreurCalcul or ErreurParam) then begin
             if LevenbergMarquardt
                then modeleErrone := not EffectueLevenbergMarquardt
                else modeleErrone := not EffectueGaussNewton;
             if (not modeleErrone) and (PrecisionModele[1]<BestPrecision) then begin
                BestPrecision := PrecisionModele[1];
                BestValeurParam := ValeurParam;
             end;
          end;
       until (iRecuit=6) or (BestPrecision<0.2);
       ValeurParam := BestValeurParam;
       CalculJ(true);
       Lambda := 0;
       calculPrecision;
       modeleErrone := false;
    end; // recuit
    calcIntersection;
    ParamAjustes := ajuste and stable;
    ModeleCalcule := true;
    CompleteValTh;
    for iModele := 1 to NbreModele do
        fonctionTheorique[iModele].calculResidu(iModele,csSigma);
    if ajuste then begin
    for iModele := 1 to NbreModele do with fonctionTheorique[iModele] do
        if IsSinusoide then with pages[pageCourante] do begin
           if valeurParam[amplitude]<0 then begin
              valeurParam[amplitude] := -valeurParam[amplitude];
              valeurParam[Phase] := valeurParam[Phase]+
                                                AngleUtilisateur(pi);
           end;
           if (periodeOuFrequence<>grandeurInconnue) and
              (valeurParam[PeriodeOuFrequence]<0) then
// Période peut être commune à deux modèles donc ne modifier T qu'après
              if IsCosinus
                 then valeurParam[Phase] := -valeurParam[Phase]
                 else valeurParam[Phase] := -valeurParam[Phase]+
                                                         AngleUtilisateur(pi);
           valeurParam[Phase] := Atan2(MySin(valeurParam[Phase]),
                                                   MyCos(valeurParam[Phase]));
        end;
    for iModele := 1 to NbreModele do with fonctionTheorique[iModele] do
        if IsSinusoide and
           (periodeOuFrequence<>grandeurInconnue) then with pages[pageCourante] do
           valeurParam[PeriodeOuFrequence] := abs(valeurParam[PeriodeOuFrequence]);
    end;
    if not chi2Actif then
       for i := 1 to NbreParam do
           for l := 1 to NbreParam do
               CovarianceParam[i,l] := 0;
end end; // EffectueModele

Procedure TgrapheVariab.CalcIntersection;
var i,iX : integer;
    posDebut,posFin : integer;
begin with pages[pageCourante] do
   if isModeleSysteme and (fonctionTheorique[1].genreC=g_fonction) then
   for i := 2 to NbreModele do
       if (fonctionTheorique[pred(i)].indexX=fonctionTheorique[i].indexX) and
          (fonctionTheorique[pred(i)].indexY=fonctionTheorique[i].indexY)
           then begin
              if fin[pred(i)]<debut[i]
                 then begin // (i-1) avant i
                      posDebut := fin[pred(i)]-1;
                      posFin := debut[i]+1;
                 end
                 else if fin[i]<debut[pred(i)]
                    then begin // i avant i-1
                        posDebut := fin[i]-1;
                        posFin := debut[pred(i)]+1;
                    end
                    else begin // zone commune
                        if debut[i]>debut[pred(i)]
                           then posDebut := debut[i]-1
                           else posDebut := debut[pred(i)]-1;
                        if fin[i]>fin[pred(i)]
                           then posFin := fin[pred(i)]+1
                           else posFin := fin[i]+1;
                    end;
              while (posFin-posDebut)<5 do begin
                  dec(posDebut);
                  inc(posFin);
              end;
              if posDebut<0 then posDebut := 0;
              if posFin>=nmes then posFin := pred(nmes);                   
              iX := fonctionTheorique[i].indexX;
              try
              Dichotomie(pageCourante,iX,
                 fonctionTheorique[pred(i)].calcul,fonctionTheorique[i].calcul,
                 valeurVar[iX,posDebut],valeurVar[iX,posFin],
                 Y_inter[i],X_inter[i]);
(*
              if calcSI then begin
                 Y_inter[i] := Y_inter[i]/coeffSI;
                 X_inter[i] := X_inter[i]/coeffSI;
              end;
*)
              except;
                 Y_inter[i] := Nan;
                 X_inter[i] := Nan
              end;
           end
           else begin
                Y_inter[i] := Nan;
                X_inter[i] := Nan
           end;
end; // calcIntersection

Procedure TgrapheVariab.CompileModele(var PosErreur,LongErreur : integer);
Type Tligne = (LCommentaire,LModele,Lsuperpose);
var posErreurLigne : integer;
    LigneCourante : string;
    i : integer;

Function TypeDeLigne : Tligne;
var PosEgal : integer;
    index : integer;
    NomLu : string;
begin
    result := Lcommentaire;
    if IsLigneComment(LigneCourante) then exit;
    if pos(':=',LigneCourante)>0 then begin
       result := Lsuperpose;
       exit;
    end;
    PosEgal := Pos('=',ligneCourante);
    if PosEgal=0 then begin
       codeErreurC := erEgalAbsent;
       exit;
    end;
    nomLu := copy(ligneCourante,1,pred(posEgal));// extrait le nom
    trimComplet(nomLu);
    index := indexToParam(IndexNom(nomLu));
    if index=grandeurInconnue
       then result := Lmodele
end;

Procedure CompileModelisation;
var iY : integer;
begin
    if NbreModele<maxIntervalles
       then begin
            inc(NbreModele);
            trimComplet(LigneCourante);
            with fonctionTheorique[NbreModele] do begin
                 LigneMemo := i;
                 compileM(LigneCourante,posErreurLigne,longErreur);
                 if (pos('PI', UpperCase(ligneCourante))>0) or
                    (pos(PiMin, ligneCourante)>0) or
                    (pos(omegaMin, ligneCourante)>0) then
                       Fvaleurs.passageEnRadian(false);
            end;
            if ModifInverse then exit;
            if NbreModele>1 then begin
                 if fonctionTheorique[1].GenreC<>fonctionTheorique[NbreModele].GenreC then
                      IsModeleSysteme := false;
                 if (codeErreurC='') and
                    (fonctionTheorique[1].GenreC in [g_diff1,g_diff2]) and
                    (fonctionTheorique[1].indexY=fonctionTheorique[NbreModele].indexY) then
                      IsModeleSysteme := false;
            end;
            with pages[pageCourante] do begin
                 iY := fonctionTheorique[nbreModele].indexY;
                 if (debut[NbreModele]=0) and
                    (iY<>grandeurInconnue) and
                    isNan(valeurVar[iY,0])
                    then debut[NbreModele] := 1;
                 if (fin[NbreModele]=pred(nmes)) and
                    (iY<>grandeurInconnue) and
                    isNan(valeurVar[iY,pred(nmes)])
                    then fin[NbreModele] := nmes-2;
            end;
      end
      else begin
           codeErreurC := erMaxModele;
           posErreurLigne := 0;
      end;
end; // CompileModelisation

Procedure CompileSuperposition;
begin
     if NbreFonctionSuper<maxIntervalles
        then begin
            inc(NbreFonctionSuper);
            trimComplet(LigneCourante);
            fonctionSuperposee[NbreFonctionSuper].compileM(
                LigneCourante,posErreurLigne,longErreur);
            if (codeErreurC='') and
               not(fonctionSuperposee[NbreFonctionSuper].GenreC in [g_fonction,g_equation])
                   then codeErreurC := erGenreModele
        end
        else begin
             codeErreurC := erMaxModele;
             posErreurLigne := 0;
        end;
end; // CompileSuperposition

var m,j : integer;
begin
    IsModeleSysteme := true;
    for i := 1 to maxParametres do begin
        paramInverse[i] := false;
        inversePermis[i] := true;
    end;
    codeErreurC := '';
    modifInverse := false;
    i := 0;
    while i<FRegressiMain.MemoModele.Lines.count do begin
        LigneCourante := FRegressiMain.memoModele.Lines[i];
        case TypeDeLigne of
            Lcommentaire : ;
            Lmodele : compileModelisation;
            Lsuperpose : compileSuperposition;
        end;
        if codeErreurC=''
           then posErreur := posErreur + length(LigneCourante) + 2 { 2=CR+LF }
           else begin
                posErreur := posErreur + posErreurLigne;
                break;
           end;
     if modifInverse
        then begin
             i := 0;
             codeErreurC := '';
             posErreur := 0;
             NbreParam := 0;
             NbreModele := 0;
             NbreFonctionSuper := 0;
             modifInverse := false;
         end
         else begin
            inc(i);
            for j := 1 to NbreParam do
                if not paramInverse[j] then inversePermis[j] := false;
         end;
     end; // while i
 // recompiler les modéles si modifInverse
     if codeErreurC=''
        then begin
           TexteModele.Clear;
           for i := 0 to pred(FRegressiMain.MemoModele.Lines.count) do
               TexteModele.Add(FRegressiMain.MemoModele.Lines[i]);
           for m := 1 to NbreModele do with fonctionTheorique[m] do begin
               NbreParamModele := 0;
               for i := 1 to NbreParam do
                   if ParamToIndex(i) in depend then
                      inc(NbreParamModele);
           end;
           if NbreModele>0
              then include(etatModele,ModeleDefini)
              else include(etatModele,PasDeModele);
           if NbreFonctionSuper>0 then include(etatModele,SimulationDefinie);
           { TODO :  rechercher si y ne dépend que de x } 
        end
        else afficheErreur(codeErreurC,0);
    include(Modif,gmModele);
    modeleDependant := false;
    for i := 1 to NbreModele do
        for j := succ(i) to NbreModele do
            modeleDependant := modeleDependant or
            ((fonctionTheorique[i].depend * fonctionTheorique[j].depend)<>[]);
end; // CompileModele

Procedure TgrapheVariab.ConstruitModele;

Procedure ConstruitFonction(m : codeIntervalle);
var l,k : integer;
    dependPossible : TsetGrandeur;
begin
  with fonctionTheorique[m] do begin
     lineaire := true; { par défaut }
     DeriveeForm(fonctionTheorique[m],
             grandeurs[indexX],fchi2,dependPossible);
     if not (traceEllipse or avecChi2) then libere(fchi2);
     lineaireVar := not(indexX in dependPossible);
     for k := 1 to NbreParam do begin
         DeriveeForm(fonctionTheorique[m],Parametres[k],
            derf[m,k],dependPossible);
         for l := 1 to NbreParam do
             if ParamToIndex(l) in dependPossible then begin
               exclude(etatModele,modeleLineaire);
               lineaire := false;
           end;
     end; // for k
  end; {with}
end; // ConstruitFonction

procedure ConstruitDiff(m : codeIntervalle);
// pour dérivée seconde ou première : y'=f(y,x,a,b,c) ou y''=f(y,y',x,a,b,c)
var
   derf_y,derf_yprime : Pelement; { df/dy' et df/dy }
   l : integer;
   dependDer : TsetGrandeur;
   second : boolean;
begin
    exclude(etatModele,modeleLineaire);
    with fonctionTheorique[m] do begin
         lineaire := false;
         lineaireVar := false;
         derf_y := nil;derf_yprime := nil;
         second := genreC=g_diff2;
         libere(fchi2);
         DeriveeForm(fonctionTheorique[m],addrY,derf_y,dependDer);
         if second then
             DeriveeForm(fonctionTheorique[m],addrYp,derf_yprime,dependDer);
         for l := 1 to NbreParam do begin
             DeriveeForm(fonctionTheorique[m],Parametres[l],derf[m,l],dependDer);
             if second
                then construire2(derf_y,derf_yprime,derf[m,l],l)
                else construire1(derf_y,derf[m,l],l);
             if Parametres[l]=fonctionTheorique[m].calcul^.varx
                then derf[m,l].valeurGlb := 1
                else derf[m,l].valeurGlb := 0;
             if Parametres[l]=fonctionTheorique[m].calcul^.vary
                  then derf[m,l].valeurInitDer := 1
                  else derf[m,l].valeurInitDer := 0;
//  valeur initiale fonction et dérivée nulle sauf pour
//  y0 : fonction=1 ;  y'0 : dérivée=1 
   end;// for l
   end;// with
   libere(derf_y);
   libere(derf_yprime);
end; // ConstruitDiff

procedure ConstruitEquation(m : codeIntervalle);
// pour équation f(y,x,a,b,c)=0
var
   derf_y : Pelement; { df/dy }
   l : integer;
   dependDer : TsetGrandeur;
begin
    exclude(etatModele,modeleLineaire);
    with fonctionTheorique[m] do begin
         lineaire := false;
         lineaireVar := false;
         derf_y := nil;
         libere(fchi2);
         DeriveeForm(fonctionTheorique[m],addrY,derf_y,dependDer);
         for l := 1 to NbreParam do begin
              DeriveeForm(fonctionTheorique[m],Parametres[l],derf[m,l],dependDer);
              construireEquation(derf_y,derf[m,l]);
         end; // for l
   end;// with
   libere(derf_y);
end; // ConstruitEquation

Procedure VerifierGraphe;
var iPrinc,i : integer;
    CoordOK : boolean;
    m : integer;
begin
     coordOK := false;
     with fonctionTheorique[1] do coordOK := coordOK or
              ( (grandeurs[indexX].nom=coordonnee[1].nomX) and
                (grandeurs[indexY].nom=coordonnee[1].nomY) ) or
              ( (grandeurs[indexX].nom=coordonnee[1].nomY) and
                (grandeurs[indexY].nom=coordonnee[1].nomX) );
     if not CoordOK and (NbreModele>1) then
            coordOK := coordOK or
            ((grandeurs[fonctionTheorique[1].indexY].nom=coordonnee[1].nomX) and
              (grandeurs[fonctionTheorique[2].indexY].nom=coordonnee[1].nomY)) or
            ((grandeurs[fonctionTheorique[2].indexY].nom=coordonnee[1].nomX) and
              (grandeurs[fonctionTheorique[1].indexY].nom=coordonnee[1].nomY));
     if not CoordOK and OKReg(OkModifGr,0) then begin
         for i := 2 to maxOrdonnee do with Coordonnee[i] do begin
            nomY := '';
            nomX := '';
            iMondeC := MondeY;
         end;
         with fonctionTheorique[1] do begin
              coordonnee[1].nomX := grandeurs[indexX].nom;
              Coordonnee[1].nomY := grandeurs[indexY].nom;
         end;
         iPrinc := 1;
         for m := 2 to NbreModele do with fonctionTheorique[m] do
             if (grandeurs[indexX].nom=Coordonnee[1].nomX)
                then begin
                    if (grandeurs[indexY].nom<>Coordonnee[1].nomY)
                       then begin
                           inc(iPrinc);
                           Coordonnee[iPrinc].nomX := grandeurs[indexX].nom;
                           Coordonnee[iPrinc].nomY := grandeurs[indexY].nom;
                       end;
                end;
         include(modif,gmModele);
         PaintBox.repaint;
   end; // not CoordOK
   for m := succ(NbreModele) to maxIntervalles do
       fonctionTheorique[m].VariableEgalAbscisse := false;
end; // VerifierGraphe

var m : codeIntervalle;
    l : integer;
    k : codePage;
begin
   if VerifGraphe then VerifierGraphe;
   VerifGraphe := true;
   include(etatModele,modeleLineaire);
   for m := 1 to NbreModele do
   case fonctionTheorique[m].genreC of
      g_fonction : ConstruitFonction(m);
      g_diff1,g_diff2 : ConstruitDiff(m);
      g_equation : ConstruitEquation(m);
   end;
   chercheUniteParametre;
   include(etatModele,UniteParamDefinie);
   for k := 1 to NbrePages do with Pages[k] do begin
        ParamAjustes := false;
        ModeleCalcule := false;
        ModeleErrone := false;
        for m := 1 to NbreModele do
            for l := 0 to pred(NmesMax) do
                valeurTheorique[m,l] := Nan;
   end; // for page[k]
   include(etatModele,ModeleConstruit);
   for m := 1 to NbreModele do with fonctionTheorique[m] do
       VariableEgalAbscisse := grandeurs[indexX]=Monde[mondeX].axe;
end; // construitModele

