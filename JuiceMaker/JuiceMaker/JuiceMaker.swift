//
//  JuiceMaker - JuiceMaker.swift
//  Created by yagom.
//  Copyright © yagom academy. All rights reserved.
//
import Foundation

struct JuiceMaker {
    func didMakeJuice(of orderedMenu: JuiceTypes) -> Bool {
        for (fruitType, requiredAmount) in orderedMenu.recipe() {
            if FruitStorage.shared.isStockExist(fruitType, requiredAmount) {
                FruitStorage.shared.subtractStock(fruitType, requiredAmount)
                } else { return false }
            }
        return true
    }
}
