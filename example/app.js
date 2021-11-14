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
        console.warn('SUPPORTED: ' + Scanner.isSupported());
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

    showAllPages();
    
    // Uncomment to test the "imageOfPageAtIndex" function
    //
    // showSinglePage();
});

win.add(btn);
win.open();

function showSinglePage() {
    var win2 = Ti.UI.createWindow({ backgroundColor: '#333' });
    var image = Ti.UI.createImageView({ height: '70%', image: Scanner.imageOfPageAtIndex(0) /* Or many images via "event.count" */ });

    win2.add(image);
    win2.open();
}

function showAllPages() {
    const pdf = Scanner.pdfOfAllPages({ resizeImages: true, padding: 80 });
    const file = Ti.Filesystem.getFile(Ti.Filesystem.applicationCacheDirectory, 'test.pdf');
    file.write(pdf);

    setTimeout(() => {
        Ti.UI.iOS.createDocumentViewer({
            url: file.nativePath
        }).show();
    }, 1000);
}