//
//  RestaurantManager.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/7/22.
//

import Foundation
import CoreLocation

class RestaurantManager {
    static let shared = RestaurantManager()
    
    private var restaurants: [Restaurant]
    
    private let serialQueueForData = DispatchQueue(label: "restaurant.queue", attributes: .concurrent)
    
    let searchService: RestaurantSearchService
    let detailService: RestaurantDetailService
    private init(searchService: RestaurantSearchService = RestaurantSearchService(), detailService: RestaurantDetailService = RestaurantDetailService()) {
        self.searchService = searchService
        self.detailService = detailService
        restaurants = []
    }
    
    private func getRestuarant(for id: String) -> Restaurant? {
        return fetchAllResturants().first(where: {
            $0.id == id
        })
    }
    
    private func getRestuarantIndex(for id: String) -> Int? {
        return fetchAllResturants().firstIndex(where: {
            $0.id == id
        })
    }
    
    func fetchAllResturants() -> [Restaurant] {
        var restaurantList: [Restaurant] = []
        self.serialQueueForData.sync(flags: .barrier) {
            restaurantList = restaurants
        }
        return restaurantList
    }
    
    func fetchResturantList(with search: String, completionHandler: @escaping ([Restaurant]) -> Void) {
        let searchString = search.lowercased()
        let list = fetchAllResturants().filter { restaurant in
            let name = restaurant.name.lowercased()
            return name.contains(searchString)
        }
        completionHandler(list)
    }
    
    func fetchReasturantList(for location: CLLocation, completionHandler: @escaping ([Restaurant]) -> Void) {
        searchService.fetchRestaurantList(location, completionHandler: { [weak self] list in
            guard let strongSelf = self else { return }
            strongSelf.serialQueueForData.sync(flags: .barrier) {
                strongSelf.restaurants = list
            }
            completionHandler(list)
        })
    }
    
    func fetchReasturantDetails(for id: String, completionHandler: @escaping (Restaurant?) -> Void) {
        if let resturant = getRestuarant(for: id), resturant.hours != nil  {
            completionHandler(resturant)
        } else {
            detailService.fetchRestaurantDetail(id, completionHandler: { [weak self] object in
                guard let strongSelf = self else {
                    completionHandler(nil)
                    return
                }
                if let newObject = object {
                    strongSelf.updateRestuarant(newObject)
                    completionHandler(newObject)
                } else {
                    completionHandler(strongSelf.getRestuarant(for: id))
                }
            })
        }
    }
    
    func updateRestuarant(_ object: Restaurant) {
        if let index = getRestuarantIndex(for: object.id) {
            self.serialQueueForData.sync(flags: .barrier) {
                var resturant = restaurants[index]
                resturant.merge(with: object)
                restaurants[index] = resturant
            }
        }
    }
}
