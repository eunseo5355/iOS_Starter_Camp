//
//  JuiceMaker - Fruit.swift
//
//  Created by 배은서 on 2021/03/08.
//

import Foundation

enum FruitTypes {
    case strawberry, banana, kiwi, pineapple, mango
}

final class FruitStock {
    var storage: [FruitTypes: Int] = [:]

    init(_ storage: [FruitTypes: Int]) {
        self.storage = storage
    }
}

final class FruitStorage {
    static let shared = FruitStorage()
    
    private(set) var fruitInformation = FruitStock([
        .strawberry: 10,
        .banana: 10,
        .pineapple: 10,
        .kiwi: 10,
        .mango: 10
    ])
    
    func isStockExist(_ fruit: FruitTypes, _ requiredFruitAmount: Int) -> Bool {
        if let stock = fruitInformation.storage[fruit], stock >= requiredFruitAmount {
            return true
        } else { return false }
    }

    func subtractStock(_ fruit: FruitTypes, _ requiredFruitAmount: Int) {
        guard let stock = fruitInformation.storage[fruit] else { return }
        fruitInformation.storage[fruit] = stock - requiredFruitAmount
        NotificationCenter.default.post(name: Notification.Name("didStockChanged"), object: fruit)
    }

    func addStock(_ fruit: FruitTypes, _ amount: Int) {
        guard let stock = fruitInformation.storage[fruit] else { return }
        fruitInformation.storage[fruit] = stock + amount
        NotificationCenter.default.post(name: Notification.Name("didStockChanged"), object: fruit)
    }
    
    func stockCount(of fruit: FruitTypes) -> String? {
        guard let fruitStock = fruitInformation.storage[fruit] else { return nil }
        return String(fruitStock)
    }
}
