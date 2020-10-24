//
//  CatalogPresenter.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit
import SwiftMessages

protocol CatalogPresenterOutput: class {
    func presenterDidLoadItems()
    func presetnerDidSelect(index: Int)
}

final class CatalogPresenter: NSObject {
    private var gateWay = BaseGateway()
    
    private weak var output: CatalogPresenterOutput?
    private(set) var items: [ProductItem] = []

    init(output: CatalogPresenterOutput) {
        self.output = output
    }
    
    static func map(with response: [String: Any]) -> ProductItem? {
        if let id = response["id"] as? String,
            let parentId = response["parentId"] as? String,
            let name = response["name"] as? String,
            let imgLink = response["preview"] as? String,
            let price = response["price"] as? Double,
            let isFolder = response["isFolder"] as? Bool,
            let isAr = response["isAR"] as? Bool
        {
            return ProductItem(id: id, parentId: parentId, name: name, imgLink: imgLink, price: price, isFolder: isFolder, isAr: isAr)
        }
        
        return nil
    }
    
    static func map(with response: Any) -> [ProductItem] {
        guard let data = response as? [[String: Any]] else { return [] }
        
        var records = [ProductItem]()
        for item in data {
            guard let record = map(with: item) else { continue }
            records.append(record)
        }
        
        return records
    }
    
    public func loadCatalog(id: String?) {
        gateWay.getRequest(url: "getCatalogItems", parameters: ["parentId": id ?? "00000000-0000-0000-0000-000000000000"]) { data in
            self.items = CatalogPresenter.map(with: data)
            self.items.forEach { item in
                item.selectionHandler = { [unowned self] index in
                    self.output?.presetnerDidSelect(index: index)
                }
            }
        } error: { err in
            let error = MessageView.viewFromNib(layout: .tabView)
            error.configureTheme(.error)
            error.configureContent(title: "Error", body: "Something is horribly wrong!")
            error.button?.setTitle("Stop", for: .normal)
            
            SwiftMessages.show(view: error)
        } finally: {
            self.output?.presenterDidLoadItems()
        }
    }
}
