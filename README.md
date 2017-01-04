# linear-algebra
A matrix struct data type to simplify linear algebra using the Accelerate framework.

## Example usage

Define two matrices:
```
var m1 = Matrix(rows: 2, columns: 2, grid: [1,2,3,4])

var m2 = Matrix(rows: 2, columns: 2, grid: [3,5,6,7])
```
Transpose of a matrix:
```
m1.transpose()
```
[1.0, 3.0, 2.0, 4.0]


Multiply two matrices:
```
m1.multiply(m2)
```
[15.0, 19.0, 33.0, 43.0]
