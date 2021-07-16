package android.src.main.kotlin.com.example.qrscan

enum class ScanErrorCode(var code : Int){
     permissionDenied(0),
     notSupport(1)
}