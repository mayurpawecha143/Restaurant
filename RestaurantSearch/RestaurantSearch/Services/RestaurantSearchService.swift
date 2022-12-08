//
//  RestaurantSearchService.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/4/22.
//

import Foundation
import CoreLocation

struct Response: Decodable {
    let businesses: [Restaurant]
    let total: Int64
}

class RestaurantSearchService: RequestConfigurator {
    
    private let webService: WebService
    init(webService: WebService = WebService()) {
        self.webService = webService
        super.init()
    }
    
    private func createRequest(_ location: CLLocation) -> URLRequest? {
        type = .search(location)
        let url = baseURL + path + requestParameters()
        guard let URL = URL(string: url) else {
            return nil
        }
        var request = URLRequest(url: URL)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        return request
    }
    
    func fetchRestaurantList(_ location: CLLocation, completionHandler: @escaping ([Restaurant]) -> Void) {
        if let request = createRequest(location) {
            webService.callAPI(urlRequest: request, completionHandler: { result in
                switch result {
                case .success(let data):
                    do {
                        let jsonDecoder = JSONDecoder()
                        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                        let restaurants = try jsonDecoder.decode(Response.self, from: data)
                        completionHandler(restaurants.businesses)
                    }
                    catch {
                        print("Error: \(error)")
                        completionHandler([])
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                    completionHandler([])
                    break
                }
            })
        }
    }
}
