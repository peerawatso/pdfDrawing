//
//  PDFPage+Selection.swift
//  pdfDrawing
//
//  Created by DSolution Macbook on 31/8/2562 BE.
//  Copyright © 2562 DSolution. All rights reserved.
//

import UIKit
import PDFKit

public extension PDFPage {
   public func annotationWithHitTest(at: CGPoint) -> PDFAnnotation? {
        for annotation in annotations {
            if annotation.contains(point: at) {
                return annotation
            }
        }
        return nil
    }
}
