//
//  RestaurantListViewController.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/2/22.
//

import UIKit
import CoreLocation

protocol RestaurantListViewControllerDelegate: AnyObject {
    func checkDetailsfor(_ restaurant: Restaurant)
    func showAlert(with error: Error)
}

class RestaurantListViewController: UIViewController {
    weak var delegate: RestaurantListViewControllerDelegate?
    
    private var pendingRequestWorkItem: DispatchWorkItem?
    private var restaurantList: [Restaurant] = []
    
    let restaurantManager: RestaurantManager
    init(restaurantManager: RestaurantManager = RestaurantManager.shared) {
        self.restaurantManager = restaurantManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        return search
    }()
    
    var tableView: UITableView = {
        var tableview = UITableView()
        tableview.register(RestaurantTableViewCell.self, forCellReuseIdentifier: "restaurantCell")
        tableview.separatorStyle = .none
        tableview.translatesAutoresizingMaskIntoConstraints = false
        return tableview
    }()
    
    var spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = NSLocalizedString("restaurants", comment: "")
        
        searchController.searchBar.delegate = self
        self.navigationItem.searchController = searchController
        
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(spinner)
        
        spinner.startAnimating()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
    }
    
    func updatedLocation(_ location: CLLocation) {
        restaurantManager.fetchReasturantList(for: location, completionHandler: { [weak self] list in
            guard let strongSelf = self else { return }
            strongSelf.restaurantList = list
            DispatchQueue.main.async {
                strongSelf.spinner.stopAnimating()
                strongSelf.tableView.reloadData()
                if list.count == 0 {
                    strongSelf.delegate?.showAlert(with: ServerError.serverError)
                }
            }
        })
    }
}

extension RestaurantListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "restaurantCell", for: indexPath) as! RestaurantTableViewCell
        cell.configure(restaurantList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let resturant = restaurantList[indexPath.row]
        delegate?.checkDetailsfor(resturant)
    }
}

extension RestaurantListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        pendingRequestWorkItem?.cancel()
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.getList(contains: searchText)
        }
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250),
                                      execute: requestWorkItem)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true)
        showDefaultList()
    }
    
    func getList(contains searchText: String) {
        if searchText.isEmpty {
            showDefaultList()
        } else {
            restaurantManager.fetchResturantList(with: searchText, completionHandler: { [weak self] list in
                guard let strongSelf = self else { return }
                strongSelf.restaurantList = list
                DispatchQueue.main.async {
                    strongSelf.tableView.reloadData()
                }
            })
        }
    }
    
    func showDefaultList() {
        self.restaurantList = restaurantManager.fetchAllResturants()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
