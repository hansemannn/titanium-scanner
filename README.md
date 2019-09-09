# Titanium iOS 13+ Document Scanner

Use the iOS 13+ `VisionKit` document scanner API in Appcelerator Titanium. Pro tip: Combine with
[Ti.Vision](https://github.com/hansemannn/titanium-vision) to apply machine learning to the detected
document.

<img src="./example.gif" width="400" />

## Requirements

- [x] Titanium SDK 8.2.0+
- [x] iOS 13+

## Example

```js
var Scanner = require('ti.scanner');

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

var btn = Ti.UI.createButton({
    title: 'Scan Document'
});

btn.addEventListener('click', function () {
    Ti.Media.requestCameraPermissions(event => {
        if (!event.success) {
            alert('No camera permissions');
            return;
        }
        Scanner.showScanner();
    });
});

Scanner.addEventListener('cancel', function () {
    Ti.API.warn('Cancelled …');
});

Scanner.addEventListener('error', function (event) {
    Ti.API.error('Errored …');
    Ti.API.error(event.error);
});

Scanner.addEventListener('success', function (event) {
    Ti.API.warn('Succeeded …');
    Ti.API.warn(event);

    var win2 = Ti.UI.createWindow({
          backgroundColor: '#333'
    });

    var image = Ti.UI.createImageView({
          height: '70%',
          image: Scanner.imageOfPageAtIndex(0) /* Or many images via "event.pageCount" */
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
