//
//  ProductCardItem.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit

class ProductCardItem {
    let id: String
    let parentId: String
    let name: String
    let isAr: Bool
    let price: Double
    let description: String
    let images: [String]
    
    init(id: String, name: String, parentId: String, isAr: Bool, price: Double, description: String, images: [String]) {
        self.id = id
        self.name = name
        self.parentId = parentId
        self.isAr = isAr
        self.price = price
        self.description = description
        self.images = images
    }
}
