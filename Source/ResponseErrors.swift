//
//  ResponseErrors.swift
//  Alamofire
//
//  Created by Zack Sheppard on 8/5/20.
//

import Foundation

import Alamofire

/// A generic root class for errors that happen while trying to deal with problems with the Alamofire response
open class ResponseError<SuccessType>: Error {
    public let response: AFDataResponse<SuccessType>

    public var aferror: AFError? {
        return response.error
    }

    public init(response: AFDataResponse<SuccessType>) {
        self.response = response
    }
}

/// An error for when the request timed out
public protocol TimeoutError: Error {}
public class TimeoutErrorWithResponse<SuccessType>: ResponseError<SuccessType>, TokenExpired {}

/// An error for when the token we're using is expired
public protocol TokenExpired: Error {}
public class TokenExpiredErrorWithResponse<SuccessType>: ResponseError<SuccessType>, TokenExpired {}

/// An error for when the response cannot be deserialized as valid JSON
public protocol MalformedBody: Error {}
public class MalformedBodyErrorWithResponse<SuccessType>: ResponseError<SuccessType>, MalformedBody {}

/// An error for when an endpoint returns a non-200 repsonse with a deserializable body
public class NotOkResponseError<SuccessType>: ResponseError<SuccessType> {
    public var serverResponse: SuccessType? {
        return self.response.value
    }
}

public class InvalidInternalStateError: Error {}
