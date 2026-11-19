// Pages.pas : fichier include de compile.pas

constructor Tpage.Create;
var i  : codeIntervalle;
    fy,k  : integer;
begin
  AllDataFFT := true;
  NbrePointsSauves := 0;
  FinFFT := -1;
  DebutFFT := 0;
  Active := true;
  Numero := 1;
  TriAfaire := false;
  ModeleErrone := false;
  NmesMax := MaxVecteurDefaut;
  for k := 0 to pred(NbreGrandeurs) do AjouteGrandeurP(k);
  for k := NbreGrandeurs to pred(MaxGrandeurs) do begin
     valeurVar[k] := nil;
     valeurLisse[k] := nil;
     FenetreFourier[k] := nil;
     FFTimag[k] := nil;
     FFTreel[k] := nil;
     FFTampl[k] := nil;
     IncertVar[k] := nil;
     FtexteVar[k] := nil;
  end;
  modeleCalcule := false;
  FPointActif := TBits.create;
  FPointActif.size := MaxVecteurDefaut+1;
  Stat := TcalculStatistique.create;
  Stat2 := TStatistiqueDeuxVar.create;
  for i := 1 to MaxIntervalles do begin
      PrecisionModele[i] :=0;
      chi2[i] := 0;
      setLength(valeurTheorique[i],NmesMax+1);
      for fy := 0 to pred(NmesMax) do
          valeurTheorique[i,fy] := Nan;
      X_inter[i] := Nan;
      Y_inter[i] := Nan;
  end;{i}
  for k := 0 to MaxVecteurDefaut do FPointActif[k] := true;
  NbrePointsInactifs := 0;
  TexteResultatModele := TstringList.Create;
  Reset;
end;// TPage.Create

constructor Tsauvegarde.Create;
var k  : codePage;
begin
  NbreMax := MaxVecteurDefaut;
  for k := low(codePage) to high(codePage) do begin
      valeurVect[k] := nil;
      IncertVect[k] := nil;
  end;
  Nbre := 0;
end; // TSauvegarde.Create

function Tpage.TitrePage : string;
begin
    if NbrePages=1
       then TitrePage := commentaireP
       else Result := 'N°'+intToStr(numero)+' '+commentaireP
end;

procedure Tpage.Reset;
var i : codeIntervalle;
    j : codeParam;
begin
  ParamAjustes := false;
  Active := true;
  nmes := 0;
  FinFFT := -1;
  TriAfaire := false;
  //Chi2Permis := false;  Chi2Actif := false;
  DebutFFT := 0;
  commentaireP := '';
  ModifiedP := false;
  for j := 1 to maxParametres do
      valeurParam[j] := Nan;
  for i := 1 to MaxIntervalles do begin
      Debut[i] := 0;
      Fin[i] := -1;
  end;
  TexteResultatModele.Clear;
end; // Page.Reset

procedure Tpage.GenereLisseP(index : codeGrandeur);
var tampon : vecteur;
begin
    try
     if (grandeurs[index].genreG=variable) and
        (valeurLisse[index]=valeurVar[index]) then begin
           setLength(tampon,NmesMax+1);
           valeurLisse[index] := tampon;
     end;
    except
        on EOutOfMemory do valeurLisse[index] := valeurVar[index]
    end;
end;

procedure Tpage.LibereLisseP(index : codeGrandeur);
begin
     if valeurLisse[index]<>valeurVar[index] then begin
         valeurLisse[index] := nil;
         valeurLisse[index] := valeurVar[index]
     end
end;

procedure Tpage.LibereFourierP(index : codeGrandeur);
begin
     FFTimag[index] := nil;
     FFTreel[index] := nil;
     FFTampl[index] := nil;
     FenetreFourier[index] := nil;
end;

destructor Tpage.destroy;
var i : codeIntervalle;
    k : integer;
begin
   TexteResultatModele.free;
   Stat.free;
   Stat2.free;
   FPointActif.free;
   for k := 0 to pred(NbreGrandeurs) do
       LibereGrandeurP(k);
   for i := 1 to maxIntervalles do
       valeurTheorique[i] := nil;
   inherited destroy
