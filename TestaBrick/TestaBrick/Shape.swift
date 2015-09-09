//
//  Shape.swift
//  TestaBrick
//
//  Created by Pablo on 30/08/15.
//  Copyright (c) 2015 Pablo. All rights reserved.
//

import SpriteKit

let NumOrientations: UInt32 = 4

enum Orientation: Int, Printable {
    
    case Zero = 0, Ninety, OneEighty, TwoSeventy
    
    var description: String {
        switch self {
        case .Zero:
            return "0"
        case .Ninety:
            return "90"
        case .OneEighty:
            return "180"
        case .TwoSeventy:
            return "270"
        }
    }
    
   
    static func random() -> Orientation {
        return Orientation(rawValue: Int(arc4random_uniform(NumOrientations)))!
    }
 
    /*
        At 0˚ the piece is at origin and as it rotates clockwise its degree advances along the circumference. That's how we're going to define a shape's orientation. At #1, we provided a method capable of returning the next orientation when traveling either clockwise or counterclockwise.
    */
    static func rotate(orientation: Orientation, clockwise: Bool) -> Orientation {
        var rotated = orientation.rawValue + (clockwise ? 1 : -1)
        
        if rotated > Orientation.TwoSeventy.rawValue {
            rotated = Orientation.Zero.rawValue
        } else if rotated < 0 {
            rotated = Orientation.TwoSeventy.rawValue
        }
        
        return Orientation(rawValue:rotated)!
    }
}

// The number of total shape varieties
let NumShapeTypes: UInt32 = 7

//Shape indexes
let FirstBlockIdx: Int = 0
let SecondBlockIdx: Int = 1
let ThirdBlockIdx: Int = 2
let FourthBlockIdx: Int = 3

class Shape: Hashable, Printable {
    // The color of the shape
    let color:BlockColor
    
    // The block comprising the shape
    var blocks = Array<Block>()
    
    // The current orientation of the shape
    var orientation: Orientation
    
    // The Column and row representing the shape's anchor
    var column, row:Int
    
    //Required Overrides
    /*
        blockRowColumnPositions defines a computed Dictionary. A dictionary is defined with square braces – […] – and maps one type of object to another. The first object type listed defines the key and the second, a value. Keys map one-to-one with values and multiple copies of a single key may not exist.
    

    */
    //Subclasses must override this property
    var blockRowColumnPositions: [Orientation: Array<(columnDiff: Int, rowDiff: Int)>] {
        return [:]
    }
    
    /*

    */
    // Subclasses must override this property
    var bottomBlocksForOrientations: [Orientation: Array<Block>] {
        return [:]
    }
    
    /*
        Return the bottom blocks of the shape at its current orientation. This will be useful later when our blocks get physical and start contacting walls and each other.    */
    var bottomBlocks:Array<Block> {
        if let bottomBlocks = bottomBlocksForOrientations[orientation] {
            return bottomBlocks
        }
        return []
    }
    
    ///Hashable
    var hashValue:Int {
        /*
            Iterate through our entire blocks array. We exclusively-or each block's hashValue together to create a single hashValue for the Shape they comprise.
        */
        return reduce(blocks, 0) { $0.hashValue ^ $1.hashValue}
    }
    
    var description:String {
        return "\(color) block facing \(orientation): \(blocks[FirstBlockIdx]), \(blocks[SecondBlockIdx]), \(blocks[ThirdBlockIdx]), \(blocks[FourthBlockIdx])"
    }
    
    init(column:Int, row: Int, color: BlockColor, orientation: Orientation) {
        self.color = color
        self.column = column
        self.row = row
        self.orientation = orientation
        initializeBlocks()
    }
    
    
    ///    A convenience initializer must call down to a standard initializer or otherwise your class will fail to compile. We've placed this one here in order to simplify the initialization process for users of the Shape class. It assigns the given row and column values while generating a random color and a random orientation.
    convenience init(column: Int, row: Int){
        self.init(column:column, row:row, color:BlockColor.random(), orientation:Orientation.random())
    }
    
