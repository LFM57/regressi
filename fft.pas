Unit fft;

interface

Uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Math,

// Pour gestion fichiers son
  {$IFDEF MACOS}
  Posix.Unistd,
  {$ENDIF}
  {$IFDEF MSWINDOWS}
   Winapi.Windows,
  {$ENDIF}

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

  MATHS;

type Tfenetre = (rectangulaire,Hamming,FlatTop,Blackman,rectangleAjuste);
     TcalculFFT = (c_spectre,c_correlation,c_enveloppe);
     TordonneeFFT = (oNormal,oReduite,oPuissance);

const
      NbrePointsSonagramme = 1024;
      NbreMaxSonagramme = 256; // MaxMaxVecteur div NbrePointsSonagramme
      PasSonCalcul = 3;
      PasTempsSonagramme = 0.03; // 30 ms
      MaxVecteurSon = 2646000; // 2,6 Mo ; 1 minute à 44100 Hz
      nomFenetre : array[Tfenetre] of string =
        ('Rectangle','Hamming','Toit plat','Blackman','Rect. corrigée');
      indexFenetre : array[Tfenetre] of integer =
        (64,67,69,66,65);

var
      fenetre : Tfenetre = rectangulaire;
      avecPeriode : boolean = false;

type
     TmatriceSonagramme = array[0..NbreMaxSonagramme,0..NbrePointsSonagramme] of single;
     PmatriceSonagramme = ^TmatriceSonagramme;

     EWavError = class(Exception);
     TformatWave = (f8,f16,f24,f32);
     Tmemblock8 = array of byte;
     Tmemblock16 = array of smallInt;
     Tmemblock8s = array of array[0..1] of byte;
     Tmemblock16s = array of array[0..1] of smallInt;
     TvecteurSon = class
             FNbrePoints : longInt;
             function GetNbit : integer;
             public
             formatWave : TformatWave;
             freqAudio : longWord;
             valeur,valeurBis : array of single;
             stereo : boolean;
             property NbrePoints : longInt read FNbrePoints;
             procedure lit(NomFichier : string);
             property Nbit : integer read GetNbit;
             destructor Destroy; override;
     end;

var son : PmatriceSonagramme;
    pasFreqSonagramme : double;
    NbreSonagrammeAff : integer;
    FreqMaxSonagramme : double;
    NbreSonagramme : integer;

Procedure Fourier(Debut,Fin,Maxi : integer;var NbreF : integer;var periode : double;
          T,X,F,Tlisse,Xlisse,Xr,Xi,Xa : vecteur;calculFFT : tcalculFFT);
Procedure FourierFiltre(Nbre : integer;var periode : double;T,X,Xr,Xi : vecteur);
Procedure FourierInverse(Nbre,NbreF,debutFFT : integer;periode : double;
          T,X,Xr,Xi : vecteur;calculFFT : tcalculFFT);
Function PuissInt(X,N:integer) : integer; // X^N avec N>=0 
Procedure SpectrePhase(var ph : vecteur;Xr,Xi : vecteur;nb : integer);
Procedure EnveloppeFourier(Nbre,NbreMax : integer;Periode : double;X,F,A : vecteur);
Procedure Sonagramme(Nbre : integer;X : vecteur;FreqEch : double);
Function GetFondamental(Nbre : integer;Xa : vecteur) : integer;
Function GetMaxiFFT(Nbre : integer;Xa : vecteur) : double;
Procedure EnveloppeReelle(Nbre,NbreF : integer;periode : double;
                T,X,Xr,Xi : vecteur);// Norme du signal analytique

Implementation

var
    coeffZeroPadding,coeffFenetrage : double;
    nbreFcourant : integer;
    fenetreCourante : Tfenetre;
    zeroPadding : boolean;
    tbi : vecteurInt;
    wr,wi,kf : vecteur;

Function PuissInt(X,N:integer) : integer; // X^N avec N>=0
var Y,i : integer;
begin
    Y := 1;
    for i := 1 to N do Y := Y*X;
    PuissInt := Y;
end;

Procedure spectrePhase(var ph : vecteur;Xr,Xi : vecteur;nb : integer);
var i : integer;
begin
    if high(ph)<nb then setLength(ph,nb);
    for i:=1 to pred(nb) do
        ph[i] := atan2(xi[i],xr[i]);
end;

procedure fenetrer(tableau,Xr,Xi : vecteur;nb : integer);
var j : integer;
    xx : double;
begin
     for j:=0 to pred(nb) do begin
         xx := kf[j]*tableau[j]; // fenêtrage
         tableau[j] := xx;
         xr[tbi[j]] := xx;
