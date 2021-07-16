package android.src.main.kotlin.com.example.qrscan

import android.content.Context
import android.net.Uri
import android.os.Build
import android.util.Log
import com.example.qrscan.BitmapUtil
import com.example.qrscan.CameraPermissions
import com.example.qrscan.QrCodeResultCallback
import com.google.zxing.*
import com.google.zxing.common.HybridBinarizer
import com.google.zxing.qrcode.QRCodeReader
import com.journeyapps.barcodescanner.BarcodeCallback
import com.journeyapps.barcodescanner.BarcodeResult
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.io.File
import java.util.*


class ScanViewFactory(qrCodeResultCallback: QrCodeResultCallback?) : PlatformViewFactory(StandardMessageCodec.INSTANCE), CameraPermissions.ResultCallback {

    private val TAG: String = "ScanViewFactory"

    private var activityPluginBinding: ActivityPluginBinding? = null

//    private var beepManager: BeepManager? = null
    private var scanView: ScanView? = null
    private val qrCodeResultCallback: QrCodeResultCallback? = qrCodeResultCallback

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(TAG, "create")

        scanView = ScanView(context)
        scanView?.contentView?.id = viewId

        scanView?.contentView?.decodeContinuous(callback)

//        beepManager = BeepManager(activityPluginBinding?.activity)
        scanView?.contentView?.resume()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CameraPermissions().requestPermissions(activityPluginBinding?.activity, activityPluginBinding, this)
        }

        return scanView as ScanView
    }

    fun setActivity(activityPluginBinding: ActivityPluginBinding) {
        this.activityPluginBinding = activityPluginBinding
    }

    fun close() {
        scanView?.contentView?.pause()
//        this.activityPluginBinding = null
    }

    fun resume() {
        scanView?.contentView?.resume()
    }

    fun pause() {
        scanView?.contentView?.pause()
    }

    //扫描结果回调
    private val callback: BarcodeCallback = object : BarcodeCallback {
        override fun barcodeResult(result: BarcodeResult) {
            if (result.text == null) {
                // Prevent duplicate scans
                return
            }
            qrCodeResultCallback?.barcodeResult(result.text)
//            beepManager?.playBeepSoundAndVibrate()
        }

        override fun possibleResultPoints(resultPoints: List<ResultPoint>) {}
    }

    fun scanImagePath(result: String) {
        Log.d(TAG, "create$result")
        val uri = Uri.fromFile(File(result))
        val scanningImage = scanningImage(uri)
        if (scanningImage!=null){
            qrCodeResultCallback?.barcodeResult(scanningImage.text)
        }
    }

    fun switchFlashlight(on: Boolean?) {
        if (on == true) {
            scanView?.contentView?.setTorch(true)
        } else {
            scanView?.contentView?.setTorch(false)
        }
    }

    /**
     * 扫描二维码图片的方法
     * @param path
     * @return
     */
    fun scanningImage(uri: Uri?): Result? {
        if (uri == null) {
            return null
        }
        val hints: Hashtable<DecodeHintType, String?> = Hashtable()
        hints[DecodeHintType.CHARACTER_SET] = "UTF8" //设置二维码内容的编码
        val scanBitmap = BitmapUtil.decodeUri(activityPluginBinding?.activity, uri, 500, 500)
        val width = scanBitmap.width
        val height = scanBitmap.height
        val pixels = IntArray(width * height)
        scanBitmap.getPixels(pixels, 0, width, 0, 0, width, height)
        val source = RGBLuminanceSource(width, height, pixels)
        val bitmap1 = BinaryBitmap(HybridBinarizer(source))
        val reader = QRCodeReader()
        try {
            return reader.decode(bitmap1, hints)
        } catch (e: NotFoundException) {
            e.printStackTrace()
        } catch (e: ChecksumException) {
            e.printStackTrace()
        } catch (e: FormatException) {
            e.printStackTrace()
        }
        return null
    }


    //权限结果
    override fun onResult(errorCode: ScanErrorCode?, errorDescription: String?) {
        if (errorCode == null) {
            resume()
        } else {
            qrCodeResultCallback?.permission(errorCode)
        }
    }



}