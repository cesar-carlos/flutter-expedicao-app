package br.com.se7esistemassinop.exp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.EventChannel

class BarcodeBroadcastStreamHandler(
  private val context: Context,
) : EventChannel.StreamHandler {

  companion object {
    private const val TAG = "BarcodeBroadcast"
    private const val DEFAULT_ACTION = "com.scanner.BARCODE"
    private const val DEFAULT_EXTRA_KEY = "data"
  }

  private var receiver: BroadcastReceiver? = null
  private var eventSink: EventChannel.EventSink? = null

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    unregisterReceiverIfNeeded()

    eventSink = events
    val args = arguments as? Map<*, *>
    val listenAction = ((args?.get("action") as? String) ?: DEFAULT_ACTION).trim()
    val listenExtraKey = ((args?.get("extraKey") as? String) ?: DEFAULT_EXTRA_KEY).trim()

    if (listenAction.isBlank() || listenExtraKey.isBlank()) {
      eventSink?.error(
        "INVALID_SCANNER_BROADCAST_CONFIG",
        "Scanner broadcast action and extraKey must not be empty.",
        null
      )
      eventSink = null
      return
    }

    if (listenAction == DEFAULT_ACTION && listenExtraKey == DEFAULT_EXTRA_KEY) {
      Log.w(
        TAG,
        "Using default scanner broadcast action/extraKey. Configure device-specific values when supported."
      )
    }

    receiver = object : BroadcastReceiver() {
      override fun onReceive(ctx: Context?, intent: Intent?) {
        if (intent == null) return
        if (intent.action != listenAction) return
        val code = intent.getStringExtra(listenExtraKey) ?: return
        eventSink?.success(code)
      }
    }

    val filter = IntentFilter(listenAction)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      // Exportado para aceitar broadcasts de apps/serviços externos do coletor.
      context.registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
    } else {
      context.registerReceiver(receiver, filter)
    }
  }

  override fun onCancel(arguments: Any?) {
    unregisterReceiverIfNeeded()
    eventSink = null
  }

  private fun unregisterReceiverIfNeeded() {
    val currentReceiver = receiver ?: return
    try {
      context.unregisterReceiver(currentReceiver)
    } catch (_: IllegalArgumentException) {
      // Receiver already unregistered; onCancel/onListen can be repeated.
    } finally {
      receiver = null
    }
  }
}
