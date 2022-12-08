//
//  File.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/2/22.
//

import CoreLocation
import Foundation
import UIKit

class AppCoordinator: NSObject {

    let navigationController: UINavigationController
    init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        
        self.setRestaurantListController()
    }
    
    func setRestaurantListController() {
        let controller = RestaurantListViewController()
        controller.delegate = self
        self.navigationController.pushViewController(controller, animated: false)
    }
    
    func showAlert(with error: Error) {
        let alert = UIAlertController(title: "Error", message: "\(error)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style:.default))
        self.navigationController.present(alert, animated: true, completion: nil)
    }
}

extension AppCoordinator {
    func updateLocation(_ result: Result<CLLocation, Error>) {
        switch result {
        case .success(let location):
            let controller = self.navigationController.viewControllers.first {
                $0.isKind(of: RestaurantListViewController.self)
            }
            if let restaurantListViewController = controller as? RestaurantListViewController {
                restaurantListViewController.updatedLocation(location)
            }
            
        case .failure(let error):
            showAlert(with: error)
            break
        }
    }
}

extension AppCoordinator: RestaurantListViewControllerDelegate {
    func checkDetailsfor(_ restaurant: Restaurant) {
        let controller = RestaurantDetailViewController(restaurant: restaurant)
        self.navigationController.pushViewController(controller, animated: true)
    }
}
