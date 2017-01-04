//: Linear algebra

// Matrix struct is adapted and extended from Apple documentation
// https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Subscripts.html

import Foundation
import Accelerate

struct Matrix {
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
}

extension Matrix {

    // Transposing a matrix
    func transpose() -> Matrix {
        var result = Matrix(rows: self.columns, columns: self.rows)
        vDSP_mtransD(self.grid, 1, &result.grid, 1, UInt(result.rows), UInt(result.columns))
        return result
    }
    
    // Multiplying two matrices
    func multiply(_ matrix2: Matrix) -> Matrix {
        assert(self.columns == matrix2.rows)
        var result = Matrix(rows: self.rows, columns: matrix2.columns)
        vDSP_mmulD(self.grid, 1, matrix2.grid, 1, &result.grid, 1, UInt(self.rows), UInt(matrix2.columns), UInt(self.columns))
        return result
    }
    
}

// Example usage

var m1 = Matrix(rows: 2, columns: 2, grid: [1,2,3,4])
var m2 = Matrix(rows: 2, columns: 2, grid: [3,5,6,7])

print(m1.transpose().grid)

print(m1.multiply(m2).grid)


