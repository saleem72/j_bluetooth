package com.jafra.j_bluetooth.data.mappers

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import com.jafra.j_bluetooth.domain.models.JBluetoothDevice
import io.flutter.Log


fun getMinorDeviceClass(bluetoothClass: Int): Int {
    return bluetoothClass and 0x0000FFFF
}

@SuppressLint("MissingPermission")
fun BluetoothDevice.toJafraBluetoothDevice(rssi: Short?): JBluetoothDevice {
    val deviceClass = this.bluetoothClass.deviceClass
    val majorDeviceClass = bluetoothClass.majorDeviceClass
    val minorDeviceClass = getMinorDeviceClass(deviceClass)
    val bond = when (bondState) {
        BluetoothDevice.BOND_NONE -> "Not Bonded" // Device is not paired.
        BluetoothDevice.BOND_BONDING -> "Bonding" // Pairing is in progress.
        BluetoothDevice.BOND_BONDED -> "Bonded" // Device is paired.
        else -> "Unknown Bond State" // In case of unexpected state.
    }
    return JBluetoothDevice(
        name = name ?: "No Name",
        address = address,
        deviceClass = deviceClass,
        majorDeviceClass = majorDeviceClass,
        minorDeviceClass = minorDeviceClass,

        rssi = rssi?.toInt() ?: 0
    )
}


fun JBluetoothDevice.toMap(): HashMap<String, Any> {

    val map = HashMap<String, Any>()

    map["name"] = name
    map["address"] = address
    map["deviceClass"] = deviceClass
    map["majorDeviceClass"] = majorDeviceClass
    map["minorDeviceClass"] = minorDeviceClass
    map["rssi"] = rssi

    return map
}