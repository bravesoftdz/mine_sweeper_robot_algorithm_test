unit robot;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,
  Grids;
   const maxX = 30;
   const maxY = 30;
   const minX = 1;
   const minY = 1;
   maxPathLength :  integer = 5000; // maximum path index
   type Towards = (Up, Down, Left, Right);
   type segment = record
        x : byte;
        y : byte;
   end;
   type akanRobot = record
      direction : Towards;
      currentPosition : integer;
      currentSegment : segment;
      Sensor1, Sensor2, Sensor3, UltraVoice : boolean;
   end;

   var bot : akanRobot;
   defMinVal : integer;
   lastMinVal : integer;
//   matrix : array [minX..maxX] of array [minY..maxY] of integer;
procedure matrixtogrid(strgrd : TStringGrid);
procedure matrix2togrid(strgrd : TStringGrid);
procedure genLeePathRightToLeft;
procedure genLeePathLeftToRight;
procedure initMatrix;
procedure init;
procedure getSensors(s1, s2, s3, uv1 : boolean);
//function findNextLeeNumber(curNum : integer; var coords : segment) : integer;
function findNextMinimum({curNum : integer;}var curKoords : segment; var nxtKoords : segment) : integer;
function findnextstep(var curCoords: segment; var nextCoords : segment; strgrd : TStringGrid) : Towards;
procedure doNextStep(t : towards);
procedure fillMatrix;
procedure dumpMatrix2Outfile;
implementation
uses matrix, dialogs;{ sysutils;}
  const filename = 'filename.txt';
  const prevent = -10;
  const akan = -10;
  const dangerZone = -20;
  const wall = -30;
  const scanned = -1{ 31000};
  const defDistBetweenAkans = 3;
  const StartOffsetX = 3;
  const StartOffsetY = 4;
  dangerZoneOffset = 2;
   var scanDone, dumpResult : boolean;
   isLeftCorner : boolean;
   var
//    matrix2 : array [minX..maxX] of array [minY..maxY] of integer;
    maxPathIndex : word = 0;
    globalInitialCur : integer = 6000;  //start of search aimed segment


procedure genLeePathRightToLeft;
var pathIndex : word;
tmpx, x, y : byte;
genDone:boolean;
begin
 for x := minX to maxX do begin
          matrix.writeXY(x,minY,dangerZone);//matrix[x,minY] := dangerZone;
          matrix.writeXY(x,minY+1,dangerZone);//matrix[x,minY+1] := dangerZone;
          matrix.writeXY(x,minY+2,dangerZone);//matrix[x,minY+2] := dangerZone;
 end;
 for y := minY to maxY do begin
          matrix.writeXY(maxX,y,dangerZone);//matrix[maxX,y] := dangerZone;
          matrix.writeXY(maxX-1,y,dangerZone);//matrix[maxX-1,y] := dangerZone;
          matrix.writeXY(maxX-2,y,dangerZone);//matrix[maxX-2,y] := dangerZone;
 end;
gendone := false;
 pathIndex := 0;
 x := maxX - startOffsetX;
 y := minY -2 + startOffsetY;
  repeat
     // go Up
     repeat
       inc(pathIndex);
       inc(y);
       matrix.writeXY(x,y,pathIndex);//matrix[x,y] := pathIndex;
     until y = (maxY - 3);
     // go Left
     if (x - 3) >= (minX + 2) then begin
        tmpx := x;
        repeat
           dec(x);
           inc (pathIndex);
            matrix.writeXY(x,y,pathIndex); //matrix[x,y] := pathIndex;
        until (x = tmpx - 3) or (x <= minX);
        // go Down
        repeat
          dec(y);
          inc(pathIndex);
          matrix.writeXY(x,y,pathIndex);//matrix[x,y] := pathIndex;
        until y = minY + 2;
     end;//if
     //showmessage ('x='+inttostr(x)+' y='+inttostr(y));
     // go Left
     if (x - 3) >= (minX + 1) then begin
         tmpx := x;
         repeat
           dec(x);
           inc(pathIndex);
           matrix.writeXY(x,y,pathIndex);//matrix[x,y] := pathIndex;
         until (x = (tmpx - 3)) or (x <=minY) ;
     end
     else
        begin
          genDone:=true;
        end;
     //showmessage ('x='+inttostr(x)+' y='+inttostr(y));

 // until x-3 < ( minX + 2 );
 until gendone = true;
  //showmessage('end =] ');
  maxPathIndex := pathIndex;
