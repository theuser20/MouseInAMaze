#!/usr/bin/perl  
#####################################################################
#
#####################################################################
#use strict;
#use warnings;
use Math::Complex;
use POSIX;

our @maze = ();
our $pr = 1;

#initializes a maze with rooms/pillars and walls
sub initMaze
{
  my $xSize = 0;
  my $ySize = 0;
  my @xMaze = ();
  my @yMaze = ();
  my $i = 0;
  my $j = 0;
  my $tempRoom = {};
  
  $xSize = ($_[0] * 2)+1;
  $ySize = ($_[1] * 2)+1;
  
  for ($i = 0; $i < $xSize; $i++)
  {
   for($j = 0; $j < $ySize; $j++)
   {
    $tempRoom = initOneRoom($i,$j);
    push @yMaze, $tempRoom;
    $tempRoom = {};
   }
   push (@xMaze , [@yMaze]);
   @yMaze = ();
  }
  return @xMaze;
} 

#set up one room wither a pillar wall or room, using hash like a struct
sub initOneRoom
{
  my $x = 0;
  my $y = 0;
  my $room = {};
  my $t = '';
  
  ($x,$y) = @_;
  
  if($x % 2 == 0 && $y % 2 == 0)
  {
   $t = 'P';
  }
  elsif($x % 2 == 1 && $y % 2 == 0 || $x % 2 == 0 && $y % 2 == 1)
  {
   $t = 'W';
  }
  else
  {
   $t = ' ';
  }
  
  $room->{'type'} = $t;
  $room->{'x'} = $x;
  $room->{'y'} = $y;
  $room->{'visited'} = 0;
  $room->{'knocked'} = 1;
  $room->{'cheese'} = 0;
  $room->{'mouse'} = 0;
  $room->{'mousevisit'} = 0;
  $room->{'deadEnd'} = 0;
  return $room;  
} 

#carves out the maze calling a start to the maze, knocking down a random wall moving to that new room,
#then backtracking if that new rooms adjacent rooms have all been visited or are out of bounds
sub makeMaze
{
  my @backTrack = ();
  my $done = 0;
  my $currentX = 0;
  my $currentY = 0;
  
  $done = $#maze;
  
  ($currentX, $currentY) = chooseStart();
  $maze[$currentX][$currentY]->{'visited'} = 1;
  
  print "Generating maze dimension x: ".$#maze." by y: ".$#{@{$maze[0]}}."\n";
  print "Starting at x: ".$currentX." y: ".$currentY."\n\n";
  while($done != 1)
  {

    ($currentX,$currentY) = randomWall($currentX,$currentY);

    $maze[$currentX][$currentY]->{'visited'} = 1;
    
    if($currentX != -1 && $currentY != -1)
    {
     push @backTrack, $maze[$currentX][$currentY];
    }

    ($currentX,$currentY) = chooseRoom($currentX,$currentY,\@backTrack);

    if($currentX == -1 || $currentY == -1)
    {
      $done = 1;
    }
  }
  
}

#randomly choose a starting position in the maze, needs to be a room not a wall or pillar 
sub chooseStart
{

  my $randX = -1;
  my $randY = -1;
  my $x = -1;
  my $y = -1;
  my $yRange = 0;
  my $xRange = 0;
  
  $xRange = scalar(@maze) - 1;
  $yRange = scalar(@{$maze[0]}) -1;
  
  while($x == -1 && $y == -1)
  {
    $randX = int(rand($xRange));
    $randY = int(rand($yRange));

    if($randX % 2 == 1 && $randY %2 == 1)
    {
      $x = $randX;
      $y = $randY;
    }
  }
  
  return ($x,$y);
}

