package br.com.se7esistemassinop.exp

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "br.com.se7esistemassinop.exp/barcode_broadcast"
        ).setStreamHandler(BarcodeBroadcastStreamHandler(this))
    }
}
