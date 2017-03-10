uses sysutils;

var f : file;
begin
assign (f, 'test.txt');
rewrite(f);
close(f);

end.
