//
//  PDFText.swift
//  pdfDrawing
//
//  Created by DSolution Macbook on 27/12/2562 BE.
//  Copyright © 2562 DSolution. All rights reserved.
//

import Foundation
import PDFKit
import UIKit

public class PDFText: MyPDFAnnotaion {
    weak public var pdfView: PDFView!
    public var currentPage: PDFPage?
//    public let currentAnnotation: PDFAnnotation?
    public var isTrue: Bool = false
    public var delegate: PDFAnnotationEvent?

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
    
//        public var font: UIFont = UIFont.systemFont(ofSize: 14.0) {
//            didSet {
//                view.font = self.font
//            }
//        }
        
        lazy var view: PDFTextAnnotationView = PDFTextAnnotationView(parent: self)
        
        fileprivate var isEditing: Bool = false
        
    //    override required public init() { super.init() }
        
        public func didEnd() {
            self.view.hideEditingHandles()
            self.view.textView.resignFirstResponder()
            self.view.textView.isUserInteractionEnabled = false
        }
        
}

extension PDFText: DrawingGestureTextDelegate {
    public func mutableView() -> UIView {
         view = PDFTextAnnotationView(parent: self)
         return view
     }
    
    public func gestureRecognizerBegan(_ touch: UITouch, _ location: CGPoint) {
        if rect == CGRect.zero {
            rect = CGRect(origin: location, size: CGSize(width: 150, height: 48))
        }
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        currentPage = page
        if isTrue == false{
            pdfView.addSubview(mutableView())
            isTrue = true
            
        }
        self.view.touchesBegan([touch], with: nil)
    }
    
    public func gestureRecognizerMoved(_ touch: UITouch, _ location: CGPoint) {
        guard let page = currentPage else { return }
        self.view.touchesMoved([touch], with: nil)
        drawAnnotation(page: page)
    }
    
    public func gestureRecognizerEnded(_ touch: UITouch, _ location: CGPoint) {
        guard let page = currentPage else { return }
        self.view.touchesEnded([touch], with: nil)
        drawAnnotation(page: page)
    }
    
    public func drawAnnotation(page: PDFPage){
//         let annotation = PDFAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .freeText, withProperties:    nil)
//         page.addAnnotation(annotation)
//        var textFieldMultiline21 = PDFAnnotation()
//        let textFieldMultilineBounds21 = CGRect(x: 27, y: 58+2, width: 339, height: 508)
//        textFieldMultiline21 = PDFAnnotation(bounds: textFieldMultilineBounds21, forType: PDFAnnotationSubtype(rawValue: PDFAnnotationSubtype.widget.rawValue), withProperties: nil)
//        textFieldMultiline21.widgetFieldType = PDFAnnotationWidgetSubtype(rawValue: PDFAnnotationWidgetSubtype.text.rawValue)
//
//        textFieldMultiline21.backgroundColor = UIColor.clear
//        textFieldMultiline21.hasComb = true
//        textFieldMultiline21.font = UIFont.systemFont(ofSize: 18)
//        textFieldMultiline21.fontColor = .black
//        textFieldMultiline21.isMultiline = true
//        page.addAnnotation(textFieldMultiline21)
        
        let annotation = PDFAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .freeText, withProperties: nil)
//         annotation.contents = "Hello, world!"
//         annotation.font = UIFont.systemFont(ofSize: 15.0)
//         annotation.fontColor = .blue
//         annotation.color = .clear
         page.addAnnotation(annotation)
     }
}

extension PDFText: ResizableViewDelegate {
    public func resizableViewDidBeginEditing(view: ResizableView) {}

    public func resizableViewDidEndEditing(view: ResizableView) {
        self.rect = self.view.frame
    }

//    func resizableViewDidSelectAction(view: ResizableView, action: String) {
//        self.delegate?.annotation(annotation: self, selected: action)
//    }
}

 extension PDFText: PDFAnnotationButtonable {

    public static var name: String? { return "Text" }
//    public static var buttonImage: UIImage? { return UIImage.bundledImage("text-symbol") }
}

 extension PDFText: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        textView.sizeToFit()

        var width: CGFloat = 150.0
        if self.view.frame.width > width {
            width = self.view.frame.width
        }

        rect = CGRect(x: self.view.frame.origin.x,
                      y: self.view.frame.origin.y,
                      width: width,
                      height: self.view.frame.height)

        if text != textView.text {
            text = textView.text
        }
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.isUserInteractionEnabled = false
    }
}

public class PDFTextAnnotationView: ResizableView, PDFAnnotationView {
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

    public convenience init(parent: PDFText) {

        self.init()

        self.parent = parent
        self.delegate = parent
        self.frame = parent.rect
        self.text = parent.text
        self.font = parent.font!

        self.textView.text = parent.text
        self.textView.delegate = parent
        self.textView.isUserInteractionEnabled = false
        self.textView.backgroundColor = UIColor.clear

//        self.backgroundColor = UIColor.clear

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