// rangement avec permutation des mesures tableau fenêtrées dans xr[]
         xi[j]:=0;
     end;
     try
     case fenetre of
           Hamming : coeffFenetrage := 1.852;
           Blackman : coeffFenetrage := 2.381;
           FlatTop : coeffFenetrage := 4.638;
           else coeffFenetrage := 1.0;
     end;
     if not (fenetre in [rectangulaire,rectangleAjuste]) then
        for j:=0 to pred(nb) do begin // renormaliser
           xr[j] := xr[j]*coeffFenetrage;
           tableau[j] := tableau[j]*coeffFenetrage;
        end;
      except
      end;  
end;

procedure fenetrerInverse(xr,xi : vecteur;nb : integer);
var j : integer;
    xxr,xxi : vecteur;
begin
     copyVecteur(xxr,xr);
     copyVecteur(xxi,xi);
     xr[0]:=2*xr[0];
     xi[0]:=2*xi[0];
     for j:=1 to pred(nb) do begin
         xr[tbi[j]]:=xxr[j];
         xi[tbi[j]]:=xxi[j];
// rangement avec permutation des mesures xr,xi dans xxr,xxi
     end;
     xxr := nil;
     xxi := nil;
end;

PROCEDURE tfd(nb : integer;xr,xi : vecteur;Normalise : boolean);
// Transformation proprement dite
var a,i,j,k,k0,nbbloc,tbloc,r,r0,p0,nombre0 : integer;
    zr,zi,c : double;
begin
  nbbloc:=nb;
  tbloc:=1;
  r:=trunc(0.5+Ln(nb)/ln(2));
  FOR i:=1 TO r do begin
          tbloc:=2*tbloc;
          nbbloc:=nbbloc div 2;
          FOR j:=1 TO nbbloc do begin
             nombre0:=(nb div nbbloc -1) div 2;
             r0:=0;
             FOR k0:=0 TO nombre0 do begin
                    k:=k0+(pred(j))*tbloc;
                    p0:=k+tbloc div 2;
                    a:=r0;
                    zr:=xr[p0]*wr[a]-xi[p0]*wi[a];
                    zi:=xr[p0]*wi[a]+xi[p0]*wr[a];
                    xr[p0]:=xr[k]-zr;
                    xi[p0]:=xi[k]-zi;
                    xr[k]:=xr[k]+zr;
                    xi[k]:=xi[k]+zi;
                    r0:=r0+nbbloc;
             end; {k0}
          end; {j}
  end; {i}
  if normalise
     then begin
         c:=2/nb;
         xr[0]:=xr[0]/2;
     end
     else c := 1/2;
  for i:= 0 to pred(nb) do begin
         xr[i]:=c*xr[i];
         xi[i]:=c*xi[i];
  end;
end;

PROCEDURE inverserIndices(nb : integer);
// Table de l'ordre inverse des bits
var i,j,k,r,p0,q,tiroir : integer;
    dpsn : double;
    angle : double;
begin
  if (nbreFcourant=nb) and (fenetre=fenetreCourante) then exit;
  if high(wr)<(nb-1) then begin
     setLength(tbi,nb);
     setLength(wr,nb);
     setLength(wi,nb);
     setLength(kf,nb);
  end;
  dpsn:=-2*pi/nb;
  FOR i:=0 TO pred(nb) do begin
         angle := dpsn*i;
         wr[i] := cos(angle);
         wi[i] := sin(angle);
// ATTENTION : les indices ne sont pas permutés
// la permutation selon tbi[] sera faite dans le fenêtrage
         case fenetre of
              Hamming  : kf[i] :=0.54-0.46*cos(i*dpsn);
              Blackman : kf[i] :=0.42-0.5*cos(i*dpsn)+0.08*cos(2*i*dpsn);
              FlatTop  : kf[i] :=0.2156-0.416*cos(i*dpsn)
                                     +0.2781*cos(2*i*dpsn)
                                     -0.0836*cos(3*i*dpsn)
                                     +0.069*cos(4*i*dpsn);
              else kf[i] :=1.0;
         end;
    end;
    for i:=0 to pred(nb) do tbi[i]:=i;
    r:=trunc(0.5+Ln(nb)/ln(2));
    for i:=0 to pred(nb) do begin
      p0:=r;
      q:=1;
      k:=0;
      for j:=1 to r do begin
           if (i and puissInt(2,pred(p0)))<>0 then k:=k+q;
           q:=2*q;
           dec(p0);
      end;
      if k>i then begin
            tiroir:=tbi[k];
            tbi[k]:=tbi[i];
            tbi[i]:=tiroir;
      end;
    end;
    nbreFcourant := nb;
    fenetreCourante := fenetre;
end; // inverserIndices

PROCEDURE inverserIndicesInverse(nb : integer);
// Table de l'ordre inverse des bits
var i,j,k,r,p0,q,tiroir : integer;
    dpsn : double;
