//
//  CallbackCoordinator.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

/// The standard type for the completion block of an endpoint.
public typealias EndpointCompletionBlock<ResponseType> = (_ result: Swift.Result<ResponseType, Error>) -> Void

/// A coordinator to chain together the various callbacks that a request-in-progress might be told to call back to.
public final class CallbackCoordinator<ResponseObject> {
    private var allCompletionCalls: [EndpointCompletionBlock<ResponseObject>] = []

    /// - Parameter callback: A completion block to be called when this coordinator wraps up.
    func addCallback(_ callback: @escaping EndpointCompletionBlock<ResponseObject>) {
        allCompletionCalls.append(callback)
    }

    /// Execute all the chained callbacks sequentially.
    /// - Parameter result: The object to pass to each callback
    func callCompleted(_ result: Swift.Result<ResponseObject, Error>) {
        allCompletionCalls.forEach { (callback) in
            callback(result)
        }
    }
}
