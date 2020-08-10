//
//  Utilities.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

import Logging

import Alamofire

/// The APIFire logger instance
internal let aflog = Logger(label: "computer.zack.APIFire")

/// - Parameter timeout: The timeout for requests and resource fetches the new instance should use.
/// - Returns: A new AlamoFire `Session` with your specified timeout interval
internal func alamoFireWithCustomTimeout(_ timeout: TimeInterval) -> Alamofire.Session {
    let myconfiguration = URLSessionConfiguration.default
    myconfiguration.timeoutIntervalForRequest = timeout
    myconfiguration.timeoutIntervalForResource = timeout
    return Alamofire.Session(
        configuration: myconfiguration, delegate: SessionDelegate()
    )
}
