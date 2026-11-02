import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    // Sadece telefon boyutuna kadar küçültmeye izin ver (En küçük: standart telefon 390 x 680)
    let minPhoneWidth: CGFloat = 390
    let minPhoneHeight: CGFloat = 680
    self.minSize = NSSize(width: minPhoneWidth, height: minPhoneHeight)

    // Pencere ilk açıldığında telefon boyutundan daha küçükse standart mobil boyuta ayarla
    var windowFrame = self.frame
    if windowFrame.size.width < minPhoneWidth || windowFrame.size.height < minPhoneHeight {
      windowFrame.size.width = max(windowFrame.size.width, 414)
      windowFrame.size.height = max(windowFrame.size.height, 800)
    }
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
