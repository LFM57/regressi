// gestVar.pas : fichier inclus de compile.pas

procedure videParam;
var i : codeParam;
begin
       NbreParam := 0;
       for i := 1 to MaxParametres do
          Parametres[i].nom := '';
end;

Function GetIndexInit(f : Tgrandeur) : codeGrandeur;
var nomInit : string;
begin
    nomInit := f.nom+'[0]';
    result := indexNom(nomInit);
    if result=GrandeurInconnue then begin
       nomInit := f.nom+'0';
       result := indexNom(nomInit);
    end;
end;

Function GrandeurToIndex(Avariable : tgrandeur) : codeGrandeur;
// Renvoie le code de la grandeur Avariable
var i : integer;
begin
   GrandeurToIndex := GrandeurInconnue;
   for i := 0 to pred(NbreGrandeurs) do
   if grandeurs[i]=Avariable then begin
      GrandeurToIndex := i;
      exit;
   end;
   for i := 1 to NbreParam do
       if Parametres[i]=Avariable then begin
      GrandeurToIndex := ParamToIndex(i);
      exit;
   end;
   if avariable=grandeurs[cFrequence] then result := cFrequence;
end;

Function indexNomVariab(const nomX : string) : codeGrandeur;
// Renvoie le code de la variable de nom : nomX
var i : integer;
begin
   result := GrandeurInconnue;
   if nomX='' then exit;
   for i := 0 to pred(NbreGrandeurs) do
       if nomX=grandeurs[i].nom then begin
         result := i;
         exit;
       end;
   if nomX=grandeurs[cDeltat].nom then result := cDeltat;
   if nomX=grandeurs[cIndice].nom then result := cIndice;
end;

Function indexNom(const nomX : string) : codeGrandeur;
// Renvoie le code de la grandeur de nom nomX
var i : integer;
begin
   result := indexNomVariab(nomX);
   if nomX='' then exit;
   if result=grandeurInconnue then
       for i := 1 to NbreParam do
          if nomX=Parametres[i].nom then begin
             result := ParamToIndex(i);
             exit;
          end;
end;

Procedure libereGrandeurE(index : codeGrandeur);
var i : integer;
begin
    if index>maxGrandeurs then exit;
    with grandeurs[index] do
        case genreG of
           Constante : begin
              dec(NbreConst);
              if fonct.genreC=g_experimentale then dec(NbreConstExp);
              if fonct.genreC=g_texte then dec(NbreConstTexte);
           end;
           Variable : begin
              for i := 1 to NbrePages do
                  pages[i].libereGrandeurP(index);
              dec(NbreVariab);
              if fonct.genreC=g_experimentale then dec(NbreVariabExp);
              if fonct.genreC=g_texte then dec(NbreVariabTexte);
           end;
           ConstanteGlb : dec(NbreConstGlb);
       end;
    oldGrandeurs.Add(grandeurs[index]);
    dec(NbreGrandeurs);
    for i := index to pred(NbreGrandeurs) do
        grandeurs[i] := grandeurs[succ(i)];
    ConstruireIndex;
end;// libereGrandeurE

Procedure transfereVariabE(indexOrig,indexDest : codeGrandeur);
var page : integer;
    tampon : tgrandeur;
begin
    if indexOrig=indexDest then exit;
    if grandeurs[indexOrig].genreG<>constanteGlb then
       for page := 1 to NbrePages do
           pages[page].transfereVariabP(indexOrig,indexDest);
    tampon :=  grandeurs[indexDest];
    grandeurs[indexDest] := grandeurs[indexOrig];
    grandeurs[indexOrig] := tampon;
end; // TransfereVariabE

Procedure transfereParamE(indexOrig,indexDest : codeParam);
var page : integer;
    tampon : tgrandeur;
begin
    if indexOrig=indexDest then exit;
    for page := 1 to NbrePages do with pages[page] do
        swap(valeurParam[indexDest],valeurParam[indexOrig]);
    tampon := parametres[indexDest];
    parametres[indexDest] := parametres[indexOrig];
    parametres[indexOrig] := tampon;
end; // TransfereParamE 

Procedure RecalculE;
var p : codePage;
    index : codeGrandeur;
    c : byte;
begin // Pour calcul des grandeurs Glb
    for c := 1 to NbreConst do begin
        index := indexConst[pred(c)];
        for p := 1 to NbrePages do begin
            grandeurs[index].valeurPage[p] := pages[p].valeurConst[index];
            grandeurs[index].incertPage[p] := pages[p].incertConst[index];
        end;
    end;
        for c := 1 to NbreParam do
            for p := 1 to NbrePages do begin
                Parametres[c].valeurPage[p] := pages[p].valeurParam[c];
                Parametres[c].incertPage[p] := pages[p].incertParam[c]
            end;
    for p := 1 to NbrePages do
        pages[p].RecalculP;
    pages[pageCourante].affecteVariableP(false);
end;

Procedure RecalculFourierE;
var i : integer;
begin
     for i := 1 to NbrePages do pages[i].RecalculFourierP
end;

Procedure RecalculColonneE;
var i : integer;
begin
     for i := 1 to NbrePages do with pages[i] do
         if modifiedP then ReCalculP
end;

Procedure videVariable;
begin
     NbreVariab := 0;
     NbreVariabExp := 0;
     NbreVariabTexte := 0;
     NbreConst := 0;
     NbreConstExp := 0;
     NbreConstTexte := 0;
     NbreConstGlb := 0;
     NbreFiltre := 0;
     FillChar(indexConst,sizeOf(indexConst),grandeurInconnue);
     FillChar(indexConstExp,sizeOf(indexConstExp),grandeurInconnue);
     FillChar(indexConstTexte,sizeOf(indexConstTexte),grandeurInconnue);
     FillChar(indexConstGlb,sizeOf(indexConstGlb),grandeurInconnue);
     FillChar(indexVariab,sizeOf(indexVariab),grandeurInconnue);
     FillChar(indexVariabExp,sizeOf(indexVariabExp),grandeurInconnue);
     FillChar(indexVariabTexte,sizeOf(indexVariabTexte),grandeurInconnue);
     FillChar(indexFiltre,sizeOf(indexFiltre),grandeurInconnue);
end;

Procedure ConstruireIndex;
var i : integer;
begin
     VideVariable;
     for i := 0 to pred(NbreGrandeurs) do
         case grandeurs[i].genreG of
              constante : begin
                  indexConst[NbreConst] := i;
                  inc(NbreConst);
                  if grandeurs[i].fonct.genreC=g_experimentale then begin
                     indexConstExp[NbreConstExp] := i;
                     inc(NbreConstExp);
                  end;
                  if grandeurs[i].fonct.genreC=g_texte then begin
                     indexConstTexte[NbreConstTexte] := i;
                     inc(NbreConstTexte);
                  end;
              end;
              variable : begin
                  indexVariab[NbreVariab] := i;
                  inc(NbreVariab);
                  if grandeurs[i].fonct.genreC=g_experimentale then begin
                     indexVariabExp[NbreVariabExp] := i;
                     inc(NbreVariabExp);
                  end;
                  if grandeurs[i].fonct.genreC=g_texte then begin
                     indexVariabTexte[NbreVariabTexte] := i;
                     inc(NbreVariabTexte);
                  end;
                  if grandeurs[i].fonct.genreC=g_definitionFiltre then begin
                     indexFiltre[NbreFiltre] := i;
                     inc(NbreFiltre);
                  end;
              end;
              constanteGlb : begin
                  indexConstGlb[NbreConstGlb] := i;
                  inc(NbreConstGlb);
              end;
         end; { case }
end;

