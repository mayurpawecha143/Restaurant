//
//  WebService.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/2/22.
//

import Foundation

class WebService {
    let session: URLSession
    init(session: URLSession) {
        self.session = session
    }
    
    convenience init() {
        self.init(session: URLSession(configuration: URLSessionConfiguration.default))
    }
    
    func callAPI(urlRequest: URLRequest, completionHandler: @escaping (Result<Data, ServerError>) -> Void) {
        session.dataTask(with: urlRequest, completionHandler: { data, response, error in
            if let _ = error {
                completionHandler(.failure(.serverError))
            }
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200,
               let data = data {
                completionHandler(.success(data))
            } else {
                completionHandler(.failure(.httpResponseError))
            }
        }).resume()
    }
}