end;

destructor Tsauvegarde.destroy;
var k : codePage;
begin
   for k := low(codePage) to high(codePage) do begin
       valeurVect[k] := nil;
       incertVect[k] := nil;
   end;
   inherited destroy
end;

Function Tpage.ParamEtPrec(k : codeGrandeur;avecPrecision : boolean) : String;
const PrecisionRef = 1e-3;
var puissValeur : integer;
    CoeffValeur,valeurDix : double;
    Precision,Decimales : integer;
    tampon,tamponPrec : String;
    PrecOk : boolean;
    valeurLoc,precLoc : double;
    expPrec,expValeur,premierChiffre : integer;
begin // ParamEtPrec
   tampon := '';
   valeurLoc := abs(valeurParam[k]);
   precLoc := incertParam[k];
   Precision := 0;
   if k<=NbreParam then with Parametres[k] do begin
      precOK := ParamAjustes and
           ( valeurLoc>precLoc/10 ) and
           ( valeurLoc<1e8*precLoc );
      if precOK then begin
           try
           expPrec := floor(log10(precLoc));
           expValeur := ceil(log10(valeurLoc));
           Precision := expValeur-expPrec;
           if Precision<0 then raise EIncertitudeError.Create('');
           premierChiffre := floor(precLoc*dix(-expPrec));
           if premierChiffre<3 then inc(Precision); // deux chiffres pour 0,13 ou 0,24
           except
           precOK := false;
           end;
      end;// precOK
      if precOK
         then begin
            if Precision<=2
               then Precision := 3
               else if Precision>PrecisionMax
                  then Precision := PrecisionMax;
            PuissValeur := 3*floor(log10(valeurLoc)/3);
            CoeffValeur := dix(-puissValeur);
         end
         else begin
            Precision := PrecisionMax div 2;
            PuissValeur := 0;
            CoeffValeur := 1;
         end;
   Decimales := Precision-1;
   valeurDix := valeurParam[k]*CoeffValeur;
   if valeurDix>=10 then dec(Decimales);
   if valeurDix>=100 then dec(Decimales);
   tampon := FloatToStrF(valeurDix,ffFixed,Precision,Decimales);
   if avecPrecision then if precOK
      then begin
         valeurDix := precLoc*CoeffValeur;
         if valeurDix>=1000
            then tamponPrec := IntToStr(round(valeurDix))
            else tamponPrec := FloatToStrF(valeurDix,ffFixed,Precision,Decimales);
         tampon := tampon+' ±'+tamponPrec;
      end
      else tampon := tampon+' ??';
   tampon := '('+tampon+')';
   if correct
      then tampon := tampon+' '+NomAff(PuissValeur)
      else begin
          if puissValeur<>0 then
             tampon:=tampon+'10'+puissToStr(puissValeur);
          tampon := tampon+' S.I.';
      end;
  result := nom+'='+tampon
end end; // ParamEtPrec

Function Tpage.ParamNum(k : codeGrandeur) : String;
var puissValeur : shortInt;
    CoeffValeur,valeurDix : double;
    Precision,Decimales : byte;
    tampon : String;
    PrecOk : boolean;
    valeurLoc,precLoc : double;
begin // ParamNum
   if k<=NbreParam then with Parametres[k] do begin
      valeurLoc := valeurParam[k];
      precLoc := incertParam[k];
      Precision := 0;
      precOK := ParamAjustes and
           ( abs(valeurLoc)>precLoc/10 ) and
           ( abs(valeurLoc)<1e8*precLoc );
      if precOK then begin
           try
           Precision := floor(log10(abs(valeurLoc))-floor(log10(precLoc))); // +1
           except
           precOK := false;
           end;
      end; // precOK
      if precOK
         then begin
            if Precision<=2
               then Precision := 3
               else if Precision>PrecisionMax
                  then Precision := PrecisionMax;
         end
         else Precision := PrecisionMax div 2;
   PuissValeur := 3*floor(log10(abs(valeurLoc))/3);
   CoeffValeur := dix(-puissValeur);
   Decimales := Precision-1;
   valeurDix := valeurLoc*CoeffValeur;
   if valeurDix>=10 then dec(Decimales);
   if valeurDix>=100 then dec(Decimales);
   tampon := FloatToStrF(valeurDix,ffFixed,Precision,Decimales);
   if puissValeur<>0 then
      tampon := tampon+pointMedian+'10'+puissToStr(puissValeur);
   result := tampon;
   end // param existant
   else result := '';