#chooses a room with one or more adjacent rooms not occupied in the list does backtracking so if the current room 
#returns with all rooms around it visited, go to a previous room and try again
sub chooseRoom
{
  my $x = -1;
  my $y = -1;
  my $range = 0;
  my $btPos = 0;
  my $currentX = 0;
  my $currentY = 0;
  my @backTrack = ();
  
  $currentX = $_[0];
  $currentY = $_[1];
  @backTrack = @{$_[2]};
  
  $range = scalar(@maze);
  $btPos = scalar(@backTrack)-1;
  
  while($x == -1 && $y == -1 && $btPos >= 0)
  {
   if(everythingVisited($currentX, $currentY) == 1)
   {
    $currentX = $backTrack[$btPos]->{'x'};
    $currentY = $backTrack[$btPos]->{'y'};  
   }
   else
   {
     $x = $currentX;
     $y = $currentY;
   }
   $btPos--;   
  }
  return ($currentX,$currentY);
}

#check all rooms around current room and if all the other rooms have been visited return 1 for all rooms visited
sub everythingVisited
{
  my $allVisited = 0;

  my ($currentX, $currentY) = @_;
  
  if(($currentY+2 > scalar(@{$maze[0]}) -1 || $maze[$currentX][$currentY+2]->{'visited'} == 1) && ($currentY-2 <= 0 || $maze[$currentX][$currentY-2]->{'visited'} == 1)  && 
     ($currentX+2 > scalar(@maze) -1 || $maze[$currentX+2][$currentY]->{'visited'} == 1) && ($currentX-2 <= 0 || $maze[$currentX-2][$currentY]->{'visited'} == 1) )
 {
   $allVisited = 1;
 }
  return $allVisited;
}

#knock a random wall down and move into that new room.
sub randomWall
{
  my $randRange = 0;
  my $randNum = 0;
  my @xWalls = ();
  my @yWalls = ();
  my $xCord = 0;
  my $yCord = 0;
  my $xWall = 0;
  my $yWall = 0;
  my $i = 0;
  my $newX = -1;
  my $newY = -1;
  
  ($xCord, $yCord) = @_;
 
  #put all valid non knocked down walls into an array  
  if($xCord+2 < scalar(@maze) -1 && $maze[$xCord+2][$yCord]->{'visited'} == 0)
  {
    push @xWalls , $xCord+1;
    push @yWalls , $yCord;
    $randRange++;
  }
  if($xCord-2 > 0 && $maze[$xCord-2][$yCord]->{'visited'} == 0)
  {
    push @xWalls , $xCord-1;
    push @yWalls , $yCord;
    $randRange++;
  }
  if($yCord+2 < scalar(@{$maze[0]}) -1 && $maze[$xCord][$yCord+2]->{'visited'} == 0)
  {
    push @xWalls , $xCord;
    push @yWalls , $yCord+1;
    $randRange++;
  }
  if( $yCord-2 > 0 && $maze[$xCord][$yCord-2]->{'visited'} == 0)
  {
    push @xWalls , $xCord;
    push @yWalls , $yCord-1;
    $randRange++;
  }
   
  $randNum = int(rand($randRange));

   #choose the random wall to knock down and set the room that is behind to the current room
   for($i = 0; $i < $randRange && $randRange > 0; $i++)
   {
    if($i == $randNum)
    {
     $maze[$xWalls[$i]][$yWalls[$i]]->{'knocked'} = 0;

     if($xWalls[$i] > $xCord )
     {
       $newX = $xCord +2;
     }
     elsif($xWalls[$i] < $xCord )
     {
      $newX = $xCord -2;
     }
     if( $yWalls[$i] > $yCord )
     {
      $newY = $yCord +2;
     }
     elsif($yWalls[$i] < $yCord )
     {
      $newY = $yCord -2;
     }
    }    
   }
  
  #can only move in x or y dirrection set the other coordinate
  if($newY == -1 && $newX != -1)
  {
    $newY = $yCord;
  }
  if($newX == -1 && $newY != -1)
  {
   $newX = $xCord;
  }
  
  return ($newX,$newY);
}

#prints the maze data structure
sub printMaze
{
  my $i = 0;
  my $j = 0;
  

  for($i = 0; $i < scalar(@maze); $i++)
  {
    for($j = 0; $j < scalar(@{$maze[0]}); $j++)
    {
      if($maze[$i][$j]->{'knocked'} == 0)
      {
        print " ";
      }
      else
      {
        #print "X";
        print $maze[$i][$j]->{'type'};
      }
    }
    print "\n";
  }

}

