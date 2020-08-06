//
//  DeserializingEndpoint.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

import Alamofire

/// A protocol building on the `DataEndpoint` that adds automatic deserialization.
/// - Note: Implementations of this protocol **must not** implement the `callEnded(_:)` method if they wish to receive the deserialization functionality.
public protocol DeserializingEndpoint: DataEndpoint {
    associatedtype ResponseObject: Decodable

    /// This coordinator serves two purposes. One, it's a handy way to declare what type your Endpoint
    /// expects the `ResponseObject` to be. Two, it functionally manages the closures waiting to hear the
    /// result of this endpoint call.
    var onCompletion: CallbackCoordinator<ResponseObject> { get }

    /// Transform an error thrown preflight. By default, passes the `Error` to the callbacks untransformed.
    /// You can add a custom handler to digest error messages into meaningful `ResponseObject`s.
    func transformError(_ error: Error) -> Swift.Result<ResponseObject, Error>

    /// If a response is received and deserialized, this function is given a chance to parse the `AFDataResponse` into the proper `Result`.
    /// - Parameter alamoResponse: The response from the Alamofire layer - could be a failure.
    /// - Returns: The synthesized `Result` holding either a valid response object or error, which will be given to the callbacks.
    func transformResponse(
        alamoResponse: AFDataResponse<ResponseObject>
    ) -> Swift.Result<ResponseObject, Error>
}

extension DeserializingEndpoint {
    /// Convenience method to add a callback handler and then start this endpoint call on the shared
    /// APIManager instance
    /// - Parameter completionCallback: The closure to call when the endpoint completes.
    func call(
        onCompletion completionCallback: EndpointCompletionBlock<ResponseObject>? = nil
    ) {
        if let callback = completionCallback {
            onCompletion.addCallback(callback)
        }

        APIManager.shared.call(self)
    }
}

// MARK: - Default Implementations of upstream protocol methods

extension DeserializingEndpoint {
    func startCall(_ call: DataRequest) {
        call.responseDecodable {
            self.handleResult(self.transformResponse(alamoResponse: $0))
        }
    }
}

extension PreflightValidation where Self: DeserializingEndpoint {
    /// Default implementation of a preflight failure is to try to digest the error and handle it.
    func preflightFailed(_ failure: Error) {
        handleResult(transformError(failure))
    }
}

// MARK: - Default Implementation for Deserialization Handling

extension DeserializingEndpoint {
    func transformResponse(
        alamoResponse: AFDataResponse<ResponseObject>
    ) -> Swift.Result<ResponseObject, Error> {
        let statusCode = StatusCodes(rawValue: alamoResponse.response?.statusCode ?? -1)

        switch statusCode {
        case .success:
            guard let deserialized = alamoResponse.value else {
                return .failure(MalformedBodyError(response: alamoResponse))
            }

            return .success(deserialized)
        case .timeout:
            return .failure(TimeoutError(response: alamoResponse))
        case nil:
            return .failure(NotOkResponseError(response: alamoResponse))
        }
    }

    /// `Error` objects just get digested as failures by default. If you'd like, you may add a
    /// custom handler to serialize the Error into a usable `ResponseObject` type.
    func transformError(_ error: Error) -> Swift.Result<ResponseObject, Error> {
        return .failure(error)
    }
}

fileprivate extension DeserializingEndpoint {
    // Handle result call just calls the completion callback
    func handleResult(_ result: Swift.Result<ResponseObject, Error>) {
        onCompletion.callCompleted(result)
    }
}