end; // ParamNum

Function Tpage.AjouteGrandeurP(index : codeGrandeur) : boolean;
var fy : integer;
begin
  try
  AjouteGrandeurP := true;
  case grandeurs[index].genreG of
       variable : begin
           setLength(valeurVar[index],NmesMax+1);
           setLength(incertVar[index],NmesMax+1);
           for fy := 0 to pred(NmesMax) do valeurVar[index,fy] := Nan;
           for fy := 0 to pred(NmesMax) do incertVar[index,fy] := Nan;
           fftImag[index] := nil;
           fftReel[index] := nil;
           fftAmpl[index] := nil;           
           fenetreFourier[index] := nil;
           valeurLisse[index] := valeurVar[index];
       end;
       constante : begin
          valeurConst[index] := Nan;
          incertConst[index] := Nan;
          TexteConst[index] := '';
       end;
  end;
  FtexteVar[index] := nil;
  iRaie1[index] := 1;
  except
      on EOutOfMemory do begin
         valeurVar[index] := nil; // à améliorer !
         valeurLisse[index] := nil;
         AjouteGrandeurP := false;
      end;
  end;
end;

procedure Tpage.GenereSpectreFourierP(index : codeGrandeur);
var Df : double;
    i : integer;
begin
    DefinitGrandeurFrequence;
    try
    newFourierP(index);
    if FinFFT>=Nmes then FinFFT := pred(Nmes);
    if (FinFFT-DebutFFT)<8 then begin
         debutFFT := 0;
         finFFT := pred(Nmes);
    end;
    allDataFFT := (finFFT=pred(nmes)) and (debutFFT=0);
    if grandeurs[index].Fonct.genreC=g_definitionFiltre
       then begin
            PeriodeFFT := (valeurVar[indexTri,pred(nmes)]-valeurVar[indexTri,0])/pred(Nmes)*Nmes;
            Df := 1/periodeFFT;
            NbreFFT := Puiss2Sup(Nmes);
            for i := 0 to (NbreFFT div 2) do
                grandeurs[cFrequence].valeur[i] := i*Df;
       end
       else begin
          GenereLisseP(indexTri);
          iRaie1[index] := 1;
          Fourier(DebutFFT,FinFFT,NmesMax,NbreFFT,PeriodeFFT,
              valeurVar[indexTri],valeurVar[index],grandeurs[cFrequence].valeur,
              valeurLisse[indexTri],fenetreFourier[index],
              fftReel[index],fftImag[index],fftAmpl[index],c_spectre);
       end;
    except
         on EOutOfMemory do
    end;
end;

procedure Tpage.calculFourierP(index : codeGrandeur;calculFFT : TcalculFFT);
begin
    try
    newFourierP(index);
    GenereLisseP(0);
    Fourier(0,pred(nmes),NmesMax,NbreFFT,PeriodeFFT,
          valeurVar[indexTri],valeurVar[index],grandeurs[cFrequence].valeur,
          valeurLisse[indexTri],fenetreFourier[index],
          fftReel[index],fftImag[index],fftAmpl[index],calculFFT);
    except
         on EOutOfMemory do
    end;
end;

procedure Tpage.NewFourierP(index : codeGrandeur);
begin
      if fftReel[index]=nil then begin
         setLength(fftReel[index],NmesMax+1);
         setLength(fftImag[index],NmesMax+1);
         setLength(fftAmpl[index],NmesMax+1);
         setLength(FenetreFourier[index],NmesMax+1);
         grandeurs[index].valeurR := fftReel[index];
         grandeurs[index].valeurA := fftAmpl[index];         
         grandeurs[index].valeurI := fftImag[index];
      end;
end;

