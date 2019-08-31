//
//  DrawingGestureRecognizerDelegate.swift
//  pdfDrawing
//
//  Created by DSolution Macbook on 31/8/2562 BE.
//  Copyright © 2562 DSolution. All rights reserved.
//
import UIKit

@objc public protocol DrawingGestureRecognizerDelegate: class {
    @objc optional func gestureRecognizerBegan(_ location: CGPoint)
    @objc optional func gestureRecognizerMoved(_ location: CGPoint)
    @objc optional func gestureRecognizerEnded(_ location: CGPoint)
    func checkNumberOfTouches(numberofTouches: Int)
}

public class DrawingGestureRecognizer: UIGestureRecognizer {
    weak var drawingDelegate: DrawingGestureRecognizerDelegate?
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
            //            touch.type == .pencil, // Comment this line to test on simulator without Apple Pencil
            //            touch.type == .pencil,
            let numberOfTouches = event?.allTouches?.count,
            numberOfTouches == 1 {
            drawingDelegate?.checkNumberOfTouches(numberofTouches: numberOfTouches)
            
            state = .began
            
            let location = touch.location(in: self.view)
            drawingDelegate?.gestureRecognizerBegan?(location)
        } else if let numbersOfTouches = event?.allTouches?.count,
            numbersOfTouches > 1 {
            drawingDelegate?.checkNumberOfTouches(numberofTouches: numbersOfTouches)
            state = .failed
        } else {
            state = .failed
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .changed
        
        guard let location = touches.first?.location(in: self.view) else { return }
        drawingDelegate?.gestureRecognizerMoved?(location)
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self.view) else {
            state = .ended
            return
        }
        drawingDelegate?.gestureRecognizerEnded?(location)
        state = .ended
    }
    
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .failed
    }
}
