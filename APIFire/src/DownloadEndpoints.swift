//
//  DownloadEndpoints.swift
//  Alamofire
//
//  Created by Zack Sheppard on 8/11/20.
//

import Alamofire

/// An endpoint that downloads data to memory or disk
public protocol DownloadEndpoint: Endpoint {
    func initiateDownloadRequest(_ request: DownloadRequest)
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

// MARK: - Default implementations

public extension DownloadEndpoint {
    func startCall(inSession session: Session) {
        if let loggableSelf = self as? WithLogging {
            loggableSelf.logAtStartOfCall()
        }

        let destination = (self as? DownloadToFileEndpoint)?.destination

        // Setup the request...
        let task = session.download(
            completeURL,
            method: httpMethod,
            parameters: parameters as Parameters,
            encoding: parameterEncoding,
            headers: headers,
            to: destination
        )

        initiateDownloadRequest(task)
    }
}

public extension DownloadToFileEndpoint {
    var queue: DispatchQueue {
        return .main
    }

    func initiateDownloadRequest(_ request: DownloadRequest) {
        request.response(queue: queue) { (response: DownloadResponse) in
            if let loggableSelf = self as? WithLogging {
                loggableSelf.logCallCompletion(response: response)
            }

            self.callEnded(response)
        }
    }
}
