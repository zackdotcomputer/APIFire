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

// MARK: - Specialization subprotocols

public protocol DataEndpoint: Endpoint {
    /// The function that the APIManager will call with the created Request to initiate it.
    func startCall(_ call: DataRequest)
}

/// Adds preflight validation and a related callback hook for the Endpoint protocol.
public protocol PreflightValidation: Endpoint {
    /// Called before APIFire attempts to make the endpoint call to allow you the chance to abort the call because of invalid state
    /// - Throws: Any error you'd like. If you throw, the call will not proceed and the error will be passed to the `preflightFailed(_:)` func.
    func validatePreflight() throws

    /// Called if the validatePreflight step fails, allowing callback interceptors a chance to pass that failure on to listeners.
    /// - Parameter failure: The error that was thrown by the `validatePreflight` call
    func preflightFailed(_ failure: Error)
}

// MARK: - Default values

extension Endpoint {
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
