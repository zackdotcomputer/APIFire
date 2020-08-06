//
//  DownloadEndpoint.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation
import Alamofire

public protocol DownloadEndpoint: Endpoint {
    /// The function that the APIManager will call with the created Request to initiate it.
    func startCall(_ call: DownloadRequest)
}

/// A subtype of the DownloadEndpoint that saves the result to a file.
public protocol DownloadToFileEndpoint: DownloadEndpoint {
    /// The destination for this download request. The downloaded data will be written there and the file URL passed
    /// to the callEnded(_:) endpoint.
    var destination: DownloadRequest.Destination { get }

    /// Get a callback when the call has ended. Note that a call to this function does NOT mean the call succeeded, as
    /// the response can still contain no response and an error instead.
    func callEnded(_ result: AFDownloadResponse<URL?>)
}

extension DownloadToFileEndpoint {
    func startCall(_ call: DownloadRequest) {
        call.response(completionHandler: { self.callEnded($0) })
    }
}
