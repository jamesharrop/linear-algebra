//: Linear algebra

import Foundation
import Accelerate

struct Matrix {
    
    // Matrix struct is adapted and extended from Apple documentation
    // https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Subscripts.html
    
    let rows: Int, columns: Int
    var grid: [Double]
    
    // A matrix of zeros
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
    
    // Identity matrix
    init(identityMatrixSize size: Int) {
        self.rows = size
        self.columns = size
        grid = Array(repeating: 0.0, count: rows * columns)
        checkDimensionsAreValid()
        for n in 0..<size {
            self[n, n] = 1
        }
    }
    
    func checkDimensionsAreValid() {
        let matrixIsValid = self.rows>0 && self.columns>0 && (self.grid.count == self.rows * self.columns)
        assert(matrixIsValid, "Error initialising matrix: Invalid dimensions of matrix")
    }
    
}

extension Matrix {

    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    // Accessing elements of the matrix using subscript notation
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
    
    // Inverse of a matrix
    public func inverse() -> Matrix {
        assert(self.rows == self.columns, "Error calculating inverse: matrix is not square")
        var selfGrid = self.grid
        var N = __CLPK_integer(sqrt(Double(selfGrid.count)))
        var pivot = [__CLPK_integer](repeating: 0, count: Int(N))
        var err : __CLPK_integer = 0
        var workspace = [Double](repeating: 0.0, count: Int(N))
        dgetrf_(&N, &N, &selfGrid, &N, &pivot, &err)
        dgetri_(&N, &selfGrid, &N, &pivot, &workspace, &N, &err)
        return Matrix(rows: self.rows, columns: self.columns, grid: selfGrid)
    }

}

// Printing a matrix
extension Matrix : CustomStringConvertible {
    
    public var description: String {
        var returnString = ""
        for row in 0..<self.rows {
            let thisRow = Array(self.grid[row*(self.columns)..<((row+1)*self.columns)])
            returnString += rowAsAString(thisRow) + "\n"
        }
        return returnString
    }
    
    func rowAsAString(_ a: [Double]) -> String {
        let num = a.count
        
        let maxSpace = 6 // If there are more columns than this, then some will be omitted from the printed output
        let firstElements = 3
        let lastElements = 3
        
        var returnString = ""
        
        if num<=maxSpace {
            // Print whole matrix
            for n in 0..<num {
                returnString += numberAsString(number: a[n]) + " "
            }
        } else {
            // Print partial matrix
            for n in 0..<firstElements {
                returnString += numberAsString(number: a[n]) + " "
            }
            returnString += "... "
            for n in (num-lastElements)..<num {
                returnString += numberAsString(number: a[n]) + " "
            }
        }
        // Remove the last character
        return returnString.substring(to: returnString.index(before: returnString.endIndex))
    }
    
    func numberAsString(number: Double) -> String {
        var returnString: String
        if abs(number)<10000 {
            returnString = String(format: "%10g", number)+"   "
        } else {
            // Format larger numbers as scientific format of fixed length
            returnString = String(format: "%10e", number)
            if number>=0 {
                returnString = " " + returnString
            }
        }
        return returnString
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

// Are two matrices equal
func ==(left: Matrix, right: Matrix) -> Bool {
    return (left.grid == right.grid) && (left.rows == right.rows) && (left.columns == right.columns)
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

// Sum the rows in each column of a matrix
func sumRows(_ input: Matrix) -> Matrix {
    var output = Matrix(rows: 1, columns: input.columns)
    var sum = 0.0
    for column in 0..<input.columns {
        sum = 0
        for row in 0..<input.rows {
            sum += input[row,column]
        }
        output[0,column] = sum
    }
    return output
}

// Sum all elements of a matrix
func sumAllElements(_ input: Matrix) -> Double {
    return input.grid.reduce(0.0, +)
}

// Reading data into a matrix from a CSV file in the resources section of the playground
func readDataFromFile(fileName: String, fileNameExtension: String) -> Matrix? {
    // Read in data from file
    var grid: [Double] = []
    var rows = 0
    var columns = 0
    
    // Open the file
    guard let fileURL = Bundle.main.url(forResource:fileName, withExtension: fileNameExtension) else {
        print("File not found")
        return nil
    }
    
    // Read the file contents to a String
    guard let text = try? String(contentsOf: fileURL, encoding: String.Encoding.utf8)
        else {
            print("Error reading the file contents")
            return nil
    }
    
    // Split the lines into a String array, removing any empty lines
    let lines = text.components(separatedBy: String("\n")).filter( { $0 != "" } )
    
    // Split each line into components
    for line in lines {
        rows += 1
        let lineComponents = line.components(separatedBy: ",")
        if rows == 1 { // first row
            columns = lineComponents.count
        }
        if columns != lineComponents.count {
            print("Error at file line:", rows)
            print("Number of values in each line of file varies")
            return nil
        }
        for component in lineComponents.enumerated() {
            if let componentAsDouble = Double(component.1) {
                grid.append(componentAsDouble)
            } else {
                print("Error at file line:", rows)
                print("Can not convert file values to type Double")
                return nil
            }
        }
    }
    return Matrix(rows: rows, columns: columns, grid: grid)
}


// Example usage
// -------------

var x = Matrix(rows: 2, columns: 2, grid: [1,2,3,4])

var y = Matrix(rows: 2, columns: 2, grid: [3,5,6,7])

var z = Matrix(identityMatrixSize: 3)

print(z)

print(x.transpose())

print(x*y)

print(x-y)

print(1-x)

print(2*y)

print(x.elementMultiply(y))

print(y)