#prints the maze data structure
sub printPrettyMaze
{
  my $i = 0;
  my $j = 0;
  

  for($i = 0; $i < scalar(@maze); $i++)
  {
    for($j = 0; $j < scalar(@{$maze[0]}); $j++)
    {
      if($maze[$i][$j]->{'knocked'} == 0)
      {
        print " ";
      }
      else
      {
        if($maze[$i][$j]->{'type'} eq 'P')
        {
          if(($maze[$i+1][$j]->{'knocked'} == 1 || $i-1 >= 0 && $maze[$i-1][$j]->{'knocked'} == 1) && ($maze[$i][$j+1]->{'knocked'} == 1 || $j-1 >= 0 && $maze[$i][$j-1]->{'knocked'} == 1))
          {
            print "+";
          }           
          elsif(($maze[$i+1][$j]->{'knocked'} == 0 || $maze[$i-1][$j]->{'knocked'} == 0) && ($maze[$i][$j+1]->{'knocked'} == 1 || $maze[$i][$j-1]->{'knocked'} == 1))
          {
           print "-";
          }
          elsif(($maze[$i][$j+1]->{'knocked'} == 0 || $maze[$i][$j+1]->{'knocked'} == 0) && ($maze[$i+1][$j]->{'knocked'} == 1 || $maze[$i-1][$j]->{'knocked'} == 1))
          {
            print "|";
          }
                    
          else
          {
            print "+";
          }          
        }
        elsif($maze[$i][$j]->{'type'} eq 'W')
        {
          if($maze[$i+1][$j]->{'type'} eq 'P' || $maze[$i-1][$j]->{'type'} eq 'P')
          {
            print "|";
          }
          else
          {
            print "-";
          }          
        }
        else
        {
          print " ";
        }
      }
    }
    print "\n";
  }

}
sub printGame
{
  my $i = 0;
  my $j = 0;
  my $prevX = -1;
  my $prevY = -1;
 
 if($pr ==1)
 { 
  ($prevX,$prevY) = @_;
  
  select(undef, undef, undef, 0.25);
  system("clear");
 
   for($i = 0; $i < scalar(@maze); $i++)
   {
    for($j = 0; $j < scalar(@{$maze[0]}); $j++)
    {
      if($maze[$i][$j]->{'knocked'} == 0)
      {
        print " ";
      }
      else
      {
        if($maze[$i][$j]->{'type'} eq 'P')
        {
          if(($maze[$i+1][$j]->{'knocked'} == 1 || $i-1 >= 0 && $maze[$i-1][$j]->{'knocked'} == 1) && ($maze[$i][$j+1]->{'knocked'} == 1 || $j-1 >= 0 && $maze[$i][$j-1]->{'knocked'} == 1))
          {
            print "+";
          }           
          elsif(($maze[$i+1][$j]->{'knocked'} == 0 || $maze[$i-1][$j]->{'knocked'} == 0) && ($maze[$i][$j+1]->{'knocked'} == 1 || $maze[$i][$j-1]->{'knocked'} == 1))
          {
           print "-";
          }
          elsif(($maze[$i][$j+1]->{'knocked'} == 0 || $maze[$i][$j+1]->{'knocked'} == 0) && ($maze[$i+1][$j]->{'knocked'} == 1 || $maze[$i-1][$j]->{'knocked'} == 1))
          {
            print "|";
          }
                    
          else
          {
            print "+";
          }          
        }
        elsif($maze[$i][$j]->{'type'} eq 'W')
        {
          if($maze[$i+1][$j]->{'type'} eq 'P' || $maze[$i-1][$j]->{'type'} eq 'P')
          {
            print "|";
          }
          else
          {
            print "-";
          }          
        }
        elsif($maze[$i][$j]->{'deadEnd'} == 1)
        {
          print "X";
        }
        else
        {
          if($maze[$i][$j]->{'mouse'} == 1)
          {
           if($prevY < $j)
           {
             print ">";
           }
           elsif($prevX < $i)
           {
             print "V";
           }
           elsif($prevX > $i)
           {
             print "^";
           }
           else
           {           
            print "<";
           }
          }
          elsif($maze[$i][$j]->{'cheese'} == 1)
          {  
            print "C";
          }
          else
          {
           print " ";
          }
        }
      }
     }
     print "\n";
   }
 }
}

