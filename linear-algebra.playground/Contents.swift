//: Linear algebra

import Foundation
import Accelerate

struct Matrix {
    
    // Matrix struct is adapted and extended from Apple documentation
    // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Subscripts.html
    
    let rows: Int, columns: Int
    var grid: [Double]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: 0.0, count: rows * columns)
        checkDimensionsAreValid()
    }
    
    init(rows: Int, columns: Int, grid: [Double]) {
        self.rows = rows
        self.columns = columns
        self.grid = grid
        checkDimensionsAreValid()
    }
    
    func checkDimensionsAreValid() {
        let matrixIsValid = self.rows>0 && self.columns>0 && (self.grid.count == self.rows * self.columns)
        assert(matrixIsValid, "Error initialising matrix: Invalid dimensions of matrix")
    }
    
}

extension Matrix {
    // Accessing elements of the matrix using subscript notation
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Double {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }

    // Transposing a matrix
    func transpose() -> Matrix {
        var result = Matrix(rows: self.columns, columns: self.rows)
        vDSP_mtransD(self.grid, 1, &result.grid, 1, UInt(result.rows), UInt(result.columns))
        return result
    }
    
    // Multiplying two matrices: element-wise multiplication
    func elementMultiply(_ matrix2: Matrix) -> Matrix {
        assert(self.rows == matrix2.rows && self.columns == matrix2.columns)
        return Matrix(rows: self.rows, columns: self.columns, grid: zip(self.grid, matrix2.grid).map(*))
    }

}

// Operator overloading
// --------------------

// Note: Accelerate could be used here instead here of map/zip

// Adding 2 matrices
func +(left: Matrix, right: Matrix) -> Matrix {
    assert(left.rows == right.rows && left.columns == right.columns)
    return Matrix(rows: left.rows, columns: left.columns, grid: zip(left.grid, right.grid).map(+))
}

// Adding a scalar to a matrix -> the scalar is added to each element
func +(left: Double, right: Matrix) -> Matrix {
    return Matrix(rows: right.rows, columns: right.columns, grid: right.grid.map({$0+left}))
}

func +(left: Matrix, right: Double) -> Matrix {
    return Matrix(rows: left.rows, columns: left.columns, grid: left.grid.map({$0+right}))
}

// Subtracting a scalar from a matrix -> the scalar is subtracted from each element
func -(left: Double, right: Matrix) -> Matrix {
    return Matrix(rows: right.rows, columns: right.columns, grid: right.grid.map({left-$0}))
}

func -(left: Matrix, right: Double) -> Matrix {
    return Matrix(rows: left.rows, columns: left.columns, grid: left.grid.map({$0-right}))
}

// Subtraction with 2 matrices
func -(left: Matrix, right: Matrix) -> Matrix {
    assert(left.rows == right.rows && left.columns == right.columns)
    return Matrix(rows: left.rows, columns: left.columns, grid: zip(left.grid, right.grid).map(-))
}

// Multiplying a matrix by minus 1
prefix func -(right: Matrix) -> Matrix {
    return -1.0*right
}

// Multiplying two matrices: matrix multiplication
func *(left: Matrix, right: Matrix) -> Matrix {
    assert(left.columns == right.rows)
    var result = Matrix(rows: left.rows, columns: right.columns)
    vDSP_mmulD(left.grid, 1, right.grid, 1, &result.grid, 1, UInt(left.rows), UInt(right.columns), UInt(left.columns))
    // Note: this could also be achieved using cblas_dgemm
    return result
}

// Multiplying a matrix by a scalar
func *(left: Matrix, right: Double) -> Matrix {
    return Matrix(rows: left.rows, columns: left.columns, grid: left.grid.map({$0*right}))
}

func *(left: Double, right: Matrix) -> Matrix {
    return Matrix(rows: right.rows, columns: right.columns, grid: right.grid.map({$0*left}))
}

// Useful functions for machine learning
// -------------------------------------

// Sigmoid function for double
func sigmoid(_ input: Double) -> Double {
    return 1/(1+exp(-input))
}

// Sigmoid function for matrix
func sigmoid(_ input: Matrix) -> Matrix {
    return Matrix(rows: input.rows, columns: input.columns, grid: input.grid.map({sigmoid($0)}))
}

// Logarithm of a matrix
func log(_ input: Matrix) -> Matrix {
    return Matrix(rows: input.rows, columns: input.columns, grid: input.grid.map({log($0)}))
}

// Sum of a matrix
func sum(_ input: Matrix) -> Double {
    return input.grid.reduce(0.0,+)
}



// Example usage
// -------------

var x = Matrix(rows: 2, columns: 2, grid: [1,2,3,4])

var y = Matrix(rows: 2, columns: 2, grid: [3,5,6,7])

print(x.transpose())

print(x*y)

print(x-y)

print(1-x)

print(2*y)

print(x.elementMultiply(y))

