# Change Log

## 0.1.0 - Initial Release

## 0.2.0 - More

## 0.2.1 - Bugfix

## 0.3.0 - Trimmed Parameters

- Using the parameters property to fill the GET params causes some weird issues where "Option" is inserted. This is fixed by trimming the params before encoding so their type is no longer nullable.

## 1.0.0 - New Beginnings

Reviving the package after a long hiatus, updating dependencies to latest.

## 2.0.0 - Swift Package Manager Support

This is essentially what 1.0.0 should have been.

It gets a new major version because 1) it adds Swift Package Manger Support and 2) it officially drops support for Swift versions prior to 5.5 on Cocoapods. (This change was already implicit in Alamofire, so attempting to use 1.x on a Swift 5.1 project would already have broken, but now that it's explicit I figured it should get a major version bump.)

Because Swift Package Manager expects a major revision to all be good for its purposes, that alone would require a major bump.
