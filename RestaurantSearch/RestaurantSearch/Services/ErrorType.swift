//
//  ErrorType.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/4/22.
//

import Foundation

enum Result<Success, Failure> where Failure : Error {
    case success(Success)
    case failure(Failure)
}

enum ServerError: Error {
    case apiRequestError
    case httpResponseError
    case serverError
}

enum ImageDownloadError: Error {
    case urlError
    case downloadError
    case conversionError
}