sub startEnd
{
  my $startX = 0;
  my $startY = 0;
  my $endX = 0;
  my $endY = 0;

  
  ($startX,$startY) = chooseStart();
  $maze[$startX][$startY]->{'mouse'} = 1;
  $maze[$startX][$startY]->{'mousevisit'} = 1;
  ($endX, $endY) = chooseStart();
  $maze[$endX][$endY]->{'cheese'} = 1;
  
  return ($startX,$startY,$endX,$endY);
}

sub travlingMouse
{
  my @backTrack = ();
  my $done = 0;
  my $currentX = 0;
  my $currentY = 0;
  my $endX = 0;
  my $endY = 0;
  my $prevX = -1;
  my $prevY = -1;
  my $weight = 0.0;
  
  ($weight) = $_[0];
  
  $done = $#maze;
  
  ($currentX,$currentY,$endX,$endY) = startEnd();
  $maze[$currentX][$currentY]->{'mousevisit'} = 1;
  
  push @backTrack, $maze[$currentX][$currentY];
  
  printGame();
  
  while($done != 1)
  {
    $maze[$currentX][$currentY]->{'mouse'} = 0;
    $prevX = $currentX;
    $prevY = $currentY;
    ($currentX,$currentY) = mouseMove($currentX,$currentY,$endX,$endY,$weight);

    $maze[$currentX][$currentY]->{'mouse'} = 1;
    $maze[$currentX][$currentY]->{'mousevisit'} = 1;
      
    if($currentX == $endX && $currentY == $endY)
    {
      $done = 1;
    }
    else
    {
      if($currentX != -1 && $currentY != -1 && $maze[$currentX][$currentY]->{'deadEnd'} != 1)
      {
       push @backTrack, $maze[$currentX][$currentY];
      }
     
      ($currentX,$currentY,$prevX,$prevY) = chooseMouseRoom($currentX,$currentY,$prevX,$prevY,\@backTrack);

      if($currentX != -1 && $currentY != -1 && $maze[$currentX][$currentY]->{'deadEnd'} != 1)
      {
       push @backTrack, $maze[$currentX][$currentY];
      } 
      if($currentX == $endX && $currentY == $endY || $currentX == -1 || $currentY == -1 )
      {
        $done = 1;
      }      
    }
  } 

  printGame($prevX,$prevY);
}

