//
//  DownloadEndpoints.swift
//  Alamofire
//
//  Created by Zack Sheppard on 8/11/20.
//

import Alamofire
import Foundation

/// An endpoint that saves a downloaded object to a file.
public protocol DownloadToFileEndpoint: CallableEndpoint where ResponseType == AFDownloadResponse<URL?> {
    /// The queue on which to run the request and the callEnded function
    var queue: DispatchQueue { get }

    /// The destination for this download request. The downloaded data will be written there and the file URL passed
    /// to the callEnded(_:) endpoint.
    var destination: DownloadRequest.Destination { get }
}

// MARK: - Default implementations

public extension DownloadToFileEndpoint {
    var queue: DispatchQueue {
        return .main
    }

    func startCall(inSession session: Session, onCompletion: @escaping EndpointCompletionBlock<AFDownloadResponse<URL?>>) {
        if let loggableSelf = self as? WithLogging {
            loggableSelf.logAtStartOfCall()
        }

        // Setup the request...
        let task = session.download(
            completeURL,
            method: httpMethod,
            parameters: compactParameters(),
            encoding: parameterEncoding,
            headers: headers,
            to: destination
        )

        task.response(queue: queue) { (response: AFDownloadResponse<URL?>) in
            if let loggableSelf = self as? WithLogging {
                loggableSelf.logCallCompletion(response: response)
            }

            let result = EndpointResult(response)

            onCompletion(result)
        }
    }
}
