package br.com.se7esistemassinop.exp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import io.flutter.plugin.common.EventChannel

class BarcodeBroadcastStreamHandler(
  private val context: Context,
) : EventChannel.StreamHandler {

  private var receiver: BroadcastReceiver? = null
  private var eventSink: EventChannel.EventSink? = null
  private var action: String = "com.scanner.BARCODE"
  private var extraKey: String = "barcode"

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
    val args = arguments as? Map<*, *>
    action = args?.get("action") as? String ?: action
    extraKey = args?.get("extraKey") as? String ?: extraKey

    receiver = object : BroadcastReceiver() {
      override fun onReceive(ctx: Context?, intent: Intent?) {
        if (intent == null) return
        if (intent.action != action) return
        val code = intent.getStringExtra(extraKey) ?: return
        eventSink?.success(code)
      }
    }

    val filter = IntentFilter(action)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      // Receiver é apenas para o app, não exportado.
      context.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
    } else {
      context.registerReceiver(receiver, filter)
    }
  }

  override fun onCancel(arguments: Any?) {
    receiver?.let { context.unregisterReceiver(it) }
    receiver = null
    eventSink = null
  }
}


