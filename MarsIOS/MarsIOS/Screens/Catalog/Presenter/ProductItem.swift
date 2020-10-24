//
//  ProductItem.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit

final class ProductItem {
    let id: String
    let parentId: String
    let name: String
    let imgLink: String
    let price: Double
    let isFolder: Bool
    let isAr: Bool
    
    var selectionHandler: ((Int) -> ())?
    
    init(id: String, parentId: String, name: String, imgLink: String, price: Double, isFolder: Bool, isAr: Bool) {
        self.id = id
        self.name = name
        self.imgLink = imgLink
        self.price = price
        self.isFolder = isFolder
        self.isAr = isAr
        self.parentId = parentId        
    }
}
