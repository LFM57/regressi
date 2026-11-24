unit regfile;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.UIConsts,
  System.Actions,
  System.Math,
  System.Character,
//  System.Generics.Collections,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Menus,
  FMX.StdCtrls,
  FMX.ExtCtrls,
  FMX.ListBox,
  FMX.Memo,
  FMX.TabControl,
  FMX.Layouts,
  FMX.Edit,
  FMX.Printer,
  FMX.ActnList,
  FMX.Platform,
  FMX.Graphics,
  FMX.DialogService,

  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,

  aidekey,
  compile,
  constreg,
  graphKer,
  maths,
  fft,

  regutil,
  statCalc,
  valeurs,
  grapheVariabU,
  grapheParamU,
  graphFFT,
  optStat,
  uniteKer;

type
    TformatSepare = (sTab,sBlanc,sVirgule,sPointVirgule);

    TFichierRegressi = class
    DecodeVariab,DecodeConst : array[codeGrandeur] of integer;
    isPrecVariab,isPrecConst : array[codeGrandeur] of boolean;
    NbrePrecVariab,NbrePrecConst : integer;
    NbreVariabAlire : integer;
    separateurCsv : char;
    avecTab : TformatSepare;
    indexDate,indexDateTime,indexTime,indexTexte : integer;
    donnees : TMemo;
    ligneList : TStringList;
    listeNom,listeUnite : TstringList;
    private
    function GetDataReg : boolean;
    procedure ChercheTab;
    Function AjouteData : integer;
    Function ExtraitIncert(var ligne : integer) : boolean;
    Function ExtraitVariableTexte(var ligne : integer) : boolean;
    Function ExtraitValeur(Agenre : TgenreGrandeur;ligne : integer;imax : integer) : boolean;
    Procedure extraitNom(const s : string;var ListeN,ListeU : TstringList;creation : boolean);
    public
    procedure EcritWin(NomFichier : string);
    function LitWin : boolean;
    Procedure AjouteWin(NomFichier : string);

    Function LitCSV(const NomFichier : String;NouveauFichier : boolean) : boolean;
    Function LitCSVHorizontal(const NomFichier : String;NouveauFichier : boolean) : boolean;
    Function LitLogger(const NomFichier : String) : boolean;

    Function LitXML(const NomFichier : String;NouveauFichier : boolean) : boolean;
 //   Function LitInfo(const NomFichier : String) : string;
    Procedure EcritXML(const NomFichier : string);
    Procedure AjouteXML(const NomFichier : string);

    Function LitTableur(const NomFichier : string) : boolean;
    Procedure EcritTableur(const NomFichier : string);
    Function AjouteTableur(const NomFichier : string) : boolean;

    function LitWav(Nom : String) : boolean;

    Function LitPressePapier : boolean;
    Function AjoutePressePapier : boolean;
    constructor Create;
    destructor Destroy; override;
    end;

var
    FichierRegressi : TFichierRegressi;

implementation

