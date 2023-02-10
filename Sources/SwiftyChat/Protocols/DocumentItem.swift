//
//  File.swift
//  
//
//  Created by Hanne Sebestyen on 10.02.2023.
//

import Foundation
import class UIKit.UIImage

public protocol DocumentItem {
    ///  document title
    var title: String { get }
    
    /// document URL
    var URL: String? { get }
    
    /// document ID
    var documentId: String? { get }
    
    /// document icon
    var image: UIImage? { get }
}
