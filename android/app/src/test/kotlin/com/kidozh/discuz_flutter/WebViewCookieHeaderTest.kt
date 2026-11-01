package com.kidozh.discuz_flutter

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class WebViewCookieHeaderTest {
    @Test fun preservesEncodedAuthAndEqualsSigns() {
        assertEquals(
            listOf(
                mapOf("name" to "discuz_auth", "value" to "encoded%3Dauth=="),
                mapOf("name" to "token", "value" to "a=b=c"),
                mapOf("name" to "empty", "value" to ""),
            ),
            parseWebViewCookieHeader("discuz_auth=encoded%3Dauth==; token=a=b=c; empty="),
        )
    }

    @Test fun ignoresInvalidPairsWithoutDroppingValidCookies() {
        assertEquals(
            listOf(mapOf("name" to "valid", "value" to "1")),
            parseWebViewCookieHeader("; invalid; =bad; valid=1; "),
        )
    }

    @Test fun handlesAnEmptyStore() {
        assertTrue(parseWebViewCookieHeader(null).isEmpty())
        assertTrue(parseWebViewCookieHeader("").isEmpty())
    }
}
