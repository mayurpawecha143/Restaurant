//
//  RequestConfigurator.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/5/22.
//

import Foundation
import CoreLocation

enum RequestType {
    case search(CLLocation)
    case detail(String)
}
class RequestConfigurator {
    
    var type: RequestType?
    
    private let apiKey = "QTBmzWZA-Bpbz2hc3C7aRmj9dW4amrxolEFaE5exhbselPR3t7cUeD3CEPPhoH8jCOC8MgDLwOc8sL9YksvExkaHisCCfgHHSvwudfEAT-_fLq2nP5dy22xnlObqYnYx"
    
    lazy var baseURL: String = {
        return "https://api.yelp.com/v3/businesses"
    }()
    
    lazy var path: String = {
        switch type {
        case .search(_):
            return "/search"
        case .detail(let id):
            return "/\(id)"
        case .none:
            return ""
        }
    }()
    
    lazy var headers: [String : String] = {
        return ["Authorization": "Bearer \(apiKey)", "accept": "application/json"]
    }()
    
    lazy var method: String = {
        return "GET"
    }()
    
    func requestParameters() -> String {
        switch type {
        case .search(let location):
            let latitude = "\(location.coordinate.latitude)"
            let longitude = "\(location.coordinate.longitude)"
            return "?sort_by=best_match&limit=20&latitude=\(latitude)&longitude=\(longitude)&device_platform=ios"
            
        case .detail(_):
            return "?device_platform=ios"
            
        case .none:
            return ""
        }
    }
}
