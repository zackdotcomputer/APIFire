//
//  ResponseErrors.swift
//  Alamofire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

import Alamofire

/// A generic root class for errors that happen while trying to deal with problems with the Alamofire response
class ResponseError<SuccessType>: Error {
    let response: AFDataResponse<SuccessType>

    var aferror: AFError? {
        return response.error
    }

    init(response: AFDataResponse<SuccessType>) {
        self.response = response
    }
}

/// An error for when the call to the server times out
class TimeoutError<SuccessType>: ResponseError<SuccessType> {}

/// An error for when an endpoint returns a non-200 repsonse with a deserializable body
class NotOkResponseError<SuccessType>: ResponseError<SuccessType> {
    var serverResponse: SuccessType? {
        return self.response.value
    }
}

/// An error for when the response cannot be deserialized as valid JSON or as the JSON type expected
class MalformedBodyError<SuccessType>: ResponseError<SuccessType> {}
