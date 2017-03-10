unit matrix;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils;

procedure creatematrix(x,y : byte);
procedure creatematrix2;
function getXY(x, y : byte):smallint;
procedure writeXY(x,y : byte; s : smallint);
function getXY2(x, y : byte):smallint;
procedure writeXY2(x,y : byte; s : smallint);
procedure dumpMtx;

implementation
uses conv, EmuAvrMmcCardLib;
var
    xMatrix, yMatrix : byte;
 fname : string = '/tmp/matrix.txt'; //'12312312TXT'
      fname2 : string = '/tmp/matrix2.txt';

procedure dumpMtx;
begin


end;

procedure creatematrix(x,y : byte);
var b : byte;
    j : word;
    f : file{ of word};
begin
   assign (f, fname);
   //sleep(10);
   rewrite(f);
   //sleep(10);
   close(f);
   xMatrix := x; yMatrix := y;
b := 0;
   for j := 0 to x*y*2+1 do begin // matrix created two elements more than necessary
      EmuAvrMmcCardLib.write_byte_to_file(fname, j, b);
   end;
end;//creatematrix

procedure creatematrix2;
var b : byte;
    j : word;
    f : file of word;
begin
   assign (f, fname2);
   //sleep(10);
   rewrite(f);
   //sleep(10);
   close(f);

b := 0;
   for j := 0 to xMatrix*yMatrix*2+1 do begin // matrix created two elements more than necessary
      EmuAvrMmcCardLib.read_byte_from_file(fname, j, b);
      EmuAvrMmcCardLib.write_byte_to_file(fname2, j, b);
   end;
end; //creatematrix2

function getXY(x, y : byte):smallint;
var offset : word;
i,j : byte;
s : smallint;
begin
offset := (y-1) * xMatrix*2 + x*2 - 2;
EmuAvrMmcCardLib.read_byte_from_file(fname,offset, j);
inc(offset);
EmuAvrMmcCardLib.read_byte_from_file(fname, offset, i);
conv.Shorts2Int(i,j, s);
result := s;
end;

function getXY2(x, y : byte):smallint;
var offset : word;
i,j : byte;
s : smallint;
begin
offset := (y-1) * xMatrix*2 + x*2 - 2;
EmuAvrMmcCardLib.read_byte_from_file(fname2,offset, j);
inc(offset);
EmuAvrMmcCardLib.read_byte_from_file(fname2, offset, i);
conv.Shorts2Int(i,j, s);
result := s;
end;


procedure writeXY(x,y : byte; s : smallint);
var i,j : byte;
offset : word;
begin
offset := (y-1) * xMatrix*2 + x*2 - 2;
conv.Int2Shorts(s, i,j);
EmuAvrMmcCardLib.write_byte_to_file(fname, offset, j);
inc(offset);
EmuAvrMmcCardLib.write_byte_to_file(fname, offset, i);
end;// writeXY;

procedure writeXY2(x,y : byte; s : smallint);
var i,j : byte;
offset : word;
begin
offset := (y-1) * xMatrix*2 + x*2 - 2;
conv.Int2Shorts(s, i,j);
EmuAvrMmcCardLib.write_byte_to_file(fname2, offset, j);
inc(offset);
EmuAvrMmcCardLib.write_byte_to_file(fname2, offset, i);
end;// writeXY;


end.

