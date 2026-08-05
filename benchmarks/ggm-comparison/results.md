### p = 50, n = 1000: 1225 pairs, 80 true edges

**Wall clock**

| package | settings | threads | wall clock | CPU time | max Rhat |
|---|---|---:|---:|---:|---:|
| bgms 0.2.0.0 | vignette settings (joint + gibbs) | 4 | 4.3 s | 14.2 s | 1.001 |
| bgms 0.2.0.0 | supplementary: vignette settings, sparse edge prior | 4 | 3.2 s | 9.7 s | 1.001 |
| bgms 0.2.0.0 | supplementary: vignette settings, 1 thread | 1 | 12.4 s | 12.8 s | 1.001 |
| modelSelection 1.0.7 | package defaults | 1 | 1.2 s | 1.2 s | n/a |
| modelSelection 1.0.7 | documentation-directed: empirical-Bayes edge prior | 1 | 4.1 s | 4.1 s | n/a |
| modelSelection 1.0.7 | documentation-directed | 1 | 13.4 s | 13.4 s | n/a |
| ssgraph 1.16 | package defaults | 1 | 13.6 s | 13.5 s | n/a |
| ssgraph 1.16 | documentation-directed | 1 | 13.6 s | 13.5 s | n/a |
| ssgraph 1.16 | supplementary: sparse edge prior | 1 | 14.2 s | 14.2 s | n/a |

**Edge recovery**

| package | settings | own rule | sel | TP | FP | FN | prec | rec | matched rule > 0.5 | sel | TP | FP | FN | prec | rec | AUC | TP in top 80 |
|---|---|---|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| bgms | vignette settings (joint + gibbs) | > 0.50 | 84 | 78 | 6 | 2 | 0.929 | 0.975 | > 0.50 | 84 | 78 | 6 | 2 | 0.929 | 0.975 | 0.9986 | 75 |
| bgms | supplementary: vignette settings, sparse edge prior | > 0.50 | 59 | 59 | 0 | 21 | 1.000 | 0.738 | > 0.50 | 59 | 59 | 0 | 21 | 1.000 | 0.738 | 0.9984 | 75 |
| bgms | supplementary: vignette settings, 1 thread | > 0.50 | 84 | 78 | 6 | 2 | 0.929 | 0.975 | > 0.50 | 84 | 78 | 6 | 2 | 0.929 | 0.975 | 0.9986 | 75 |
| modelSelection | package defaults | > 0.95 | 25 | 25 | 0 | 55 | 1.000 | 0.312 | > 0.50 | 52 | 52 | 0 | 28 | 1.000 | 0.650 | 0.9981 | 75 |
| modelSelection | documentation-directed: empirical-Bayes edge prior | > 0.95 | 33 | 33 | 0 | 47 | 1.000 | 0.412 | > 0.50 | 63 | 62 | 1 | 18 | 0.984 | 0.775 | 0.9982 | 75 |
| modelSelection | documentation-directed | > 0.95 | 25 | 25 | 0 | 55 | 1.000 | 0.312 | > 0.50 | 52 | 52 | 0 | 28 | 1.000 | 0.650 | 0.9931 | 73 |
| ssgraph | package defaults | > 0.50 | 73 | 70 | 3 | 10 | 0.959 | 0.875 | > 0.50 | 73 | 70 | 3 | 10 | 0.959 | 0.875 | 0.9989 | 76 |
| ssgraph | documentation-directed | > 0.50 | 88 | 78 | 10 | 2 | 0.886 | 0.975 | > 0.50 | 88 | 78 | 10 | 2 | 0.886 | 0.975 | 0.9988 | 76 |
| ssgraph | supplementary: sparse edge prior | > 0.50 | 60 | 60 | 0 | 20 | 1.000 | 0.750 | > 0.50 | 60 | 60 | 0 | 20 | 1.000 | 0.750 | 0.9983 | 74 |

### p = 100, n = 1000: 4950 pairs, 146 true edges

**Wall clock**

| package | settings | threads | wall clock | CPU time | max Rhat |
|---|---|---:|---:|---:|---:|
| bgms 0.2.0.0 | vignette settings (joint + gibbs) | 4 | 34.6 s | 128 s | 1.001 |
| bgms 0.2.0.0 | supplementary: vignette settings, sparse edge prior | 4 | 16.6 s | 56.0 s | 1.002 |
| bgms 0.2.0.0 | supplementary: vignette settings, 1 thread | 1 | 112 s | 113 s | 1.001 |
| modelSelection 1.0.7 | package defaults | 1 | 1.8 s | 1.8 s | n/a |
| modelSelection 1.0.7 | documentation-directed: empirical-Bayes edge prior | 1 | 8.5 s | 8.4 s | n/a |
| modelSelection 1.0.7 | documentation-directed | 1 | 76.9 s | 76.6 s | n/a |
| ssgraph 1.16 | package defaults | 1 | 194 s | 193 s | n/a |
| ssgraph 1.16 | documentation-directed | 1 | 186 s | 186 s | n/a |
| ssgraph 1.16 | supplementary: sparse edge prior | 1 | 189 s | 188 s | n/a |

**Edge recovery**

