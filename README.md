#  CryptoTokenKit samples

These are sample projects demonstrating how to leverage the CTK extension in the
iOS Yubico Authenticator from an application.

The CryptoTokenKit extension in the Yubico Authenticator allows iOS to store the public part of a certificate on the iPhone and let other apps request signing, decrypt or key-exchange from iOS for said certificate. When i.e Safari gets an auth challenge from a website it will list the stored certificates and let the user select which one to use. iOS will then open the extension associated with the certificate and ask it to sign the request. In the Yubico Authenticator case we will use the private key on the matching certificate stored in the PIV/Smart Card application on the YubiKey to sign the data. Once signed the extension will return the data to iOS which in turn sends it back to the originating app.
