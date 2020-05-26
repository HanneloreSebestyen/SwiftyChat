//
//  ChatView.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 19.05.2020.
//  Copyright © 2020 All rights reserved.
//

import SwiftUI

public struct ChatView: View {
    
    @Binding public var messages: [ChatMessage]
    public var inputView: (_ proxy: GeometryProxy) -> AnyView

    private var onMessageCellTapped: (ChatMessage) -> Void = { msg in print(msg.messageKind) }
    private var messageCellContextMenu: (ChatMessage) -> AnyView = { _ in EmptyView().embedInAnyView() }
    private var onQuickReplyItemSelected: (QuickReplyItem) -> Void = { _ in }
    private var contactCellFooterButtons: [ContactCellButton] = []
    
    public init(
        messages: Binding<[ChatMessage]>,
        inputView: @escaping (_ proxy: GeometryProxy) -> AnyView
    ) {
        self._messages = messages
        self.inputView = inputView
    }
    
    /// Triggered when a ChatMessage is tapped.
    public func onMessageCellTapped(_ action: @escaping (ChatMessage) -> Void) -> ChatView {
        var copy = self
        copy.onMessageCellTapped = action
        return copy
    }
    
    /// Present ContextMenu when a message cell is long pressed.
    public func messageCellContextMenu(_ action: @escaping (ChatMessage) -> AnyView) -> ChatView {
        var copy = self
        copy.messageCellContextMenu = action
        return copy
    }
    
    /// Triggered when a quickReplyItem is selected (ChatMessageKind.quickReply)
    public func onQuickReplyItemSelected(_ action: @escaping (QuickReplyItem) -> Void) -> ChatView {
        var copy = self
        copy.onQuickReplyItemSelected = action
        return copy
    }
    
    /// Present contactItem's footer buttons. (ChatMessageKind.contactItem)
    public func contactItemButtons(_ buttons: [ContactCellButton]) -> ChatView {
        var copy = self
        copy.contactCellFooterButtons = buttons
        return copy
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                
                List {
                    ForEach(self.messages) { message in
                        ChatMessageCellContainer(
                            message: message,
                            proxy: proxy,
                            onQuickReplyItemSelected: self.onQuickReplyItemSelected,
                            footerButtons: self.contactCellFooterButtons
                        )
                        .onTapGesture {
                            self.onMessageCellTapped(message)
                        }
                        .contextMenu(menuItems: {
                            self.messageCellContextMenu(message)
                        })
                        .modifier(MessageModifier(isSender: message.isSender))
                    }
                }
                .padding(.bottom, proxy.safeAreaInsets.bottom + 56)
                
                self.inputView(proxy)
                
            }.keyboardAwarePadding()
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            // To remove only extra separators below the list:
            UITableView.appearance().tableFooterView = UIView()
            // To remove all separators including the actual ones:
            UITableView.appearance().separatorStyle = .none
        }
    }
    
}
