//
//  MessageModifier.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 19.05.2020.
//  Copyright © 2020 All rights reserved.
//

import SwiftUI

internal struct MessageHorizontalSpaceModifier: ViewModifier {
    
    public var messageKind: ChatMessageKind
    public var isSender: Bool
    
    private var isSpaceFreeMessageKind: Bool {
        if case ChatMessageKind.carousel = messageKind {
            return true
        }
        return false
    }
    
    private var isUserActionInfo: Bool {
        if case ChatMessageKind.left(_) = messageKind {
            return true
        } else if case ChatMessageKind.join(_) = messageKind {
            return true
        }  else if case ChatMessageKind.updated(_) = messageKind {
            return true
        }
        return false
    }
    
    public func body(content: Content) -> some View {
        HStack(spacing: 0) {
            if isSender || isUserActionInfo {
                Spacer(minLength: 10)
            }
            content
            if !isSender && !isSpaceFreeMessageKind || isUserActionInfo {
                Spacer(minLength: 10)
            }
        }
    }
}