end; //genLeePath

procedure genLeePathLeftToRight;
var pathIndex : word;
tmpx, x, y : byte;
genDone:boolean;
begin
 for x := minX to maxX do begin
          matrix.writeXY(x,minY,dangerZone);//matrix[x,minY] := dangerZone;
          matrix.writeXY(x,minY+1,dangerZone);//matrix[x,minY+1] := dangerZone;
          matrix.writeXY(x,minY+2,dangerZone);//matrix[x,minY+2] := dangerZone;
 end;
 for y := minY to maxY do begin
          matrix.writeXY(minX,y,dangerZone);//matrix[minX,y] := dangerZone;
          matrix.writeXY(minX+1,y,dangerZone);//matrix[minX+1,y] := dangerZone;
          matrix.writeXY(minX+2,y,dangerZone);//matrix[minX+2,y] := dangerZone;
end;
 pathIndex := 0;
 x := minX + startOffsetX;
 y := minY -1 + startOffsetY;
 gendone := false;


  repeat
     // go Up
     repeat
       inc(pathIndex);
       inc(y);
       matrix.writeXY(x,y,pathIndex);//matrix[x, y] := pathIndex;
     until y = (maxY - 3);
     // go Right
     if (x + 3) <= (maxX - 2) then begin
     tmpx := x;
        repeat
           inc(x);
           inc (pathIndex);
           matrix.writeXY(x,y,pathIndex);//matrix[x,y] := pathIndex;
        until (x = tmpx + 3) or (x >= maxX);

        // go Down
        repeat
          dec(y);
          inc(pathIndex);
          matrix.writeXY(x,y,pathIndex);//matrix[x,y] := pathIndex;
        until y = minY + 2;
        //showmessage ('x='+inttostr(x)+' y='+inttostr(y));
     end;//if
     // go Right
     if (x + 3) <= (maxX - 1) then begin
         tmpx := x;
         repeat
           inc(x);
           inc(pathIndex);
           matrix.writeXY(x,y,pathIndex);//matrix[x,y] := pathIndex;
         until (x = tmpx + 3) or (x >= maxX);
     end
     else
        begin
          genDone:=true;
        end;
//     dialogs.showmessage ('x='+inttostr(x)+' y='+inttostr(y));
 until gendone = true;
  maxPathIndex := pathIndex;
//  until x+3 >= ( maxX - 2 );

  //showmessage('end =] ');
end; //genLeePathLeftToRight

procedure initMatrix;
var i,j : byte;
begin
matrix.creatematrix(maxX,maxY);
{
 for i:=minX to maxX do
  for j:=minY to MaxY do
   matrix[i,j]:=0 ;}

end; //initMatrix

procedure matrix2togrid(strgrd : TStringGrid);
var i,j : byte;
begin
strgrd.ColCount:= maxX + 1;
strgrd.RowCount:= maxY + 1;
  for i:=minX to maxX do begin
   for j:=minY to maxY do begin
//   strgrd.Cells[i,j] := SysUtils.IntToStr(matrix2[i,j]);
     strgrd.Cells[i,j] := SysUtils.IntToStr(matrix.getXY2(i,j));
   end;
  end;
end; //matrixtogrid


procedure matrixtogrid(strgrd : TStringGrid);
var i,j : byte;
//s : string;
begin
strgrd.ColCount:= maxX + 1;
strgrd.RowCount:= maxY + 1;

//s := SysUtils.IntToStr(matrix.getXY(25,1));
//dialogs.ShowMessage(s);
//dialogs.ShowMessage(SysUtils.IntToStr(matrix.getXY(25,6)));
  for i:=minX to maxX do begin
   for j:=minY to maxY do begin
//   strgrd.Cells[i,j] := SysUtils.IntToStr(matrix[i,j]);
     strgrd.Cells[i,j] := SysUtils.IntToStr(matrix.getXY(i,j));
   end;
  end;
//s := SysUtils.IntToStr(matrix.getXY(25,1));
//dialogs.ShowMessage(s);
//s := strgrd.Cells[1,1];
//     dialogs.showmessage(s);
//s := strgrd.Cells[25,1];
//      dialogs.showmessage(s);
end; //matrixtogrid