Function AjouteGrandeurE(Avariable : tgrandeur) : integer;
var page : integer;
begin
  if NbreGrandeurs=MaxGrandeurs then begin
     AjouteGrandeurE := grandeurInconnue;
     exit;
  end;
  grandeurs[NbreGrandeurs] := Avariable;
  AjouteGrandeurE := NbreGrandeurs;
  if Avariable.genreG in [constante,variable] then
    for page := 1 to NbrePages do
        pages[page].AjouteGrandeurP(NbreGrandeurs);
  if NbrePages>0 then case Avariable.genreG of
     variable : begin
        grandeurs[NbreGrandeurs].valeur := pages[pageCourante].valeurVar[NbreGrandeurs];
        grandeurs[NbreGrandeurs].valIncert := pages[pageCourante].incertVar[NbreGrandeurs];        
     end;
     constante : begin
         grandeurs[NbreGrandeurs].valCourante := pages[pageCourante].valeurConst[NbreGrandeurs];
         grandeurs[NbreGrandeurs].incertCourante := pages[pageCourante].incertConst[NbreGrandeurs];
     end;
  end;
  inc(NbreGrandeurs);
  ConstruireIndex;
end;

Function AjouteExperimentale(const n : string;Agenre : TgenreGrandeur) : integer;
var UU : tgrandeur;
    j : integer;
begin
    j := indexNom(n);
    if (j<>grandeurInconnue) and
       (j<maxGrandeurs) and
       (grandeurs[j].genreG=Agenre) then begin
       result := j;
       exit;
    end;
    UU := tgrandeur.Create;
    UU.init(n,'','',Agenre);
    UU.fonct.genreC := g_experimentale;
    result := ajouteGrandeurE(UU)
end;

Procedure CalculIncertConstGlb(i : codeGrandeur);
begin with grandeurs[i] do
         case fonct.genreC of
              g_experimentale : ;
              g_fonction : if IncertCalc.calcul<>nil
                 then begin
                    try
                    incertCourante := calcule(IncertCalc.calcul);
                    except
                       incertCourante := Nan;
                    end;
                 end;
              else incertCourante := Nan;
         end;
end;

Procedure Tpage.ReCalculP;
const MaxDiff = 10;
type
    TypeEquation = (tFonction,tDiff1,tDiff2,tEuler);
    TdataDiff = record
        indexDiff : byte;
        Yp1,Yp2 : tgrandeur;
        Equation : Pelement;
        typeE : TypeEquation;
    end;
    VecteurSysteme = array[codeGrandeur] of extended;
var DataDiff : array[1..MaxDiff] of TdataDiff;
    NbreDiff : byte;

Procedure CalculEuler;
var i,k,idebut,ifin : integer;
    z : double;
begin
    affecteVariableE(0);
    for k := 1 to NbreDiff do with DataDiff[k] do
        if typeE=tFonction then begin
           z := calcule(equation);
           grandeurs[indexDiff].valCourante := z;
           grandeurs[indexDiff].valeur[0] := z;
        end;
    idebut := 1;
    ifin := pred(nmes);
    for i := idebut to ifin do begin
        try
        affecteVariableE(i);
        for k := 1 to NbreDiff do with DataDiff[k] do begin
           z := calcule(equation);
           grandeurs[indexDiff].valCourante := z;
           grandeurs[indexDiff].valeur[i] := z;
        end;
        except
            on E:exception do derniereErreur := E.message;
        end;
    end;{i}
end; // calculEuler 

Procedure CalculDiff12;
// calcul par Runge-Kunta d'ordre 4 de z(t) solution de
//   z''=f(t,z,z') système équivalent : z'=x  z''=x'=f(t,z,x)
//   ou de z'=f(t,z)
var i : integer;
    index : codeGrandeur;

const dureeMax = 2;  // secondes

Procedure calcPoint;
var  t,deltatsur2 : double;
     p,p1,p2,p2bis,pbis : VecteurSysteme;
     fp,fp1,fp2,fp2bis,fpbis : VecteurSysteme;
     val_p,val_pprime : vecteurSysteme;

Procedure Calc(var ffp,zzp : vecteurSysteme;t,deltat : double);
var k : byte;
begin
    grandeurs[0].valCourante := t;
    for k := 1 to NbreDiff do with DataDiff[k] do begin
       index := indexDiff;
       if typeE=tDiff2 then Yp1.valCourante := val_pprime[index];
       grandeurs[index].valCourante := val_p[index];
    end;
    for k := 1 to NbreDiff do with DataDiff[k] do begin
       index := indexDiff;
       ffp[index] := calcule(equation);
       case typeE of
          tDiff2 : begin
            zzp[index] := val_pprime[index];
            val_p[index] := p[index] + deltat*val_pprime[index];
            val_pprime[index] := fp[index] + deltat*ffp[index];
          end;
          tDiff1 : val_p[index] := val_p[index]+deltat*ffp[index];
          tFonction : val_p[index] := ffp[index];
       end;   
    end;
end; { Calc }

var k : integer;
    valYsec : double;
begin
     t := grandeurs[0].valeur[pred(i)];
     deltatSur2 := (grandeurs[0].valeur[i]-t)/2;
     affecteVariableE(i);
     for k := 1 to NbreDiff do with DataDiff[k] do begin
        index := indexDiff;
        p[index] := grandeurs[index].valeur[pred(i)];
        if typeE=tDiff2 then fp[index] := Yp1.valeur[pred(i)];
     end;
     val_p := p;
     val_pprime := fp;
     Calc(fp1,p1,t,deltatSur2);
     Calc(fp2,p2,t+deltatSur2,deltatSur2);
     Calc(fp2bis,p2bis,t+deltatSur2,deltatSur2*2);
     Calc(fpbis,pbis,t+deltatSur2*2,0);
     for k := 1 to NbreDiff do with DataDiff[k] do begin
        index := indexDiff;
        valYsec := (fp1[index]+2*fp2[index]+2*fp2bis[index]+fpbis[index])/6;
        case typeE of
           tDiff2 : begin
             Yp2.valeur[i] := valYsec;
             Yp1.valeur[i] := Yp1.valeur[pred(i)] + deltatSur2*valYsec*2;
             grandeurs[index].valeur[i] := grandeurs[index].valeur[pred(i)] +
                deltatSur2*(p1[index]+2*p2[index]+2*p2bis[index]+pbis[index])/3;
           end;
           tDiff1 : begin
              Yp1.valeur[i] := valYsec;
              grandeurs[index].valeur[i] := grandeurs[index].valeur[pred(i)] +
                 deltatSur2*valYsec*2;
           end;      
           tFonction : grandeurs[index].valeur[i] := valYsec;
       end;    
     end;
end; // calcPoint

Procedure calcPoint0;
var k : integer;
    z : double;
begin
     for k := 1 to NbreDiff do with DataDiff[k] do begin
        z := calcule(equation);
        case typeE of
           tDiff2 : begin
              Yp2.valeur[0] := z;
              Yp2.valCourante := z;
           end;
           tDiff1 : begin
              Yp1.valeur[0] := z;
              Yp1.valCourante := z;
           end;
           tFonction : begin
              grandeurs[indexDiff].valCourante := z;
              grandeurs[indexDiff].valeur[0] := z;
           end;
       end;
     end;
end; // calcPoint0

var j : integer;
begin
     try
     i := 0;
     affecteVariableE(0);
     calcPoint0;
     for i := 1 to pred(Nmes) do calcPoint;
     except
         on E:exception do begin
            derniereErreur := E.message;
            for j := i to pred(Nmes) do grandeurs[index].valeur[j] := Nan;
         end;
     end;
end; // CalculDiff12

Procedure CalcCol(i : integer);
begin
    if not(grandeurs[i].fonct.genreC in [g_experimentale,g_texte,g_forward]) and
       not (grandeurs[i].fonct.isSysteme)
           then CalcColonneP(i,false)
end;

Procedure ChercheSystDiff(var IndexModifie : integer);
var DiffDepend,DiffVariab : tsetGrandeur;

