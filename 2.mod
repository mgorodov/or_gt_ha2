reset;

param A{1..5}; # aladdin demand
param P{1..5}; # persian demand

param ARC{1..3}; # aladdin -> persian cost
param PRC{1..3}; # persian -> aladdin cost
param ART{1..3}; # aladdin -> persian time
param PRT{1..3}; # persian -> aladdin time

param APC{1..3}; # aladdin unit production cost
param PPC{1..3}; # persian unit production cost
param APT{1..3}; # aladdin unit production time
param PPT{1..3}; # persian unit production time


var s{1..3, 0..5} binary; # indicator whether s[i, j] i-th machine produces aladdin at j-th month
var q{1..3, 1..5} integer >= 0; # q[i, j] quantity which i-th machine produced at j-th month

var a{0..5} integer >= 0;
var p{0..5} integer >= 0;

minimize z:
	sum{j in 0..4}
		(a[j] + p[j])*5
	+
	sum{j in 1..5, i in 1..3}
		q[i, j] * (s[i, j] * APC[i] + (1 - s[i, j]) * PPC[i])
	+
	sum{j in 1..5, i in 1..3}
		(if s[i, j] = s[i, j - 1] then 0 else 1) * (s[i, j] * PRC[i] + (1 - s[i, j]) * ARC[i])
;

subject to

working_hours_limit{i in 1..3, j in 1..5}:
									 q[i, j] * (s[i,j] * APT[i] + (1 - s[i,j]) * PPT[i]) +
	(if s[i, j] = s[i, j - 1] then 0 else 1) * (s[i,j] * PRT[i] + (1 - s[i,j]) * ART[i]) <= 160
;

initial_aladdin:
	a[0] = 20
;
demand_on_alladin{j in 1..5}:
	a[j] = a[0] + sum{k in 1..j, i in 1..3}(s[i, k] * q[i, k]) - sum{k in 1..j}A[k] 
;

initial_persian:
	p[0] = 15
;
demand_on_persian{j in 1..5}:
	p[j] = p[0] + sum{k in 1..j, i in 1..3}((1 - s[i, k]) * q[i, k]) - sum{k in 1..j}P[k]
;

initial_aladdin_state{i in 1..3}:
	s[i, 0] = 1
;

data;

param A :=
	1 30
	2 20
	3 20
	4 20
	5 30
;
param P :=
	1 10
	2 30
	3 35
	4 15
	5 10
;

param ARC := 
	1 100
	2 90
	3 110
;
param PRC := 
	1 150
	2 180
	3 120
;
param ART := 
	1 20
	2 15
	3 18
;
param PRT := 
	1 15
	2 10
	3 12
;

param APC := 
	1 90
	2 80
	3 120
;
param PPC := 
	1 120
	2 110
	3 130
;
param APT := 
	1 10
	2 12
	3 8
;
param PPT := 
	1 12
	2 14
	3 16
;

option solver gurobi; 
solve;
display z, s, q;
display a, p;

