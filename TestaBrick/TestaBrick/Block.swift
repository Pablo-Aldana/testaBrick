//
//  Block.swift
//  TestaBrick
//
//  Created by Pablo on 30/08/15.
//  Copyright (c) 2015 Pablo. All rights reserved.
//

import SpriteKit

/*
    Define  how many colors are available in TestaBrick, 6.
*/
let NumberOfColors: UInt32 = 6

/*
    Enumeration. It is of type Int and it implements the Printable protocol.
    Classes, structures and enums which implement Printable are capable of generating human-readable strings when debugging or printing their value to the console
*/
enum BlockColor: Int, Printable {
    
    /*
        Provide the full list of enumerable options, one for each color beginning with Blue at 0 and ending at 5 with Yellow.
    */
    case Blue = 0, Orange, Purple, Red, Teal, Yellow
    
    /*
        We define a computed property, spriteName. A computed property is one that behaves like a typical variable, but when accessing it, a code block is invoked to generate its value each time. We could have put this inside of a function named, getSpriteName() but a computed property is the better design choice.

        spriteName returns the correct filename for the given color, we use a simple switch…case statement to accomplish this.

    */
    var spriteName: String {
        switch self {
        case .Blue:
            return "blue"
        case .Orange:
            return "orange"
        case .Purple:
            return "purple"
        case .Red:
            return "red"
        case .Teal:
            return "teal"
        case .Yellow:
            return "yellow"
        }
    }
    
    /*
        We declare yet another computed property, description. This property is required if we are to adhere to the Printable protocol. Without it, our code will fail to compile. It simply returns the spriteName of the color which is more than enough to describe the object.
    */
    var description: String {
        return self.spriteName
    }
    
    /*
        We declare a static function named random(). As you may have guessed, this function returns a random choice among the colors found in BlockColor. It creates a BlockColor using the rawValue:Int initializer to setup an enumeration which assigned to the numerical value passed into it, in our case numbers 0 through 5.
    
    */
    static func random() -> BlockColor {
        return BlockColor(rawValue:Int(arc4random_uniform(NumberOfColors)))!
    }
    
}

/*
    Block is declared as a class which implements both the Printable and Hashable protocols. Hashable allows Block to be stored in Array2D.
*/
class Block: Hashable, Printable {
    /*
        We define our color property as let, meaning once we assign it, it can no longer be re-assigned. A block should not be able to change colors mid-game unless you decide to make TestaBrick: Epileptic Adventures.
    */
    let color:BlockColor

    /*
        We declare a column and row. These properties represent the location of the Block on our game board. The SKSpriteNode will represent the visual element of the Block to be used by GameScene when rendering and animating each Block.
    */
    //Properties
    var column: Int
    var row: Int
    var sprite: SKSpriteNode?
    
    /*
        Provide a convenient shortcut for recovering the file name of the sprite to be used when displaying this Block. It effectively shortened our code from block.color.spriteName to block.spriteName.
    */
    var spriteName: String {
        return color.spriteName
    }
    
    /*
        hashValue calculated property, which is required in order to support the Hashable protocol. We return the exclusive-or of our row and column properties to generate a unique integer for each Block.
    */
    var hashValue: Int {
        return self.column ^ self.row
    }
    
    /*
        We implement description as we must do in order to comply with the Printable protocol. Printable object types can be placed in the middle of a string by surrounding them with \( and ). For a blue block at row 3, column 8, printing that Block will result in: "blue: [8, 3]".
    */
    var description: String {
        return "\(color): [\(column), \(row)]"
    }
    
    init(column:Int, row:Int, color:BlockColor) {
        self.column = column
        self.row = row
        self.color = color
    }
    
  
   
}

/*
We create a custom operator- == - when comparing one Block with another. It returns true if and only if both Blocks are in the same location and of the same color. This operator is required in order to support the Hashable protocol.
implement equatable

CAUTION! IS OUTIDE THE CLASS
*/
func ==(lhs: Block, rhs: Block) -> Bool {
    return lhs.column == rhs.column && lhs.row == rhs.row && lhs.color.rawValue == rhs.color.rawValue
}