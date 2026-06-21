package com.example.device_pulse

import java.net.ServerSocket
import kotlin.concurrent.thread

class SocketServer {

    fun startServer(onDataReceived: (String) -> Unit) {

        thread {
            val serverSocket = ServerSocket(8888)

            while (true) {
                val client = serverSocket.accept()

                val input = client.getInputStream().bufferedReader()
                val data = input.readLine()

                onDataReceived(data)

                client.close()
            }
        }
    }
}