begin
  if high(wr)<nb then begin
     setLength(tbi,nb);
     setLength(wr,nb);
     setLength(wi,nb);
     setLength(kf,nb);
  end;
  dpsn:=2*pi/nb;
  FOR i:=0 TO pred(nb) do begin
         wr[i]:=COS(dpsn*i);
         wi[i]:=SIN(dpsn*i);
  end;
  FOR i:=0 TO pred(nb) do tbi[i]:=i;
  r:=trunc(0.5+Ln(nb)/ln(2));
  FOR i:=0 TO pred(nb) do begin
      p0:=r;
      q:=1;
      k:=0;
      FOR j:=1 TO r do begin
           IF (i AND puissInt(2,pred(p0)))<>0 then k:=k+q;
           q:=2*q;
           dec(p0);
      end;
      IF k>i then begin
            tiroir:=tbi[k];
            tbi[k]:=tbi[i];
            tbi[i]:=tiroir;
      end;
  end;
  nbreFcourant := 0;
end; // inverserIndicesInverse

Procedure corrigeAmplitude(var freq,ampli,Yr,Yi : vecteur;var periode : double;NbreFFT : integer);
var i,imax,i0,iRef : integer;
    valeurMax,deltaF,maxA : double;
// En entrée freq et ampl les valeurs issues d'une FFT avec fenêtre rectangulaire
// En sortie on a remplacé les raies excentrées par non synchronisation par la "vraie" raie

function AjusteFrequence(var j1 : integer) : boolean;

Function MyArcTan2(im,re:double) : double;
// z = re + j*im
begin
   if re=0
      then if im<0
          then result := -pi/2
          else result := pi/2
      else result := arcTan2(im,re);
end;

Function sincard(x : double) : double;
begin
   try
      if isZero(x,1e-6)
         then result := 1
         else result := sin(x)/x;
   except
      result := 1
   end;
end;

var i,j2,j3 : integer;
    F0,A0 : double;
    phase0,argument,A : double;
begin
    repeat
       inc(j1)
    until (j1>imax) or
          ((ampli[j1+1]<ampli[j1]) and
           (ampli[j1]>valeurMax)); // maximum  local en j1
    result := j1<=imax;
    if not result then exit;
    if ampli[j1-1]>ampli[j1+1] then j2 := j1-1 else j2 := j1+1;
    F0 := 1-(ampli[j1]/(ampli[j2]+ampli[j1]));
// F0>0 est ici l'écart / maxi du sinc
    A0 := ampli[j1]/sincard(pi*F0);
    phase0 := MyArctan2(Yi[j1],Yr[j1]);
// la non synchronisation crée également un déphasage de pi*(f0-f)*T
// T = 1/deltaf = 1 en numéro
    if j1>j2
       then begin
          phase0 := phase0+pi*F0;
          F0 := j1-F0
       end else begin
          phase0 := phase0-pi*F0;
          F0 := j1+F0;
       end;
 // F0 en numéro
    j2 := j1;
    repeat dec(j2)
    until (j2<=2) or (ampli[j2]<ampli[j2-1]);
    j3 := j1;
    repeat inc(j3)
    until (j3>=imax) or (ampli[j3]<ampli[j3+1]);
    for i := j2 to j3 do begin
       argument := pi*(F0-i);
       A := A0*sincard(argument);
       argument := phase0+argument;
       Yr[i] := Yr[i]-A*cos(argument);
       Yi[i] := Yi[i]-A*sin(argument);
       ampli[i] := sqrt(sqr(Yr[i])+sqr(Yi[i]));
       freq[i] := (F0+i-j1)*deltaF; // F0 en Hz
       if Ampli[i]>maxA then begin
           iref := i;
           maxA := ampli[i];
       end;
    end;
    ampli[j1] := A0;
    Yr[j1] := A0*cos(phase0);
    Yi[j1] := A0*sin(phase0);
    freq[j1] := F0*deltaF; // F0 en Hz
    if A0>maxA then begin
       iref := j1;
       maxA := A0;
    end;
    j1 := j3;
end; // AjusteFrequence

begin
     deltaF := freq[1];
// ne marche pas dans le cas où fréquence signal de l'ordre du pas
     imax := (NbreFFT div 2) - 2;
     i0 := 0;
     repeat inc(i0)
     until (ampli[i0]>ampli[i0-1]) or (i0>=imax); // on évite le continu
     valeurMax := 0;
     maxA := 0;
     for i:= i0 to imax do
         if ampli[i]>valeurMax then valeurMax := ampli[i];
     valeurMax := valeurMax / 50;
     iRef := i0;
     while AjusteFrequence(i0) do;
     periode := iRef/Freq[iRef];
