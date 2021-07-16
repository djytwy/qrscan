package android.src.main.kotlin.com.example.qrscan

import android.content.Context
import android.util.Log
import android.view.View
import com.journeyapps.barcodescanner.BarcodeView
import com.journeyapps.barcodescanner.DecoratedBarcodeView
import io.flutter.plugin.platform.PlatformView


class ScanView(context: Context) : PlatformView {

    private val TAG: String = "ScanView"

//    val contentView: DecoratedBarcodeView = DecoratedBarcodeView(context)
    val contentView: BarcodeView = BarcodeView(context)


    override fun getView(): View {
        Log.d(TAG, "getView")
        return contentView
    }

    override fun dispose() {
        contentView.pause()
    }
}