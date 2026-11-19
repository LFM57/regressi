unit Images;

interface

uses
  System.SysUtils, System.Classes, System.ImageList,

  FMX.ImgList;

type
  TImagesData = class(TDataModule)
    ImagesList: TImageList;
    ImageListNB: TImageList;
  private
  public
  end;

var
  ImagesData: TImagesData;

const
  indexImageAngle : array[boolean] of integer = (39,21);

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

end.
