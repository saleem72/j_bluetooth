package com.jafra.j_bluetooth.data.helpers

import android.app.ActivityManager
import android.content.ContentResolver
import android.content.pm.FeatureInfo
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.provider.Settings

internal class DeviceInfoHelper(
    private val packageManager: PackageManager,
    private val activityManager: ActivityManager,
    private val contentResolver: ContentResolver,
) {

    public fun getBuild(): MutableMap<String, Any>  {
        val build: MutableMap<String, Any> = HashMap()

        build["board"] = Build.BOARD
        build["bootloader"] = Build.BOOTLOADER
        build["brand"] = Build.BRAND
        build["device"] = Build.DEVICE
        build["display"] = Build.DISPLAY
        build["fingerprint"] = Build.FINGERPRINT
        build["hardware"] = Build.HARDWARE
        build["host"] = Build.HOST
        build["id"] = Build.ID
        build["manufacturer"] = Build.MANUFACTURER
        build["model"] = Build.MODEL
        build["product"] = Build.PRODUCT

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            build["name"] = Settings.Global.getString(contentResolver, Settings.Global.DEVICE_NAME) ?: ""
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            build["supported32BitAbis"] = listOf(*Build.SUPPORTED_32_BIT_ABIS)
            build["supported64BitAbis"] = listOf(*Build.SUPPORTED_64_BIT_ABIS)
            build["supportedAbis"] = listOf<String>(*Build.SUPPORTED_ABIS)
        } else {
            build["supported32BitAbis"] = emptyList<String>()
            build["supported64BitAbis"] = emptyList<String>()
            build["supportedAbis"] = emptyList<String>()
        }

        build["tags"] = Build.TAGS
        build["type"] = Build.TYPE
        build["isPhysicalDevice"] = !isEmulator
        build["systemFeatures"] = getSystemFeatures()

        val statFs = StatFs(Environment.getDataDirectory().path)
        build["freeDiskSize"] = statFs.freeBytes
        build["totalDiskSize"] = statFs.totalBytes

        val version: MutableMap<String, Any> = HashMap()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            version["baseOS"] = Build.VERSION.BASE_OS
            version["previewSdkInt"] = Build.VERSION.PREVIEW_SDK_INT
            version["securityPatch"] = Build.VERSION.SECURITY_PATCH
        }
        version["codename"] = Build.VERSION.CODENAME
        version["incremental"] = Build.VERSION.INCREMENTAL
        version["release"] = Build.VERSION.RELEASE
        version["sdkInt"] = Build.VERSION.SDK_INT
        build["version"] = version

        val memoryInfo: ActivityManager.MemoryInfo = ActivityManager.MemoryInfo()
        activityManager.getMemoryInfo(memoryInfo)
        build["isLowRamDevice"] = memoryInfo.lowMemory
        build["physicalRamSize"] = memoryInfo.totalMem / 1048576L // Mb
        build["availableRamSize"] = memoryInfo.availMem / 1048576L // Mb

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            build["serialNumber"] = try {
                Build.getSerial()
            } catch (ex: SecurityException) {
                Build.UNKNOWN
            }
        } else {
            build["serialNumber"] = "" // Build.SERIAL
        }

        return  build
    }


    private fun getSystemFeatures(): List<String> {
        val featureInfos: Array<FeatureInfo> = packageManager.systemAvailableFeatures
        return featureInfos
            .filterNot { featureInfo -> featureInfo.name == null }
            .map { featureInfo -> featureInfo.name }
    }

    /**
     * A simple emulator-detection based on the flutter tools detection logic and a couple of legacy
     * detection systems
     */
    private val isEmulator: Boolean
        get() = ((Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic"))
                || Build.FINGERPRINT.startsWith("generic")
                || Build.FINGERPRINT.startsWith("unknown")
                || Build.HARDWARE.contains("goldfish")
                || Build.HARDWARE.contains("ranchu")
                || Build.MODEL.contains("google_sdk")
                || Build.MODEL.contains("Emulator")
                || Build.MODEL.contains("Android SDK built for x86")
                || Build.MANUFACTURER.contains("Genymotion")
                || Build.PRODUCT.contains("sdk")
                || Build.PRODUCT.contains("vbox86p")
                || Build.PRODUCT.contains("emulator")
                || Build.PRODUCT.contains("simulator"))
}