//
//  DrawingGestureRecognizer.swift
//  PDFKit Demo
//
//  Created by Tim on 29/01/2019.
//  Copyright © 2019 Tim. All rights reserved.
//

import UIKit

@objc public protocol DrawingGestureRecognizerDelegate: class {
    @objc optional func gestureRecognizerBegan(_ location: CGPoint, _ prevLocation: CGPoint)
    @objc optional func gestureRecognizerMoved(_ location: CGPoint, _ prevLocation: CGPoint)
    @objc optional func gestureRecognizerEnded(_ location: CGPoint, _ prevLocation: CGPoint)
    func checkNumberOfTouches(numberofTouches: Int)
}

public class DrawingGestureRecognizer: UIGestureRecognizer {
    public weak var drawingDelegate: DrawingGestureRecognizerDelegate?
    public var isbuttonNone : Bool!
    public var isbuttonApplePen : Bool!
    
   public convenience init(isbuttonNone: Bool?, isbuttonApple: Bool?) {
        self.init()
        self.isbuttonNone = isbuttonNone
        self.isbuttonApplePen = isbuttonApple
    }
//    init(isbuttonNone: Bool, isbuttonApplePen: Bool) {
//        self.isbuttonNone = isbuttonNone
//        self.isbuttonApplePen = isbuttonApplePen
//        
//    }
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
            //            touch.type == .pencil, // Comment this line to test on simulator without Apple Pencil
            //            touch.type == .pencil,
            let numberOfTouches = event?.allTouches?.count,
            numberOfTouches == 1 {
            if self.isbuttonNone == false{
                touch.type == .direct
                drawingDelegate?.checkNumberOfTouches(numberofTouches: numberOfTouches)
                
                state = .began
                
                let location = touch.location(in: self.view)
                let prevlocation = touch.previousLocation(in: self.view)
                drawingDelegate?.gestureRecognizerBegan?(location, prevlocation)
            } else if self.isbuttonApplePen == true {
                touch.type == .pencil
                drawingDelegate?.checkNumberOfTouches(numberofTouches: numberOfTouches)
                
                state = .began
                
                let location = touch.location(in: self.view)
                let prevlocation = touch.previousLocation(in: self.view)
                drawingDelegate?.gestureRecognizerBegan?(location, prevlocation)
            }
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .changed
        
        guard let location = touches.first?.location(in: self.view) else { return }
        guard let prevlocation = touches.first?.previousLocation(in: self.view) else { return }
        drawingDelegate?.gestureRecognizerMoved?(location, prevlocation)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self.view) else {
            state = .ended
            return
        }
        guard let prevlocation = touches.first?.previousLocation(in: self.view) else {
            return
        }
        drawingDelegate?.gestureRecognizerEnded?(location, prevlocation)
        state = .ended
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
}

//extension DrawingGestureRecognizer {
//   @objc func checkPenAble(isNone: Bool, isApplePen: Bool){
//        isbuttonNone = isNone
//        isbuttonApplePen = isApplePen
//    }
//}