Procedure AjouteFonct(i : integer);
var j,k : integer;
begin
       if i<indexModifie then indexModifie := i;
       grandeurs[i].fonct.isSysteme := true;
       inc(NbreDiff);
       include(diffVariab,i);
       diffDepend := diffDepend + grandeurs[i].fonct.depend;
       j := 1;
       while (j<NbreDiff) and
             (DataDiff[j].indexDiff<i) do inc(j);
       for k := NbreDiff downto succ(j) do
             DataDiff[k] := DataDiff[pred(k)];
       DataDiff[j].indexDiff := i;
       DataDiff[j].typeE := Tfonction;
       DataDiff[j].equation := grandeurs[i].fonct.calcul;
end;

var i,j : integer;
    index,i0 : codeGrandeur;
    DiffTrouve,modif : boolean;
begin // ChercheSystDiff 
       NbreDiff := 0;
       DiffTrouve := false;
       DiffVariab := [];
       DiffDepend := [];
       for i := 0 to pred(NbreGrandeurs) do with grandeurs[i].fonct do
           if (genreC in [g_diff1,g_diff2])  or
              (isSysteme and
               not(genreC in [g_derivee,g_diff1,g_diff2,g_euler])) then begin
                 inc(NbreDiff);
                 if NbreDiff>MaxDiff then begin
                     afficheErreur(erDiffSimul,0);
                     exit;
                 end;
                 with DataDiff[NbreDiff] do begin
                     indexDiff := i;
                     case genreC of
                          g_diff1 : typeE := tDiff1;
                          g_diff2 : typeE := tDiff2;
                          else typeE := tFonction;
                     end;
                     if typeE in [tDiff1,tDiff2]
                        then begin
                           equation := calcul.OperandGlb;
                           i0 := getIndexInit(grandeurs[i]);
                           if isNan(valeurConst[i0]) then exit; // valeur initiale non définie
                        end
                        else equation := calcul;
                     diffDepend := diffDepend + depend;
                     include(diffVariab,i);
                     if i<indexModifie then indexModifie := i;
                     DiffTrouve := DiffTrouve or (genreC in [g_diff1,g_diff2]);
                 end;
           end;
       if DiffTrouve
          then begin
               repeat
           { vérifier fonction incluse dans le système diff }
               modif := false;
               for i := 0 to pred(NbreGrandeurs) do
                   if not grandeurs[i].fonct.isSysteme and
                      (grandeurs[i].fonct.genreC=g_fonction) and
                      (grandeurs[i].genreG=variable) and
                      (i in DiffDepend) and
                      ((grandeurs[i].fonct.depend*diffVariab<>[]) or
                       ((i>DataDiff[1].indexDiff) and
                        (i<DataDiff[NbreDiff].indexDiff))) then begin
                           if NbreDiff=MaxDiff then begin
                              afficheErreur(erDiffSimul,0);
                              exit;
                           end;
                           modif := true;
                           AjouteFonct(i);
                       end;
               until not modif;
//   modif x0 (varX) oblige à recalculer x' ; x'0 (varY) pour x'' 
          end
          else exit;
       for i := 0 to pred(NbreGrandeurs) do
           if (grandeurs[i].fonct.genreC=g_derivee) and
              (grandeurs[i].genreG=variable) then
                  for j := 1 to NbreDiff do begin
                      if (dataDiff[j].typeE in [tDiff2,tDiff1]) and
                         (dataDiff[j].Yp1=grandeurs[i])
                           then grandeurs[i].fonct.isSysteme := true;
                      if (dataDiff[j].typeE=tDiff2) and
                         (dataDiff[j].Yp2=grandeurs[i])
                           then grandeurs[i].fonct.isSysteme := true;
                  end;
       for i := 1 to NbreDiff do with DataDiff[i] do begin
           index := indexDiff;
           with grandeurs[index].fonct.calcul^ do
                case typeE of
                    tDiff1 : begin
                        Yp1 := grandeurs[index].fonct.addrYp;
                        grandeurs[index].valeur[0] := varX.valCourante;
                        Yp1.fonct.isSysteme := true;
                    end;
                    tDiff2 : begin
                        Yp1 := grandeurs[index].fonct.addrYp;
                        Yp2 := grandeurs[index].fonct.addrYp2;
                        grandeurs[index].valeur[0] := varX.valCourante;
                        Yp1.valeur[0] := varY.valCourante;
                        Yp1.fonct.isSysteme := true;
                        Yp2.fonct.isSysteme := true;
                    end;
               end;{case}
       end;
       calculDiff12;
end; // ChercheSystDiff

Procedure ChercheEuler(var IndexModifie : integer);
var DiffDepend,DiffVariab : tsetGrandeur;

Procedure AjouteFonct(i : integer);
var j,k : integer;
begin
       if i<indexModifie then indexModifie := i;
       grandeurs[i].fonct.isSysteme := true;
       inc(NbreDiff);
       include(diffVariab,i);
       diffDepend := diffDepend + grandeurs[i].fonct.depend;
       j := 1;
       while (j<NbreDiff) and
             (DataDiff[j].indexDiff<i) do inc(j);
       for k := NbreDiff downto succ(j) do
             DataDiff[k] := DataDiff[pred(k)];
       DataDiff[j].indexDiff := i;
       DataDiff[j].typeE := Tfonction;
       DataDiff[j].equation := grandeurs[i].fonct.calcul;
end;

var i : integer;
    index,i0 : codeGrandeur;
    DiffTrouve,modif : boolean;
begin // ChercheEuler
       NbreDiff := 0;
       DiffTrouve := false;
       DiffVariab := [];
       DiffDepend := [];
       for i := 0 to pred(NbreGrandeurs) do with grandeurs[i].fonct do
           if (genreC=g_euler) or
              (isSysteme and not(genreC in [g_derivee,g_diff1,g_diff2,g_euler])) then begin
                 inc(NbreDiff);
                 if NbreDiff>MaxDiff then begin
                     afficheErreur(erDiffSimul,0);
                     exit;
                 end;
                 with DataDiff[NbreDiff] do begin
                     indexDiff := i;
                     if genreC=g_euler
                        then begin
                           typeE := tEuler;
                           i0 := getIndexInit(grandeurs[i]);
                           if isNan(valeurConst[i0]) then exit; // valeur initiale non définie
                        end
                        else typeE := tFonction;
                     equation := calcul;
                     diffDepend := diffDepend + depend;
                     include(diffVariab,i);
                     if i<indexModifie then indexModifie := i;
                     DiffTrouve := DiffTrouve or (genreC=g_euler);
                 end;
           end;
       if DiffTrouve
          then begin
               repeat
// vérifier fonction incluse dans le système
               modif := false;
               for i := 0 to pred(NbreGrandeurs) do
                   if not grandeurs[i].fonct.isSysteme and
                      (grandeurs[i].fonct.genreC=g_fonction) and
                      (grandeurs[i].genreG=variable) and
                      (i in DiffDepend) and
                      ((grandeurs[i].fonct.depend*diffVariab<>[]) or
                       ((i>DataDiff[1].indexDiff) and
                        (i<DataDiff[NbreDiff].indexDiff))) then begin
                           if NbreDiff=MaxDiff then begin
                              afficheErreur(erDiffSimul,0);
                              exit;
                           end;
                           modif := true;
                           AjouteFonct(i);
                       end;
               until not modif;
// modif x0 (varX) oblige à recalculer x' ;  x'0 (varY) pour x'' 
          end
          else exit;
       for i := 1 to NbreDiff do with DataDiff[i] do begin
           index := indexDiff;
           if typeE=tEuler then
              with grandeurs[index].fonct do begin
                   if calcul^.varX<>nil then begin
                        try
                        grandeurs[index].valeur[0] := calcul^.varX.valCourante;
                        except
                        grandeurs[index].valeur[0] := 0;
                        end;
                  end;
                  isSysteme := true;
             end;     
       end;
       calculEuler;
end; // ChercheEuler

