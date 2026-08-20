//
//  SplashBottomImage.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/29.
//

import Foundation
import UIKit

enum ImageScaleType: String, Codable {
    case contain
    case cover
    case fill

    var contentMode: UIView.ContentMode {
        switch self {
        case .contain:
            return .scaleAspectFit
        case .cover:
            return .scaleAspectFill
        case .fill:
            return .scaleToFill
        }
    }

    var clipsToBounds: Bool {
        return self == .cover
    }
}

struct SplashBottomImage : Codable{
    
    var x: CGFloat?
    var y: CGFloat?
    var imagePath: String?
    var width: CGFloat?
    var height: CGFloat?
    var scaleType: ImageScaleType?
}
