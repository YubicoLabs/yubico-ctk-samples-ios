#  Yubico Browser with embedded CTK Extension

This sample app demonstrates how to build an app with a `WKWebView` that uses an embedded CryptoTokenKit extension to sign auth requests. It's similar to the Browser Only sample but differs in that it does not rely on the Yubico Authenticator to handle the signing of requests. Instead the embedded CTK extension handles it. Unless you have very specific needs for you application the Browser Only sample is what you should look at.

Note that there's no error handling if anything goes wrong while signing the data supplied by the extension. The PIN is also stored temporary (10 seconds) on disk in a shared UserDefaults suite.