Procedure CalculIncertP;
var i,j : integer;
begin
    affecteVariableP(false);
    for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
        case genreG of
           variable : case fonct.genreC of
              g_experimentale : if IncertCalc.expression<>''
                  then for j := 0 to pred(nmes) do begin
                     valCourante := valeurVar[i,j]; // SI ?
                     try
                     IncertVar[i,j] := calcule(IncertCalc.calcul)
                     except
                         IncertVar[i,j] := Nan;
                     end;
              end;
              g_fonction,g_derivee,g_deriveeSeconde : ; // fait dans calcColonne
              else for j := 0 to pred(nmes) do
                     IncertVar[i,j] := Nan
           end;{variable  genreC}
           constante : calculIncertConst(i);
           constanteGlb : calculIncertConstGlb(i);
      end;{genreG}
end; // calculIncertP

procedure RemplitPage;
var i : integer;
begin
      setDeltaSimulation;
      valeurVar[0,0] := MiniSimulation;
      if logSimulation
         then for i := 1 to Nmes do
                 valeurVar[0,i] := valeurVar[0,pred(i)]*deltaSimulation
         else for i := 1 to Nmes do
                valeurVar[0,i] := MiniSimulation+i*deltaSimulation;
      AffecteNbreFFT;
      PeriodeFFT := MaxiSimulation-MiniSimulation;
      modifiedP := true;
      grandeurs[cDeltat].valCourante := deltaSimulation;
end;

var i,iModifie : integer;
    avecDiff : boolean;
begin // recalculPage
    if NbreGrandeurs=0 then exit;
    affecteConstParam;
    affecteVariableP(false);
    if ModeAcquisition=acqSimulation then remplitPage;
    AvecDiff := true;
    for i := 0 to pred(NbreGrandeurs) do with Grandeurs[i] do
         if fonct.genreC=g_forward then begin
              AvecDiff := false;
              break;
         end;
    for i := 0 to pred(NbreGrandeurs) do
        calcCol(i);
    iModifie := NbreGrandeurs;
    if avecDiff then begin
         chercheEuler(iModifie);
         chercheSystDiff(iModifie);
    end;
    for i := succ(iModifie) to pred(NbreGrandeurs) do
        calcCol(i);
    calculIncertP;
    modifiedP := false;
//    setChi2;
end; // recalculPage

Procedure Tpage.ReCalculFourierP;
var i : integer;
    Modif : TsetGrandeur;
begin
    affecteConstParam;
    affecteVariableP(false);
    Modif := [];
    if finFFT=-1 then affecteNbreFFT; (*debutFFT=0 ? *)
    for i := 0 to pred(NbreGrandeurs) do with grandeurs[i] do
        if ( (genreG=variable)  and
             (fonct.genreC in [g_correlation,g_enveloppe,g_decalage,
                 g_retardCorr,g_filtrage,g_definitionFiltre,g_harmonique]) ) or
           (fonct.depend*Modif<>[])
              then begin
                   CalcColonneP(i,false);
                   include(modif,i);
              end;
    modifiedP := false;
end; // recalculFourierP

Procedure Tpage.RecalculIncert(index : codeGrandeur);

Procedure IncertDerivee;
var NbrePointDer : integer;
    indexX,indexY : codeGrandeur;
begin with grandeurs[index].fonct.calcul^ do begin
   if operandDebut<>nil
      then begin
         NbrePointDer := round(calcule(operandDebut));
         if not odd(NbrePointDer) then inc(NbrePointDer);
         if (NbrePointDer>11) or (NbrePointDer<3)
             then NbrePointDer := NbrePointDerivee;
      end
      else NbrePointDer := NbrePointDerivee;
   indexX := grandeurToIndex(varX);
   indexY := grandeurToIndex(varY);
   try
   incertitudeDerivee(varX.valeur,varY.valeur,
                incertVar[indexX],incertVar[indexY],nmes,incertVar[index],
                NbrePointDer);
   except
   end;
end end;

var j : integer;
begin
    affecteConstParam;
    affecteVariableP(false);
    with grandeurs[index] do case genreG of
        variable : case fonct.genreC of
            g_experimentale : if IncertCalc.expression<>''
              then for j := 0 to pred(nmes) do begin
                   valCourante := valeurVar[index,j]; // SI ?
                   try
                   IncertVar[index,j] := calcule(IncertCalc.calcul)
                   except
                       IncertVar[index,j] := Nan
                   end;
              end;
            g_fonction : for j := 0 to pred(nmes) do begin
               affecteVariableE(j);
               CalculIncertFonction(index,j);
            end;
            g_derivee : incertDerivee;
            else for j := 0 to nmes do
                   IncertVar[index,j] := Nan
       end;{variable genreC}
       constante : CalculIncertConst(index);
       constanteGlb : CalculIncertConstGlb(index);
       end;{genreG}
end; // RecalculIncert

Procedure Tpage.CalculIncertFonction(index : codeGrandeur;j : integer);
begin with grandeurs[index] do begin
         try
         if IncertCalc.calcul<>nil
            then valIncert[j] := calcule(IncertCalc.calcul)
            else valIncert[j] := Nan;
         except
            valIncert[j] := Nan;
         end
end end;

Procedure Tpage.CalculIncertConst(i : codeGrandeur);
begin with grandeurs[i] do begin
         try
         case fonct.genreC of
              g_experimentale : if IncertCalc.expression<>''
                  then incertConst[i] := calcule(IncertCalc.calcul);
                   { else entrée dans le tableau }
              g_fonction : if IncertCalc.calcul<>nil
                 then incertConst[i] := calcule(IncertCalc.calcul)
                 else incertConst[i] := Nan;
              else incertConst[i] := Nan;
         end;
         except
         incertConst[i] := Nan;
         end;
         incertCourante := incertConst[i];
end end;

procedure Tpage.CalcColonneP(index : codeGrandeur;lisse : boolean);
var indexX : integer;

Procedure calculFiltrage;
// filtrage : grandeur*operandGlb dans l'espace des fréquences
var  i,j : integer;
     z : complexe;
     x,y : double;
     NfiltreCalc : integer;
     sauveFenetre : Tfenetre;
     sauveDebut,sauveFin : integer;
begin
    sauveFenetre := fenetre;
    if not (fenetre in [rectangulaire,rectangleAjuste]) then fenetre := rectangulaire;
    sauveDebut := debutFFT;
    sauveFin := finFFT;
    debutFFT := 0;
    finFFT := pred(nmes);
    GenereSpectreFourierP(indexX);
    NewFourierP(index);
    NfiltreCalc := -1;
    for j := 0 to pred(NbreFiltre) do
        if indexFiltre[j]<index then NfiltreCalc := j;
// f=0 à part pour éviter erreur /0 lors de passe-bande
    grandeurs[cFrequence].valCourante := grandeurs[cFrequence].valeur[0];
    for j := 0 to NfiltreCalc do with grandeurs[indexFiltre[j]] do begin
          valCourante := valeurR[0];
          valCouranteIm := valeurI[0];
    end;
    grandeurs[cIndice].valCourante := 0;
    x := fftReel[indexX][0];
    y := fftImag[indexX][0];
    try
    calculeCpx(grandeurs[index].fonct.calcul^.operandGlb,z);
    if isNan(z.reel) or isNan(z.imag)
       then begin
            fftReel[index,0] := 0;
            fftImag[index,0] := 0;
       end
       else begin
            fftReel[index,0] := z.reel*x-z.imag*y;
            fftImag[index,0] := z.reel*y+z.imag*x;
       end;
    except
    end;
    for i := 1 to NbreFFT div 2 do begin
        grandeurs[cFrequence].valCourante := grandeurs[cFrequence].valeur[i];
        for j := 0 to NfiltreCalc do with grandeurs[indexFiltre[j]] do begin
              valCourante := valeurR[i];
              valCouranteIm := valeurI[i];
        end;
        grandeurs[cIndice].valCourante := i;
        x := fftReel[indexX][i];
        y := fftImag[indexX][i];
        calculeCpx(grandeurs[index].fonct.calcul^.operandGlb,z);
        fftReel[index,i] := z.reel*x-z.imag*y;
        fftImag[index,i] := z.reel*y+z.imag*x;
    end;{for i}
    for i := succ(NbreFFT div 2) to pred(NbreFFT) do begin
    // f<0 donc complexe conjugué pour signal réel
        fftReel[index,i] := fftReel[index,NbreFFT-i];
        fftImag[index,i] := -fftImag[index,NbreFFT-i];
    end;{for i}
    FourierInverse(Nmes,NbreFFT,DebutFFT,PeriodeFFT,grandeurs[indexTri].valeur,
       grandeurs[index].valeur,fftReel[index],fftImag[index],c_spectre);
    fenetre := sauveFenetre;
    debutFFT := sauveDebut;
    finFFT := sauveFin;
