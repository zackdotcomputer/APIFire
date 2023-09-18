//
//  EndpointResult.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/12/20.
//

import Alamofire

/// A struct equivalent to the Swift.Result enum, allowing for use in situations where enums are no allowed by the Swift type system.
public class EndpointResult<Success> {
    public let value: Success?
    public let error: Error?

    public var isFailure: Bool {
        return error != nil
    }

    public var isSuccess: Bool {
        return !isFailure
    }

    public init(value: Success, error: Error? = nil) {
        self.value = value
        self.error = error
    }

    public init(error: Error, value: Success? = nil) {
        self.value = value
        self.error = error
    }

    public init<ResponseData: TypedFireResponse>(afData: ResponseData) where ResponseData.Success == Success {
        self.value = afData.value
        self.error = afData.error
    }

    public var result: Result<Success, Error> {
        if let e = error {
            return .failure(e)
        } else if let r = value {
            return .success(r)
        } else {
            return .failure(InvalidInternalStateError())
        }
    }
}

public extension EndpointResult where Success: TypedFireResponse {
    convenience init(_ value: Success) {
        self.init(value: value, error: value.error)
    }
}
