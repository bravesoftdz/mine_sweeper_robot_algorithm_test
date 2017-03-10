uses matrix;
   const maxX = 30;
      const maxY = 30;
         const minX = 1;
	    const minY = 1;
	      const akan = -10;
	        const dangerZone = -20;
		  const scanned = -1

var q,w : byte;
tiv : smallint;
begin

for q := 1 to maxX do begin
   for w := 1 to maxY do begin
      tiv := matrix.getXY(q,w);
      if tiv = akan then begin
         writeln (x + ' , ' + y + '"m"');
      end;
      if tiv = scanned then begin
        writeln (x + ' , ' + y + '"c"');
      end;
   end;
end;   


end.
 

