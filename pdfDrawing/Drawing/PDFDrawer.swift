//
//  PDFDrawer.swift
//  PDFKit Demo
//
//  Created by Tim on 31/01/2019.
//  Copyright © 2019 Tim. All rights reserved.
//

import Foundation
import PDFKit
import SQLite3

enum DrawingTool: Int {
    case eraser = 0
    case pencil = 11
    case pen = 12
    case penM = 14
    case highlighter = 13
    case clear = 15
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case five = 5
    case six = 6
    case seven = 7
    case eight = 8
    case nine = 9
    case ten = 10
    case none = 16
    
    var width: CGFloat {
        switch self {
        case .pencil:
            return 1
        case .penM:
            return 3
        case .pen:
            return 5
        case .highlighter:
            return 10
        case .clear:
            return 0
        case .one:
            return 1
        case .two:
            return 2
        case .three:
            return 3
        case .four:
            return 4
        case .five:
            return 5
        case .six:
            return 6
        case .seven:
            return 7
        case .eight:
            return 8
        case .nine:
            return 9
        case .ten:
            return 10
        case .none:
            return 0
        default:
            return 0
        }
    }
    
    var alpha: CGFloat {
        switch self {
        case .highlighter:
            return 0.3 //0,5
        case .none:
            return 0
        default:
            return 1
        }
    }
}

protocol PDFDrawerDelegate : class{
    func undo(isUndo : Bool)
    func redo(isRedo : Bool)
    func checkSelect()
    //   func checkNumberOfTouches(numberOfTouches: Int)
    //    func selectDB(page : PDFPage) -> [MyPDFAnnotaion]
}

class PDFDrawer {
    weak var pdfView: PDFView!
    private var path: UIBezierPath?
    var currentAnnotation : DrawingAnnotation?
    var currentAnnotation1 : DrawingAnnotation?
    var currentPoint : CGPoint?
    var currentPage: PDFPage?
    var currentPage1: PDFPage?
    var color = UIColor.black // default color is black
    var drawingTool = DrawingTool.pen
    var pathArrays : [Path] = []
    var bufferArrays : [Path] = []
    var undoAnnotation : [MyPDFAnnotaion] = []
    var redoAnnotation : [MyPDFAnnotaion] = []
    var historyAnnotation : [MyPDFAnnotaion] = []
    weak var delegate : PDFDrawerDelegate? = .none
    open var fileName : String?
    var point : CGPoint?
    var border : PDFBorder?
    var page : PDFPage?
    var pagePDF : PDFPage?
    var alpha : CGFloat?
    var tool : Int?
    var urlPath : URL? = nil
    var db: OpaquePointer?
    var pdfDocument: PDFDocument?
    var currentAnnotation2: MyPDFAnnotaion?
    var Addannotations : PDFAnnotation?
    var prevPoint : CGPoint?
    var prevPoint2 : CGPoint?
    var isFirst = true
    
}

extension PDFDrawer: DrawingGestureRecognizerDelegate {
    func gestureRecognizerBegan(_ location: CGPoint, _ prevLocation: CGPoint) {
        pdfView.isUserInteractionEnabled = true
        guard let page = pdfView.page(for: location, nearest: true) else { return }
        currentPage = page
        let convertedPoint = pdfView.convert(location, to: currentPage!)
        let convertedPoint2 = pdfView.convert(prevLocation, to: currentPage!)
        path = UIBezierPath()
        path?.move(to: convertedPoint)
        prevPoint = convertedPoint
        prevPoint2 = convertedPoint2
        delegate?.checkSelect()
    }
    
    func gestureRecognizerMoved(_ location: CGPoint, _ prevLocation: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        let convertedPoint2 = pdfView.convert(prevLocation, to: page)
        if drawingTool == .eraser {
            if undoAnnotation.count >= 1{
                removeAnnotationUndo(point: convertedPoint, page: page)
                removeAnnotationAtPoint(point: convertedPoint, page: page)
                return
            }else {
                removeAnnotationAtPoint(point: convertedPoint, page: page)
                return
            }
        }
        //        if let prevPoint = prevPoint {
        //            let midPoint = CGPoint(
        //                x: (convertedPoint.x + prevPoint.x) / 2,
        //                y: (convertedPoint.y + prevPoint.y) / 2)
        //            if isFirst {
        //                path?.addLine(to: convertedPoint)
        //                path?.move(to: convertedPoint)
        //            } else {
        //                path?.addCurve(to: midPoint, controlPoint1: prevPoint, controlPoint2: convertedPoint)
        //                path?.move(to: midPoint)
        //
        //            }
        //            isFirst = false
        //
        //        }
        
        path?.addLine(to: convertedPoint)
        //        path?.addQuadCurve(to: convertedPoint, controlPoint: convertedPoint2)
        path?.move(to: convertedPoint)
        drawAnnotation(onPage: page, point: convertedPoint)
        
    }
    