Procedure Tpage.SupprimeGrandeurP(index : codeGrandeur;S : Tsauvegarde);
var i,j : integer;
begin
    if (S<>nil) and (S.undo=UsupprVariab) then begin
        setLength(S.ValeurVect[numero],nmes);
        setLength(S.IncertVect[numero],nmes);
        for j := 0 to pred(nmes) do begin
            S.ValeurVect[numero,j] := valeurVar[index,j];
            S.IncertVect[numero,j] := incertVar[index,j];
        end;
    end;
    if (S<>nil) and (S.undo=UsupprVariabTexte) then begin
        S.SauveTexte[numero] := TstringList.create;
        for j := 0 to pred(nmes) do
            S.SauveTexte[numero].add(texteVar[index,j]);
    end;
    if (S<>nil) and (S.undo=UsupprConst) then begin
        S.ValeurUnique[numero] := valeurConst[index];
        S.IncertUnique[numero] := incertConst[index];
    end;
    if (S<>nil) and (S.undo=UsupprConstTexte) then begin
        if S.SauveTexteUnique=nil then S.SauveTexteUnique := TstringList.create;
        if S.sauveTexteUnique.count<=numero then
           for i := S.sauveTexteUnique.count to numero do
               S.sauveTexteUnique.Add('');
        S.SauveTexteUnique[numero] := texteConst[index];
    end;
    if grandeurs[index].genreG=variable then
       libereGrandeurP(index);
    for i := index to (NbreGrandeurs-2) do begin
         valeurVar[i] := valeurVar[succ(i)];
         valeurLisse[i] := valeurLisse[succ(i)];
         valeurConst[i] := valeurConst[succ(i)];
         incertConst[i] := incertConst[succ(i)];
         FFTimag[i] := FFTimag[succ(i)];
         FFTreel[i] := FFTreel[succ(i)];
         FFTampl[i] := FFTampl[succ(i)];
         FenetreFourier[i] := FenetreFourier[succ(i)];
         IncertVar[i] := incertVar[succ(i)];
         FTexteVar[i] := FTexteVar[succ(i)];
    end;
end; // page.SupprimeGrandeurP

Procedure Tpage.LibereGrandeurP(index : codeGrandeur);
begin
     libereFourierP(index);
     libereLisseP(index);
     if valeurVar[index]<>nil then valeurVar[index] := nil;
     if incertVar[index]<>nil then incertVar[index] := nil;
     if FTexteVar[index]<>nil then begin
        FTexteVar[index].free;
        FTexteVar[index] := nil;
     end;
end; // libereGrandeurP

Procedure Tpage.TransfereVariabP(indexOrig,indexDest : codeGrandeur);
var tamponSL : TstringList;
    tamponS : string;
begin
       swap(fftImag[indexDest],fftImag[indexOrig]);
       swap(fftReel[indexDest],fftReel[indexOrig]);
       swap(fftAmpl[indexDest],fftAmpl[indexOrig]);
       swap(fenetreFourier[indexDest],fenetreFourier[indexOrig]);
       swap(incertVar[indexDest],incertVar[indexOrig]);
       swap(valeurVar[indexDest],valeurVar[indexOrig]);
       swap(valeurLisse[indexDest],valeurLisse[indexOrig]);
       swap(valeurConst[indexDest],valeurConst[indexOrig]);
       swap(incertConst[indexDest],incertConst[indexOrig]);
       TamponSL := FTexteVar[indexOrig];
       FTexteVar[indexOrig] := FTexteVar[indexDest];
       FTexteVar[indexDest] := TamponSL;
       TamponS := TexteConst[indexOrig];
       TexteConst[indexOrig] := TexteConst[indexDest];
       TexteConst[indexDest] := TamponS;
end; // transfereVariableP

procedure Tpage.affecteVariableP(lisse : boolean);
var i,index : integer;
begin
  for i := 0 to pred(NbreVariab) do begin
      index := indexVariab[i];
      with grandeurs[index] do begin
         if lisse
            then valeur := valeurLisse[index]
            else valeur := valeurVar[index];
         valIncert := incertVar[index];
         valeurR := fftReel[index];
         valeurA := fftAmpl[index];         
         valeurI := fftImag[index];
      end;{with}
  end;
  nmesCourant := nmes;
  NbreFFTcourant := NbreFFT;