end; // corrigeAmplitude

Procedure Fourier(Debut,Fin,Maxi : integer;var NbreF : integer;var periode : double;
   T,X,F,Tlisse,Xlisse,Xr,Xi,Xa : vecteur;calculFFT : TcalculFFT);
var Nbre : integer;

Procedure SetZero;
var deltat : double;
    i : integer;
begin
     NbreF := Puiss2Sup(Nbre);
     if (calculFFT=c_correlation) and
        (2*NbreF<=Maxi) then NbreF := 2*NbreF;
// Interdit pour spectre car on obtient le spectre du signal discrétisé 
     Deltat := Periode/Nbre;
     Periode := NbreF*deltat;
     for i := 0 to pred(Nbre) do begin
           Xlisse[i] := X[i+debut];
           Tlisse[i] := T[i+debut];
     end;
     for i := Nbre to pred(NbreF) do begin
           Xlisse[i] := 0;
           Tlisse[i] := Tlisse[0]+i*deltat;
     end;
     ZeroPadding := true;
end;

Procedure setInterp;
begin
      NbreF := Puiss2Inf(Nbre);
      CalculIntLineaire(T,X,Debut,Fin,NbreF,Tlisse,Xlisse);
      ZeroPadding := false;
end;

// const Aflat : array[1..4] of double = (0.934516,0.597986,0.179644,0.015458);

var i : integer;
    Df : double;
begin
     Nbre := Fin-Debut+1;
     Periode := (T[fin]-T[debut])/pred(Nbre)*Nbre;
     case calculFFT of
          c_spectre : setZero;
          c_correlation : setZero; // zeroPadding obligatoire pour corrélation
          c_enveloppe : setInterp;
     end;
     inverserIndices(NbreF);
     fenetrer(Xlisse,xr,xi,NbreF);
     tfd(NbreF,xr,xi,true);
     Df := 1/periode;
     if zeroPadding then begin
          coeffZeroPadding := NbreF/Nbre;
          for i := 0 to NbreF div 2 do begin
              xr[i] := xr[i]*coeffZeroPadding;
              xi[i] := xi[i]*coeffZeroPadding;
          end;
     end;
     if high(Xa)<(NbreF div 2) then setLength(Xa,NbreF div 2);
     for i := 0 to (NbreF div 2) do begin
         F[i] := i*Df;
         Xa[i]:=sqrt(sqr(xr[i])+sqr(xi[i]));
     end;
     if fenetre=rectangleAjuste then corrigeAmplitude(f,Xa,xr,xi,periode,NbreF)
end; // Fourier

Procedure FourierFiltre(Nbre : integer;var periode : double;
   T,X,Xr,Xi : vecteur);
begin
     Periode := (T[Nbre-1]-T[0])/pred(Nbre)*Nbre;
     inverserIndices(Nbre);
     fenetrer(X,xr,xi,Nbre);
     tfd(Nbre,xr,xi,true);
end;

Procedure FourierInverse(Nbre,NbreF,debutFFT : integer;Periode : double;
      T,X,Xr,Xi : vecteur;calculFFT : tcalculFFT);
var i : integer;
    iAvant,iApres : integer;
    deltat,ecart : double;
    xxr,xxi : vecteur;
begin
     CopyVecteur(xxr,xr);
     CopyVecteur(xxi,xi);
     inverserIndicesInverse(NbreF);
     fenetrerInverse(xxr,xxi,NbreF);
     tfd(NbreF,xxr,xxi,false);
     case calculFFT of
          c_spectre : zeroPadding := true;
          c_correlation : zeroPadding := true;
          c_enveloppe : zeroPadding := false;
     end;
     if zeroPadding then begin
          coeffZeroPadding := Nbre/NbreF;
          for i := 0 to pred(NbreF) do
              xxr[i] := xxr[i]*coeffZeroPadding;
     end;
     if not (fenetre in [Rectangulaire,RectangleAjuste]) then
        for i := 0 to pred(NbreF) do
            xxr[i] := xxr[i]/kf[i]/coeffFenetrage;
     deltat := Periode/NbreF; // NbreF et non Nbre à cause choix de période et interpolation
     for i := 0 to pred(Nbre) do begin
         iAvant := trunc((T[i]-T[debutFFT])/deltat);
         ecart := T[i]-T[debutFFT]-iAvant*deltat;
         iAvant := iAvant mod NbreF; { périodiser }
         if iAvant<0 then inc(iAvant,NbreF);
         iApres := succ(iAvant) mod NbreF;
         x[i] := xxr[iAvant]+(xxr[iApres]-xxr[iAvant])*ecart/deltat;{ interpoler }
     end;
     xxr := nil;xxi := nil;
end;//FourierInverse

