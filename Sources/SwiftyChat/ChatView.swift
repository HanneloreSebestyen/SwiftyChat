//
//  ChatView.swift
//  SwiftyChatbot
//
//  Created by Enes Karaosman on 19.05.2020.
//  Copyright © 2020 All rights reserved.
//

import SwiftUI
import SwiftUIEKtensions

public struct ChatView<Message: ChatMessage, User: ChatUser>: View {
    
    @Binding private var messages: [Message]
    @Binding public var loadMore: Bool
    @Binding private var isScrolledUp: Bool
    @State var message: String = ""
    private let offset: Int = 10
    
    private var inputView: () -> AnyView
    private var previousLastMessageId: String
    
    private var onMessageCellTapped: (Message) -> Void = { msg in print(msg.messageKind) }
    private var messageCellContextMenu: (Message) -> AnyView = { _ in EmptyView().embedInAnyView() }
    private var onQuickReplyItemSelected: (QuickReplyItem) -> Void = { _ in }
    private var contactCellFooterSection: (ContactItem, Message) -> [ContactCellButton] = { _, _ in [] }
    private var onAttributedTextTappedCallback: () -> AttributedTextTappedCallback = { return AttributedTextTappedCallback() }
    private var onCarouselItemAction: (CarouselItemButton, Message) -> Void = { (_, _) in }
    private var inset: EdgeInsets
    private var dateFormater: DateFormatter = DateFormatter()
    private var dateHeaderTimeInterval: TimeInterval
    private var shouldShowGroupChatHeaders: Bool
    @State private var menuIsPresented: Bool = false
    @Binding private var scrollToBottom: Bool
    
    private var messageEditorHeight: CGFloat {
        min(
            50,
            0.25 * UIScreen.main.bounds.height
        )
    }
    
    public var body: some View {
        VStack {
            chatView()
//            inputView()
//                .padding(.horizontal)
//                .padding(.vertical, 8)
        }
        
    }
    