end; // calculFiltrage

Procedure calculDefinitionFiltre;
// définition d'un filtre dans l'espace des fréquences
// et réponse impulsionnelle dans l'espace temporel
var  i,j : integer;
     z : complexe;
     sauveFenetre : Tfenetre;
     NfiltreCalc : integer;
     sauveDebut,sauveFin : integer;
begin
    sauveFenetre := fenetre;
    fenetre := rectangulaire;
    sauveDebut := debutFFT;
    sauveFin := finFFT;
    debutFFT := 0;
    finFFT := pred(nmes);
    GenereSpectreFourierP(index);
    NfiltreCalc := -1;
    for j := 0 to pred(NbreFiltre) do
        if indexFiltre[j]<index then NfiltreCalc := j;
    for i := 0 to NbreFFT div 2 do begin
          grandeurs[cFrequence].valCourante := grandeurs[cFrequence].valeur[i];
          for j := 0 to NFiltreCalc do with grandeurs[indexFiltre[j]] do begin
              valCourante := valeurR[i];
              valCouranteIm := valeurI[i];
          end;
          grandeurs[cIndice].valCourante := i;
          try
          calculeCpx(grandeurs[index].fonct.calcul^.operandGlb,z);
          fftReel[index,i] := z.reel;
          fftImag[index,i] := z.imag;
          except
             if i=0
// f=0 à part pour éviter erreur /0 lors de passe-bande ou passe-haut 
                then begin
                     fftReel[index,0] := 0;
                     fftImag[index,0] := 0;
                end
                else raise
          end;
          fftAmpl[index,i] := sqrt(sqr(fftReel[index,i])+sqr(fftImag[index,i]));
    end;{for i}
    for i := succ(NbreFFT div 2) to pred(NbreFFT) do begin
        fftReel[index,i] := fftReel[index,NbreFFT-i];
        fftImag[index,i] := -fftImag[index,NbreFFT-i];
    end;
    FourierInverse(Nmes,NbreFFT,0,PeriodeFFT,grandeurs[indexTri].valeur,
       grandeurs[index].valeur,fftReel[index],fftImag[index],c_spectre);
 // réponse impulsionnelle
    fenetre := sauveFenetre;
    debutFFT := sauveDebut;
    finFFT := sauveFin;
end; // calculDefinitionFiltre

Procedure calculEnveloppe;
var jMax : integer;
    Xe,Ye : vecteur;

Procedure chercheEquation(const X,Y : vecteur;N : integer);
var i : integer;
    eqV : vecteur;
    eqE : Pelement;
begin
     setLength(Xe,N);
     setLength(Ye,N);
     setLength(eqV,N);
     eqE := grandeurs[index].fonct.calcul.operandGlb;
     for i := 0 to pred(N) do begin
         affecteVariableE(i);
         eqV[i] := calcule(eqE);
     end;
     jMax := 0;
     for i := 0 to N-2 do
         if eqV[i]*eqV[succ(i)]<=0 then begin
            Xe[jMax] := X[i]-eqV[i]*(X[succ(i)]-X[i])/(eqV[succ(i)]-eqV[i]);
            Ye[jMax] := Y[i]+(Xe[jMax]-X[i])*(Y[succ(i)]-Y[i])/(X[succ(i)]-X[i]);
            inc(jMax);
         end;
     eqV := nil;
end;

var sauveFenetre : Tfenetre;
begin
   case round(grandeurs[index].fonct.calcul^.valeurGlb) of
        envMax : chercheMinMax(grandeurs[0].valeur,
                 grandeurs[indexX].valeur,
                 Nmes,true,jMax,Xe,Ye);
        envMin : chercheMinMax(grandeurs[0].valeur,
                 grandeurs[indexX].valeur,
                 Nmes,false,jMax,Xe,Ye);
        envEqu : chercheEquation(grandeurs[0].valeur,
                 grandeurs[indexX].valeur,Nmes);
        envFourier : begin
             sauveFenetre := fenetre;
             fenetre := Rectangulaire;
             CalculFourierP(indexX,c_enveloppe);
             EnveloppeReelle(Nmes,NbreFFT,PeriodeFFT,grandeurs[0].valeur,
                grandeurs[index].valeur,
                fftReel[indexX],fftImag[indexX]);
             if not allDataFFT then GenereSpectreFourierP(indexX);
             fenetre := sauveFenetre;
             exit;
        end;
   end;
   chercheEnveloppe(grandeurs[0].valeur,
                   grandeurs[indexX].valeur,
                   Nmes,
                   Xe,Ye,Jmax,
                   grandeurs[index].valeur);
    Xe := nil;
    Ye := nil;
end; // calculEnveloppe

Procedure calculRetard;
var i : integer;
    coeff,maxi : double;
begin
    Maxi := valeurVar[0,pred(nmes)]-valeurVar[0,0];
    try
    coeff := 1/pred(nmes);
    for i := 0 to pred(nmes) do
        valeurVar[index,i] := Maxi*i*coeff
    except
    end;
end; // calculRetard (pour corrélation)

Procedure calculHarmonique;
// harmonique debut à fin de grandeur
var  i,idebut,ifin : integer;
     sauveFenetre : Tfenetre;
     largeurRaie : integer;
begin
    sauveFenetre := fenetre;
    if not (fenetre in [rectangulaire,rectangleAjuste]) then fenetre := rectangulaire;
    DefinitGrandeurFrequence;
    calculFourierP(indexX,c_spectre);
    newFourierP(index);
    with grandeurs[index].fonct.calcul^ do
    try
        iDebut := round(calcule(OperandGlb));
        ifin := round(calcule(OperandDebut));
    except
        idebut := 1;
        ifin := 1;
    end;
    iRaie1[index] := getFondamental(NbreFFT,fftAmpl[indexX]);
    largeurRaie := iRaie1[index] div 16;
    iDebut := iDebut*iRaie1[index]-largeurRaie;
    iFin := iFin*iRaie1[index]+largeurRaie;
    if iDebut<0 then iDebut := 0;
    if iFin<iDebut then iFin := iDebut;
    if iFin>(NbreFFT div 2) then iFin := NbreFFT div 2;
    if iDebut>iFin then iDebut := iFin;
    for i := 0 to pred(idebut) do begin
             fftReel[index,i] := 0;
             fftImag[index,i] := 0;
    end;{for i}
    for i := idebut to ifin do begin
             fftReel[index,i] := fftReel[indexX,i];
             fftImag[index,i] := fftImag[indexX,i];
    end;{for i}
    for i := succ(ifin) to NbreFFT div 2 do begin
             fftReel[index,i] := 0;
             fftImag[index,i] := 0;
    end;{for i}
    { facteur *2 pour le continu pris en compte par FFT ? }
(*    fftReel[index]^[0] := 2*fftReel[index]^[0];
    fftImag[index]^[0] := 2*fftImag[index]^[0];*)
    for i := succ(NbreFFT div 2) to pred(NbreFFT) do begin
        fftReel[index,i] := fftReel[index,NbreFFT-i];
        fftImag[index,i] := -fftImag[index,NbreFFT-i];
    end;{for i}
    FourierInverse(Nmes,NbreFFT,0,PeriodeFFT,grandeurs[indexTri].valeur,
       grandeurs[index].valeur,fftReel[index],fftImag[index],c_spectre);
    fenetre := sauveFenetre;
    if not allDataFFT then GenereSpectreFourierP(indexX);
end; // calculHarmonique

