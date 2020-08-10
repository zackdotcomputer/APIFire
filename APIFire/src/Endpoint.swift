//
//  Endpoint.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

import Alamofire

/// Typealias for a generic parameter structure for endpoint calls
/// Overrides the Alamofire.Parameters type to allow explicitly for optional values
public typealias EndpointParameters = [ String : Any? ]

/// The most generic form for defining how to make an API call
public protocol Endpoint {
    /// The URL that will be requested
    var completeURL: URL { get }

    /// How long Alamofire should allow the call to hang before terminating it (and returning a TimeoutFailure to any callback)
    var timeout: TimeInterval { get }

    /// Get or Post or something more exotic? - default is GET
    var httpMethod: HTTPMethod { get }

    /// Parameters to pass to the endpoint - default is to pass no parameters
    var parameters: EndpointParameters { get }

    /// Custom headers to use for the call - default is to pass no custom headers
    var headers: HTTPHeaders { get }

    /// How to encode the parameters - default is JSON for POST and QueryString for GET requests
    var parameterEncoding: ParameterEncoding { get }
}

// MARK: - Specialization protocols

/// An endpoint that expects data returned over HTTP
public protocol DataEndpoint: Endpoint {
    /// The function that the APIManager will call with the created Request to initiate it.
    func startCall(_ call: DataRequest)
}

/// An endpoint that downloads data to memory or disk
public protocol DownloadEndpoint: Endpoint {
    /// The function that the APIManager will call with the created Request to initiate it.
    func startCall(_ call: DownloadRequest)
}

/// A subtype of the DownloadEndpoint that saves the result to a file.
public protocol DownloadToFileEndpoint: DownloadEndpoint {
    /// The queue on which to run the request and the callEnded function
    var queue: DispatchQueue { get }

    /// The destination for this download request. The downloaded data will be written there and the file URL passed
    /// to the callEnded(_:) endpoint.
    var destination: DownloadRequest.Destination { get }

    /// Get a callback when the call has ended. Note that a call to this function does NOT mean the call succeeded, as
    /// the response can still contain no response and an error instead.
    func callEnded(_ result: AFDownloadResponse<URL?>)
}

// MARK: - Extra Feature Protocols

/// Adds preflight validation and a related callback hook for the `Endpoint` protocol.
/// This is done automatically and ensured no matter how you subclass `Endpoint`.
public protocol PreflightValidation: Endpoint {
    /// Called before APIFire attempts to make the endpoint call to allow you the chance to abort the call because of invalid state
    /// - Throws: Any error you'd like. If you throw, the call will not proceed and the error will be passed to the `preflightFailed(_:)` func.
    func validatePreflight() throws

    /// Called if the validatePreflight step fails, allowing callback interceptors a chance to pass that failure on to listeners.
    /// - Parameter failure: The error that was thrown by the `validatePreflight` call
    func preflightFailed(_ failure: Error)
}

/// Adds custom logging hooks for your Endpoint
/// - NOTE: This is implemented by the default implementations in the library. However, if you override the `startCall` function or create your
///   own implementers of `Endpoint`, you are responsible for detecting and calling these methods as appropriate.
public protocol WithLogging: Endpoint {
    func logAtStartOfCall()
    func logCallCompletion<ResponseType>(response: ResponseType)
}

// MARK: - Default values

public extension Endpoint {
    // NOTE(zack): The default timeout will cause the call to be processed by the shared Alamofire instance.
    // If you customize this value, it may cause the creation of a new Alamofire Session.
    var timeout: TimeInterval {
        return EndpointConstants.timeout
    }

    var parameterEncoding: ParameterEncoding {
        if self.httpMethod == .get {
            return URLEncoding(destination: .queryString, arrayEncoding: .noBrackets, boolEncoding: .literal)
        }

        return JSONEncoding()
    }

    var httpMethod: HTTPMethod {
        return .get
    }

    var parameters: EndpointParameters {
        return [:]
    }

    var headers: HTTPHeaders {
        return [:]
    }
}

public extension DownloadToFileEndpoint {
    var queue: DispatchQueue {
        return .main
    }

    func startCall(_ call: DownloadRequest) {
        if let loggableSelf = self as? WithLogging {
            loggableSelf.logAtStartOfCall()
        }
        call.response(queue: self.queue) { (response: DownloadResponse) in
            if let loggableSelf = self as? WithLogging {
                loggableSelf.logCallCompletion(response: response)
            }

            self.callEnded(response)
        }
    }
}

public extension WithLogging {
    func logAtStartOfCall() {
        /* Default to no-op */
    }

    func logCallCompletion<ResponseType>(response: ResponseType) {
        /* Default to no-op */
    }
}
