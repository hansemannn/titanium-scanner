//
//  TiScannerModule.swift
//  titanium-scanner
//
//  Created by Your Name
//  Copyright (c) 2021 Your Company. All rights reserved.
//

import UIKit
import TitaniumKit
import Vision
import VisionKit
import PDFKit

@objc(TiScannerModule)
class TiScannerModule: TiModule {
  
  var _scanner: VNDocumentCameraViewController?

  func scannerInstance() -> VNDocumentCameraViewController {
    if let scanner = _scanner {
      return scanner
    }
    _scanner = VNDocumentCameraViewController()
    _scanner!.delegate = self

    return _scanner!
  }

  var currentScan: VNDocumentCameraScan?
  
  func moduleGUID() -> String {
    return "fc40b436-6d90-4cf0-9627-f56e4321b30f"
  }
  
  override func moduleId() -> String! {
    return "ti.scanner"
  }
  
  func dismissAndCleanup() {
    _scanner?.delegate = nil
    _scanner = nil
  }

  // MARK: Public APIs

  @objc(isSupported:)
  func isSupported(unused: [Any]?) -> Bool {
    return VNDocumentCameraViewController.isSupported
  }

  @objc(showScanner:)
  func showScanner(unused: [Any]?) {
    TiApp.controller().present(scannerInstance(), animated: true, completion: nil)
  }

  @objc(imageOfPageAtIndex:)
  func imageOfPageAtIndex(args: [Any]) -> TiBlob? {
    guard let index = args.first as? Int, let scan = currentScan else { return nil }

    let image = scan.imageOfPage(at: index)
    return TiBlob(image: image)
  }

  @objc(pdfOfPageAtIndex:)
  func pdfOfPageAtIndex(args: [Any]) -> TiBlob? {
    guard let index = args.first as? Int, let scan = currentScan else { return nil }

    let image = scan.imageOfPage(at: index)
    let pdfDocument = PDFDocument()

    if let pdfPage = PDFPage(image: image) {
      pdfDocument.insert(pdfPage, at: 0)
    }

    return TiBlob(data: pdfDocument.dataRepresentation(), mimetype: "application/pdf")
  }
  
  @objc(pdfOfAllPages:)
  func pdfOfAllPages(args: [Any]?) -> TiBlob? {
    guard let scan = currentScan else { return nil }

    var resizeImages = false
    var padding = 80

    if let params = args?.first as? [String: Any] {
      resizeImages = params["resizeImages"] as? Bool ?? false
      padding = params["padding"] as? Int ?? 80
    }
    
    let pdfDocument = PDFDocument()

    for index in 0...scan.pageCount - 1 {
      let image = scan.imageOfPage(at: index)

      if resizeImages {
        // Get the raw data representation
        if let pdfData = A4PDFDataFromCentered(image: image, with: Float(padding)) {
          // Generate a PDF document from the raw data
          if let pdfDataDocument = PDFDocument(data: pdfData) {
            // Get the page from the generate document
            if let pdfPage = pdfDataDocument.page(at: 0) {
              // Add the generated page to the actual document
              pdfDocument.insert(pdfPage, at: index)
            }
          }
        }
      } else {
        if let pdfPage = PDFPage(image: image) {
          pdfDocument.insert(pdfPage, at: index)
        }
      }
    }
    
    return TiBlob(data: pdfDocument.dataRepresentation(), mimetype: "application/pdf")
  }
}

// MARK: VNDocumentCameraViewControllerDelegate

extension TiScannerModule: VNDocumentCameraViewControllerDelegate {
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    fireEvent("cancel")

    controller.dismiss(animated: true, completion: nil)
    dismissAndCleanup()
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
    fireEvent("error", with: ["error": error.localizedDescription])
    
    controller.dismiss(animated: true, completion: nil)
    dismissAndCleanup()
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    currentScan = scan

    fireEvent("success", with: ["count": scan.pageCount, "title": scan.title])
    
    controller.dismiss(animated: true, completion: nil)
    dismissAndCleanup()
  }
}

// MARK: Utils to generate a centered image

extension TiScannerModule {
  func A4PDFDataFromCentered(image: UIImage, with padding: Float) -> Data? {
    let A4_WIDTH: Float = 595.2
    let A4_HEIGHT: Float = 841.8

    // Prepare raw data
    let pdfData = NSMutableData()
    let pdfConsumer = CGDataConsumer(data: pdfData as CFMutableData)!
    
    // Calculate the aspect ratio
    let imageWidth = A4_WIDTH - (padding * 2)
    let imageHeight = round(CGFloat(imageWidth) * (image.size.height / image.size.width))

    // Calculate the bounces
    var mediaBox = CGRect(x: 0,
                          y: 0,
                          width: CGFloat(A4_WIDTH),
                          height: CGFloat(A4_HEIGHT)); // A4

    let imageBox = CGRect(x: CGFloat((A4_WIDTH / 2) - (imageWidth / 2)),
                          y: (CGFloat(A4_HEIGHT) / 2) - (imageHeight / 2),
                          width: CGFloat(imageWidth),
                          height: CGFloat(imageHeight))

    // Create the context to draw in
    let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)!
    
    // Perform the drawing
    pdfContext.beginPage(mediaBox: &mediaBox)
    pdfContext.draw(image.cgImage!, in: imageBox)
    pdfContext.endPage()
    pdfContext.closePDF()

    return pdfData as Data
  }
}
