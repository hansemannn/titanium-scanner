/**
 * titanium-scanner
 *
 * Created by Your Name
 * Copyright (c) 2019 Your Company. All rights reserved.
 */

#import <Vision/Vision.h>
#import <VisionKit/VisionKit.h>
#import "TiModule.h"

@interface TiScannerModule : TiModule<VNDocumentCameraViewControllerDelegate> {
  VNDocumentCameraViewController *_scannerViewController;
  VNDocumentCameraScan *_currentScan;
}

- (NSNumber *)isSupported:(id)unused;

- (void)showScanner:(id)value;

- (TiBlob *)imageOfPageAtIndex:(id)index;

- (TiBlob *)pdfOfPageAtIndex:(id)index;

- (TiBlob *)pdfOfAllPages:(id)unused;

@end
