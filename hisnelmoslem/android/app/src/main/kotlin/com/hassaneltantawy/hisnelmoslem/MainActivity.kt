package com.hassaneltantawy.hisnelmoslem

import io.flutter.embedding.android.FlutterActivity
import android.view.KeyEvent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "volume_button_channel")
    }


    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        val action: Int = event.getAction()
        val keyCode: Int = event.getKeyCode()
        return when (keyCode) {
            KeyEvent.KEYCODE_VOLUME_UP -> {
                if (action == KeyEvent.ACTION_DOWN) {
                    channel.invokeMethod("volumeBtnPressed", "VOLUME_UP_DOWN")
                } else if (action == KeyEvent.ACTION_UP) {
                    channel.invokeMethod("volumeBtnPressed", "VOLUME_UP_UP")
                }
                true
            }
            KeyEvent.KEYCODE_VOLUME_DOWN -> {
                if (action == KeyEvent.ACTION_DOWN) {
                    channel.invokeMethod("volumeBtnPressed", "VOLUME_DOWN_DOWN")
                } else if (action == KeyEvent.ACTION_UP) {
                    channel.invokeMethod("volumeBtnPressed", "VOLUME_DOWN_UP")
                }
                true
            }

            else -> super.dispatchKeyEvent(event)
        }
    }
}
