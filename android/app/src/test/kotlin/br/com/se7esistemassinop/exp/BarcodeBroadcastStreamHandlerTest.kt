package br.com.se7esistemassinop.exp

import android.content.Context
import android.content.Intent
import android.content.BroadcastReceiver
import androidx.test.core.app.ApplicationProvider
import io.flutter.plugin.common.EventChannel
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.annotation.Config
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34], manifest = Config.NONE)
class BarcodeBroadcastStreamHandlerTest {
  private lateinit var context: Context
  private lateinit var handler: BarcodeBroadcastStreamHandler

  @Before
  fun setUp() {
    context = ApplicationProvider.getApplicationContext()
    handler = BarcodeBroadcastStreamHandler(context)
  }

  @Test
  fun onListenRejectsBlankActionAndCanRelistenWithValidConfig() {
    val invalidSink = RecordingEventSink()

    handler.onListen(mapOf("action" to "", "extraKey" to "data"), invalidSink)

    assertEquals("INVALID_SCANNER_BROADCAST_CONFIG", invalidSink.errors.single().code)

    val validSink = RecordingEventSink()
    handler.onListen(mapOf("action" to "com.test.SCAN", "extraKey" to "data"), validSink)
    currentReceiver().onReceive(context, Intent("com.test.SCAN").putExtra("data", "ABC-123"))

    assertEquals(listOf("ABC-123"), validSink.successes)
  }

  @Test
  fun onListenRejectsBlankExtraKey() {
    val sink = RecordingEventSink()

    handler.onListen(mapOf("action" to "com.test.SCAN", "extraKey" to " "), sink)

    assertEquals("INVALID_SCANNER_BROADCAST_CONFIG", sink.errors.single().code)
  }

  @Test
  fun onCancelIsIdempotent() {
    val sink = RecordingEventSink()
    handler.onListen(mapOf("action" to "com.test.SCAN", "extraKey" to "data"), sink)

    handler.onCancel(null)
    handler.onCancel(null)

    currentReceiverOrNull()?.onReceive(context, Intent("com.test.SCAN").putExtra("data", "IGNORED"))
    assertTrue(sink.successes.isEmpty())
  }

  @Test
  fun secondOnListenReplacesPreviousReceiver() {
    val firstSink = RecordingEventSink()
    val secondSink = RecordingEventSink()

    handler.onListen(mapOf("action" to "com.test.OLD", "extraKey" to "data"), firstSink)
    handler.onListen(mapOf("action" to "com.test.NEW", "extraKey" to "barcode"), secondSink)

    val activeReceiver = currentReceiver()
    activeReceiver.onReceive(context, Intent("com.test.OLD").putExtra("data", "OLD"))
    activeReceiver.onReceive(context, Intent("com.test.NEW").putExtra("barcode", "NEW"))

    assertTrue(firstSink.successes.isEmpty())
    assertEquals(listOf("NEW"), secondSink.successes)
  }

  private fun currentReceiver(): BroadcastReceiver {
    return requireNotNull(currentReceiverOrNull())
  }

  private fun currentReceiverOrNull(): BroadcastReceiver? {
    val field = BarcodeBroadcastStreamHandler::class.java.getDeclaredField("receiver")
    field.isAccessible = true
    return field.get(handler) as? BroadcastReceiver
  }

  private class RecordingEventSink : EventChannel.EventSink {
    val successes = mutableListOf<Any?>()
    val errors = mutableListOf<SinkError>()
    var ended = false

    override fun success(event: Any?) {
      successes.add(event)
    }

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
      errors.add(SinkError(errorCode, errorMessage, errorDetails))
    }

    override fun endOfStream() {
      ended = true
    }
  }

  private data class SinkError(
    val code: String,
    val message: String?,
    val details: Any?,
  )
}