end;

procedure Tpage.affecteConstParam;
var i : integer;
    index : codeGrandeur;
begin
   for i := 0 to pred(NbreConst) do begin
       index := indexConst[i];
       with grandeurs[index] do begin
           valCourante := valeurConst[index];
           incertCourante := incertConst[index];
       end;{with}
   end;
       for i := 1 to NbreParam do begin
           Parametres[i].valCourante := valeurParam[i];
           Parametres[i].incertCourante := incertParam[i];
       end;
// uniquement pour modèle
   for i := 1 to NbreParam do
       if paramInverse[i] then
          Parametres[i].valCourante := 1/Parametres[i].valCourante;
   derniereErreur := '';
end; // affecteConstParam

procedure Tpage.SupprimeLignes(debut,fin : integer);
var i,j,jmax : integer;
    k,index : codeGrandeur;
    S : tsauvegarde;
begin
     if debut<0 then exit;
     verifMinMaxInt(debut,fin);
     if fin>=nmes then begin
        fin := pred(nmes);
        if debut>fin then exit;
     end;
     S := tsauvegarde.create;
     S.NbreGrandeursSauvees := NbreVariabExp;
     S.Nbre := succ(fin-debut);
     S.undo := UsupprPoint;
     S.numeroPage := numero;
     if NbreVariabExp<MaxPages
        then jmax := NbreVariabExp
        else jmax := MaxPages;
     for j := 1 to jmax do begin
         setLength(S.valeurVect[j],S.Nbre+1);
         setLength(S.incertVect[j],S.Nbre+1);
     end;
     for j := 1 to jmax do begin
         index := indexVariab[pred(j)];
         S.nomData[j] := grandeurs[index].nom;
         for i := 0 to pred(S.Nbre) do begin
             S.valeurVect[j,i] := valeurVar[index,debut+i];
             S.incertVect[j,i] := incertVar[index,debut+i];
         end;
     end;
     dec(Fnmes,S.Nbre);
     for k := 0 to pred(NbreVariab) do begin
         index := indexVariab[k];
         for i := debut to pred(nmes) do begin
             valeurVar[index,i] := valeurVar[index,i+S.nbre];
             incertVar[index,i] := incertVar[index,i+S.nbre];
         end;
         for i := nmes to pred(S.nbre+nmes) do begin
             valeurVar[index,i] := Nan;
             incertVar[index,i] := Nan;
         end;
         if (grandeurs[index].fonct.genreC=g_texte) and
            (FtexteVar[index]<>nil) then begin
            try
            for i := debut to pred(nmes) do
                FtexteVar[index].strings[i] := FtexteVar[index].strings[i+S.nbre];
            except
            end;
         end;
       end;
   CalculGlb;
// recalcul des fonctions globales : dérivée, maxi ...
   PileSauvegarde.Push(S);
end;

Function Tpage.ValeurParametre(i : codeGrandeur) : double;
// Renvoie la valeur du paramètre d'index i
var k : codeGrandeur;
begin
   if i<NbreGrandeurs
      then result := valeurConst[i]
      else begin
         k := indexToParam(i);
         if k<>grandeurInconnue
            then result := ValeurParam[k]
            else result := nan;
     end;
end;

Function Tpage.PrecisionParametre(i : codeGrandeur) : double;
// Renvoie la precision du paramètre d'index i
var k : codeGrandeur;
begin
   if i<NbreGrandeurs
      then result := incertConst[i]
      else begin
         k := indexToParam(i);
         if k<>grandeurInconnue
            then result := EcartTypeParam[k]
            else result := Nan
      end;
end;

Procedure Tpage.SetNmes(NewNmes : LongInt);
var oldNmesMax : LongInt;