procedure init;
var WallRight : boolean;
begin
defMinVal := 1;
lastMinVal := 1;

initMatrix;
//matrix.writeXY(1,1,-300);
//matrix.writeXY(25,1,-300);

WallRight := true;

if WallRight then begin
   bot.currentSegment.x := maxX -startOffsetX;
   genLeePathRightToLeft;
end
else
begin
   bot.currentSegment.x := minX +startOffsetX;
   robot.genLeePathLeftToRight;
end;
bot.currentSegment.y := minY + startOffsetY-1;
bot.currentPosition := 1;
bot.direction := Up;
bot.Sensor1 := false; bot.Sensor2 := false; bot.Sensor3 := false;  bot.UltraVoice := false;
end;

procedure setAkan (x, y : byte);
var i, j : shortint;
begin
   for i := x - defDistBetweenAkans to x + defDistBetweenAkans do begin
       for j := y - defDistBetweenAkans to y + defDistBetweenAkans do begin
           if (i>= minX) and (j >= minY) and (i <= maxX) and (j <= maxY) then begin
               //if matrix[i,j] > prevent then begin
                if (matrix.getXY(i,j) > prevent) then begin
                      matrix.writeXY(i,j,scanned); //matrix[i,j] := scanned
               end;
           end;
       end;
   end;

   matrix.writeXY(x,y,akan);//matrix[x,y] := akan;
   matrix.writeXY(x-1,y,dangerZone);//matrix[x-1,y] := dangerZone;
   if x-2 = minX then begin
            matrix.writeXY(x-2,y,dangerZone);//matrix[x-2,y] := dangerZone;
            matrix.writeXY(x-2,y -1,dangerZone);//matrix[x-2,y -1] := dangerZone;
            matrix.writeXY(x-2,y + 1,dangerZone);//matrix[x-2,y + 1] := dangerZone;
   end; //pateri koghmic chshrjancelu hamar
   matrix.writeXY(x+1,y,dangerZone);//matrix[x+1,y] := dangerZone;
   if (x + 2 = maxX) then begin
      matrix.writeXY(x +2, y,dangerZone);//matrix[x +2, y] := dangerZone;
      matrix.writeXY(x +2, y-1,dangerZone);//matrix[x +2, y-1] := dangerZone;
      matrix.writeXY(x +2, y+1,dangerZone);//matrix[x +2, y+1] := dangerZone;
   end;
   matrix.writeXY(x-1,y-1,dangerZone);//matrix[x-1,y-1] := dangerZone;
   matrix.writeXY(x+1,y-1,dangerZone);//matrix[x+1,y-1] := dangerZone;
   if y + 2 = maxY then begin
      matrix.writeXY(x, y + 2, dangerZone);//matrix[x, y + 2] := dangerZone;
      matrix.writeXY(x-1, y + 2,dangerZone) ;//matrix[x-1, y + 2]:= dangerZone ;
      matrix.writeXY(x+1, y + 2,dangerZone);//matrix[x+1, y + 2] := dangerZone;
   end;
   if y - 2 = minY then begin
      matrix.writeXY(x, y - 2,dangerZone);//matrix[x, y - 2] := dangerZone;
      matrix.writeXY(x-1, y - 2,dangerZone) ;//matrix[x-1, y - 2]:= dangerZone ;
      matrix.writeXY(x+1, y - 2, dangerZone);//matrix[x+1, y - 2] := dangerZone;
   end;
   matrix.writeXY(x-1,y+1,dangerZone);//matrix[x-1,y+1] := dangerZone;
   matrix.writeXY(x+1, y+1,dangerZone);//matrix[x+1, y+1] := dangerZone;
   matrix.writeXY(x, y-1, dangerZone);//matrix[x, y-1] := dangerZone;
   matrix.writeXY(x, y+1,dangerZone);//matrix[x, y+1] := dangerZone;
end; //setAkan

