unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Grids, Spin, Math;

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
  noresult:boolean;

procedure swap(i,n,pivot:integer;var matice:Matrix;var vektor:Vector);
procedure rev_sbst(var matice:Matrix;var vektor:Vector;var n:integer);
procedure gauss(n:integer; var matice:Matrix; var vektor:Vector);
procedure outprint(var n:integer; var vektor:Vector);
procedure popis_stringgrid(n:integer);
procedure gauss_jordan(n:integer; var matice:Matrix; var vektor:Vector);

implementation

{$R *.dfm}

function pivot_lookup(i:integer; n:integer; var matice:Matrix):integer;
var k,return:integer; max:real;
begin
  {v i-tem sloupci hledam nejvetsi prvek}
  return:=i;
  max:=abs(matice[i][i]);
  for k:=i+1 to n-1 do
        if abs(matice[k,i])>max then begin
              max:=abs(matice[k,i]);
              return:=k;
        end;
  pivot_lookup:=return;
end;

procedure gauss_jordan(n:integer; var matice:integer; var vektor:Vector);
var i,j,k:integer;
begin
	gauss(n,matice,vektor);{mame matici s nulami pod hlavni diagonalou}
	{ted jeste ziskat nuly nad hlavni diagonalou}
	try for i:=0 to n-1 do
		if not noresult then begin
			for k:=i+1 downto 0 do begin {pro vsechny vyssi radky v matici budu delit a odecitat (pokud je cislo nenulove)}
           			if not isZero(abs(matice[i,i]),nula) then begin
                			help:=matice[i,k]/matice[i,i];
                        	       	for j:=i+1 to n-1 do matice[j,k]:=matice[j,k]-help*matice[j,i];
	                                vektor[k]:=vektor[k]-help*vektor[i];
        	                end else raise Exception.Create('Spatny vstup - nedovolene deleni nulou');
                	end;
		end
	outprint(n,vektor);
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
        noresult:=false;
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
     if isZero(matice[n-1,n-1],nula) then begin
        if not isZero(vektor[n-1],nula) then ShowMessage('Soustava nema reseni')
        else if isZero(vektor[n+1],nula) then ShowMessage('Resenim je mnozina realnych cisel');
        noresult:=true;
     end
     else for i:=n-1 downto 0 do begin
        for j:=i+1 to n-1 do vektor[i]:=vektor[i]-matice[j,i]*vektor[j];
        if not isZero(abs(matice[i,i]),nula) then vektor[i]:=vektor[i]/matice[i,i]
        else ShowMessage('Spatny vstup - nedovolene deleni nulou');
     end;
end;

procedure gauss(n:integer; var matice:Matrix; var vektor:Vector);
var i,j,k,pivot:integer; help:real;
begin
{Gaussova elimiace s vyberem pivota}
        try for i:=0 to n-1 do begin
                pivot:=pivot_lookup(i,n,matice); {najdu nejvetsi prvek ve sloupci}
		if isZero(pivot,nula) then begin ShowMessage('Neni pravda, ze existuje jedine reseni'); noresult:=true; end
		else begin
	                if i <> pivot then swap(i,n,pivot,matice,vektor); {pivot neni na [i,i] prohodim radky}
        	        for k:=i+1 to n-1 do begin {pro vsechny nizsi radky v matici budu delit a odecitat (pokud je cislo nenulove)}
                	        if not isZero(abs(matice[i,i]),nula) then begin
                        	        help:=matice[i,k]/matice[i,i];
                                	for j:=i+1 to n-1 do matice[j,k]:=matice[j,k]-help*matice[j,i];
	                                vektor[k]:=vektor[k]-help*vektor[i];
        	                end else raise Exception.Create('Spatny vstup - nedovolene deleni nulou');
                	end;
		end;
        end;
        except on E:Exception do ShowMessage(E.Message); end;
        {if not isZero(pivot,nula) then rev_sbst(matice,vektor,n);} {reverzni substituci ziskam reseni}
end;

procedure outprint(var n:integer; var vektor:Vector);
var i:integer;
begin
  {vypisu mnozinu reseni do labelu}
  if not noresult then begin
        Form1.Label2.Caption:='K={';
        for i:=0 to n-1 do Form1.Label2.Caption:=Form1.Label2.Caption+floattostr(vektor[i])+',';
        Form1.Label2.Caption:=Form1.Label2.Caption+'}';
  end else Form1.Label2.Caption:='';
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
        {spusti Gaussovu eliminaci}
        gauss(n,matice,vektor);
	{spusti reverzni substituci, ziskame vektor reseni}
	if not noresult then rev_sbst(matice,vektor,n);
        {vypis vektoru na obrazovku}
        outprint(n,vektor);
end;

procedure popis_stringgrid(n:integer);
const a=ord('a');
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
