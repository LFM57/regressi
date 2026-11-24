unit Latex;

interface

uses sysutils, classes,
  regutil, compile, constreg,

  FMX.TMSFNCCustomControl,
  FMX.TMSFNCCustomScrollControl, FMX.TMSFNCGridData, FMX.TMSFNCCustomGrid,
  FMX.TMSFNCGrid, FMX.TMSFNCGridCell, FMX.TMSFNCTypes, FMX.TMSFNCUtils,
  FMX.TMSFNCGraphics, FMX.TMSFNCGraphicsTypes, FMX.TMSFNCGridOptions;

procedure AjouteGrandeur(index : integer);
procedure AjouteModele(amodele : Tmodele;avecCouleur : boolean);
procedure DebutDoc(const titre : string);
procedure FinDoc;

Procedure AjouteLigne(aligne : string);
Procedure AjouteLigneItem(aligne : string);
Procedure AjouteGrid(agrid : TTMSFNCGrid);
Procedure AjouteParagraphe(titre : string);
Procedure AjouteLigneLatex(const aligne : string);
Procedure SautLigne;

Procedure SaveFile(const nomFichier : string);

implementation

var latexStr : TstringList;

Function TranslateExpression(F:Pelement) : string;
// renvoie le code Tex d'un arbre pointé par F

Function calcIf(ff : Pelement): string;
begin with ff^ do begin
   result := result+' \textrm{if } '+TranslateExpression(test)+' \newline';
   result := result+' \textrm{ then } '+TranslateExpression(positif)+' \newline';
   result := result+' \textrm{ else } '+TranslateExpression(negatif);
end end;

Function calcPW(ff : Pelement): string;
begin
   result := '\begin{dcases} ';
   repeat
       result := result + translateExpression(ff.PWtest)+'& '+ translateExpression(ff.PWthen)+'\newline';
       ff := ff.PWtestElse;
       if ff.typeElement<>Piecewise then begin
          result := result + '\text{else} & '+ translateExpression(ff)+'\newline';
          ff := nil;
       end;
   until ff=nil;
   result := result+'\end{dcases}';
end;

Function calculFonctionGlb(F : Pelement): string;

Function CalcIntegrale : String; // intégrale operandGlb / varMuette de a à b
var a,b,sigma,vm : string;
begin with F^ do begin
        a := translateExpression(operandDebut);
        b := translateExpression(operandFin);
        vm := translateNomMath(Grandeurs[cMuette].nom);
        sigma := translateExpression(operandGlb);
        result := '\int'+'_{'+a+'}'+'^{'+b+'}'+sigma+'\, \mathrm{d} '+vm;
end end; // CalcIntegrale

var Lfreq,rapportCyclique,anom,anomY : string;
begin with F^ do begin // calculFonctionGlb
    result := '';
    if varX<>nil
       then aNom := translateNomMath(varX.nom)
       else aNom :='';
    if operandGlb<>nil then Lfreq := translateExpression(OperandGlb);
    if OperandDebut<>nil then rapportCyclique := translateExpression(OperandDebut);
    case CodeFglb of
        maximum,position,minimum,moyenne,somme,efficace,frequence,
                    ecartType,surface,phase,initial :
                    result := LowerCase(nomFonctionGlb[CodeFglb])+'('+aNom+')';
        pente,origine :  begin
           aNomY := translateNomMath(varY.nom);
           result := LowerCase(nomFonctionGlb[CodeFglb])+'('+aNom+','+anomY+')';
        end;
        derivee : begin
           aNomY := translateNomMath(varY.nom);
           result := '\frac{ \mathrm{d} '+anomY+'}{ \mathrm{d} '+aNom+'}';
        end;
        equation : result := Lfreq;
        integraleDefinie,integrale : result := CalcIntegrale;
        cCreneau : result := 'Creneau('+Lfreq+','+rapportCyclique+')';
        cCnp : result := 'C_{'+Lfreq+'}{'+rapportCyclique+'}';
        cTriangle : result := 'Triangle('+Lfreq+','+rapportCyclique+')';
        cGauss : CalculFonctionGlb := 'Gauss('+Lfreq+','+rapportCyclique+')';
        cPhaseModulo : result := 'PhaseModulo('+anom+Lfreq+','+rapportCyclique+')';
        cPoisson : result := 'Poisson('+anom+','+Lfreq+')';
        cBessel : CalculFonctionGlb := 'BesselJ('+rapportCyclique+','+Lfreq+')';
   end; // case
end end; // calculFonctionGlb

Var X,Y : string;
    parX,parY : boolean; // parenthèse X Y
    indexP : integer;
