//
//  CatalogViewController.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit

final class CatalogViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private lazy var presenter = CatalogPresenter(output: self)
    private lazy var catalogTableViewManager = CatalogCollectionViewManager(collectionView: collectionView, dataSource: self)
        
    private var categoryId: String?
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 25, height: 25)))
        activityIndicator.tintColor = .systemOrange

        return activityIndicator
    }()
    
    static func make(id: String?) -> CatalogViewController {
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CatalogVC") as! CatalogViewController
        vc.categoryId = id
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.isHidden = true
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        presenter.loadCatalog(id: categoryId)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Каталог товаров"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationItem.title = ""
    }
}

extension CatalogViewController: CatalogPresenterOutput {
    func presenterDidLoadItems() {
        activityIndicator.stopAnimating()
        if activityIndicator.superview != nil {
            activityIndicator.removeFromSuperview()
        }
        
        collectionView.isHidden = false
        catalogTableViewManager.reloadData()
    }
    
    func presetnerDidSelect(index: Int) {
        let item = presenter.items[index]
        
        var vc: UIViewController?
        if item.isFolder {
            vc = CatalogViewController.make(id: item.id)
        } else {
            vc = ProductCardViewController.make(productId: item.id)
        }
        
        if vc != nil {
            navigationController?.pushViewController(vc!, animated: true)
        }
    }
}

extension CatalogViewController: CatalogCollectionViewManagerDataSourse {
    var items: [ProductItem] {
        presenter.items
    }
}

