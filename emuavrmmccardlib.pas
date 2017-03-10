unit EmuAvrMmcCardLib;

{$mode objfpc}{$H+}

interface
procedure write_byte_to_file(fname : string; offset : word; b : byte);
procedure read_byte_from_file(fname : string; offset : word; var res : byte);

implementation
    uses Sysutils, BaseUnix, dialogs;
(* original func from Avr source
procedure Write_byte_to_File(var filename : string[14]; offset:word; var content_byte : byte);
var tmp:byte;
     i:word;
     tmp_content: array [1] of byte;
begin
 tmp_content[0] := content_byte;
 Mmc_Fat_Assign(filename, 0);
// delay_ms(100);
 Mmc_Fat_Reset(size);
 if ( offset > 0 ) then
 begin
 for i:=0 to offset-1 do
  begin
   Mmc_Fat_Read(tmp);
  end;
 end;
 Mmc_Fat_Write(tmp_content, 1);
 Mmc_Fat_Reset(size);
end;  //write to file
*)

procedure write_byte_to_file(fname : string; offset : word; b : byte);
var f : cint;
p : string[2];
begin
//writeln ('entered write_byte_to_file'); writeln ('fname=' + fname);
p[2] := ' ';
p[1] := char(b);
if sysutils.FileExists(fname) then begin
f := BaseUnix.fpOpen(fname, o_wronly or o_creat, &666);
//sleep(100);
if f >= 0 then begin
   BaseUnix.fpLSeek(f, offset, Seek_Set);
   //sleep(100);
   BaseUnix.fpWrite (f, p[1], 1);
   //sleep(100);
   BaseUnix.fpClose(f);
   //sleep(100);
end
else
begin
    //dialogs.ShowMessage('failed to open for writing file ' + fname );
    writeln ('error opening for writing');
end;
end;
end; //write_byte_to_file

(* original function from Avr source *)
{
procedure Read_byte_from_file(var filename : string[14]; offset:word; var result:byte);
var i:word;
begin
  //filename := '12312312TXT';
  Mmc_Fat_Assign(filename, 0);
  Mmc_Fat_Reset(size);
  for i:=0 to offset do
   begin
  //while size > 0 do
  //  begin
      Mmc_Fat_Read(result);
  //    Lcd4_custom_chr_cp(result);
   //   Dec(size);
   end;
end; //end read_from_file
}


procedure read_byte_from_file(fname : string; offset : word; var res : byte);
var f : cint;
p : string[2];
begin
//writeln ('entered write_byte_to_file'); writeln ('fname=' + fname);
if sysutils.FileExists(fname) then begin
   f := BaseUnix.fpOpen(fname, o_rdonly);
   //sleep(100);
      if f >= 0 then begin
         BaseUnix.fpLSeek(f, offset, Seek_Set);
         //sleep(100);
         BaseUnix.fpRead(f, p[1], 1);
         BaseUnix.fpClose(f);
         //sleep(100);
         res := byte(p[1]);
      end
     else
      begin
         //dialogs.ShowMessage('failed to open for reading file ' + fname);
         writeln ('error while reading');
      end;
 end;
end;


end.

