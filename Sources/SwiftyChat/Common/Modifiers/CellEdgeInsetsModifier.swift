//
//  CellEdgeInsetsModifier.swift
//  
//
//  Created by Enes Karaosman on 4.08.2020.
//

import SwiftUI

internal struct CellEdgeInsetsModifier: ViewModifier {
    
    public let isSender: Bool
    public let message: any ChatMessage
    
    @EnvironmentObject var style: ChatMessageCellStyle
    
    private var insets: EdgeInsets {
        switch message.messageKind {
        case .left, .join:
            return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        default:
            return isSender ? style.outgoingCellEdgeInsets : style.incomingCellEdgeInsets
        }
    }
    
    public func body(content: Content) -> some View {
        content.padding(insets)
    }
    
}