Procedure EnveloppeFourier(Nbre,NbreMax : integer;Periode : double;X,F,A : vecteur);
var i : integer;
    Df,coeff : double;
    xr,xi : vecteur;
    xLisse : vecteur;
    sauveFenetre : Tfenetre;
begin
     setLength(xLisse,NbreMax);
     setLength(xr,NbreMax);
     setLength(xi,NbreMax);
     sauveFenetre := fenetre;
     fenetre := rectangulaire;
     CopyVecteur(Xlisse,X);
     setLength(xLisse,NbreMax);
 //    for i := Nbre to pred(NbreMax) do Xlisse[i] := 0;
     inverserIndices(NbreMax);
     fenetrer(Xlisse,xr,xi,NbreMax);
     tfd(NbreMax,xr,xi,true);
     Df := Nbre/NbreMax/Periode;
     coeff := NbreMax/Nbre;
     coeff := coeff*coeffZeroPadding;
     for i := 0 to NbreMax div 2 do begin
         F[i] := i*Df;
         A[i] := sqrt(sqr(Xr[i])+sqr(Xi[i]))*coeff;
     end;
     fenetre := sauveFenetre;
     Xlisse := nil;
     Xr := nil;
     Xi := nil;
end;

Procedure Sonagramme(Nbre : integer;X : vecteur;FreqEch : double);
var Xlisse : vecteur;
    Xr,Xi,Xa,coeffWin : vecteur;
    NbreCalcul,pas,decalage : integer;

PROCEDURE fenetrage; // Hamming
var i,N : integer;
    dpsn : double;
begin
  N := NbreCalcul div pas;
  dpsn := -2*pi/N;
  for i := 0 to pred(N) do
      coeffWin[i] := 0.54-0.46*cos(i*dpsn);
 // donc 0,08 sur les bords et 1 au centre
end;

Procedure FourierSonagramme(Debut,Fin : integer);
var i,j,N : integer;
    decale : integer;
begin
     N := NbreCalcul div pas;
     decale := debut-decalage;
     if decale<0 then decale := 0;
     if (N*pas+decale)>Nbre then N := (Nbre-decale) div pas;
     for i := 0 to pred(N) do
         Xlisse[i] := coeffWin[i]*X[i*pas+decale];
     for i := N to pred(NbrePointsSonagramme) do
         Xlisse[i] := 0;
     for j:=0 to pred(NbrePointsSonagramme) do begin
         xr[tbi[j]] := Xlisse[j];
// rangement avec permutation des mesures tableau fenêtrées dans xr[]
         xi[j]:=0;
     end;
     tfd(NbrePointsSonagramme,xr,xi,false);
     for i := 0 to (NbrePointsSonagramme div 2) do
         Xa[i]:=sqrt(sqr(xr[i])+sqr(xi[i]));
end; // FourierSonagramme

var i,j : integer;
    sonMax : double;
begin
    try
    if son=nil then new(son);
    inverserIndices(NbrePointsSonagramme);
    sonMax := 0;
    if FreqMaxSonagramme>FreqEch/2 then FreqMaxSonagramme := FreqEch/2;
    NbreSonagrammeAff := round(pasTempsSonagramme*FreqEch);
    if NbreSonagrammeAff<32 then NbreSonagrammeAff := 32;
    NbreCalcul := round(pasSonCalcul*NbreSonagrammeAff);
    Decalage := (NbreCalcul-NbreSonagrammeAff) div 2;
    pas := succ(NbreCalcul div NbrePointsSonagramme);
// si trop de points, prendre un point sur pas
    NbreSonagramme := Nbre div NbreSonagrammeAff;
    if NbreSonagramme>NbreMaxSonagramme then NbreSonagramme := NbreMaxSonagramme;
    setLength(Xr,NbrePointsSonagramme);
    setLength(Xi,NbrePointsSonagramme);
    setLength(Xa,NbrePointsSonagramme);
    setLength(coeffWin,NbrePointsSonagramme);
    setLength(Xlisse,NbrePointsSonagramme);
    fenetrage;
    for i := 0 to pred(NbreSonagramme) do begin
        FourierSonagramme(i*NbreSonagrammeAff,(i+1)*nbreSonagrammeAff-1);
        son[i,0] := Xa[0]; // continu à part
        for j := 1 to pred(NbrePointsSonagramme div 2) do begin
            if Xa[j]>sonMax then sonMax := Xa[j];
            son[i,j] := Xa[j];
        end;
    end;
    pasFreqSonagramme := NbreSonagrammeAff/NbrePointsSonagramme/pasTempsSonagramme;
    for i := 0 to pred(NbreSonagramme) do
       for j := 1 to pred(NbrePointsSonagramme div 2) do
           son[i,j] := son[i,j]/sonMax; // entre 0 et 1
    Xr := nil;Xi := nil;Xa := nil;
    Xlisse := nil;
    NbreFcourant := 0;
    except
    end;
