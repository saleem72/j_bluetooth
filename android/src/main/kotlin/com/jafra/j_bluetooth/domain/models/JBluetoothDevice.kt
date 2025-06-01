package com.jafra.j_bluetooth.domain.models

data class JBluetoothDevice(
    val name: String?,
    val address: String,
    val deviceClass : Int,
    val majorDeviceClass : Int,
    val minorDeviceClass : Int,
    val rssi: Int,
    val bond: String,
)
