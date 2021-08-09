# Titanium iOS 13+ Document Scanner

Use the iOS 13+ `VisionKit` document scanner API in Appcelerator Titanium. Pro tip: Combine with
[Ti.Vision](https://github.com/hansemannn/titanium-vision) to apply machine learning to the detected
document.

<img src="./example.gif" width="400" />

## Requirements

- [x] iOS 13+
- [x] Titanium SDK 8.2.0+
- [x] Granted camera permissions

## APIs

### Methods

- [x] `showScanner`
- [x] `imageOfPageAtIndex(index)` (after the `success` event)
- [x] `pdfOfPageAtIndex(index)` (after the `success` event)
- [x] `pdfOfAllPages()` (after the `success` event)

### Events

- [x] `success`
- [x] `error`
- [x] `cancel`

## Example

```js
import Scanner from 'ti.scanner';

const win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

const btn = Ti.UI.createButton({
    title: 'Scan Document'
});

btn.addEventListener('click', () => {
    Ti.Media.requestCameraPermissions(event => {
        if (!event.success) {
            alert('No camera permissions');
            return;
        }
        Scanner.showScanner();
    });
});

Scanner.addEventListener('cancel', () => {
    Ti.API.warn('Cancelled …');
});

Scanner.addEventListener('error', event => {
    Ti.API.error('Errored …');
    Ti.API.error(event.error);
});

Scanner.addEventListener('success', event => {
    Ti.API.warn('Succeeded …');
    Ti.API.warn(event);

    const win2 = Ti.UI.createWindow({
        backgroundColor: '#333'
    });

    const image = Ti.UI.createImageView({
        height: '70%',
        image: Scanner.imageOfPageAtIndex(0) /* Or pdfOfPageAtIndex(0) if you need the PDF of it, or many images via "event.count" */
    });

    win2.add(image);
    win2.open();
});

win.add(btn);
win.open();
```

## License

MIT

## Author

Hans Knöchel
