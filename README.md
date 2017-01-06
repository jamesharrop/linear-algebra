# linear-algebra
A matrix struct data type to simplify linear algebra using the Accelerate framework and higher order function. Operator overloading is used to make the matrix calculations more readable.

## Example usage

Define matrices:

    var x = Matrix(rows: 2, columns: 2)

    var y = Matrix(rows: 2, columns: 2, grid: [3,5,6,7])

Transpose of a matrix:

    x.transpose()

Multiply two matrices:

    x*y

Element-wise multiplication:

    m1.elementMultiply(y)

Subtract two matrices:

    x-y

Add or subtract a scalar (double)

    1-x

Multiply by a scalar:

    2*y
