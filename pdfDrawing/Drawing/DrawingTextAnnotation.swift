//
//  DrawingTextAnnotation.swift
//  pdfDrawing
//
//  Created by DSolution Macbook on 25/12/2562 BE.
//  Copyright © 2562 DSolution. All rights reserved.
//

import Foundation
import UIKit
import PDFKit

public class DrawingTextAnnotation: MyPDFAnnotaion {
//    public var path = UIBezierPath()
    weak public var pdfView: PDFView!
    public var currentPage: PDFPage?
//    func completed() {
//        add(path)
//    }

    public var text: String = "" {
        didSet {
            view.text = text
        }
    }

    public var rect: CGRect = CGRect.zero {
        didSet {
            view.frame = self.rect
        }
    }

    override public var font: UIFont?  {
        didSet{
            view.font = self.font!
        }
    }
//    public var font: UIFont = UIFont.systemFont(ofSize: 14.0) {
//        didSet {
//            view.font = self.font
//        }
//    }
    
    lazy var view: PDFTextAnnotationView1 = PDFTextAnnotationView1(parent: self)

    fileprivate var isEditing: Bool = false
    
//    override required public init() { super.init() }
    
//    public func didEnd() {
//        self.view.hideEditingHandles()
//        self.view.textView.resignFirstResponder()
//        self.view.textView.isUserInteractionEnabled = false
//    }
    
//    public func touchStarted(_ touch: UITouch, point: CGPoint) {
//        if rect == CGRect.zero {
//            rect = CGRect(origin: point, size: CGSize(width: 150, height: 48))
//        }
//        guard let page = pdfView.page(for: point, nearest: true) else { return }
//        currentPage = page
//        self.view.touchesBegan([touch], with: nil)
//    }
//
//    public func touchMoved(_ touch: UITouch, point: CGPoint) {
//        guard let page = currentPage else { return }
//        self.view.touchesMoved([touch], with: nil)
//        drawAnnotation(page: page)
//    }
//
//    public func touchEnded(_ touch: UITouch, point: CGPoint) {
//        guard let page = currentPage else { return }
//        self.view.touchesEnded([touch], with: nil)
//        drawAnnotation(page: page)
//    }
//
//    public func drawAnnotation(page: PDFPage){
//        let annotation = PDFAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .freeText, withProperties:    nil)
//        page.addAnnotation(annotation)
//    }
    
    public override func draw(with box: PDFDisplayBox, in context: CGContext) {
        UIGraphicsPushContext(context)
        context.setAlpha(1.0)
        let nsText = self.text as NSString

        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.alignment = .left
        let attributes: [String:AnyObject] = [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font!,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.black,
            convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paragraphStyle
        ]
        let size = nsText.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
        let textRect = CGRect(origin: rect.origin, size: size)
        
        nsText.draw(in: textRect, withAttributes: convertToOptionalNSAttributedStringKeyDictionary(attributes))
        
        UIGraphicsPopContext()
    }
    
     // Helper function inserted by Swift 4.2 migrator.
     public func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
         return input.rawValue
     }

     // Helper function inserted by Swift 4.2 migrator.
     public func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
         guard let input = input else { return nil }
         return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
     }
}



//extension DrawingTextAnnotation: ResizableViewDelegate {
//    public func resizableViewDidBeginEditing(view: ResizableView) {}
//
//    public func resizableViewDidEndEditing(view: ResizableView) {
//        self.rect = self.view.frame
//    }
//
////    func resizableViewDidSelectAction(view: ResizableView, action: String) {
////        self.delegate?.annotation(annotation: self, selected: action)
////    }
//}
//
// extension DrawingTextAnnotation: PDFAnnotationButtonable {
//
//    public static var name: String? { return "Text" }
////    public static var buttonImage: UIImage? { return UIImage.bundledImage("text-symbol") }
//}
//
// extension DrawingTextAnnotation: UITextViewDelegate {
//    public func textViewDidChange(_ textView: UITextView) {
//        textView.sizeToFit()
//
//        var width: CGFloat = 150.0
//        if self.view.frame.width > width {
//            width = self.view.frame.width
//        }
//
//        rect = CGRect(x: self.view.frame.origin.x,
//                      y: self.view.frame.origin.y,
//                      width: width,
//                      height: self.view.frame.height)
//
//        if text != textView.text {
//            text = textView.text
//        }
//    }
//
//    public func textViewDidEndEditing(_ textView: UITextView) {
//        textView.isUserInteractionEnabled = false
//    }
//}
//
public class PDFTextAnnotationView1: ResizableView, PDFAnnotationView {
    public var parent: MyPDFAnnotaion?
    override public var canBecomeFirstResponder: Bool { return true }
    override var menuItems: [UIMenuItem] {
        return [
            UIMenuItem(
                title: "Delete",
                action: #selector(PDFTextAnnotationView.menuActionDelete(_:))
            ),
            UIMenuItem(
                title: "Edit",
                action: #selector(PDFTextAnnotationView.menuActionEdit(_:))
            )
        ]
    }
    
   public var textView: UITextView = UITextView()
    
   public var text: String = "" {
        didSet {
            textView.text = text
        }
    }
    
   public var font: UIFont = UIFont.systemFont(ofSize: 14.0) {
        didSet {
            textView.font = self.font
        }
    }
    
    override public var frame: CGRect {
        didSet {
            textView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        }
    }
    
    public convenience init(parent: DrawingTextAnnotation) {
        
        self.init()
        
        self.parent = parent
        self.delegate = parent as! ResizableViewDelegate
        self.frame = parent.rect
        self.text = parent.text
        self.font = parent.font!
        
        self.textView.text = parent.text
        self.textView.delegate = parent as! UITextViewDelegate
        self.textView.isUserInteractionEnabled = false
        self.textView.backgroundColor = UIColor.clear
        
        self.backgroundColor = UIColor.clear
        
        self.addSubview(textView)
    }
    
    @objc public func menuActionEdit(_ sender: Any!) {
//        self.delegate?.resizableViewDidSelectAction(view: self, action: "edit")
        
        self.isLocked = true
        self.textView.isUserInteractionEnabled = true
        self.textView.becomeFirstResponder()
    }
    
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        if action == #selector(menuActionEdit(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
}



