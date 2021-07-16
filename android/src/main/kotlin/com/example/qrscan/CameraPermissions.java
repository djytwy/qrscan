package com.example.qrscan;

import android.Manifest;
import android.Manifest.permission;
import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Build;
import android.src.main.kotlin.com.example.qrscan.ScanErrorCode;

import androidx.annotation.RequiresApi;
import androidx.annotation.VisibleForTesting;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.PluginRegistry;

@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public class CameraPermissions {

    public interface ResultCallback {
        void onResult(ScanErrorCode errorCode, String errorDescription);
    }

    private static final int CAMERA_REQUEST_ID = 6996;
    private boolean ongoing = false;

    public void requestPermissions(
            Activity activity,
            ActivityPluginBinding binding,
            ResultCallback callback) {

        if (!hasCamera(activity)) {
            callback.onResult(ScanErrorCode.notSupport, "This device does not have any cameras");
        }

        if (ongoing) {
//            callback.onResult(ScanErrorCode.permissionDenied, "Camera permission request ongoing");
        }
        if (!hasCameraPermission(activity)) {
            binding.addRequestPermissionsResultListener(
                    new CameraRequestPermissionsListener(
                            (ScanErrorCode errorCode, String errorDescription) -> {
                                ongoing = false;
                                callback.onResult(errorCode, errorDescription);
                            }));
            ongoing = true;
            ActivityCompat.requestPermissions(
                    activity, new String[]{Manifest.permission.CAMERA},
                    CAMERA_REQUEST_ID);
        } else {
            // Permissions already exist. Call the callback with success.
            callback.onResult(null, null);
        }
    }

    private boolean hasCameraPermission(Activity activity) {
        return ContextCompat.checkSelfPermission(activity, permission.CAMERA)
                == PackageManager.PERMISSION_GRANTED;
    }

    @VisibleForTesting
    @SuppressWarnings("deprecation")
    static final class CameraRequestPermissionsListener
            implements PluginRegistry.RequestPermissionsResultListener {

        // There's no way to unregister permission listeners in the v1 embedding, so we'll be called
        // duplicate times in cases where the user denies and then grants a permission. Keep track of if
        // we've responded before and bail out of handling the callback manually if this is a repeat
        // call.
        boolean alreadyCalled = false;

        final ResultCallback callback;

        @VisibleForTesting
        CameraRequestPermissionsListener(ResultCallback callback) {
            this.callback = callback;
        }

        @Override
        public boolean onRequestPermissionsResult(int id, String[] permissions, int[] grantResults) {
            if (alreadyCalled || id != CAMERA_REQUEST_ID) {
                return false;
            }

            alreadyCalled = true;
            if (grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                callback.onResult(ScanErrorCode.permissionDenied, "MediaRecorderCamera permission not granted");
            } else {
                callback.onResult(null, null);
            }
            return true;
        }
    }

    //是否有相机
    private boolean hasCamera(Activity activity) {
        PackageManager pm = activity.getPackageManager();
        // FEATURE_CAMERA - 后置相机
        // FEATURE_CAMERA_FRONT - 前置相机
        if (!pm.hasSystemFeature(PackageManager.FEATURE_CAMERA)
                && !pm.hasSystemFeature(PackageManager.FEATURE_CAMERA_FRONT)) {
            return false;
        } else {
            return true;
        }
    }
}