procedure calculCorrelation;
var indexY : integer;
    i : integer;
    tampon : vecteur;
    coeff,coeffX,coeffY : double;
    sauveFenetre : Tfenetre;
    sauveDebut,sauveFin : integer;
begin with grandeurs[index].fonct.calcul^ do begin
    sauveFenetre := fenetre;
    fenetre := rectangulaire;
    sauveDebut := debutFFT;
    sauveFin := finFFT;
    indexY := GrandeurToIndex(varY);
    fenetre := rectangulaire;
    finFFT := pred(nmes);
    setLength(tampon,NmesMax+1);
    debutFFT := 0;
    calculFourierP(indexX,c_correlation);
    calculFourierP(indexY,c_correlation);
    newFourierP(index);
    fftReel[index,0] := fftReel[indexX,0]*fftReel[indexY,0]*2;
    fftImag[index,0] := 0;
    for i := 1 to pred(NbreFFT) do begin { conjugue(x)*y }
        fftReel[index,i] := fftReel[indexX,i]*fftReel[indexY,i]+
                     fftImag[indexY,i]*fftImag[indexX,i];
        fftImag[index,i] := fftReel[indexX,i]*fftImag[indexY,i]-
                     fftImag[indexX,i]*fftReel[indexY,i];
    end;{for i}
    for i := 0 to pred(Nmes) do
        Tampon[i] := i*PeriodeFFT/NbreFFT;
    FourierInverse(Nmes,NbreFFT,0,PeriodeFFT,tampon,
        grandeurs[index].valeur,fftReel[index],fftImag[index],c_correlation);
    if indexX=indexY
       then coeff := 1/grandeurs[index].valeur[0]
       else begin
           coeffX := 0;coeffY := 0;
           for i := 0 to pred(Nmes) do begin
               coeffY := coeffX+sqr(grandeurs[indexX].valeur[i]);
               coeffX := coeffY+sqr(grandeurs[indexY].valeur[i]);
           end;
           coeff := Nmes/sqrt(coeffX*coeffY);
       end;
    for i := 0 to pred(Nmes) do
        grandeurs[index].valeur[i] := coeff*grandeurs[index].valeur[i];
    tampon := nil;
    fenetre := sauveFenetre;
    debutFFT := sauveDebut;
    finFFT := sauveFin;
end end; // calculCorrelation

Procedure Tri3(v1,v2 : vecteur;v4 : vecteurInt;N : integer);
{ Tri Shell Meyer-Baudoin p 456 de v2 v4 selon v1 }
var increment : integer;
    cle : double;
    sauve2 : double;
    sauveInt : integer;
    i,j,k : integer;
Begin
   increment := 1;
   while ( increment<(N div 3) ) do increment := succ(3*increment);
   repeat
	  for k := 0 to pred(increment) do begin
		  i := increment+k;
		  while (i<N) do begin
			  sauve2 := v2[i];
        sauveInt := v4[i];
			  cle := v1[i];
			  j := i-increment;
			  while (j>=0) and (v1[j]>cle) do begin
				  v1[j+increment] := v1[j];
				  v2[j+increment] := v2[j];
      		v4[j+increment] := v4[j];
				  dec(j,increment);
			  end;
			  v1[j+increment] := cle;
			  v2[j+increment] := sauve2;
      	v4[j+increment] := sauveInt;
			  inc(i,increment);
		   end;
	  end;
	  increment := increment div 3;
   Until increment=0;
end;{tri3}

Procedure calculDerivee; // d(vary)/d(varx)
var vi : vecteurInt;
    valeurX,valeurY,valeurDer : vecteur;
    i,j : integer;
    NbrePointDer : integer;
begin with grandeurs[index].fonct.calcul^ do begin
   if operandDebut<>nil
      then begin
         NbrePointDer := round(calcule(operandDebut));
         if not odd(NbrePointder) then inc(NbrePointDer);
         if (NbrePointDer>MaxPointsDerivee) or (NbrepointDer<MinPointsDerivee) then
             NbrePointDer := NbrePointDerivee;
      end
      else NbrePointDer := NbrePointDerivee;
   setLength(vi,NmesMax+2);
   setLength(valeurDer,NmesMax+2);
   CopyVecteur(valeurX,varX.valeur);
   CopyVecteur(valeurY,varY.valeur);
   j := 0;
   for i := 0 to pred(nmes) do begin
       if not isNan(valeurX[i]) and
          not isNan(valeurY[i]) then begin
             vi[j] := i;
             valeurX[j] := valeurX[i];
             valeurY[j] := valeurY[i];
             inc(j);
       end
       else grandeurs[index].valeur[i] := Nan;
       incertVar[index][i] := Nan;
   end;
   DeriveeGauss(valeurX,valeurY,j,valeurDer,NbrePointDer);
   for i := 0 to pred(j) do
       grandeurs[index].valeur[vi[i]] := valeurDer[i];
   vi := nil;valeurX := nil;valeurY := nil;valeurDer := nil;
   RecalculIncert(index);
end end; // calculDerivee

Procedure calculDeriveeSeconde; // d2(vary)/d(varx)2
var vi : vecteurInt;
    valeurX,valeurY,valeurDer : vecteur;
    i,j : integer;
    NbrePointsDer : integer;
begin with grandeurs[index].fonct.calcul^ do begin
   if operandDebut<>nil
      then begin
         NbrePointsDer := round(calcule(operandDebut));
         if not odd(NbrePointsDer) then inc(NbrePointsDer);
         if (NbrePointsDer>MaxPointsDerivee) or
            (NbrepointsDer<MinPointsDerivee) then
             NbrePointsDer := NbrePointDerivee;
      end
      else NbrePointsDer := NbrePointDerivee;
   setLength(vi,NmesMax+2);
   setLength(valeurDer,NmesMax+2);
   CopyVecteur(valeurX,varX.valeur);
   CopyVecteur(valeurY,varY.valeur);
   j := 0;
   for i := 0 to pred(nmes) do begin
       if not isNan(valeurX[i]) and
          not isNan(valeurY[i]) then begin
             vi[j] := i;
             valeurX[j] := valeurX[i];
             valeurY[j] := valeurY[i];
             inc(j);
       end
       else grandeurs[index].valeur[i] := Nan;
       incertVar[index][i] := Nan;
   end;
   DeriveeSecondeGauss(valeurX,valeurY,j,valeurDer,nbrePointsDer);
   for i := 0 to pred(j) do
       grandeurs[index].valeur[vi[i]] := valeurDer[i];
   vi := nil;valeurX := nil;valeurY := nil;valeurDer := nil;
   RecalculIncert(index);
end end;// calculDeriveeSeconde

Procedure calculLissage;
var ordre : integer;
begin with grandeurs[index] do begin
   if fonct.calcul^.operandDebut=nil
      then ordre := ordreFiltrage
      else ordre := round(calcule(fonct.calcul^.operandDebut));
// FiltreButterWorth(fonct.calcul^.varX.valeur,valeur,tau,nmes)
   MoyGlissante(fonct.calcul^.varX.valeur,valeur,ordre,nmes)
end end;// calculLissage 

Procedure calculFreqInst;
var i,j,iDebut : integer;
    freq : double;
    Di,Diprec,periode : double;
    voieF : Tgrandeur;
    seuil,ymax,ymin,valeurC : double;
    premier : boolean;
    seuilTrouve : boolean;
begin with grandeurs[index] do begin
     voieF := fonct.calcul^.varx;
     if (fonct.calcul.operandFin<>nil)
        then seuil := calcule(fonct.calcul.OperandFin)
        else begin
            ymin := voieF.valeur[0];
            ymax := voieF.valeur[0];
            for i := 1 to pred(nmes) do begin
                valeurC := voieF.valeur[i];
                if valeurC>ymax
                   then ymax := valeurC
                   else if valeurC<ymin then ymin := valeurC;
            end;
            seuil := (ymax+ymin)/2;
        end;
     i := 1;
     Di := voieF.valeur[0];
     repeat
        inc(i);
        DiPrec := Di;
        Di := voieF.valeur[i];
        seuilTrouve := (Di>seuil) and (DiPrec<seuil);
     until seuilTrouve or (i>=(Nmes-1));
     // traversée du seuil à i
     freq := 0;
     premier := true;
     while i<(Nmes-1) do begin
         iDebut := i; // dernière traversée du seuil
         inc(i,4); // "hystérésis" temporel
         seuilTrouve := false;
         while  (i<=(Nmes-1)) and (voieF.valeur[i]>seuil) do begin
            inc(i)
         end;
