#include <incmode>.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program base.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% BI-DIRECTIONAL WALL
wall(X1,Y1,X2,Y2) :- wall(X2,Y2,X1,Y1).

%% +\- 1 true function
diff(1). diff(-1).	
%% delta(A,B):- ((B-A)/|B-A|)>0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ALL  MOVES
%% checks up/down
pathx(X1,Y1,X2,Y2) :- field(X1,Y1), field(X2,Y2), DX=((X2-X1)/|(X2-X1)|), diff(DX), not wall(X1,Y1,X1+DX,Y1).								
%% checks left/right
pathy(X1,Y1,X2,Y2) :- field(X1,Y1), field(X2,Y2), DY=((Y2-Y1)/|(Y2-Y1)|), diff(DY), not wall(X1,Y1,X1,Y1+DY), not pathx(X1,Y1,X2,Y2).		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MINOTAUR MOVES IN TWO STEPS
%% if along x succes, then move mino
long_path(X1,Y1,X2,Y2,X1+((X2-X1)/|(X2-X1)|),Y1) :- pathx(X1,Y1,X2,Y2), DX=((X2-X1)/|(X2-X1)|), diff(DX).
%% if along y succes, then move mino
long_path(X1,Y1,X2,Y2,X1,Y1+((Y2-Y1)/|(Y2-Y1)|)) :- pathy(X1,Y1,X2,Y2), DY=((Y2-Y1)/|(Y2-Y1)|), diff(DY).
%% if both untrue, don't move
long_path(X1,Y1,X2,Y2,X1,Y1) :- field(X1,Y1), field(X2,Y2), not pathx(X1,Y1,X2,Y2), not pathy(X1,Y1,X2,Y2).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% THE PREDICATE PRIOR TO PRINT, AND MY MOVE
%% set possible moves for player
onestep_or_none(0,0). 
onestep_or_none(1,0).
onestep_or_none(-1,0). 
onestep_or_none(0,-1).
onestep_or_none(0,1).

%% some functions to ease calculation

minogo(A,B):- field(A,B).
mego(A,B):- field(A,B).
max_check(s):- s<=M, maxsteps(M).
super_long(X1,Y1,X2,Y2,X3,Y3,X4,Y4):- long_path(X1,Y1,X2,Y2,X3,Y3), long_path(X3,Y3,X2,Y2,X4,Y4).

%% set starting point
mino_me(mego(I,J),0,minogo(X,Y)) :- start(I,J), mino(X,Y).		

#program step(s).

%%% various mino and me conditions	

%% between two instances of mino_me
{mino_me(mego(X2,Y2),s,minogo(X4,Y4))} :- mino_me(mego(X3,Y3),s-1,minogo(X1,Y1)), s<=M, maxsteps(M),field(X2,Y2),field(X4,Y4), onestep_or_none(X3-X2,Y3-Y2), not wall(X2,Y2,X3,Y3), super_long(X1,Y1,X2,Y2,_,_,X4,Y4).
%% mego and minogo vars need to be unequal
:- mino_me(mego(X1,Y1),_,minogo(X2,Y2)),(X1,Y1) == (X2,Y2).
%% there cannot be two exactly equal mino_me's
{mino_me(mego(X1,Y1),s,minogo(X2,Y2))} :- mino_me(mego(X3,Y3),s-1,minogo(X4,Y4)), s<=M, maxsteps(M), (X1,Y1,X2,Y2) == (X3,Y3,X4,Y4).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% THE OUTPUT FUNCTION
%% my start position
at(A,B,0):- start(A,B).
%% minotair's position is omitted
at(X1,Y1,s) :- mino_me(mego(X1,Y1),s,minogo(_,_)),field(X1,Y1).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test phase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#program check(s).
#external query(s).
%% stop when player is on the goal cell, and mino is not
:- query(s), goal(X,Y), not at(X,Y,s).
:- at(X,Y,s), mino_me(mego(X,Y),s,minogo(X,Y)).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Optimize phase
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% min(MIN):-MIN=#min{s: at(X,Y,s)}
#minimize {0,s}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#show at/3.
