//
//  SwiftUIView.swift
//  
//
//  Created by Hanne Sebestyen on 27.12.2022.
//

import SwiftUI

enum UserActionType: String {
    case join = "joined"
    case left = "left"
    case updated = "updated"
}

struct UserActionInfoCell: View {
    public let userName: String
    public let actionType: UserActionType
    public let size: CGSize

    
    @EnvironmentObject var style: ChatMessageCellStyle
    
    private var maxWidth: CGFloat {
        size.width * (UIDevice.isLandscape ? 0.6 : 0.75)
    }
    private var cellStyle: UserActionInfoCellStyle {
        style.userActionInfoStyle
    }
    
    // MARK: - Default Text
    private var defaultText: some View {
        Text("\(userName) has \(actionType.rawValue) the group")
            .fontWeight(cellStyle.textStyle.fontWeight)
            .lineLimit(nil)
            .foregroundColor(cellStyle.textStyle.textColor)
            .padding(cellStyle.textPadding)
            .background(cellStyle.cellBackgroundColor)
            .clipShape(RoundedCornerShape(radius: cellStyle.cellCornerRadius, corners: cellStyle.cellRoundedCorners)
            )
            .overlay(
                RoundedCornerShape(radius: cellStyle.cellCornerRadius, corners: cellStyle.cellRoundedCorners)
                .stroke(
                    cellStyle.cellBorderColor,
                    lineWidth: cellStyle.cellBorderWidth
                )
                .shadow(
                    color: cellStyle.cellShadowColor,
                    radius: cellStyle.cellShadowRadius
                )
            )
    }

    @ViewBuilder public var body: some View {
            defaultText
    }
    
}


