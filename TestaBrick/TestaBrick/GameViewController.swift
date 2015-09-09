//
//  GameViewController.swift
//  TestaBrick
//
//  Created by Pablo on 29/08/15.
//  Copyright (c) 2015 Pablo. All rights reserved.
//

import UIKit
import SpriteKit



class GameViewController: UIViewController, TestaBrickDelegate, UIGestureRecognizerDelegate {

    var scene: GameScene!
    var testaBrick: TestaBrick!
    
    /// We keep track of the last point on the screen at which a shape movement occurred or where a pan begins.
    var panPointReference:CGPoint?
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Configure the view
        let skView = view as! SKView
        skView.multipleTouchEnabled = false
        
        //Create and configure the scene
        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .AspectFill
        
        /*
            we've set a closure for the tick property of GameScene.swift. Remember that functions are simply named closures. In our case, we've used a function named didTick(). We define didTick() at #3. All it does is lower the falling shape by one row and then asks GameScene to redraw the shape at its new location.
        */
        scene.tick = didTick
        
        testaBrick = TestaBrick()
        testaBrick.delegate = self
        testaBrick.beginGame()
        
        
        //Present the scene
        skView.presentScene(scene)
        
        /*
            We add nextShape to the game layer at the preview location. When that animation completes, we reposition the underlying Shape object at the starting row and starting column before we ask GameScene to move it from the preview location to its starting position. Once that completes, we ask Swiftris for a new shape, begin ticking, and add the newly established upcoming piece to the preview area.
        */
        
