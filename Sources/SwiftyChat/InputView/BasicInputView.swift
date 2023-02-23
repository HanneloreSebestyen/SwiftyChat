//
//  BasicInputView.swift
//  
//
//  Created by Enes Karaosman on 19.10.2020.
//

import SwiftUI

public struct BasicInputView: View {
    
    @Binding private var message: String
    @Binding private var isEditing: Bool
    private let placeholder: String

    private var onCommit: ((ChatMessageKind) -> Void)?
    
    public init(
        message: Binding<String>,
        isEditing: Binding<Bool>,
        placeholder: String = "",
        onCommit: @escaping (ChatMessageKind) -> Void
    ) {
        self._message = message
        self.placeholder = placeholder
        self._isEditing = isEditing
        self.onCommit = onCommit
    }

    private var messageEditorView: some View {
        TextEditor(text: $message)
                .frame(height: 40)
    }

    private var sendButton: some View {
        Button(action: {
            self.onCommit?(.text(message))
            self.message.removeAll()
        }, label: {
            Circle().fill(Color(.systemBlue))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .offset(x: -1, y: 1)
                        .padding(8)
                )
        })
        .disabled(message.isEmpty)
    }

    public var body: some View {
        VStack {
            Divider()
            HStack {
                self.messageEditorView
                self.sendButton
            }
        }
    }
    
}
