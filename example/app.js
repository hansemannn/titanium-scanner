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
        Scanner.showScanner({});
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

    var win2 = Ti.UI.createWindow({ backgroundColor: '#333' });
    var image = Ti.UI.createImageView({ height: '70%', image: Scanner.imageOfPageAtIndex(0) /* Or many images via "event.count" */ });

    win2.add(image);
    win2.open();
});

win.add(btn);
win.open();