procedure fillMatrix;
var x,y : byte;
begin

      if bot.Sensor1 then begin
          if bot.direction = Up then begin
             setAkan(bot.currentSegment.x - 1, bot.currentSegment.y + 2);
          end;
          if bot.direction = Down then begin
              setAkan(bot.currentSegment.x + 1, bot.currentSegment.y -2);
          end;
          if bot.direction = Left then begin
             setAkan(bot.currentSegment.x - 2, bot.currentSegment.y - 1 );
          end;
          if bot.direction = Right then begin
              setAkan(bot.currentSegment.x + 2, bot.currentSegment.y  + 1);
          end;

      end;
      if bot.Sensor2 then begin
          if bot.direction = Up then begin
             setAkan(bot.currentSegment.x, bot.currentSegment.y + 2);
          end;
          if bot.direction = Down then begin
              setAkan(bot.currentSegment.x, bot.currentSegment.y -2);
          end;
          if bot.direction = Left then begin
             setAkan(bot.currentSegment.x - 2, bot.currentSegment.y );
          end;
          if bot.direction = Right then begin
              setAkan(bot.currentSegment.x + 2, bot.currentSegment.y );
          end;
      end;
      if bot.Sensor3 then begin
          if bot.direction = Up then begin
             setAkan(bot.currentSegment.x + 1, bot.currentSegment.y +2);
          end;
          if bot.direction = Down then begin
              setAkan(bot.currentSegment.x - 1, bot.currentSegment.y -2);
          end;
          if bot.direction = Left then begin
             setAkan(bot.currentSegment.x - 2, bot.currentSegment.y + 1 );
          end;
          if bot.direction = Right then begin
              setAkan(bot.currentSegment.x + 2, bot.currentSegment.y  - 1);
          end;
      end;
      if bot.UltraVoice then begin
             if (bot.direction = Up) and (bot.currentSegment.y + 2 <= maxY) then begin
                 for x := minX to maxX do begin
                    for y := bot.currentSegment.y + 2 to maxY do begin
                     matrix.writeXY(x, y,{wall}dangerZone);//matrix[x, y] := {wall}dangerZone;
                     end;
                 end;
             end;
             if (bot.direction = Down) and (bot.currentSegment.y - 2 >=minY) then begin
                 for x := minX to maxX do begin
                    for y := bot.currentSegment.y - 2 to minY do begin
                     matrix.writeXY(x, y,{wall}dangerZone);//matrix[x, y] := {wall}dangerZone;
                     end;
                 end;
             end;

             if (bot.direction = Left) and (bot.currentSegment.x - 2 >= minX)then begin
                 for x := minx to bot.currentSegment.x - 2 do begin
                    for y := minY to maxY do begin;
                     matrix.writeXY(x, y,{wall}dangerZone);//matrix[x, y] := {wall}dangerZone;
                     end;
                 end;
             end;
             if (bot.direction = Right) and (bot.currentSegment.x + 2 <= maxX) then begin
                 for x := bot.currentSegment.x + 2 to maxX do begin
                    for y := minY to maxY do begin
                     matrix.writeXY(x, y,{wall}dangerZone);//matrix[x, y] := {wall}dangerZone;
                     end;
                 end;
             end;
      end;

end; //fillMatrix

procedure getSensors(s1, s2, s3, uv1 : boolean);
//this function actually write sensors, but on the robot it get sensors;
// then it fills the matrix with the corresponding numbers;
begin
   bot.Sensor1 := s1;
   bot.Sensor2 := s2;
   bot.Sensor3 := s3;
   bot.UltraVoice := uv1;
{if (bot.Sensor1 or bot.Sensor2 or bot.Sensor3 or bot.UltraVoice) then begin
   fillMatrix;
end;}
//bot.Sensor1 := false; bot.Sensor2 :=false; bot.Sensor3 := false; bot.UltraVoice := false;
end; //getSensors;



function findNextMinimum({curNum : integer;}var curKoords : segment; var nxtKoords : segment) : integer;
// returns next minimal number and its coordinates
var xx,yy, xF, yF : byte;
minVal, tmpVal, nxtVal : integer;
begin
matrix.writeXY(curKoords.x, curKoords.y,scanned);//matrix[curKoords.x, curKoords.y]:=scanned;

