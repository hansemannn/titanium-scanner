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

  lazy var scanner: VNDocumentCameraViewController? = {
    let scannerViewController = VNDocumentCameraViewController()
    scannerViewController.delegate = self

    return scannerViewController
  }()

  var currentScan: VNDocumentCameraScan?
  
  func moduleGUID() -> String {
    return "fc40b436-6d90-4cf0-9627-f56e4321b30f"
  }
  
  override func moduleId() -> String! {
    return "ti.scanner"
  }
  
  func dismissAndCleanup() {
    scanner?.dismiss(animated: true, completion: nil)
    scanner?.delegate = nil
    scanner = nil
  }

  // MARK: Public APIs

  @objc(isSupported:)
  func isSupported(unused: Any) -> Bool {
    return VNDocumentCameraViewController.isSupported
  }

  @objc(showScanner:)
  func showScanner(unused: Any) {
    if let scanner = scanner {
      TiApp.init().showModalController(scanner, animated: true)
    }
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
  func pdfOfAllPages(unused: Any) -> TiBlob? {
    guard let scan = currentScan else { return nil }

    let pdfDocument = PDFDocument()

    for index in 0...scan.pageCount - 1 {
      let image = scan.imageOfPage(at: index)
      if let pdfPage = PDFPage(image: image) {
        pdfDocument.insert(pdfPage, at: index)
      }
    }
    
    return TiBlob(data: pdfDocument.dataRepresentation(), mimetype: "application/pdf")
  }
}

// MARK: VNDocumentCameraViewControllerDelegate

extension TiScannerModule: VNDocumentCameraViewControllerDelegate {
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    fireEvent("cancel")
    dismissAndCleanup()
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
    fireEvent("error", with: ["error": error.localizedDescription])
    dismissAndCleanup()
  }
  
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    fireEvent("success", with: ["count": scan.pageCount, "title": scan.title])
    
    currentScan = scan
    dismissAndCleanup()
  }
}