sub mouseMove
{
  my $randRange = 0;
  my $randNum = 0;
  my @xWalls = ();
  my @yWalls = ();
  my $xCord = 0;
  my $yCord = 0;
  my $xWall = 0;
  my $yWall = 0;
  my $i = 0;
  my $newX = -1;
  my $newY = -1;
  my $endX = 0;
  my $endY = 0;
  my $weight = 0.0;
  my $max = 100;
  my $weightHigh = 0;  
  my $xWeightHigh = 0;
  my $yWeightHigh = 0;  
  my $weightLow = 0;
  my $weightInc = 0;
  my $xDif = 0;
  my $yDif = 0;
  
  ($xCord, $yCord,$endX,$endY,$weight) = @_;
 
  if($weight <= 0.0)
  {
   $weightHigh = int($max/2)
  }
  else
  {
   $weightHigh = int($max*$weight);
  }
  
  $weightLow = $max-$weightHigh;
  $weightLow = int($weightLow/2);
  
  $xDif = $endX - $xCord;
  $yDif = $endY - $yCord;
  
  if($xDif+$yDif != 0 && $weight != 0.0)
  {
   $xWeightHigh = int($weightHigh * (abs($xDif)/(abs($xDif)+abs($yDif))));
  }
  else
  {
   $xWeightHigh = int($weightHigh/2);
  }
  
  $yWeightHigh = $weightHigh - $xWeightHigh;
  
  #put all valid non knocked down walls into an array  
  if($xCord+2 < scalar(@maze) -1 && $maze[$xCord+2][$yCord]->{'mousevisit'} == 0 && $maze[$xCord+1][$yCord]->{'knocked'} != 1 && $maze[$xCord+2][$yCord]->{'deadEnd'} != 1)
  {
    if($xDif > 0)
    {
      $weightInc = $xWeightHigh;
    }
    else
    {    
      $weightInc = $weightLow;
    }
    
    while($weightInc >= 0)
    {
     push @xWalls , $xCord+1;
     push @yWalls , $yCord;
     $randRange++;
     $weightInc--;
    }
  }
  if($xCord-2 > 0 && $maze[$xCord-2][$yCord]->{'mousevisit'} == 0 && $maze[$xCord-1][$yCord]->{'knocked'} != 1 && $maze[$xCord-2][$yCord]->{'deadEnd'} != 1)
  {
    if($xDif < 0)
    {
      $weightInc = $xWeightHigh;
    }
    else
    {    
      $weightInc = $weightLow;
    }
    
    while($weightInc >= 0)
    {
     push @xWalls , $xCord-1;
     push @yWalls , $yCord;
     $randRange++;
     $weightInc--;
    }
  }
  if($yCord+2 < scalar(@{$maze[0]}) -1 && $maze[$xCord][$yCord+2]->{'mousevisit'} == 0 && $maze[$xCord][$yCord+1]->{'knocked'} != 1 && $maze[$xCord][$yCord+2]->{'deadEnd'} != 1)
  {
    if($yDif > 0)
    {
      $weightInc = $yWeightHigh;
    }
    else
    {    
      $weightInc = $weightLow;
    }
    
    while($weightInc >= 0)
    {
     push @xWalls , $xCord;
     push @yWalls , $yCord+1;
     $randRange++;
     $weightInc--;
    }
  }
  if( $yCord-2 > 0 && $maze[$xCord][$yCord-2]->{'mousevisit'} == 0 && $maze[$xCord][$yCord-1]->{'knocked'} != 1 && $maze[$xCord][$yCord-2]->{'deadEnd'} != 1)
  {
    if($yDif < 0)
    {
      $weightInc = $yWeightHigh;
    }
    else
    {    
      $weightInc = $weightLow;
    }
    
    while($weightInc >= 0)
    {
     push @xWalls , $xCord;
     push @yWalls , $yCord-1;
     $randRange++;
     $weightInc--;
    }
  }
   
  $randNum = int(rand($randRange));

   #choose the random wall to knock down and set the room that is behind to the current room
   for($i = 0; $i < $randRange && $randRange > 0; $i++)
   {
    if($i == $randNum)
    {
     if($xWalls[$i] > $xCord )
     {
       $newX = $xCord +2;
     }
     elsif($xWalls[$i] < $xCord )
     {
      $newX = $xCord -2;
     }
     if( $yWalls[$i] > $yCord )
     {
      $newY = $yCord +2;
     }
     elsif($yWalls[$i] < $yCord )
     {
      $newY = $yCord -2;
     }
    }    
   }
  
  #can only move in x or y dirrection set the other coordinate
  if($newY == -1 && $newX != -1)
  {
    $newY = $yCord;
  }
  if($newX == -1 && $newY != -1)
  {
   $newX = $xCord;
  }
  
  return ($newX,$newY);
}