    @ViewBuilder private func chatView() -> some View {
        ScrollView {
            ScrollViewReader { scrollViewProxy in
                ForEach(messages) { message in
                    HStack {
                        Spacer()
                        HStack {
                            //  chatMessageCellContainer(in: CGSize(width: 200, height: 50), with: message, with: false)
                            Text(message.messageKind.description)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                HStack { Spacer() }
                    .id("bottom")
                    .onChange(of: scrollToBottom) { value in
                        if value {
                            withAnimation {
                                scrollViewProxy.scrollTo("bottom")
                            }
                            scrollToBottom = false
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) { inputView().background(Color.white)}
    }
}
    
    internal extension ChatView {
        // MARK: - List Item
        private func chatMessageCellContainer(
            in size: CGSize,
            with message: Message,
            with avatarShow: Bool
        ) -> some View {
            ChatMessageCellContainer(
                message: message,
                size: size,
                onQuickReplyItemSelected: onQuickReplyItemSelected,
                contactFooterSection: contactCellFooterSection,
                onTextTappedCallback: onAttributedTextTappedCallback,
                onCarouselItemAction: onCarouselItemAction
            )
            .onTapGesture { onMessageCellTapped(message) }
            .onLongPressGesture(perform: {
                switch message.messageKind {
                case .text(let text):
                    menuIsPresented = true
                    self.message = text
                default:
                    break
                }

                print(message.messageKind.description)
                print(message.id)
            })
            .modifier(
                AvatarModifier<Message, User>(
                    message: message,
                    showAvatarForMessage: shouldShowAvatarForMessage(
                        forThisMessage: avatarShow
                    )
                )
            )
            .modifier(MessageHorizontalSpaceModifier(messageKind: message.messageKind, isSender: message.isSender))
            .modifier(CellEdgeInsetsModifier(isSender: message.isSender))
            .id(message.id)
        }

        private func emptyView() -> some View {
            menuIsPresented = false
            return  EmptyView()
        }

    }

    public extension ChatView {
        func shouldShowDateHeader(messages: [Message], thisMessage: Message) -> Bool {
            if let messageIndex = messages.firstIndex(where: { $0.id == thisMessage.id }) {
                if messageIndex == messages.count - 1 { return true }
                let prevMessage = messages[messageIndex + 1]
                let currMessage = messages[messageIndex]
                let timeInterval = currMessage.date - prevMessage.date
                return timeInterval > dateHeaderTimeInterval
            }
            return false
        }

        func shouldShowDisplayName(
            messages: [Message],
            thisMessage: Message,
            dateHeaderShown: Bool
        ) -> Bool {
            if !shouldShowGroupChatHeaders {
                return false
            } else if dateHeaderShown {
                return true
            }

            if let messageIndex = messages.firstIndex(where: { $0.id == thisMessage.id }) {
                if messageIndex == 0 { return true }
                let prevMessageUserID = messages[messageIndex].user.id
                let currMessageUserID = messages[messageIndex - 1].user.id
                return !(prevMessageUserID == currMessageUserID)
            }

            return false
        }

        func shouldShowAvatarForMessage(forThisMessage: Bool) -> Bool {
            (forThisMessage || !shouldShowGroupChatHeaders)
        }
    }

    // MARK: - Initializers
    public extension ChatView {
        /// ChatView constructor
        /// - Parameters:
        ///   - messages: Messages to display
        ///   - scrollToBottom: set to `true` to scrollToBottom
        ///   - dateHeaderTimeInterval: Amount of time between messages in
        ///                             seconds required before dateheader added
        ///                             (Default 1 hour)
        ///   - shouldShowGroupChatHeaders: Shows the display name of the sending
        ///                                 user only if it is the first message in a chain.
        ///                                 Also only shows avatar for first message in chain.
        ///                                 (disabled by default)
        ///   - inputView: inputView view to provide message
        ///
        init(
            messages: Binding<[Message]>,
            scrollToBottom: Binding<Bool> = .constant(false),
            loadMore: Binding<Bool> = .constant(false),
            isScrolledUp: Binding<Bool> = .constant(false),
            previousLastMessageId: String,
            dateHeaderTimeInterval: TimeInterval = 3600,
            shouldShowGroupChatHeaders: Bool = false,
            inputView: @escaping () -> AnyView,
            inset: EdgeInsets = .init()
        ) {
            _messages = messages
            self.inputView = inputView
            _loadMore = loadMore
            _isScrolledUp = isScrolledUp
            _scrollToBottom = scrollToBottom
            self.previousLastMessageId = previousLastMessageId
            self.inset = inset
            self.dateFormater.dateStyle = .medium
            self.dateFormater.timeStyle = .short
            self.dateFormater.timeZone = NSTimeZone.local
            self.dateFormater.doesRelativeDateFormatting = true
            self.dateHeaderTimeInterval = dateHeaderTimeInterval
            self.shouldShowGroupChatHeaders = shouldShowGroupChatHeaders
        }
    }

    public extension ChatView {
        /// Triggered when a ChatMessage is tapped.
        func onMessageCellTapped(_ action: @escaping (Message) -> Void) -> Self {
            then({ $0.onMessageCellTapped = action })
        }

        /// Present ContextMenu when a message cell is long pressed.
        func messageCellContextMenu(_ action: @escaping (Message) -> AnyView) -> Self {
            return then({ $0.messageCellContextMenu = action})
        }

        /// Triggered when a quickReplyItem is selected (ChatMessageKind.quickReply)
        func onQuickReplyItemSelected(_ action: @escaping (QuickReplyItem) -> Void) -> Self {
            then({ $0.onQuickReplyItemSelected = action })
        }

        /// Present contactItem's footer buttons. (ChatMessageKind.contactItem)
        func contactItemButtons(_ section: @escaping (ContactItem, Message) -> [ContactCellButton]) -> Self {
            then({ $0.contactCellFooterSection = section })
        }

        /// To listen text tapped events like phone, url, date, address
        func onAttributedTextTappedCallback(action: @escaping () -> AttributedTextTappedCallback) -> Self {
            then({ $0.onAttributedTextTappedCallback = action })
        }

        /// Triggered when the carousel button tapped.
        func onCarouselItemAction(action: @escaping (CarouselItemButton, Message) -> Void) -> Self {
            then({ $0.onCarouselItemAction = action })
        }
    }

    public extension ChatView {
        private func listItemAppears<Message: Identifiable>(_ item: Message) {
            if messages.isThresholdItem(offset: offset,
                                        item: item) {
                loadMore = true
            }
        }
    }





