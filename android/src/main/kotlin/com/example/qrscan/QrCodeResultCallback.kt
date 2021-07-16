package com.example.qrscan

import android.src.main.kotlin.com.example.qrscan.ScanErrorCode


interface QrCodeResultCallback {
    fun barcodeResult(result: String?)
    fun permission(result: ScanErrorCode?)
}