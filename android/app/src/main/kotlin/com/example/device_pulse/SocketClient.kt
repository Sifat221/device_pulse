package com.example.device_pulse

import java.net.Socket

object SocketClient {

    fun sendData(ip: String, data: String) {
        Thread {
            try {
                val socket = Socket(ip, 8888)

                val output = socket.getOutputStream()
                output.write((data + "\n").toByteArray())

                socket.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }.start()
    }
}