package com.jafra.j_bluetooth.data.mappers

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import com.jafra.j_bluetooth.domain.models.JBluetoothDevice
import io.flutter.Log


fun getMinorDeviceClass(bluetoothClass: Int): Int {
    return bluetoothClass and 0x0000FFFF
}

@SuppressLint("MissingPermission")
fun BluetoothDevice.toJafraBluetoothDevice(): JBluetoothDevice {
    val deviceClass = this.bluetoothClass.deviceClass
    val majorDeviceClass = bluetoothClass.majorDeviceClass
    val minorDeviceClass = getMinorDeviceClass(deviceClass)
    Log.d("JBluetoothPlugin", "Device: $deviceClass")
    return JBluetoothDevice(
        name = name ?: "No Name",
        address = address,
        deviceClass = deviceClass,
        majorDeviceClass = majorDeviceClass,
        minorDeviceClass = minorDeviceClass,
    )
}


fun JBluetoothDevice.toMap(): HashMap<String, Any> {

    val map = HashMap<String, Any>()

    map["name"] = name
    map["address"] = address
    map["deviceClass"] = deviceClass
    map["majorDeviceClass"] = majorDeviceClass
    map["minorDeviceClass"] = minorDeviceClass

    return map
}