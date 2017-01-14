//
//  matrix-tests.swift
//  
//
//  Created by James Harrop on 14/01/2017.
//
//

import Foundation
import Accelerate

// Creating random numbers and matrices for testing

func randomPositiveInt(max: Int) -> Int {
    var rand = Int(arc4random_uniform(UInt32(max)))+1
    return rand
}

func randomDouble(max: Int) -> Double {
    let multiplyConstant = 20
    var rand = Int(arc4random_uniform(UInt32(max*multiplyConstant)))+1
    rand -= (max*multiplyConstant)/2
    return 2*Double(rand)/Double(multiplyConstant)
}

func randomMatrix(rows: Int, columns: Int, maxElement: Int) -> Matrix {
    var returnMatrix = Matrix(rows: rows, columns: columns)
    for element in 0..<returnMatrix.grid.count {
        returnMatrix.grid[element] = randomDouble(max: maxElement)
    }
    return returnMatrix
}

func randomSquareMatrix(maxRow: Int, maxElement: Int) -> Matrix {
    let size = randomPositiveInt(max: maxRow)
    return randomMatrix(rows: size, columns: size, maxElement: maxElement)
}


// Matrix test functions

func testInverseAndMultiplication() -> Bool {
    // Create a square matrix
    let m1 = randomSquareMatrix(maxRow: 10, maxElement: 100)
    
    // Invert the matrix and multiply it by itself - the answer should be the identiy matrix
    let m2 = (m1.inverse()*m1)
    
    // Return true if successful (to within a small tolerance)
    let sum = sumAllElements(m2)-Double(m2.rows)
    return(sum<0.000001)
}

testInverseAndMultiplication()