    func gestureRecognizerEnded(_ location: CGPoint, _ prevlocation: CGPoint) {
        guard let page = currentPage else { return }
        let convertedPoint = pdfView.convert(location, to: page)
        let convertedPoint2 = pdfView.convert(prevlocation, to: page)
        // Erasing
        if drawingTool == .eraser {
            if undoAnnotation.count >= 1{
                removeAnnotationUndo(point: convertedPoint, page: page)
                removeAnnotationAtPoint(point: convertedPoint, page: page)
                return
            }else {
                removeAnnotationAtPoint(point: convertedPoint, page: page)
                return
            }
        }
        
        // Drawing
        guard let _ = currentAnnotation else { return }
        //        if let prevPoint = prevPoint {
        //            let midPoint = CGPoint(
        //                x: (convertedPoint.x + prevPoint.x) / 2,
        //                y: (convertedPoint.y + prevPoint.y) / 2)
        //            if isFirst {
        //                path?.addLine(to: convertedPoint)
        //                path?.move(to: convertedPoint)
        //            } else {
        //                path?.addCurve(to: midPoint, controlPoint1: prevPoint, controlPoint2: convertedPoint)
        //                path?.move(to: midPoint)
        //            }
        //            isFirst = false
        //
        //        }
        path?.addLine(to: convertedPoint)
        //        path?.addQuadCurve(to: convertedPoint, controlPoint: convertedPoint2)
        path?.move(to: convertedPoint)
        
        drawAnnotation(onPage: page, point: convertedPoint)
        
        currentAnnotation?.completed()
        currentAnnotation = nil
    }
    
    func checkNumberOfTouches(numberofTouches: Int) {
        if numberofTouches > 1{
            //            pdfView.isUserInteractionEnabled = false
            //        } else if numberofTouches == 1 {
            //            pdfView.isUserInteractionEnabled = true
            //        }
            if let recognizers = pdfView.gestureRecognizers {
                for gestureRecognizer in recognizers{
                    print(gestureRecognizer)
                    //                    if gestureRecognizer is UIPanGestureRecognizer {
                    //                        gestureRecognizer.isEnabled = false
                    //                    }
                    if gestureRecognizer is UIPinchGestureRecognizer {
                        gestureRecognizer.isEnabled = false
                    }
                    if gestureRecognizer is UIScreenEdgePanGestureRecognizer {
                        gestureRecognizer.isEnabled = false
                    }
                    if gestureRecognizer is UITapGestureRecognizer {
                        gestureRecognizer.isEnabled = false
                    }
                    if gestureRecognizer is UILongPressGestureRecognizer {
                        gestureRecognizer.isEnabled = false
                    }
                    
                }
            }
        }
    }
    
    private func createAnnotation(path: UIBezierPath, page: PDFPage, point: CGPoint) -> DrawingAnnotation {
        let annotation = DrawingAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
        let uuid = UUID().uuidString
        if(redoAnnotation.count > 0){
            pathArrays.removeAll()
            redoAnnotation.removeAll()
            let border = PDFBorder()
            border.lineWidth = drawingTool.width
            
            annotation.color = color.withAlphaComponent(drawingTool.alpha)
            annotation.border = border
            //            annotation.status = "show"
            //            annotation.pageCurrent = page
            //            annotation.colorCurrent = color.withAlphaComponent(drawingTool.alpha)
            //            annotation.borderCurrent = border
            //            annotation.pathCurrent = path
            //            annotation.pointCurrent = point
            //            let a = NSCoder.string(for: point)
            //            annotation.StringPointCurrent = a
            //            annotation.alphaCurrent = drawingTool.alpha
            //            annotation.toolCurrent = annotation.type
            ////            annotation.type = String(drawingTool.rawValue)
            ////            annotation.type = uuid
            //            annotation.uuid = uuid
            //            let p  = Path(path: path, color: annotation.color, point: point, border: border, page: page, alpha: drawingTool.alpha, tool: drawingTool.rawValue)
            //            pathArrays.append(p)
            undoAnnotation.append(annotation)
            //            historyAnnotation.append(annotation)
            
            delegate?.undo(isUndo: undoAnnotation.count > 0)
            delegate?.redo(isRedo: redoAnnotation.count > 0)
            
            return annotation
        }else if(redoAnnotation.count == 0) {
            let border = PDFBorder()
            border.lineWidth = drawingTool.width
            //            let annotation = DrawingAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
            annotation.color = color.withAlphaComponent(drawingTool.alpha)
            annotation.border = border
            annotation.status = "show"
            //            let uuid = UUID().uuidString
            ////            print(uuid)
            //            annotation.type = uuid
            //            print(annotation.description)
            //            annotation.pageCurrent = page
            //            annotation.colorCurrent = color.withAlphaComponent(drawingTool.alpha)
            //            annotation.borderCurrent = border
            //            annotation.pathCurrent = path
            //            let a = NSCoder.string(for: point)
            //            annotation.pointCurrent = point
            //            annotation.StringPointCurrent = a
            //            annotation.alphaCurrent = drawingTool.alpha
            //            annotation.toolCurrent = annotation.type
            ////            annotation.type = String(drawingTool.rawValue)
            ////            annotation.type = uuid
            //            annotation.uuid = uuid
            
            //            let p  = Path(path: path, color: annotation.color, point: point, border: border, page: page, alpha: drawingTool.alpha, tool: drawingTool.rawValue)
            undoAnnotation.append(annotation)
            //            historyAnnotation.append(annotation)
            //            pathArrays.append(p)
            delegate?.undo(isUndo: undoAnnotation.count > 0)
            
            return annotation
        }
        return annotation
    }
    
