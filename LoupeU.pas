unit LoupeU;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.UIConsts,

  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Colors, FMX.Utils;

type
  TLoupeForm = class(TForm)
    Image: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImagePaint(Sender: TObject; Canvas: TCanvas;
      const ARect: TRectF);
    procedure ImageMouseLeave(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormFocusChanged(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ImageMouseEnter(Sender: TObject);
  private
  public
    bitmapLoupe : Tbitmap;
    avecSouris : boolean;
    avecLoupe : boolean;
    aForm : TForm;
  end;

var
  LoupeForm: TLoupeForm;

implementation

{$R *.fmx}

procedure TLoupeForm.FormCreate(Sender: TObject);
begin
    image.Cursor := crNone;
    cursor := crNone;
    bitmapLoupe := Tbitmap.create;
    bitmapLoupe.Width := loupeForm.width;
    bitmapLoupe.Height := loupeForm.height;
    avecLoupe := false;
    avecSouris := false;
end;

procedure TLoupeForm.FormDeactivate(Sender: TObject);
begin
    aForm.Active := true;
end;

procedure TLoupeForm.FormDestroy(Sender: TObject);
begin
    loupeForm := nil;
    bitmapLoupe.Free;
end;

procedure TLoupeForm.FormFocusChanged(Sender: TObject);
begin
    aForm.Active := true;
end;

procedure TLoupeForm.FormHide(Sender: TObject);
begin
    aForm.Active := true;
end;

procedure TLoupeForm.ImageMouseEnter(Sender: TObject);
begin
    avecSouris := true;
end;

procedure TLoupeForm.ImageMouseLeave(Sender: TObject);
begin
    avecSouris := false;
end;

procedure TLoupeForm.ImagePaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);

procedure Efface;
var Data  : TBitmapData;
    increment : integer;
    i,j,j2,i2 : integer;
    aFormat : TPixelFormat;
    hauteurLoupe,demiHauteurLoupe : integer;
begin
    if bitmapLoupe.Map(TMapAccess.ReadWrite, Data) then begin
       aFormat := bitmapLoupe.pixelFormat;
       increment := Data.Pitch div PixelFormatBytes[aFormat];
       demiHauteurLoupe := Width div 2;
       hauteurLoupe := 2*demiHauteurLoupe;
       for j := 0 to hauteurLoupe do begin
          J2 := J*increment;
          i2 := round(demiHauteurLoupe-sqrt(j*(2*demiHauteurLoupe-j)));
          for i := 0 to i2 do
              AlphaColorToPixel(claNull, @PAlphaColorArray(Data.Data)[J2+I], aFormat);
          i2 := round(demiHauteurLoupe+sqrt(j*(2*demiHauteurLoupe-j)));
          for i := i2 to hauteurLoupe do
              AlphaColorToPixel(claNull, @PAlphaColorArray(Data.Data)[J2+I], aFormat);
       end;
       bitmapLoupe.Unmap(Data);
    end;
end;

begin
     if avecLoupe then begin
        efface;
        canvas.DrawBitmap(bitmapLoupe,Arect,Arect,1);
     end;
end;

end.


(*
procedure TImageCacheLayout.ApplyNoAlphaEdge(ABitmap: TBitmap; OpacityThreshold: integer);
var
  bitdata1: TBitmapData;
  I: integer;
  J: integer;
  C: TAlphaColor;
begin
    if (ABitmap.Map(TMapAccess.maReadWrite, bitdata1)) then begin
        for I := 0 to ABitmap.Width - 1 do begin
          for J := 0 to ABitmap.Height - 1 do  begin
               C := PixelToAlphaColor(@PAlphaColorArray(bitdata1.Data)
                  [J * (bitdata1.Pitch div PixelFormatBytes[ABitmap.PixelFormat])
                   + I], ABitmap.PixelFormat);
              if TAlphaColorRec(C).A<OpacityThreshold then begin
                  TAlphaColorRec(C).A := 0;
                  AlphaColorToPixel(C, @PAlphaColorArray(bitdata1.Data)
                    [J * (bitdata1.Pitch div PixelFormatBytes[ABitmap.PixelFormat])
                     + I], ABitmap.PixelFormat);
              end;
          end;
        end;
      ABitmap.Unmap(bitdata1);
    end;
end;
*)

(*
var
  bNewAlpha: byte;
  bOldAlpha: byte;
begin
 // input parameter of new alpha
 bNewAlpha := 123;
 //
 xCl := xBitmapData.GetPixel(iX,iY);
 xCl := UnpremultiplyAlpha(xCl);
 bOldAlpha := TAlphaColorRec(xCl).A;
 bNewAlpha := Min(bNewAlpha,bOldAlpha);
 TAlphaColorRec(xCl).A := bNewAlpha;
 xCl := PremultiplyAlpha(xCl);
 xBitmapData.SetPixel(iX,iY,xCl);
 end;
 *)