        /*
            DELETED BECAUSE OF YES
        scene.addPreviewShapeToScene(testaBrick.nextShape!) {
            self.testaBrick.nextShape?.moveTo(StartingColumn, row: StartingRow)
            self.scene.movePreviewShape(self.testaBrick.nextShape!) {
                let nextShapes = self.testaBrick.newShape()
                self.scene.startTicking()
                self.scene.addPreviewShapeToScene(nextShapes.nextShape!) {}
            }

            
        }*/
        
        
       
    }
    

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    //#3
    func didTick() {
        /// "e substituted our previous efforts with Swiftris' letShapeFall() function, precisely what we need at each tick.
        testaBrick.letShapeFall()
        
        //testaBrick.fallingShape?.lowerShapeByOneRow()
        //scene.redrawShape(testaBrick.fallingShape!, completion: {})
    }

    func nextShape() {
    
        let newShapes = testaBrick.newShape()
        if let fallingShape = newShapes.fallingShape {
            self.scene.addPreviewShapeToScene(newShapes.nextShape!) {}
            self.scene.movePreviewShape(fallingShape) {
                /// We introduced a boolean which allows us to shut down interaction with the view. Regardless of what the user does to the device at this point, they will not be able to manipulate Switris in any way. This is useful during intermediate states when blocks are being animated, shifted around or calculated. Otherwise, a well-timed user interaction may cause an unpredictable game state to occur.
                self.view.userInteractionEnabled = true
                self.scene.startTicking()
                
            }
        }
    }
    
    func gameDidBegin(testabrick: TestaBrick) {
        
        levelLabel.text = "\(testaBrick.level)"
        scoreLabel.text = "\(testaBrick.score)"
        scene.tickLengthMillis = TickLengthLevelOne
        
        // The following is false when restarting a new game
        if testaBrick.nextShape != nil && testaBrick.nextShape!.blocks[0].sprite == nil {
            scene.addPreviewShapeToScene(testaBrick.nextShape!) {
                self.nextShape()
            }
        } else {
            nextShape()
        }
    }
    
    func gameDidEnd(testaBrick: TestaBrick) {
        view.userInteractionEnabled = false
        scene.stopTicking()
        scene.playSound("Sounds/gameover.mp3")
        scene.animateCollapsingLines(testaBrick.removeAllBlocks(), fallenBlocks: Array<Array<Block>>()) {
            testaBrick.beginGame()
        }
    }
    
    func gameDidLevelUp(testaBrick: TestaBrick) {
        //
        levelLabel.text = "\(testaBrick.level)"
        if scene.tickLengthMillis >= 100 {
            scene.tickLengthMillis -= 100
        } else if scene.tickLengthMillis > 50 {
            scene.tickLengthMillis -= 50
        }
        scene.playSound("Sounds/levelup.mp3")
    }

    func gameShapeDidDrop(testaBrick: TestaBrick) {
        /// we stop the ticks, redraw the shape at its new location and then let it drop. This will in turn call back to GameViewController and report that the shape has landed.

        scene.stopTicking()
        scene.redrawShape(testaBrick.fallingShape!) {
            testaBrick.letShapeFall()
        }
           scene.playSound("Sounds/drop.mp3")
    }
    
    func gameShapeDidLand(testaBrick: TestaBrick) {
        scene.stopTicking()
        self.view.userInteractionEnabled = false
        
        /// 1
        let removedLines = testaBrick.removeCompletedLines()
        if removedLines.linesRemoved.count > 0 {
            self.scoreLabel.text = "\(testaBrick.score)"
            scene.animateCollapsingLines(removedLines.linesRemoved, fallenBlocks:removedLines.fallenBlocks) {
                
                /// 2 
                self.gameShapeDidLand(testaBrick)
            }
            scene.playSound("Sounds/bomb.mp3")
        } else {
            nextShape()
        }
    }
    @IBAction func didSwipe(sender: UISwipeGestureRecognizer) {
        testaBrick.dropShape()
    }
    /// GameViewController will implement an optional delegate method found in UIGestureRecognizerDelegate which will allow each gesture recognizer to work in tandem with the others. However, at times a gesture recognizer may collide with another.
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// Occasionally when swiping down, a pan gesture may occur simultaneously with a swipe gesture. In order for these recognizers to relinquish priority, we will implement another optional delegate method at gestureRecognizer. The code performs several optional cast conditionals. These if conditionals attempt to cast the generic UIGestureRecognizer parameters as the specific types of recognizers we expect to be notified of. If the cast succeeds, the code block is executed.
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let swipeRec = gestureRecognizer as? UISwipeGestureRecognizer {
            if let panRec = otherGestureRecognizer as? UIPanGestureRecognizer {
                return true
            }
        } else if let panRec = gestureRecognizer as? UIPanGestureRecognizer {
            if let tapRec = otherGestureRecognizer as? UITapGestureRecognizer {
                return true
            }
        }
        return false
    }
    
 
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        testaBrick.rotateShape()
    }
    @IBAction func didPan(sender: UIPanGestureRecognizer) {
        /// We recover a point which defines the translation of the gesture relative to where it began. This is not an absolute coordinate, just a measure of the distance that the user's finger has traveled.
        let currentPoint = sender.translationInView(self.view)
        if let originalPoint = panPointReference {
            
            /// We check whether or not the x translation has crossed our threshold - 90% of BlockSize - before proceeding.
            if abs(currentPoint.x - originalPoint.x) > (BlockSize * 0.9) {
                /// 4 Velocity will give us direction, in this case a positive velocity represents a gesture moving towards the right side of the screen, negative towards the left. We then move the shape in the corresponding direction and reset our reference point.
                if sender.velocityInView(self.view).x > CGFloat(0) {
                    testaBrick.moveShapeRight()
                    panPointReference = currentPoint
                } else {
                    testaBrick.moveShapeLeft()
                    panPointReference = currentPoint
                }
            }
        } else if sender.state == .Began {
            panPointReference = currentPoint
        }
    }
    
    /// All that is necessary to do after a shape has moved is to redraw its representative sprites at their new locations.
    func gameShapeDidMove(testaBrick: TestaBrick) {
        scene.redrawShape(testaBrick.fallingShape!) {}
    }
}
