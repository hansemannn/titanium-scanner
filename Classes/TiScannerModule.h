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

@end
