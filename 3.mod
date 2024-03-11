reset;

param I{0..3}; # upper bound for intervals
param M{0..3}; # maintenance cost
param PCD{0..3}; # max capacity decrease
param P{1..6}; # profit / ton

var a{1..3, 0..6} >= 0;
var m{1..3, 1..6, 0..3} binary;
var x{1..3, 1..6} >= 0;
var rep{1..3, 1..6} >= 0;

maximize z:
	sum{j in 1..6, i in 1..3} P[j] * x[i, j]
	-
	sum{j in 1..6, i in 1..3, s in 1..3} m[i, j, s] * M[s]
;

subject to

accumulated_amount_initial_1:
	a[1, 0] = 600
;
accumulated_amount_initial_2:
	a[2, 0] = 400
;
accumulated_amount_initial_3:
	a[3, 0] = 1000
;

accumulated_amount{i in 1..3, j in 1..6}:
	a[i, j] = a[i, j-1] + x[i, j] - rep[i, j]
;

next_stage_lower_condition{j in 1..6}:
	sum{i in 1..3} x[i, j] >= 2000
;

next_stage_upper_condition{j in 1..6}:
	sum{i in 1..3} x[i, j] <= 3000
;

production_restriction{i in 1..3, j in 1..6}:
	x[i, j] <= 1000 * sum{s in 0..3} m[i, j, s] * (1 - PCD[s])
;

one_wear_level_for_machine{i in 1..3, j in 1..6}:
	sum{s in 0..3} m[i, j, s] = 1
;

at_most_one_machine_maintenance_per_month{j in 1..6}:
	sum{i in 1..3, s in 1..3} m[i, j, s] <= 1
;

wear_level_lower_condition{i in 1..3, j in 1..6, s in 1..3}:
	m[i, j, s] * I[s - 1] <= a[i, j - 1]
;

wear_level_upper_condition{i in 1..3, j in 1..6, s in 1..3}:
	a[i, j - 1] <= a[i, j - 1] * (1 - m[i, j, s]) + m[i, j, s] * I[s]
;

repaired_by_maintenance{i in 1..3, j in 1..6}:
	rep[i, j] = a[i, j-1] * sum{s in 1..3} m[i, j, s]
;
max_unmaintanable_bound{i in 1..3, j in 1..6}:
	a[i, j] <= 4000
;
data;

param I :=
	0 0
	1 1500
	2 2500
	3 4000
;

param M :=
	0 0
	1 1000
	2 2000
	3 4000
;

param PCD :=
	0 0
	1 0.2
	2 0.3
	3 0.5
;

param P :=
	1 100
	2 120
	3 110
	4 140
	5 90
	6 100
;

option solver mosek; 
solve;
display z, m, a, x, rep;

