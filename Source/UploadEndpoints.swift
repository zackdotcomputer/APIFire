//
//  UploadEndpoints.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/11/20.
//

import Alamofire
import Foundation

/// The base endpoint type for an endpoint that uploads a data payload
public protocol UploadEndpoint: CallableEndpoint where ResponseType == AFDataResponse<Data?> {
    /// Override the Endpoint parameterEncoding type with URLEncoding, as it's the only valid way to encode parameters to an Upload.
    var parameterEncoding: URLEncoding { get }

    /// Optional hook to receive progress as the upload proceeds
    func uploadProgress(_ progress: Progress)

    /// Optional hook to receive progress as the download proceeds after the upload finishes
    func downloadProgress(_ progress: Progress)

    /// Optional hook to be notified of the response from the server to your upload
    func uploadCompleted(_ response: AFDataResponse<Data?>)

    /// Required for subclasses to create the actual request object
    func makeUploadRequest(_ session: Session) -> UploadRequest
}

/// Endpoint that uploads multipart form data
public protocol MultipartFormDataUploadEndpoint: UploadEndpoint {
    /// Append your form data to the formData object. By default, will append the values from
    func buildFormData(onto formData: MultipartFormData)
}

// MARK: - Default Implementations

public extension UploadEndpoint {
    var httpMethod: HTTPMethod {
        return .post
    }

    var parameterEncoding: ParameterEncoding {
        return URLEncoding(destination: .queryString)
    }

    func startCall(inSession session: Session, onCompletion: @escaping EndpointCompletionBlock<AFDataResponse<Data?>>) {
        if let loggableSelf = self as? WithLogging {
            loggableSelf.logAtStartOfCall()
        }

        self.makeUploadRequest(session)
            .uploadProgress { self.uploadProgress($0) }
            .downloadProgress { self.downloadProgress($0) }
            .response { (r: AFDataResponse<Data?>) in
                if let loggableSelf = (self as? WithLogging) {
                    loggableSelf.logCallCompletion(response: r)
                }

                self.uploadCompleted(r)
                
                onCompletion(EndpointResult(r))
        }
    }

    func uploadCompleted(_ response: AFDataResponse<Data?>) {
        /* No-op */
    }

    func uploadProgress(_ progress: Progress) {
        /* No-op */
    }

    func downloadProgress(_ progress: Progress) {
        /* No-op */
    }
}

public extension MultipartFormDataUploadEndpoint {
    func makeUploadRequest(_ session: Session) -> UploadRequest {
        return session.upload(
            multipartFormData: { self.buildFormData(onto: $0) },
            to: completeURL,
            method: httpMethod,
            headers: headers
        )
    }
}
