package com.example.device_pulse

import android.content.Context
import android.net.nsd.*

class NsdDiscovery(private val context: Context) {

    private val SERVICE_TYPE = "_devicepulse._tcp."
    private val nsdManager =
        context.getSystemService(Context.NSD_SERVICE) as NsdManager

    var devices = mutableListOf<NsdServiceInfo>()

    fun discover(onUpdate: (List<NsdServiceInfo>) -> Unit) {

        val listener = object : NsdManager.DiscoveryListener {

            override fun onServiceFound(service: NsdServiceInfo) {
                if (service.serviceType == SERVICE_TYPE) {
                    devices.add(service)
                    onUpdate(devices)
                }
            }

            override fun onServiceLost(service: NsdServiceInfo) {
                devices.remove(service)
                onUpdate(devices)
            }

            override fun onDiscoveryStarted(type: String) {}
            override fun onDiscoveryStopped(type: String) {}
            override fun onStartDiscoveryFailed(type: String, errorCode: Int) {}
            override fun onStopDiscoveryFailed(type: String, errorCode: Int) {}
        }

        nsdManager.discoverServices(
            SERVICE_TYPE,
            NsdManager.PROTOCOL_DNS_SD,
            listener
        )
    }
}