//
//  CallbackCoordinator.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation
import Alamofire

/// The standard type for the completion block of an endpoint.
public typealias EndpointCompletionBlock<ResponseType> = (EndpointResult<ResponseType>) -> ()

/// A coordinator to chain together the various callbacks that a request-in-progress might be told to call back to.
public final class CallbackCoordinator<ResponseObject> {
    private var allCompletionCalls: [EndpointCompletionBlock<ResponseObject>] = []

    public init() {}

    /// - Parameter callback: A completion block to be called when this coordinator wraps up.
    public func addCallback(_ callback: @escaping EndpointCompletionBlock<ResponseObject>) {
        allCompletionCalls.append(callback)
    }

    /// Execute all the chained callbacks sequentially.
    /// - Parameter result: The object to pass to each callback
    public func callCompleted(_ result: EndpointResult<ResponseObject>) {
        allCompletionCalls.forEach { (callback) in
            callback(result)
        }
    }
}
