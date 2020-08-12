//
//  APIManager.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

import Alamofire

/// The singleton object that coordinates the Alamofire Session objects to perform API calls.
public final class APIFireSessionManager {
    static private var __singleton: APIFireSessionManager? = nil

    /// The shared instance of the API Manager
    public static var shared: APIFireSessionManager {
        if let oneoff = __singleton {
            return oneoff
        }

        let newly = APIFireSessionManager()
        __singleton = newly
        return newly
    }

    private var alamofireSessions: [TimeInterval : Alamofire.Session] = [
        EndpointConstants.timeout : alamoFireWithCustomTimeout(EndpointConstants.timeout)
    ]

    /// Perform the Endpoint call using an existing Session, or creating a new one if needs be.
    /// - Parameter endpoint: The Endpoint object to call.
    public func call<EndpointType>(containedEndpoint container: CallableContainer<EndpointType>, onCompletion: @escaping EndpointCompletionBlock<EndpointType.ResponseType>) {
        guard let session = buildSessionAndValidate(for: container.endpoint) else {
            // The preflight failed but should have been logged and called back by the build function
            return
        }

        container.coordinateCall(in: session, completion: onCompletion)
    }

    private func buildSessionAndValidate(for endpoint: Endpoint) -> Session? {
        if let toValidate = endpoint as? PreflightValidation {
            // Check preflight
            do {
                try toValidate.validatePreflight()
            } catch {
                aflog.warning("Download from \(endpoint.completeURL) failed in preflight\n\(String(describing: error))")
                toValidate.preflightFailed(error)
                return nil
            }
        }

        // Make sure we have an AF Session that has the right timeout
        let session: Session
        if let existing = alamofireSessions[endpoint.timeout] {
            session = existing
        } else {
            aflog.trace("APIFire: Creating new alamofire instance for timeout \(endpoint.timeout)")
            session = alamoFireWithCustomTimeout(endpoint.timeout)
            alamofireSessions[endpoint.timeout] = session
        }

        return session
    }
}

public struct CallableContainer<Call: CallableEndpoint> {
    let endpoint: Call

    public init(endpoint: Call) {
        self.endpoint = endpoint
    }

    func coordinateCall(in session: Session, completion: @escaping EndpointCompletionBlock<Call.ResponseType>) {
        aflog.info("APIFire: Starting call...\n\tEndpoint: \(endpoint.completeURL)\n\tMethod: \(endpoint.httpMethod)\n\tParams: \(endpoint.parameters)")

        endpoint.startCall(inSession: session, completion: completion)
    }
}
