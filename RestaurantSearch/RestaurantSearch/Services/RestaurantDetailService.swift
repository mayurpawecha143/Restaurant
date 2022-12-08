//
//  RestaurantDetailService.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/7/22.
//

import Foundation
 
class RestaurantDetailService: RequestConfigurator{
    private let webService: WebService
    init(webService: WebService = WebService()) {
        self.webService = webService
        super.init()
    }
    
    private func createRequest(_ id: String) -> URLRequest? {
        type = .detail(id)
        let url = baseURL + path + requestParameters()
        guard let URL = URL(string: url) else {
            return nil
        }
        var request = URLRequest(url: URL)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        return request
    }
    
    func fetchRestaurantDetail(_ id: String, completionHandler: @escaping (Restaurant?) -> Void) {
        if let request = createRequest(id) {
            webService.callAPI(urlRequest: request, completionHandler: { result in
                switch result {
                case .success(let data):
                    do {
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                        let restaurant = try jsonDecoder.decode(Restaurant.self, from: data)
                        completionHandler(restaurant)
                    }
                    catch {
                        print("Error: \(error)")
                        completionHandler(nil)
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                    completionHandler(nil)
                    break
                }
            })
        }
    }
}
