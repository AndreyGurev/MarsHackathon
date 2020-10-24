//
//  CatalogCollectionViewManager.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit

protocol CatalogCollectionViewManagerDataSourse: class {
    var items: [ProductItem] { get }
}

final class CatalogCollectionViewManager: NSObject {
    private var collectionView: UICollectionView?
    private weak var dataSource: CatalogCollectionViewManagerDataSourse?
    
    init(collectionView: UICollectionView, dataSource: CatalogCollectionViewManagerDataSourse) {
        super.init()
        
        self.dataSource = dataSource
        self.config(collectionView: collectionView)
    }
    
    public func reloadData() {
        collectionView?.reloadData()
    }
    
    private func config(collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.dataSource = self
                
        self.collectionView = collectionView
    }
}

extension CatalogCollectionViewManager: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width / 2 - 15
        return CGSize(width: collectionViewWidth, height: collectionViewWidth + 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension CatalogCollectionViewManager: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource?.items[indexPath.row].selectionHandler?(indexPath.row)
    }
}

extension CatalogCollectionViewManager: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.items.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = dataSource?.items[indexPath.row] else { return UICollectionViewCell() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatalogCollectionViewCell.reuseIdentifier, for: indexPath) as? CatalogCollectionViewCell else { return UICollectionViewCell() }
        
        cell.configure(with: item)
        
        return cell
    }
}
