//
//  Array2D.swift
//  TestaBrick
//
//  Created by Pablo on 29/08/15.
//  Copyright (c) 2015 Pablo. All rights reserved.
//
/*
    We're defining a class named Array2D. Generic arrays in Swift are actually of type struct, not class but we need a class in this case since class objects are passed by reference whereas structures are passed by value (copied). Our game logic will require a single copy of this data structure to persist across the entire game.
*/
class Array2D<T> {
    
    let columns: Int
    let rows: Int
    
    /*
        We declare an actual Swift array; it will be the underlying data structure which maintains references to our objects. It's declared with type <T?>. A ? in Swift symbolizes an optional value. An optional value is just that, optional. Optional variables may or may not contain data, and they may in fact be nil, or empty. nil locations found on our game board will represent empty spots where no block is present.*/
    
    var array: Array<T?>
    
    /*
        We instantiate our internal array structure with a size of rows * columns. This guarantees that Array2D can store as many objects as our game board requires, 200 in our case.
    */
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(count:rows * columns, repeatedValue: nil)
    }
    
    /*
        We create a custom subscript for Array2D. We mentioned earlier that we wanted to have a subscript capable of supporting array[column, row] - this accomplishes just that. The getter is fairly self explanatory. To get the value at a given location we need to multiply the provided row by the class variable columns, then add the column number to reach the final destination.
    */
    subscript(colum: Int, row: Int) -> T? {
        get {
            return array[(row * columns) + colum]
        }
        set(newValue) {
            array[(row * columns) + colum] = newValue
        }
    }
    
}