end;// Sonagramme

Function GetFondamental(Nbre : integer;Xa : vecteur) : integer;

function affine(i : integer) : integer;
var maxi : double;
    j : integer;
begin
    result := i;
    if i<4 then exit;
    maxi := Xa[i];
    for j := i-3 to i+3 do
        if Xa[j]>maxi then begin
           result := j;
           maxi := Xa[j];
        end;
end;

var i,i0,imax,imin : integer;
    maxi,s : double;
begin
   maxi := 0;
   imax := Nbre div 4; // i à ne pas dépasser
   imin := Nbre div 64; // i à ne pas dépasser
   i0 := 1;
   for i := imin to imax do
       if Xa[i]>maxi then begin
          maxi := Xa[i];
          i0 := i;
       end;
   if i0>=2 then begin // on a en fait trouvé l'harmonique 2 ?
       s := Xa[i0 div 2]+Xa[3*i0 div 2]+Xa[5*i0 div 2];
   { en fait i0=harm2 3*i0/2=harm3 ; i0/2 fondamental ; 5*i0/2 harm5
     on ne teste pas 4*i0/2 qui est hamr2 de i0 }
       if s>maxi/2 then i0 := affine(i0 div 2);
   end;
   if i0>=3 then begin // on a en fait trouvé l'harmonique 3 ?
       s := Xa[i0 div 3]+Xa[2*i0 div 3]+Xa[4*i0 div 3];
   { en fait i0=harm3 2*i0/3=harm2 ; i0/3 fondamental ; 4*i0/3 harm4 }
       if s>maxi/2 then i0 := affine(i0 div 3);
   end;
   if i0>=4 then begin // on a en fait trouvé l'harmonique 4 ?
       s := Xa[i0 div 4]+Xa[2*i0 div 4]+Xa[3*i0 div 4];
   { en fait i0=harm4 i0/4=harm1 ; 2*i0/4 harm2 ; 3*i0/4 harm3 }
       if s>maxi/2 then i0 := affine(i0 div 4);
   end;
   if i0>=imax then i0 := 1;
   result := i0;
end;

Function GetMaxiFFT(Nbre : integer;Xa : vecteur) : double; // sans prendre en compte le continu
var i,idebut,imax : integer;
    maxi : double;
    termine,secondEssai : boolean;
    i0 : integer;
begin
   maxi := 0;
   idebut := 0;
   imax := Nbre div 3;
   repeat inc(idebut) until (idebut>=imax) or (Xa[idebut]>Xa[idebut-1]);
   for i := idebut to pred(Nbre) do
       if Xa[i]>maxi then maxi := Xa[i];
   maxi := maxi/2;
   i := idebut;
   repeat inc(i)
   until (i>=imax) or (Xa[i]>maxi);
// début du premier pic
   i0 := i;
   maxi := Xa[i];
   secondEssai := true;
   repeat
      inc(i);
      if Xa[i]>maxi
         then begin
           i0 := i;
           maxi := Xa[i];
           secondEssai := true;
           termine := false;
         end
         else begin
           termine := not secondEssai;
           secondEssai := false;
         end;
   until (i>imax) or termine;
// maxi du pic
   if i>=imax then i0 := 1;
   result := Xa[i0];
end;

Procedure EnveloppeReelle(Nbre,NbreF : integer;Periode : double;
                T,X,Xr,Xi : vecteur);
var i : integer;
    iAvant,iApres : integer;
    deltat,ecart : double;
    xxr,xxi : vecteur;
    xre,xim,continu : double;
begin
     CopyVecteur(xxr,xr);
     CopyVecteur(xxi,xi);
     continu := xxr[0];
     for i := 1 to pred(NbreF div 2) do begin
         xxr[i] := 2*xxr[i];
         xxi[i] := 2*xxi[i];
     end;
     for i := succ(NbreF div 2) to pred(NbreF) do begin
     // signal analytique f>0 ; composantes f<0 nulles
         xxr[i] := 0;
         xxi[i] := 0;
     end;
     xxr[0] := 0;
     xxi[0] := 0;
     inverserIndicesInverse(NbreF);
     fenetrerInverse(xxr,xxi,NbreF);
     tfd(NbreF,xxr,xxi,false);
     if zeroPadding then begin
        coeffZeroPadding := Nbre/NbreF;
        for i := 0 to pred(NbreF) do begin
           xxr[i] := xxr[i]*coeffZeroPadding;
           xxi[i] := xxi[i]*coeffZeroPadding;
        end;
     end;
     deltat := Periode/NbreF;
