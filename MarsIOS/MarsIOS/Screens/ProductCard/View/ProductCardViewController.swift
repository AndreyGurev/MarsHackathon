//
//  ProductCardViewController.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit

class ProductCardViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var arButton: UIButton!

    private lazy var presenter = ProductCardPresenter(output: self)
    
    private var productId: String?
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 25, height: 25)))
        activityIndicator.tintColor = .systemOrange
        
        return activityIndicator
    }()
    
    static func make(productId: String) -> ProductCardViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProductCardVC") as! ProductCardViewController
        vc.productId = productId
        return vc
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scrollView.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        scrollView.isHidden = true
        
        presenter.loadItem(id: productId!)
    }
    
    private func showCard() {
        guard let item = presenter.item else {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20))
            label.textAlignment = .center
            label.textColor = .lightGray
            label.text = "Не удалось загрузить информацию о товаре"
            view.addSubview(label)
            
            return
        }
        
        arButton.setImage(UIImage(named: "ArIconWhite")!, for: .normal)
        arButton.imageView?.contentMode = .scaleAspectFit
        arButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        arButton.layer.cornerRadius = arButton.bounds.width / 2
        
        scrollView.isHidden = false
    
        nameLabel.text = item.name
        priceLabel.text = "\(String(format: "%g", item.price))₽"
        descriptionLabel.text = item.description
        if !item.isAr {
            arButton.isHidden = true
        }
        
        let imageData = Data(base64Encoded: item.images[0], options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        imageView.image = UIImage(data: imageData)
    }
    
    @IBAction func onArTap(_ sender: Any) {
        self.present(ARViewController.make(id: presenter.item!.id), animated: true, completion: nil)
    }
}

extension ProductCardViewController: ProductCardPresenterOutput {
    func presenterDidLoadItems() {
        activityIndicator.stopAnimating()
        if activityIndicator.superview != nil {
            activityIndicator.removeFromSuperview()
        }
                
        activityIndicator.stopAnimating()
        scrollView.isHidden = false
        
        showCard()
    }
}
