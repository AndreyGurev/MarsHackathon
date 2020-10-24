//
//  CatalogCollectionViewCell.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit
import AlamofireImage

final class CatalogCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "catalogCollectionViewCellReuseIdentifier"

    @IBOutlet weak var arEnableImageView: UIImageView!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func configure(with item: ProductItem) {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 5
        
        let imageData = Data(base64Encoded: item.imgLink, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        productImageView.image = UIImage(data: imageData)
        
        if item.isFolder {
            productPriceLabel.text = ""
            productNameLabel.numberOfLines = 3
        } else {
            arEnableImageView.image = UIImage(named: "ArIcon")
            productPriceLabel.text = "\(item.price)₽"
        }
        
        productNameLabel.text = item.name
    }
}
