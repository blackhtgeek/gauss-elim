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

implementation

{$R *.dfm}

function pivot_lookup(i:integer; n:integer; var matice:Matrix):integer;
var k:integer; max:real;
begin
        pivot_lookup:=i;
        max:=abs(matice[i][i]);
        for k:=i+1 to n-1 do
                if abs(matice[k,i])>max then begin
                    max:=abs(matice[k,i]);
                    pivot_lookup:=k;
                 end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
        {nastavi velikost matice na n*n+1, n je zadene uzivatelem pres spinedit}
        n:=SpinEdit1.Value;
        StringGrid1.ColCount:=n+2;
        StringGrid1.RowCount:=n+1;
        StringGrid1.Refresh;
end;

procedure swap(i,n,pivot:integer;var matice:Matrix;var vektor:Vector);
var k:integer; help:real;
begin
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
     try for i:=n-1 downto 0 do begin
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
                pivot:=pivot_lookup(i,n,matice);
                if i <> pivot then swap(i,n,pivot,matice,vektor);
                for k:=i+1 to n-1 do begin
                        if abs(matice[i,i])>nula then begin
                                help:=matice[i,k]/matice[i,i];
                                for j:=i+1 to n-1 do matice[j,k]:=matice[j,k]-help*matice[j,i];
                                vektor[k]:=vektor[k]-help*vektor[i];
                        end else raise Exception.Create('Spatny vstup - nedovolene deleni nulou');
                end;
        end;
        except on E:Exception do ShowMessage(E.Message); end;
        rev_sbst(matice,vektor,n);
end;

procedure in2file(var n:integer; var matice:Matrix; var vektor:Vector);
var f:TextFile; i,j:integer;
begin
        assignfile(f,'loaded.txt');
        rewrite(f);
        for i:=0 to n-1 do begin
                for j:=0 to n-1 do write(f,matice[j,i],' ');
                writeln(f,'');
        end;{v souboru data po radcich}
        writeln(f,'');
        for i:=0 to n-1 do write(f,vektor[i],' ');
        closefile(f);
end;

procedure out2file(var n:integer; var vektor:Vector);
var f:TextFile; i:integer;
begin
        assign(f,'out.txt');
        rewrite(f);
        for i:=0 to n-1 do write(f,vektor[i]:8:3,' ');
        closefile(f);
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
        {zapise data do souboru pro kontrolu toho, co se nacetlo}
        {in2file(n,matice,vektor);}
        {spusti Gaussovu eliminaci, ziskame vektor reseni}
        gauss(n,matice,vektor);
        {zapiseme vektor do souboru}
        out2file(n,vektor);
end;

end.