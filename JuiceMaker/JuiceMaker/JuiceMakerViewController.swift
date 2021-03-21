//
//  JuiceMaker - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom academy. All rights reserved.
// 

import UIKit

final class JuiceMakerViewController: UIViewController {
    @IBOutlet private weak var strawberryStockLabel: UILabel!
    @IBOutlet private weak var bananaStockLabel: UILabel!
    @IBOutlet private weak var pineappleStockLabel: UILabel!
    @IBOutlet private weak var kiwiStockLabel: UILabel!
    @IBOutlet private weak var mangoStockLabel: UILabel!
    
    @IBOutlet private weak var strawberryJuiceOrderButton: UIButton!
    @IBOutlet private weak var bananaJuiceOrderButton: UIButton!
    @IBOutlet private weak var pineappleJuiceOrderButton: UIButton!
    @IBOutlet private weak var kiwiJuiceOrderButton: UIButton!
    @IBOutlet private weak var mangoJuiceOrderButton: UIButton!
    @IBOutlet private weak var strawberryBananaJuiceOrderButton: UIButton!
    @IBOutlet private weak var mangoKiwiJuiceOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFruitStock()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateFruitStock(_:)), name: Notification.Name("didStockChanged"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        initializeFruitStock()
    }

    private func makeOrderedJuice(menu: JuiceTypes) {
        if JuiceMaker().didMakeJuice(of: menu) {
            showOrderSuccessAlert(menu: menu)
        } else {
            showOrderFailAlert()
        }
    }
    
    @objc private func updateFruitStock(_ notification: Notification) {
        guard let fruit = notification.object as? FruitTypes else { return }
        switch fruit {
        case .strawberry:
            strawberryStockLabel.text = FruitStorage.shared.stockCount(of: .strawberry)
        case .banana:
            bananaStockLabel.text = FruitStorage.shared.stockCount(of: .banana)
        case .kiwi:
            kiwiStockLabel.text = FruitStorage.shared.stockCount(of: .kiwi)
        case .mango:
            mangoStockLabel.text = FruitStorage.shared.stockCount(of: .mango)
        case .pineapple:
            pineappleStockLabel.text = FruitStorage.shared.stockCount(of: .pineapple)
        }
    }
    
    func initializeFruitStock() {
        strawberryStockLabel.text = FruitStorage.shared.stockCount(of: .strawberry)
        bananaStockLabel.text = FruitStorage.shared.stockCount(of: .banana)
        pineappleStockLabel.text = FruitStorage.shared.stockCount(of: .pineapple)
        kiwiStockLabel.text = FruitStorage.shared.stockCount(of: .kiwi)
        mangoStockLabel.text = FruitStorage.shared.stockCount(of: .mango)
    }

    private func showOrderSuccessAlert(menu: JuiceTypes) {
        let alert = UIAlertController(title: nil, message: "\(menu) 나왔습니다! 맛있게 드세요!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showOrderFailAlert() {
        let alert = UIAlertController(title: nil, message: "재고가 모자라요. 재고를 수정할까요?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "예", style: .default) { (action) in
            self.moveStockManagerVC()
        }
        let cancelAction = UIAlertAction(title: "아니오", style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func moveStockManagerVC() {
        guard let stockManagerVC = self.storyboard?.instantiateViewController(withIdentifier: "StockManagerVC") as? StockManagerViewController else { return }
        self.present(stockManagerVC, animated: true, completion: nil)
    }

    @IBAction private func touchUpJuiceOrderButton(_ sender: UIButton) {
        switch sender {
        case strawberryJuiceOrderButton:
            makeOrderedJuice(menu: .strawberryJuice)
        case bananaJuiceOrderButton:
            makeOrderedJuice(menu: .bananaJuice)
        case pineappleJuiceOrderButton:
            makeOrderedJuice(menu: .pineappleJuice)
        case kiwiJuiceOrderButton:
            makeOrderedJuice(menu: .kiwiJuice)
        case mangoJuiceOrderButton:
            makeOrderedJuice(menu: .mangoJuice)
        case mangoKiwiJuiceOrderButton:
            makeOrderedJuice(menu: .mangoKiwiJuice)
        case strawberryBananaJuiceOrderButton:
            makeOrderedJuice(menu: .strawberryBananaJuice)
        default:
            return
        }
    }
}

