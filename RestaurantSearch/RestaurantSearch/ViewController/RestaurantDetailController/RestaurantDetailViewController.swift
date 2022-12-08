//
//  RestaurantDetailViewController.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/7/22.
//

import UIKit

class RestaurantDetailViewController: UIViewController {

    var openTimeList: [OpenHours] = []
    
    var restaurant: Restaurant
    let restaurantManager: RestaurantManager
    let imageDownloader: ImageDownloader
    init(restaurant: Restaurant, restaurantManager: RestaurantManager = RestaurantManager.shared, imageDownloader: ImageDownloader = ImageDownloadManager.shared) {
        self.restaurant = restaurant
        self.restaurantManager = restaurantManager
        self.imageDownloader = imageDownloader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageview: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "cell_background")
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()
    
    var name: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var rating: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var phone: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var openHourLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        let openHoursText = NSLocalizedString("open_hours", comment: "")
        label.text = openHoursText
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var tableView: UITableView = {
        var tableview = UITableView()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "timeCell")
        tableview.separatorStyle = .none
        tableview.translatesAutoresizingMaskIntoConstraints = false
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        addViews()
        requestDetails()
        updateDetails()
    }
    
    func requestDetails() {
        restaurantManager.fetchReasturantDetails(for: restaurant.id, completionHandler: { newRestaurant in
            guard let restaurant = newRestaurant else { return }
            self.restaurant = restaurant
            DispatchQueue.main.async { [weak self] in
                guard let storngSelf = self else { return }
                if let list = storngSelf.restaurant.hours?.first?.open {
                    storngSelf.openTimeList = list
                    if list.count > 0 {
                        storngSelf.openHourLabel.isHidden = false
                    }
                    storngSelf.tableView.reloadData()
                }
            }
        })
    }
    
    func updateDetails() {
        self.name.text = restaurant.name
        let ratingText = NSLocalizedString("rating", comment: "")
        let callText = NSLocalizedString("call", comment: "")
        self.rating.text = "\(ratingText): \(restaurant.rating) (\(restaurant.reviewCount))"
        self.phone.text = "\(callText): \(restaurant.phone)"
        downloadImage(restaurant)
    }
    
    func downloadImage(_ restaurant: Restaurant) {
        imageDownloader.downloadImage(with: restaurant.imageUrl, id: restaurant.id, completionHandler: {result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async { [weak self] in
                    guard let storngSelf = self else { return }
                    storngSelf.imageview.image = image
                }
                
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
    
    func addViews() {
        self.view.addSubview(name)
        self.view.addSubview(rating)
        self.view.addSubview(phone)
        self.view.addSubview(imageview)
        self.view.addSubview(openHourLabel)
        openHourLabel.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            name.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100),
            name.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            name.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            
            rating.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5),
            rating.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            rating.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            
            phone.topAnchor.constraint(equalTo: rating.bottomAnchor, constant: 5),
            phone.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            phone.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            
            imageview.topAnchor.constraint(equalTo: phone.bottomAnchor, constant: 5),
            imageview.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            imageview.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            imageview.heightAnchor.constraint(equalToConstant: 200),
            
            openHourLabel.topAnchor.constraint(equalTo: imageview.bottomAnchor, constant: 10),
            openHourLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 5),
            openHourLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -5),
            
            tableView.topAnchor.constraint(equalTo: openHourLabel.bottomAnchor, constant: 5),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

extension RestaurantDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return openTimeList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeCell", for: indexPath)
        let value = openTimeList[indexPath.row]
        cell.textLabel?.text = getOpenHoursString(value)
        return cell
    }
    
    func getOpenHoursString(_ openHour: OpenHours) -> String {
        
        let day = getDay(from: openHour.day)
        let start = getTime(from: openHour.start)
        let end = getTime(from: openHour.end)
        return "\(day) : \(start) - \(end) "
    }
    
    func getTime(from hours: String) -> String {
        if let hour = Int(hours.prefix(2)) {
            if hour < 12 {
                return "\(hour):\(hours.suffix(2)) AM"
            } else {
                return "\(hour - 12):\(hours.suffix(2)) PM"
            }
        }
        return ""
    }
    
    func getDay(from value: Int64) -> String {
        switch value {
        case 0:
            return NSLocalizedString("monday", comment: "")
        case 1:
            return NSLocalizedString("tuesday", comment: "")
        case 2:
            return NSLocalizedString("wednesday", comment: "")
        case 3:
            return NSLocalizedString("thursday", comment: "")
        case 4:
            return NSLocalizedString("friday", comment: "")
        case 5:
            return NSLocalizedString("saturday", comment: "")
        case 6:
            return NSLocalizedString("sunday", comment: "")
        default:
            return NSLocalizedString("sunday", comment: "")
        }
    }
}
