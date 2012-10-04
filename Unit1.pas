unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Grids, Spin;

type Vector = array[0..9] of real;
type Matrix = array[0..9,0..9] of real;

type
  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    SpinEdit1: TSpinEdit;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  
const nula=0.000001;

var
  Form1: TForm1;
  n:integer;

procedure swap(i,n,pivot:integer;var matice:Matrix;var vektor:Vector);
procedure rev_sbst(var matice:Matrix;var vektor:Vector;var n:integer);
procedure gauss(var n:integer; var matice:Matrix; var vektor:Vector);
procedure outprint(var n:integer; var vektor:Vector);
procedure popis_stringgrid(n:integer);
procedure jordan(var n:integer; var matice:matrix; var vektor:Vector);

implementation

{$R *.dfm}

function pivot_lookup(i:integer; n:integer; var matice:Matrix):integer;
var k,return:integer; max:real; vyjimka:Exception;
begin
  {v i-tem sloupci hledam nejvetsi prvek}
  vyjimka:=Exception.Create('Reseni je nejednoznacne - hledane maximum v '+inttostr(i+1)+' sloupci je 0');
  return:=i;
  try
        max:=abs(matice[i][i]);
        if max<=nula then raise vyjimka;
        for k:=i+1 to n-1 do
                if abs(matice[k,i])>max then begin
                    max:=abs(matice[k,i]);
                    if max<=nula then raise vyjimka;
                    return:=k;
                 end;
  except
        on E:Exception do ShowMessage(E.Message);
  end;
        pivot_lookup:=return;
end;

procedure jordan(var n:integer; var matice:matrix; var vektor:vector);
var i,j,k:integer; var vyjimka:Exception;
begin
{jordanova eliminace - jde o to dostat nuly nad hlavni diagonalou}
        vyjimka:=Exception.Create('Spatny vstup - nedovolene deleni nulou');
        try for i:=0 to n-1 do begin
                for k:=i+1 to n-1 do begin {pro vsechny nizsi radky v matici budu delit a odecitat (pokud je cislo nenulove)}
                        if abs(matice[i,i])>nula then 
                          if k<>i then begin
                                help:=matice[i,k]/matice[k,k];
                                for j:=i+1 to n-1 do matice[i,j]:=matice[i,j]-help*matice[k,j];
                          end
                        else raise vyjimka;{jak to pozna ke kteremu if-u patri?}
                end;
                if abs(matice[i,i])>nula then vektor[i]:=vektor[i]/matice[i,i]
                else raise vyjimka;
            end;
            {JESTE SE CHCE MIT NA HLAVNI DIAGONALE SAME JEDNICKY}
        except on E:Exception do ShowMessage(E.Message); 
        end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
        {nastavi velikost matice na n*n+1, n je zadene uzivatelem pres spinedit}
        n:=SpinEdit1.Value;
        StringGrid1.ColCount:=n+2;
        StringGrid1.RowCount:=n+1;
        StringGrid1.Refresh;
        popis_stringgrid(n);
        StringGrid1.Enabled:=true;
end;

procedure swap(i,n,pivot:integer;var matice:Matrix;var vektor:Vector);
var k:integer; help:real;
begin
        {prohodim v i-tem sloupci k-ty radek s pivot-ym radkem}
        for k:=i to n-1 do begin
            help:=matice[k,pivot];
            matice[k,pivot]:=matice[k,i];
            matice[k,i]:=help;
        end;
        help:=vektor[pivot];
        vektor[pivot]:=vektor[i];
        vektor[i]:=help;
end;

procedure rev_sbst(var matice:Matrix;var vektor:Vector;var n:integer);
var i,j:integer;
begin
    {zpetne dosazuji a ziskavam reseni soustavy v poli vektor}
     try 
     if matice[n-1,n-1]=0 then
        if vektor[n-1]<>0 then raise Exception.Create('Soustava nema reseni')
        else if vektor[n+1]=0 then Exception.Create('Resenim je mnozina realnych cisel')
     else for i:=n-1 downto 0 do begin
        for j:=i+1 to n-1 do vektor[i]:=vektor[i]-matice[j,i]*vektor[j];
        if abs(matice[i,i])>nula then vektor[i]:=vektor[i]/matice[i,i]
        else raise Exception.Create('Spatny vstup - nedovolene deleni nulou');
     end;
     except on E:Exception do ShowMessage(E.Message);
     end;
end;

procedure gauss(var n:integer; var matice:Matrix; var vektor:Vector);
var i,j,k,pivot:integer; help:real;
begin
{Gaussova elimiace s vyberem pivota}
        try for i:=0 to n-1 do begin
                pivot:=pivot_lookup(i,n,matice); {najdu nejvetsi prvek ve sloupci}
                if i <> pivot then swap(i,n,pivot,matice,vektor); {pivot neni na [i,i] prohodim radky}
                for k:=i+1 to n-1 do begin {pro vsechny nizsi radky v matici budu delit a odecitat (pokud je cislo nenulove)}
                        if abs(matice[i,i])>nula then begin
                                help:=matice[i,k]/matice[i,i];
                                for j:=i+1 to n-1 do matice[j,k]:=matice[j,k]-help*matice[j,i];
                                vektor[k]:=vektor[k]-help*vektor[i];
                        end else raise Exception.Create('Spatny vstup - nedovolene deleni nulou');
                end;
        end;
        except on E:Exception do ShowMessage(E.Message); end;
        rev_sbst(matice,vektor,n); {reverzni substituci ziskam reseni}
end;

procedure outprint(var n:integer; var vektor:Vector);
var i:integer;
begin
  {vypisu mnozinu reseni do labelu}
        if form1.label2.Caption=' ' then begin
                Form1.Label2.Caption:='K={';
                for i:=0 to n-1 do Form1.Label2.Caption:=Form1.Label2.Caption+floattostr(vektor[i])+',';
                Form1.Label2.Caption:='}';
        end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var i,j,code:integer; matice:Matrix; vektor:Vector;
begin
        {prepise data ze StringGrid do poli matice a vektor}
       for i:=1 to n+1 do
                for j:=1 to n+1 do
                        Val(StringGrid1.Cells[i,j],matice[i-1,j-1],code);            
        for i:=0 to n do
                Val(StringGrid1.Cells[n+1,i+1],vektor[i],code);
        {spusti Gaussovu eliminaci, ziskame vektor reseni}
        gauss(n,matice,vektor);
        {vypis vektoru na obrazovku}
        outprint(n,vektor);
end;

procedure popis_stringgrid(n:integer);
const a=ord('a');
const x=ord('x');
var i:integer;
begin
  {popise policka ve stringgridu pro uzivatelskou privetivost}
        for i:=1 to n do
                Form1.StringGrid1.Cells[0,i]:='rovnice '+inttostr(i);
        for i:=1 to n do
                Form1.StringGrid1.Cells[i,0]:=chr(a+i-1)+'x'+inttostr(i);
        Form1.StringGrid1.Cells[n+1,0]:='prava strana';
end;

end.