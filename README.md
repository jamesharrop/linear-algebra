# linear-algebra
A matrix struct data type to simplify linear algebra using the Accelerate framework.

## Example usage

Define two matrices:

    var x = Matrix(rows: 2, columns: 2, grid: [1,2,3,4])

    var y = Matrix(rows: 2, columns: 2, grid: [3,5,6,7])

Transpose of a matrix:

    x.transpose()

Multiply two matrices:

    x.multiply(y)

Subtract two matrices:

    x-y

Add or subtract a scalar (double)

    1-x

Multiply by a scalar:

    2*y

Element-wise multiplication:

    m1.elementMultiply(y)