    //    private func createAnnotation(path: UIBezierPath,color: UIColor,point: CGPoint,border: PDFBorder,page: PDFPage,alpha: CGFloat,tool: Int) -> DrawingAnnotation {
    //
    //        let annotation = DrawingAnnotation(bounds: page.bounds(for: pdfView.displayBox), forType: .ink, withProperties: nil)
    //        annotation.color = color.withAlphaComponent(alpha)
    //        annotation.border = border
    //        delegate?.redo(isRedo: bufferArrays.count > 0)
    //        print(annotation)
    //        pathArrays.append(Path(path: path, color: annotation.color, point: point, border: border, page: page, alpha: alpha, tool: tool))
    //        return annotation
    //    }
    //
    //    private func drawAnnotation(path: UIBezierPath,color: UIColor,point: CGPoint,border: PDFBorder, page: PDFPage, alpha: CGFloat,tool: Int) {
    //
    //        if currentAnnotation1 == nil {
    //            currentAnnotation1 = createAnnotation(path: path,color: color,point: point,border: border,page: page,alpha: alpha,tool: tool)
    //        }
    //
    //        currentAnnotation1?.path = path
    //        //        drawRedo(annotation: currentAnnotation!, onPage: page)
    //        forceRedraw(annotation: currentAnnotation1!, onPage: page)
    //        currentAnnotation1?.completed()
    //        currentAnnotation1 = nil
    //    }
    
    
    private func drawAnnotation(onPage: PDFPage, point: CGPoint) {
        guard let path = path else { return }
        
        if currentAnnotation == nil {
            currentAnnotation = createAnnotation(path: path, page: onPage,point: point)
        }
        
        currentAnnotation?.path = path
        onPage.addAnnotation(currentAnnotation!)
        //        guard let pathPdf = urlPath else { return }
        //        let isSuccess = self.pdfView.document?.write(to: pathPdf)
        //        currentPage = onPage
        //        forceRedraw(annotation: currentAnnotation!, onPage: onPage)
    }
    
    private func removeAnnotationAtPoint(point: CGPoint, page: PDFPage) {
        if let selectedAnnotation = page.annotationWithHitTest(at: point) {
            selectedAnnotation.page?.removeAnnotation(selectedAnnotation)
            print(selectedAnnotation)
        }
        
    }
    
    private func removeAnnotationUndo(point: CGPoint, page: PDFPage) {
        if let selectedAnnotation = page.annotationWithHitTest(at: point) {
            guard let select = selectedAnnotation as? MyPDFAnnotaion else { return }
            if let index = undoAnnotation.firstIndex(of: select) {
                let undoEraser = undoAnnotation.remove(at: index)
                
                selectedAnnotation.page?.removeAnnotation(selectedAnnotation)
                print(selectedAnnotation)
                delegate?.undo(isUndo: undoAnnotation.count > 0)
            } else {
                selectedAnnotation.page?.removeAnnotation(selectedAnnotation)
                //                print(selectedAnnotation)
            }
        }
    }
    
    //    private func forceRedraw(annotation: PDFAnnotation, onPage: PDFPage) {
    //        onPage.removeAnnotation(annotation)
    //        onPage.addAnnotation(annotation)
    //    }
    
