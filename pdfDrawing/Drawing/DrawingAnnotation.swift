//
//  DrawingAnnotation.swift
//  pdfDrawing
//
//  Created by DSolution Macbook on 31/8/2562 BE.
//  Copyright © 2562 DSolution. All rights reserved.
//

import Foundation
import PDFKit

public class DrawingAnnotation: MyPDFAnnotaion {
    public var path = UIBezierPath()
    
    public func completed() {
        add(path)
    }
    
    override public func draw(with box: PDFDisplayBox, in context: CGContext) {
        super.draw(with: box, in: context)
        let pathCopy = path.copy() as! UIBezierPath
        UIGraphicsPushContext(context)
        //        UIGraphicsBeginImageContext(self.bounds.size)
        context.saveGState()
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)//
        //        context.setMiterLimit(2.0)
        color.set()
        pathCopy.lineJoinStyle = .round
        pathCopy.lineCapStyle = .round
        pathCopy.lineWidth = border?.lineWidth ?? 1.0
        pathCopy.stroke()
        
        context.restoreGState()
        
        UIGraphicsPopContext()
    }

}