tmpVal := maxPathLength; //num path cannot reach;
    for xx := minX to maxX do begin
       for yy := minY to maxY do begin
           if (matrix.getXY(xx,yy) > defminVal) then begin//if (matrix[xx,yy] > defminVal) then begin
              if matrix.getXY(xx,yy) < tmpVal then begin//if matrix[xx,yy] < tmpVal then begin
               tmpVal := matrix.getXY(xx,yy);//matrix[xx,yy];
               xF := xx; yF := yy;
              end;
           end;
       end;
    end;
    dialogs.ShowMessage('NextMinimum='+ IntToStr(tmpVal));
    nxtKoords.x := xF;
    nxtKoords.y := yF;
    result := tmpVal;
end;  //findNextMinimum

procedure dumpMatrix2Outfile;
begin
 matrix
end; //dumpMatrix2Outfile

function findnextstep(var curCoords: segment; var nextCoords : segment; strgrd : TStringGrid) : Towards;
var i,j : byte;
curr, initialCurr, finish : integer;
changed : boolean;
destIndex, curIndex : integer;
dire : Towards;
begin
destIndex := matrix.getXY(nextCoords.x, nextCoords.y);//destIndex := matrix[nextCoords.x, nextCoords.y]; //remember destination
showmessage ('next coords x=' + inttostr(nextCoords.x) + ' y=' + inttostr(nextcoords.y));
curIndex := matrix.getXY(curCoords.x, curCoords.y);//curIndex := matrix[curCoords.x, curCoords.y]; //remember source
initialCurr := globalInitialCur;
curr := initialCurr;
matrix.creatematrix2;//matrix2 := matrix;
matrix.writeXY2(curCoords.x, curCoords.y, curr);//matrix2[curCoords.x, curCoords.y] := curr; //must be > tmpVal in previous func
changed := false;
repeat
for i := 1 to maxX do begin
   for j := 1 to maxY do begin
        if matrix.getXY2(i,j) = curr then begin//if matrix2[i,j] = curr then begin
           if (j> minY) and (matrix.getXY2(i,j-1) > prevent) and (matrix.getXY2(i,j-1) < initialCurr) then begin//if (j> minY) and (matrix2[i,j-1] > prevent) and (matrix2[i,j-1] < initialCurr) then begin //actually 2 is minY+1 and j is checked to prevent matrix overflow
              matrix.writeXY2(i,j-1,curr +1);//matrix2[i,j-1] := curr +1;
              strgrd.Cells[i, j-1] := IntToStr(curr+1);// ShowMessage('x=' + IntToStr(i) + ' y=' + IntToStr(j-1) + ' cur+1=' + IntToStr(curr+1));
              changed := true;
           end;
           if (j <= (maxY-1)) and (matrix.getXY2(i,j+1) > prevent) and (matrix.getXY2(i,j+1) < initialCurr) then begin//if (j <= (maxY-1)) and (matrix2[i,j+1] > prevent) and (matrix2[i,j+1] < initialCurr) then begin
              matrix.writeXY2(i,j+1,curr +1);//matrix2[i,j+1] := curr +1;
              strgrd.Cells[i, j+1] := IntToStr(curr+1);// ShowMessage('x=' + IntToStr(i) + ' y=' + IntToStr(j+1) + ' cur+1=' + IntToStr(curr+1));
              changed := true;
           end;
           if (i > minX) and (matrix.getXY2(i-1,j) > prevent ) and (matrix.getXY2(i-1,j) < initialCurr) then begin //if (i > minX) and (matrix2[i-1,j] > prevent ) and (matrix2[i-1,j] < initialCurr) then begin
              matrix.writeXY2(i-1,j,curr +1);//matrix2[i-1,j] := curr +1;
              strgrd.Cells[i-1, j] := IntToStr(curr+1);// ShowMessage('x=' + IntToStr(i+1) + ' y=' + IntToStr(j) + ' cur+1=' + IntToStr(curr+1));
              changed := true;
           end;
           if (i < maxX) and (matrix.getXY2(i+1,j) > prevent) and (matrix.getXY2(i+1,j) < initialCurr) then begin//if (i < maxX) and (matrix2[i+1,j] > prevent) and (matrix2[i+1,j] < initialCurr) then begin
              matrix.writeXY2(i+1,j,curr +1);//matrix2[i+1,j] := curr +1;
              strgrd.Cells[i+1, j] := IntToStr(curr+1);// ShowMessage('x=' + IntToStr(i+1) + ' y=' + IntToStr(j) + ' cur+1=' + IntToStr(curr+1));
              changed := true;
           end;
        end;
   end;