Procedure AllocationMemoire;
var i,N,k : LongInt;
begin
        N := NmesMax + 1;
        for i := 1 to MaxIntervalles do
            setLength(valeurTheorique[i],N);
        for i := 0 to pred(NbreGrandeurs) do
            if grandeurs[i].genreG=variable then begin
               libereLisseP(i);
               setLength(valeurVar[i],N);
               valeurLisse[i] := valeurVar[i];
               setLength(incertVar[i],N);               
               if fftReel[i]<>nil then begin
                  setLength(fftReel[i],N);
                  setLength(fftImag[i],N);
                  setLength(fftAmpl[i],N);
                  setLength(FenetreFourier[i],N);
               end;
           end; // variable
        FPointActif.size := N;
        for k := oldNmesMax to NmesMax do FPointActif[k] := true;
end;

begin
   if newNmes>nmesMax
      then begin
        oldNmesMax := NmesMax;
        NmesMax := Puiss2Sup(NewNmes);
        if NmesMax>MaxMaxVecteur
           then NmesMax := MaxMaxVecteur;
        if newNmes>NMesMax
           then newNmes := NMesMax;
        try
        AllocationMemoire;
        changeAdresse := true;
        Fnmes := newNmes;
        except
           NmesMax := oldNmesMax;
        end;
      end
      else Fnmes := newNmes;
end;

Procedure Tsauvegarde.SetNombre(NewNbre : integer);

Procedure AllocationMemoire;
var i,N : integer;
begin
        N := NbreMax + 2;
        for i := 1 to NbreGrandeursSauvees do begin
            setLength(valeurVect[i],N);
            setLength(incertVect[i],N);
        end;
end;

begin
     if newNbre>nbreMax then begin
        if newNbre>MaxMaxVecteur then exit;
        NbreMax := Puiss2Sup(NewNbre);
        try
        AllocationMemoire;
        except
         on EOutOfMemory do begin
            NbreMax := maxVecteurDefaut;
            if newNbre>NbreMax then newNbre := nbreMax;
            AllocationMemoire;
         end;
       end;
     end;
     Fnbre := newNbre;
end; // setNombre

Procedure Tsauvegarde.Restaure;
var oldNmes : integer;
    i,j : integer;
    index : integer;
    p : codePage;
begin
   case undo of
       UsupprPage : if NbrePages<MaxPages then begin
             inc(NbrePages);
             pageCourante := NbrePages;
             Pages[NbrePages] := PageSauvee;
       end;
       UsupprPoint : begin
          oldNmes := Pages[NumeroPage].nmes;
          Pages[NumeroPage].nmes := oldNmes+nbre;
          for j := 1 to NbreGrandeursSauvees do begin
              index := IndexNom(nomData[j]);
              for i := 0 to pred(nbre) do
                  Pages[NumeroPage].valeurVar[index,oldNmes+i] := valeurVect[j,i];
          end;
          pages[NumeroPage].TriAFaire := true;
          pages[NumeroPage].Tri;
          pages[NumeroPage].RecalculP;
       end;
       UsupprConst : begin
          index := AjouteGrandeurE(GrandeurSauvee);
          for p := 1 to NbrePages do begin
              pages[p].valeurConst[index] := valeurUnique[p];
              pages[p].incertConst[index] := valeurUnique[p];
          end;
       end;
       UsupprVariab : begin
          index := AjouteGrandeurE(GrandeurSauvee);
          for p := 1 to NbrePages do begin
              for j := 0 to pred(pages[p].nmes) do begin
                  pages[p].valeurVar[index,j] := valeurVect[p,j];
                  pages[p].incertVar[index,j] := incertVect[p,j];
              end;
              pages[p].RecalculP;
          end;
       end;
       UsupprConstTexte : begin
          index := AjouteGrandeurE(GrandeurSauvee);
          for p := 1 to NbrePages do
              pages[p].TexteConst[index] := SauveTexteUnique[p];
          SauveTexteUnique.free;
       end;
       UsupprVariabTexte : begin
          index := AjouteGrandeurE(GrandeurSauvee);
          for p := 1 to NbrePages do begin
              for j := 0 to pred(pages[p].nmes) do
                  pages[p].texteVar[index,j] := SauveTexte[p].strings[j];
              SauveTexte[p].free;
          end;
       end;
   end;
end;  // Restaure

