//
//  File.swift
//  
//
//  Created by Hanne Sebestyen on 20.12.2022.
//

import Foundation

extension RandomAccessCollection where Self.Element: Identifiable {
    public func isLastItem<Item: Identifiable>(_ item: Item) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = firstIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        
        let distance = self.distance(from: startIndex, to: itemIndex)
        return distance == 0
    }
    
    public func isThresholdItem<Item: Identifiable>(
        offset: Int,
        item: Item
    ) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = lastIndex(where: { AnyHashable($0.id) == AnyHashable(item.id) }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: startIndex)
        let offset = offset < count ? offset : count - 1
        return offset == abs(distance)
    }
}