// NbreF et non Nbre à cause choix de période et interpolation
     for i := 0 to pred(Nbre) do begin
         iAvant := trunc((T[i]-T[0])/deltat);
         ecart := T[i]-T[0]-iAvant*deltat;
         iAvant := iAvant mod NbreF; { périodiser }
         if iAvant<0 then inc(iAvant,NbreF);
         iApres := succ(iAvant) mod NbreF;
         xre := xxr[iAvant]+(xxr[iApres]-xxr[iAvant])*ecart/deltat;{ interpoler }
         xim := xxi[iAvant]+(xxi[iApres]-xxi[iAvant])*ecart/deltat;{ interpoler }
         X[i] := sqrt(sqr(xre)+sqr(xim))+continu;
     end;
     xxr := nil;xxi := nil;
end;

Procedure TVecteurSon.lit(NomFichier : string);

var taille : longInt;
    Nbit,Nvoie : byte;
    texte : string;
    i : integer;
    octet : byte;
    Hfichier : integer;
    son8 : array of byte;
    son16 : array of smallInt;
    son32 : array of single;
    testPCM : byte;


(*
var Datei: file of Byte;
AssignFile(Datei, FN);
Reset(Datei);
while not Eof(Datei) do
   Read(Datei, wert);
CloseFile(Datei);
*)

function valeur24bits(j : longint) : double;
var val24 : integer;
begin
  val24 := son8[j]+
           256*(son8[j+1]+
                256*son8[j+2]);
  if val24 >= 8388608 then
     val24 := val24 - 16777216;
  result := val24/8388608;
end;

