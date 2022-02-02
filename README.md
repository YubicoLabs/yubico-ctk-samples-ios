#  Yubico Browser Samples

These are sample projects demonstrating how to use a `WKWebView` together with a CTK extension either in the Yubico Authenticator (browser-only) or an embedded extension in the app (browser-with-extension). The Browser Only sample will work for both NFC and 5Ci YubiKeys while the sample with an embedded extension only work for 5Ci YubiKeys.

A CryptoTokenKit extension allows an app to store the public parts of a certificate on the device and let other apps request signing, decrypt or key-exchange from iOS for said certificate. When i.e Safari gets an auth challenge from a website it will list the stored certificates and let the user select which one to use. iOS will then open the extension associated with the certificate and ask it to sign the request. In the Yubico Authenticator case we will use the private key on the matching certificate stored in the PIV/Smart Card application on the YubiKey to sign the data. Once signed the extension will return the data to iOS which in turn sends it back to the originating app.

## TERMS & CONDITIONS

The Yubico iOS Browser project is intended for use in development and as reference material to building your own production environments, pursuant to Yubico’s terms and conditions. By downloading and installing the software, you agree to the Yubico Toolset Software License Agreement located at https://www.yubico.com/support/terms-conditions/yubico-toolset-software-license-agreement/