//---------------------------------------------------------------------------

// This software is Copyright (c) 2015 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------

unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls, FMX.Edit,
  FMX.WebBrowser, FMX.Layouts, FMX.Controls.Presentation;

type
  TWebBrowserForm = class(TForm)
    WebBrowser1: TWebBrowser;
    procedure WebBrowser1DidFailLoadWithError(ASender: TObject);
    procedure FormActivate(Sender: TObject);
  private
  public
  end;

var
  WebBrowserForm: TWebBrowserForm;

implementation

{$R *.fmx}

procedure TWebBrowserForm.FormActivate(Sender: TObject);
begin
    WebBrowser1.URL := '\\Mac\Home\Documents\RegHelp\Regressi.html';
end;

procedure TWebBrowserForm.WebBrowser1DidFailLoadWithError(ASender: TObject);
begin
    showMessage('erreur')
end;


end.