Begin // TranslateExpression
  result := '';
  if F=nil then exit;
  With F^ do Case TypeElement of
       Operateur: Begin
            X := translateExpression(OperG);
            parX := (Operg.TypeElement=Operateur) and
                    charInSet(OperG.CodeOp,['+','-']) and
                    charInSet(CodeOp,['*','^','&','#','@']);
            if parX then X := '('+X+')';
            Y := translateExpression(OperD);
            parY := (OperD.TypeElement=Operateur) and
                    charInSet(OperD.CodeOp,['+','-']) and
                    charInSet(CodeOp,['*','&','#','@']);
            if parY then Y := '('+Y+')';
            Case CodeOp of
                 '+','<','-','>','=' : result := X+CodeOp+Y;
                 '*' : if (Operd.typeElement=grandeur) and
                          (Operd.pvar.genreG=paramNormal) then begin
                         indexP := indexNom(operd.Pvar.nom);
                         indexP := indexToParam(indexP);
                         if ParamInverse[indexP]
                             then result := '\frac{'+X+'}{'+Y+'}'
                             else result := X+'\cdot '+Y;
                    end
                    else result := X+'\cdot '+Y; // ou times ?
                 '/' : result := '\frac{'+X+'}{'+Y+'}';
                 '@' : result := X+'+'+Y;
                 '#' : result := X+'-'+Y;
                 '^' : result := X+'^{'+Y+'}';
                 '&' : result := '\arg('+X+'+\jmath'+Y+')';
            end;{case codeOp}
       end;{operateur}
       Fonction: Begin
             X := translateExpression(Operand);
             parX := (codeF in [lognep,logdec,sinus,cosinus,tangente,argument,exponentielle,sinuscardinal,reelle,imaginaire,arctangente,carre,sinuscardinal]);
             parY := pos('\frac',X)=1;
             if parX then if parY
                then X := '\left('+X+'\right)'
                else X := '('+X+')';
             case codef of
                racine : result := '\sqrt{'+X+'}';
                oppose: result := '-'+X;
                absolue: result := '\| '+X+' \|';
                inverse: result := '\frac{1}{'+X+'}';
                carre : result := X+'^2';
                lognep: result := '\ln '+X;
                logdec: result := '\log '+X;
                sinus: result := '\sin '+X;
                cosinus: result := '\cos '+X;
                tangente: result := '\tan '+X;
                arcSinus: result := '\arcsin ('+X+')';
                arcCosinus: result := '\arccos ('+X+')';
                arcTangente: result := '\arctan '+X;
                cosHyper: result := '\cosh ('+X+')';
                sinHyper: result := '\sinh ('+X+')';
                tanHyper: result := '\tanh ('+X+')';
                ArgTanHyper: result := '\atanh ('+X+')';
                NotFunction,FonctInconnue: result := '?';
                CodeGamma: result := '\Gamma ('+X+')';
                CodeFact: result := X+'!';
                reelle: result := '\Re '+X;
                imaginaire: result := '\Im '+X;
                argument: result := '\arg '+X;
                echelon: result := '\Upsilon ('+X+')';
                entierSup: result := '\lceil {'+X+'} \rceil';
                entier,entierInf: result := '\lfloor {'+X+'} \rfloor';
                exponentielle: result := '\exp '+X;
                sinusCardinal: result := '\rm{sinc} '+X;
                errorFunction: result := '\rm{erf}('+X+')' ;
                else result := LowerCase(nomFonction[codeF])+'('+X+')';
             end;// case codeF
       End;{Fonction}
       FonctionGlb : result := calculFonctionGlb(F);
       IfThenElse : result := calcIf(F);
       PieceWise: result := calcPW(F);
       grandeur : result := translateNomMath(Pvar.nom);
       grandeurIndicee,IncertIndicee : result := translateNomMath(Pvar.nom)+'['+intToStr(round(numero))+']';
       Nombre: if F=pointeurPi then result := '\pi' else result := floatToStrPoint(valeur);
       RacineMoinsUn : result := '\jmath';
     	 Incert : result := '';
       else result := '';
  End; // case
End; //  TranslateExpression

procedure AjouteGrandeur(index : integer);
var sigma,vm : string;
    debutLigne,nomL,nomX : string;
begin with grandeurs[index] do begin
     nomL := translateNomMath(nom);
     debutLigne := '\[ '+nomL+'=';
     nomX := translateNomMath(grandeurs[0].nom);
     case fonct.genreC of
          g_fonction,g_derivee,g_equation,g_filtrage, g_definitionFiltre :
              AjouteLigneLatex(debutLigne+translateExpression(fonct.calcul)+' \]');
          g_experimentale,g_texte : if fonct.expression<>'' then
              AjouteLigne(debutLigne+fonct.expression);
          g_diff1 : ajouteLigneLatex('\[ \frac{ \mathrm{d} '+NomL+'}{ \mathrm{d} '+nomX+'}='+
              translateExpression(fonct.calcul.operandGlb)+' \]');
          g_diff2 : ajouteLigneLatex('\[ \frac{ \mathrm{d} ^2'+nomL+'}{ \mathrm{d} '+nomX+'^2}='+
              translateExpression(fonct.calcul.operandGlb)+' \]');
          g_integrale : begin
             vm := translateNomMath(fonct.calcul^.varX.nom);
             sigma := translateExpression(fonct.calcul.OperandGlb);
             AjouteLigneLatex(debutLigne+'\int'+sigma+'\, \mathrm{d} '+vm+' \]');
          end;
          g_a_affecter, g_forward : ;
          g_deriveeSeconde : begin
            sigma := translateNomMath(fonct.calcul.varY.nom);
            vm := translateNomMath(fonct.calcul.varX.nom);
            AjouteLigneLatex(debutLigne+'\frac{ \mathrm{d} ^2'+sigma+'}{ \mathrm{d} '+vm+'^2}');
          end;
          g_euler : ;
          else if fonct.expression<>'' then
              ajouteLigne(debutLigne+fonct.expression+' \]');
     end;
