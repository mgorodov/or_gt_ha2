reset;

set D{1..5};
param R{1..5};
param U{1..5};
param T{1..5};
param P{1..4};

var m{1..5} binary;
var x{1..5, 1..4} integer >= 0;

minimize z:
	sum{i in 1..5}
		m[i] * (R[i] + U[i] * sum{j in 1..4}x[i, j]);

subject to

Monthly_plan{j in 1..4}:
	sum{i in 1..5} m[i]*x[i, j] >= P[j]
;

Total_production_capacity{i in 1..5}:
	sum{j in 1..4} m[i]*x[i, j] <= T[i]
;

Production_possibility{i in 1..5, j in 1..4 diff D[i]}:
	x[i, j] = 0
;

data;

set D[1] := 1 2 3;
set D[2] := 1 3 4;
set D[3] := 2 4;
set D[4] := 3 4;
set D[5] := 1 4;

param R :=
	1	2000
	2	2500
	3	1500
	4	1400
	5	1700
;

param U :=
	1	17
	2	15
	3	20
	4	18
	5	14
;

param T :=
	1	250
	2	200
	3	100
	4	300
	5	150
;

param P :=
	1	200
	2	100
	3	50
	4	100
;

option solver gurobi; 
solve;
display z, x, m;