// on est repassé en dessous
         inc(i,4);
         while (i<(Nmes-2)) and not seuilTrouve do begin
            inc(i);
            DiPrec := Di;
            Di := voieF.valeur[i];
            seuilTrouve := (Di>seuil) and (DiPrec<seuil);
         end;
         if seuilTrouve then begin
             periode := grandeurs[0].valeur[i]-grandeurs[0].valeur[idebut];
             try
             freq := 1/periode;
             for j := iDebut to pred(i) do
                valeur[j] := freq;
             if premier then begin
                for j := 0 to pred(iDebut) do valeur[j] := freq;
                premier := false;
             end;
             except
             end;
          end
          else for j := iDebut to pred(i) do
               valeur[j] := freq;
    end; // while i
end end;// calculFreqInst 

Procedure CalculIntegrale;
// intégrale operandGlb / varx
var  i : integer;
     yprec,y,xprec,x : double;
     vecteurX : vecteur;
begin with grandeurs[index] do begin
        copyVecteur(vecteurX,fonct.calcul^.varX.valeur);
        affecteVariableE(0);
        try
       	yprec := calculeLoc(fonct.calcul^.operandGlb);
        except
           yprec := 0;
        end;
      	valeur[0] := 0;
       	xprec := vecteurX[0];
      	for i := 1 to pred(nmes) do begin
      	   affecteVariableE(i);
           try
	         y := calculeLoc(fonct.calcul^.operandGlb);
      	   x := vecteurX[i];
           valeur[i] := (x-xprec)*(y+yprec)/2+valeur[pred(i)];
       	   yprec := y;
           xprec := x;
           except
              on E:exception do begin
                 derniereErreur := E.message;
                 valeur[i] := Nan;
              end;
           end;
     	end;{for i}
   	  affecteVariableE(0);
      vecteurX := nil;
end end;// CalculIntegrale

Procedure CalculFonction;
const NbreErreurMax = 3;
var i : integer;
begin with grandeurs[index] do begin
     for i := 0 to pred(nmes) do begin
         affecteVariableE(i);
         try
            valeur[i] :=  calcule(fonct.calcul);
            CalculIncertFonction(index,i);
         except
            on E:exception do begin
               derniereErreur := E.message;
               valeur[i] := Nan;
               valIncert[i] := Nan;
            end;
         end;
     end;{i}
end end;// calculFonction

procedure CalculPhaseContinue;
var deuxPi : double;
    i : integer;
begin with grandeurs[index] do begin
     if angleEnDegre then deuxPi := 360 else DeuxPi := 2*pi;
     CopyVecteur(valeur,fonct.calcul^.varX.valeur);
     for i := 1 to pred(nmes) do
         valeur[i] := valeur[i]-
               round((valeur[i]-valeur[pred(i)])/DeuxPi)*DeuxPi
end end;

// Tpage.CalcColonneP
begin with grandeurs[index] do begin
   if (nmes=0) and (genreG<>constanteGlb) then exit;
   libereFourierP(index);
   indexX := GrandeurToIndex(fonct.calcul^.varX);
   if lisse then begin
      GenereLisseP(index);
      if valeurLisse[index]=valeurVar[index] then exit;
   end;
   affecteVariableP(lisse);
   try
   case genreG of
       constante : begin
           grandeurs[cIndice].valCourante := 0;
           try
           valCourante :=  calcule(fonct.calcul);
           except on E:exception do begin
              derniereErreur := E.message;
              valCourante := Nan;
           end end;
           valeurConst[index] := valCourante;
           CalculIncertConst(index);
       end;
       constanteGlb : begin
           grandeurs[cIndice].valCourante := 0;
           try
           valCourante :=  calcule(fonct.calcul);
           except
               on E:exception do begin
                  derniereErreur := E.message;
                  valCourante := Nan;
               end;
           end;
           CalculIncertConstGlb(index);
       end;
       variable : case Fonct.genreC of
             g_correlation : calculCorrelation;
             g_filtrage : calculFiltrage;
             g_definitionFiltre : calculDefinitionFiltre;
             g_harmonique : calculHarmonique;
             g_enveloppe : calculEnveloppe;
             g_retardCorr : calculRetard;
             g_diff1,g_diff2,g_euler : ; // fait au niveau global : système différentiel
             g_integrale : calculIntegrale;
             g_derivee : if not Fonct.isSysteme then calculDerivee;
             g_deriveeSeconde : if not Fonct.isSysteme then calculDeriveeSeconde;
             g_lissage : calculLissage;
             g_FreqInst : calculFreqInst;
             g_phaseContinue : calculPhaseContinue;
             g_forward : ; // calculé ailleurs système diff
             g_experimentale,g_texte : ;
             else if not Fonct.isSysteme then
                  calculFonction // g_fonction,g_equation 
       end;
    end;
    except
        on E:exception do derniereErreur := E.message;
    end;
end end; // calcColonneP

Procedure Tpage.RemplitVarLisse;
// Avec résultat de la modélisation 

Procedure completer(i : codeIntervalle);
var j,jdebut : integer;
    k : codeIntervalle;
begin with fonctionTheorique[i] do begin
    GenereLisseP(indexY);
    jdebut := debut[i];
    if not isNan(X_inter[i]) then
       while (jdebut>1) and (jdebut>fin[pred(i)]) and
             (grandeurs[indexX].valeur[jdebut]>X_inter[i])
            do dec(jdebut);
       for k := 1 to pred(i) do if jdebut<fin[k] then jdebut := fin[k];
       for j := jdebut to pred(nmes) do
           valeurLisse[indexY,j] := valeurTheorique[i,j];
end end;

var i : codeIntervalle;
    v,index,j : integer;
    complete : boolean;
    dependLisse,dependModele : TsetGrandeur;
begin // RemplitVarLisse 
  affecteConstParam;
  dependLisse := [] ;
  for i := 1 to NbreModele do with fonctionTheorique[i] do begin
      include(dependLisse,indexY);
      LibereLisseP(indexX);
  end;
  for i := 1 to NbreModele do begin
      complete := false;
      for j := 1 to pred(i) do
          if fonctionTheorique[j].indexY=fonctionTheorique[i].indexY
             then begin
                completer(i);
                complete := true;
                break;
             end;
      if not complete then with fonctionTheorique[i] do begin
         GenereLisseP(indexY);
         if valeurVar[indexY]<>valeurLisse[indexY] then
            copyVecteur(valeurLisse[indexY],valeurTheorique[i]);
      end;
  end;
  if fonctionTheorique[1].genreC=g_diff2 then
     for i := 1 to NbreModele do
	 include(dependLisse,FonctionTheorique[i].indexYp);
  dependModele := dependLisse;
  for v := 0 to pred(NbreVariab) do begin
      index := indexVariab[v];
      if not (index in dependModele) then with grandeurs[index] do
	   if (genreG=Variable) and
              (not(fonct.genreC in [g_experimentale,g_texte])) and
              (fonct.depend*dependLisse <> [])
           	  then begin
		      calcColonneP(index,true);
		      include(dependLisse,index);
		  end
		  else LibereLisseP(index);
   end;
end; // RemplitVarLisse 

Procedure Tpage.CalculGlb;
// Fonction "globales" : dérivée maxi ...
var v : integer;
    dependGlb : TsetGrandeur;