end end;

procedure DebutDoc(const titre : string);
var date : string;
begin
     latexStr.clear;
     latexStr.add('%!TEX encoding = UTF-8 Unicode');
     latexStr.add('\documentclass[french]{article}');
     latexStr.add('\usepackage[utf8]{inputenc}');
     latexStr.add('\usepackage[T1]{fontenc}');
//     latexStr.add('\usepackage{fourier}');
     latexStr.add('\usepackage[french]{babel}');
     latexStr.add('\usepackage{tikz}');
     latexStr.add('\usepackage{mathtools}');
     latexStr.add('\usepackage{amsmath}');
     latexStr.add('\usepackage{pgfplots}');
     latexStr.add('\usetikzlibrary{plotmarks}');
     latexStr.add('\usepackage{enumitem}');
     latexStr.add('\usepackage{siunitx}');
     latexStr.add('%\sisetup{exponent-product=\cdot,output-decimal-marker={,},separate-uncertainty}');
     latexStr.add('%\title{'+titre+'}');
     latexStr.add('%\author{}');
     date := DateToStr(Now);
     latexStr.add('%\date{'+date+'}');
     latexStr.add('\pgfplotsset{compat=1.18}');
     latexStr.add('\begin{document}');
     latexStr.add('%\maketitle');
end;

procedure FinDoc;
begin
     latexStr.add('\end{document}');
end;

Procedure AjouteLigne(aligne : string);
begin
     if aligne<>'' then aligne := translateNomTexte(aligne);
     latexStr.add(aligne);
end;

Procedure SautLigne;
begin
     latexStr.add('');
end;

Procedure AjouteLigneItem(aligne : string);
begin
     if pos('$',aligne)<>1 then aligne := translateNomTexte(aligne);
     aligne := '\item '+aligne;
     latexStr.add(aligne);
end;

Procedure AjouteGrid(agrid : TTMSFNCGrid);

Function LigneDeChiffresGrid(row : integer) : boolean;
var j,col : integer;
    s : string;
begin
    result := true;
    for col := 0 to pred(agrid.columnCount) do begin
        s := agrid.cells[col,row];
        for j := 1 to length(s) do
            if not (charInSet(s[j],['0'..'9','+','-','.',',','E','e',' ',#177])
                    or (s[j]=cdot) or (pos(s[j],ChiffreExpStr)>0))
               then begin
                   result := false;
                   exit;
               end;
   end;            
end;

var col,row : integer;
    ligne : string;
begin
    latexStr.add('');
    ligne := '\begin{tabular}{';
    for col := 0 to pred(agrid.columnCount) do
        ligne := ligne+'|c';
    ligne := ligne+'|}';
    latexStr.add(ligne);
    for row := 0 to pred(agrid.rowCount) do
        if ligneDeChiffresGrid(row)
           then begin
              ligne := agrid.cells[0,row];
              for col := 1 to pred(agrid.columnCount) do
                  ligne := ligne + ' & ' + agrid.cells[col,row];
              ligne := ligne+'\\';
              latexStr.add(ligne);
           end
           else begin
              ligne := translateNomTexte(agrid.cells[0,row]);
              for col := 1 to pred(agrid.columnCount) do
                  ligne := ligne + ' & ' + translateNomTexte(agrid.cells[col,row]);
              ligne := ligne+'\\';
              latexStr.add(ligne);
           end;
    latexStr.add('\end{tabular}');
end; // ajouteGrid

Procedure AjouteModele(amodele : Tmodele;avecCouleur : boolean);
var texte : string;
begin
     with amodele do begin
          texte := '\[ ';
          if avecCouleur then texte := texte+'{\color{'+couleurLatex(couleurM)+'} ';
          texte := texte + translateNomMath(addrY.nom)+'='+translateExpression(calcul);
          if avecCouleur then texte := texte+'}';
          texte := texte+' \]';
          latexStr.add(texte)
     end;
end;

Procedure SaveFile(const nomFichier : string);
var fichierDest : TextFile;
   i: Integer;
begin
     FileMode := fmOpenWrite;
     AssignFile(fichierDest,NomFichier,CP_UTF8);
     Rewrite(fichierDest);
     for i := 0 to latexStr.Count-1 do
         writeln(fichierDest,latexStr[i]);
     closeFile(fichierDest);
     FileMode := fmOpenReadWrite;
end;

Procedure AjouteParagraphe(titre : string);
begin
  titre := translateNomTexte(titre);
  latexStr.add('\paragraph{'+titre+'}');
end;

Procedure AjouteLigneLatex(const aligne : string);
begin
    latexStr.add(aligne);
end;

initialization
     latexStr := TstringList.create

finalization
     latexStr.free

end.
