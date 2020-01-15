////
////  DrawingGestureTextDelegate.swift
////  pdfDrawing
////
////  Created by DSolution Macbook on 26/12/2562 BE.
////  Copyright © 2562 DSolution. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//@objc public protocol DrawingGestureTextDelegate: class {
//    @objc optional func gestureRecognizerBegan(_ touch: UITouch, _ location: CGPoint)
//    @objc optional func gestureRecognizerMoved(_ touch: UITouch, _ location: CGPoint)
//    @objc optional func gestureRecognizerEnded(_ touch: UITouch, _ location: CGPoint)
////    func checkNumberOfTouches(numberofTouches: Int)
//}
//
//
//public class DrawingGestureText: UIGestureRecognizer{
//    public weak var drawingDelegate: DrawingGestureTextDelegate?
//
//    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self.view)
//        drawingDelegate?.gestureRecognizerBegan?(touch, location)
//    }
//
//    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self.view)
//        drawingDelegate?.gestureRecognizerMoved?(touch, location)
//    }
//
//    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
//        guard let touch = touches.first else { return }
//        let location = touch.location(in: self.view)
//        drawingDelegate?.gestureRecognizerEnded?(touch, location)
//    }
//}
