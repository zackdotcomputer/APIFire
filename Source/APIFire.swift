//
//  APIFire.swift
//  APIFire
//

import Dispatch
import Foundation
#if canImport(Alamofire)
@_exported import Alamofire
#endif

// Per Alamofire's (MIT Licensed) header Swift:
// Enforce minimum Swift version for all platforms and build systems.
#if swift(<5.5)
#error("Alamofire doesn't support Swift versions below 5.5, so APIFire cannot either.")
#endif

/// Current version
let version = "1.1.0"
