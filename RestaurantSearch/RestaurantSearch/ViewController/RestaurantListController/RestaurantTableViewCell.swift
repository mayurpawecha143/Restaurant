//
//  RestaurantTableViewCell.swift
//  RestaurantSearch
//
//  Created by Mayur Pawecha on 12/5/22.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    var baseView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.6
        view.layer.borderColor = CGColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        view.layer.cornerRadius = 3.0
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var horizontalView: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .horizontal
        stackview.distribution = .equalSpacing
        stackview.alignment = .center
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }()
    
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
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var rating: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var price: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var spinner = UIActivityIndicatorView(style: .medium)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func addViews() {
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        imageview.addSubview(spinner)
        
        horizontalView.addArrangedSubview(rating)
        horizontalView.addArrangedSubview(price)
        
        baseView.addSubview(imageview)
        baseView.addSubview(name)
        baseView.addSubview(horizontalView)
        self.addSubview(baseView)
    
        NSLayoutConstraint.activate([
            baseView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3),
            baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3),
            baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 3),
            baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -3),
            
            imageview.topAnchor.constraint(equalTo: baseView.topAnchor),
            imageview.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            imageview.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            imageview.heightAnchor.constraint(equalToConstant: 200),
            
            spinner.centerXAnchor.constraint(equalTo: imageview.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: imageview.centerYAnchor),
            
            name.topAnchor.constraint(equalTo: imageview.bottomAnchor),
            name.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 5),
            name.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -5),
            
            horizontalView.topAnchor.constraint(equalTo: name.bottomAnchor),
            horizontalView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor, constant: 5),
            horizontalView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor, constant: -5)
        ])
    }
    
    func configure(_ restaurant: Restaurant) {
        name.text = restaurant.name
        let ratingText = NSLocalizedString("rating", comment: "")
        let priceText = NSLocalizedString("price", comment: "")
        rating.text = "\(ratingText): \(restaurant.rating)"
        price.text = "\(priceText): \(restaurant.price)"
        downloadImage(restaurant)
    }
    
    func downloadImage(_ restaurant: Restaurant, _ imageDownloader: ImageDownloader = ImageDownloadManager.shared) {
        spinner.startAnimating()
        imageDownloader.downloadImage(with: restaurant.imageUrl, id: restaurant.id, completionHandler: {[weak self] result in
            guard let storngSelf = self else { return }
            DispatchQueue.main.async {
                storngSelf.spinner.stopAnimating()
            }
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    storngSelf.imageview.image = image
                }
                
            case .failure(let error):
                print("Error: \(error)")
            }
        })
    }
}