#chooses a room with one or more adjacent rooms not occupied in the list does backtracking so if the current room 
#returns with all rooms around it visited, go to a previous room and try again
sub chooseMouseRoom
{
  my $x = -1;
  my $y = -1;
  my $range = 0;
  my $btPos = 0;
  my $currentX = 0;
  my $currentY = 0;
  my @backTrack = ();
  my $isDeadEnd = 0;
  my $prevX = -1;
  my $prevY = -1;
  
  $currentX = $_[0];
  $currentY = $_[1];
  $prevX = $_[2];
  $prevY = $_[3];
  @backTrack = @{$_[4]};
  
  $range = scalar(@maze);
  $btPos = scalar(@backTrack)-1;
 
  while($x == -1 && $y == -1 && $btPos >= 0)
  {
   
   $maze[$currentX][$currentY]->{'mouse'} = 0; 
  
   if(mouseVisited($currentX, $currentY) == 1)
   {
    $prevX = $currentX;
    $prevY = $currentY;   
    $currentX = $backTrack[$btPos]->{'x'};
    $currentY = $backTrack[$btPos]->{'y'};
    
    $isDeadEnd = deadEnd($currentX,$currentY,$isDeadEnd);  
   }
   else
   {
      $x = $currentX;
      $y = $currentY;
      $isDeadEnd = deadEnd($currentX,$currentY,$isDeadEnd); 
   }
   
   if($backTrack[$btPos]->{'deadEnd'} != 1 && $maze[$currentX][$currentY]->{'deadEnd'} != 1)
   {
    $maze[$currentX][$currentY]->{'mouse'} = 1;
    $maze[$currentX][$currentY]->{'mousevisit'} = 1;
     printGame($prevX,$prevY);
    
   }
   if($isDeadEnd)
   {
    $backTrack[$btPos]->{'deadEnd'} = 1;
    $maze[$currentX][$currentY]->{'deadEnd'} = 1;
   } 
   $btPos--;   
  }
  $isDeadEnd = deadEnd($currentX,$currentY,$isDeadEnd);

  return ($currentX,$currentY,$prevX,$prevY);
}

#check all rooms around current room and if all the other rooms have been visited return 1 for all rooms visited
sub mouseVisited
{
  my $allVisited = 0;

  my ($currentX, $currentY) = @_;
  
  if(($currentY+2 > scalar(@{$maze[0]}) -1 || $maze[$currentX][$currentY+2]->{'mousevisit'} == 1 || $maze[$currentX][$currentY+1]->{'knocked'} == 1) && ($currentY-2 <= 0 || $maze[$currentX][$currentY-2]->{'mousevisit'} == 1 || $maze[$currentX][$currentY-1]->{'knocked'} == 1)  && 
     ($currentX+2 > scalar(@maze) -1 || $maze[$currentX+2][$currentY]->{'mousevisit'} == 1 || $maze[$currentX+1][$currentY]->{'knocked'} == 1) && ($currentX-2 <= 0 || $maze[$currentX-2][$currentY]->{'mousevisit'} == 1 || $maze[$currentX-1][$currentY]->{'knocked'} == 1))
 {
   $allVisited = 1;
 }
  return $allVisited;
}

sub deadEnd
{
  my $numWalls = 0;
  my $dead = 0;
  
  my ($currentX, $currentY, $isDeadEnd) = @_;
 
 if($maze[$currentX][$currentY+1]->{'knocked'} == 1)
 {
  $numWalls++;
 }
 elsif($maze[$currentX][$currentY+2]->{'deadEnd'} == 1)
 {
  $dead++;
 }
 if($maze[$currentX][$currentY-1]->{'knocked'} == 1)
 {
  $numWalls++;
 }
 elsif($maze[$currentX][$currentY-2]->{'deadEnd'} == 1)
 {
  $dead++;
 }
 if($maze[$currentX+1][$currentY]->{'knocked'} == 1)
 {
  $numWalls++;
 }
 elsif($maze[$currentX+2][$currentY]->{'deadEnd'} == 1)
 {
  $dead++;
 }
 if($maze[$currentX-1][$currentY]->{'knocked'} == 1)
 {
  $numWalls++;
 }
 elsif($maze[$currentX-2][$currentY]->{'deadEnd'} == 1)
 {
  $dead++;
 }
 
 if($numWalls >= 3)
 {
  $isDeadEnd = 1;
 }
 elsif(((4 - $numWalls) - 1) == $dead)  
 {
  $isDeadEnd = 1;
 }
 else
 {
  $isDeadEnd = 0;
 }
 
 return $isDeadEnd;
}

sub main
{
  print "Generating Maze...\n";
  sleep(2);
  @maze = initMaze($ARGV[0],$ARGV[1]);
  makeMaze();
  #printMaze();
  printPrettyMaze();
  print "Dropping cheese and mouse into the maze randomly...\n";
  sleep(3);
  travlingMouse($ARGV[2]);
}

main();