var NbreMaxPermis : longInt;
begin
     FNbrePoints := 0;
     if not(FileExists(NomFichier)) then
        raise EWavError.create('Le fichier '+nomFichier+' n''existe pas');
     Hfichier := System.SysUtils.FileOpen(NomFichier,fmOpenRead);
     if HFichier<0 then
        raise EWavError.create('Problème d''ouverture du fichier .wav');
     son8 := nil;
     son16 := nil;
     son32 := nil;
     valeur := nil;
     System.SysUtils.FileSeek(Hfichier,16,0);
     System.SysUtils.FileRead(Hfichier,testPCM,1);
     if testPCM<>16 then begin
         FileClose(Hfichier);
         raise EWavError.create('Format de fichier attendu : PCM');
     end;
     System.SysUtils.FileSeek(Hfichier,20,0);
     System.SysUtils.FileRead(Hfichier,testPCM,1);
     // 1 : linéaire ; 3 : linéaire flottant ?
     if not (testPCM in [1,3]) then begin
         FileClose(Hfichier);
         raise EWavError.create('Format de fichier attendu : PCM linéaire');
     end;
     System.SysUtils.FileSeek(Hfichier,4,0);
     System.SysUtils.FileRead(Hfichier,taille,4);
     System.SysUtils.FileSeek(Hfichier,24,0);
     System.SysUtils.FileRead(Hfichier,FreqAudio,4);
     System.SysUtils.FileSeek(Hfichier,34,0);
     System.SysUtils.FileRead(Hfichier,Nbit,1);
     if Nbit=8
        then formatWave := f8
        else if Nbit=16
             then formatWave := f16
             else if Nbit=24
                 then formatWave := f24
                 else if Nbit=32
                   then formatWave := f32
                   else begin
                      FileClose(Hfichier);
                      raise EWavError.create('Format de fichier attendu : PCM 8/16/24/32 bits');
                 end;
     System.SysUtils.FileSeek(Hfichier,22,0);
     System.SysUtils.FileRead(Hfichier,Nvoie,1);
     stereo := Nvoie=2;
     System.SysUtils.FileSeek(Hfichier,36,0);
     texte := '';
     for i := 1 to 4 do begin
         System.SysUtils.FileRead(Hfichier,octet,1);
         texte := texte+char(octet);
     end;
     i := 40;
     while (i<taille) and (texte<>'data') do begin
          delete(texte,1,1);
          FileRead(Hfichier,octet,1);
          texte := texte+char(octet);
          inc(i);
     end;
     if i>=taille then begin
         FileClose(Hfichier);
         FNbrePoints := 0;
         raise EWavError.create('Problème de lecture du fichier .wav');
     end;
     System.SysUtils.FileRead(Hfichier,FNbrePoints,4); // Nombre de points en octets
     case formatWave of
        f8 : if stereo
           then begin if FNbrePoints>2*MaxVecteurSon then FNbrePoints := 2*MaxVecteurSon end
           else if FNbrePoints>MaxVecteurSon then FNbrePoints := MaxVecteurSon;
        f16 : if stereo
           then begin if FNbrePoints>4*MaxVecteurSon then FNbrePoints := 4*MaxVecteurSon end
           else if FNbrePoints>2*MaxVecteurSon then FNbrePoints := 2*MaxVecteurSon;
        f24 : if stereo
           then begin if FNbrePoints>6*MaxVecteurSon then FNbrePoints := 6*MaxVecteurSon end
           else if FNbrePoints>3*MaxVecteurSon then FNbrePoints := 3*MaxVecteurSon;
        f32 : if stereo
           then begin if FNbrePoints>8*MaxVecteurSon then FNbrePoints := 8*MaxVecteurSon end
           else if FNbrePoints>4*MaxVecteurSon then FNbrePoints := 4*MaxVecteurSon;
     end;
     case formatWave of
        f8 : setLength(son8,FNbrePoints);
        f16 : setLength(son16,FNbrePoints div 2);
        f24 : setLength(son8,FNbrePoints);
        f32 : setLength(son32,FNbrePoints div 4); // single 4 octets
     end;
     if FNbrePoints > 0 then
     case formatWave of
        f8 : begin
           FNbrePoints := FileRead(Hfichier, son8[0], FNbrePoints);
        end;
        f16 : begin
           FNbrePoints := FileRead(Hfichier, son16[0], FNbrePoints);
           FNbrePoints := FNbrePoints div 2;
        end;
        f24 : begin
           FNbrePoints := FileRead(Hfichier, son8[0], FNbrePoints);
           FNbrePoints := FNbrePoints div 3;
        end;
        f32 : begin
           FNbrePoints := FileRead(Hfichier, son32[0], FNbrePoints);
           FNbrePoints := FNbrePoints div 4;
        end;
     end;
     if stereo then begin
        FNbrePoints := FNbrePoints div 2;
        setLength(valeurBis,FNbrePoints);
     end;
     setLength(valeur,FNbrePoints);
     case formatWave of
        f8 : if stereo
          then for i := 0 to FNbrePoints-1 do begin
            valeur[i] := (son8[2*i]-128)/128;
            valeurBis[i] := (son8[2*i+1]-128)/128
          end
          else for i := 0 to FNbrePoints-1 do
            valeur[i] := (son8[i]-128)/128;
        f16 : if stereo
           then for i := 0 to FNbrePoints-1 do begin
            valeur[i] := son16[2*i]/32768;
            valeurBis[i] := son16[2*i+1]/32768;
           end
           else for i := 0 to FNbrePoints-1 do
            valeur[i] := son16[i]/32768;
        f24 : if stereo
           then for i := 0 to FNbrePoints-1 do begin
             valeur[i] := valeur24bits(6*i);
             valeurBis[i] := valeur24bits(6*i+3)
           end
           else for i := 0 to FNbrePoints-1 do
           valeur[i] := valeur24bits(3*i);
        f32 : if stereo
           then for i := 0 to FNbrePoints-1 do begin
                valeur[i] := son32[2*i];
                valeurBis[i] := son32[2*i+1];
           end
           else for i := 0 to FNbrePoints-1 do
                valeur[i] := son32[i];
     end;
     System.SysUtils.FileClose(Hfichier);
     son8 := nil;
     son16 := nil;
     son32 := nil;
     if (freqAudio>50000)
         then NbreMaxPermis := 8*MaxMaxVecteur   // 96k et 88200 ; passage à 12k
         else if (freqAudio>35000)
              then NbreMaxPermis := 4*MaxMaxVecteur // 48k et 44100 ; passage à 12k
              else if (freqAudio>20000)
                   then NbreMaxPermis := 2*MaxMaxVecteur // 32k 24k 22050 ; passage à 12k
                   else NbreMaxPermis := MaxMaxVecteur;// 16k 12k 11025
     if (FNbrePoints>NbreMaxPermis) then FNbrePoints := NbreMaxPermis;
     FNbrePoints := FNbrePoints-1;
end;

destructor TvecteurSon.Destroy;
begin
    valeur := nil;
    inherited
end;

function TVecteurSon.GetNbit : integer;
begin
    case formatWave of
        f8 : result := 8;
        f16 : result := 16;
        f24 : result := 24;
        f32 : result := 32;
        else result := 8; // pour le compilateur
     end;
end;

initialization
     setLength(tbi,MaxVecteurDefaut);
     setLength(wr,MaxVecteurDefaut);
     setLength(wi,MaxVecteurDefaut);
     setLength(kf,MaxVecteurDefaut);
     nbreFcourant := 0;
     fenetreCourante := rectangulaire;
     FreqMaxSonagramme := 11000;
     PasFreqSonagramme := 100;

Finalization
     tbi := nil;
     wr := nil;
     wi := nil;
     kf := nil;
     if son<>nil then begin
        Dispose(son);
        son := nil;
     end;
end.

