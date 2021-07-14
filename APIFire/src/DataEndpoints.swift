//
//  DataEndpoints.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

import Alamofire

/// An endpoint that expects data returned over HTTP
public protocol DataEndpoint: Endpoint {}

/// A protocol building on the `DataEndpoint` that adds automatic deserialization.
/// - Note: Implementations of this protocol **must not** implement the `callEnded(_:)` method if they wish to receive the deserialization functionality.
public protocol DeserializingEndpoint: DataEndpoint, CallableEndpoint where ResponseType: Decodable {
    /// This coordinator serves two purposes. One, it's a handy way to declare what type your Endpoint
    /// expects the `ResponseType` to be. Two, it functionally manages the closures waiting to hear the
    /// result of this endpoint call.
    var onCompletion: CallbackCoordinator<ResponseType> { get }

    /// The queue on which to run the Alamofire call and, relatedly, the onCompletion blocks
    var queue: DispatchQueue { get }

    /// The data preprocessor - see Alamofire for more information.
    var dataPreprocessor: DataPreprocessor { get }
    var decoder: DataDecoder { get }

    /// Transform an error thrown preflight. By default, passes the `Error` to the callbacks untransformed.
    /// You can add a custom handler to digest error messages into meaningful `ResponseType`s.
    func transformError(_ error: Error) -> EndpointResult<ResponseType>

    /// If a response is received and deserialized, this function is given a chance to parse the `AFDataResponse` into the proper `Result`.
    /// - Parameter alamoResponse: The response from the Alamofire layer - could be a failure.
    /// - Returns: The synthesized `Result` holding either a valid response object or error, which will be given to the callbacks.
    func transformResponse(
        alamoResponse: AFDataResponse<ResponseType>
    ) -> EndpointResult<ResponseType>
}

// MARK: - Default Implementations of upstream protocol methods

public extension DeserializingEndpoint {
    /// Convenience method to add a callback handler and then start this endpoint call on the shared
    /// APIManager instance
    /// - Parameter completionCallback: The closure to call when the endpoint completes.
    func call(
        onCompletion completionCallback: @escaping EndpointCompletionBlock<ResponseType>
    ) {
        onCompletion.addCallback(completionCallback)

        APIFireSessionManager.shared.call(containedEndpoint: CallableContainer(endpoint: self), onCompletion: { (r: EndpointResult<ResponseType>) in
            self.handleResult(r)
        })
    }

    // Handle result call just calls the completion callback
    fileprivate func handleResult(_ result: EndpointResult<ResponseType>) {
        onCompletion.callCompleted(result)
    }
}

public extension DeserializingEndpoint {
    // Maintain the Alamofire default of executing on main
    var queue: DispatchQueue {
        return .main
    }

    var dataPreprocessor: DataPreprocessor {
        // NOTE(zack): The type of decodable here doesn't matter cause defaultDataPreprocessor is untyped.
        return DecodableResponseSerializer<String>.defaultDataPreprocessor
    }

    var decoder: DataDecoder {
        return JSONDecoder()
    }

    func startCall(inSession session: Session, completion: @escaping EndpointCompletionBlock<ResponseType>) {
        let call = session.request(
            completeURL,
            method: httpMethod,
            parameters: compactParameters(),
            encoding: parameterEncoding,
            headers: headers
        )

        if let loggableSelf = self as? WithLogging {
            loggableSelf.logAtStartOfCall()
        }

        call.responseDecodable(queue: self.queue, dataPreprocessor: self.dataPreprocessor, decoder: self.decoder) { (r: AFDataResponse<ResponseType>) in
            if let loggableSelf = self as? WithLogging {
                loggableSelf.logCallCompletion(response: r)
            }

            completion(self.transformResponse(alamoResponse: r))
        }
    }
}

public extension PreflightValidation where Self: DeserializingEndpoint {
    /// Default implementation of a preflight failure is to try to digest the error and handle it.
    func preflightFailed(_ failure: Error) {
        handleResult(transformError(failure))
    }
}

// MARK: - Default Implementation for Deserialization Handling

public extension DeserializingEndpoint {
    func transformResponse(
        alamoResponse: AFDataResponse<ResponseType>
    ) -> EndpointResult<ResponseType> {
        let statusCode = StatusCodes(rawValue: alamoResponse.response?.statusCode ?? -1)

        switch statusCode {
        case .success:
            guard let deserialized = alamoResponse.value else {
                return EndpointResult(error: MalformedBodyErrorWithResponse(response: alamoResponse))
            }

            return EndpointResult(value: deserialized)
        case .timeout:
            return EndpointResult(error: TimeoutErrorWithResponse(response: alamoResponse))
        case nil:
            return EndpointResult(error: NotOkResponseError(response: alamoResponse), value: alamoResponse.value)
        }
    }

    /// `Error` objects just get digested as failures by default. If you'd like, you may add a
    /// custom handler to serialize the Error into a usable `ResponseObject` type.
    func transformError(_ error: Error) -> EndpointResult<ResponseType> {
        return EndpointResult(error: error)
    }
}
