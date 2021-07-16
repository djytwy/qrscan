//
//  ScanType.swift
//  qrscan
//
//  Created by 斌王 on 2020/11/23.
//

import Foundation

enum ScanErrorCode: Int {
    case permissionDenied = 0
    case notSupport = 1
}

public enum ScanNotification {
    public static let startRunning = "ScanNotification.startRunning"
    public static let stopRunning = "ScanNotification.stopRunning"
    public static let permissionDenied = "ScanNotification.permissionDenied"
    public static let scanImagePath = "ScanNotification.scanImagePath"

}

extension NSNotification.Name {
    public static let startRunning = NSNotification.Name.init(ScanNotification.startRunning)
    public static let stopRunning = NSNotification.Name.init(ScanNotification.stopRunning)
    public static let permissionDenied = NSNotification.Name.init(ScanNotification.permissionDenied)
    public static let scanImagePath = NSNotification.Name.init(ScanNotification.scanImagePath)
}

protocol ScanType: class {
    func didScanResult(_ result: String);
}
