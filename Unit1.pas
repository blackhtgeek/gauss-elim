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

var
  Form1: TForm1;
  n:integer;

implementation

{$R *.dfm}

function pivot_lookup(i:integer; var n:integer; matice:Matrix):integer;
var k:integer; max:real;
begin
        pivot_lookup:=i;
        max:=abs(matice[i][i]);
        for k:=i+1 to n do
                if abs(matice[i][k])>max then begin
                    max:=abs(matice[i][k]);
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


procedure swap(i:integer; var n,pivot:integer;matice:Matrix;vektor:Vector);
var k:integer; help:real;
begin
        for k:=i to n do begin
            help:=matice[k][pivot];
            matice[k][pivot]:=matice[k][i];
            matice[k][i]:=help;
        end;
        help:=vektor[pivot];
        vektor[pivot]:=vektor[i];
        vektor[i]:=help;
end;

procedure elimine(matice:Matrix;vektor:Vector; var n:integer; i,j:integer);
var help:real; k:integer;
begin
     for k:=i+1 to n do begin
        help:=matice[i][k]/matice[i][i];
        for j:=i+1 to n do matice[j][k]:=matice[j][k]-help*matice[j][i];
        vektor[k]:=vektor[k]-help*vektor[i];
     end;
end;

procedure rev_sbst(matice:Matrix;vektor:Vector;var n:integer;reseni:Vector);
var i,j:integer;
begin
     for i:=n downto 1 do begin
        for j:=i+1 to n do vektor[i]:=vektor[i]-matice[j][i]*vektor[j];
        reseni[i]:=vektor[i]/matice[i][i];
     end;
end;

procedure gauss(var n:integer; matice:Matrix; vektor:Vector; reseni:Vector);
var a,i,j,pivot:integer;
begin
{Gaussova elimiace s vyberem pivota}
        for i:=1 to n do begin
                pivot:=pivot_lookup(i,n,matice);
                if i <> pivot then swap(i,n,pivot,matice,vektor);
                elimine(matice,vektor,n,i,j);
        end;
        rev_sbst(matice,vektor,n,reseni);
end;

procedure in2file(var n:integer; var matice:Matrix; var vektor:Vector);
var f:TextFile; i,j:integer;
begin
        assignfile(f,'loaded.txt');
        rewrite(f);
        for i:=0 to n-1 do begin
                for j:=0 to n-1 do write(f,matice[i,j],' ');
                writeln(f,'');
        end;{v souboru data po radcich}
        writeln(f,'');
        for i:=0 to n-1 do write(f,vektor[i],' ');
        closefile(f);
end;

procedure out2file(var n:integer; var reseni:Vector);
var f:TextFile; i:integer;

begin
        assign(f,'out.txt');
        rewrite(f);
        for i:=1 to n do write(f,reseni[i],' ');
        closefile(f);
end;

procedure TForm1.Button2Click(Sender: TObject);
var i,j,code:integer; matice:Matrix; vektor:Vector; vyjimka:Exception; reseni:Vector;
begin
        vyjimka:=Exception.Create('Spatny vstup');
        {prepise data ze StringGrid do poli matice a vektor}
try     for i:=1 to n+1 do
                for j:=1 to n+1 do begin
                        Val(StringGrid1.Cells[i,j],matice[i-1,j-1],code);
                        {if code<>0 then raise vyjimka}
                end;
        for i:=0 to n do begin
                Val(StringGrid1.Cells[n+1,i+1],vektor[i],code);
                {if code<>0 then raise vyjimka}
        end;
except  on E:Exception do ShowMessage(E.Message);
end;
        {zapise data do souboru pro kontrolu toho, co se nacetlo}
        in2file(n,matice,vektor);
        {spusti Gaussovu eliminaci, ziskame vektor reseni}
        gauss(n,matice,vektor,reseni);
        {zapiseme vektor do souboru}
        out2file(n,reseni);
end;

end.
