unit modeleGr; // Modélisation graphique

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.UIConsts,
  System.Classes,
  System.Math,

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
  FMX.Platform,
  FMX.Graphics,

  compile,
  constreg,
  fft,
  graphker,
  maths,
  regutil,
  statcalc,
  uniteker,
  valeurs;

type
    TgenreModeleGr = (mgAffine,mgParabolique,mgSinus,mgSinusAmorti,
                   mgEchelon1,mgPuissance,mgSinusDiverge,mgRadio,
                   mgManuel,mgQualite,
                   mgPasseBas1,mgPasseHaut1,mgPasseBande,mgPasseBas2,mgPasseHaut2,
                   mgHyperbolique,mgLineaire,mgSigmoide,
                   mgGauss,mgLorentz,
                   mgAffineDouble);

    TmodeleGr = class
         Expression : TstringList;
         Genre : TgenreModeleGr;
         modeleOK : boolean;
         parametreGr : matriceLigne;
         mondeGr : indiceMonde;
         numeroModele : integer;
         nX,nY : string;
         nomParam : array[1..5] of string;
         couleur : TAlphaColor;
         Constructor Create;
         Destructor Destroy;override;
         Procedure Init(Agenre : TgenreModeleGr;Agraphe : TgrapheReg;
                        Numero : integer);
         Procedure InitialiseParametre(var debut,fin : integer;changeDebutDemande : boolean);
         Procedure GetParametres(var p : tableauParam);
         Procedure SetParametres(var p : tableauParam);
         procedure ImagePaint(Canvas: TCanvas;const ARect: TRectF;tag : integer);
    end;

var
    modeleGraphique,modeleParametre : array[codeIntervalle] of TmodeleGr;


implementation

const
    NbreParamMagnum : array[tgenreModeleGr] of integer =(2,3,4,5,2,2,5,2,0,5,
                      2,2,3,3,3,
                      2,1,4,3,3,4);
    coeffPenteSig = 2;
    NomSinus : array[boolean] of string = ('sin','cos');

procedure TmodeleGr.Init(Agenre : TgenreModeleGr;Agraphe : TgrapheReg;
                         numero : integer);
const UnTour : array[boolean] of string = ('2*'+piMin,'360');
      UnDemiTour : array[boolean] of string = (piMin,'180');

Function getNom(NomDefaut : string) : string;
var index : integer;
begin
    result := NomDefaut;
    index :=  indexNom(NomDefaut);
// vérifier si une variable de même nom existe
    if (index<MaxGrandeurs) or
       (indexToParam(index)<>grandeurInconnue)
        then begin
           result := result + intToStr(numero);
           index :=  indexNom(result);
           if (index<MaxGrandeurs) or
              (indexToParam(index)<>grandeurInconnue)
            then result := result + intToStr(numero);
       end;     
end;

