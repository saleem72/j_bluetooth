package com.jafra.j_bluetooth.data.mappers

import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import com.jafra.j_bluetooth.domain.models.JBluetoothDevice


private fun getMinorDeviceClass(bluetoothClass: Int): Int {
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
        name = name,
        address = address,
        deviceClass = deviceClass,
        majorDeviceClass = majorDeviceClass,
        minorDeviceClass = minorDeviceClass,

        rssi = rssi?.toInt() ?: 0,
        bond = bond
    )
}


fun JBluetoothDevice.toMap(): HashMap<String, Any> {

    val map = HashMap<String, Any>()

    name?.let { map["name"] = it }
    map["address"] = address
    map["deviceClass"] = deviceClass
    map["majorDeviceClass"] = majorDeviceClass
    map["minorDeviceClass"] = minorDeviceClass
    map["rssi"] = rssi
    map["bond"] = bond
    return map
}