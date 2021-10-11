unit SinTxtUnit;

interface
{

  Un example de texete en sinusoide le but est uniquement didactique
  j'ai introduit quelques astuces dans le code pour le rendre + interessant
  bon codage

  ManChesTer.

}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    Panel2: TPanel;
    Panel3: TPanel;
    Edit1: TEdit;
    Label1: TLabel;
    Image2: TImage;
    ComboBox1: TComboBox;
    UpDown1: TUpDown;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Panel1: TPanel;
    procedure Edit2Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure showtext;
    procedure Edit1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1  : TForm1;
  Sinuso : real;

implementation

{$R *.DFM}

function scolor(r,g,b:byte):tcolor;
var rgb:array[0..3] of byte;
    rs:longint;
begin
 rgb[0]:=r;
 rgb[1]:=g;
 rgb[2]:=b;
 rgb[3]:=$2;
 move(rgb[0],rs,4);
 scolor:=rs;
end;

function degrade_rgb(r,g,b:byte;st:tcolor):tcolor;
var m,rr,gg,bb:longint;
begin
 m:=round(abs(st));
 rr:=r;
 gg:=g;
 bb:=b;
 if st<0 then
 begin
  if (rr-m)>=0 then
   rr:=rr-m
  else
   rr:=0;
  if (gg-m)>=0 then
   gg:=gg-m
  else
   gg:=0;
  if (bb-m)>=0 then
   bb:=bb-m
  else
   bb:=0;
 end
 else if st>0 then
 begin
  if (rr+m)<=255 then
   rr:=rr+m
  else
   rr:=255;
  if (gg+m)<=255 then
   gg:=gg+m
  else
   gg:=255;
  if (bb+m)<=255 then
   bb:=bb+m
  else
   bb:=255;
 end;
 result:=scolor(byte(rr),byte(gg),byte(bb));
end;

Procedure SinText(BmpTxt,BmpOut:Tbitmap;x,y:integer;text:string);
var tx,ty       : integer;
    c,t         : Real;
    HdcOut,
    HdcTxt      : HDC;
    HeightOfTxt : Integer;
    WidthOfTxt  : Integer;
    RecTxt      : Trect;
    Couleur     : Tcolor;
begin
 c:=0;
 HeightOfTxt:=BmpTxt.Canvas.TextHeight(text); // prendre la hauteur du texte;
 WidthOfTxt:=BmpTxt.Canvas.TextWidth(text);   // prendre la Longeur du texte;
 RecTxt.Top:=0;      // definir le rectangle pour dessiner le texte
 RecTxt.Left:=0;
 RecTxt.Right:=BmpTxt.Width;
 RecTxt.Bottom:=BmpTxt.Height;  // prendre tout le bmp comme taille
 HdcTxt:=BmpTxt.Canvas.Handle;  // Prendre Le HDC du canvas de Bmp Texte
 HdcOut:=BmpOut.Canvas.Handle;  // Prendre Le HDC du canvas de Bmp Out
 TextOut(HdcTxt,0,0,pchar(Text),Length(text)); // ecrire le texte
 for tx:=0 to WidthOfTxt do        // depuis le debut du texte dessiné jusque la fin
 begin
  t:=t+sinuso+0.01477;
  c:=c+(sin(t)*0.73421);
  for ty:=0 to HeightOfTxt do
  begin
   couleur:=degrade_rgb(byte($10),byte($60),byte($60),round(c+(ty*2)));
   case getpixel(HdcTxt,tx,ty) of   // utilisation de cas (+rapide que if)
    0:                              // si le pixel tx,ty est pas noir
    SetPixelV(HdcOut,Tx+x,Ty+y+round(c),couleur); // ecrire le texte en sinusoide
    // setpixelv + rapide que setpixel
   end;
    //il existe des mèthode + rapides pour obtenit le meme resultat mais
    // le but ici est de pouvoir déformé du texte n'importe comment et point par point
  end;
 end;
end;

procedure TForm1.showtext;
var bmpTxt, BmpOut: Tbitmap;
begin
 bmpTxt:=tbitmap.create;          // Création d'un Bmp de sortie
 bmpOut:=tbitmap.create;          // Création d'un Bmp Pour Le Texte
 BmpOut.Width:=Image2.Width;      // Definir la taille du bmp
 BmpOut.Height:=Image2.Height;
 Bmptxt.assign(Bmpout);           // Copier le bmp de sortie ds le bmp de texte
                                  // Ceci est une astuce pour reprendre les
                                  // params d'un bmp ds un autre
 BmpTxt.Canvas.Brush.style:=BsClear; // pas de fond a notre text;
 BmpTxt.Canvas.Font.assign(Panel1.font);  // Prendre les attributs de la fonte
 BmpTxt.Canvas.Font.Size:=strtoint(edit2.text); // prendre la taille
 SinText(BmpTxt,BmpOut,
         0,bmpout.height div 2,edit1.text); // faire un texte sinuzoidal
 Image2.Picture.Bitmap.Assign(BmpOut);  // Afficher le resultat
 BmpOut.Free;                           // libèrer les bmp de création
 BmpTxt.Free;
end;

procedure TForm1.Edit2Change(Sender: TObject);
var txt:string;
begin
 txt:=Tedit(sender).Text;
 if not (txt[1] in ['0'..'9']) then
  delete(txt,1,1);
 if not(txt[2] in ['0'..'9']) then
  delete(txt,2,1);
 if txt='' then txt:='4';
 edit2.text:=txt;
 showtext;
end;

function GetFonts(var LogFont: TLogFont; var TextMetric: TTextMetric;
  FontType: Integer; Data: Pointer): Integer; stdcall;
begin
 TStrings(Data).Add(LogFont.lfFaceName);
end;

procedure TForm1.FormShow(Sender: TObject);
var
 DC: HDC;
begin
 DC := GetDC(0);
 EnumFonts(DC, nil, @GetFonts, Pointer(ComboBox1.Items));
 ReleaseDC(0, DC);
 Combobox1.Sorted := True;
 combobox1.Text:=font.name;
 edit2.text:='38';
 panel1.Caption:=edit1.text;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
 panel1.font.Name:=combobox1.text;
 panel1.Caption:=edit1.text;
 showtext;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
 if CheckBox1.checked then
  panel1.font.Style:=panel1.Font.Style + [fsbold]
 else
  panel1.font.Style:=panel1.Font.Style - [fsbold];
 showtext;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
 panel1.Caption:=edit1.text;
 showtext;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 if Tbutton(sender).caption='+' then
  sinuso:=sinuso+0.005
 else
  sinuso:=sinuso-0.005;
 showtext;
end;

end.
