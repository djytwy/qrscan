import Flutter
import UIKit
import AVFoundation

public class SwiftQrscanPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, ScanType {

    var eventSink: FlutterEventSink?
    static let ph = PermissionHandler()


    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "io.isa.flutter.plugin.qrscan.channel", binaryMessenger: registrar.messenger())
        let instance = SwiftQrscanPlugin()

        registrar.addMethodCallDelegate(instance, channel: channel)
        let sink = FlutterEventChannel(name: "io.isa.flutter.plugin.qrscan.sink", binaryMessenger: registrar.messenger())
        sink.setStreamHandler(instance)

        let event = FlutterEventChannel(name: "io.isa.flutter.plugin.qrscan.permission.sink", binaryMessenger: registrar.messenger())
        event.setStreamHandler(ph)
        let flutterViewId = "ScanView"
        registrar.register(ScanViewFactory(delegate: instance), withId: flutterViewId)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "close" {
            NotificationCenter.default.post(Notification(name: Notification.Name.stopRunning))
        }
        if call.method == "onBuildFinish" {
            NotificationCenter.default.post(Notification(name: Notification.Name.startRunning))
        }

        if call.method == "scanImagePath" {
            NotificationCenter.default.post(name: Notification.Name.scanImagePath, object: nil, userInfo: ["arguments":call.arguments ?? ""])
        }
    }

    func didScanResult(_ result: String) {
        if let sink = eventSink {
            sink(result)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil;
        return nil
    }
}


class PermissionHandler: NSObject, FlutterStreamHandler {

    var permissionSink: FlutterEventSink?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.permissionDenied, object: nil, queue: OperationQueue.main) { [weak self] noti in
            if let sink = self?.permissionSink {
                if let m = noti.object as? ScanErrorCode {
                    sink(m.rawValue)
                }

            }
        }
    }


    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        permissionSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        permissionSink = nil;
        return nil
    }


}
