//
//  ScanFactroyView.swift
//  qrscan
//
//  Created by 斌王 on 2020/11/20.
//

import Foundation
import Flutter

class ScanViewFactory: NSObject, FlutterPlatformViewFactory {

    weak var delegate: ScanType?

    init(delegate: ScanType) {
        super.init()
        self.delegate = delegate;
    }


    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let view = ScanView.init(frame: frame, delegate: delegate)
        view.delegate = delegate
        return view
    }

}
