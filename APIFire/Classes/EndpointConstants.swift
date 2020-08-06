//
//  EndpointConstants.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

/// Shared default constants for the endpoints systemwide
internal enum EndpointConstants {
    static let timeout: TimeInterval = 15 // Seconds
}

internal enum StatusCodes: Int {
    case timeout = -1001
    case success = 200
}
