//
//  APIManager.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

import Alamofire

/// The singleton object that coordinates the Alamofire Session objects to perform API calls.
internal final class APIManager {
    static private var __singleton: APIManager? = nil

    /// The shared instance of the API Manager
    static var shared: APIManager {
        if let oneoff = __singleton {
            return oneoff
        }

        let newly = APIManager()
        __singleton = newly
        return newly
    }

    private var alamofireSessions: [TimeInterval : Alamofire.Session] = [
        EndpointConstants.timeout : alamoFireWithCustomTimeout(EndpointConstants.timeout)
    ]

    /// Perform the Endpoint call using an existing Session, or creating a new one if needs be.
    /// - Parameter endpoint: The Endpoint object to call.
    func call(_ endpoint: DataEndpoint) {
        guard let session = buildSessionAndValidate(for: endpoint) else {
            // The preflight failed but should have been logged and called back by the build function
            return
        }

        aflog.info("APIFire: Starting call...\n\tEndpoint: \(endpoint.completeURL)\n\tMethod: \(endpoint.httpMethod)\n\tParams: \(endpoint.parameters)")

        // Setup the request...
        let request = session.request(
            endpoint.completeURL,
            method: endpoint.httpMethod,
            parameters: endpoint.parameters as Parameters,
            encoding: endpoint.parameterEncoding,
            headers: endpoint.headers
        )

        endpoint.startCall(request)
    }

    /// Queue a download with an existing Session, or creating a new one if needs be.
    /// - Parameter endpoint: The Endpoint object to call.
    func download(_ endpoint: DownloadEndpoint) {
        guard let session = buildSessionAndValidate(for: endpoint) else {
            // The preflight failed but should have been logged and called back by the build function
            return
        }

        aflog.info("APIFire: Starting download...\n\tEndpoint: \(endpoint.completeURL)\n\tMethod: \(endpoint.httpMethod)\n\tParams: \(endpoint.parameters)")

        let destination = (endpoint as? DownloadToFileEndpoint)?.destination

        // Setup the request...
        let task = session.download(
            endpoint.completeURL,
            method: endpoint.httpMethod,
            parameters: endpoint.parameters as Parameters,
            encoding: endpoint.parameterEncoding,
            headers: endpoint.headers,
            to: destination
        )

        endpoint.startCall(task)
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