begin
  affecteConstParam;
  dependGlb := [] ;
  for v := 0 to pred(NbreGrandeurs) do with grandeurs[v] do
      if not(fonct.genreC in [g_experimentale,g_texte]) and
              ((fonct.calcul^.TypeElement=fonctionGlb) or
               (fonct.depend*dependGlb <> [])) or
               fonct.contientCalculGlb
         then begin
           calcColonneP(v,false);
           include(dependGlb,v);
         end
end;// CalculGlb

Function IndexDerivee(y,x : tgrandeur;Acalculer : boolean;Acreer : boolean) : codeGrandeur;

Procedure DefinitDerivee(index : integer);
begin with grandeurs[index] do begin
       AdUnite('-',y,x);
       fonct.expression := 'd('+y.nom+')/d('+x.nom+')';
       fonct.calcul := genFonctionGlb(derivee,nil,nil,nil,x,y);
end end;

var UU : tgrandeur;
    nomDerivee : string;
    i,page : integer;
begin
    for i := 0 to pred(NbreGrandeurs) do with grandeurs[i].fonct do
        if (genreC=g_derivee) and (calcul<>nil) and
           (calcul^.varY=y) and (calcul^.varX=x)
            then begin result := i;exit end;
    nomDerivee := y.nom+'''';
    result := indexNomVariab(nomDerivee);
    if result=GrandeurInconnue
       then if Acreer
         then begin // Création de y'
           UU := tgrandeur.Create;
           UU.init(nomDerivee,'','',variable);
           UU.fonct.genreC := g_derivee;
           result := ajouteGrandeurE(UU);
           if result=GrandeurInconnue then exit;
           DefinitDerivee(result);
           for page := 1 to NbrePages do
              if Acalculer
                 then pages[page].CalcColonneP(result,false)
                 else pages[page].modifiedP := true;
          pages[pageCourante].affecteVariableP(false);
         end
         else
        else with grandeurs[result] do
           if (genreG=variable) and (fonct.genreC=g_forward) then begin
               fonct.genreC := g_derivee;
               DefinitDerivee(result);
           end;
end;

Function IndexVitesse(position : string) : codeGrandeur;
var i : integer;
begin
    for i := 1 to pred(NbreGrandeurs) do with grandeurs[i] do
        if (genreMecanique=gm_vitesse) and
           (nomVarPosition=position)
            then begin result := i;exit end;
    result := IndexDerivee(grandeurs[indexNom(position)],grandeurs[0],false,false);
    if result<>GrandeurInconnue then begin
       grandeurs[result].genreMecanique := gm_vitesse;
       grandeurs[result].nomVarPosition := position;
    end;
end;

Function IndexAcceleration(position : string) : codeGrandeur;
var i : integer;
begin
    for i := 1 to pred(NbreGrandeurs) do with grandeurs[i] do
        if (genreMecanique=gm_acceleration) and
           (nomvarPosition=position)
            then begin result := i;exit end;
    result := IndexDerivee(grandeurs[indexNom(position)],grandeurs[0],false,false);
    if result<>GrandeurInconnue then begin
       result := IndexDerivee(grandeurs[result],grandeurs[0],false,false);
       if result<>GrandeurInconnue then begin
          grandeurs[result].genreMecanique := gm_acceleration;
          grandeurs[result].nomVarPosition := position;
       end;
    end;
end;

Function IndexGrandeurInitiale(f : Tgrandeur;
         var GI : Tgrandeur;ParamModele,isEuler : boolean) : codeGrandeur;
var nomInitiale : string;
    i : integer;
begin
    result := GrandeurInconnue;
    for i := 1 to pred(NbreGrandeurs) do with grandeurs[i] do
        if (genreMecanique=gm_initial) and
           (nomVarPosition=f.nom)
            then begin result := i;break end;
    nomInitiale := f.nom+'[0]';
    if result=GrandeurInconnue then
       result := indexNom(nomInitiale);
    if result=GrandeurInconnue then begin
       nomInitiale := f.nom+'0';
       result := indexNom(nomInitiale);
    end;
    if isEuler and (result=GrandeurInconnue) then begin
       nomInitiale := f.nom+'[0]';
       result := indexNom(nomInitiale);
    end;
    if result=GrandeurInconnue
       then begin
          if ParamModele
             then begin // Création de y0 comme paramètre de modélisation
                inc(NbreParam);
                result := ParamToIndex(NbreParam);
                grandeurs[result].nom := nomInitiale;
             end
             else result := AjouteExperimentale(nomInitiale,constante);
             // Création de y0 comme parametre experimental
          grandeurs[result].recopieUnite(f);
          grandeurs[result].uniteDonnee := false;
      end;
    GI := grandeurs[result];
end; //  IndexGrandeurInitiale

Procedure supprimeGrandeurE(index : codeGrandeur);
var i : integer;
    S : Tsauvegarde;
    p : codePage;
begin
    if index>maxGrandeurs then exit;
    S := nil;
    if (grandeurs[index].fonct.genreC=g_experimentale) and
       (grandeurs[index].genreG in [variable,constante]) then begin
       S := tsauvegarde.create;
       if grandeurs[index].genreG=variable then
          S.undo := UsupprVariab;
       if grandeurs[index].genreG=constante then
          S.undo := UsupprConst;
       S.GrandeurSauvee := grandeurs[index];
       PileSauvegarde.push(S);
    end;
    if (grandeurs[index].fonct.genreC=g_texte) and
       (grandeurs[index].genreG in [variable,constante]) then begin
       S := tsauvegarde.create;
       if grandeurs[index].genreG=variable then begin
          S.undo := UsupprVariabTexte;
          for p := 1 to NbrePages do S.sauveTexte[p] := TstringList.create;
       end;
       if grandeurs[index].genreG=constante then begin
          S.undo := UsupprConstTexte;
          S.sauveTexteUnique := TstringList.create;
       end;
       S.GrandeurSauvee := grandeurs[index];
       PileSauvegarde.push(S);
    end;
    for i := 1 to NbrePages do
        pages[i].supprimeGrandeurP(index,S);
    if not(grandeurs[index].fonct.genreC in [g_experimentale,g_texte]) or
       not (grandeurs[index].genreG in [variable,constante])
          then Grandeurs[index].free;
    dec(NbreGrandeurs);
    for i := index to pred(NbreGrandeurs) do
        grandeurs[i] := grandeurs[succ(i)];
    ConstruireIndex;
end; // SupprimeGrandeurE

function Tgrandeur.axe(avecResidu,endB : boolean;exposant : double) : string;
begin
  if affSignif and (fonct.genreC=g_experimentale)
           then begin
              result := fonct.expression;
              if result='' then result := nom;
           end
           else result := nom;
        if avecResidu then result := DeltaMaj+result;
        if endB
           then result := result+'/dB'
           else result := result+UniteAxe(exposant);
end;

Procedure Tpage.setDeltaSimulation;
begin
      if ModeAcquisition<>acqSimulation then begin
         deltaSimulation := 1;
         exit;
      end;
      if Nmes<8 then Nmes := 8;
      if Nmes>MaxMaxVecteur then Nmes := 4096;
      if logSimulation
         then begin
             try
             MiniSimulation := abs(MiniSimulation);
             MaxiSimulation := abs(MaxiSimulation);
             VerifMinMaxReal(MiniSimulation,MaxiSimulation);
             deltaSimulation := Power(10,log10(MaxiSimulation/MiniSimulation)/Nmes);
             if deltaSimulation=1 then begin
                 deltaSimulation := 1.01;
                 MaxiSimulation := MiniSimulation*power(deltaSimulation,Nmes);
             end;
             except
                 deltaSimulation := 1000/Nmes;
                 MiniSimulation := maxiSimulation/1000;
                 AfficheErreur(erRemplitLog,0);
             end;
         end
         else begin
            VerifMinMaxReal(MiniSimulation,MaxiSimulation);
            deltaSimulation := (MaxiSimulation-MiniSimulation)/Nmes;
            if deltaSimulation<1E-12 then begin
               deltaSimulation := 1;
               MaxiSimulation := MiniSimulation+Nmes*deltaSimulation;
            end;
         end;
end;


// GestVar.pas inclus dans compile.pas


