unit conv;

{$mode objfpc}{$H+}


interface

procedure Int2Shorts(i :smallint; var l, h : byte);
procedure Shorts2Int(l, h : byte; var i : smallint);

implementation

procedure Int2Shorts(i :smallint; var l, h : byte);
var x : word; //unsigned 16bit
begin
x := i;
l := x and $00ff;
h := x shr 8;
end; //Int2Short

procedure Shorts2Int(l, h : byte; var i : smallint);
begin
i := (h shl 8) or l;

end;//Shorts2Int

end.