procedure LoadLinesSmart(List : TStrings; const NomFichier : string);
begin
   try
      List.LoadFromFile(NomFichier);
      if Pos(#$FFFD, List.Text) > 0 then
         List.LoadFromFile(NomFichier, TEncoding.ANSI);
   except
      List.LoadFromFile(NomFichier, TEncoding.ANSI);
   end;
end;

function NettoieIMCCE(chaine : string) : string;
const
    minuteIMCCE = 'â€²';
    secondeIMCCE = 'â€³';
var suivantUnicode, suivantA2 : boolean;
    i : integer;
    posCarac : integer;
    carac : char;
begin
    result := '';
    suivantUnicode := false;
    suivantA2 := false;
    posCarac := pos(minuteIMCCE,chaine);
    while posCarac>0 do begin
        delete(chaine,posCarac,3);
        insert('''',chaine,posCarac);
        posCarac := pos(minuteIMCCE,chaine);
    end;
    posCarac := pos(secondeIMCCE,chaine);
    while posCarac>0 do begin
        delete(chaine,posCarac,3);
        insert('"',chaine,posCarac);
        posCarac := pos(secondeIMCCE,chaine);
    end;
    for i := 1 to length(chaine) do begin
        carac := chaine[i];
        if suivantUnicode then begin
           case carac of
                '©','¨','ª','«' : result := result + 'e';
                '²' : result := result + '2';
                '´' : result := result + 'o';
                '°' : result := result + '°';
                '§' : result := result + 'c';
                '¼','»','¹' : result := result + 'u';
                ' ','¡','¢','£','¤' : result := result + 'a';
                '®','¯' : result := result + 'i';
                else result := result + 'Ã' + carac;
           end;
           suivantUnicode := false;
        end else if suivantA2 then begin
           case carac of
                '°' : result := result + '°';
                'µ' : result := result + 'µ';
                '²' : result := result + '2';
                else result := result + 'Â' + carac;
           end;
           suivantA2 := false;
        end else case carac of
           'Ã' : suivantUnicode := true;
           'Â' : suivantA2 := true;
           else result := result + carac;
        end;
    end;
    if suivantUnicode then result := result + 'Ã';
    if suivantA2 then result := result + 'Â';
end;

Function LigneDeChiffres(const s : String) : boolean;
var j : integer;
    AvecChiffres : boolean;
begin
    Result := false;
    AvecChiffres := false;
    for j := 1 to length(s) do
        if charinset(s[j],chiffreEtc) or
           (charinset(s[j],caracPrefixe) and (j>1) and
           s[j-1].isDigit)
           then avecChiffres := true
           else if not charinset(s[j],separateur) then exit;
    result := avecChiffres;
end;

function TFichierRegressi.LitCSV(const NomFichier : String;NouveauFichier : boolean) : boolean;
var
    nom,unite : array[codeGrandeur] of string;
    NbreCSV : integer;
    csvLines : TStringList;
    csvIdx : integer;
    finFichierCSV : boolean;
    uniteTrouvee : boolean;
    isLigneDeChiffres : boolean;
    nombrePages,pageDebut : integer;
    caracNomPasco : TsysCharset;
    VariabAsuppr : TstringList;
    VariabTextuelle : set of byte;
    isPasco,avecNoms : boolean;
    AFormatSettings : TFormatSettings;
    commentaire : string;
    NbreEnTete : integer;
    premiereLigne : string;

function csvEof : boolean;
begin
   result := csvIdx >= csvLines.Count;
end;

procedure csvReset;
begin
   csvIdx := 0;
   finFichierCSV := csvLines.Count = 0;
end;

procedure csvReadln(var s : string);
begin
   if csvIdx < csvLines.Count then begin
      s := csvLines[csvIdx];
      inc(csvIdx);
   end else begin
      s := '';
      finFichierCSV := true;
   end;
end;

procedure litLigneCSV;
var i,j,NbrePb : integer;
    aligne,aElement : string;
    isNombre,avecBlanc : boolean;
begin
   try
   NbreCSV := 0;
   NbrePb := 0;
   isLigneDeChiffres := false;
   FinFichierCSV := FinFichierCSV or csvEof;
   if finFichierCSV then exit;
   csvReadln(aLigne);
   aLigne := NettoieIMCCE(aLigne);
   ligneList.DelimitedText := aLigne;
   NbreCSV := ligneList.count;
   if NbreCSV>maxGrandeurs then nbreCSV := maxGrandeurs;
   if NbreCSV=0 then begin
      FinFichierCSV := true;
      exit;
   end;
   if (NbreCSV>0) and (LigneList[pred(NbreCSV)]='') then dec(NbreCSV);
   isLigneDeChiffres := NbreCSV>0;
   for i := 0 to pred(NbreCSV) do begin
       aElement := NettoieIMCCE(ligneList[i]);
       ligneList[i] := aElement;
       if isLigneDeChiffres then begin
           isNombre := true;
           avecBlanc := false;
           for j := 1 to length(aElement) do begin
               isNombre := isNombre and
                   charInSet(aElement[j],['0'..'9','+','-','E','.',',','e','/',':','T','°','''','"',' ']);
               avecBlanc := avecBlanc or (aElement[j]=' ');
           end;
           if avecBlanc and isNombre then ligneList[i] := trim(aElement);
           isNombre := isNombre or (UpperCase(trim(aElement))='NAN') or
                       (UpperCase(trim(aElement))='INF') or (UpperCase(trim(aElement))='#N/A');
           if not isNombre then begin
               include(VariabTextuelle,i);
               if (nom[i]<>'') then VariabAsuppr.Add(nom[i]);
               inc(NbrePb);
           end;
           isLigneDeChiffres := isNombre;
       end;
   end;
   if not isLigneDeChiffres then isLigneDeChiffres := (NbreCsv>3) and (NbrePb<(NbreCSV-3));
   isLigneDeChiffres := isLigneDeChiffres and (NbreCsv>0);
   except
        FinFichierCSV := true;
        NbreCSV := 0;
   end;
end;

procedure LitValeurVecteurCSV;
var i,j,k,NbrePoints,compteurNan : integer;
    posDate,posTime,posDegre : integer;
    index : integer;
    strValeur : string;
    Lvaleur : double;
    Asuppr : boolean;

Procedure RecupereDateHeure;
var posT : integer;
begin
    posT := pos('T',strValeur);
    if posT>0 then strValeur[posT] := ' ';
    posT := pos('.',strValeur);
    if posT>0 then delete(strValeur,posT,length(strValeur)-posT+1);
    posT := pos('-',strValeur);
    if posT>0 then strValeur[posT] := '/';
    posT := pos('-',strValeur);
    if posT>0 then strValeur[posT] := '/';
    AFormatSettings.DateSeparator := '/';
    AFormatSettings.TimeSeparator := ':';
    AFormatSettings.ShortDateFormat := 'yyyy/mm/dd';
    AFormatSettings.ShortTimeFormat := 'hh:nn:ss';
end;

begin
   indexDate := grandeurInconnue;
   indexTime := grandeurInconnue;
   indexDateTime := grandeurInconnue;
   while not(finFichierCSV) and isLigneDeChiffres do with pages[pageCourante] do begin
      if nmes>=MaxMaxVecteur then break;
      NbrePoints := nmes;
      compteurNan := 0;
      if (NbreCsv>NbreVariab) and (NbreCsv<=maxGrandeurs) then
         for j := NbreVariab+1 to NbreCSV do
             decodeVariab[j-1] := AjouteExperimentale('x'+intToStr(j),variable);
      for i := 0 to pred(NbreCSV) do begin
          if i in VariabTextuelle then continue;
          index := decodeVariab[i];
          if (index=grandeurInconnue) or (index>=maxGrandeurs) then continue;
          strValeur := trim(ligneList[i]);
          if pos('T',strValeur)>0 then recupereDateHeure;
          posTime := pos(':',strValeur);
          posDate := pos('/',strValeur);
          posDegre := pos('°',strValeur);
          if posDegre=0 then posDegre := pos('''',strValeur);
          if posDegre=0 then posDegre := pos('"',strValeur);
          if (strValeur='') or (UpperCase(strValeur)='NAN') or
             (UpperCase(strValeur)='INF') or (UpperCase(strValeur)='#N/A') then begin
              Lvaleur := NAN;
              inc(compteurNan);
          end
          else if (posTime>0) or (posDate>0)
            then begin
                try
                if posTime>0
                   then if posDate>0
                        then begin
                            Lvaleur := StrToDateTime(strValeur,AFormatSettings);
                            indexDateTime := index;
                            Grandeurs[index].formatU := fDateTime;
                        end
                        else begin
                           Lvaleur := StrToTime(strValeur);
                           indexTime := index;
                           Grandeurs[index].formatU := fTime;
                        end
                   else begin
                        Lvaleur := StrToDate(strValeur);
                        indexDate := index;
                        Grandeurs[index].formatU := fDate;
                   end;
                 except
                   Lvaleur := Nan;
                   inc(compteurNan);
                 end;
             end
             else if posDegre>0 then begin
                try
                   Lvaleur := StrSexaToDeci(strValeur);
                except
                   Lvaleur := Nan;
                   inc(compteurNan);
                end;
             end
             else begin
                Lvaleur := strToFloatWin(strValeur);
                if isNan(Lvaleur) then inc(compteurNan);
             end;
          valeurVar[index,NbrePoints] := Lvaleur;
      end;
      if compteurNan<2 then nmes := nmes+1;
      litLigneCSV;
   end;
   if (indexTime<>grandeurInconnue) and
      (indexDate<>grandeurInconnue) and
      (indexDateTime=grandeurInconnue) then begin
           Fvaleurs.Memo.lines.add('t='+grandeurs[indexDate].nom+'+'+grandeurs[indexTime].nom);
           Fvaleurs.Memo.lines.add('''t=date et heure');
   end;
   for I := 0 to VariabAsuppr.Count-1 do begin
       index := indexNom(VariabAsuppr[i]);
       if index<>grandeurInconnue then SupprimeGrandeurE(index);
   end;
   if pages[pageCourante].nmes>0 then begin
      k := NbreVariab-1;
      while k>=0 do begin
          index := indexVariab[k];
          Asuppr := true;
          for j := 0 to min(3,pred(pages[pageCourante].nmes)) do
             Asuppr := Asuppr and isNan(pages[pageCourante].valeurVar[index,j]);
          if Asuppr then SupprimeGrandeurE(index);
          dec(k);
      end;
   end;
end; // litValeurVecteurCSV

Function VerifUnite(num : integer) : string;
var posO,posF,posA,i,posSerie : integer;
    reponse : string;
begin
   result := '';
   posSerie := pos('Serie #',ligneList[num]);
   if posSerie=1 then begin
      ligneList[num] := '';
      exit;
   end;
   if posSerie>1 then
      ligneList[num] := copy(ligneList[num],1,posSerie-1);
   posO := pos('en ',ligneList[num]);
   if (posO>1) then begin
      reponse := copy(ligneList[num],posO+3,4);
      ligneList[num] := copy(ligneList[num],1,posO-1);
      i:=1;
      while i<=length(reponse) do
          if charInSet(reponse[i],caracUnite)
             then inc(i)
             else delete(reponse,i,1);
      reponse := copy(reponse,1,posO-2); // on enlève blanc ou ( avant en
      UniteTrouvee := true;
      if reponse='Second' then reponse := 's';
      if reponse='Volt' then reponse := 'V';
      result := reponse;
      exit;
   end;
   posO := pos('(',ligneList[num]);
   posF := pos(')',ligneList[num]);
   if (posO>1) and (posF>posO) then begin
      reponse := copy(ligneList[num],posO+1,posF-posO-1);
      ligneList[num] := copy(ligneList[num],1,posO-1);
      UniteTrouvee := true;
      if reponse='Second' then reponse := 's';
      if (reponse='degrees') or (reponse='deg') then reponse := '°';
      if reponse='Volt' then reponse := 'V';
      if reponse='undefined' then reponse := '';
      if reponse='au' then reponse := 'ua';
      if reponse='au/d' then reponse := 'ua/j';
      if reponse='n' then reponse := 'N';
      posA := pos('Â',reponse);
      if posA>0 then delete(reponse,posA,1);
      if (reponse='max') or (reponse='min') then begin
         UniteTrouvee := false;
         ligneList[num] := ligneList[num]+reponse;
         reponse := '';
      end;
      result := reponse;
   end;
end;

procedure LitValeurVecteurDoubleVirgule;
var i,NbrePoints : integer;
    index : integer;
    strValeur : string;
begin
   while not(finFichierCSV) and isLigneDeChiffres do with pages[pageCourante] do begin
      NbrePoints := nmes;
      nmes := nmes+1;
      for i := 0 to pred(NbreVariabExp) do begin
          index := decodeVariab[i];
          if (index<>grandeurInconnue) and (2*i+1<ligneList.count) then begin
             strValeur := ligneList[2*i]+','+ligneList[2*i+1];
             valeurVar[index,NbrePoints] := strToFloatWin(strValeur);
          end;
      end;
      litLigneCSV;
   end;
end; // litValeurVecteurDoubleVirgule

Procedure extraitNomCSV;
var i : integer;
    NbreNom : integer;
begin
  NbreNom := 0;
  for i := 0 to pred(NbreCSV) do
      if ligneList[i]<>'' then inc(NbreNom);
  if (NbreNom<NbreCsv) then
  for i := 0 to pred(NbreCSV) do
      if ligneList[i]='' then
      case i of
           0 : ligneList[0] := 't';
           1 : ligneList[1] := 'V1';
           2 : ligneList[2] := 'V2';
           else ligneList[i] := 'Var'+IntToStr(i);
      end;
end;

procedure LitValeurVecteurFizziq;
var i,NbrePoints : integer;
    index : integer;
    strValeur : string;
    compteurNan : integer;
begin
   while not(finFichierCSV) and isLigneDeChiffres do with pages[pageCourante] do begin
      NbrePoints := nmes;
      compteurNan := 0;
      for i := 1 to pred(NbreCSV) do begin
          index := decodeVariab[i];
          if index=grandeurInconnue then continue;
          strValeur := trim(ligneList[i]);
          try
          valeurVar[index,NbrePoints] := strToFloatWin(strValeur);
          if isNan(valeurVar[index,NbrePoints]) then inc(compteurNan);
          except
              inc(compteurNan);
              valeurVar[index,NbrePoints] := Nan;
          end;
      end;
      if compteurNan<2 then nmes := nmes+1;
      litLigneCSV;
   end;
end; // litValeurVecteurFizziq

function litNomUniteFizziq : boolean;

Function LigneDeNomFizziq : boolean;
var i : integer;
    NbreNoms : integer;
begin
  NbreNoms := 0;
  for i := 1 to pred(NbreCSV) do
      if ligneList[i]<>'' then inc(NbreNoms);
  result := NbreNoms>0;
end;

var i,index : integer;
begin
     for i := 0 to maxGrandeurs do begin
         DecodeVariab[i] := grandeurInconnue;
         nom[i] := '';
         unite[i] := '';
     end;
     VariabAsuppr.clear;
     litLigneCSV;
     result := LigneDeNomFizziq;
     if not result then exit;
     UniteTrouvee := false;
     for i := 1 to pred(NbreCSV) do begin // 0 = # = index
         unite[i] := VerifUnite(i);
         nom[i] := Copy(trimNomGrandeur(LigneList[i]),1,16);
         if nom[i]<>'' then begin
            if indexNom(nom[i])<>grandeurInconnue then nom[i] := nom[i]+intToStr(i);
            if indexNom(nom[i])=grandeurInconnue then begin
               if charInSet(nom[i][1],['0'..'9']) then nom[i] := 'V'+nom[i];
               index := AjouteExperimentale(nom[i],variable);
               grandeurs[index].NomUnite := unite[i];
               DecodeVariab[i] := index;
            end;
         end;
     end;
     VariabTextuelle := [];
     litLigneCSV;
     if not ajoutePage then exit;
     litValeurVecteurFizziq;
     if (NbreGrandeurs>0) and
        (pages[pageCourante].nmes>0)then begin
            LitCSV := true;
            construireIndex;
     end;
end; // litNomUniteFizziq

procedure litNomUnite;
const maxU = 7;
      nomCSV : array[0..MaxU,boolean] of string =
          (('second','s'),
           ('Ampere','A'),
           ('Watt','W'),
           ('Volt','V'),
           ('Volt²','V2'),
           ('Ampere²','A2'),
           ('Hertz','Hz'),
           ('Â°','°'));
var i,j,index : integer;
    Lsignif : string;
    listeNomPages : array[1..8] of TstringList;
begin
     for i := 0 to maxMaxGrandeurs do begin
         DecodeVariab[i] := i;
         nom[i] := '';
         unite[i] := '';
     end;
     VariabAsuppr.clear;
     for i := 1 to 8 do listeNomPages[i] := TstringList.Create;
     try
     if avecNoms then begin
        repeat
           litLigneCSV;
        until FinFichierCSV or (NbreCsv>1) or isLigneDeChiffres;
        UniteTrouvee := false;
        if isLigneDeChiffres then begin
           for i := 1 to nbreCSV do begin
               index := AjouteExperimentale('x'+intToStr(i),variable);
               decodeVariab[i-1] := index;
               nom[i-1] := grandeurs[index].nom;
               listeNomPages[1].Add(grandeurs[index].nom);
           end;
        end
        else begin
           extraitNomCSV;
           for i := 0 to pred(NbreCSV) do begin
               Lsignif := LigneList[i];
               Unite[i] := VerifUnite(i);
               Nom[i] := Copy(trimNomGrandeur(LigneList[i]),1,16);
               if nom[i]<>'' then begin
                  if nom[i]='xaxis' then nom[i] := 't';
                  if charInSet(nom[i][1],['0'..'9']) then nom[i] := 'V'+nom[i];
                  if indexNom(nom[i])=grandeurInconnue then begin
                     index := AjouteExperimentale(nom[i],variable);
                     grandeurs[index].NomUnite := unite[i];
                     grandeurs[index].fonct.expression := Lsignif;
                     decodeVariab[i] := index;
                     listeNomPages[1].Add(nom[i]);
                  end
                  else begin
                      if listeNomPages[nombrePages].indexOf(nom[i])<0 then
                         inc(nombrePages);
                      listeNomPages[nombrePages].Add(nom[i]);
                  end;
               end;
           end;
           VariabTextuelle := [];
           VariabAsuppr.clear;
           litLigneCSV;
        end;
        if not uniteTrouvee and not isLigneDeChiffres then begin
           for i := 0 to pred(NbreCSV) do begin
               Unite[i] := LigneList[i];
               for j := 0 to maxU do
                   if Unite[i]=nomCSV[j,false] then begin
                      Unite[i] := nomCSV[j,true];
                      break;
                   end;
               if pos('_Time',unite[i])>0 then if pos('1',unite[i])>0 then begin
                    unite[i] := 's';
                    index := indexNom(nom[i]);
                    if index<>grandeurInconnue then begin
                       grandeurs[index].nom := 't';
                       nom[i] := 't';
                    end;
               end else if nom[i]<>'' then VariabAsuppr.Add(nom[i]);
               if i<NbreGrandeurs then grandeurs[i].NomUnite := unite[i];
            end;
            VariabTextuelle := [];
            VariabAsuppr.clear;
            litLigneCSV;
        end;
     end
     else begin
        litLigneCSV;
        if isLigneDeChiffres and (NbreCSV>0) then begin
           for i := 1 to NbreCSV do begin
              index := AjouteExperimentale('x'+intToStr(i),variable);
              decodeVariab[i-1] := index;
              nom[i-1] := grandeurs[index].nom;
           end;
        end;
     end;
     if not ajoutePage then exit;
     pageDebut := pageCourante;
     for i := 2 to nombrePages do ajoutePage;
     if (','=separateurCSV) and (NbreCsv>NbreVariabExp) and not isLigneDeChiffres
        then litValeurVecteurDoubleVirgule
        else litValeurVecteurCsv;
     if (NbreGrandeurs>0) and
        (pages[pageCourante].nmes>0)then begin
            LitCSV := true;
            construireIndex;
     end;
     finally
       for i := 1 to 8 do listeNomPages[i].free;
     end;
end; // litNomUnite

procedure verifNoms;
var i : integer;
    Lnom : string;
begin
     for i := 0 to maxMaxgrandeurs do begin
         DecodeVariab[i] := i;
         nom[i] := '';
         unite[i] := '';
     end;
     litLigneCSV;
     if NbreCSV<>NbreVariabExp then exit;
     for i := 0 to pred(NbreCSV) do begin
         VerifUnite(i);
         Lnom := trimNomGrandeur(LigneList[i]);
         DecodeVariab[i] := indexNom(Lnom);
         if DecodeVariab[i]=grandeurInconnue then exit;
     end;
     VariabTextuelle := [];
     VariabAsuppr.clear;
     litLigneCSV; // unite
     if not isLigneDeChiffres then litLigneCSV;
     if not ajoutePage then exit;
     litValeurVecteurCsv;
     if pages[pageCourante].nmes>0
          then LitCSV := true
end; // verifNoms

procedure litGoodwill;
var valeurY : array of integer;
    nbre, cap : integer;
    premiereLigne : string;
    posV : integer;

function extraitNombre : double;
begin
    posV := pos(',',premiereLigne);
    premiereLigne := copy(premiereLigne, posV+1, length(premiereLigne)-posV);
    posV := pos(',',premiereLigne);
    if posV>0 then premiereLigne := copy(premiereLigne, 1, posV-1);
    result := strToFloatWin(premiereLigne);
end;

var lecture : boolean;
    penteX,penteY,yzero : double;
    i : integer;
begin
     csvReset;
     if nouveauFichier then begin
        AjouteExperimentale('t',variable);
        grandeurs[0].NomUnite := 's';
        AjouteExperimentale('V',variable);
        grandeurs[1].NomUnite := 'V';
     end;
     if not ajoutePage then exit;
     lecture := false;
     nbre := 0;
     yzero := 0;
     penteX := 1e-6;
     penteY := 0.001;
     while not csvEof and not lecture do begin
           csvReadln(premiereLigne);
           if pos('Memory Length',premiereLigne)>0 then ;
           if pos('Vertical Units',premiereLigne)>0 then ;
           if pos('Horizontal Units',premiereLigne)>0 then ;
           if pos('Vertical Scale',premiereLigne)>0 then begin
              penteY := extraitNombre/25;
           end;
           if (pos('Sample Period',premiereLigne)>0) or
              (pos('Sampling Period',premiereLigne)>0)
              then begin
              penteX := extraitNombre;
           end;
           if pos('Trigger Level',premiereLigne)>0 then ;
           if pos('Vertical Position',premiereLigne)>0 then begin
              yzero := extraitNombre;
           end;
           if pos('Horizontal Position',premiereLigne)>0 then ;
           if pos('Horizontal Scale',premiereLigne)>0 then ;
           if pos('Firmware',premiereLigne)>0 then ;
           if pos('Waveform Data',premiereLigne)>0 then begin
              lecture := true;
           end;
           if pos('Source',premiereLigne)>0 then begin // CH1
              posV := pos(',',premiereLigne);
              premiereLigne := copy(premiereLigne, posV+1, length(premiereLigne)-posV);
              posV := pos(',',premiereLigne);
              if posV>0 then premiereLigne := copy(premiereLigne, 1, posV-1);
              grandeurs[1].Nom := premiereLigne;
           end;
     end;
     cap := 8192;
     SetLength(valeurY, cap);
     while not csvEof do begin
        csvReadln(premiereLigne);
        if premiereLigne<>'' then begin
           if nbre >= MaxMaxVecteur then break;
           if nbre >= cap then begin
              cap := cap * 2;
              if cap > MaxMaxVecteur then cap := MaxMaxVecteur;
              SetLength(valeurY, cap);
           end;
           posV := pos(',',premiereLigne);
           if posV>0 then premiereLigne := copy(premiereLigne, 1, posV-1);
           valeurY[nbre] := strToInt(premiereLigne);
           inc(nbre);
        end;
     end;
     with pages[pageCourante] do begin
          nmes := nbre;
          for i := 0 to pred(Nbre) do begin
              valeurVar[0,i] := i*penteX;
              valeurVar[1,i] := valeurY[i]*penteY+yzero;
          end;
     end;
     result := pages[pageCourante].nmes>128;
end; // litGoodWill

procedure litGoodwillPC;
var valeurY : array of integer;
    nbre, cap : integer;
    premiereLigne : string;
    posV : integer;

function extraitNombre : double;
begin
    posV := pos(',',premiereLigne);
    premiereLigne := copy(premiereLigne, posV+1, length(premiereLigne)-posV);
    posV := pos(',',premiereLigne);
    if posV>0 then premiereLigne := copy(premiereLigne, 1, posV-1);
    result := strToFloatWin(premiereLigne);
end;

var lecture : boolean;
    penteX,penteY,yzero : double;
    i : integer;
begin
     csvReset;
     if nouveauFichier then begin
        AjouteExperimentale('t',variable);
        grandeurs[0].NomUnite := 's';
        AjouteExperimentale('V',variable);
        grandeurs[1].NomUnite := 'V';
     end;
     if not ajoutePage then exit;
     lecture := false;
     nbre := 0;
     yzero := 0;
     penteX := 1e-6;
     penteY := 0.001;
     while not csvEof and not lecture do begin
           csvReadln(premiereLigne);
           if pos('Memory Length',premiereLigne)>0 then ;
           if pos('Vertical Units',premiereLigne)>0 then ;
           if pos('Horizontal Units',premiereLigne)>0 then ;
           if pos('VERTICAL SCALE',premiereLigne)>0 then begin
              penteY := extraitNombre/25;
           end;
           if pos('TIME BASE SCALE',premiereLigne)>0 then begin
              penteX := extraitNombre/256;
               // par division avec 8 divisions sur 256 niveaux soit 32
           end;
           if pos('Trigger Level',premiereLigne)>0 then ;
           if pos('Vertical Position',premiereLigne)>0 then begin
              yzero := extraitNombre;
           end;
           if pos('Horizontal Position',premiereLigne)>0 then ;
           if pos('Horizontal Scale',premiereLigne)>0 then ;
           if pos('Firmware',premiereLigne)>0 then ;
           if pos('POINT,VALUE',premiereLigne)>0 then begin
              lecture := true;
           end;
           if pos('RECORD Length',premiereLigne)>0 then begin
             // NbreMax := round(extraitNombre);
           end;
           if pos('Channel',premiereLigne)>0 then begin // CH1
              posV := pos(',',premiereLigne);
              premiereLigne := copy(premiereLigne, posV+1, length(premiereLigne)-posV);
              posV := pos(',',premiereLigne);
              if posV>0 then premiereLigne := copy(premiereLigne, 1, posV-1);
              grandeurs[1].Nom := premiereLigne;
           end;
     end;
     cap := 8192;
     SetLength(valeurY, cap);
     while not csvEof do begin
        csvReadln(premiereLigne);
        if premiereLigne<>'' then begin
           if nbre >= MaxMaxVecteur then break;
           if nbre >= cap then begin
              cap := cap * 2;
              if cap > MaxMaxVecteur then cap := MaxMaxVecteur;
              SetLength(valeurY, cap);
           end;
           posV := pos(',',premiereLigne);   // index X
           if posV>0 then premiereLigne := copy(premiereLigne, posV+1, length(premiereLigne)-posV);
           posV := pos(',',premiereLigne); // indexY
           if posV>0 then premiereLigne := copy(premiereLigne, 1, posV-1);
           valeurY[nbre] := strToInt(premiereLigne);
           inc(nbre);
        end;
     end;
     with pages[pageCourante] do begin
          nmes := nbre;
          for i := 0 to pred(Nbre) do begin
              valeurVar[0,i] := i*penteX;
              valeurVar[1,i] := valeurY[i]*penteY+yzero;
          end;
     end;
     result := pages[pageCourante].nmes>128;
end; // litGoodWillPC

procedure litHanna;
var Ligne : string;
    hannaList : TStringList;
    hannaUnit : string;
    indexHeure,indexConduct : integer;

Procedure extraitPoint;
begin with pages[pageCourante] do begin
   csvReadln(Ligne);
   Ligne := NettoieIMCCE(Ligne);
   hannaList.DelimitedText := Ligne;
   if (indexHeure>=0) and (indexConduct>=0) and
      (indexHeure<hannaList.count) and (indexConduct<hannaList.count) then begin
      try
         valeurVar[0,nmes] := strToTime(hannaList[indexHeure]);
         valeurVar[1,nmes] := strToFloatWin(hannaList[indexConduct]);
         nmes := nmes+1;
      except
      end;
   end;
end end;

Procedure extraitUnit;
var posCrochetO,posCrochetF : integer;
    i : integer;
begin
   hannaUnit := '';
   indexHeure := 2;
   indexConduct := 3;
   csvReadln(Ligne);
   Ligne := NettoieIMCCE(Ligne);
   posCrochetO := pos('[', Ligne);
   posCrochetF := pos(']', Ligne);
   if (posCrochetO>0) and (posCrochetF>posCrochetO+1) then
      hannaUnit := copy(Ligne,posCrochetO+1,posCrochetF-posCrochetO-1);
   hannaList.DelimitedText := Ligne;
   for i := 0 to pred(hannaList.Count) do begin
       if hannaList[i]='Heure' then indexHeure := i;
       if pos('Conduct',hannaList[i])=1 then indexConduct := i;
   end;
end;

label finHanna;
var i : integer;
    t0 : double;
begin
     AFormatSettings.ShortTimeFormat := 'hh:nn:ss';
     hannaList := TstringList.Create;
     hannaList.strictDelimiter := true;
     hannaList.delimiter := ',';
     hannaList.QuoteChar := #0;
     try
     repeat
         csvReadln(Ligne);
     until ((pos('ENREGISTREMENT',Ligne)>0) and (pos('DONN',Ligne)>0)) or csvEof;
     if csvEof then goto finHanna;
     extraitUnit;
     if nouveauFichier then begin
        AjouteExperimentale('t',variable);
        grandeurs[0].NomUnite := 's';
        AjouteExperimentale('sigma',variable);
        grandeurs[1].NomUnite := hannaUnit;
     end;
     if not ajoutePage then goto finHanna;
     while not csvEof do extraitPoint;
     result := pages[pageCourante].nmes>2;
     if result then with pages[pageCourante] do begin
        t0 := valeurVar[0,0];
        for i := 0 to pred(nmes) do
            valeurVar[0,i] := (valeurVar[0,i]-t0)*24*3600;
     end
     else codeErreurF := erNbreData;
     finHanna:
     finally
       hannaList.Free;
     end;
end; // litHanna

procedure litChauvinArnoux;

procedure LitValeurs;
var i,NbrePoints : integer;
    posTime,posDateCA : integer;
    strValeur : string;
    index : integer;
begin
   litLigneCSV;
   while not(finFichierCSV) do with pages[pageCourante] do begin
      NbrePoints := nmes;
      for i := 0 to pred(NbreCSV) do begin
          index := decodeVariab[i];
          if index=grandeurInconnue then continue;
          strValeur := trim(ligneList[i]);
          posTime := pos(':',strValeur);
          posDateCA := pos('-',strValeur);
          if (posDateCA>0) and (posTime>0) then begin // 2012-12-25 12:56:13:000
              posDateCA := pos(' ',strValeur);
              if posDateCA>0 then strValeur := copy(strValeur,posDateCA+1,length(strValeur));
              strValeur := copy(strValeur,1,8);
              try
                 valeurVar[index,NbrePoints] := StrToTime(strValeur);
              except
                 valeurVar[index,NbrePoints] := Nan;
              end;
          end
          else valeurVar[index,NbrePoints] := strToFloatWin(strValeur);
      end;
      nmes := nmes+1;
      litLigneCSV;
   end;
end; // litValeurs

var Ligne : string;
    i : integer;
begin // litChauvinArnoux
    csvReset;
    finFichierCSV := false;
    NbreCSV := 0;
    csvReadln(Ligne);
    for i := 0 to maxGrandeurs do
        DecodeVariab[i] := grandeurInconnue;
    if nouveauFichier then begin
        AjouteExperimentale('index',variable);
        grandeurs[0].NomUnite := '';
        AjouteExperimentale('t',variable);
        grandeurs[1].NomUnite := 's';
        grandeurs[1].formatU := fTime;
        AjouteExperimentale('T',variable);
        grandeurs[2].NomUnite := '°C';
        for i := 0 to 2 do
            DecodeVariab[i] := i;
    end
    else begin
        DecodeVariab[0] := indexNom('index');
        if DecodeVariab[0]=grandeurInconnue then
           DecodeVariab[0] := 0;
        DecodeVariab[1] := indexNom('t');
        DecodeVariab[2] := indexNom('T');
    end;
    if not ajoutePage then exit;
    pages[pageCourante].commentaireP := Ligne;
    csvReadln(Ligne); // deuxième ligne en-tête colonnes
    separateurCSV := ';';
    ligneList.delimiter := separateurCSV;
    litValeurs;
    if pages[pageCourante].nmes>0 then begin
        result := true;
        construireIndex;
    end;
end; // litChauvinArnoux

function litFizziq : boolean;
var nomCourt : string;
begin
    result := false;
    nomCourt := extractFileName(nomFichier);
    nomCourt := changeFileExt(nomCourt,'');
    TrimAscii127(nomCourt);
    if (nomCourt='') or (pos(nomCourt,premiereLigne)=0) then exit;
    csvReadln(premiereLigne); // ligne vide
    if premiereLigne<>'' then exit;
    csvReadln(premiereLigne); // titre
    commentaire := premiereLigne;
    csvReadln(premiereLigne);
    if pos('Date',premiereLigne)=0 then exit;
    commentaire := commentaire+' '+premiereLigne;
    if pos(';',premiereLigne)>0
       then separateurCSV := ';'
       else if pos(',',premiereLigne)>0
            then separateurCSV := ',';
    ligneList.delimiter := separateurCSV;
    csvReadln(premiereLigne); // ligne vide
    if premiereLigne<>'' then exit;
    finFichierCSV := false;
    if litNomUniteFizziq
       then result := pages[pageCourante].nmes>0
       else begin
          csvReset;
          csvReadln(premiereLigne);
          result := false;
       end;
end; // litFizziq

procedure litTektro;
var penteY,penteX,Yzero,probe,Yoffset : double;

procedure extraitPoint;
const
    filtre : TSysCharSet = ['0'..'9'];
    filtreInterne : TSysCharSet = ['0'..'9','.','-','E'];
var chaine : string;
    nbreCarac,posDebut : integer;
    premiereLigne : string;

function extraitNombre : double;
var posV : integer;
begin
    posV := pos(',',premiereLigne);
    premiereLigne := copy(premiereLigne, posV+1, length(premiereLigne)-posV);
    posV := pos(',',premiereLigne);
    if posV>0 then premiereLigne := copy(premiereLigne, 1, posV-1);
    result := strToFloatWin(premiereLigne);
end;

begin with pages[pageCourante] do begin
   csvReadln(premiereLigne);
   posDebut := length(premiereLigne);
   while (posDebut>0) and not CharInset(premiereLigne[posDebut],filtre) do dec(posDebut);
   nbreCarac := 0;
   while (posDebut>0) and CharInset(premiereLigne[posDebut],filtreInterne) do begin
     inc(nbreCarac);
     dec(posDebut);
   end;
   chaine := copy(premiereLigne,posDebut+1,nbreCarac);
   valeurVar[1,nmes] := strToFloatWin(chaine);
   while (posDebut>0) and not CharInSet(premiereLigne[posDebut],filtre) do dec(posDebut);
   nbreCarac := 0;
   while (posDebut>0) and charInset(premiereLigne[posDebut],filtre) do begin
     inc(nbreCarac);
     dec(posDebut);
   end;
   chaine := copy(premiereLigne,posDebut+1,nbreCarac);
   valeurVar[0,nmes] := strToFloatWin(chaine);
   nmes := nmes+1;
   if pos('Vertical Scale',premiereLigne)>0 then
         penteY := extraitNombre/2000;
// pleine échelle avec 10 divisions sur 2048 niveaux
   if pos('Horizontal Scale',premiereLigne)>0 then
         penteX := extraitNombre*1e-6/250;
// par division avec 10 divisions sur 2500 points en micro s
    if pos('Vertical Offset',premiereLigne)>0 then
         Yoffset := extraitNombre;
    if pos('Probe Atten',premiereLigne)>0 then
         probe := extraitNombre;
    if pos('Yzero',premiereLigne)>0 then
         yzero := extraitNombre;
end end;

var i : integer;
begin
     csvReset;
     penteX := 1e-6;
     penteY := 1;
     probe := 1;
     Yoffset := 0;
     yzero := 0;
     if nouveauFichier then begin
        AjouteExperimentale('t',variable);
        grandeurs[0].NomUnite := 's';
        AjouteExperimentale('V',variable);
        grandeurs[1].NomUnite := 'V';
     end;
     if not ajoutePage then exit;
     while not csvEof do extraitPoint;
     result := pages[pageCourante].nmes>128;
     penteY := penteY/probe;
     for i := 0 to pred(pages[pageCourante].nmes) do begin
         pages[pageCourante].valeurVar[0,i] := i*penteX;
         pages[pageCourante].valeurVar[1,i] := (pages[pageCourante].valeurVar[1,i]-yzero)*penteY+yOffset;
     end;
end;  // litTektro

function litLigneSecomam : string;
var i : integer;
    uneLigne : string;
begin
    csvReadln(uneLigne);
    result := '';
    for i := 1 to Length(uneLigne) do
        if ord(uneLigne[i])>1 then result := result+uneLigne[i];
end;

procedure litSecomam;

procedure extraitPoint;
var chaine : string;
    posTab : integer;
    uneLigne : string;
begin with pages[pageCourante] do begin
   uneLigne := litLigneSecomam;
   posTab := pos(crTab,uneLigne);
   if posTab=0 then exit;
   chaine := copy(uneLigne,1,pred(posTab));
   valeurVar[0,nmes] := strToFloatWin(chaine);
   chaine := copy(uneLigne,succ(posTab),length(uneLigne));
   valeurVar[1,nmes] := strToFloatWin(chaine);
   nmes := nmes+1;
end end;

procedure getNU(tout : string;var nom,unite : string);
var posCO,posCF : integer;
begin
    posCO := pos('[',tout);
    posCF := pos(']',tout);
    if (posCO>0) and (posCF>posCO) then begin
       unite := copy(tout,succ(posCO),posCF-posCO-1);
       nom := copy(tout,1,pred(posCO))
    end
    else begin
       unite := '';
       nom := tout;
    end;
end;

var uneLigne : string;
    posTab : integer;
    nomComplet,Lnom,Lunite : string;
begin  // secomam : csv avec tabulation !
     repeat
         uneLigne := litLigneSecomam;
     until csvEof or (pos('Absorption',uneLigne)>0);
     if pos('Absorption',uneLigne)=0 then exit;
     if nouveauFichier then begin
        posTab := pos(crTab,uneLigne);
        nomComplet := copy(uneLigne,1,pred(posTab));
        getNU(nomComplet,Lnom,Lunite);
        AjouteExperimentale(Lnom,variable);
        grandeurs[0].NomUnite := Lunite;
        grandeurs[0].fonct.expression := nomComplet;
        nomComplet := copy(uneLigne,succ(posTab),length(uneLigne));
        getNU(nomComplet,Lnom,Lunite);
        AjouteExperimentale(Lnom,variable);
        grandeurs[1].NomUnite := Lunite;
        grandeurs[1].fonct.expression := nomComplet;
     end;
     if not ajoutePage then exit;
     while not csvEof do
        extraitPoint;
     result := pages[pageCourante].nmes>2;
end;  // litSecomam

procedure litPasco;
Const
  maxConnu = 13;
  nomPasco : array[1..MaxConnu] of string =
  ('Velocite','Vitesseangulaire','Temps','Position','PhaseShift','Frequency',
   'Velocity','Angle','AngularVelocity','Force','AngularAcceleration','Time','Acceleration');
  signifPasco : array[1..MaxConnu] of string =
  ('vitesse','vitesse angulaire','temps','position','phase','fréquence',
   'vitesse','angle','vitesse angulaire','force','accélération angulaire','temps','accélération');
  nomSimplePasco : array[1..MaxConnu] of string =
  ('v',omegaMin,'t','d',phiMin,'f',
   'v',thetaMin,omegaMin,'F',alphaMin,'t','a');

var
  pagePasco : array[codeGrandeur] of codePage;
  NomVariabPagePasco : array[1..maxConnu] of TStringList;
  nomPage : TstringList;
  nbreCsvPasco : integer;
  p: Integer;

function ConvertitNomPasco(chaine : string) : string;
var suivantUnicode : boolean;
    i : integer;
begin
    result := '';
    suivantUnicode := false;
    for i := 1 to length(chaine) do begin
        if chaine[i]='Ã'
           then SuivantUnicode := true
           else begin
              if suivantUnicode
                 then case chaine[i] of
                      '©' : result := result + 'e';//'é';
                      '²' : result := result + '2';
                      '¨' : result := result + 'e';//'è';
                      'ª' : result := result + 'e';//'ê';
                      '«' : result := result + 'e';//'ë';
                      '´' : result := result + 'o';//'ô';
                      '°' : ;//result := result + '°';
                      '§' : result := result + 'c';//'ç';
                      '¼' : result := result + 'u';//'ü';
                      '»' : result := result + 'u';//'û';
                 end
                 else if charInSet(chaine[i],caracNomPasco) then result := result + chaine[i];
                 // on enlève les blancs tirets ...
              suivantUnicode := false;
           end;
    end;
end;

procedure affectePagePasco;
var i : integer;
    pageC : codePage;
    indexNomTitre : integer;
begin
    nomPage := TstringList.Create;
    for i := 1 to MaxConnu do NomVariabPagePasco[i] :=  TstringList.Create;
    pageC := 0;
    for i := 0 to maxMaxGrandeurs do pagePasco[i] := 0;
    NbreCSVPasco := NbreCSv;
    for i := 0 to pred(NbreCSV) do begin
        indexNomTitre := nomPage.indexOfName(ligneList[i]);
        if indexNomTitre=-1
        then begin // nouvellePage
             inc(pageC);
             nomPage.Add(ligneList[i]+'='+intToStr(pageC));
             pagePasco[i] := pageC;
        end
        else begin
             pagePasco[i] := strToInt(nomPage.valueFromIndex[indexNomTitre]);
        end;
    end;
end;

procedure litNomUnitePasco;
var i,index : integer;
    signif,suffixe : string;
    k,j: Integer;
begin
     for i := 0 to maxMaxGrandeurs do DecodeVariab[i] := grandeurInconnue;
     for i := 0 to pred(NbreCSV) do begin
         signif := LigneList[i];
         //Unite[i] := VerifUnite(Unite[i]);
         Nom[i] := convertitNomPasco(LigneList[i]);
         for k := 1 to maxConnu do begin
             if pos(nomPasco[k],nom[i])=1 then begin
                if length(nom[i])>length(nomPasco[k])
                   then suffixe := copy(nom[i],length(nomPasco[k])+1,length(nom[i])-length(nomPasco[k]))
                   else suffixe := '';
                signif := signifPasco[k];
                if suffixe='resultante' then begin
                   suffixe := 'R'; // résultante
                   signif := signif+' résultante';
                end;
                nom[i] := nomSimplePasco[k]+suffixe;
             end;
         end;
         if nom[i]<>'' then begin
            if (indexNom(nom[i])<>grandeurInconnue) then begin
               decodeVariab[i] := indexNom(nom[i]);
               if pagePasco[i]=1 then begin // existe déjà -> mettre dans une autre page
                  j := 1;
                  repeat
                      inc(j);
                  until (nomVariabPagePasco[j].indexOfName(nom[i])<0) or (j=MaxConnu);
                  pagePasco[i] := j;
                  if j>nomPage.count then
                     nomPage.Add(char(ord('A')+j)+'='+intToStr(j));
               end;
               nomVariabPagePasco[pagePasco[i]].Add(nom[i]);
            end;
            if indexNom(nom[i])=grandeurInconnue then begin
               index := AjouteExperimentale(nom[i],variable);
               decodeVariab[i] := index;
               grandeurs[index].NomUnite := unite[i];
               grandeurs[index].fonct.expression := signif;
            end;
         end;
     end;
end;

procedure LitValeursPasco;
var i : integer;
    index : integer;
    dataLigne : array[codePage] of integer;
    iPage : integer;
begin
   while not(finFichierCSV) do begin
      litLigneCSV;
      if NbreCSV=0 then exit;
      for i := 1 to NbrePages do
          dataLigne[i] := 0;
      for i := 0 to pred(NbreCSV) do begin
          index := decodeVariab[i];
          if index<>GrandeurInconnue then begin
             iPage := pagePasco[i];
             if ligneList[i]<>''
                then begin
                   pages[iPage].valeurVar[index,pages[iPage].nmes] := strToFloatWin(ligneList[i]);
                   inc(dataLigne[iPage]);
                end;
          end;
      end;
      for i := 1 to NbrePages do
          if dataLigne[i]>2 then pages[i].nmes := pages[i].nmes+1;
   end;
end; // litValeursPasco

var i,j,k,imax : integer;
    existeAilleurs : boolean;
    NomVariab : array[codeGrandeur] of string;
    NbreDataZero : array[codePage,codeGrandeur] of integer;
    nbreVar : integer;
label fin;
begin
     caracNomPasco := ['a'..'z','A'..'Z','0'..'9'];
     finFichierCsv := false;
     csvReset;
     litLigneCSV;
     affectePagePasco;
     litLigneCSV;
     litNomUnitePasco;
     if NbreGrandeurs=0 then goto fin;
     for i := 0 to pred(nomPage.count) do begin
         ajoutePageForce;
         pages[pageCourante].CommentaireP := nomPage.Names[i];
     end;
     litValeursPasco;
     construireIndex;
     for j := 0 to NbreCsvPasco do
         if decodeVariab[j]=grandeurInconnue
            then NomVariab[j] := ''
            else NomVariab[j] := grandeurs[decodeVariab[j]].nom;
     for i := NbrePages downto 1 do
           if (pages[i].nmes<8) and (NbrePages>1) then begin
                 SupprimePage(i,false);
                 // supprimer les grandeurs n'apparaissant que dans cette page
                 for j := 0 to pred(NbreCsvPasco) do
                     if PagePasco[j]=i then begin
                        existeAilleurs := false;
                        for k := 0 to pred(NbreCsvPasco) do
                            if (j<>k) and (nomVariab[k]=nomVariab[j]) then begin
                               existeAilleurs := true;
                               break;
                            end;
                        if not existeAilleurs then VariabASuppr.add(nomVariab[j]);
                     end;
                 for j := 0 to pred(NbreCsvPasco) do begin
                     if pagePasco[j]>i then dec(pagePasco[j]);
                     if pagePasco[j]=i then pagePasco[j] := 0;
                 end;
              end;
      if NbrePages>3 then begin
           // supprimer les grandeurs n'apparaissant que dans une page
           for j := 0 to pred(NbreGrandeurs) do begin
               i := 0;
               for k := 0 to pred(NbreCsvPasco) do
                   if (nomVariab[k]=grandeurs[j].nom) then
                      inc(i);
               if (i<2) and (grandeurs[j].nom<>'t') then VariabASuppr.add(grandeurs[j].nom);
           end;
      end;
      if NbrePages>=2 then begin
           // distribuer le temps sur les pages
           for j := 0 to pred(NbreGrandeurs) do
               if (grandeurs[j].nom='t') then begin
                   for p := 2 to NbrePages do begin
                       if isNan(pages[p].valeurVar[j,2]) then begin
                           if (pages[p].nmes>pages[1].nmes)
                               then imax := pred(pages[1].nmes)
                               else imax := pred(pages[p].nmes);
                           for i := 0 to imax do
                               pages[p].valeurVar[j,i] := pages[1].valeurVar[j,i];
                       end;
                   end;
                   break;
               end;
      end;
      for p := 1 to NbrePages do begin
          for j := 0 to pred(NbreGrandeurs) do begin
              NbreDataZero[p,j] := 0;
              for i := 0 to pred(pages[p].nmes) do
                  if IsNan(pages[p].ValeurVar[j,i]) or
                    (pages[p].ValeurVar[j,i]=0) then inc(NbreDataZero[p,j]);
          end;
      end;
      for j := 0 to pred(NbreGrandeurs) do begin
        // supprimer les grandeurs sans intérêt
          existeAilleurs := false;
          for p := 1 to NbrePages do
              if NbreDataZero[p,j]<(pages[p].nmes div 2) then begin
                 existeAilleurs := true;
                 break;
              end;
          if not existeAilleurs then VariabASuppr.add(grandeurs[j].nom);
      end;
      for p := NbrePages downto 1 do begin
      // supprimer les pages sans intérêt
          NbreVar := 0;
          for j := 0 to pred(NbreGrandeurs) do
              if NbreDataZero[p,j]<(pages[p].nmes div 2) then inc(Nbrevar);
          if (nbreVar<=1) and (NbrePages>1) then SupprimePage(p,false);
      end;
      for i := 0 to pred(VariabASuppr.count) do
          supprimeGrandeurE(indexNomVariab(VariabASuppr[i]));
      LitCSV := (NbrePages>0) and (pages[1].nmes>0) and (NbreGrandeurs>1);
      fin:
      nomPage.Free;
      for i := 1 to MaxConnu do NomVariabPagePasco[i].free;
end; // litPasco

var ls : string;
    compteur,i,indexDateTexte : integer;
    t0 : double;
label fin;
begin // LitCSV
     result := false;
     nombrePages := 1;
     lectureFichier := true;
     codeErreurF := erFileData;
     ModeAcquisition := AcqFichier;
     AFormatSettings := TFormatSettings.Create;
     VariabTextuelle := [];
     for i := 0 to maxMaxGrandeurs do begin
         nom[i] := '';
         unite[i] := '';
     end;
     csvLines := TStringList.Create;
     VariabASuppr := TStringList.create;
     VariabASuppr.Duplicates := dupIgnore;
     try
     try
        LoadLinesSmart(csvLines, NomFichier);
     except
        on E:exception do begin
           codeErreurF := E.message;
           exit;
        end;
     end;
     csvReset;
     csvReadln(premiereLigne);
     premiereLigne := NettoieIMCCE(premiereLigne);
     ligneList.delimiter := ',';
     ligneList.QuoteChar := #0;
     separateurCSV := ',';
     if pos(';',premiereLigne)>0
        then separateurCSV := ';'
        else if pos(',',premiereLigne)>0
           then separateurCSV := ','
           else if pos(crTab,premiereLigne)>0
              then separateurCSV := crTab;
     ligneList.delimiter := separateurCsv;
     isPasco := false;
     if not isPasco then
        isPasco := compte(premiereLigne,'Set')>5;
     if not isPasco then
        isPasco := compte(premiereLigne,'Calibrate')>5;
     if not isPasco then
        isPasco := compte(premiereLigne,'Run #')>5;
     if not isPasco then
        isPasco := compte(premiereLigne,'Monitor Run')>5;
     if not isPasco then
        isPasco := compte(premiereLigne,'Exécuter')>5;
     if not isPasco then
        isPasco := compte(premiereLigne,'ExÃ©cuter')>5;
     if isPasco then begin
         litPasco;
         goto fin;
     end;
     if litFizziq then goto fin;
     if pos('Record Length',premiereLigne)>0 then begin
        litTektro;
        goto fin;
     end;
     if pos('IR Camera',premiereLigne)>0 then begin
        litChauvinArnoux;
        goto fin;
     end;
     if pos('Memory Length',premiereLigne)>0 then begin
        litGoodwill;
        goto fin;
     end;
     if pos('DESCRIPTION',premiereLigne)>0 then begin
         csvReadln(premiereLigne);
         if pos('MANUFACTURE',premiereLigne)>0 then begin
           litGoodwillPC;
           goto fin;
         end;
         csvReset;
         csvReadln(premiereLigne);
     end;
     if pos('SOMMAIRE',premiereLigne)>0 then begin
         csvReadln(premiereLigne);
         if (pos('BUTER',premiereLigne)>0) and (pos('ARR',premiereLigne)>0) then begin
            litHanna;
            goto fin;
         end;
         csvReset;
         csvReadln(premiereLigne);
     end;
     NbreEnTete := 0;
     while not csvEof and
           ((length(premiereLigne)=0) or (premiereLigne[1]='#') or
           ((pos(';',premiereLigne)<=0) and (pos(',',premiereLigne)<=0) and (pos(crTab,premiereLigne)<=0))) do begin
        inc(NbreEnTete);
        csvReadln(premiereLigne);
        premiereLigne := NettoieIMCCE(premiereLigne);
     end;
     if pos(';',premiereLigne)>0
        then separateurCSV := ';'
        else if pos(',',premiereLigne)>0
           then separateurCSV := ','
           else if pos(crTab,premiereLigne)>0
              then separateurCSV := crTab;
     ligneList.delimiter := separateurCSV;
     avecNoms := not LigneDeChiffres(premiereLigne);
     compteur := 1;
     repeat
        ls := litLigneSecomam;
        inc(compteur);
     until csvEof or
           (pos('UviLine',ls)>0) or
           (compteur=5);
     if (pos('UviLine',ls)>0) then begin
         csvReset;
         litSecomam;
         goto fin;
     end;
     csvReset;
     finFichierCSV := false;
     NbreCSV := 0;
     commentaire := '';
     for compteur := 1 to NbreEnTete do begin
         csvReadln(premiereLigne);
         premiereLigne := NettoieIMCCE(premiereLigne);
         if (length(premiereLigne)>0) and (premiereLigne[1]='#')
            then premiereLigne := copy(premiereLigne,2,length(premiereLigne));
         if premiereLigne<>'' then begin
            if commentaire<>'' then commentaire := commentaire + ' ';
            commentaire := commentaire + premiereLigne;
         end;
     end;
     try
     if NouveauFichier
        then litNomUnite
        else verifNoms;
     if result and nouveauFichier then begin
        if (NbreGrandeurs>0) and (grandeurs[0].nom='Date') then begin
           grandeurs[0].nom := 't';
           grandeurs[0].nomUnite := 'jour';
           grandeurs[0].formatU := fDefaut;
           indexDateTexte := ajouteExperimentale('Date',variable);
           grandeurs[indexDateTexte].fonct.genreC := g_texte;
           construireIndex;
           with pages[pageCourante] do if nmes>0 then begin
              t0 := valeurVar[0,0];
              for i := 0 to nmes-1 do begin
                 texteVar[indexDateTexte,i] := FormatDateTime('dd mmm yyyy',valeurVar[0,i]);
                 valeurVar[0,i] := valeurVar[0,i]-t0;
              end;
           end;
        end;
        pages[pageCourante].affecteVariableP(false);
        pages[pageCourante].commentaireP := commentaire;
     end;
     except
         codeErreurF := erReadFile;
         result := false;
     end;
     fin:
     finally
       lectureFichier := false;
       variabAsuppr.free;
       csvLines.free;
     end;
end; // LitCSV

Procedure TFichierRegressi.EcritTableur(const NomFichier : string);
var isCSV,isTXT : boolean;
    FichierAsc : textFile;

Procedure sautDeLigne;
begin
    if isCSV then write(FichierAsc,crLF) else writeln(fichierAsc)
end;

var
    i,j : integer;
    extension : string;
    avecPoint : boolean;
begin
     extension := AnsiUpperCase(ExtractFileExt(NomFichier));
     isCSV := extension='.CSV';
     isTXT := extension='.TXT';
     if isCSV
        then if oCSV_vrai
           then separateurCsv := ','
           else if formatSettings.decimalSeparator='.'
              then separateurCsv := ','
              else separateurCsv := ';'
        else separateurCsv := crTab;
     try
     AssignFile(fichierAsc,NomFichier);
     Rewrite(fichierAsc);
     if not isCSV and not isTXT then
        writeln(fichierAsc,pages[pageCourante].TitrePage);
     if not isCSV or not oCSV_valeursSeules then begin
        write(fichierAsc,grandeurs[0].nom);
        for i := 1 to pred(NbreGrandeurs) do
            if grandeurs[i].genreG=variable then
               write(fichierAsc,separateurCsv,grandeurs[i].nom);
        sautDeLigne;
        write(fichierAsc,grandeurs[0].nomUnite);
        for i := 1 to pred(NbreGrandeurs) do
            if grandeurs[i].genreG=variable then
               write(fichierAsc,separateurCsv,grandeurs[i].nomUnite);
        sautDeLigne;
     end;
     if not isCSV and not isTXT then begin
        write(fichierAsc,grandeurs[0].fonct.expression);
        for i := 1 to pred(NbreGrandeurs) do
            if grandeurs[i].genreG=variable then
               write(fichierAsc,crTab,grandeurs[i].fonct.expression);
        sautDeLigne;
     end;
     avecPoint := not(isCSV) or oCSV_vrai;
     with pages[pageCourante] do
          for j := 0 to pred(Nmes) do begin
                if avecPoint
                   then write(fichierAsc,FloatToStrPoint(valeurVar[0,j]))
                   else write(fichierAsc,FloatToStr(valeurVar[0,j]));
                for i := 1 to pred(NbreGrandeurs) do
                    if grandeurs[i].genreG=variable then if avecPoint
                       then write(fichierAsc,separateurCsv,FloatToStrPoint(valeurVar[i,j]))
                       else write(fichierAsc,separateurCsv,FloatToStr(valeurVar[i,j]));
            sautDeLigne;
     end; // for j
     if (NbreConst>0) and not isCSV and not isTXT then begin
        writeln(fichierAsc);
        for i := 0 to pred(NbreGrandeurs) do
            if grandeurs[i].genreG=constante then
               write(fichierAsc,grandeurs[i].nom,separateurCsv);
        sautDeLigne;
        for i := 0 to pred(NbreGrandeurs) do
            if grandeurs[i].genreG=constante then
               write(fichierAsc,grandeurs[i].nomUnite,separateurCsv);
        sautDeLigne;
        for i := 0 to pred(NbreGrandeurs) do
            if grandeurs[i].genreG=constante then
               write(fichierAsc,grandeurs[i].fonct.expression,separateurCsv);
        sautDeLigne;
        for i := 0 to pred(NbreGrandeurs) do
            if grandeurs[i].genreG=constante then
               write(fichierAsc,FloatToStrPoint(pages[pageCourante].valeurConst[i]),separateurCsv);
        sautDeLigne;
     end;
     closeFile(FichierAsc);
     except
     end;
end; // EcritTableur

procedure TFichierRegressi.ChercheTab;

Function LigneDeChiffres(const s : String) : boolean;
var j : integer;
    AvecChiffres : boolean;
begin
    Result := false;
    AvecChiffres := false;
    for j := 1 to length(s) do
        if charinset(s[j],chiffreEtc)
           then avecChiffres := true
           else if not charinset(s[j],separateur) then exit;
    result := avecChiffres;
    if result then begin
       if pos(';',s)>0 then begin
          separateurCSV := ';';
          if pos(',',s)>0 then avecTab := sPointVirgule; // 1,23;1,58
       end;
       if pos('.',s)>0 then begin
          separateurCSV := ',';
          if pos(',',s)>0 then avecTab := sVirgule; // 1.23,1.59
       end;
    end;
end;

var i : integer;
begin
     AvecTab := sBlanc;
     if (donnees.lines.count<3) then exit;
     i := 0;
     while (AvecTab=sBlanc) and
           (i<Donnees.lines.count) and
           (i<5) do begin
              if pos(crTab,Donnees.lines[i])<>0 then avecTab := sTab;
              inc(i);
     end;
     if (AvecTab=sBlanc) then begin
          i := 0;
          repeat inc(i)
          until (i=Donnees.lines.count) or
                (i=4) or
                ligneDeChiffres(donnees.lines[i]);
     end;
     case avecTab of
         sTab : separateurCsv := crTab;
         sBlanc : separateurCsv := ' ';
         sVirgule : separateurCsv := ',';
         sPointVirgule : separateurCsv := ';';
     end;
     ligneList.delimiter := separateurCsv;
end; // chercheTab

Function TFichierRegressi.ExtraitIncert(var ligne : integer) : boolean;

Function ExtraitValeurIncert(const s : string;N : integer) : boolean;
var jfin,jdebut : integer;
    i : integer;
    valeur : double;
begin with pages[pageCourante] do begin
    result := true;
    i := 0;jfin := 1;
    try
    Repeat
        jdebut := jfin;
        while (jdebut<length(s)) and
              not charinset(s[jdebut],chiffreEtc) do inc(jdebut);
        jfin := jdebut;
        while (jfin<=length(s)) and
              charinset(s[jfin],chiffreEtc) do inc(jfin);
        valeur := strToFloatWin(copy(s,jdebut,jfin-jdebut));
        incertVar[decodeVariab[i],N] := valeur;
        inc(i);
    Until (jfin>=length(s)) or (i>=NbreVariab);
    except
          result := false;
    end;
end end; // extraitValeurIncert

var NbreLigne,j : integer;
    s : string;
begin with pages[pageCourante] do begin
    if ligne>=Donnees.lines.count then begin
       result := false;
       exit;
    end;
    s := Donnees.lines[ligne];
    result := (pos('INCERT',s)>0) and (s[1]=symbReg2);
    if not result then exit;
    inc(ligne);
    NbreLigne := NbreLigneWin(s);
    for j := 0 to pred(NbreLigne) do begin
         extraitValeurIncert(Donnees.lines[ligne],j);
         inc(ligne);
    end;
    result := true;
end end; // extraitIncert

Function TFichierRegressi.ExtraitValeur(Agenre : TgenreGrandeur;ligne : integer;imax : integer) : boolean;
var s: string;

Function ExtraitValeurLoc : boolean;
var j : integer;
    i : integer;
    index : integer;
    valeur : array[codeGrandeur] of double;
    strValeur,texte : string;
    posDate,posTime : integer;
begin with pages[pageCourante] do begin
    result := (length(s)>0) and (s[1]<>symbReg2);
    if not result then exit;
    i := 0;
    ligneList.DelimitedText := s;
    try
    for j := 0 to pred(ligneList.count) do begin
        strValeur := ligneList[j];
        posTime := pos(':',strValeur);
        posDate := pos('/',strValeur);
        if (posTime>0) or (posDate>0)
            then begin
                try
                if Agenre=variable
                    then index := decodeVariab[i]
                    else index := decodeConst[i];
                if posTime>0
                   then if posDate>0
                        then begin
                            valeur[i] := StrToDateTime(strValeur);
                            Grandeurs[index].formatU := fDateTime;
                            indexDateTime := index;
                        end
                        else begin
                           valeur[i] := StrToTime(strValeur);
                           indexTime := index;
                           Grandeurs[index].formatU := fTime;
                        end
                   else begin
                        valeur[i] := StrToDate(strValeur);
                        indexDate := index;
                        Grandeurs[index].formatU := fDate;
                   end;
                 except
                   valeur[i] := Nan;
                 end;
             end
             else if i=indexTexte
               then texte := strValeur
               else valeur[i] := strToFloatWin(strValeur);
        inc(i);
    end;
    imax := pred(i);
    if Agenre=variable
       then begin
           nmes := nmes+1;
           for i := 0 to imax do begin
               index := decodeVariab[i];
               if i=indexTexte
                  then texteVar[index,pred(Nmes)] := texte //??
                     else if isPrecVariab[i]
                          then incertVar[index,pred(Nmes)] := valeur[i]
                          else valeurVar[index,pred(Nmes)] := valeur[i];
           end;
       end
       else for i := 0 to imax do begin
            index := decodeConst[i];
            if isPrecConst[i]
               then incertConst[index] := valeur[i]
               else valeurConst[index] := valeur[i];
       end
     except
       result := false
     end;
end end; // extraitValeurLoc

Function ExtraitValeurTab : boolean;
var j : integer;
    i : integer;
    k,kk : integer;
    index : integer;
    valeur : array[codeGrandeur] of double;
    strValeur : string;
    posDate,posTime : integer;
    valeurNonDef : boolean;

Procedure TrimStrValeur;
var longueur,posCourant : integer;
begin
     longueur := Length(strValeur);
     posCourant := 1;
     while (posCourant<=longueur) do
         if charinset(strValeur[posCourant],chiffreEtc+[':','/'])
            then inc(posCourant)
            else if (posCourant=longueur) and
                    charinset(strValeur[posCourant],caracPrefixe)
                 then convertitPrefixe(strValeur)
                 else begin
                      Delete(strValeur,posCourant,1);
                      dec(longueur);
                 end;
end;

begin with pages[pageCourante] do begin
    result := (length(s)>0) and (s[1]<>symbReg2);
    if not result then exit;
    i := 0;
    valeurNonDef := false;
    result := false;
    ligneList.DelimitedText := s;
    if (Agenre=variable) and (ligneList.count>NbreVariab) and (ligneList.count<=maxGrandeurs) then
       for j := NbreVariab+1 to ligneList.count do
           decodeVariab[j-1] := AjouteExperimentale('x'+intToStr(j),variable);
    for j := 0 to pred(ligneList.count) do begin
        strValeur := ligneList[i];
        trimStrValeur;
        posTime := pos(':',strValeur);
        posDate := pos('/',strValeur);
        try
        if (posTime>0) or (posDate>0)
            then begin
                if Agenre=variable
                    then index := decodeVariab[i]
                    else index := decodeConst[i];
                if posTime>0
                   then if posDate>0
                        then begin
                            valeur[i] := StrToDateTime(strValeur);
                            Grandeurs[index].formatU := fDateTime;
                        end
                        else begin
                           valeur[i] := StrToTime(strValeur);
                           indexTime := index;
                           Grandeurs[index].formatU := fTime;
                        end
                   else begin
                        valeur[i] := StrToDate(strValeur);
                        indexDate := index;
                        Grandeurs[index].formatU := fDate;
                   end
             end
             else valeur[i] := strToFloatWin(strValeur);
        result := true;
        except
              valeur[i] := Nan;
              valeurNonDef := true;
        end;
        inc(i);
        if (i=imax) and valeurNonDef and (j<length(s)) then begin
            k := -1;
            repeat inc(k)
            until (k=imax) or isNan(valeur[k]);
            if k<imax then begin
               for kk := k to (imax-2) do valeur[kk] := valeur[succ(kk)];
               dec(i);
            end;
        end;
    end;
    imax := pred(i);
    if Agenre=variable
       then begin
           nmes := nmes+1;
           for i := 0 to imax do begin
               index := decodeVariab[i];
               if isPrecVariab[i]
                  then incertVar[index,pred(Nmes)] := valeur[i]
                  else valeurVar[index,pred(Nmes)] := valeur[i];
               // texteVar[index,pred(Nmes)] := texte;
           end
       end
       else for i := 0 to imax do begin
               index := decodeConst[i];
               if isPrecConst[i]
                   then incertConst[index] := valeur[i]
                   else valeurConst[index] := valeur[i];
       end;
end end; // extraitValeurTab

Function ExtraitValeurCSV : boolean;
var j : integer;
    i : integer;
    k,kk : integer;
    index : integer;
    valeur : array[codeGrandeur] of double;
    strValeur : string;
    posDate,posTime : integer;
    valeurNonDef : boolean;

Procedure TrimStrValeur;
var longueur,posCourant : integer;
begin
     longueur := Length(strValeur);
     posCourant := 1;
     while (posCourant<=longueur) do
         if charinset(strValeur[posCourant],chiffreEtc+[':','/'])
            then inc(posCourant)
            else begin
                 Delete(strValeur,posCourant,1);
                 dec(longueur);
            end;
end;

begin with pages[pageCourante] do begin
    s := donnees.lines[ligne];
    result := length(s)>0;
    if not result then exit;
    i := 0;
    valeurNonDef := false;
    result := false;
    ligneList.DelimitedText := s;
    if (Agenre=variable) and (ligneList.count>NbreVariab) and (ligneList.count<=maxGrandeurs) then
       for j := NbreVariab+1 to ligneList.count do
           decodeVariab[j-1] := AjouteExperimentale('x'+intToStr(j),variable);
    for j := 0 to pred(ligneList.count) do begin
        strValeur := ligneList[j];
        trimStrValeur;
        posTime := pos(':',strValeur);
        posDate := pos('/',strValeur);
        try
        if (posTime>0) or (posDate>0)
            then begin
                if Agenre=variable
                    then index := decodeVariab[i]
                    else index := decodeConst[i];
                if posTime>0
                   then if posDate>0
                        then begin
                            valeur[i] := StrToDateTime(strValeur);
                            Grandeurs[index].formatU := fDateTime;
                        end
                        else begin
                           valeur[i] := StrToTime(strValeur);
                           indexTime := index;
                           Grandeurs[index].formatU := fTime;
                        end
                   else begin
                        valeur[i] := StrToDate(strValeur);
                        indexDate := index;
                        Grandeurs[index].formatU := fDate;
                   end
             end
             else valeur[i] := strToFloatWin(strValeur);
        result := true;
        except
              valeur[i] := Nan;
              valeurNonDef := true;
        end;
        inc(i);
        if (i=imax) and valeurNonDef and (j<length(s)) then begin
            k := -1;
            repeat inc(k)
            until (k=imax) or isNan(valeur[k]);
            if k<imax then begin
               for kk := k to (imax-2) do valeur[kk] := valeur[succ(kk)];
               dec(i);
            end;
        end;
    end;
    imax := pred(i);
    if Agenre=variable
       then begin
           nmes := nmes+1;
           for i := 0 to imax do begin
               index := decodeVariab[i];
               valeurVar[index,pred(Nmes)] := valeur[i];
           end
       end
       else for i := 0 to imax do
            valeurConst[decodeConst[i]] := valeur[i];
end end; // extraitValeurCSV

begin
   s := donnees.lines[ligne];
   case avecTab of
      sTab : result := extraitValeurTab;
      sBlanc :  result := extraitValeurLoc;
      sVirgule,sPointVirgule : result := extraitValeurCSV;
      else result := false;
   end;
end;

Procedure TFichierRegressi.extraitNom(const s : string;
                     var ListeN,ListeU : TstringList;creation : boolean);

Procedure extraitNomLoc;
var j : integer;
    nomU,uniteU : string;
    posParentheseO,posParentheseF : integer;
begin
    ligneList.DelimitedText := s;
    for j :=0 to pred(ligneList.count) do begin
            nomU := ligneList[j];
            posParentheseO := pos('(',nomU); // grandeur sous forme : nom (unite)
            posParentheseF := pos(')',nomU);
            if (posParentheseO>0) and (posParentheseF>posParentheseO)
               then begin
                  uniteU := copy(nomU,posParentheseO+1,posParentheseF-posParentheseO-1);
                  nomU := copy(nomU,1,posParentheseO-1);
               end
               else uniteU := '';
            listeU.Add(uniteU);
            listeN.Add(nomU);
     end;
end;

Procedure extraitNomTab;
var j,posIn : integer;
    Lnom,nomU : string;
    posParentheseO,posParentheseF : integer;
begin
    ligneList.DelimitedText := s;
    for j :=0 to pred(ligneList.count) do begin
        Lnom := ligneList[j];
        posIn := pos(' in ',Lnom);
        if posIn>0 then begin
           Lnom[posIn] := '(';
           delete(Lnom,posIn+1,3);
           Lnom := Lnom + ')';
        end;
        trimComplet(Lnom);
        if Lnom='Magnum' then Lnom := 'x';
        posParentheseO := pos('(',Lnom);
        posParentheseF := pos(')',Lnom);
        if (posParentheseO>0) and (posParentheseF>(posParentheseO+1))
           then begin
              nomU := copy(Lnom,posParentheseO+1,posParentheseF-posParentheseO-1);
              Lnom := copy(Lnom,1,pred(posParentheseO));
           end
           else nomU := '';
        if (Lnom='') and Creation then Lnom := 'x'+intToStr(listeN.count);
        listeN.Add(Lnom);
        listeU.Add(nomU);
     end;
     if listeN[listeN.count-1]='' then begin
            // cas de data Direct #9#9 pour trois variables ?
        if creation then listeN.Add('Z') else listeN.Add('');
        listeU.Add('');
     end;
end;

Procedure extraitNomCSV;
var j : integer;
    uniteU,nomU : string;
    posParentheseO,posParentheseF : integer;
begin
    ligneList.delimitedText := s;
    for j := 0 to pred(ligneList.Count) do begin
        nomU := ligneList[j];
        trimComplet(nomU);
        posParentheseO := pos('(',nomU);
        posParentheseF := pos(')',nomU);
        if (posParentheseO>0) and (posParentheseF>(posParentheseO+1))
           then begin
              uniteU := copy(nomU,posParentheseO+1,posParentheseF-posParentheseO-1);
              nomU := copy(nomU,1,pred(posParentheseO));
           end
           else uniteU := '';
        if (nomU='') and Creation then nomU := 'x'+intToStr(listeN.count);
        listeN.Add(nomU);
        listeU.Add(uniteU);
     end;
end;

begin
   listeN.clear;
   listeU.clear;
   case avecTab of
        sTab :  extraitNomTab;
        sBlanc : extraitNomLoc;
        sVirgule,sPointVirgule : extraitNomCSV;
   end;
end;

Function TFichierRegressi.ExtraitVariableTexte(var ligne : integer) : boolean;
var NbreLigne,j,index : integer;
    s : string;
begin with pages[pageCourante] do begin
    if ligne>=Donnees.lines.count then begin
       result := false;
       exit;
    end;
    s := Donnees.Lines[ligne];
    result := (pos('VARIAB_TEXTE',s)>0) and (s[1]=symbReg2);
    if not result then exit;
    NbreLigne := NbreLigneWin(s);
    result := NbreLigne=(nmes+1);
    if not result then exit;
    inc(ligne); // nom de la variable texte
    index := indexNom(Donnees.lines[ligne]);
    result := index>0;
    if not result then begin
       inc(ligne,NbreLigne);
       exit;
    end;
    inc(ligne); // les valeurs
    grandeurs[index].fonct.genreC := g_texte;
    for j := 0 to pred(nmes) do begin
         s := Donnees.lines[ligne];
         texteVar[index,j] := s;
         inc(ligne);
    end;
    result := true;
end end; // extraitVariableTexte

Function TFichierRegressi.LitTableur(const NomFichier : string) : boolean;
var i : integer;
begin
     donnees.lines.Clear;
     try
     LoadLinesSmart(Donnees.lines, NomFichier);
     for i := 0 to pred(Donnees.lines.Count) do
         Donnees.lines[i] := NettoieIMCCE(Donnees.lines[i]);
     except
        on E:exception do begin
           codeErreurF := E.message;
           result := false;
           exit;
        end;
     end;
     try
     if GetDataReg
        then result := true
        else begin
           codeErreurF := erFormat;
           result := false;
        end;
     ModeAcquisition := AcqFichier;
     except
         codeErreurF := erFormat;
         result := false;
     end;
     donnees.lines.Clear;
end; // LitTableur

Function LigneVide(Astr : string) : boolean;
begin
      trimComplet(Astr);
      result := Astr=''
end;

Function TFichierRegressi.GetDataReg : boolean;
var ligneCourante : integer;
    Comm : string;
    contenu : String;

Procedure affecteNom(Agenre : TgenreGrandeur);
var i,z : integer;
    isIncert : boolean;
begin
    extraitNom(Contenu,listeNom,listeUnite,true);
    for i := 0 to pred(listeNom.count) do begin
        isIncert := pos('sigma_',listeNom[i])=1;
        z := grandeurInconnue; // pour le compilateur
        if isIncert then begin // incertitude de qui ?
           z := indexNom(copy(listeNom[i],7,length(listeNom[i])-6));
           isIncert := (z<>grandeurInconnue) and
                       (grandeurs[z].genreG=Agenre);
        end;
        if not isIncert then
           z := AjouteExperimentale(listeNom[i],Agenre);
        if agenre=variable
           then begin
              decodeVariab[i] := z;
              isPrecVariab[i] := isIncert;
              if isIncert then inc(NbrePrecVariab);
           end
           else begin
              decodeConst[i] := z;
              isPrecConst[i] := isIncert;
              if isIncert then inc(NbrePrecConst);
           end;
        grandeurs[z].nomUnite := listeUnite[i];
    end;
end;

Procedure completeNomVar;

Procedure TrimNomVar(var s : String);
var longueur,posCourant : integer;
    sMaj : String;
begin
     longueur := Length(s);
     posCourant := 1;
     while (posCourant<=longueur) do
         if isCaracGrandeur(s[posCourant])
            then inc(posCourant)
            else begin
                 Delete(s,posCourant,1);
                 dec(longueur);
            end;
     sMaj := AnsiUpperCase(s);
     if sMaj='TEMPERATURE' then s := 'T'
     else if sMaj='HAUT' then s := 'max'
     else if sMaj='BAS' then s := 'min'
     else if sMaj='VITESSE' then s := 'V'
     else if sMaj='BAROMETRE' then s := 'P'
     else if sMaj='HUMIDITE' then s := 'Hum'
     else if sMaj='EXTERIEURE' then s := 'ext'
     else if sMaj='INTERIEURE' then s := 'int'
     else if sMaj='REFROIDISSEMENT' then s := 'Refr'
end;

var liste : TstringList;
    i,imax : integer;
    z1,z2 : string;
begin
    liste := TstringList.Create;
    extraitNom(Contenu,liste,listeUnite,false);
    imax := pred(liste.count);
    if imax>=NbreVariab then imax := pred(NbreVariab);
    for i := 0 to imax do begin
        Z1 := listeNom[i];
        Z2 := liste[i];
        grandeurs[i].fonct.expression := z1+' '+z2;
        TrimNomVar(Z1);
        TrimNomVar(Z2);
        if ((z1='V') or (z2='V')) and
           (grandeurs[i].nomUnite='') then grandeurs[i].nomUnite := 'm/s';
        if ((z1='T') or (z2='T')) and
           (grandeurs[i].nomUnite='') then grandeurs[i].nomUnite := '°C';
        if ((z1='P') or (z2='P')) and
           (grandeurs[i].nomUnite='') then grandeurs[i].nomUnite := 'hPa';
        if ((z1='Hum') or (z2='Hum')) and
           (grandeurs[i].nomUnite='') then grandeurs[i].nomUnite := '%';
        if (length(Z1)+length(Z2))>16
           then grandeurs[i].nom := copy(Z1,1,16 div 2)+
                                    copy(Z2,1,16 div 2)
           else grandeurs[i].nom := Z1+Z2;
    end;
    liste.free;
end;

Procedure extraitUniteLigne(Agenre : TgenreGrandeur);
var j,debut,long : integer;
    k : integer;
    delim : char;
begin
    j := 1;
    if Agenre=variable then k := 0 else k := NbreVariab;
    if avecTab=sPointVirgule then delim := ';' else delim := crTab;
    Repeat
        debut := j;
        while (j<=length(contenu)) and
              (contenu[j]<>delim) do inc(j);
        long := j-debut;
        if long>0 then begin
           Grandeurs[k].NomUnite := copy(contenu,debut,long);
           if Grandeurs[k].nomUnite='°' then AngleEnDegre := true;
           if Grandeurs[k].nomUnite='rad' then AngleEnDegre := false;
        end;
        inc(k);
        inc(j);// saute delimiteur
     Until (j>length(contenu)) or (k>=NbreGrandeurs);
end;

function ChercheEnTeteTracker : boolean;
begin
     result := (Donnees.lines.count>=3) and (pos('t;x;y;',Donnees.lines[1])>0);
     if result then begin
        Comm := Donnees.lines[0];
        contenu := Donnees.lines[1];
        affecteNom(variable);
        if ligneDeChiffres(Donnees.lines[2])
           then begin
              ligneCourante := 2;
              grandeurs[0].nomUnite := 's';
              grandeurs[1].nomUnite := 'm';
              grandeurs[2].nomUnite := 'm';
           end
           else begin
              contenu := Donnees.lines[2];
              extraitUniteLigne(variable);
              ligneCourante := 3;
           end;
     end;
end; // ChercheEnTeteTracker

Procedure extraitCommLigne(Agenre : TgenreGrandeur);
var j,debut,long : integer;
    k : integer;
begin
    j := 1;
    if Agenre=variable then k := 0 else k := NbreVariab;
    Repeat
        debut := j;
        while (j<=length(contenu)) and
              (contenu[j]<>crTab) do inc(j);
        long := j-debut;
        if long>0 then begin
           Fvaleurs.Memo.Lines.Add(''''+grandeurs[k].nom+'='+
                        copy(contenu,debut,long));
           grandeurs[k].fonct.expression := copy(contenu,debut,long);
        end;
        inc(k);
        inc(j);
     Until (j>=length(contenu)) or (k>=NbreGrandeurs);
end;

function ChercheEnTeteVariabFichier : boolean;
var FinEnTete : boolean;
    Code : integer;
    FinContenu : string;
    k : integer;
begin
     FinEnTete := false;
     Code := 0;
     Comm := '';
     while (ligneCourante<Donnees.lines.count) and not FinEnTete do begin
        Contenu := Donnees.lines[LigneCourante];
        FinEnTete := LigneDeChiffres(Contenu);
        if FinEnTete then break;
        if Length(contenu)>4
           then FinContenu := AnsiUppercase(copy(contenu,length(contenu)-3,4))
           else FinContenu := '';
        if (pos('Pointages',contenu)>0) and (avecTab=sPointVirgule) then begin
           comm := contenu;
        end
        else
        if (pos(crTab,Contenu)=0) and (avecTab=sTab)
           then if FinContenu='.EXE'
                then
                else begin
                   if Contenu<>'' then Fvaleurs.Memo.Lines.Add(''''+Contenu);
                   Comm := Contenu;
                 end
           else if (pos(crTab,Contenu)<>0) or
                    (contenu<>'') then if FinContenu='.EXE'
                then
                else begin
                  inc(code);
                  case code of
                      1 : if NbreVariab=0
                         then begin
                            affecteNom(variable);
                            for k := 0 to pred(NbreVariab) do
                                if grandeurs[k].nom='' then begin
                                   code := 0;
                                   break
                                end;
                          end
                          else completeNomVar;
                      2 : extraitUniteLigne(variable);
                      3 : extraitCommLigne(variable);
                  end; {case}
            end; {else}
            inc(LigneCourante);
     end;
     result := NbreGrandeurs>0;
end; // ChercheEnTeteVariabFichier

function ChercheEnTeteVide : boolean;
var i,j,N : integer;
    NombreEnCours : boolean;
begin
    ligneCourante := 0;
    while (ligneCourante<Donnees.lines.count) and
          (length(Donnees.lines[LigneCourante])=0) do inc(LigneCourante);
    contenu := Donnees.lines[LigneCourante];
    if pos(crTab,Contenu)>0 then avecTab := sTab else avecTab := sBlanc;
    Result := false;
    if length(contenu)=0 then exit;
    if not LigneDeChiffres(Contenu) then exit;
    NombreEnCours := charinset(contenu[1],chiffreEtc);
    if NombreEnCours then N := 1 else N := 0;
    for j := 2 to length(contenu) do
        if charinset(contenu[j],chiffreEtc) or
           (charinset(contenu[j],caracPrefixe) and
            contenu[j-1].isDigit)
                       then if NombreEnCours
                then
                else begin
                   NombreEnCours := true;
                   inc(N);
                end
           else if charinset(contenu[j],separateur)
                then NombreEnCours := false
                else exit;
    result := N>=1;
    for i := 1 to N do
        AjouteExperimentale('var'+intToStr(i),variable);
end; // ChercheEnTeteVide

function ChercheEnTeteConst : boolean;
var oldNbre : integer;
begin
     oldNbre := NbreGrandeurs;
     while (ligneCourante<Donnees.lines.count) and
           LigneVide(Donnees.lines[LigneCourante]) do inc(ligneCourante);
     result := ligneCourante<Donnees.lines.count;
     if not result then exit;
     Contenu := Donnees.lines[LigneCourante];
     result := contenu[1]<>symbReg2;
     if not result then exit;
     affecteNom(constante);
     result := NbreGrandeurs>OldNbre;
     if not result then exit;
     inc(ligneCourante);
     Contenu := Donnees.lines[LigneCourante];
     extraitUniteLigne(constante);
     inc(LigneCourante);
     Contenu := Donnees.lines[LigneCourante];
     if LigneDeChiffres(Contenu) then exit;
     extraitCommLigne(constante);
     inc(LigneCourante);
end; // ChercheEnTeteConst

var i,j,k : integer;
begin // GetDataReg
     FichierTrie := DataTrieGlb;
     for i := 0 to MaxGrandeurs do begin
         DecodeVariab[i] := i;
         DecodeConst[i] := indexConstExp[i];
         isPrecConst[i] := false;
         isPrecVariab[i] := false;
         NbrePrecConst := 0;
         NbrePrecVariab := 0;
     end;
     result := false;
     listeNom.clear;
     listeUnite.clear;
     ChercheTab;
     indexTime := grandeurInconnue;
     indexDate := grandeurInconnue;
     indexDateTime := grandeurInconnue;
     indexTexte := grandeurInconnue;
     LigneCourante := 0;
     if not ChercheEnTeteVariabFichier and
        not ChercheEnTeteTracker then begin
        if ChercheEnTeteVide and ajoutePage then begin
           pageCourante := 1;
           while (ligneCourante<Donnees.lines.count) and
               ExtraitValeur(variable,LigneCourante,NbreVariab+NbrePrecVariab)
               do inc(LigneCourante);
           result := true;
        end;
        exit;
     end;
     if not AjoutePage then exit;
     pages[1].CommentaireP := Comm;
     pageCourante := 1;
     if indexTexte<>grandeurInconnue then ;
     while (ligneCourante<Donnees.lines.count) and
            ExtraitValeur(variable,LigneCourante,NbreVariab+NbrePrecVariab)
        do inc(LigneCourante);
     if (indexTime<>grandeurInconnue) and
        (indexDate<>grandeurInconnue) and
        (indexDateTime=grandeurInconnue) then begin
           with Fvaleurs do begin
                memo.Lines.Add('t='+grandeurs[indexDate].nom+'+'+grandeurs[indexTime].nom);
                memo.Lines.Add('''t=date et heure');
           end;
           with graphe do begin
               k := 0;
               for j := 1 to MaxOrdonnee do begin
                   Coordonnee[j].nomX := 't';
                   while (k=indexDate) or (k=indexTime) do inc(k);
                   if k<NbreGrandeurs then
                      Coordonnee[j].nomY := grandeurs[k].nom;
                   inc(k)
               end;
               Monde[mondeX].Graduation := gLin;
               Monde[mondeX].zeroInclus := false;
               configCharge := true;
           end;
     end;
     if (ligneCourante<(Donnees.lines.count-2)) and
        ChercheEnTeteConst and
        ligneDeChiffres(Donnees.lines[LigneCourante]) then begin
             ExtraitValeur(constante,LigneCourante,NbreConst+NbrePrecConst);
             inc(ligneCourante);
     end;
     while ligneCourante<Donnees.lines.count do
           if not ExtraitIncert(ligneCourante)
              and not ExtraitVariableTexte(ligneCourante)
                   then inc(ligneCourante);
     result := true;
end; // GetDataReg

Function TFichierRegressi.AjouteData : integer;
var i : integer;
    NbreVariabLu : integer;

Function ChercheVariab : boolean;
var i,j,k,kc : integer;
    libre : boolean;
 { TODO : Vérifier les doublons de nom }
begin
  NbreVariabAlire := NbreVariabExp+NbreVariabTexte;
  NbreVariabLu := 0;
  for i := 0 to MaxGrandeurs do DecodeVariab[i] := grandeurInconnue;
  for i := 0 to pred(listeNom.count) do begin
        k := indexNom(listeNom[i]);
        if k<>grandeurInconnue
          then begin
             inc(NbreVariabLu);
             DecodeVariab[i] := k;
          end
          else if (pos('sigma_',listeNom[i])<>1)
               then inc(NbreVariabLu);
  end;
  for i := 0 to pred(listeNom.count) do begin
        k := indexNom(listeNom[i]);
        if k=grandeurInconnue then begin  // else decodeVariab déjà affecté
             if pos('sigma_',listeNom[i])=1
                then begin
                    k := indexNom(copy(listeNom[i],7,length(listeNom[i])-6));
                    isPrecVariab[i] := k<>grandeurInconnue;
                    if isPrecVariab[i]
                       then begin
                           decodeVariab[i] := k;
                           inc(NbrePrecVariab); // decodeVariab non nécessaire
                       end;
                       // else à faire
                end
                else begin
                     kc := 0;
                     repeat
                        libre := true;
                        for j := 0 to pred(NbreVariabLu) do
                            if decodeVariab[j]=kc then begin // déjà pris
                               repeat
                                  inc(kc)
                               until ((grandeurs[kc].fonct.genreC=g_experimentale) and
                                      (grandeurs[kc].genreG=variable)) or
                                     (kc=pred(NbreGrandeurs));
                               libre := false;
                               break;
                            end;
                      until libre or (kc=pred(NbreGrandeurs));
                      if libre and
                        (grandeurs[kc].fonct.genreC=g_experimentale) and
                        (grandeurs[kc].genreG=variable) then DecodeVariab[i] := kc;
               end;
        end;
  end;
  if (NbreVariabAlire<NbreVariabLu) then begin
     for i := pred(NbreVariabAlire) downto NbreVariabLu do
         decodeVariab[i] := indexVariabExp[i]; // à améliorer
  end;
  result := true;
end; // ChercheVariab

procedure AjouteConstante;
var NbreConstCB : integer;

Procedure extraitUniteConst(const contenu : string);
var j,debut,long : integer;
    k,c : integer;
begin
    j := 1;
    c := 0;
    Repeat
        debut := j;
        k := decodeConst[c];
        while (j<=length(contenu)) and
              (contenu[j]<>crTab) do inc(j);
        long := j-debut;
        if long>0 then begin
           Grandeurs[k].NomUnite := copy(contenu,debut,long);
           if pos('°',Grandeurs[k].nomUnite)>0 then AngleEnDegre := true;
           if pos('rad',Grandeurs[k].nomUnite)>0 then AngleEnDegre := false;
        end;
        inc(c);
        inc(j); { saute Tab }
     Until (j>length(contenu)) or (k>=NbreConstCB);
end;

Procedure affecteNomConst;
var j,jmax : integer;
begin
    extraitNom(Donnees.lines[i],listeNom,listeUnite,true);
    if NbreConstExp>listeNom.count
       then jmax := listeNom.count
       else jmax := NbreConstExp;
    for j := 0 to pred(jmax) do
        decodeConst[j] := IndexNom(listeNom[j]);
    for j := jmax to pred(listeNom.count) do begin
        decodeConst[j] := AjouteExperimentale(listeNom[j],constante);
        grandeurs[decodeConst[j]].nomUnite := listeUnite[j];
    end;
    NbreConstCB := listeNom.count;
end;

Procedure extraitCommConst(const contenu : string);
var j,debut,long : integer;
    k,c : integer;
begin
    j := 1;
    c := 0;
    Repeat
        k := decodeConst[c];
        debut := j;
        while (j<=length(contenu)) and
              (contenu[j]<>crTab) do inc(j);
        long := j-debut;
        if long>0 then begin
           Fvaleurs.Memo.Lines.Add(''''+grandeurs[k].nom+'='+
                        copy(contenu,debut,long));
           grandeurs[k].fonct.expression := copy(contenu,debut,long);
        end;
        inc(c);
        inc(j);
     Until (j>=length(contenu)) or (k>=NbreConstCB);
end;

begin // AjouteConstante
     while (i<Donnees.lines.count) and
           LigneVide(Donnees.lines[i]) do inc(i);
     if (i>=Donnees.lines.count) or
         (Donnees.lines[i][1]=symbReg2) then exit;
     affecteNomConst;
     inc(i);
     if (i>=Donnees.lines.count) or
        (Donnees.lines[i][1]=symbReg2) then exit;
     extraitUniteConst(Donnees.lines[i]);
     inc(i);
     if (i>=Donnees.lines.count) or
         (Donnees.lines[i][1]=symbReg2) then exit;
     if not LigneDeChiffres(Donnees.lines[i]) then begin
        extraitCommConst(Donnees.lines[i]);
        inc(i);
     end;
     if (i>=Donnees.lines.count) or
        (Donnees.lines[i][1]=symbReg2) then exit;
     ExtraitValeur(constante,i,NbreConstExp);
     inc(i);
end; // AjouteConstante

Procedure AjouteValeur;
var s : string;
begin
     while (i<Donnees.lines.count) and
           ExtraitValeur(variable,i,NbreVariabAlire)
        do inc(i);
     AjouteConstante;
     while i<Donnees.lines.count do begin
         s := Donnees.lines[i];
         if (length(s)>1) and (s[1]=symbReg2)
               then if not ExtraitIncert(i) and
                       not ExtraitVariableTexte(i)
                            then inc(i)
                            else
               else inc(i);
     end;
     Pages[pageCourante].modifiedP := true;
end; // AjouteValeur

var Contenu,Comm : string;
    LigneNom,Fini : boolean;
    j,k : integer;
    FinContenu : string;
    DataSuppl,dataOK : boolean;
begin // AjouteData
     for i := 0 to MaxGrandeurs do begin
         DecodeVariab[i] := indexVariabExp[i];
         isPrecVariab[i] := false;
         NbrePrecVariab := 0;
         DecodeConst[i] := indexConstExp[i];
         isPrecConst[i] := false;
         NbrePrecConst := 0;
     end;
     i := 0;
     result := idCancel;
     chercheTab;
     listeNom.clear;
     listeUnite.clear;
     LigneNom := true;
     Fini := false;
     Comm := '';
     if avecTab=sTab then while (i<Donnees.lines.count) and not fini do begin
        Contenu := Donnees.lines[i];
        if Length(contenu)>4
           then FinContenu := AnsiUppercase(copy(contenu,length(contenu)-3,4))
           else FinContenu := '';
        fini := pos(crTab,Contenu)<>0;
        if not fini then begin
              if FinContenu='.EXE'
                 then
                 else comm := comm+Contenu;
              inc(i);
        end;
     end; // Tabulation trouvée
     fini := false;
     NbreVariabAlire := NbreVariabExp+NbreVariabTexte;
     while (i<Donnees.lines.count) and not fini do begin
        Contenu := Donnees.lines[i];
        Fini := LigneDeChiffres(Contenu);
        if not Fini and LigneNom and (length(Contenu)>2) then begin
               extraitNom(Contenu,listeNom,listeUnite,false);
            { TODO : vérifier listeNom.count<=nbrevariab }
               dataOK := true;
               for j := 0 to pred(listeNom.count) do begin
                   k := indexVariabExp[j];
                   if k<NbreGrandeurs then dataOK := dataOK and (listeNom[j]=grandeurs[k].nom);
                               { TODO : sigma_ }
               end;
               if dataOK then begin
                  result := idOK;
                  NbreVariabLu := listeNom.count;
               end;
               if result<>idOK then if chercheVariab
                   then result := idOK
                   else begin
                      result := idYes;
                      exit;
                   end;
               DataSuppl := NbreVariabLu>NbreVariabAlire;
               if NbreVariabLu<>NbreVariabAlire then begin
               end;
               if result<>idOK then exit;
               if DataSuppl then begin
                  for j := 0 to pred(listeNom.count) do
                      if DecodeVariab[j]=grandeurInconnue then begin
                         isPrecVariab[j] := pos('sigma_',listeNom[j])=1;
                         if isPrecVariab[j] then begin
                            k := indexNom(copy(listeNom[j],7,length(listeNom[j])-6));
                            isPrecVariab[j] := k<>grandeurInconnue;
                            DecodeVariab[j] := k;
                            inc(NbrePrecVariab);
                         end;
                         if not isPrecVariab[j]
                            then DecodeVariab[j] := AjouteExperimentale(listeNom[j],variable);
                      end;
                  NbreVariabAlire := NbreVariabExp+NbreVariabTexte;
               end;
               for k := 0 to pred(NbreVariabExp) do
                   if DecodeVariab[k]=grandeurInconnue then DecodeVariab[k] := indexVariabExp[k];
               LigneNom := false;
        end;
        if Fini
           then begin
                NbreVariabLu := 0;
                repeat inc(NbreVariabLu)
                until DecodeVariab[NbreVariabLu]=grandeurInconnue;
                dec(NbreVariabLu);
           end
           else inc(i);
     end;
     if i=Donnees.lines.count then begin // pas d'en tête ?
        i := 0;
        while (i<Donnees.lines.count) and
              not ligneDeChiffres(donnees.lines[i]) do inc(i);
        if i=Donnees.lines.count then exit;
     end;
     if not ajoutePage then exit;
     Pages[pageCourante].commentaireP := Comm;
     ajouteValeur;
     if Pages[PageCourante].nmes=0
        then supprimePage(pageCourante,false)
        else begin
             pages[pageCourante].recalculP;
             lecturePage := false;
             ModifFichier := true;
             result := idOK;
        end;
end; // AjouteData

procedure TFichierRegressi.EcritWin(NomFichier : string);

Procedure EcritPage(page : integer);
var i,j : LongInt;
    ivar : integer;
    ligneVide : boolean;
    chaine : string;
begin with pages[page] do begin
    ecritSection(1,'PAGE COMMENT');
    ecritLigneRW3U(commentaireP);
    ligneVide := true;
    while (nmes>0) and ligneVide do begin
       for i := 0 to pred(NbreVariabExp) do
           ligneVide := ligneVide and isNan(valeurVar[indexVariabExp[i],pred(nmes)]);
       if ligneVide then nmes := nmes-1;
    end;
    if nmes>0 then begin
       ecritSousSection(nmes,'VALEUR VAR');
       for j := 0 to pred(nmes) do begin
           chaine := '';
           for i := 0 to pred(NbreVariabExp) do
               chaine := chaine+FloatToStr(valeurVar[indexVariabExp[i],j])+' ';
           ecritLigneRW3(chaine);
       end; { for j }
       if NbreVariabTexte>0 then begin
          ecritSousSection(Nmes,'TEXTE VAR');
          for i := 0 to pred(NbreVariabTexte) do begin
              ivar := indexVariabTexte[i];
              for j := 0 to pred(nmes) do
                    ecritLigneRW3U(texteVar[iVar,j]);
          end;
       end;
       ligneVide := false;
       for i := 0 to pred(NbreVariabExp) do
           if isIncertitudeDefinie(indexVariabExp[i]) then begin
              ligneVide := true;
              break;
           end;
       if ligneVide or (nmes<128) then begin
          ecritSousSection(Nmes,'INCERT VAR');
          for j := 0 to pred(nmes) do begin
              chaine := '';
              for i := 0 to pred(NbreVariabExp) do
                  if IncertVar[indexVariabExp[i]]=nil
                     then chaine := chaine+'0 '
                     else chaine := chaine+floatToStr(IncertVar[indexVariabExp[i],j])+' ';
             ecritLigneRW3(chaine);
          end; //for j
       end;
    end;// Nmes>0
    if NbreConstExp>0 then begin
       ecritSousSection(NbreConstExp,'VALEUR CONST');
       for i := 0 to pred(NbreConstExp) do
               ecritFloatRW3(ValeurConst[indexConstExp[i]]);
       ecritSousSection(NbreConstExp,'INCERT CONST');
       for i := 0 to pred(NbreConstExp) do
           ecritFloatRW3(incertConst[indexConstExp[i]]);
    end;
    if NbreConstTexte>0 then begin
       ecritSousSection(NbreConstTexte,'TEXTE CONST');
       for i := 0 to pred(NbreConstTexte) do
           ecritLigneRW3U(TexteConst[indexConstTexte[i]]);
    end;
    ecritSousSection(2,'OPTIONS');
    ecritIntegerRW3(ord(active));
    ecritIntegerRW3(ord(true));
    if stat.StatOK then with stat do begin
       ecritSousSection(Nbre,'VALEUR STAT');
       for i := 0 to pred(Nbre) do
           ecritFloatRW3(Donnees[i]);
    end;
    if debutFFT>0 then begin
       ecritSousSection(2,'BORNES FFT');
       ecritIntegerRW3(debutFFT);
       ecritIntegerRW3(finFFT);
    end;
    if NbreParam>0 then begin
       ecritSousSection(NbreParam,'VALEUR PARAM');
       for i := 1 to NbreParam do
           ecritFloatRW3(valeurParam[i]);
       ecritSousSection(NbreParam,'INCERT PARAM');
       for i := 1 to NbreParam do
           ecritFloatRW3(incertParam[i]);
       ecritSousSection(NbreParam,'STDEV PARAM');
       for i := 1 to NbreParam do
           ecritFloatRW3(ecartTypeParam[i]);
    end;
    if NbreModele>0 then begin
       ecritSousSection(NbreModele,'DEBUT');
       for i := 1 to NbreModele do ecritIntegerRW3(debut[i]);
       ecritSousSection(NbreModele,'FIN');
       for i := 1 to NbreModele do ecritIntegerRW3(fin[i]);
    end;
end end; // ecritPage

Procedure ecritEnTete;

Procedure EcritMemoExpressions;
var i,posR : integer;
    nom : string;
begin
   if Fvaleurs.Memo.lines.count>0 then begin
      ecritSection(Fvaleurs.Memo.lines.count,'MEMO GRANDEURS');
      for i := 0 to pred(Fvaleurs.Memo.lines.count) do begin
          nom := Fvaleurs.Memo.lines[i];
          posR := pos(reperageConstGlb,nom);
          if posR>0 then nom := copy(nom,1,pred(posR));
          ecritLigneRW3U(nom);
      end;
   end;
end;

Procedure EcritStrList(M : TstringList;nom : string);
var i : integer;
begin
   if M.count>0 then begin
      ecritSection(M.count,nom);
      for i := 0 to pred(M.count) do
          ecritLigneRW3U(M[i])
   end;
end;

var i : integer;
    mecaOK, avecIncert : boolean;
begin // ecritEnTete
   ecritLigneRW3('EVARISTE REGRESSI WINDOWS 1.0');
   ecritSection(NbreVariab,'NOM VAR');
   for i := 0 to pred(NbreVariab) do
       ecritLigneRW3U(grandeurs[indexVariab[i]].nom);
   ecritSection(NbreVariab,'GENRE VAR');
   for i := 0 to pred(NbreVariab) do
       ecritIntegerRW3(ord(grandeurs[indexVariab[i]].fonct.genreC));
   ecritSection(NbreVariab,'UNITE VAR');
   for i := 0 to pred(NbreVariab) do
       if grandeurs[indexVariab[i]].UniteDonnee
          then ecritLigneRW3U(grandeurs[indexVariab[i]].nomUnite)
          else ecritLigneRW3('');
   if indexTri<>0 then begin
      ecritSection(1,'GrandeurTri');
      ecritLigneRW3U(nomGrandeurTri);
   end;
   ecritSection(NbreVariab,'FORMAT VAR');
   for i := 0 to pred(NbreVariab) do
       ecritIntegerRW3(ord(grandeurs[indexVariab[i]].formatU));
   mecaOK := false;
   for i := 0 to pred(NbreVariab) do
       if grandeurs[indexVariab[i]].affSignif then begin
           mecaOK := true;
           break;
       end;
   if mecaOK then begin
      ecritSection(NbreVariab,'AFF VAR');
      for i := 0 to pred(NbreVariab) do
          ecritIntegerRW3(ord(grandeurs[indexVariab[i]].affSignif));
   end;
   ecritSection(NbreVariab,'PRECISION VAR');
   for i := 0 to pred(NbreVariab) do
       ecritIntegerRW3(ord(grandeurs[indexVariab[i]].precisionU));
   mecaOK := false;
   for i := 0 to pred(NbreVariab) do with grandeurs[indexVariab[i]] do
       if genreMecanique<>gm_position then begin
              mecaOK := true;
              break;
       end;
   if mecaOK then begin
      ecritSection(NbreVariab,'MECA VAR');
      for i := 0 to pred(NbreVariab) do with grandeurs[indexVariab[i]] do
          if genreMecanique=gm_position
             then ecritIntegerRW3(ord(gm_position))
             else ecritLigneRW3U(intTostr(ord(genreMecanique))+' '+nomvarPosition);
   end;
   ecritSection(NbreVariabExp,'SIGNIF VAR');
   for i := 0 to pred(NbreVariabExp) do
       ecritLigneRW3U(grandeurs[indexVariabExp[i]].fonct.expression);
   avecIncert := false;
   for i := 0 to pred(NbreVariabExp) do with grandeurs[indexVariabExp[i]] do
       if grandeurs[indexVariabExp[i]].IncertCalc.expression<>'' then begin
              avecIncert := true;
              break;
       end;
   if avecIncert then begin
      ecritSection(NbreVariabExp,'INCERTITUDE');
      for i := 0 to pred(NbreVariabExp) do
          ecritLigneRW3(grandeurs[indexVariabExp[i]].IncertCalc.expression);
   end;
   if NbreConstExp>0 then begin
      ecritSection(NbreConstExp,'NOM CONST');
      for i := 0 to pred(NbreConstExp) do
          ecritLigneRW3U(grandeurs[indexConstExp[i]].nom);
      ecritSection(NbreConstExp,'UNITE CONST');
      for i := 0 to pred(NbreConstExp) do
          ecritLigneRW3U(grandeurs[indexConstExp[i]].nomUnite);
      ecritSection(NbreConstExp,'SIGNIF CONST');
      for i := 0 to pred(NbreConstExp) do
          ecritLigneRW3U(grandeurs[indexConstExp[i]].fonct.expression);
      ecritSection(NbreConstExp,'FORMAT CONST');
      for i := 0 to pred(NbreConstExp) do
          ecritIntegerRW3(ord(grandeurs[indexConstExp[i]].formatU));
      ecritSection(NbreConstExp,'PRECISION CONST');
      for i := 0 to pred(NbreConstExp) do
          ecritIntegerRW3(ord(grandeurs[indexConstExp[i]].precisionU));
      ecritSection(NbreConstExp,'AFF CONST');
      for i := 0 to pred(NbreConstExp) do
          ecritIntegerRW3(ord(grandeurs[indexConstExp[i]].AffSignif));
      avecIncert := false;
      for i := 0 to pred(NbreConstExp) do with grandeurs[indexConstExp[i]] do
            if (IncertCalc.expression<>'') then begin
              avecIncert := true;
              break;
            end;
      if avecIncert then begin
          ecritSection(NbreConstExp,'INCERT CONST');
          for i := 0 to pred(NbreConstExp) do
              ecritLigneRW3(grandeurs[indexConstExp[i]].IncertCalc.expression);
      end;
   end;
   if NbreConstTexte>0 then begin
      ecritSection(NbreConstTexte,'NOM TC');
      for i := 0 to pred(NbreConstTexte) do
          ecritLigneRW3U(grandeurs[indexConstTexte[i]].nom);
      ecritSection(NbreConstTexte,'SIGNIF TC');
      for i := 0 to pred(NbreConstTexte) do
          ecritLigneRW3U(grandeurs[indexConstTexte[i]].fonct.expression);
   end;
   if NbreParam>0 then begin
      ecritSection(NbreParam,'NOM PARAM');
      for i := 1 to NbreParam do
          ecritLigneRW3U(parametres[i].nom);
      ecritSection(NbreParam,'UNITE PARAM');
      for i := 1 to NbreParam do
          ecritLigneRW3U(parametres[i].nomUnite);
   end;
   if ModeAcquisition=AcqSimulation then begin
      ecritSection(1,'LOGBOX');
      ecritIntegerRW3(ord(Fvaleurs.logBox.isChecked));
   end;
   ecritSection(1,'TRIGO');
   ecritIntegerRW3(ord(AngleEnDegre));
   if traceEllipse then begin
      ecritSection(1,'CHI2');
      ecritIntegerRW3(ord(true));
   end;
   if FichierTrie then begin
      ecritSection(1,'TRIDATA');
      ecritIntegerRW3(ord(FichierTrie));
   end;
   ecritMemoExpressions;
   ecritStrList(TexteModele,'MODELISATION');
   ecritSection(2,'ACQUISITION');
   ecritLigneRW3(NomModeAcq[ModeAcquisition]);
   ecritLigneRW3('');
end; // ecritEnTete

Procedure ecritFenetres;
begin
         if FgrapheFFT<>nil then begin
            ecritSection(0,'FOURIER');
            FgrapheFFT.ecritConfig;
         end;
         if graphe<>nil then begin
            ecritSection(0,'GRAPHE VAR');
            graphe.ecritConfig;
         end;
         if statOptDlg<>nil then begin
            ecritSection(0,'STATISTIQUE');
            statOptDlg.ecritConfig;
         end;
end;// ecritFenetres

//  EcritWin
var page : integer;
begin
     NomFichier := changeFileExt(NomFichier,'.rw3');
     FichierRW3 := TStringList.create;
     try
     ecritEnTete;
     ecritFenetres;
     for page := 1 to NbrePages do ecritPage(page);
     modifFichier := false;
     except
         AfficheErreur(erWriteFile,0);
     end;
     FichierRW3.saveToFile(nomFichierTampon);
     Convert_RMac_to_RW3(NomFichierTampon,NomFichier);
     FichierRW3.free;
end; // ecritWin

function TFichierRegressi.LitWin : boolean;
var valeurs : TStringList;

procedure litPage;
var ligneWinaLire : boolean;

Procedure litValeur(imax : LongInt);
var i,j,nmesC : LongInt;
    tousNan : boolean;
begin with pages[pageCourante] do begin
    nmes := imax;
    nmesC := 0;
    try
    for j:=0 to pred(nmes) do begin
        litLigneWin;
        valeurs.clear;
        valeurs.delimitedText := ligneWin;
        for i := 0 to pred(NbreVariabExp) do
            valeurVar[i,j] := strToFloatWin(valeurs[i]);
        nmesC := j+1;
    end;
    except
        nmes := nmesC;
        repeat
           litLigneWin; // trop tard on a déjà mangé le $2
        until finFichierWin or
              (Length(LigneWin)=0) or
              charinset(ligneWin[1],[symbReg2,symbReg]);
        ligneWinAlire := (Length(LigneWin)>0) and
                         not charInSet(ligneWin[1],[symbReg2,symbReg]);
    end;
    while (nmes>0) and (NbreVariabExp>0) do begin
        tousNan := true;
        for i := 0 to pred(NbreVariabExp) do
            if not isNan(valeurVar[i,pred(nmes)]) then begin
               tousNan := false;
               break;
            end;
        if tousNan
           then nmes := nmes-1
           else break;
    end;
end end;

Procedure litIncertVariab(imax : integer);
var i,j,jmax : integer;
begin with pages[pageCourante] do begin
    if imax>nmes
       then jmax := nmes
       else jmax := imax;
    try
    for j := 0 to pred(jmax) do begin
        litLigneWin;
        valeurs.clear;
        valeurs.delimitedText := ligneWin;
        for i := 0 to pred(NbreVariabExp) do begin
            incertVar[i,j] := strToFloatWin(valeurs[i]);
        end;
    end;
    for j := jmax to pred(imax) do litLigneWin;
    except
    end;
end end;

var i,j,imax,choix,iVar : integer;
begin // litPage
   if ajoutePage then with pages[pageCourante] do begin
      commentaireP := ligneWin;
      litLigneWin;
      while (Length(LigneWin)>0) and (ligneWin[1]=symbReg2) do begin
        imax := NbreLigneWin(ligneWin);
        choix := 0;
        if pos('VALEUR',ligneWin)<>0 then begin
           if pos('VAR',ligneWin)<>0 then choix := 1 else
              if pos('CONST',ligneWin)<>0 then choix := 2 else
              if pos('PARAM',ligneWin)<>0 then choix := 3 else
              if pos('STAT',ligneWin)<>0 then choix := 6;
        end else
        if pos('DEBUT',ligneWin)<>0 then choix := 10 else
        if pos('FIN',ligneWin)<>0 then choix := 11 else
        if pos('OPTIONS',ligneWin)<>0 then choix := 13 else
        if pos('INCERT',ligneWin)<>0 then begin
           if pos('VAR',ligneWin)<>0 then choix := 14 else
           if pos('CONST',ligneWin)<>0 then choix := 15 else
           if pos('GLB',ligneWin)<>0 then choix := 23 else
           if pos('PARAM',ligneWin)<>0 then choix := 20;
        end else
        if pos('STDEV',ligneWin)<>0 then begin
           if pos('PARAM',ligneWin)<>0 then choix := 21;
        end else
        if pos('ORIGINE TEMPS',ligneWin)<>0 then choix := 17 else
        if pos('TEXTE',ligneWin)<>0 then begin
           if pos('VAR',ligneWin)<>0 then choix := 18 else
           if pos('CONST',ligneWin)<>0 then choix := 19;
        end else
        if (pos('BORNES FFT',ligneWin)<>0) and (imax=2) then choix := 25;
        ligneWinalire := true;
        case choix of
             0 : for i := 1 to imax do litLigneWin;
             1 : litValeur(imax);
             2 : for i := 0 to pred(imax) do begin
                 j := indexConstExp[i];
                 try
                 if j=grandeurInconnue
                    then litLigneWin
                    else ValeurConst[j] := litFloatRW3;
                 except
                     ValeurConst[j] := 0;
                 end;
             end;
             3 : for i := 1 to imax do valeurParam[i] := litFloatRW3;
             6 : with stat do begin
                 Nbre := imax;
                 StatOK := true;
                 for i := 0 to pred(imax) do
                     Donnees[i] := litFloatRW3;
             end;
             10 : for i := 1 to imax do debut[i] := litIntegerRW3;
             11 : for i := 1 to imax do fin[i] := litIntegerRW3;
             13 : begin
                active := litBooleanRW3;
                litBooleanRW3; // experimentale
             end;
             14 : litIncertVariab(imax);
             15 : for i := 0 to pred(imax) do begin
                 j := indexConstExp[i];
                 if j=grandeurInconnue
                    then litLigneWin
                    else incertConst[j] := litFloatRW3;
             end;
             17 : litLigneWin;
             18 : for i := 0 to pred(NbreVariabTexte) do begin
                      iVar := indexVariabTexte[i];
                      for j := 0 to pred(nmes) do
                          texteVar[iVar,j] := litLigneWinU;
             end;
             19 : for i := 0 to pred(imax) do begin
                      j := indexConstTexte[i];
                      litLigneWinU;
                      if j<>grandeurInconnue then begin
                            texteConst[j] := ligneWin;
                            valeurConst[j] := 0;
                      end;
             end;
             20 : for i := 1 to imax do incertParam[i] := litFloatRW3;
             21 : for i := 1 to imax do ecartTypeParam[i] := litFloatRW3;
             23 : for i := 0 to pred(imax) do begin
                      j := indexConstGlb[i];
                      if j=grandeurInconnue
                        then litLigneWin
                        else grandeurs[j].incertCourante := litFloatRW3;
             end;
             25 : begin
                debutFFT := litIntegerRW3;
                finFFT := litIntegerRW3;
             end;
        end;
        if ligneWinaLire then litLigneWin;
     end;{while}
   end
   else litLigneWin;
   if ModeAcquisition=AcqSimulation then with pages[pageCourante] do begin
          MiniSimulation := valeurVar[0,0];
          MaxiSimulation := valeurVar[0,pred(nmes)];
          VerifMinMaxReal(MiniSimulation,MaxiSimulation);
          if MiniSimulation=MaxiSimulation then
             MaxiSimulation := MiniSimulation+1;
          valeurVar[0,pred(nmes)] := MaxiSimulation;
          MaxiSimulation := MaxiSimulation+(maxiSimulation-miniSimulation)/pred(nmes);
          valeurVar[0,0] := MiniSimulation;
   end;
end; // litPage

procedure litListe;

procedure litMemoGrandeurs(imax : integer);
var i : integer;
begin
     FValeurs.Memo.lines.Clear;
     for i := 1 to imax do begin
         Fvaleurs.Memo.lines.add(ligneWin);
         litLigneWinU;
     end;
     Fvaleurs.Memo.lines.Add('');
end;

procedure litNom(Agenre : TgenreGrandeur;imax : integer);
var i : integer;
begin
     for i := 1 to imax do begin
         AjouteExperimentale(ligneWin,Agenre);
         litLigneWinU
     end;
end;

procedure litNomConstTexte(imax : integer);
var i : integer;
    index : integer;
begin
     for i := 1 to imax do begin
         index := AjouteExperimentale(ligneWin,constante);
         grandeurs[index].fonct.genreC := g_texte;
         litLigneWinU
     end;
     construireIndex;
end;

procedure litNomParam(imax : integer;affecte : boolean);
var i : integer;
begin
     if affecte then NbreParam := imax;
     for i := 1 to imax do begin
         parametres[i].nom := ligneWin;
         litLigneWinU
     end;
end;

procedure litGenreVariab(Nbrei : integer);
var i,iTexte : integer;
    genre : TgenreCalcul;
begin
     iTexte := -1;
     for i := 0 to pred(Nbrei) do begin
         genre := TgenreCalcul(StrToInt(ligneWin));
         if genre<>g_experimentale then begin
            grandeurs[i].fonct.genreC := genre;
            dec(NbreVariabExp);
         end;
         if genre=g_texte then begin
            inc(NbreVariabTexte);
            iTexte := i;
         end;
         litLigneWin
     end;
     if (iTexte>0) and  (iTexte<NbreVariabExp) then begin
        transfereVariabE(iTexte,NbreVariabExp);
     // mettre g_texte à la fin
     end;
     construireIndex;
end;

procedure litUnite(iDebut,Nbrei : integer);
var i : integer;
begin
     for i := iDebut to pred(iDebut+Nbrei) do begin
         grandeurs[i].NomUnite := ligneWin;
         litLigneWinU
     end;
end;

procedure litAff(iDebut,Nbrei : integer);
var i : integer;
begin
     for i := iDebut to pred(iDebut+Nbrei) do begin
         grandeurs[i].affSignif := ligneWin<>'0';
         litLigneWin
     end;
end;

procedure litMeca(Nbre : integer);
var i : integer;
    k : integer;
begin
     for i := 0 to pred(Nbre) do with grandeurs[i] do begin
         k := strToInt(ligneWin[1]);
         genreMecanique := TgenreMecanique(k);
         if genreMecanique>gm_position then begin
            nomVarPosition := copy(ligneWin,3,length(ligneWin));
            k := indexNom(nomVarPosition);
            if k=grandeurInconnue then nomvarPosition := '';
         end;
         litLigneWin
     end;
end;

procedure litIncertConstGlb(imax : integer);
var i : integer;
begin
    try
    for i := 0 to pred(imax) do
        litLigneWin;
    except
    end;
end;

procedure litUniteParam(imax : integer);
var i : integer;
begin
     for i := 1 to imax do begin
         parametres[i].NomUnite := ligneWin;
         litLigneWinU
     end;
end;

procedure litSignif(iDebut,Nbrei : integer);
var i : integer;
begin
     for i := iDebut to pred(iDebut+Nbrei) do begin
         grandeurs[i].fonct.expression := ligneWin;
         litLigneWinU
     end;
end;

procedure litPrecision(iDebut,Nbrei : integer);
var i : integer;
begin
     for i := iDebut to pred(iDebut+Nbrei) do begin
         try
         grandeurs[i].precisionU := strToInt(ligneWin);
         except
         end;
         litLigneWin
     end;
end;

procedure litFormat(iDebut,Nbrei : integer);
var i : integer;
begin
     for i := iDebut to pred(iDebut+Nbrei) do begin
         grandeurs[i].formatU := TnombreFormat(strToInt(ligneWin));
         litLigneWin
     end;
end;

procedure litIncertitude(iDebut,Nbrei : integer);
var i : integer;
begin
     for i := iDebut to pred(iDebut+Nbrei) do begin
         grandeurs[i].IncertCalc.expression := ligneWin;
         litLigneWin
     end;
end;

Procedure litAcquisition(Nligne : byte);
var i : TmodeAcquisition;
    j : byte;
begin
   LigneWin := AnsiUpperCase(ligneWin);
   for i := low(TmodeAcquisition) to high(TmodeAcquisition) do
       if ligneWin=NomModeAcq[i] then begin
          ModeAcquisition := i;
          break;
       end;
   if Nligne>=2 then begin
      litLigneWin;
   end;
   for j := 3 to Nligne do litLigneWin;
   litLigneWin;
end;

procedure litStrList(T : TstringList;imax : integer);
var i : integer;
begin
     for i := 1 to imax do begin
         T.add(ligneWin);
         litLigneWinU;
     end;
end;

Procedure litChoix(choix : integer);
var i : integer;
    Nligne : integer;
begin
    Nligne := NbreLigneWin(ligneWin);
    litLigneWinU;
    case choix of
         0 : begin
            for i := 1 to Nligne do litLigneWin;
            while (Length(LigneWin)>0) and (ligneWin[1]=symbReg2) do begin
               Nligne := NbreLigneWin(ligneWin);
               for i := 0 to Nligne do litLigneWin;
            end;
         end;
         1 : litPage;
         2 : graphe.litConfig;
         3 : FgrapheFFT.litConfig;
         4 : litNom(variable,Nligne);
         5 : litNom(constante,Nligne);
         6 : litUnite(NbreVariab,Nligne);
         7 : litUnite(0,Nligne);
         8 : litIncertitude(0,Nligne);
         10 : LitMemoGrandeurs(Nligne);
         12 : LitStrList(TexteModele,Nligne);
         14 : LitAcquisition(Nligne);
         15 : begin
            if statOptDlg=nil then
                application.createForm(TstatOptDlg,statOptDlg);
            statOptDlg.litConfig;
         end;
         16 : litLigneWin;
         17 : begin
             AngleEnDegre := ligneWin<>'0';
             litLigneWin;
         end;
         18 : litGenreVariab(Nligne);
         19 : litSignif(NbreVariab,Nligne);
         20 : litSignif(0,Nligne);
         22 : litFormat(NbreVariab,Nligne);
         23 : litFormat(0,Nligne);
         24 : litPrecision(NbreVariab,Nligne);
         25 : litPrecision(0,Nligne);
         26 : litNomParam(Nligne,true);
         28 : litUniteParam(Nligne);
         30 : litNomParam(Nligne,false);
         31 : begin
             litLigneWin;
             litLigneWin;
         end;
         34 : litAff(NbreVariab,Nligne);
         35 : litAff(0,Nligne);
         36 : litMeca(Nligne);
         39 : litNomConstTexte(Nligne);
         40 : litSignif(NbreVariab+NbreConstExp,Nligne);
         42 : begin
             traceEllipse := ligneWin<>'0';
             litLigneWin;
         end;
         43 : begin
             nomGrandeurTri := ligneWin;
             litLigneWin;
         end;
         44 : begin
             FichierTrie := ligneWin<>'0';
             litLigneWin;
         end;
         49 : litNom(constanteGlb,Nligne);
         50 : begin
             Fvaleurs.logBox.isChecked := ligneWin<>'0';
             logSimulation := ligneWin<>'0';
             litLigneWinU;
         end;
         51 : litIncertitude(NbreVariab,Nligne);
         52 : litIncertConstGlb(Nligne);
   end;
end;

begin
    if ligneWin='PAGESINDEP' then ligneWin := 'CBPAGESINDEP';
    if Pos('PAGE',ligneWin)=4 then litChoix(1)
    else if Pos('GRAPHE',ligneWin)=4 then begin
       if Pos('CONST',ligneWin)<>0
          then litChoix(0)
          else litChoix(2);
    end
    else if Pos('FOURIER',ligneWin)=4 then litChoix(3)
    else if Pos('STATISTIQUE',ligneWin)=4 then litChoix(15)
    else if Pos('NOM',ligneWin)<>0 then begin
        if Pos('CONST',ligneWin)<>0 then litChoix(5)
        else if Pos('VAR',ligneWin)<>0 then litChoix(4)
        else if Pos('PARAM',ligneWin)<>0 then litChoix(26)
        else if Pos('SAUVE',ligneWin)<>0 then litChoix(30)
        else if Pos('TC',ligneWin)<>0 then litChoix(39) // texte const
        else litChoix(0)
    end
    else if (Pos('MECA',ligneWin)<>0) and
       (Pos('VAR',ligneWin)<>0) then litChoix(36)
    else if (Pos('GENRE',ligneWin)<>0) and
       (Pos('VAR',ligneWin)<>0) then litChoix(18)
    else if Pos('UNITE',ligneWin)<>0 then begin
       if Pos('CONST',ligneWin)<>0 then litChoix(6)
       else if Pos('VAR',ligneWin)<>0 then litChoix(7)
       else if Pos('PARAM',ligneWin)<>0 then litChoix(28);
    end
    else if Pos('FORMAT',ligneWin)<>0 then begin
       if Pos('CONST',ligneWin)<>0 then litChoix(22)
       else if Pos('VAR',ligneWin)<>0 then litChoix(23)
       else litChoix(0)
    end
    else if Pos('AFF',ligneWin)<>0 then begin
       if Pos('CONST',ligneWin)<>0 then litChoix(34)
       else if Pos('VAR',ligneWin)<>0 then litChoix(35)
       else litChoix(0)
    end
    else if Pos('PRECISION',ligneWin)<>0 then begin
       if Pos('CONST',ligneWin)<>0 then litChoix(24)
       else if Pos('VAR',ligneWin)<>0 then litChoix(25)
       else litChoix(0)
    end
    else if Pos('SIGNIF',ligneWin)<>0 then begin
       if Pos('CONST',ligneWin)<>0 then litChoix(19)
       else if Pos('VAR',ligneWin)<>0 then litChoix(20)
       else if Pos('TC',ligneWin)<>0 then litChoix(40) // texte const
       else litChoix(0)
    end
    else if Pos('INCERT',ligneWin)<>0 then begin
       if Pos('CONST',ligneWin)<>0 then litChoix(51)
       else if Pos('GLB',ligneWin)<>0 then litChoix(52)
       else if Pos('TUDE',ligneWin)<>0 then litChoix(8)
       else litChoix(0)
    end
    else if Pos('GRANDEURS',ligneWin)<>0 then begin
       if Pos('MEMO',ligneWin)<>0
          then litChoix(10)
          else litChoix(0)
    end
    else if Pos('MODELISATION',ligneWin)<>0 then litChoix(12)
    else if Pos('TRIGO',ligneWin)<>0 then litChoix(17)
    else if Pos('CHI2',ligneWin)<>0 then litChoix(42)
    else if Pos('TRIDATA',ligneWin)<>0 then litChoix(44)
    else if Pos('ACQUISITION',ligneWin)<>0 then litChoix(14)
    else if Pos('DATETIME',ligneWin)=4 then litChoix(31)
    else if pos('GrandeurTri',ligneWin)<>0 then litChoix(43)
    else if Pos('LOGBOX',ligneWin)=4 then litChoix(50)
    else litChoix(0)
end; // litListe

procedure litFichierRW3;
begin
     litLigneWin;
     FichierTrie := dataTrieGlb;
     while (Length(LigneWin)>0) and (ligneWin[1]=symbReg) do litListe;
     if pageCourante>0 then begin
        pages[pageCourante].affecteConstParam;
        pages[pageCourante].affecteVariableP(false);
     end;
end;

var i,j : integer;
    index : integer;
    trouve : boolean;
    p : codePage;
begin // LitFichierWin
     LectureFichier := true;
     result := false;
     codeErreurF := erFileData;
     ModeAcquisition := AcqClavier;
     Convert_RW3_to_Mac(NomFichierData,NomFichierTampon);
     fichierRW3 := TStringList.create;
     fichierRW3.loadFromFile(nomFichierTampon,TEncoding.Ansi);
     finFichierWin := false;
     valeurs := TStringList.create;
     valeurs.delimiter := ' ';
     try
     if not enTeteRW3 then begin
            afficheErreur(erFormat,0);
            fichierRW3.free;
            LectureFichier := false;
            exit
     end;
     litFichierRW3;
     for i := pred(NbreVariabTexte) downto 0 do begin
         index := indexVariabTexte[i];
         trouve := false;
         for p := 1 to NbrePages do
             trouve := trouve or (pages[p].FtexteVar[index]<>nil);
         if not trouve then begin
            grandeurs[index].fonct.genreC := g_forward;
            for j := succ(i) to pred(NbreVariabTexte) do
                indexVariabTexte[j-1] := indexVariabTexte[j];
            dec(NbreVariabTexte);
         end;
     end;
     result := pageCourante>0;
     except
         codeErreurF := erReadFile;
         result := false;
     end;
     fichierRW3.free;
     LectureFichier := false;
end; // LitWin

Procedure TFichierRegressi.AjouteWin(NomFichier : string);
var FichierOK : boolean;
    DecodeVariab,DecodeConst : array[codeGrandeur] of codeGrandeur;
    NomFichierCourt : string;
    NbreVariabFichier,NbreVariabExpFichier : integer;
    valeurs : TStringList;

procedure litGenreVariab(Nbrei : integer);
var i : integer;
    genre : TgenreCalcul;
begin
     NbreVariabExpFichier := 0;
     for i := 0 to pred(Nbrei) do begin
         litLigneWin;
         genre := TgenreCalcul(StrToInt(ligneWin));
         if genre=g_experimentale then begin
            inc(NbreVariabExpFichier);
         end;
     end;
     litLigneWin
end;

procedure litExpression(imax : integer);
var i,posEgal,k : integer;
    nom : string;
begin
    for i := 0 to pred(imax) do begin
        litLigneWinU;
        PosEgal := Pos('=',ligneWin);
        if PosEgal>0 then begin
           nom := copy(ligneWin,1,posEgal-1);
           PosEgal := Pos('[',ligneWin);
           if PosEgal>0 then
              nom := copy(nom,1,posEgal-1);
           PosEgal := Pos('''',ligneWin);
           if PosEgal>0 then
              nom := copy(nom,1,posEgal-1);
           k := indexNom(nom);
           if k=grandeurInconnue then
              Fvaleurs.Memo.lines.add(ligneWin);
        end
        else Fvaleurs.Memo.lines.add(ligneWin); // commentaire
    end;
    litLigneWin;
end;

procedure litPage;

Procedure litValeur(imax : integer);
var i,j : integer;
begin with pages[pageCourante] do begin
    if imax>MaxMaxVecteur
       then nmes := MaxMaxVecteur
       else nmes := imax;
    j := 0;
    try
    while j<nmes do begin
        valeurs.delimitedText := ligneWin;
        for i := 0 to pred(NbreVariabExpFichier) do
            valeurVar[decodeVariab[i],j] := StrToFloatWin(valeurs[i]);
        litLigneWin;
        inc(j);
    end;
    j := nmes;
    while j<imax do begin
        litLigneWin;
        inc(j);
    end;
    except
        nmes := j;
    end;
end end;

var i,j,imax,choix,iVar : integer;
begin
   if ajoutePage then with pages[pageCourante] do begin
      commentaireP := nomFichierCourt+ligneWin;
      litLigneWin;
      while (Length(LigneWin)>0) and (ligneWin[1]=symbReg2) do begin
        imax := NbreLigneWin(ligneWin);
        choix := 0;
        if pos('VALEUR',ligneWin)<>0 then begin
           if pos('VAR',ligneWin)<>0 then choix := 1 else
           if pos('CONST',ligneWin)<>0 then choix := 2 else
           if pos('PARAM',ligneWin)<>0 then choix := 5;
        end else
        if pos('TEXTE',ligneWin)<>0 then begin
           if pos('VAR',ligneWin)<>0 then choix := 3 else
           if pos('CONST',ligneWin)<>0 then choix := 4;
        end;
        case choix of
             0 : for i := 1 to imax do litLigneWin;
             1 : litValeur(imax);
             2 : for i := 0 to pred(imax) do begin
                 j := decodeConst[i];
                 if j=grandeurInconnue
                    then litLigneWin
                    else ValeurConst[j] := litFloatRW3;
             end;
             3 : for i := 0 to pred(NbreVariabTexte) do begin
                      iVar := indexVariabTexte[i];
                      for j := 0 to pred(imax) do
                          texteVar[iVar,j] := litLigneWinU;
             end;
             4 : for i := 0 to pred(imax) do begin
                     j := indexConstTexte[i];
                     litLigneWinU;
                     if j<>grandeurInconnue then
                        texteConst[j] := ligneWin;
             end;
             5 : for i := 1 to imax do valeurParam[i] := litFloatRW3;
        end;
        litLigneWin;
     end;
   end
   else litLigneWin
end; // litPage

Procedure litListe;

Procedure LitVariab(N : integer);
var i,k : integer;
    nomCourant : string;
begin
  NbreVariabFichier := N;
  NbreVariabExpFichier := N; // par défaut avant lecture du genre
  for i := 0 to pred(NbreVariabFichier) do begin
        nomCourant := litLigneWinU;
        k := indexNom(nomCourant);
        if (i<NbreVariabExp) and
           (k=grandeurInconnue)
              then k := AjouteExperimentale(NomCourant,variable);
        if (i<NbreVariabExp) and
           ((k=grandeurInconnue) or
            (grandeurs[k].fonct.genreC<>g_experimentale) or
            (grandeurs[k].genreG<>variable)) then begin
              afficheErreur(erFileAdd,0);
              FichierOK := false;
              exit;
        end;
        if (i<NbreVariabExp) then DecodeVariab[i] := k;
  end;
  litLigneWin;
end;

Procedure LitConst(NbreConstFichier : integer);
var i,k : integer;
begin
    for i := 0 to pred(NbreConstFichier) do begin
        litLigneWinU;
        k := indexNom(ligneWin);
        if k=grandeurInconnue then
           k := ajouteExperimentale(ligneWin, constante);
        decodeConst[i] := k;
        if (i<NbreConstExp) and
           ((k=grandeurInconnue) or
           ((grandeurs[k].fonct.genreC<>g_experimentale) or
            (grandeurs[k].genreG<>constante))) then begin
                 afficheErreur(erFileAdd,0);
                 FichierOK := false;
                 exit;
        end;
  end;
  litLigneWin;
end;

var
    Nligne,i : integer;
begin
    Nligne := NbreLigneWin(ligneWin);
    if pos('NOM CONST',ligneWin)<>0
        then LitConst(Nligne)
        else if pos('NOM VAR',ligneWin)<>0
        then LitVariab(Nligne)
        else if pos('GENRE VAR',ligneWin)<>0
        then LitGenreVariab(Nligne)
        else if pos('MEMO GRANDEURS',ligneWin)<>0
        then litExpression(Nligne)
        else if pos('PAGE',ligneWin)<>0
        then begin
            litLigneWin;
            litPage
        end
        else begin
           for i := 0 to Nligne do litLigneWin;
           while (Length(LigneWin)>0) and (ligneWin[1]=symbReg2) do begin
               Nligne := NbreLigneWin(ligneWin);
               for i := 0 to Nligne do litLigneWin;
            end;
       end;
end; // litListe

begin
     Convert_RW3_to_Mac(NomFichier, NomFichierTampon);
     FichierRW3 := TStringList.create;
     valeurs := TStringList.create;
     try
        FichierRW3.LoadFromFile(NomFichierTampon, TEncoding.Ansi);
        valeurs.delimiter := ' ';
        finFichierWin := false;
        if enTeteRW3
             then begin
                 litLigneWin;
                 nomFichierCourt := extractFileName(NomFichier)+' : ';
                 FichierOK := true;
                 while fichierOK and
                      (ligneWin<>'') and
                      (ligneWin[1]=symbReg) do litListe;
             end
             else AfficheErreur(erFormat,0);
     finally
        FichierRW3.free;
        valeurs.free;
     end;
end; // AjouteWin

// FileXML.pas : récupération des fichiers xml Regressi

procedure TFichierRegressi.EcritXML(const nomFichier : String);

procedure writePage(ANode : IXMLNOde;p : integer);
begin
    ANode.Attributes[stPage] := intToStr(p);
end;

procedure writeIndex(ANode : IXMLNOde;p : integer);
begin
    ANode.Attributes[stIndex] := intToStr(p);
end;

var i : integer;
    v : integer;
    p : codePage;
    dataCsv : TstringList;
    XmlDoc: TXMLDocument;
    Document: IXMLNode;
    Node1, Node2 : IXMLNode;
begin
     dataCsv := TstringList.create;
     dataCsv.StrictDelimiter := True;
     XMLDoc := TXMLDocument.Create(nil);
     XMLDoc.active := true;
     XMLDoc.Options := [doNodeAutoIndent];

  //   XMLDoc.ExternalEncoding := seUTF16LE;
  //   XMLDoc.Declaration.Encoding := 'UTF-16';
  //   XMLDoc.xmlFormat := xfReadable;
     XMLDoc.DocumentElement := XMLDoc.createElement('Regressi','');
     Document := XMLDoc.DocumentElement;

     Node1 := Document.addChild('SOURCE');
     WriteStringXML(Node1,'Logiciel','Regressi');
     WriteStringXML(Node1,'Version','3.05');
     WriteStringXML(Node1,'Acquisition',NomModeAcq[ModeAcquisition]);
     WriteDateTimeXML(Node1,'Date',now);
     WriteStringXML(Node1,'Copyright','Jean-Michel Millet');

     Node1 := Document.addChild('OPTIONS');
     WriteBoolXML(Node1,'Trigo',AngleEnDegre);
     WriteIntegerXML(Node1,'NbreDerivee',NbrePointDerivee);

     dataCsv.clear;
     for I := 0 to FValeurs.Memo.lines.Count - 1 do
         dataCsv.add(Fvaleurs.Memo.lines[i]);
     dataCsv.Delimiter := crCR;
     WriteStringXML(Document,'Memo',dataCsv.DelimitedText);
     for v := 0 to pred(NbreGrandeurs) do with grandeurs[v] do
     if fonct.genreC in [g_experimentale, g_texte] then begin
         case genreG of
              variable : Node1 := Document.addChild('VARIABLE');
              constante : Node1 := Document.addChild('CONSTANTE');
              else continue;
         end;
         Node1.Attributes[stNom] := nom;
         WriteStringXML(Node1,stUniteIni,nomUnite);
         WriteIntegerXML(Node1,'Precision',precisionU);
         WriteIntegerXML(Node1,'Format',ord(formatU));
         if affSignif then WriteBoolXML(Node1,'AffSignif',affSignif);
         if genreMecanique<>gm_position then begin
            WriteIntegerXML(Node1,'GenreMecanique',ord(genreMecanique));
            if nomVarPosition<>'' then
               WriteStringXML(Node1,'NomVarPosition',nomVarPosition);
         end;
         WriteIntegerXML(Node1,'GenreCalcul',ord(fonct.genreC));
         WriteStringXML(Node1,'Description',fonct.expression);
         if IncertCalc.expression<>'' then
            WriteStringXML(Node1,'Incertitude',IncertCalc.expression);
         if v=indexTri then WriteBoolXML(Node1,'Controle',true);
         for p := 1 to NbrePages do with pages[p] do begin
             case genreG of
                 variable : if fonct.genreC=g_texte
                    then begin
                         dataCsv.clear;
                         for i := 0 to pred(nmes) do
                             dataCsv.Add(TexteVar[v,i]);
                         dataCsv.Delimiter := crCR;
                         Node2 := writeStringXML(Node1,'Texte',dataCsv.delimitedText);
                         writePage(Node2,p);
                    end
                    else begin
                       dataCsv.clear;
                       for i := 0 to pred(nmes) do
                           dataCsv.Add(FloatToStrPoint(valeurVar[v,i]));
                       dataCsv.Delimiter := ' ';
                       Node2 := WriteStringXML(Node1,'Valeur',dataCsv.DelimitedText);
                       writePage(Node2,p);
                       if isIncertitudeDefinie(v) then begin
                          dataCsv.clear;
                          for i := 0 to pred(nmes) do
                              dataCsv.Add(FloatToStrPoint(incertVar[v,i]));
                          dataCsv.Delimiter := ' ';
                          Node2 := WriteStringXML(Node1,'ValIncert',dataCsv.DelimitedText);
                          writePage(Node2,p);
                       end;
                   end;
                 constante : if fonct.genreC=g_texte then begin
                     Node2 := WriteStringXML(Node1,'Texte',TexteConst[v]);
                     writePage(Node2,p);
                 end else begin
                     Node2 := WriteFloatXML(Node1,'Valeur',valeurConst[v]);
                     writePage(Node2,p);
                     if isIncertitudeDefinie(v) then begin
                        Node2 := WriteFloatXML(Node1,'ValIncert',incertConst[v]);
                        writePage(Node2,p);
                     end;
                 end;
             end;  // case
          end;  // for p
     end; // grandeur
     for p := 1 to NbrePages do with pages[p] do begin
         Node1 := Document.addChild('PAGE');
         writePage(Node1,p);
         if commentaireP<>'' then WriteStringXML(Node1,'Commentaire',commentaireP);
         WriteBoolXML(Node1,'Active',active);
         if (debutFFT>0) or (finFFT>0) then begin
            WriteIntegerXML(Node1,'DebutFFT',debutFFT);
            WriteIntegerXML(Node1,'FinFFT',finFFT);
         end;
         dataCsv.clear;
         for i := 0 to pred(nmes) do
             if not PointActif[i] then
                dataCsv.Add(IntToStr(i));
         if dataCsv.Count>0 then begin
            dataCsv.Delimiter := ' ';
            WriteStringXML(Node1,'PointsInactifs',dataCsv.DelimitedText);
         end;
     end;
     for v := 1 to NbreParam do begin
         Node1 := Document.addChild('PARAMETRE');
         writeIndex(Node1,v);
         Node1.Attributes[stNom] := parametres[v].nom;
         WriteStringXML(Node1,stUniteIni,parametres[v].nomUnite);
         for p := 1 to NbrePages do begin
             Node2 := WriteFloatXML(Node1,'Valeur',pages[p].valeurParam[v]);
             writePage(Node2,p);
         end;
         for p := 1 to NbrePages do begin
             Node2 := WriteFloatXML(Node1,'ValIncert',pages[p].incertParam[v]);
             writePage(Node2,p);
         end;
     end;
     for v := 1 to NbreParamGlb do begin
         Node1 := Document.addChild('PARAMGLB');
         writeIndex(Node1,v);
         Node1.Attributes[stNom] := parametresGlb[v].nom;
         WriteStringXML(Node1,stUniteIni,parametresGlb[v].nomUnite);
         Node2 := WriteFloatXML(Node1,'Valeur',parametresGlb[v].valCourante);
         writePage(Node2,1);
         Node2 := WriteFloatXML(Node1,'ValIncert',parametresGlb[v].incertCourante);
         writePage(Node2,1);
     end;
     if (NbreModele>0) or (TexteModele.count>0) then begin
        Node1 := Document.addChild('MODELE');
        TexteModele.StrictDelimiter := True;
        TexteModele.Delimiter := crCR;
        WriteStringXML(Node1,'Modelisation',TexteModele.delimitedText);
        for i := 1 to NbreModele do begin
            Node2 := writeColorXML(Node1,'COULEURMODELE',couleurModele[i]);
            writeIndex(Node2,i);
            for p := 1 to NbrePages do begin
                Node2 := writeIntegerXML(Node1,'DEBUT',pages[p].debut[i]);
                writeIndex(Node2,i);
                writePage(Node2,p);
                Node2 := writeIntegerXML(Node1,'FIN',pages[p].fin[i]);
                writeIndex(Node2,i);
                writePage(Node2,p);
            end;
        end;
        for i := 1 to NbreFonctionSuper do begin
            Node2 := writeColorXML(Node1,'COULEURMODELE',couleurModele[-i]);
            writeIndex(Node2,-i);
        end;
     end;
     for i := 0 to pred(NbreParamAnimation) do begin
         Node1 := Document.addChild('ANIMATION');
         writeIndex(Node1,i);
         ParamAnimation[i].ecritXML(Node1);
     end;
     Node1 := Document.AddChild('Graphe');
     Graphe.ecritConfigXML(Node1);
     if FgrapheFFT<>nil then begin
        Node1 := Document.AddChild('FOURIER');
        FgrapheFFT.ecritConfigXML(Node1);
     end;
     if grapheParam<>nil then begin
        Node1 := Document.AddChild('GrapheParam');
        grapheParam.ecritConfigXML(Node1);
     end;
     if statOptDlg<>nil then with statOptDlg do begin
        Node1 := Document.AddChild('STATISTIQUE');
        WriteStringXML(Node1,'NomStat',nomStat);
        WriteStringXML(Node1,'NomEffectif',nomEffectif);
        WriteBoolXML(Node1,'CourbeGauss',courbeGaussCB.IsChecked);
        WriteBoolXML(Node1,'Distribution',distributionCB.IsChecked);
        WriteIntegerXML(Node1,'ClasseGroupe',classeGroupe.itemIndex);
        WriteBoolXML(Node1,'CourbePoisson',courbePoissonCB.IsChecked);
        WriteBoolXML(Node1,'CourbeBinome',courbeBinomeCB.IsChecked);
     end;
     XMLDoc.saveToFile(NomFichier);
     dataCsv.free;
end; // EcritXML

function TFichierRegressi.LitXML(const NomFichier : String;nouveauFichier : boolean) : boolean;
var
    XmlDoc: TXmlDocument; // Xml document
    indexCourant : integer; // de la grandeur
    modeleCourant : integer;
    pageBase : integer;
    chaines : TStringList;

procedure LoadXMLInReg(XMLNode: IXMLNode);

Procedure ExtraitValeurs;
var i : integer;
    strValeur : string;
begin with pages[pageCourante] do begin
    chaines.Clear;
    chaines.Delimiter := ' ';
    chaines.DelimitedText := XMLNode.Text;
    nmes := chaines.Count;
    for i := 0 to chaines.Count-1 do begin
        strValeur := chaines[i];
        try
        valeurVar[indexCourant,i] := strToFloatWin(strValeur);
        except
        valeurVar[indexCourant,i] := Nan;
        end;
    end;
end end; // extraitValeurs

Procedure ExtraitIncertitudes;
var i : integer;
begin with pages[pageCourante] do begin
    chaines.Clear;
    chaines.Delimiter := ' ';
    chaines.DelimitedText := XMLNode.Text;
    if chaines.Count>nmes then nmes := chaines.Count;
    for i := 0 to chaines.Count-1 do begin
        try
        incertVar[indexCourant,i] := strToFloatWin(chaines[i]);
        except
        incertVar[indexCourant,i] := Nan;
        end;
    end;
end end; // extraitIncertitudes

Procedure ExtraitChaines;
begin
    chaines.Clear;
    chaines.Delimiter := crCR;
    chaines.DelimitedText := XMLNode.Text;
end; // extraitChaines

procedure EnsurePage(pAttr : integer);
begin
    if pAttr<=0 then pAttr := 1;
    pageCourante := pageBase + pAttr;
    while pageCourante>NbrePages do
       ajoutePageForce;
end;

procedure Suite;
var i: Integer;
begin
if XMLNode.HasChildNodes then
   for I := 0 to XMLNode.ChildNodes.Count - 1 do
       LoadXMLInReg(XMLNode.ChildNodes.Nodes[I]);
end;

var
I: Integer;
code, idxPt : integer;
nom : string;
ma : TmodeAcquisition;

begin //Les noeuds internes sont traitées récursivement

if XMLNode.NodeType <> ntElement then Exit;
//S'il s'agit d'une feuille

if (XmlNode.NodeName='Regressi') then begin
   suite;
   exit;
end;

if (XmlNode.NodeName='Memo') then begin
   extraitChaines;
   if nouveauFichier then
      Fvaleurs.Memo.Lines.Assign(chaines)
   else
      for i := 0 to chaines.Count-1 do
         if (chaines[i]<>'') and (Fvaleurs.Memo.Lines.IndexOf(chaines[i])<0) then
            Fvaleurs.Memo.Lines.Add(chaines[i]);
   exit;
end;

if (XmlNode.NodeName='Graphe') then begin
   if nouveauFichier and (Graphe<>nil) then Graphe.LitConfigXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='GrapheParam') or (XmlNode.NodeName='GrapheP') then begin
   if nouveauFichier and (GrapheParam<>nil) then GrapheParam.LitConfigXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='OPTIONS') then begin
   if nouveauFichier then suite;
   exit;
end;

if (XmlNode.NodeName='FOURIER') then begin
   if nouveauFichier and (FGrapheFFT<>nil) then FGrapheFFT.LitConfigXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='STATISTIQUE') then begin
   if nouveauFichier then begin
      if statOptDlg=nil then
         application.createForm(TstatOptDlg,statOptDlg);
      suite;
   end;
   exit;
end;

if (XmlNode.NodeName='NomStat') then begin
   if statOptDlg<>nil then statOptDlg.nomStat := XMLNode.Text;
   exit;
end;

if (XmlNode.NodeName='NomEffectif') then begin
   if statOptDlg<>nil then statOptDlg.nomEffectif := XMLNode.Text;
   exit;
end;

if (XmlNode.NodeName='CourbeGauss') then begin
   if statOptDlg<>nil then statOptDlg.courbeGaussCB.IsChecked := getBoolXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='Distribution') then begin
   if statOptDlg<>nil then statOptDlg.distributionCB.IsChecked := getBoolXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='ClasseGroupe') then begin
   if statOptDlg<>nil then statOptDlg.classeGroupe.itemIndex := getIntegerXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='CourbePoisson') then begin
   if statOptDlg<>nil then statOptDlg.courbePoissonCB.IsChecked := getBoolXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='CourbeBinome') then begin
   if statOptDlg<>nil then statOptDlg.courbeBinomeCB.IsChecked := getBoolXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='PAGE') then begin
   EnsurePage(getIntegerAttribute(XmlNode,stPage));
   suite;
   exit;
end;

if (XmlNode.NodeName='Commentaire') then begin
   if (pageCourante>0) and (pageCourante<=NbrePages) then
      pages[pageCourante].commentaireP := XMLNode.Text;
   exit;
end;

if (XmlNode.NodeName='Active') then begin
   if (pageCourante>0) and (pageCourante<=NbrePages) then
      pages[pageCourante].active := getBoolXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='DebutFFT') then begin
   if (pageCourante>0) and (pageCourante<=NbrePages) then
      pages[pageCourante].debutFFT := getIntegerXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='FinFFT') then begin
   if (pageCourante>0) and (pageCourante<=NbrePages) then
      pages[pageCourante].finFFT := getIntegerXML(XMLNode);
   exit;
end;

if (XmlNode.NodeName='PointsInactifs') then begin
   if (pageCourante>0) and (pageCourante<=NbrePages) then begin
      chaines.Clear;
      chaines.Delimiter := ' ';
      chaines.DelimitedText := XMLNode.Text;
      for i := 0 to chaines.Count-1 do
         if TryStrToInt(chaines[i], idxPt) and (idxPt>=0) and (idxPt<pages[pageCourante].nmes) then
            pages[pageCourante].PointActif[idxPt] := false;
   end;
   exit;
end;

if (XmlNode.NodeName='Modelisation') then begin
   if nouveauFichier then begin
      extraitChaines;
      TexteModele.Assign(chaines);
   end;
   exit;
end;

if (XmlNode.NodeName='Acquisition') then begin
   if nouveauFichier then begin
      nom := XMLNode.Text;
      for ma := low(TmodeAcquisition) to high(TmodeAcquisition) do
          if nom=NomModeAcq[ma] then begin
             ModeAcquisition := ma;
             break;
          end;
   end;
   exit;
end;

if (XMLNode.NodeName='Texte') then begin
   EnsurePage(getIntegerAttribute(XmlNode,stPage));
   case grandeurs[indexCourant].genreG of
      variable : begin
         extraitChaines;
         if chaines.Count>pages[pageCourante].nmes then
            pages[pageCourante].nmes := chaines.Count;
         for i := 0 to chaines.Count-1 do
             pages[pageCourante].TexteVar[indexCourant,i] := chaines[i];
      end;
      constante :
         pages[pageCourante].TexteConst[indexCourant] := XMLNode.Text;
   end;
   exit;
end;

if (XMLNode.NodeName='Valeur') then begin
   EnsurePage(getIntegerAttribute(XmlNode,stPage));
   case grandeurs[indexCourant].genreG of
      variable : if grandeurs[indexCourant].fonct.genreC=g_texte
                    then begin
                       extraitChaines;
                       if chaines.Count>pages[pageCourante].nmes then
                          pages[pageCourante].nmes := chaines.Count;
                       for i := 0 to chaines.Count-1 do
                           pages[pageCourante].TexteVar[indexCourant,i] := chaines[i];
                       exit;
                    end
                    else begin
                       ExtraitValeurs;
                    end;
      constante : begin
           pages[pageCourante].valeurConst[indexCourant] := getFloatXML(XmlNode);
           exit;
      end;
      paramNormal : begin
           code := indexToParam(indexCourant);
           pages[pageCourante].valeurParam[code] := getFloatXML(XmlNode);
           exit;
      end;
      paramGlb : begin
           grandeurs[indexCourant].valCourante := getFloatXML(XmlNode);
           exit;
      end;
   end;
end;

if (XMLNode.NodeName='ValIncert') then begin
   EnsurePage(getIntegerAttribute(XmlNode,stPage));
   case grandeurs[indexCourant].genreG of
      variable : ExtraitIncertitudes;
      constante : begin
           pages[pageCourante].incertConst[indexCourant] := getFloatXML(XMLNode);
           exit;
      end;
      paramNormal : begin
           code := indexToParam(indexCourant);
           pages[pageCourante].incertParam[code] := getFloatXML(XMLNode);
           exit;
      end;
      paramGlb : begin
           grandeurs[indexCourant].incertCourante := getFloatXML(XmlNode);
           exit;
      end;
   end;
end;

if (XmlNode.NodeName='VARIABLE') then begin
    nom := XmlNode.Attributes[stNom];
    if not nouveauFichier then
       indexCourant := indexNom(nom)
    else
       indexCourant := grandeurInconnue;
    if indexCourant=grandeurInconnue then
       indexCourant := AjouteExperimentale(nom,variable);
    suite;
    exit;
end;

if (XmlNode.NodeName='MODELE') then begin
    if nouveauFichier then suite;
    exit;
end;

if (XmlNode.NodeName='COULEURMODELE') then begin
    code := getIntegerAttribute(XmlNode,stIndex);
    if (code>=-MaxIntervalles) and (code<=MaxIntervalles) then
       couleurModele[code] := getColorXML(XmlNode);
    exit;
end;

if (XmlNode.NodeName='ANIMATION') then begin
    if nouveauFichier then begin
       code := getIntegerAttribute(XmlNode,stIndex);
       paramAnimation[code].litXML(XmlNode);
    end;
    exit;
end;

if (XmlNode.NodeName='DEBUT') then begin
    EnsurePage(getIntegerAttribute(XmlNode,stPage));
    modeleCourant := getIntegerAttribute(XmlNode,stIndex);
    if (pageCourante>0) and (modeleCourant<>0) then
    pages[pageCourante].debut[modeleCourant] := getIntegerXML(XmlNode);
    exit;
end;

if (XmlNode.NodeName='FIN') then begin
    EnsurePage(getIntegerAttribute(XmlNode,stPage));
    modeleCourant := getIntegerAttribute(XmlNode,stIndex);
    if (pageCourante>0) and (modeleCourant<>0) then
    pages[pageCourante].fin[modeleCourant] := getIntegerXML(xmlNode);
    exit;
end;

if (XmlNode.NodeName='CONSTANTE') then begin
    nom := XmlNode.Attributes[stNom];
    if not nouveauFichier then
       indexCourant := indexNom(nom)
    else
       indexCourant := grandeurInconnue;
    if indexCourant=grandeurInconnue then
       indexCourant := AjouteExperimentale(nom,constante);
    suite;
    exit;
end;

if (XmlNode.NodeName='PARAMETRE') then begin
    if not nouveauFichier then exit;
    nom := XmlNode.Attributes[stNom];
    indexCourant := GetIntegerAttribute(XmlNode,stIndex);
    parametres[indexCourant].nom := nom;
    if indexCourant>NbreParam then
       NbreParam := indexCourant;
    indexCourant := paramToIndex(indexCourant);
    suite;
    exit;
end;

if (XmlNode.NodeName='PARAMGLB') then begin
    if not nouveauFichier then exit;
    nom := XmlNode.Attributes[stNom];
    indexCourant := GetIntegerAttribute(XmlNode,stIndex);
    parametresGlb[indexCourant].nom := nom;
    if indexCourant>NbreParamGlb then
       NbreParamGlb := indexCourant;
    indexCourant := paramGlbToIndex(indexCourant);
    suite;
    exit;
end;

if (XmlNode.NodeName='Trigo') then begin
    AngleEnDegre := GetBoolXML(XmlNode);
    exit;
end;

if (XmlNode.NodeName='NbreDerivee') then begin
    NbrePointDerivee := GetIntegerXML(XmlNode);
    exit;
end;

if (XmlNode.NodeName='SOURCE') then begin
   if nouveauFichier then suite;
   exit;
end;

if (XMLNode.NodeName=stUniteIni) or (XMLNode.NodeName=stUnite) then begin
      grandeurs[indexCourant].nomUnite := XMLNode.Text;
      exit;
end;
if XMLNode.NodeName='GenreCalcul' then begin
      code := getIntegerXML(XmlNode);
      grandeurs[indexCourant].fonct.genreC := TGenreCalcul(code);
      exit;
end;
if XMLNode.NodeName='Precision' then begin
      grandeurs[indexCourant].precisionU := getIntegerXML(XmlNode);
      exit;
end;
if XMLNode.NodeName='Format' then begin
      code := getIntegerXML(XmlNode);
      if (code>=ord(low(TnombreFormat))) and (code<=ord(high(TnombreFormat))) then
         grandeurs[indexCourant].formatU := TnombreFormat(code);
      exit;
end;
if XMLNode.NodeName='AffSignif' then begin
      grandeurs[indexCourant].affSignif := getBoolXML(XmlNode);
      exit;
end;
if XMLNode.NodeName='GenreMecanique' then begin
      code := getIntegerXML(XmlNode);
      if (code>=ord(low(TgenreMecanique))) and (code<=ord(high(TgenreMecanique))) then
         grandeurs[indexCourant].genreMecanique := TgenreMecanique(code);
      exit;
end;
if XMLNode.NodeName='NomVarPosition' then begin
      grandeurs[indexCourant].nomVarPosition := XMLNode.Text;
      exit;
end;
if XMLNode.NodeName='Description' then begin
      grandeurs[indexCourant].fonct.expression := XMLNode.Text;
      exit;
end;
if XMLNode.NodeName='Incertitude' then begin
      grandeurs[indexCourant].incertCalc.expression := XMLNode.Text;
      exit;
end;

end; // LoadXMLInReg

procedure MajSimulation;
var p : integer;
begin
   for p := 1 to NbrePages do
   with pages[p] do if nmes>1 then begin
          MiniSimulation := valeurVar[0,0];
          MaxiSimulation := valeurVar[0,pred(nmes)];
          VerifMinMaxReal(MiniSimulation,MaxiSimulation);
          if MiniSimulation=MaxiSimulation then
             MaxiSimulation := MiniSimulation+1;
          valeurVar[0,pred(nmes)] := MaxiSimulation;
          MaxiSimulation := MaxiSimulation+(maxiSimulation-miniSimulation)/pred(nmes);
          valeurVar[0,0] := MiniSimulation;
   end;
end;

begin // LitXML
LectureFichier := true;
codeErreurF := erFileData;
if nouveauFichier then begin
   ModeAcquisition := AcqClavier;
   pageBase := 0;
end else
   pageBase := NbrePages;
chaines := TStringList.create;
chaines.StrictDelimiter := True;
chaines.Delimiter := crCR;
XMLDoc := TXMLDocument.Create(application.MainForm);
try
XmlDoc.FileName := NomFichier;
if (XmlDoc.DOMVendor=nil) and (DomVendors.count>0)
    then XmlDoc.DOMVendor := DomVendors.Vendors[0];
XMLDoc.Active := True;
if (XMLDoc.DocumentElement.NodeType=ntElement) and
   (XMLDoc.DocumentElement.NodeName='Regressi')
   then begin
      LoadXMLInReg(XMLDoc.DocumentElement);
      ConstruireIndex;
      result := true;
   end
   else begin
      result := false;
      codeErreurF := erReadFileRXML;
   end;
if nouveauFichier and (ModeAcquisition=AcqSimulation) then MajSimulation;
except
    codeErreurF := erReadFile;
    result := false;
    if nouveauFichier then resetEnTete;
end;
chaines.free;
LectureFichier := false;
end; // LitXML

(*
function TFichierRegressi.LitInfo(const NomFichier : String) : string;
var
    XmlDoc: TXmlDocument; // Xml document
    ANode : IXMLNode;
    dict : TDictionary<string,string>;

procedure XmlToDictionary(var dict : TDictionary<string, string>;baseElm : XMLElement);
var dictKey,dictString : string;
    elm : XMLelement;
begin
       dict = TDictionary<string, string>.create;
       for (elm in baseElm.Elements)
            begin
                dictKey = elm.Attribute(key).Value;
                dictVal = elm.Attribute(value).Value;
                dict.Add(dictKey, dictVal);
            end;
ènd;

begin // LitInfo
result := '';
XMLDoc := TXMLDocument.Create(application.MainForm);
try
XmlDoc.FileName := NomFichier;
if (XmlDoc.DOMVendor=nil) and (DomVendors.count>0)
    then XmlDoc.DOMVendor := DomVendors.Vendors[0];
XMLDoc.Active := True;
ANode := XMLDoc.DocumentElement.ChildNodes['dict'] ;
ANode := Anode.ChildNodes['CFBundleVersion'];
Anode := ANode.NextSibling;
result := ANode.NodeName;
finally
  result := '';
end;
end; // LitInfo

*)

Function TFichierRegressi.AjouteTableur(const NomFichier : string) : boolean;
var sauveModeAcq : TmodeAcquisition;
    NomFichierCourt : string;
    i : integer;
begin
     try
     Donnees.Lines.clear;
     LoadLinesSmart(Donnees.lines, NomFichier);
     for i := 0 to pred(Donnees.lines.Count) do
         Donnees.lines[i] := NettoieIMCCE(Donnees.lines[i]);
     lecturePage := true;
     case FichierRegressi.AjouteData of
         idYes : begin
            sauveModeAcq := modeAcquisition;
            nomFichierCourt := extractFileName(NomFichier)+' : ';
            result := FichierRegressi.litTableur(NomFichier);
            if result then pages[pageCourante].commentaireP :=
               nomFichierCourt+' : '+pages[pageCourante].commentaireP;
            modeAcquisition := sauveModeAcq;
         end;
         idOK : result := true;
         idCancel : result := false;
         else result := false;
     end;
     except
         result := false;
     end;
     lecturePage := false;
     donnees.lines.clear;
end; // AjouteTableur

Procedure TFichierRegressi.AjouteXML(const NomFichier : string);
begin
     if not LitXML(NomFichier,false) then
        AfficheErreur(codeErreurF,0);
end;

Function TFichierRegressi.LitPressePapier : boolean;
begin
     result := false;
     donnees.lines.clear;
     Donnees.PasteFromClipBoard;
     if GetDataReg then begin
         result := true;
         NomFichierData := '';
         ModeAcquisition := AcqClipBoard;
         ModifFichier := true;
     end;
     donnees.lines.clear;
end;

Function TFichierRegressi.AjoutePressePapier : boolean;
begin
     result := false;
     if pageCourante=0 then begin
        result := LitPressePapier;
        exit;
     end;
     donnees.lines.clear;
     Donnees.PasteFromClipBoard;
     LecturePage := true;
     case AjouteData of
        idOK : ;
        idYes : result := litPressePapier;
        idCancel : ;
     end;
     donnees.lines.Clear;
     LecturePage := false;
end; // AjoutePressePapier

constructor TFichierRegressi.Create;
begin
  donnees := TMemo.create(nil);
  ligneList := TStringList.Create;
  ligneList.strictDelimiter := true;
  listeNom := TstringList.Create;
  listeUnite := TstringList.Create;
end;

destructor TFichierRegressi.Destroy;
begin
  donnees.free;
  ligneList.free;
  listeNom.free;
  listeUnite.free;
end;

function TFichierRegressi.LitWav(Nom : String) : boolean;
var vecteurSon : TvecteurSon;
    dt : double;
    j,nbre,pasReg : integer;
begin
     vecteurSon := TvecteurSon.create;
     try
     vecteurSon.lit(Nom);
     if vecteurSon.nbrePoints>0 then begin
        pasReg := succ(vecteurSon.NbrePoints div MaxMaxVecteur);
        if pageCourante=0 then begin
          ajouteExperimentale('t',variable);
          grandeurs[0].nomUnite := 's';
          if vecteurSon.stereo then begin
             ajouteExperimentale('sD',variable);
             ajouteExperimentale('sG',variable);
          end
          else  ajouteExperimentale('s',variable);
        end;
        ajoutePage;
        dt := pasReg/vecteurSon.freqAudio;
        pages[pageCourante].commentaireP := 'Acquisition à fech='+IntToStr(round(1/pasReg/dt))+' Hz';
        nbre := vecteurSon.NbrePoints div pasReg;
        pages[pageCourante].nmes := nbre;
        for j := 0 to nbre-1 do begin
            pages[pageCourante].valeurVar[0,j] := j*dt;
            pages[pageCourante].valeurVar[1,j] := vecteurSon.valeur[j*pasReg];
        end;
        if vecteurSon.stereo then  for j := 0 to nbre-1 do
           pages[pageCourante].valeurVar[2,j] := vecteurSon.valeurBis[j*pasReg];
        modeAcquisition := acqSon;
        result := true;
        end
        else result := false;
     finally
       vecteurSon.Free;
     end;
end; // openWavFile

function TFichierRegressi.LitCSVHorizontal(const NomFichier : String;NouveauFichier : boolean) : boolean;
var
    csvLines : TStringList;
    csvIdx : integer;
    csvList : TStringList;
    NbreCSV : integer;
    finFichierCSV : boolean;
    uniteTrouvee : boolean;
    premiereLigne : string;
    commentaire : string;
    NbreEnTete,i : integer;

function csvEof : boolean;
begin
   result := csvIdx >= csvLines.Count;
end;

procedure csvReset;
begin
   csvIdx := 0;
   finFichierCSV := csvLines.Count = 0;
end;

procedure csvReadln(var s : string);
begin
   if csvIdx < csvLines.Count then begin
      s := NettoieIMCCE(csvLines[csvIdx]);
      inc(csvIdx);
   end else begin
      s := '';
      finFichierCSV := true;
   end;
end;

procedure litLigneCSV;
var aligne : string;
begin
   try
   NbreCSV := 0;
   FinFichierCSV := FinFichierCSV or csvEof;
   if finFichierCSV then exit;
   csvReadln(aLigne);
   csvList.DelimitedText := aLigne;
   NbreCSV := csvList.count;
   if NbreCSV>maxGrandeurs then nbreCSV := maxGrandeurs;
   if (NbreCSV>0) and (csvList[pred(NbreCSV)]='') then dec(NbreCSV);
   except
        FinFichierCSV := true;
        NbreCSV := 0;
   end;
end;

procedure LitValeurVecteurCSV(index : integer);
var i : integer;
    strValeur : string;
    Lvaleur : double;
begin with pages[pageCourante] do begin
      if nmes<(NbreCSV-1) then nmes := NbreCSV-1;
      for i := 1 to pred(NbreCSV) do begin
          strValeur := trim(csvList[i]);
          if (length(strValeur)>=2) and (strvaleur[1]='"') and (strValeur[length(strValeur)]='"') then
             strValeur := copy(strvaleur,2,length(strValeur)-2);
          if strValeur=''
             then Lvaleur := NAN
             else Lvaleur := strToFloatWin(strValeur);
          valeurVar[index,i-1] := Lvaleur;
      end;
end end; // litValeurVecteurCSV

procedure litUneLigne;

Function VerifUniteLoc : string;
var posO,posF : integer;
begin
   result := '';
   posO := pos('(',csvList[0]);
   posF := pos(')',csvList[0]);
   if (posO>1) and (posF>posO) then begin
      result := copy(csvList[0],posO+1,posF-posO-1);
      csvList[0] := copy(csvList[0],1,posO-1);
      UniteTrouvee := true;
   end;
end; // VerifUniteLoc

var index : integer;
    Lsignif : string;
    Lnom,Lunite : string;
begin
     litLigneCSV;
     if finFichierCSV or (NbreCSV=0) then exit;
     Lsignif := csvList[0];
     Lunite := VerifUniteLoc;
     LNom := Copy(trimNomGrandeur(csvList[0]),1,16);
     if Lnom='' then Lnom := 'V';
     if indexNom(Lnom)<>grandeurInconnue then Lnom := Lnom+intToStr(NbreVariab);
     if (indexNom(Lnom)=grandeurInconnue) and
        (charInSet(Lnom[1],['0'..'9'])) then Lnom := 'V'+Lnom;
     index := AjouteExperimentale(Lnom,variable);
     grandeurs[index].NomUnite := Lunite;
     grandeurs[index].fonct.expression := Lsignif;
     litValeurVecteurCSV(index);
end; // litUneLigne

begin // LitCSVHorizontal
     result := false;
     codeErreurF := erFileData;
     ModeAcquisition := AcqFichier;
     csvLines := TStringList.Create;
     csvList := TStringList.Create;
     csvList.strictDelimiter := true;
     csvList.QuoteChar := #0;
     try
     try
        LoadLinesSmart(csvLines, NomFichier);
     except
        on E:exception do begin
           codeErreurF := E.message;
           exit;
        end;
     end;
     csvReset;
     csvReadln(premiereLigne);
     NbreEnTete := 0;
     while (pos(';',premiereLigne)<=0) and
           (pos(',',premiereLigne)<=0) and
           not csvEof do begin
             inc(NbreEnTete);
             csvReadln(premiereLigne);
     end;
     if pos(';',premiereLigne)>0
        then separateurCSV := ';'
        else if pos(',',premiereLigne)>0
           then separateurCSV := ','
           else if pos(crTab,premiereLigne)>0
              then separateurCSV := crTab
              else separateurCSV := ',';
     csvList.delimiter := separateurCSV;
     csvReset;
     finFichierCSV := false;
     NbreCSV := 0;
     if NbreEnTete>0
        then csvReadln(commentaire)
        else commentaire := '';
     for i := 2 to NbreEnTete do csvReadln(premiereLigne);
     if not ajoutePage then exit;
     pages[pageCourante].commentaireP := commentaire;
     repeat
           litUneLigne;
     until finFichierCSV or csvEof;
     if (NbreGrandeurs>0) and
        (pages[pageCourante].nmes>0) then begin
            pages[pageCourante].affecteVariableP(false);
            result := true;
            construireIndex;
     end;
     finally
       csvList.free;
       csvLines.free;
     end;
end; // LitCSVHorizontal

function TFichierRegressi.LitLogger(const NomFichier : String) : boolean;
var
    FXmlDoc: TXmlDocument;
    Ident,LDecodeVariab : array[0..maxGrandeurs] of integer;
    Symbole,Comment,CommentInit : array[0..maxGrandeurs] of string;
    DataExp : array[0..maxGrandeurs] of boolean;
    nouvellePage : boolean;
    NbreVariabXML : integer;
    valeur : TVecteur;
    NbreValeurs : integer;

Procedure ExtraitValeurs(i,j,k : integer);
var jj,ii : integer;
    index : integer;
    strValeur : string;
    s : string;
begin
    s := FXMLdoc.DocumentElement.ChildNodes[i].ChildNodes[j].ChildNodes[k].NodeValue;
with pages[pageCourante] do begin
    ii := 0; jj := 1;
    Repeat
        strValeur := '';
        while (jj<=length(s)) and
              (ord(s[jj])<=ord(' ')) do inc(jj);
        while (jj<=length(s)) and
              (ord(s[jj])>ord(' ')) do begin
           strValeur := strValeur+s[jj];
           inc(jj);
        end;
        if strValeur<>'' then begin
           try
           valeur[ii] := strToFloatWin(strValeur);
           inc(ii);
           if ii>=NbreValeurs then begin
              NbreValeurs := NbreValeurs+MaxVecteurDefaut;
              setLength(valeur,NbreValeurs);
           end;
           except
           end;
        end;
    until (jj>length(s));
    if ii>nmes then nmes := ii;
    index := LDecodeVariab[j];
    if (index<>grandeurInconnue) then
       copyVecteur(valeurVar[index],valeur);
end end; // extraitValeurs

Procedure DecodeLogger(var s : String);
var longueur,posCourant : integer;
begin
   s := NettoieIMCCE(s);
   longueur := Length(s);
   posCourant := 1;
   while (posCourant<=longueur) do
      if not isLettre(s[posCourant]) and not charinset(s[posCourant],CaracNombre)
         then begin
            Delete(s,posCourant,1);
            dec(longueur);
         end
         else inc(posCourant);
end;

procedure LitNom(i,j : integer);
const maxU = 6;
      nomCSV : array[0..MaxU,boolean] of string =
          (('second','s'),
           ('Ampere','A'),
           ('Watt','W'),
           ('Volt','V'),
           ('Volts','V'),
           ('Amperes','A'),
           ('Hertz','Hz'));
var k,l,index,po : integer;
    nomUnite : string;
    cells : string;
    identStr : string;
begin with FXMLdoc.DocumentElement.ChildNodes[i].ChildNodes[j] do begin
    if j>maxGrandeurs then exit;
    dataExp[j] := false;
    nomUnite := '';
    for k := 0 to ChildNodes.Count - 1 do begin
        if ChildNodes[k].NodeName='DataObjectName' then begin
           commentInit[j] := VarToStr(ChildNodes[k].NodeValue);
           comment[j] := commentInit[j];
           decodeLogger(comment[j]);
        end;
        if ChildNodes[k].NodeName='DataObjectShortName' then begin
           symbole[j] := VarToStr(ChildNodes[k].NodeValue);
           TrimComplet(symbole[j]);
           if pos('1/',symbole[j])>0 then begin
              system.delete(symbole[j],1,2);
              symbole[j] := 'inv'+symbole[j];
           end;
           po := pos('.',symbole[j]);
           if po>0 then system.delete(symbole[j],po,1);
           trimComplet(symbole[j]);
        end;
        if ChildNodes[k].NodeName='ID' then begin
           IdentStr := VarToStr(ChildNodes[k].NodeValue);
           trimComplet(identStr);
           if identStr<>'' then Ident[j] := StrToIntDef(identStr, 0);
        end;
        if ChildNodes[k].NodeName='ColumnUnits' then begin
           nomUnite := VarToStr(ChildNodes[k].NodeValue);
           nomUnite := NettoieIMCCE(nomUnite);
           TrimAscii127(nomUnite);
           for l := 0 to maxU do
                if nomUnite=nomCSV[l,false] then begin
                   nomUnite := nomCSV[l,true];
                   break;
                end;
        end;
        if ChildNodes[k].NodeName='ColumnCells' then begin
           cells := VarToStr(ChildNodes[k].NodeValue);
           po := pos('Z',cells);
           dataExp[j] := (cells<>'') and
             ((po=0) or (po>16));
        end;
     end; // for k
     if dataExp[j] then begin
        if symbole[j]='' then begin
           symbole[j] := comment[j];
           po := pos('.',symbole[j]);
           if po>0 then system.delete(symbole[j],po,1);
           trimComplet(symbole[j]);
           comment[j] := '';
        end;
        if pageCourante=0 then begin
            index := AjouteExperimentale(symbole[j],variable);
            grandeurs[index].NomUnite := nomUnite;
            grandeurs[index].fonct.expression := comment[j];
            LDecodeVariab[j] := index;
            nouvellePage := true;
        end
        else LDecodeVariab[j] := indexNom(symbole[j]);
        inc(NbreVariabXML);
     end;
end end;

Procedure GetMemo;
var equationStr : string;

procedure MajFonctions;
const maxK = 10;
      nomLogger : array[0..MaxK,boolean] of string =
          (('secondDerivative','diff2'),
           ('derivative','diff'),
           ('diff2SG','diff2'),
           ('diffSG','diff'),
           ('sinh','sh'),
           ('cosh','ch'),
           ('tanh','th'),
           ('smoothAve','lisse'),
           ('integral','intg'),
           ('smoothSG','lisse'),
           ('ceiling','ceil'));

var po,k : integer;
begin
     for k := 0 to maxK do begin
         po := pos(nomLogger[k,false],equationStr);
         while po>0 do begin
              system.delete(equationStr,po,length(nomLogger[k,false]));
              insert(nomLogger[k,true],equationStr,po);
              po := pos(nomLogger[k,false],equationStr);
         end;
    end;
end;

var i,j,k,po : integer;
    variabId : integer;
begin with FXMLDoc.DocumentElement do
    for i := 0 to ChildNodes.Count - 1 do if ChildNodes[i].NodeName='DataSourceServer' then
          for j := 0 to ChildNodes[i].ChildNodes.Count - 1 do
              if ChildNodes[i].ChildNodes[j].NodeName='CalcColumnSource2' then  begin
                 variabId := -1;
                 equationStr := '';
                 for k := 0 to ChildNodes[i].ChildNodes[j].ChildNodes.Count - 1 do begin
                     if ChildNodes[i].ChildNodes[j].ChildNodes[k].NodeName='CalcEquation' then
                        equationStr := VarToStr(ChildNodes[i].ChildNodes[j].ChildNodes[k].NodeValue);
                     if ChildNodes[i].ChildNodes[j].ChildNodes[k].NodeName='CalcOutColumnID' then
                        variabId := StrToIntDef(VarToStr(ChildNodes[i].ChildNodes[j].ChildNodes[k].NodeValue),-1);
                 end;
                 repeat
                     po := pos('"',equationStr);
                     if po>0 then system.delete(equationStr,po,1);
                 until po=0;
                 repeat
                     po := pos('Latest:',equationStr);
                     if po>0 then system.delete(equationStr,po,7);
                 until po=0;
                 MajFonctions;
                 k := 0;
                 repeat
                     if (symbole[k]<>'') and
                        (length(commentInit[k])>length(symbole[k])+3) then begin
                        po := pos(commentInit[k],equationStr);
                        if po>0 then begin
                           system.delete(equationStr,po,length(commentInit[k]));
                           insert(symbole[k],equationStr,po);
                        end;
                     end;
                     inc(k);
                 until k=maxGrandeurs;
                 for k := 0 to maxGrandeurs do
                     if ident[k]=variabId then begin
                        trimComplet(equationStr);
                        equationStr := symbole[k]+'='+equationStr;
                        Fvaleurs.memo.lines.Add(equationStr);
                        break;
                     end;
              end;
end;

function litChaine(noeud : IXMLNode) : string;
begin
     try
        result := VarToStr(noeud.NodeValue);
     except
        result := '';
     end;
end;

procedure GenereRW3;
const maxConst = 3;
var i,j,k,l : integer;
    nomNoeud : string;
    valeurStr,valeurUnit,valeurNom : string;
    LvaleurParam : array[1..maxConst] of double;
    editable : boolean;
    nomUnitParam,nomParam : array[1..maxConst] of string;
    indexParam : integer;
    nombreConstxmbl : integer;
begin
nombreConstxmbl := 0;
editable := false;
with FXMLDoc.DocumentElement do
      for i := 0 to ChildNodes.Count - 1 do begin
      nomNoeud := ChildNodes[i].NodeName;
      if nomNoeud='DataSet' then begin
           nouvellePage := false;
           for j := 0 to maxGrandeurs do begin
               LDecodeVariab[j] := grandeurInconnue;
               ident[j] := 0;
               symbole[j] := '';
               comment[j] := '';
               commentInit[j] := '';
               dataExp[j] := false;
           end;
           NbreVariabXML := 0;
           for j := 0 to ChildNodes[i].ChildNodes.Count - 1 do begin
               if ChildNodes[i].ChildNodes[j].NodeName='DataColumn' then
                   litNom(i,j);
           end;
           if nouvellePage then getMemo;
           nouvellePage := nouvellePage or
                  ((pageCourante>0) and (NbreVariabExp=NbreVariabXML));
           if nouvellePage then begin
               ajoutePage;
               construireIndex;
               for j := 0 to ChildNodes[i].ChildNodes.Count - 1 do begin
                   if ChildNodes[i].ChildNodes[j].NodeName='DataSetComments' then
                      pages[pageCourante].commentaireP := litChaine(ChildNodes[i].ChildNodes[j]);
                   if ChildNodes[i].ChildNodes[j].NodeName='DataSetName' then
                      pages[pageCourante].commentaireP := litChaine(ChildNodes[i].ChildNodes[j]);
                   if (j<=maxGrandeurs) and (ChildNodes[i].ChildNodes[j].NodeName='DataColumn') and dataExp[j] then begin
                      for k := 0 to ChildNodes[i].ChildNodes[j].ChildNodes.Count - 1 do
                          if ChildNodes[i].ChildNodes[j].ChildNodes[k].NodeName='ColumnCells' then
                             extraitValeurs(i,j,k);
                      if pages[pageCourante].nmes>2
                         then result := true
                         else if pageCourante>1 then supprimePage(pageCourante,false);
                   end;
               end;
               for l := 1 to nombreConstXMBL do begin
                  indexParam := indexNom(nomParam[l]);
                  if indexParam=grandeurInconnue then begin
                     indexParam := AjouteExperimentale(nomParam[l],constante);
                     grandeurs[indexParam].nomUnite := nomUnitParam[l];
                  end;
                  pages[pageCourante].ValeurConst[indexParam] := LvaleurParam[l];
               end;
            end;
      end
      else if nomNoeud='MathConstantValue' then begin
           valeurStr := litChaine(ChildNodes[i]);
      end
      else if nomNoeud='MathConstantEditable' then begin
           editable := VarToStr(ChildNodes[i].NodeValue)='1';
      end
      else if nomNoeud='MathConstantUnits' then begin
           valeurUnit := litChaine(ChildNodes[i]);
      end
      else if nomNoeud='MathConstantName' then begin
           valeurNom := litChaine(ChildNodes[i]);
           if (valeurNom<>'pi') and
              editable and
              (nombreConstXMBL<maxConst) then begin
               inc(NombreConstXmbl);
               nomParam[NombreConstXMBL] := valeurNom;
               LvaleurParam[NombreConstXMBL] := strToFloatWin(valeurStr);
               nomUnitParam[NombreConstXMBL] := valeurUnit;
           end;
      end;
      end;
end; // GenereRW3

begin // LitLogger
     result := false;
     codeErreurF := erFileData;
     ModeAcquisition := AcqFichier;
     NbreValeurs := MaxVecteurDefaut;
     setLength(valeur,NbreValeurs);
     FXmlDoc := TXMLDocument.Create(nil);
     try
       try
         if (FXmlDoc.DOMVendor=nil) and (DomVendors.count>0) then
            FXmlDoc.DOMVendor := DomVendors.Vendors[0];
         FXmlDoc.LoadFromFile(NomFichier);
         if assigned(FXMLDoc.DocumentElement) then genereRW3;
         if result and (pageCourante>0) then
            pages[pageCourante].affecteVariableP(false);
       except
         codeErreurF := erReadFile;
         result := false;
         resetEnTete;
       end;
     finally
       FXmlDoc.Free;
     end;
end; // LitLogger

initialization

FichierRegressi := TFichierRegressi.create;

finalization

FichierRegressi.free;

end.
