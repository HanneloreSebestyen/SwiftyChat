//
//  File.swift
//  
//
//  Created by Hanne Sebestyen on 22.12.2022.
//

import Foundation
import SwiftUI
import SwiftyChat

public class BasicViewModel: ObservableObject {
    @Published var messages: [MockMessages.ChatMessageItem] = MockMessages.generateMessage(kind: .Text, count: 20)
    
    init() {
        
    }
    
    func addMessage(message: MockMessages.ChatMessageItem) {
        messages.append(message)
    }
}
