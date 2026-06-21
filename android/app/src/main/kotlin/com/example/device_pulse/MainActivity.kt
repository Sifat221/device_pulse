package com.example.device_pulse

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.net.nsd.NsdServiceInfo
import android.net.wifi.WifiManager
import android.os.BatteryManager
import android.os.Build
import android.telephony.*
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.NetworkInterface
import java.util.*

class MainActivity : FlutterActivity(), SensorEventListener {

    private val CHANNEL = "device.health.channel"

    private var stepCount: Float = 0f
    private var lastStepCount: Float = 0f
    private var activityStatus: String = "Still"

    private lateinit var sensorManager: SensorManager
    private lateinit var socketServer: SocketServer

    private lateinit var nsdService: NsdService
    private lateinit var nsdDiscovery: NsdDiscovery
    private var discoveredDevices = mutableListOf<NsdServiceInfo>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
        stepSensor?.let {
            sensorManager.registerListener(this, it, SensorManager.SENSOR_DELAY_NORMAL)
        }

        socketServer = SocketServer()
        socketServer.startServer { data ->

            println("RECEIVED: $data")

            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .invokeMethod("onDataReceived", data)
        }

        nsdService = NsdService(this)
        nsdDiscovery = NsdDiscovery(this)

        nsdService.registerService(8888)

        nsdDiscovery.discover { devices ->
            discoveredDevices = devices.toMutableList()
            println("FOUND DEVICES: $devices")
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->

                when (call.method) {

                    "getDeviceData" -> {
                        result.success(collectDeviceData())
                    }

                    "getDevices" -> {
                        val list = discoveredDevices.map {
                            mapOf(
                                "name" to it.serviceName,
                                "ip" to it.host.hostAddress
                            )
                        }
                        result.success(list)
                    }

                    "sendToDevice" -> {
                        val index = call.argument<Int>("index")
                        val data = call.argument<String>("data")

                        if (index != null && data != null && index < discoveredDevices.size) {

                            val service = discoveredDevices[index]
                            val host = service.host.hostAddress

                            SocketClient.sendData(host, data)

                            result.success("sent")
                        } else {
                            result.error("ERROR", "Invalid device", null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun collectDeviceData(): Map<String, Any?> {

        val data = HashMap<String, Any?>()

        val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val batteryLevel = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val temp = batteryIntent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
        val batteryTemp = temp / 10.0
        val batteryHealth = if (batteryTemp > 40) "Overheat" else "Good"

        val wifiManager = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val wifiInfo = wifiManager.connectionInfo

        val ssid = wifiInfo.ssid?.replace("\"", "") ?: "Unknown"
        val rssi = wifiInfo.rssi

        val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val carrierName = telephonyManager.networkOperatorName ?: "Unknown"

        val simState = when (telephonyManager.simState) {
            TelephonyManager.SIM_STATE_READY -> "READY"
            TelephonyManager.SIM_STATE_ABSENT -> "ABSENT"
            else -> "UNKNOWN"
        }

        var signalDbm = -1

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
            == PackageManager.PERMISSION_GRANTED
        ) {
            val cellInfoList = telephonyManager.allCellInfo
            if (!cellInfoList.isNullOrEmpty()) {
                val cellInfo = cellInfoList[0]
                signalDbm = when (cellInfo) {
                    is CellInfoLte -> cellInfo.cellSignalStrength.dbm
                    is CellInfoGsm -> cellInfo.cellSignalStrength.dbm
                    else -> -1
                }
            }
        }

        data["batteryLevel"] = batteryLevel
        data["batteryTemp"] = batteryTemp
        data["batteryHealth"] = batteryHealth

        data["steps"] = stepCount.toInt()
        data["activity"] = activityStatus

        data["wifiSSID"] = ssid
        data["wifiRSSI"] = rssi
        data["ipAddress"] = getLocalIpAddress()

        data["deviceModel"] = Build.MODEL
        data["androidVersion"] = Build.VERSION.RELEASE
        data["deviceName"] = "${Build.MANUFACTURER} ${Build.MODEL}"

        data["carrier"] = carrierName
        data["simState"] = simState
        data["signalDbm"] = signalDbm

        return data
    }

    override fun onSensorChanged(event: SensorEvent?) {
        if (event == null) return

        if (event.sensor.type == Sensor.TYPE_STEP_COUNTER) {
            val currentSteps = event.values[0]

            activityStatus = if (currentSteps > lastStepCount) "Walking" else "Still"

            lastStepCount = currentSteps
            stepCount = currentSteps
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}

    private fun getLocalIpAddress(): String? {
        try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            for (intf in Collections.list(interfaces)) {
                for (addr in Collections.list(intf.inetAddresses)) {
                    if (!addr.isLoopbackAddress && addr.hostAddress.indexOf(':') < 0) {
                        return addr.hostAddress
                    }
                }
            }
        } catch (e: Exception) {}
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(this)
    }
}