    func undoLatestStep (path: UIBezierPath, color: UIColor ,point: CGPoint,border: PDFBorder, page: PDFPage, alpha: CGFloat ,tool: Int) {
        //        if(tool == 0){
        //            pathArrays.count - 1
        //            delegate?.undo(isUndo: pathArrays.count > 0)
        //            return
        //            for path in bufferArrays {
        //                self.path = path.getPath()
        //                self.color = path.getColor()
        //                self.point = path.getPoint()
        //                self.border = path.getBorder()
        //                self.page = path.getPage()
        //                self.alpha = path.getAlpha()
        //                self.tool = path.getTool()
        //        }else{
        //            redoLastestStep(path: self.path!, color: self.color, point: self.point!, border: self.border!, page: self.page!, alpha: self.alpha!, tool: self.tool!)
        //        }else {
        let p = Path(path: path, color: color, point: point, border: border, page: page, alpha: alpha, tool: tool)
        if(canUndo()) {
            //            delegate?.test(isUndo: true)
            self.bufferArrays.append(p)
            self.pathArrays.removeLast()
            for undoArray in undoAnnotation {
                
            }
            //            print(b)
            if let undo = undoAnnotation.popLast() {
                undo.page?.removeAnnotation(undo)
            }
            //            if let annotation = page.annotation(at: point){
            //                annotation.page?.removeAnnotation(annotation)
            //                print(annotation)
            //            }
            //            delegate?.undo(isUndo: pathArrays.count > 0)
            //            delegate?.redo(isRedo: bufferArrays.count > 0)
            //                pdfView.setNeedsDisplay()
            //            }
            //            }
        }
    }
    
    func undoLatestStep (annotation: MyPDFAnnotaion) {
        if(canUndo()) {
            //            if annotation.type == "0" {
            //                if annotation.status?.contains("hide") == true {
            //                    history.status = "show"
            //                    redoAnnotation.append(history)
            //                }
            //                if let undo = undoAnnotation.popLast() {
            //                    undo.page?.addAnnotation(annotation)
            //                }
            //                delegate?.undo(isUndo: undoAnnotation.count > 0)
            //                delegate?.redo(isRedo: redoAnnotation.count > 0)
            //            }else {
            redoAnnotation.append(annotation)
            if let undo = undoAnnotation.popLast() {
                undo.page?.removeAnnotation(undo)
            }
            delegate?.undo(isUndo: undoAnnotation.count > 0)
            delegate?.redo(isRedo: redoAnnotation.count > 0)
            //            }
        }
    }
    
    
    
    func canUndo() -> Bool {
        return undoAnnotation.count > 0
    }
    
    func redoLastestStep (path: UIBezierPath, color: UIColor ,point: CGPoint,border: PDFBorder, page: PDFPage, alpha: CGFloat, tool :Int ) {
        if(canRedo()){
            let p = Path(path: path, color: color, point: point, border: border, page: page, alpha: alpha, tool: tool)
            self.pathArrays.append(p)
            self.bufferArrays.removeLast()
            //            drawAnnotation(path:path,color:color,point:point,border: border,page: page,alpha: alpha, tool: tool)
            delegate?.undo(isUndo: pathArrays.count > 0)
            delegate?.redo(isRedo: bufferArrays.count > 0)
            //            let annotation = page.redo(at: point)
            //            annotation!.page?.addAnnotation(annotation!)
            // pdfView.setNeedsDisplay()
        }
    }
    
    func redoLastestStep (annotation: MyPDFAnnotaion) {
        if(canRedo()){
            //            if annotation.type == "0" {
            //                undoAnnotation.append(annotation)
            //                if let redo = redoAnnotation.popLast() {
            //                    redo.page?.removeAnnotation(redo)
            //                    delegate?.undo(isUndo: undoAnnotation.count > 0)
            //                    delegate?.redo(isRedo: redoAnnotation.count > 0)
            //                }
            //            } else {
            undoAnnotation.append(annotation)
            if let redo = redoAnnotation.popLast() {
                redo.page?.addAnnotation(redo)
                delegate?.undo(isUndo: undoAnnotation.count > 0)
                delegate?.redo(isRedo: redoAnnotation.count > 0)
                //                }
            }
        }
        
    }
    
    func canRedo() -> Bool {
        return redoAnnotation.count > 0
    }
}

class Path {
    var path : UIBezierPath
    var color : UIColor
    var point : CGPoint
    var border : PDFBorder
    var page : PDFPage
    var alpha : CGFloat = 0.0
    var tool : Int = 0
    
    init(path: UIBezierPath, color: UIColor, point: CGPoint, border: PDFBorder, page : PDFPage, alpha : CGFloat, tool : Int) {
        self.path = path
        self.color = color
        self.point = point
        self.border = border
        self.page = page
        self.alpha = alpha
        self.tool = tool
    }
}

class MyPDFAnnotaion : PDFAnnotation {
    open var uuid: String?
    open var status: String?
    open var fileNameCurrent: String?
    open var pageCurrent: PDFPage?
    open var colorCurrent: UIColor?
    open var borderCurrent: PDFBorder?
    open var pathCurrent: UIBezierPath?
    open var pointCurrent: CGPoint?
    open var alphaCurrent: CGFloat?
    open var StringPointCurrent : String?
    open var toolCurrent: String?
}