| package | settings | own rule | sel | TP | FP | FN | prec | rec | matched rule > 0.5 | sel | TP | FP | FN | prec | rec | AUC | TP in top 146 |
|---|---|---|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| bgms | vignette settings (joint + gibbs) | > 0.50 | 161 | 135 | 26 | 11 | 0.839 | 0.925 | > 0.50 | 161 | 135 | 26 | 11 | 0.839 | 0.925 | 0.9964 | 129 |
| bgms | supplementary: vignette settings, sparse edge prior | > 0.50 | 91 | 91 | 0 | 55 | 1.000 | 0.623 | > 0.50 | 91 | 91 | 0 | 55 | 1.000 | 0.623 | 0.9962 | 129 |
| bgms | supplementary: vignette settings, 1 thread | > 0.50 | 161 | 135 | 26 | 11 | 0.839 | 0.925 | > 0.50 | 161 | 135 | 26 | 11 | 0.839 | 0.925 | 0.9964 | 129 |
| modelSelection | package defaults | > 0.95 | 52 | 52 | 0 | 94 | 1.000 | 0.356 | > 0.50 | 84 | 84 | 0 | 62 | 1.000 | 0.575 | 0.9942 | 129 |
| modelSelection | documentation-directed: empirical-Bayes edge prior | > 0.95 | 60 | 60 | 0 | 86 | 1.000 | 0.411 | > 0.50 | 91 | 91 | 0 | 55 | 1.000 | 0.623 | 0.9941 | 128 |
| modelSelection | documentation-directed | > 0.95 | 53 | 53 | 0 | 93 | 1.000 | 0.363 | > 0.50 | 83 | 83 | 0 | 63 | 1.000 | 0.568 | 0.9886 | 128 |
| ssgraph | package defaults | > 0.50 | 123 | 120 | 3 | 26 | 0.976 | 0.822 | > 0.50 | 123 | 120 | 3 | 26 | 0.976 | 0.822 | 0.9968 | 131 |
| ssgraph | documentation-directed | > 0.50 | 171 | 136 | 35 | 10 | 0.795 | 0.932 | > 0.50 | 171 | 136 | 35 | 10 | 0.795 | 0.932 | 0.9968 | 130 |
| ssgraph | supplementary: sparse edge prior | > 0.50 | 88 | 88 | 0 | 58 | 1.000 | 0.603 | > 0.50 | 88 | 88 | 0 | 58 | 1.000 | 0.603 | 0.9926 | 128 |

### p = 200, n = 1000: 19900 pairs, 289 true edges

**Wall clock**

| package | settings | threads | wall clock | CPU time | max Rhat |
|---|---|---:|---:|---:|---:|
| bgms 0.2.0.0 | vignette settings (joint + gibbs) | 4 | 394 s | 1532 s | 1.002 |
| bgms 0.2.0.0 | supplementary: vignette settings, sparse edge prior | 4 | 122 s | 442 s | 1.002 |
| bgms 0.2.0.0 | supplementary: vignette settings, 1 thread | 1 | 1410 s | 1413 s | 1.002 |
| modelSelection 1.0.7 | package defaults | 1 | 4.2 s | 4.2 s | n/a |
| modelSelection 1.0.7 | documentation-directed: empirical-Bayes edge prior | 1 | 24.8 s | 24.8 s | n/a |
| modelSelection 1.0.7 | documentation-directed | 1 | 393 s | 392 s | n/a |
| ssgraph 1.16 | package defaults | 1 | 3174 s | 3169 s | n/a |
| ssgraph 1.16 | documentation-directed | 1 | 3180 s | 3176 s | n/a |
| ssgraph 1.16 | supplementary: sparse edge prior | 1 | 3276 s | 3264 s | n/a |

**Edge recovery**

| package | settings | own rule | sel | TP | FP | FN | prec | rec | matched rule > 0.5 | sel | TP | FP | FN | prec | rec | AUC | TP in top 289 |
|---|---|---|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|---:|---:|---:|---:|
| bgms | vignette settings (joint + gibbs) | > 0.50 | 382 | 258 | 124 | 31 | 0.675 | 0.893 | > 0.50 | 382 | 258 | 124 | 31 | 0.675 | 0.893 | 0.9957 | 247 |
| bgms | supplementary: vignette settings, sparse edge prior | > 0.50 | 169 | 168 | 1 | 121 | 0.994 | 0.581 | > 0.50 | 169 | 168 | 1 | 121 | 0.994 | 0.581 | 0.9957 | 245 |
| bgms | supplementary: vignette settings, 1 thread | > 0.50 | 382 | 258 | 124 | 31 | 0.675 | 0.893 | > 0.50 | 382 | 258 | 124 | 31 | 0.675 | 0.893 | 0.9957 | 247 |
| modelSelection | package defaults | > 0.95 | 92 | 92 | 0 | 197 | 1.000 | 0.318 | > 0.50 | 152 | 152 | 0 | 137 | 1.000 | 0.526 | 0.9937 | 241 |
| modelSelection | documentation-directed: empirical-Bayes edge prior | > 0.95 | 108 | 108 | 0 | 181 | 1.000 | 0.374 | > 0.50 | 170 | 169 | 1 | 120 | 0.994 | 0.585 | 0.9938 | 242 |
| modelSelection | documentation-directed | > 0.95 | 95 | 95 | 0 | 194 | 1.000 | 0.329 | > 0.50 | 151 | 151 | 0 | 138 | 1.000 | 0.522 | 0.9751 | 237 |
| ssgraph | package defaults | > 0.50 | 260 | 238 | 22 | 51 | 0.915 | 0.824 | > 0.50 | 260 | 238 | 22 | 51 | 0.915 | 0.824 | 0.9957 | 249 |
| ssgraph | documentation-directed | > 0.50 | 435 | 264 | 171 | 25 | 0.607 | 0.913 | > 0.50 | 435 | 264 | 171 | 25 | 0.607 | 0.913 | 0.9958 | 249 |
| ssgraph | supplementary: sparse edge prior | > 0.50 | 161 | 159 | 2 | 130 | 0.988 | 0.550 | > 0.50 | 161 | 159 | 2 | 130 | 0.988 | 0.550 | 0.9903 | 242 |

