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
    @Binding public var hasNextPage: Bool
    @Binding private var isScrolledUp: Bool
    @State var message: String = ""
    @State var scrollingUp: Bool = false
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
    private var shouldShowAvatar: Bool
    private var defaultChatInfo: String?

    @Binding private var scrollToBottom: Bool
    
    private var messageEditorHeight: CGFloat {
        min(
            50,
            0.25 * UIScreen.main.bounds.height
        )
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                chatView(in: geometry)
                PIPVideoCell<Message>()
            }
        }
        .environmentObject(DeviceOrientationInfo())
        .environmentObject(VideoManager<Message>())
        .iOS { $0.dismissKeyboardOnTappingOutside() }
    }
    
    @ViewBuilder private func chatView(in geometry: GeometryProxy) -> some View {
//        VStack {
        ScrollViewReader { proxy in
            if let defaultInfo = defaultChatInfo {
                Text(defaultInfo)
                    .font(.subheadline)
                    .padding(.vertical)
            }
            //
            //                LazyVStack {
            List(messages) { message in
                messagesContent(message: message, geometry: geometry)
                    .onAppear{
                        listItemAppears(message)
                    }
            }  .simultaneousGesture(
                DragGesture().onChanged({
                    isScrolledUp = 0 < $0.translation.height
                    scrollingUp = 0 < $0.translation.height
                }))
            
            Spacer()
                .id("bottom")
                .onChange(of: scrollToBottom) { value in
                    if value {
                        withAnimation {
                            proxy.scrollTo("bottom")
                        }
                        scrollToBottom = false
                    }
                }
                .onChange(of: loadMore) { value in
                    if !value {
                        withAnimation {
                            proxy.scrollTo(previousLastMessageId, anchor: .top)
                        }
                    }
                }
            //            }
            //        }
            
        }
        .background(Color.clear)
        .safeAreaInset(edge: .bottom) { inputView().background(Color(UIColor.systemBackground))}
    }
 
    private func messagesContent(message: Message, geometry: GeometryProxy) -> some View {
        Group {
                if self.messages.isLastItem(message) && loadMore && hasNextPage {
                    Text("Loading ...")
                        .padding(.vertical)
                }
                let showDateheader = shouldShowDateHeader(
                    messages: messages,
                    thisMessage: message
                )
                let shouldShowDisplayName = shouldShowDisplayName(
                    messages: messages,
                    thisMessage: message,
                    dateHeaderShown: showDateheader
                )
                
                if showDateheader {
                    VStack(alignment: .center) {
                        Text(dateFormater.string(from: message.date))
                            .font(.subheadline)
                    }
                    .frame(width: geometry.size.width)
                }
                
                if shouldShowDisplayName {
                    Text(message.user.userName)
                        .font(.caption)
                        .font(.system(size: 13))
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.trailing)
                        .frame(
                            maxWidth: geometry.size.width,
                            minHeight: 1,
                            alignment: message.isSender ? .trailing: .leading
                        ).padding(.horizontal)
                }
                chatMessageCellContainer(in: geometry.size, with: message, with: shouldShowAvatar)
            }
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
        .contextMenu(menuItems: { messageCellContextMenu(message) })
        .modifier(
            AvatarModifier<Message, User>(
                message: message,
                showAvatarForMessage: shouldShowAvatarForMessage (
                    forThisMessage: avatarShow
                )
            )
        )
        .modifier(MessageHorizontalSpaceModifier(messageKind: message.messageKind, isSender: message.isSender))
        .modifier(CellEdgeInsetsModifier(isSender: message.isSender, message: message))
        .id(message.id)
    }
}

public extension ChatView {
    func shouldShowDateHeader(messages: [Message], thisMessage: Message) -> Bool {
        if let messageIndex = messages.firstIndex(where: { $0.id == thisMessage.id }) {
            if messageIndex == 0 { return true }
            let prevMessage = messages[messageIndex]
            let currMessage = messages[messageIndex - 1]
            let timeInterval = prevMessage.date - currMessage.date
            return timeInterval > dateHeaderTimeInterval
        }
        return false
    }
    
    func shouldShowDisplayName(
        messages: [Message],
        thisMessage: Message,
        dateHeaderShown: Bool
    ) -> Bool {
        switch thisMessage.messageKind {
        case .left(_), .join(_), .updated(_):
            return false
        default:
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
        defaultChatInfo: String? = nil,
        scrollToBottom: Binding<Bool> = .constant(false),
        loadMore: Binding<Bool> = .constant(false),
        isScrolledUp: Binding<Bool> = .constant(false),
        hasNextPage: Binding<Bool> = .constant(false),
        previousLastMessageId: String,
        dateHeaderTimeInterval: TimeInterval = 3600,
        shouldShowGroupChatHeaders: Bool = false,
        shouldShowAvatar: Bool = false,
        inputView: @escaping () -> AnyView,
        inset: EdgeInsets = .init()
    ) {
        _messages = messages
        self.defaultChatInfo = defaultChatInfo
        self.inputView = inputView
        _loadMore = loadMore
        _isScrolledUp = isScrolledUp
        _scrollToBottom = scrollToBottom
        _hasNextPage = hasNextPage
        self.previousLastMessageId = previousLastMessageId
        self.inset = inset
        self.dateFormater.dateStyle = .medium
        self.dateFormater.timeStyle = .short
        self.dateFormater.timeZone = NSTimeZone.local
        self.dateFormater.doesRelativeDateFormatting = true
        self.dateHeaderTimeInterval = dateHeaderTimeInterval
        self.shouldShowGroupChatHeaders = shouldShowGroupChatHeaders
        self.shouldShowAvatar = shouldShowAvatar
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
            if scrollingUp && hasNextPage {
                loadMore = true
            }
            
            
        }
    }
}
