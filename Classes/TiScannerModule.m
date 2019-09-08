/**
 * titanium-scanner
 *
 * Created by Your Name
 * Copyright (c) 2019 Your Company. All rights reserved.
 */

#import <TitaniumKit/TitaniumKit.h>
#import "TiScannerModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiScannerModule

#pragma mark Internal

- (id)moduleGUID
{
  return @"558d8ef6-a01d-4474-ac25-777fdecf86a8";
}

- (NSString *)moduleId
{
  return @"ti.scanner";
}

#pragma Public APIs

- (NSNumber *)isSupported:(id)unused
{
  return @(VNDocumentCameraViewController.supported);
}

- (void)showScanner:(id)value
{
  [[TiApp app] showModalController:[self scannerViewController] animated:YES];
}

- (TiBlob *)imageOfPageAtIndex:(id)index
{
  ENSURE_SINGLE_ARG(index, NSNumber);

  if (_currentScan == nil) {
    return nil;
  }

  UIImage *image = [_currentScan imageOfPageAtIndex:[(NSNumber *)index integerValue]];
  TiBlob *blob = [[TiBlob alloc] initWithImage:image];

  return blob;
}

#pragma mark Utils

- (VNDocumentCameraViewController *)scannerViewController
{
  if (_scannerViewController == nil) {
    _scannerViewController = [VNDocumentCameraViewController new];
    _scannerViewController.delegate = self;
  }
  
  return _scannerViewController;
}

#pragma mark VNDocumentCameraViewControllerDelegate

- (void)documentCameraViewControllerDidCancel:(VNDocumentCameraViewController *)controller
{
  [self fireEvent:@"cancel"];
  [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFailWithError:(NSError *)error
{
  [self fireEvent:@"error" withObject:@{ @"error": error.localizedDescription }];
  [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFinishWithScan:(VNDocumentCameraScan *)scan
{
  _currentScan = scan;

  [self fireEvent:@"success" withObject:@{ @"count": @(scan.pageCount), @"title": NULL_IF_NIL(scan.title) }];
  [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
