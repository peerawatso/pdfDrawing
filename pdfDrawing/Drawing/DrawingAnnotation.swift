//
//  DrawingAnnotation.swift
//  PDFKit Demo
//
//  Created by Tim on 31/01/2019.
//  Copyright © 2019 Tim. All rights reserved.
//

import Foundation
import PDFKit

public class DrawingAnnotation: MyPDFAnnotaion {
    public var path = UIBezierPath()
    
    func completed() {
        add(path)
    }
    
    override func draw(with box: PDFDisplayBox, in context: CGContext) {
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