var exp,debutExp,exp1,exp2,exp3 : string;
begin
     genre := Agenre;
     numeroModele := numero;
     if (numeroModele<1) or (numeroModele<MaxIntervalles) then numeroModele := 1;
     with aGraphe.Coordonnee[1] do begin
          mondeGr := iMondeC;
          nX := nomX;
          nY := NomY;
     end;
     debutExp := nY+'=';
     NomParam[5] := getNom(tauMin);
     NomParam[4] := getNom(phiMin);
     if genre in [mgPasseBas1,mgPasseHaut1,mgPasseBande,
                  mgPasseBas2,mgPasseHaut2]
          then begin
             NomParam[2] := getNom(nX+'0');
             NomParam[1] := getNom('G0');
          end
          else begin
             NomParam[1] := getNom('a');
             NomParam[2] := getNom('b');
          end;
     if genre in [mgPasseBas2,mgPasseHaut2,mgPasseBande]
          then begin
              exp2 := '('+nX+'/'+NomParam[2]+')^2';
              if ModeleFacteurQualite
                 then begin
                     NomParam[3] := 'Q';
                     exp3 := 'abs(1+j*'+nX+'/'+NomParam[2]+'/'+NomParam[3]+'-'+exp2+')';
                 end
                 else begin
                     NomParam[3] := 'm';
                     exp3 := 'abs(1+2*j*m*'+nX+'/'+NomParam[2]+'-'+exp2+')';
                 end;
          end
          else if genre=mgQualite
                 then NomParam[3] := getNom(omegaMin+'0')
                 else NomParam[3] := getNom('c');
     if genre in [mgPasseBas1,mgPasseHaut1]
        then exp1 := 'abs(1+j*'+nX+'/'+NomParam[2]+')';
     if genre=mgAffineDouble then begin
         NomParam[3] := getNom('a');
         NomParam[4] := getNom('b');
     end;
     case genre of
          mgLineaire : exp:=debutExp+NomParam[1]+'*'+nX; // a*x
          mgAffine,mgAffineDouble : exp:=debutExp+NomParam[1]+'*'+nX+'+'+NomParam[2];
            // a*x+b
          mgPuissance : exp:=debutExp+NomParam[1]+'*'+nX+'^'+NomParam[2];
            // a*x^b
          mgParabolique : exp:=debutExp+NomParam[1]+'+'+NomParam[2]+
              '*'+nX+'+'+NomParam[3]+'*'+nX+'^2';
            // a*x^2+b*x+c
          mgHyperbolique : begin // a*x/(b+x) = Vm.[S]/(KM+[S])
             NomParam[2] := 'KM';
             NomParam[1] := 'Vm';
             exp:=debutExp+'Vm*'+nX+'/(KM+'+nX+')';
          end;
          mgSinus,mgSinusAmorti,mgSinusDiverge : begin
              NomParam[3] := 'T';
              exp:=debutExp+NomParam[1]+'+'+NomParam[2]+'*'+
                  nomSinus[modeleCosinus]+'('+UnTour[angleEnDegre]+
                      '*'+nX+'/'+nomParam[3]+'+'+NomParam[4]+')';
              // c+y0*sin(2*pi*t/T+phi)
              if genre<>mgSinus then begin
                 exp:=exp+'*exp(';
                 if genre=mgSinusAmorti then exp:=exp+'-';
                 exp:=exp+nX+'/'+NomParam[5]+')'; // *exp(-t/tau)
              end;
          end;
          mgQualite : begin
              // c+y0*sin(w0*rac(1-k*k)*t+phi)*exp(-k*w0*t)
              // ne marche qu'en radian !
              Fvaleurs.passageEnRadian(true);
              NomParam[5] := NomParam[4]; // phi
              NomParam[4] := lambdaMin; // k
              exp:=debutExp+NomParam[1]+'+'+NomParam[2]+'*'+
                    nomSinus[modeleCosinus]+'('+NomParam[3]+'*'+nX+
                    '*sqrt(1-'+nomParam[4]+'^2)+'+nomParam[5]+')';
              exp:=exp+'*exp(-'+nomParam[4]+'*'+nomParam[3]+'*'+nX+')';
          end;
          mgSigmoide : begin
              NomParam[1] := nY+'min'; // Ymin
              NomParam[2] := nY+'max'; // Ymax
              NomParam[3] := nX+'0'; // Xdemi
              NomParam[4] := getNom('b'); // exposant              
              exp:=debutExp+NomParam[1]+'+('+NomParam[2]+'-'+NomParam[1]+')/(1+('+nX+
                 '/'+nomParam[3]+')^'+nomParam[4]+')';
          end;
          mgGauss : begin
              NomParam[3] := getNom(sigmaMin); // ecart type
              NomParam[2] := nX+'0'; // moyenne
              NomParam[1] := getNom('A'); // coeff multiplicateur
              exp:=debutExp+NomParam[1]+'*exp(-(('+nX+'-'+NomParam[2]+')/'+NomParam[3]+')^2/2)';
          end;
          mgLorentz : begin
              NomParam[3] := getNom(gammaMaj); // largeur
              NomParam[2] := nX+'0'; // moyenne
              NomParam[1] := getNom('A'); // coeff multiplicateur
              exp:=debutExp+NomParam[1]+'/(('+nX+'-'+NomParam[2]+')^2+('+NomParam[3]+'/2)^2)';
          end;
          mgEchelon1 : begin // a*(1-exp(-t/tau))
             nomParam[2] := nomParam[5];
             exp:=debutExp+NomParam[1]+'*(1-exp(-'+nX+'/'+NomParam[2]+'))';
          end;
          mgRadio : begin // a*exp(-t/tau)
             nomParam[2] := nomParam[5];
             exp:=debutExp+NomParam[1]+'*exp(-'+nX+'/'+NomParam[2]+')';
          end;
          mgPasseBas1 : if ModeleDecibel
             then exp:=debutExp+NomParam[1]+'-20*log('+exp1+')'
              // a-20*log(abs(1+j*w/w0))
             else exp:=debutExp+NomParam[1]+'/'+exp1;
              // a/abs(1+j*w/w0)
          mgPasseHaut1 : if ModeleDecibel
            then exp:=debutExp+NomParam[1]+'+20*log('+nX+'/'+NomParam[2]+')-20*log('+exp1+')'
              // a +20*log(w/w0) -20*log(abs(1+j*w/w0))
            else exp:=debutExp+NomParam[1]+'*'+nX+'/'+NomParam[2]+'/'+exp1;
              // a*w/w0/abs(1+j*w/w0)
          mgPasseBas2 : if ModeleDecibel
            then exp:=debutExp+NomParam[1]+'-20*log('+exp3+')'
              // a-20*log(abs(1+j*2m*w/w0-(w/w0)^2))
            else exp:=debutExp+NomParam[1]+'/'+exp3;
             // G0/abs(1+j*2*m*f/f0-(f/f0)^2)
          mgPasseHaut2 : if ModeleDecibel
            then exp:=debutExp+NomParam[1]+'+40*log('+nX+'/'+NomParam[2]+')-20*log('+exp3+')'
             // a +40*log(w/w0) -20*log(abs(1+j*2m*w/w0-(w/w0)^2)))
            else exp:=debutExp+NomParam[1]+'*'+exp2+'/'+exp3;
             // G0*(f/f0)^2/abs(1+j*2*m*f/f0-(f/f0)^2)
          mgPasseBande : if ModeleFacteurQualite
             then if ModeleDecibel
                  then exp:=debutExp+NomParam[1]+'-20*log(abs(1+j*('+
                          nX+'/'+NomParam[2]+'-'+NomParam[2]+'/'+nX+')*Q))'
                        { a -20*log(abs(1+j*(w/w0-w0/w)*Q)) }
                  else exp:=debutExp+NomParam[1]+'/abs(1+j*('+
                    nX+'/'+NomParam[2]+'-'+NomParam[2]+'/'+nX+')*Q)'
                // a/abs(1+j*(w/w0-w0/w)*Q)
             else if ModeleDecibel
                  then exp:=debutExp+NomParam[1]+'-20*log(abs(1+j*('+
                            nX+'/'+NomParam[2]+'-'+NomParam[2]+'/'+nX+')/2/m))'
               // a -20*log(abs(1+j*(w/w0-w0/w)/2m))
                  else exp:=debutExp+NomParam[1]+'/abs(1+j*('+
                    nX+'/'+NomParam[2]+'-'+NomParam[2]+'/'+nX+')/2/m)';
                 // a/abs(1+j*(w/w0-w0/w)/2m)
     end;
     Expression.clear;
     Expression.Add(exp);
     debutExp := nY+'('+nX+'):=';
     case genre of
          mgSinus : ;
          mgAffineDouble : begin
             exp:=debutExp+NomParam[3]+'*'+nX+'+'+NomParam[4];
            // a'*x+b'
          end;
          mgSigmoide : ;
          mgGauss : ;
          mgLorentz : ;
          mgSinusAmorti : begin
             exp := debutExp+NomParam[1]+'+'+NomParam[2]+
                 '*exp(-'+nX+'/'+NomParam[5]+')';
             Expression.Add(exp);
             exp := debutExp+NomParam[1]+'-'+NomParam[2]+
                 '*exp(-'+nX+'/'+NomParam[5]+')';
             Expression.Add(exp);
          end;
          mgQualite : begin
             exp := debutExp+NomParam[1]+'+'+NomParam[2]+
                  '*exp(-'+nomParam[4]+'*'+nomParam[3]+'*'+nX+')';
             Expression.Add(exp);
             exp := debutExp+NomParam[1]+'-'+NomParam[2]+
                 '*exp(-'+nomParam[4]+'*'+nomParam[3]+'*'+nX+')';
             Expression.Add(exp);
          end;
          mgSinusDiverge : begin
             exp := debutExp+NomParam[1]+'+'+NomParam[2]+
                 '*exp('+nX+'/'+NomParam[5]+')';
             Expression.Add(exp);
             exp := debutExp+NomParam[1]+'-'+NomParam[2]+
                 '*exp('+nX+'/'+NomParam[5]+')';
             Expression.Add(exp);
          end;
          mgEchelon1 : begin
             exp := debutExp+NomParam[1];
             Expression.Add(exp);
             exp := debutExp+NomParam[1]+'*'+nX+'/'+NomParam[2];
             Expression.Add(exp);
          end;
          mgRadio : begin
             exp := debutExp+NomParam[1]+'*(1-'+nX+'/'+NomParam[2]+')';
             Expression.Add(exp);
          end;
          mgPasseBas1 : begin
             exp:=debutExp+NomParam[1];
             Expression.Add(exp);
             if ModeleDecibel
               then exp:=debutExp+NomParam[1]+'-20*log('+nX+'/'+NomParam[2]+')'
               else exp:=debutExp+NomParam[1]+'*'+NomParam[2]+'/'+nX;
             Expression.Add(exp);
          end;
          mgPasseHaut1 : begin
             exp:=debutExp+NomParam[1];
             Expression.Add(exp);
             if ModeleDecibel
                then exp:=debutExp+NomParam[1]+'+20*log('+nX+'/'+NomParam[2]+')'
                else exp:=debutExp+NomParam[1]+'*'+nX+'/'+NomParam[2];
             Expression.Add(exp);
          end;
          mgPasseBas2 : begin
             exp:=debutExp+NomParam[1];
             Expression.Add(exp);
             if ModeleDecibel
               then exp:=debutExp+NomParam[1]+'-40*log('+nX+'/'+NomParam[2]+')'
               else exp:=debutExp+NomParam[1]+'*('+NomParam[2]+'/'+nX+')^2';
             Expression.Add(exp);
          end;
          mgPasseHaut2 : begin
             exp:=debutExp+NomParam[1];
             Expression.Add(exp);
             if modeleDecibel
                then exp:=debutExp+NomParam[1]+'+40*log('+nX+'/'+NomParam[2]+')'
                else exp:=debutExp+NomParam[1]+'*('+nX+'/'+NomParam[2]+')^2';
             Expression.Add(exp);
          end;
          mgPasseBande : if ModeleDecibel
             then begin
             exp:=''''+debutExp+NomParam[1]+'-20*log('+nX+'/'+NomParam[2]+
                 '*'+NomParam[3]+')';
             Expression.Add(exp);
             exp:=''''+debutExp+NomParam[1]+'+20*log('+nX+'/'+NomParam[2]+
                  '/'+NomParam[3]+')';
             Expression.Add(exp);
             end
             else begin
             exp:=''''+debutExp+NomParam[1]+'*'+NomParam[2]+'/'+nX+'/'+NomParam[3];
             Expression.Add(exp);
             exp:=''''+debutExp+NomParam[1]+'*'+nX+'/'+NomParam[2]+'/'+NomParam[3];
             Expression.Add(exp);
          end;
    end;
end;

Procedure TmodeleGr.InitialiseParametre(var debut,fin : integer;changeDebutDemande : boolean);
var minX,maxX,minY,maxY : double;
    i,Nbre,milieu,posMaxY : integer;
    valeurX,valeurY : vecteur;
    indexX,indexY : integer;

Procedure InitialiseAffineDouble;
var statLoc : TStatistiqueDeuxVar;

Procedure Resoudre(i1,i2 : integer;var xs1,xs2 : double);
var systeme : matrice;
    x,y : double;
    i,j : integer;
begin
    for i := 1 to 2 do
        for j := 1 to 3 do systeme[i,j] := 0;
    systeme[1,1] := (i2-i1)+1;
    maxX := valeurX[i1];
    minX := maxX;
    for i := i1 to i2 do begin
        x := valeurX[i];
        y := valeurY[i];
        systeme[1,2] := systeme[1,2]+x;
        systeme[2,2] := systeme[2,2]+x*x;
        systeme[1,3] := systeme[1,3]+y;
        systeme[2,3] := systeme[2,3]+y*x;
        if valeurX[i]>maxX
           then maxX := valeurX[i]
           else if valeurX[i]<minX then minX := valeurX[i];
    end;
    systeme[2,1] := systeme[1,2];
    Resolution(systeme,2,parametreGr);
    swap(parametreGr[1],parametreGr[2]);
// a*x+b au lieu de a+b*x !
    xs1 := minX+(maxX-minX)/10;
    xs2 := maxX-(maxX-minX)/10;
end;

var fin1,debut2 : integer;
    xs1,xs2,xs3,xs4 : double;
begin
   modeleOK := nbre>11;
   if not modeleOK then exit;
   statLoc := TStatistiqueDeuxVar.create;
   fin1 := debut+1;
   repeat
         inc(fin1,2);
         statLoc.Init(valeurX,valeurY,debut,fin1);
   until (fin1>milieu) or (abs(statLoc.correlation)<0.95);
   resoudre(debut,fin1,xs1,xs2);
   debut2 := fin-1;
   repeat
         dec(debut2,2);
         statLoc.Init(valeurX,valeurY,debut2,fin);
   until (debut2<milieu) or (abs(statLoc.correlation)<0.95);
   resoudre(debut2,fin,xs3,xs4);
   statLoc.Free;
end;

Procedure InitialiseAffine;
var systeme : matrice;
    x,y : double;
    i,j : integer;
begin
    for i := 1 to 2 do
        for j := 1 to 3 do systeme[i,j] := 0;
    systeme[1,1] := Nbre;
    for i := debut to fin do begin
        x := valeurX[i];
        y := valeurY[i];
        systeme[1,2] := systeme[1,2]+x;
        systeme[2,2] := systeme[2,2]+x*x;
        systeme[1,3] := systeme[1,3]+y;
        systeme[2,3] := systeme[2,3]+y*x;
    end;
    systeme[2,1] := systeme[1,2];
    Resolution(systeme,2,parametreGr);
    swap(parametreGr[1],parametreGr[2]);
// a*x+b au lieu de a+b*x !
end;

Procedure InitialiseLineaire;
var a : double;
    i,N : integer;
begin
    A := 0;
    N := 0;
    for i := debut to fin do begin
        try
        a := a+valeurY[i]/valeurX[i];
        inc(N);
        except
        end;
    end;
    parametreGr[1] := a/N;
end;

Procedure InitialiseHyperbolique;
var systeme : matrice;
    x,y,a,b : double;
    i,j : integer;
// y=a*x/(b+x) linéarisé en 1/y = b/a*(1/x)+1/a=a2*x+a1
begin
    for i := 1 to 2 do
        for j := 1 to 3 do systeme[i,j] := 0;
    systeme[1,1] := Nbre;
    for i := debut to fin do begin
        try
        x := 1/valeurX[i];
        y := 1/valeurY[i];
        systeme[1,2] := systeme[1,2]+x;
        systeme[2,2] := systeme[2,2]+x*x;
        systeme[1,3] := systeme[1,3]+y;
        systeme[2,3] := systeme[2,3]+x*y;
        except
        continue
        end;
    end;
    systeme[2,1] := systeme[1,2];
    Resolution(systeme,2,parametreGr);
    a := 1/parametreGr[1];
    b := parametreGr[2]*a;
    parametreGr[1] := a;
    parametreGr[2] := b;
end;

Procedure InitialisePuissance;
var systeme : matrice;
    x,y : double;
    i,j : integer;
begin
    for i := 1 to 2 do
        for j := 1 to 3 do systeme[i,j] := 0;
    systeme[1,1] := Nbre;
    for i := debut to fin do begin
        try
        x := ln(valeurX[i]);
        y := ln(valeurY[i]);
        systeme[1,2] := systeme[1,2]+x;
        systeme[2,2] := systeme[2,2]+x*x;
        systeme[1,3] := systeme[1,3]+y;
        systeme[2,3] := systeme[2,3]+y*x;
        except
        continue
        end;
    end;
    systeme[2,1] := systeme[1,2];
    Resolution(systeme,2,parametreGr);
    parametreGr[1] := exp(parametreGr[1]);
end;

Procedure InitialiseParabolique;
var systeme : matrice;
    loc : double;
    i,k : integer;
    puissX : vectorPuiss;
begin
    for k := 1 to 4 do puissX[k] := 0;
    puissX[0] := Nbre;
    for k := 1 to 3 do systeme[k,4] := 0;
    for i := debut to fin do begin
        loc := valeurX[i];
        for k := 1 to 4 do begin
            puissX[k] := puissX[k]+loc;
            loc := loc*valeurX[i];
        end;
        loc := valeurY[i];
        for k := 1 to 3 do begin
            systeme[k,4] := systeme[k,4]+loc;
            loc := loc*valeurX[i];
        end;
    end;
    for k := 1 to 3 do
         for i := 1 to 3 do
             systeme[k,i] := PuissX[k+i-2];
    Resolution(systeme,3,parametreGr);
end;

Procedure InitialiseSinus;
var i,idebut : integer;
    pente,zero : double;
    y0,a,periode,phase : double;
begin
    case genre of
       mgSinus : y0 := (maxY+minY)/2; // décalage de zéro
       mgSinusAmorti,mgQualite : begin
          y0 := 0;
          for i := debut to fin do
              y0 := y0+valeurY[i];
          y0 := y0/Nbre;
       end;
       else y0 := 0;
    end;
    a := (maxY-minY)/2; // amplitude
    i := debut;
    repeat inc(i)
    until ((valeurY[pred(i)]-y0)*(valeurY[succ(i)]-y0)<=0) or (i>Milieu);
// Passage par zéro à iDebut
    modeleOK := i<=Milieu;
    if not modeleOK then exit;
    iDebut := i;
    while (i<fin) and (abs(valeurY[i]-y0)<(a/3)) do inc(i);
// Hystérésis
    modeleOK := i<(fin-4);
    if not modeleOK then exit;
    repeat inc(i)
    until ((valeurY[pred(i)]-y0)*(valeurY[succ(i)]-y0)<=0) or (i>=(fin-1));
// Deuxième passage par zéro
    modeleOK := i<(fin-1);
    if not modeleOK then exit;
    Periode := 2*(valeurX[i]-valeurX[idebut]);
    i := debut;
    repeat
      inc(i);
      zero := (y0-valeurY[pred(i)])*(y0-valeurY[succ(i)]);
      pente := valeurY[succ(i)]-valeurY[pred(i)];
    until ( (zero<0) and (pente>0) ) or (i=(fin-2));
         // premier passage par zéro montant ou non trouvé
    modeleOK := i<(fin-2);
    if not modeleOK then exit;
    phase := frac(valeurX[i]/periode); // phase en tour
    if modeleCosinus then phase := phase + 0.25;
    if phase<0.5
       then phase := -2*pi*phase
       else phase := 2*pi*(1-phase); // -pi<phase<+pi
    if AngleEnDegre then phase := RadToDeg(phase); // degré/radian
    ParametreGr[1] := y0;
    ParametreGr[2] := a;
    ParametreGr[3] := periode;
    ParametreGr[4] := phase;
end;

Procedure InitialiseSigmoide;
var signe,ref : double;
    N : integer;
    systeme : matrice;
    i,j : integer;
    x,y : double;
    resultat : matriceLigne;
begin
    i := debut;
    ref := valeurY[debut]+(valeurY[fin]-valeurY[debut])/2;
    signe := valeurY[fin]-valeurY[debut];
    while (i<fin) and ((valeurY[i]-ref)*signe<0) do inc(i);
    parametreGr[1] := valeurY[debut];
    parametreGr[2] := valeurY[fin];
    parametreGr[3] := valeurX[i];
// la dérivée en x=x0 vaut -(ymax-ymin)*b/(4*x0)
// soit b=pente*4*x0/(ymin-ymax)
    for i := 1 to 2 do
        for j := 1 to 3 do systeme[i,j] := 0;
    N := Nbre div 3;
    j := 0;
    for i := debut+N to fin-N do begin
        x := valeurX[i];
        y := valeurY[i];
        systeme[1,2] := systeme[1,2]+x;
        systeme[2,2] := systeme[2,2]+x*x;
        systeme[1,3] := systeme[1,3]+y;
        systeme[2,3] := systeme[2,3]+y*x;
        inc(j);
    end;
    systeme[1,1] := j;
    systeme[2,1] := systeme[1,2];
    Resolution(systeme,2,resultat);
    parametreGr[4] := resultat[2]*4*parametreGr[3]/((parametreGr[1]-parametreGr[2]));
end;

Procedure InitialiseSinusAmorti;
var i1,i2 : integer;
    xs2,dYavant,dYapres,phase,t2 : double;
begin
   initialiseSinus;
   if not modeleOK then exit;
   i1 := debut;
   repeat
      inc(i1);
      dYavant := valeurY[i1]-valeurY[pred(i1)];
      dYapres := valeurY[succ(i1)]-valeurY[i1];
   until (i1=fin-3) or (dYavant*dYapres<=0);
   i2 := i1;
   t2 := valeurX[i1]+parametreGr[3]/2;
   repeat
      inc(i2)
   until (i2=fin-2) or (valeurX[i2]>t2);
   repeat
      inc(i2);
      dYavant := valeurY[i2]-valeurY[pred(i2)];
      dYapres := valeurY[succ(i2)]-valeurY[i2];
   until (i2=fin-1) or (dYavant*dYapres<=0);
   parametreGr[5] := (valeurX[i2]-valeurX[i1])/ln(
           abs((valeurY[i1]-parametreGr[1])/(valeurY[i2]-parametreGr[1])));
 // 5=constante de temps
   if AngleEnDegre
      then xs2 := 180
      else xs2 := pi;
   xs2 := parametreGr[3]*(1/4-parametreGr[4]/2/xs2);
   parametreGr[2] := parametreGr[2]*exp(xs2/parametreGr[5]);
   if genre=mgQualite then begin
// periode=3 phase=4 tau=5 donne pulsation=3 lambda=4 phase=5 //
      phase := parametreGr[4];
      parametreGr[3] := 2*pi/parametreGr[3];
// passage de période à pulsation : omega0=2pi/periode
      if AngleEnDegre then parametreGr[3] := RadToDeg(parametreGr[3]); // degré/radian
      parametreGr[4] := 1/parametreGr[3]/parametreGr[5];
// passage de constante de temps au facteur d'amortissement 1/tau=lambda*omega0
      parametreGr[5] := phase;
   end;
end;

Procedure InitialiseSinusDiverge;
var zero : double;
    NbrePeriode,NbreParPeriode : integer;

Procedure MaxLocal(debut,fin : integer;var t,m : double);
var i : integer;
    v : double;
begin
    m := abs(valeurY[debut]-zero);
    t := valeurX[debut];
    for i := succ(debut) to fin do begin
        v := abs(valeurY[i]-zero);
        if v>m then begin
           m := v;
           t := valeurX[i];
        end;
    end;
end;

Procedure CherchePeriodeFFT;
var NbreFFT,i : integer;
    PeriodeFFT : double;
    F,Vphase,Vampl : vecteur;
    Xr,Xi,Xa : vecteur;
    periode,phase : double;
    NbreMax : integer;
begin
    NbreMax := Puiss2Sup(fin);
    setLength(F,NbreMax+1);
    setLength(Xa,NbreMax+1);
    setLength(Vphase,NbreMax+1);
    setLength(Vampl,NbreMax+1);
    setLength(Xr,NbreMax+1);
    setLength(Xi,NbreMax+1);
    Fourier(Debut,Fin,NbreMax,NbreFFT,PeriodeFFT,
          valeurX,valeurY,F,Vampl,Vphase,
          Xr,Xi,Xa,c_spectre);
    SpectrePhase(Vphase,Xr,Xi,NbreFFT);
    i := getFondamental(NbreFFT,Xa);
    Periode := 1/F[i];
    Phase := Vphase[i];
    ParametreGr[3] := periode;
    ParametreGr[4] := phase;
    F := nil;
    Vampl := nil;
    Vphase := nil;
    Xr := nil;
    Xi := nil;
end;

Procedure CherchePeriode;
var i,idebut : integer;
    pente,y0,a,periode,phase : double;
begin
    y0 := 0;
    for i := debut to fin do
        y0 := y0+valeurY[i];
    y0 := y0/Nbre;
    a := (maxY-minY)/2;// amplitude
    i := fin;
    repeat dec(i)
    until ((valeurY[pred(i)]-y0)*(valeurY[succ(i)]-y0)<=0) or
           (i<=Milieu);
    modeleOK := i>Milieu;
    if not modeleOK then exit;
    iDebut := i;
    while (i<Nbre) and (abs(valeurY[i]-y0)<(a/2)) do dec(i);
//  Passage par maxi
    modeleOK := i>debut+3;
    if not modeleOK then exit;
    repeat dec(i)
    until ((valeurY[pred(i)]-y0)*(valeurY[succ(i)]-y0)<=0) or
           (i=debut);
    modeleOK := i>debut;
    if not modeleOK then exit;
    Periode := 2*abs(valeurX[i]-valeurX[idebut]);
    i := fin;
    repeat
      dec(i);
      zero := (y0-valeurY[pred(i)])*(y0-valeurY[succ(i)]);
      pente := valeurY[succ(i)]-valeurY[pred(i)];
    until ( (zero<0) and (pente>0) ) or (i=debut+2);
         // premier passage par zéro montant ou non trouvé 
    modeleOK := i>2;
    if not modeleOK then exit;
    phase := frac(valeurX[i]/periode); // phase en tour
    phase := -2*pi*phase;// -2.pi<phase<0
    if AngleEnDegre then phase := RadToDeg(phase);// degré/radian
    ParametreGr[1] := y0;
    ParametreGr[2] := a;
    ParametreGr[3] := periode;
    ParametreGr[4] := phase;
    NbrePeriode := round((valeurX[fin]-valeurX[debut])/periode);
    NbreParPeriode := Nbre div NbrePeriode;
    if NbreParPeriode<16 then CherchePeriodeFFT;
end;

var t1,v1,t2,v2 : double;
    N : integer;
begin
   CherchePeriode;
   if not modeleOK then exit;
   if NbrePeriode>12
      then begin
         N := Nbre div 6;
         MaxLocal(4*N,5*N,t1,v1);
 // Pas la fin saturation possible
 // On laisse de côté le milieu de 2N à 4N
         MaxLocal(N,2*N,t2,v2);
 // Pas le début bruit
      end
      else begin
         N := NbreParPeriode div 2;
         MaxLocal(milieu+N,fin-N,t1,v1);
    // Pas la fin saturation possible
         MaxLocal(debut+N,milieu-N,t2,v2);
         { Pas le début bruit }
      end;
   parametreGr[5] := (t2-t1)*ln(v2/v1);
   parametreGr[2] := v1*exp(-t1/parametreGr[5]);
end; // InitialiseSinusDiverge

Procedure InitialiseEchelon1;
var a : double;
    i : integer;
    ecart : double;
begin
     if changeDebutDemande then begin // préacquisition éventuelle
        ecart := abs(valeurY[fin]-valeurY[debut])/(fin-debut);
        while (debut<fin-2) and (abs(valeurY[debut+1])<ecart) do inc(debut);
     end;
     if abs(valeurY[debut])>abs(valeurY[fin]) then begin
        modeleOK := false;
        exit;
     end;
     if abs(minY)> abs(maxY)
        then ParametreGr[1] := minY
        else ParametreGr[1] := maxY;
     i := debut;
     a := abs(parametreGr[1]*(1-exp(-1)));
     repeat inc(i)
     until (i=fin) or (abs(valeurY[i])>a);
     ParametreGr[2] := valeurX[i]-valeurX[debut];
end;  // InitialiseEchelon1

Procedure InitialiseRadio;
const PrecisionSuffisante = 0.05;
var a,a0 : double;
    i : integer;
    changeDebut : boolean;
    precisionModele : double;
    sommeCarreY : double;
    J,ecart : double;
    sauveDebut : integer;
begin
     if abs(minY)> abs(maxY)
        then ParametreGr[1] := minY
        else ParametreGr[1] := maxY;
     a := abs(parametreGr[1]/exp(1));
     if changeDebutDemande then begin // préacquisition éventuelle
        sauveDebut := debut;
        while (debut<fin) and (abs(valeurY[debut])<a) do inc(debut);
        i := debut;
        repeat inc(i)
        until (i=fin) or (abs(valeurY[i])<a);
        ParametreGr[2] := valeurX[i]-valeurX[debut]; // tau
        SommeCarreY := 0;
        J := 0;
        a0 := ParametreGr[1]*exp(valeurX[debut]/ParametreGr[2]);
        for i := debut to fin do begin
            SommeCarreY := SommeCarreY + sqr(valeurY[i]);
            Ecart := a0*exp(-valeurX[i]/ParametreGr[2])-valeurY[i];
            J := J + sqr(ecart);
        end;
        PrecisionModele := sqrt(J/SommeCarreY);
        changeDebut := (debut>0) and (PrecisionModele<PrecisionSuffisante);
        if changeDebut then begin
           pages[pageCourante].debut[numeroModele] := debut;
           a0 := valeurX[debut];
           for i := 0 to pred(Pages[pageCourante].nmes) do
               Pages[pageCourante].valeurVar[indexX,i] :=
                   Pages[pageCourante].valeurVar[indexX,i]-a0;
        end
        else debut := sauveDebut;
     end;
     i := debut;
     repeat inc(i)
     until (i=fin) or (abs(valeurY[i])<a);
     ParametreGr[2] := valeurX[i]-valeurX[debut];
     if abs(valeurY[debut])<abs(valeurY[fin]) then begin
        modeleOK := false;
        exit;
     end;
end; // InitialiseRadio

Procedure InitialiseGauss;
var a : double;
    i : integer;
begin
     ParametreGr[1] := maxY;
     ParametreGr[2] := valeurX[posMaxY];
     a := maxY*exp(-1/2);
     i := posMaxY;
     repeat inc(i)
     until (i=fin) or (valeurY[i]<a);
     ParametreGr[3] := valeurX[i]-ParametreGr[2];
end;

Procedure InitialiseLorentz;
var a : double;
    i : integer;
begin
     ParametreGr[2] := valeurX[posMaxY];
     a := maxY/2;
     i := posMaxY;
     repeat inc(i)
     until (i=fin) or (valeurY[i]<a);
     ParametreGr[3] := 2*(valeurX[i]-ParametreGr[2]);
     ParametreGr[1] := maxY*sqr(ParametreGr[3])/4;
end;

Procedure InitialiseFiltre1;
var a : double;
    i : integer;
begin
     ParametreGr[1] := maxY;
     if ModeleDecibel
        then a := maxY-3
        else a := maxY/sqrt(2);
     case genre of
          mgPasseBas1 : begin
             i := debut;
             repeat inc(i)
             until (i=fin) or (valeurY[i]<a);
          end;
          mgPasseHaut1 : begin
             i := fin;
             repeat dec(i)
             until (i=debut) or (valeurY[i]<a);
          end;
          else i := (debut+fin) div 2;
     end;
     ParametreGr[2] := valeurX[i]; // fréquence de coupure
end;

Procedure InitialiseFiltre2;
var a : double;
    i,n : integer;
begin
     a := 0;
     n := (fin-debut) div 20;
     if genre=mgPasseBas2
        then for i := debut to debut+n do a := a + valeurY[i]
        else for i := fin-n to fin do a := a + valeurY[i];
     a := a/(n+1);
     ParametreGr[1] := a;
     if maxY>a
        then i := posMaxY { résonance }
        else begin
             if modeleDecibel
                then a := a-3
                else a := a/sqrt(2);
             case genre of
          mgPasseBas2 : begin
             i := debut;
             repeat inc(i)
             until (i=fin) or (valeurY[i]<a);
          end;
          mgPasseHaut2 : begin
             i := fin;
             repeat dec(i)
             until (i=debut) or (valeurY[i]<a);
          end;
          else i := (debut+fin) div 2;
            end;
     end;
     ParametreGr[2] := valeurX[i];// fréquence de coupure
     ParametreGr[3] := maxY/a; // Q ou QdB approx
     if modeleDecibel then
        ParametreGr[3] := power(10,ParametreGr[3]/20);// Q
     if not ModeleFacteurQualite then ParametreGr[3] := 1/2/ParametreGr[3]; { m }
end;

Procedure InitialisePasseBande;

Procedure ChercheDroite(i1,i2 : integer;var pente,origine : double);
var systeme : matrice;
    x,y : double;
    i,j,k : integer;
    OriginePente : matriceLigne;
begin
    for k := 1 to 2 do
        for j := 1 to 3 do systeme[k,j] := 0;
    systeme[1,1] := i2-i1+1;
    for i := i1 to i2 do begin
        x := ln(valeurX[i]);
        y := ln(valeurY[i]);
        systeme[1,2] := systeme[1,2]+x;
        systeme[2,2] := systeme[2,2]+x*x;
        systeme[1,3] := systeme[1,3]+y;
        systeme[2,3] := systeme[2,3]+y*x;
    end;
    systeme[2,1] := systeme[1,2];
    Resolution(systeme,2,OriginePente);
    Origine := OriginePente[1];
    Pente := OriginePente[2];
end;

var i,N : integer;
    Origine1,Pente1,Origine2,Pente2 : double;
begin
     ParametreGr[1] := maxY;
     i := debut;
     repeat inc(i)
     until (i=fin) or (valeurY[i]=maxY);
     ParametreGr[2] := valeurX[i];
     N := (fin-debut) div 10;
     if N<3 then N := 3;
     ChercheDroite(debut,debut+N,pente1,origine1);
     ChercheDroite(fin-N,fin,pente2,origine2);
     ParametreGr[3] := ParametreGr[1]/exp((Origine1*pente2-Origine2*pente1)/(pente2-pente1))
end;

begin // InitialiseParametre
    indexX := indexNom(nX);
    changeDebutDemande := changeDebutDemande and
        (ModeleGraphique[1].genre in [mgEchelon1,mgRadio]) and
        (debut=0) and (succ(fin)=pages[pageCourante].nmes) and
        (indexX=0);
    setLength(valeurX,fin+1);
    copyVecteur(valeurX,grandeurs[indexX].valeur);
    indexY := indexNom(nY);
    setLength(valeurY,fin+1);
    copyVecteur(valeurY,grandeurs[indexY].valeur);
    while isNan(valeurY[debut]) or
          isNan(valeurX[debut])
            do inc(debut);
    while isNan(valeurY[fin]) or
          isNan(valeurX[fin])
            do dec(fin);
    maxX := valeurX[debut];
    minX := maxX;
    maxY := valeurY[debut];
    posMaxY := debut;
    minY := maxY;
    Nbre := fin-debut+1;
    Milieu := debut+(Nbre div 2);
    for i := succ(debut) to fin do begin
        if valeurY[i]>maxY
           then begin
              maxY := valeurY[i];
              posMaxY := i;
           end
           else if valeurY[i]<minY then minY := valeurY[i];
        if valeurX[i]>maxX
           then maxX := valeurX[i]
           else if valeurX[i]<minX then minX := valeurX[i];
    end;
    modeleOK := true;
    try
    case genre of
          mgLineaire :InitialiseLineaire;
          mgAffine :InitialiseAffine;
          mgAffineDouble :InitialiseAffineDouble;
          mgPuissance :InitialisePuissance;
          mgParabolique :InitialiseParabolique;
          mgHyperbolique :InitialiseHyperbolique;
          mgSinus :InitialiseSinus;
          mgSinusAmorti,mgQualite :InitialiseSinusAmorti;
          mgSigmoide : InitialiseSigmoide;
          mgSinusDiverge :InitialiseSinusDiverge;
          mgEchelon1 : InitialiseEchelon1;
          mgRadio : InitialiseRadio;
          mgPasseBas1,mgPasseHaut1 : InitialiseFiltre1;
          mgPasseBas2,mgPasseHaut2 : InitialiseFiltre2;
          mgPasseBande : InitialisePasseBande;
          mgGauss : InitialiseGauss;
          mgLorentz : InitialiseLorentz;
   end;
   except
       modeleOK := false;
   end;
   valeurX := nil;
   valeurY := nil;
end; // InitialiseParametre


Procedure TmodeleGr.GetParametres(var P : TableauParam);
var k,index : integer;
begin
     for k := 1 to NbreParamMagnum[genre] do begin
         index := IndexToParam(indexNom(nomParam[k]));
         P[index] := parametreGr[k]
     end;
end;

Procedure TmodeleGr.SetParametres(var P : TableauParam);
var k,index : integer;
begin
     for k := 1 to NbreParamMagnum[genre] do begin
         index := IndexToParam(indexNom(nomParam[k]));
         parametreGr[k] := P[index];
     end;
end;

constructor TmodeleGr.Create;
begin
   Expression := TstringList.Create ;
   numeroModele := 1;
end;

destructor TmodeleGr.Destroy;
begin
   Expression.Free;
   inherited destroy;
end;

Procedure CreateModeleGr;
var i : codeIntervalle;
begin
    for i := 1 to maxIntervalles do begin
       ModeleGraphique[i] := TmodeleGr.create;
       ModeleParametre[i] := TmodeleGr.create
    end;
end;

Procedure DestroyModeleGr;
var i : codeIntervalle;
begin
    for i := 1 to maxIntervalles do begin
       ModeleGraphique[i].free;
       ModeleParametre[i].free
    end;
end;

procedure TModeleGr.ImagePaint(Canvas: TCanvas;const ARect: TRectF;tag : integer);
var ay,by,bx,ax : single;
    genreLoc : TgenreModeleGr;
    Imax : integer;
    Fpath : TPathData;
    debut : boolean;

procedure pointSuivant(I : integer);
var x,y,u : single;
    aPoint : TpointF;
begin
      y := by;
      x := I+bX;
      case genreLoc of
          mgLineaire : y := ay*(I-ax)/Imax/1.5+bY;
          mgAffine : y := ay*(I-ax)/Imax+3*bY/2;
          mgPuissance : y := ay*sqr(1.5*I/Imax)+by;
          mgParabolique : y := ay*sqr(1.5*(I-ax)/Imax)+3*by/2;
          mgHyperbolique : y := ay/(3*I/Imax+1)+by; // Michaelis
          mgSinus : y := ay*sin(I/4)+bY;
          mgSinusAmorti,mgQualite : y := ay*sin(I/2)*exp(-2*I/Imax)+bY;
          mgSinusDiverge : y := ay*sin(I/2)*exp(2*I/Imax)+bY;
          mgSigmoide : y := ay/(1+6*sqr(I/Imax))+by;
          mgGauss : y := ay*exp(-sqr(I/Imax-0.5)*5)+by;
          mgLorentz : y := ay/(1+5*sqr(I/Imax-0.5))+by;
          mgEchelon1 : y := ay*(1-exp(-4*I/Imax))+by;
          mgRadio : y := ay*exp(-3*I/Imax)+by;
          mgPasseBas1 : begin
             u := (I+0.001)/(Imax*0.35);
             y := ay*0.85/sqrt(1+sqr(u))+by;
          end;
          mgPasseHaut1 : begin
             u := (I+0.001)/(Imax*0.35);
             y := ay*0.85*u/sqrt(1+sqr(u))+by;
          end;
          mgPasseBas2 : begin
             u := (I+0.001)/(Imax*0.35);
             y := ay*0.45/sqrt(sqr(1-sqr(u))+sqr(0.5*u))+by;
          end;
          mgPasseHaut2 : begin
             u := (I+0.001)/(Imax*0.35);
             y := ay*0.45*sqr(u)/sqrt(sqr(1-sqr(u))+sqr(0.5*u))+by;
          end;
          mgPasseBande : begin
             u := (I+0.5)/(Imax*0.5);
             y := ay*0.85/sqrt(1+sqr(3*(u-1/u)))+by;
          end;
     end;
     if (y>arect.top) and (y<arect.bottom) then begin
        aPoint := TPointF.create(x,y);
        if debut
           then FPath.moveTo(aPoint)
           else FPath.lineTo(aPoint);
        debut := false;
     end;
end;

var i : integer;
begin
     genreLoc := TgenreModeleGr(tag);
     FPath := TPathData.Create;
     canvas.stroke.Color := claBlack; // axes
     bY := (arect.top+arect.bottom)/2;
     aY := (arect.top-arect.bottom);
     ax := (arect.right+arect.left)/2;
     bX := arect.left;
     case genreLoc of
          mgLineaire : ;
          mgAffine : ;
          mgPuissance : by := by*2;
          mgParabolique : ;
          mgHyperbolique : by := by*2;
          mgSinus : ay := ay/2.4;
          mgSinusAmorti,mgQualite : ay := ay/2;
          mgSinusDiverge : ay := ay/15;
          mgSigmoide : by := by*2;
          mgGauss,mgLorentz : begin
             by := by*2;
             ay := ay/1.1;
          end;
          mgEchelon1 : begin
            by := by*2;
            ay := ay/1.2;
          end;
          mgRadio : by := by*2;
          mgPasseBas1,mgPasseHaut1,mgPasseBas2,mgPasseHaut2,mgPasseBande :
             by := arect.bottom-2;
     end;
     debut := true;
     Imax := trunc(arect.right-arect.left);
     FPath.moveTo(TPointF.create(bx,by));
     FPath.lineTo(TPointF.create(arect.right,by));
     if genreLoc in [mgLineaire,mgAffine,mgParabolique]
        then begin
           FPath.moveTo(TPointF.create(ax,arect.bottom));
           FPath.lineTo(TPointF.create(ax,arect.top));
        end
        else begin
           FPath.moveTo(TPointF.create(bx,arect.bottom));
           FPath.lineTo(TPointF.create(bx,arect.top));
        end;
     Canvas.DrawPath(FPath, 1);
     FPath.Clear;
     canvas.stroke.Color := claRed; // courbes
     for I := 0 to Imax do PointSuivant(I);
     Canvas.DrawPath(FPath, 1);
     FPath.Free;
end;

initialization
    CreateModeleGr;

Finalization
    DestroyModeleGr
end.
