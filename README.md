# linear-algebra
A matrix struct data type to simplify linear algebra using the Accelerate framework and higher order functions. Operator overloading is used to make the matrix calculations more readable.

## Example usage

Define matrices:

    var x = Matrix(rows: 2, columns: 2)

    var y = Matrix(rows: 2, columns: 2, grid: [3,5,6,7])

Transpose of a matrix:

    x.transpose()

Multiply two matrices:

    x*y

Element-wise multiplication:

    x.elementMultiply(y)

Subtract two matrices:

    x-y

Add or subtract a scalar (double)

    1-x

Multiply by a scalar (double):

    2*x

Sum a matrix:

    sum(x)

Some useful functions for logistic regression / machine learning:

    log(x)

    sigmoid(x)