end;
inc(curr);

until (changed = false) or (matrix.getXY2(nextCoords.x, nextCoords.y) <> destIndex);//until (changed = false) or (matrix2[nextCoords.x, nextCoords.y] <> destIndex);
if  (changed = false) then begin
    dialogs.ShowMessage('no way, panic!');
    halt;
end;
finish := matrix.getXY2(nextCoords.x, nextCoords.y);//finish := matrix2[nextCoords.x, nextCoords.y];
dialogs.ShowMessage('way length ' + inttostr(finish - initialCurr)); // simple way to calculate way length

//now search for the way back
i := nextCoords.x; j := nextCoords.y;
repeat
  if (i < maxX) and (matrix.getXY2(i + 1, j) = (finish -1)) then begin //if (i < maxX) and (matrix2[i + 1, j] = (finish -1)) then begin
  i := i + 1; dire := Left;         dec(finish); //showmessage ('left');
  end
else
  begin
     if (i > minX) and (matrix.getXY2(i-1, j) = (finish - 1)) then begin //if (i > minX) and (matrix2[i-1, j] = (finish - 1)) then begin
      i := i - 1; dire := Right; dec(finish);   //showmessage('right');
     end
    else
     begin
        if  (j > minY) and (matrix.getXY2(i,j-1) = (finish -1)) then begin //if  (j > minY) and (matrix2[i,j-1] = (finish -1)) then begin
            j := j - 1; dire := Up; dec(finish);//  showmessage('up');
        end
       else
        begin
            if (j < maxY) and (matrix.getXY2(i, j+1) = (finish -1)) then begin //if (j < maxY) and (matrix2[i, j+1] = (finish -1)) then begin
                 j := j + 1;     dire := Down;  dec(finish); //showmessage('down');
            end; // if j + 1
        end; //if j - 1
     end; // if i - 1
  end; //if i+ i
until matrix.getXY2(i,j) =  initialCurr;//until matrix2[i,j] =  initialCurr;
// restore source and destination
matrix.writeXY(nextCoords.x, nextCoords.y,destIndex);//matrix[nextCoords.x, nextCoords.y] := destIndex; //restore destination
//matrix[curCoords.x, curCoords.y] := curIndex; //restore source
   result := dire;
end;//findnextstep

procedure RotateLeft;
begin


end;

procedure RotateRight;
begin

end;

procedure MoveForward; //moves robot to the next square
begin


end;

procedure doNextStep(t : towards);
begin
   If bot.direction <> t then begin
     if bot.direction = Up then begin
        if t = Down then begin
           RotateLeft; RotateLeft;
        end;
        if t = Left then begin
           RotateLeft;
        end;
        if t = Right then begin
           RotateRight;
        end;
     end; //if Up
     if bot.direction = Down then begin
        if t = Up then begin
           RotateRight; RotateRight;
        end;
        if t = Left then begin
           RotateRight;
        end;
        if t = Right then begin
           RotateLeft;
        end;
     end;        //if Down
     if bot.direction = Left then begin
        if t = Up then begin
           RotateRight;
        end;
        if t = Right then begin
           RotateRight; RotateRight;
        end;
        if t = Down then begin
           RotateLeft;
        end;
     end;                // if Left
     if bot.direction = Right then begin
          if t = Down then begin
             RotateRight;
          end;
          if t = Left then begin
             RotateRight; RotateRight;
          end;
          if t = Up then begin
             RotateLeft;
          end;
     end; //if right
   end; // if bot.direction # t
      matrix.writeXY(bot.currentSegment.x,bot.currentSegment.y, scanned);//matrix[bot.currentSegment.x,bot.currentSegment.y] := scanned;
      if t = Up then begin    inc(bot.currentSegment.y); end;
      if t = Down then dec(bot.currentSegment.y);
      if t = Left then dec(bot.currentSegment.x);
      if t = Right then inc(bot.currentSegment.x);
      bot.currentPosition:= matrix.getXY(bot.currentSegment.x, bot.currentSegment.y);//bot.currentPosition:= matrix[bot.currentSegment.x, bot.currentSegment.y];
      bot.direction:= t;
      MoveForward;
end; //doNextStep;
end.