Function AjoutePage : boolean;
begin
    if NbrePages=MaxPages
       then result := false
       else begin
           try
             if (NbrePages=0) or
                (pages[NbrePages].nmes>0) then begin
                   pages[succ(NbrePages)] :=  Tpage.create;
                   inc(NbrePages);
             end;
             result := true;
             pageCourante := NbrePages;
           except
             result := false;
           end;
      end;
end; // AjoutePage

Function AjoutePageForce : boolean;
begin
    if NbrePages=MaxPages
       then result := false
       else begin
           try
             inc(NbrePages);
             pages[NbrePages] := Tpage.create;
             result := true;
             pageCourante := NbrePages;
           except
             result := false;
           end;
      end;
end; // AjoutePageForce

Function Tpage.Tri : boolean;
// Tri Shell Meyer-Baudoin p 456 ; origine vecteur en 0
var increment,k : integer;
    cle : double;
    fx,i,j,index : integer;
    SauveV : array[codeGrandeur] of double;
    SauveI : array[codeGrandeur] of double;
    SauveT : array[codeGrandeur] of string;
    IsTexte : set of byte;
Begin
   result := false;
   if not(TriAfaire) or FichierTrie then exit;
   isTexte := [];
   DefinitGrandeurFrequence;
   for fx := 0 to pred(NbreVariab) do begin
       index := indexVariab[fx];
       libereLisseP(index);
       libereFourierP(index);
       if grandeurs[index].fonct.genreC=g_texte then include(isTexte,index);
   end;
   increment := 1;
   while (increment<(Nmes div 3)) do increment := succ(3*increment);
   repeat
     for k := 0 to pred(increment) do begin
         i := increment+k;
     while (i<Nmes) do begin
         for fx := 0 to pred(NbreVariab) do begin
                       index := indexVariab[fx];
                       if index in isTexte
                          then sauveT[index] := texteVar[index,i]
                          else begin
                              sauveV[index] := valeurVar[index,i];
                              sauveI[index] := incertVar[index,i];
                          end;
         end; // fx
         j := i-increment;
         cle := ValeurVar[indexTri,i];
         while (j>=0) and (valeurVar[indexTri,j]>cle) do begin
              for fx := 0 to pred(NbreVariab) do begin
                              index := indexVariab[fx];
                              if index in isTexte
                                 then FtexteVar[index].strings[j+increment] := FtexteVar[index].strings[j]
                                 else begin
                                    valeurVar[index,j+increment] := valeurVar[index,j];
                                    incertVar[index,j+increment] := incertVar[index,j];                                    
                                 end;
             end; // fx
             dec(j,increment);
             result := true;
         end; // while
        for fx := 0 to pred(NbreVariab) do begin
               index := indexVariab[fx];
               if index in isTexte
                   then FtexteVar[index].strings[j+increment] := sauveT[index]
                   else begin
                       valeurVar[index,j+increment] := sauveV[index];
                       incertVar[index,j+increment] := sauveI[index];                       
                   end;
       end; // fx
       inc(i,increment);
     end; { while i>=nmes }
     end; { for k }
     increment := increment div 3;
   Until increment=0;
   TriAfaire := false;
//   if modifTri and (numero=pageCourante) then FRegressiMain.WMRegMaj(MajTri,0)
end; // Tpage.Tri

procedure Tsauvegarde.Libere;
begin
     pageSauvee.free;
     grandeurSauvee.free;
end;

procedure Tpage.VerifIntervalles;
var i : codeIntervalle;
    iY,iX : integer;
begin
     for i := 1 to MaxIntervalles do begin
        if (fin[i]<0) or (fin[i]>=nmes) then fin[i] := pred(nmes);
        if (debut[i]<0) or (debut[i]>=nmes) then debut[i] := 0;
        if fin[i]<debut[i] then swap(debut[i],fin[i]);
        if fin[i]=debut[i] then resetDebutFin(i);
        if i<=NbreModele then begin
        iY := fonctionTheorique[i].indexY;
        iX := fonctionTheorique[i].indexX;
        if iY<>grandeurInconnue then
        while (debut[i]<nmes) and (isNan(valeurVar[iY,debut[i]])) do inc(debut[i]);
        if iX<>grandeurInconnue then
        while (debut[i]<nmes) and (isNan(valeurVar[iX,debut[i]])) do inc(debut[i]);
        if iY<>grandeurInconnue then
        while (fin[i]>debut[i]) and isNan(valeurVar[iY,fin[i]]) do dec(fin[i]);
        if iX<>grandeurInconnue then
        while (fin[i]>debut[i]) and isNan(valeurVar[iX,fin[i]]) do dec(fin[i]);
        end;
     end;
