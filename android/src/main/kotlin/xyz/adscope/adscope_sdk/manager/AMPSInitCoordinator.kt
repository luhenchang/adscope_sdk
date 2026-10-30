package xyz.adscope.adscope_sdk.manager

import xyz.adscope.adscope_sdk.data.AMPSInitChannelMethod
import xyz.adscope.adscope_sdk.data.ErrorModel
import xyz.adscope.amps.common.AMPSError
import xyz.adscope.amps.init.inter.IAMPSInitCallback
import java.util.WeakHashMap

/** The native SDK is process-wide; share only its in-flight initialization attempt. */
internal object AMPSInitCoordinator {
    private class Attempt {
        val owners = WeakHashMap<AMPSEventManager, Unit>()
    }
    private var pending: Attempt? = null

    fun request(owner: AMPSEventManager, start: (IAMPSInitCallback) -> Unit) {
        val attempt = synchronized(this) {
            if (owner.isReleased) return
            pending?.let { it.owners[owner] = Unit; return }
            Attempt().also { it.owners[owner] = Unit; pending = it }
        }
        val callback = object : IAMPSInitCallback {
            override fun successCallback() {
                complete(attempt, AMPSInitChannelMethod.INIT_SUCCESS, null)
            }
            override fun failCallback(error: AMPSError?) {
                complete(attempt, AMPSInitChannelMethod.INIT_FAILED, mapOf(
                    ErrorModel.CODE to (error?.code?.toIntOrNull() ?: -1),
                    ErrorModel.MESSAGE to error?.message
                ))
            }
        }
        try {
            start(callback)
        } catch (error: Exception) {
            complete(attempt, AMPSInitChannelMethod.INIT_FAILED, mapOf(
                ErrorModel.CODE to -1, ErrorModel.MESSAGE to error.message
            ))
        }
    }

    @Synchronized fun detach(owner: AMPSEventManager) {
        pending?.owners?.remove(owner)
    }

    private fun complete(attempt: Attempt, method: String, args: Any?) {
        val owners = synchronized(this) {
            // Some SDK implementations can deliver a late timeout after completion.
            if (pending !== attempt) return
            pending = null
            attempt.owners.keys.toList().also { attempt.owners.clear() }
        }
        owners.forEach { it.sendMessageToFlutter(method, args) }
    }
}
