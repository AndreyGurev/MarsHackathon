//
//  ProductCardPresenter.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit
import SwiftMessages

protocol ProductCardPresenterOutput: class {
    func presenterDidLoadItems()
}

class ProductCardPresenter: NSObject {
    private var gateWay = BaseGateway()
    
    private weak var output: ProductCardPresenterOutput?
    private(set) var item: ProductCardItem?

    init(output: ProductCardPresenterOutput) {
        self.output = output
    }
    
    public func loadItem(id: String?) {
        gateWay.getRequest(url: "getGood", parameters: ["id": id!]) { data in
            self.item = ProductCardPresenter.map(with: data)
        } error: { err in
            let error = MessageView.viewFromNib(layout: .tabView)
            error.configureTheme(.error)
            error.configureContent(title: "Error", body: "Something is horribly wrong!")
            error.button?.setTitle("ok", for: .normal)
            
            SwiftMessages.show(view: error)
        } finally: {
            self.output?.presenterDidLoadItems()
        }
    }
    
    static func map(with response: Any) -> ProductCardItem? {
        guard let data = response as? [String: Any] else { return nil }
        
        if let id = data["id"] as? String,
            let parentId = data["parentId"] as? String,
            let name = data["name"] as? String,
            let isAr = data["isAR"] as? Bool,
            let price = data["price"] as? Double,
            let description = data["description"] as? String,
            let images = data["images"] as? [String]
        {
            return ProductCardItem(id: id, name: name, parentId: parentId, isAr: isAr, price: price, description: description, images: images)
        }
        
        return nil
    }
}
