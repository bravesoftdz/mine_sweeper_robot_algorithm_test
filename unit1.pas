unit Unit1; 

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Grids, ExtCtrls, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    bot: TButton;
    bot2: TButton;
    HideBot: TButton;
    Go: TButton;
    Ok: TButton;
    Clear: TButton;
    UltraVoice: TCheckBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Sensors: TRadioGroup;
    StringGrid1: TStringGrid;
    procedure ClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GoClick(Sender: TObject);
    procedure HideBotClick(Sender: TObject);
    procedure OkClick(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation
  uses robot;
{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Panel1.Caption:='';
  Panel2.Caption:='';
  Panel2.Align:= alClient;
StringGrid1.DefaultColWidth := 25;
StringGrid1.DefaultRowHeight := 25;
StringGrid1.ColCount := robot.maxX + 1;
StringGrid1.ColCount := robot.maxY + 1;
Sensors.Items.Add('Sensor1');
Sensors.Items.Add('Sensor2');
Sensors.Items.Add('Sensor3');
Sensors.Enabled := false;
UltraVoice.Enabled := false;
Clear.Enabled := false;
OK.Enabled := false;
UltraVoice.checked  := false;
Sensors.ItemIndex := -1;
//form1.WindowState := wsMaximized;
bot.Parent := StringGrid1;
bot2.Parent := StringGrid1;
bot2.Caption:= 'nose';
HideBot.Caption:= 'Hide bot';

robot.init;

robot.matrixtogrid(StringGrid1);
//StringGrid1.Cells[robot.currentSegment.x, currentSegment.y] := 'X';
end;

procedure TForm1.ClearClick(Sender: TObject);
begin
  UltraVoice.checked  := false;
Sensors.ItemIndex := -1;
end;

procedure TForm1.GoClick(Sender: TObject);
begin
   //inc(robot.currentSegment.y);
Sensors.Enabled := true;
UltraVoice.Enabled := true;
Clear.Enabled := true;
OK.Enabled := true;
OK.TabOrder:=1;
Go.Enabled := false;
UltraVoice.checked  := false;
Sensors.ItemIndex := -1;

//StringGrid1.Repaint;


end;

procedure TForm1.HideBotClick(Sender: TObject);
begin
if bot.Visible = true then begin
  bot.Visible:= false;
  bot2.Visible:= false;
  HideBot.Caption:= 'Show bot';
end
else
begin
//if bot.Visible = false then begin
  bot.Visible:= true;
  bot2.Visible:= true;
  HideBot.Caption:= 'Hide bot';
end;
end;

procedure TForm1.OkClick(Sender: TObject);
var s1, s2, s3 : boolean;
nxtKoords : robot.segment;
nxtNum : integer;
direct : robot.Towards;
begin
Sensors.Enabled := false;
UltraVoice.Enabled := false;
Clear.Enabled := false;
OK.Enabled := false;
Go.Enabled := true;
if Sensors.ItemIndex = 0 then begin
    s1 := true; s2 := false; s3 := false;
end;
if Sensors.ItemIndex = 1 then begin
    s1 := false; s2 := true; s3 := false;
end;
if Sensors.ItemIndex = 2 then begin
    s1 := false; s2 := false; s3 := true;
end;
if Sensors.ItemIndex = -1 then begin
    s1 := false; s2 := false; s3 := false;
end;
robot.getSensors (s1, s2, s3,   UltraVoice.Checked);

if (robot.bot.Sensor1 or robot.bot.Sensor2 or robot.bot.Sensor3 or robot.bot.UltraVoice) then begin
   if ((robot.bot.Sensor1) and (robot.bot.Sensor2) and (robot.bot.Sensor3 = false))
   or ((robot.bot.Sensor1 = false) and (robot.bot.Sensor2) and (robot.bot.Sensor3)) then begin
      robot.bot.Sensor2 := false;
      showmessage('DropMark left or right');
   end;
   if (robot.bot.Sensor1) and (robot.bot.Sensor2) and (robot.bot.Sensor3) then begin
      robot.bot.Sensor1 := false;
      robot.bot.Sensor3 := false; showmessage ('dropmark middle');
   end;
   robot.fillMatrix;
end;


robot.bot.Sensor1 := false; robot.bot.Sensor2 :=false; robot.bot.Sensor3 := false; robot.bot.UltraVoice := false;

nxtNum:=robot.findNextMinimum(robot.bot.currentSegment, nxtKoords );
if (nxtNum = robot.maxPathLength) or (nxtNum = 0) then begin robot.dumpMatrix2Outfile; halt; end;

direct := robot.findnextstep(robot.bot.currentSegment, nxtKoords, StringGrid1);
robot.donextstep(direct);
robot.matrixtogrid(StringGrid1);
//robot.matrix2togrid(StringGrid1);
//bot2.Visible := false;
//bot.Visible := false;
StringGrid1.Repaint;
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var P:TPoint;
begin
if robot.bot.direction = robot.Up then begin
   if (aCol = robot.bot.currentSegment.x) and (aRow = robot.bot.currentSegment.y -1) then begin
       bot.Width:= aRect.Right - aRect.Left + StringGrid1.DefaultColWidth;
       bot.Height := StringGrid1.DefaultRowHeight * 3;
       P := Form1.ScreenToClient ( StringGrid1.ClientToScreen( Point (aRect.Left, aRect.Top) ) );
       bot.Left:= (P.X - Round(StringGrid1.DefaultColWidth{/2}) - 1);
       bot.Top:= P.Y - Round(StringGrid1.DefaultRowHeight*0.5)+ 1;

       bot2.Width:= StringGrid1.DefaultColWidth * 3;
       bot2.Height := StringGrid1.DefaultRowHeight;
       P := Form1.ScreenToClient ( StringGrid1.ClientToScreen( Point (aRect.Left, aRect.Top) ) );
       bot2.Left:= (P.X - StringGrid1.DefaultColWidth - Round(StringGrid1.DefaultColWidth/2));
       bot2.Top:= P.Y + StringGrid1.DefaultRowHeight * 4 - Round(StringGrid1.DefaultRowHeight*1.5){ Round(StringGrid1.DefaultRowHeight/2)} + 1;
  end;
end;
if  robot.bot.direction = robot.Down then begin
       if (aCol = robot.bot.currentSegment.x) and (aRow = robot.bot.currentSegment.y -1) then begin
       bot.Width:= aRect.Right - aRect.Left + StringGrid1.DefaultColWidth;
       bot.Height := StringGrid1.DefaultRowHeight * 3;
       P := Form1.ScreenToClient ( StringGrid1.ClientToScreen( Point (aRect.Left, aRect.Top) ) );
       bot.Left:= (P.X - Round(StringGrid1.DefaultColWidth{/2}) - 1);
       bot.Top:= P.Y - Round(StringGrid1.DefaultRowHeight/2) + 1;

       bot2.Width:= StringGrid1.DefaultColWidth * 3;
       bot2.Height := StringGrid1.DefaultRowHeight;
       P := Form1.ScreenToClient ( StringGrid1.ClientToScreen( Point (aRect.Left, aRect.Top) ) );
       bot2.Left:= (P.X - StringGrid1.DefaultColWidth - Round(StringGrid1.DefaultColWidth/2));
       bot2.Top:= P.Y - Round(StringGrid1.DefaultRowHeight*1.5)+ 1;
  end;
end;
if robot.bot.direction = robot.Left then begin
   if (aCol = robot.bot.currentSegment.x) and (aRow = robot.bot.currentSegment.y -1) then begin
       bot.Height:= aRect.Right - aRect.Left + StringGrid1.DefaultColWidth;
       bot.Width := StringGrid1.DefaultRowHeight * 3;
       P := Form1.ScreenToClient ( StringGrid1.ClientToScreen( Point (aRect.Left, aRect.Top) ) );
       bot.Left:= (P.X - StringGrid1.DefaultColWidth - Round(StringGrid1.DefaultColWidth /2) {- 1});
       bot.Top:= P.Y;

       bot2.Height:= StringGrid1.DefaultColWidth * 3;
       bot2.Width := StringGrid1.DefaultRowHeight;
       P := Form1.ScreenToClient ( StringGrid1.ClientToScreen( Point (aRect.Left, aRect.Top) ) );
       bot2.Left:= (P.X - Round(2.5 * StringGrid1.DefaultColWidth));
       bot2.Top:= P.Y  - Round(StringGrid1.DefaultRowHeight*0.5)+ 1;
  end;
end;

if robot.bot.direction = robot.Right then begin
   if (aCol = robot.bot.currentSegment.x) and (aRow = robot.bot.currentSegment.y -1) then begin
       bot.Height:= aRect.Right - aRect.Left + StringGrid1.DefaultColWidth;
       bot.Width := StringGrid1.DefaultRowHeight * 3;
       P := Form1.ScreenToClient ( StringGrid1.ClientToScreen( Point (aRect.Left, aRect.Top) ) );
       bot.Left:= (P.X - StringGrid1.DefaultColWidth - Round(StringGrid1.DefaultColWidth /2) {- 1});
       bot.Top:= P.Y;

       bot2.Height:= StringGrid1.DefaultColWidth * 3;
       bot2.Width := StringGrid1.DefaultRowHeight;
       P := Form1.ScreenToClient ( StringGrid1.ClientToScreen( Point (aRect.Left, aRect.Top) ) );
       bot2.Left:= (P.X + Round(1.5 * StringGrid1.DefaultColWidth));
       bot2.Top:= P.Y - Round(StringGrid1.DefaultRowHeight*0.5)+1;
  end;
end;

end; //OnDrawCell

initialization
  {$I unit1.lrs}

end.

