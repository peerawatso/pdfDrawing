//
//  PDFAnnotationWithPath.swift
//  pdfDrawing
//
//  Created by DSolution Macbook on 31/8/2562 BE.
//  Copyright © 2562 DSolution. All rights reserved.
//

import UIKit
import PDFKit
import Foundation

public extension PDFAnnotation {
    
   public func contains(point: CGPoint) -> Bool {
        var hitPath: CGPath?
        
        if let path = paths?.first {
            hitPath = path.cgPath.copy(strokingWithWidth: 10.0, lineCap: .round, lineJoin: .round, miterLimit: 0)
        }
        return hitPath?.contains(point) ?? false
    }
    
    
}