  ///final function which means it cannot be overridden by subclasses. This implementation of initializeBlocks() is the only one allowed by Shape and its subclasses.
    final func initializeBlocks() {
        
        /*
             Conditional assignments. This if conditional first attempts to assign an array into blockRowColumnTranslations after extracting it from the computed dictionary property. If one is not found, the if block is not executed.
        */
        if let blockRowColumnTranslations = blockRowColumnPositions[orientation] {
            for i in 0..<blockRowColumnTranslations.count {
                let blockRow = row + blockRowColumnTranslations[i].rowDiff
                let blockColumn = column + blockRowColumnTranslations[i].columnDiff
                let newBlock = Block(column: blockColumn, row: blockRow, color: color)
                blocks.append(newBlock)
            }
        }
    }
    
    final func rotateBlocks(orientation: Orientation) {
    
        if let blockRowColumnTranslation:Array<(columnDiff: Int, rowDiff: Int)> = blockRowColumnPositions[orientation] {
            
            /*
                This allows us to iterate through an array object by defining an index variable - idx - as well as the contents at that index: (columnDiff:Int, rowDiff:Int). This saves us the added step of recovering it from the array, let tuple = blockRowColumnTranslation[idx]. We loop through the blocks and assign them their row and column based on the translations provided by the Tetromino subclass.
            */
            for(idx, diff) in enumerate(blockRowColumnTranslation) {
                blocks[idx].column = column + diff.columnDiff
                blocks[idx].row = row + diff.rowDiff
            }
        }
    }
    
    /// We created a couple methods for quickly rotating a shape one turn clockwise or counterclockwise, this will come in handy when testing a potential rotation and reverting it if it breaks the rules. Below that we've added convenience functions which allow us to move our shapes incrementally in any direction.
    final func rotateClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: true)
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }
    
    
    final func rotateCounterClockwise() {
        let newOrientation = Orientation.rotate(orientation, clockwise: false)
        rotateBlocks(newOrientation)
        orientation = newOrientation
    }
    
    
    
    /// Adjust each row and column by rows and columns, respectively
    final func shiftBy(columns: Int, rows: Int) {
        self.column += columns
        self.row += rows
        
        for block in blocks {
            block.column += columns
            block.row += rows
        }
    }
    
    final func lowerShapeByOneRow() {
        shiftBy(0, rows:1)
    }
    
    final func raiseShapeByOneRow() {
        shiftBy(0, rows: -1)
    }
    
    final func shiftLeftByOneColumn() {
        shiftBy(-1, rows: 0)
    }
    
    final func shiftRightByOneColumn() {
        shiftBy(1, rows:0)
    }
    /// We provide an absolute approach to position modification by setting the column and row properties before rotating the blocks to their current orientation which causes an accurate realignment of all blocks relative to the new row and column properties.
    final func moveTo(column: Int, row: Int) {
        self.column = column
        self.row = row
        rotateBlocks(orientation)
    }
    
    ///Generate a random Tetromino shape and you can see that subclasses naturally inherit initializers from their parent class.
    final class func random(startingColumn: Int, startingRow: Int) -> Shape {
        
        switch Int(arc4random_uniform(NumShapeTypes)) {
        case 0:
            return SqaureShape(column: startingColumn, row: startingRow)
        case 1:
            return LineShape(column: startingColumn, row: startingRow)
        case 2:
            return TShape(column: startingColumn, row: startingRow)
        case 3:
            return LShape(column: startingColumn, row: startingRow)
        case 4:
            return JShape(column: startingColumn, row: startingRow)
        case 5:
            return SShape(column: startingColumn, row: startingRow)
        default:
            return ZShape(column: startingColumn, row: startingRow)
        
        }
    }
    
}
func ==(lhs: Shape, rhs: Shape) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}

