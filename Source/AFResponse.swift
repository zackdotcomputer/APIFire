//
//  AFResponse.swift
//  APIFire
//
//  Created by Zack Sheppard on 8/12/20.
//

import Alamofire

/// A shared root protocol for the AFDataResponse and AFDownloadResponse types from Alamofire.
public protocol FireResponse {}

public protocol TypedFireResponse: FireResponse {
    associatedtype Success
    associatedtype Failure: Error

    var result: Result<Success, Failure> { get }

    var value: Success? { get }
    var error: Failure? { get }
}

extension Alamofire.DataResponse: TypedFireResponse {}
extension Alamofire.DownloadResponse: TypedFireResponse {}