end;

Function Tpage.EffacePage(xdebut,ydebut,xfin,yfin : double;indexX,indexY : integer) : boolean;
var j,jj,k,index,oldNmes : integer;
begin
result := false;
if OKreg(OkDelData,0) then begin
       verifMinMaxReal(xdebut,xfin);
       verifMinMaxReal(ydebut,yfin);
       j := 0;
       oldNmes := nmes;
       while (j<nmes) do if
           (valeurVar[indexx,j]>xdebut) and
           (valeurVar[indexx,j]<xfin) and
           (valeurVar[indexy,j]>ydebut) and
           (valeurVar[indexy,j]<yfin)
              then begin
                  dec(Fnmes);
                  result := true;
                  for k := 0 to pred(NbreVariab) do begin
                      index := indexVariab[k];
                      for jj := j to pred(nmes) do
                          valeurVar[index,jj] := valeurVar[index,succ(jj)];
                  end;
              end
              else inc(j);
        if result then
           for k := 0 to pred(NbreVariab) do begin
              index := indexVariab[k];
              for jj := nmes to pred(oldNmes) do
                  valeurVar[index,jj] := Nan;
           end;
end end; // effacePage

Procedure SupprimePage(numero : integer;avecSauvegarde : boolean);
var page : integer;
    S : Tsauvegarde;
begin
   if (numero<1) or (numero>NbrePages) then exit;
   if NbrePages=1
      then pages[1].reset
      else begin
        if avecSauvegarde
           then begin
               S := Tsauvegarde.create;
               S.undo := UsupprPage;
               S.PageSauvee := Pages[numero];
               PileSauvegarde.push(S);
           end
           else pages[numero].free;
        for page := succ(numero) to NbrePages do
            pages[pred(page)] := pages[page];
        dec(NbrePages);
        if pageCourante>NbrePages then PageCourante := 1;
      end;
end; // SupprimePage

Procedure Tpage.ResetDebutFin(i : codeIntervalle);
begin
       debut[i] := 0;
       fin[i] := pred(nmes);
       if (i<=NbreModele) and
          (fonctionTheorique[i].indexY<>grandeurInconnue) and
          (fonctionTheorique[i].indexX<>grandeurInconnue) then begin
       while isNan(valeurVar[fonctionTheorique[i].indexY,debut[i]]) or
             isNan(valeurVar[fonctionTheorique[i].indexX,debut[i]])
            do inc(debut[i]);
       while isNan(valeurVar[fonctionTheorique[i].indexY,fin[i]]) or
             isNan(valeurVar[fonctionTheorique[i].indexX,fin[i]])
            do dec(fin[i]);
       end;
end;

function Tpage.getTexteVar(indexV,indexP : integer) : string;
begin
    if (FtexteVar[indexV]<>nil) and
       (indexP<FtexteVar[indexV].count)
          then result := FtexteVar[indexV].strings[indexP]
          else result := '';
end;

procedure Tpage.setTexteVar(indexV,indexP : integer;value : string);
var i : integer;
begin
    if FtexteVar[indexV]=nil then FtexteVar[indexV] := TstringList.create;
    if FtexteVar[indexV].count<=indexP then
        for i := FtexteVar[indexV].count to indexP do
            FtexteVar[indexV].Add('');
    FtexteVar[indexV].strings[indexP] := value;
end;

procedure Tpage.setPointActif(index : integer;value : boolean);
begin
    FpointActif[index] := value;
    if value
       then dec(NbrePointsInactifs)
       else inc(NbrePointsInactifs)
end;

function Tpage.getPointActif(index : integer) : boolean;
begin
    if numero>0
       then result := FPointActif[index]
       else if index<=NbrePages
          then result := Pages[index+1].active
          else result := true

end;

// Pages.pas


