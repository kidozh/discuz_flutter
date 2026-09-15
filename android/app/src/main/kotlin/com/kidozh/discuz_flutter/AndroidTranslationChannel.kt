package com.kidozh.discuz_flutter

import android.os.Handler
import android.os.Looper
import com.google.mlkit.common.model.DownloadConditions
import com.google.mlkit.nl.languageid.LanguageIdentification
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.Translator
import com.google.mlkit.nl.translate.TranslatorOptions
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

/** Dedicated offline translation, independent of AICore and Gemini Nano. */
class AndroidTranslationChannel(messenger: BinaryMessenger) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "com.kidozh.discuz_flutter/translation")
    private val identifier = LanguageIdentification.getClient()
    private val translators = mutableSetOf<Translator>()
    private var closed = false

    init { channel.setMethodCallHandler(this) }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "languages" -> {
                val locale = call.argument<String>("displayLocale")?.let(Locale::forLanguageTag) ?: Locale.getDefault()
                result.success(TranslateLanguage.getAllLanguages().map {
                    mapOf("id" to it, "name" to Locale.forLanguageTag(it).getDisplayName(locale))
                }.sortedBy { it["name"] })
            }
            "detectLanguage" -> {
                val text = call.argument<String>("text").orEmpty()
                identifier.identifyLanguage(text).addOnSuccessListener { language ->
                    if (!closed) {
                        if (language == "und") result.error("translation_source_undetected", "Unable to identify the source language.", null)
                        else result.success(language)
                    }
                }.addOnFailureListener {
                    if (!closed) result.error("translation_source_undetected", "Unable to identify the source language.", null)
                }
            }
            "translate" -> {
                val text = call.argument<String>("text").orEmpty()
                val source = translationLanguage(call.argument<String>("source").orEmpty())
                val target = translationLanguage(call.argument<String>("target").orEmpty())
                if (source == null || target == null) {
                    result.error("unsupported_language", "This language is not supported by ML Kit.", null)
                    return
                }
                if (source == target || text.none { it.isLetter() }) {
                    result.success(text)
                    return
                }
                val translator = Translation.getClient(TranslatorOptions.Builder()
                    .setSourceLanguage(source).setTargetLanguage(target).build())
                translators.add(translator)
                val handler = Handler(Looper.getMainLooper())
                var completed = false
                val timeout = Runnable {
                    if (!completed) {
                        completed = true
                        translators.remove(translator)
                        translator.close()
                        if (!closed) result.error("translation_failed", "Translation timed out. Connect to Wi-Fi to download the language models and try again.", null)
                    }
                }
                handler.postDelayed(timeout, 120_000)
                translator.downloadModelIfNeeded(DownloadConditions.Builder().requireWifi().build())
                    .continueWithTask { download ->
                        if (!download.isSuccessful) throw download.exception ?: IllegalStateException("Model download failed")
                        if (closed || completed) throw IllegalStateException("Translation closed")
                        translator.translate(text)
                    }.addOnCompleteListener { task ->
                        if (completed) return@addOnCompleteListener
                        completed = true
                        handler.removeCallbacks(timeout)
                        translators.remove(translator)
                        translator.close()
                        if (!closed) {
                            if (task.isSuccessful) result.success(task.result)
                            else result.error("translation_failed", "Translation failed. Connect to Wi-Fi to download the language models and try again.", null)
                        }
                    }
            }
            else -> result.notImplemented()
        }
    }

    private fun translationLanguage(tag: String): String? {
        val normalized = tag.replace('_', '-')
        return TranslateLanguage.fromLanguageTag(normalized)
            ?: TranslateLanguage.fromLanguageTag(Locale.forLanguageTag(normalized).language)
    }

    fun close() {
        closed = true
        channel.setMethodCallHandler(null)
        identifier.close()
        translators.forEach { it.close() }
        translators.clear()
    }
}
