# linear-algebra
A matrix struct data type to simplify linear algebra using the Accelerate framework and higher order functions. Operator overloading is used to make the matrix calculations more readable.

## Example usage

Define matrices:

    var x = Matrix(rows: 2, columns: 2)

    var y = Matrix(rows: 2, columns: 2, grid: [3,5,6,7])

    var z = Matrix(identityMatrixSize: 3)

Print a matrix:

    print(z)

    1             0             0   
    0             1             0   
    0             0             1   


Transpose of a matrix:

    x.transpose()

Inverse of a matrix

    x.inverse()

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

Some useful functions for logistic regression, machine learning:

    log(x)

    sigmoid(x)

Read data from a CSV file into a matrix:

    guard let dataMatrix = readDataFromFile(fileName: "data", fileNameExtension: "txt") else { print("Error reading file") }
