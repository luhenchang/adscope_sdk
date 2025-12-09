//
//  models.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/30.
//

import Foundation

struct FlutterUnifiedParam:Codable {
    var adId: String?
    var unifiedWidget: FlutterUnifiedWidget?
}

struct FlutterUnifiedWidget:Codable {
    var children: [FlutterUnifiedChild]? = []
    var backgroundColor: String?
    var type: String?
    var width: CGFloat?
    var height: CGFloat?
}

struct FlutterUnifiedChild: Codable {
    var x: CGFloat?
    var y: CGFloat?
    var width: CGFloat?
    var height: CGFloat?
    var clickIdType: Int?
    var clickType: Int?
    var backgroundColor: String?
    
    var type: FlutterUnifiedChildType?
    var imagePath: String?
    var fontSize: CGFloat?
    var color: String?
    var bttonType: String?
    var fontColor: String?
    var content: String?
    
    
    
    
}

enum FlutterUnifiedChildType:String,Codable {
    case mainImage //= "mainImage"
    case mainTitle //= "mainTitle"
    case descText
    case actionButton
    case adSourceLogo
    case appIcon
    case downloadInfo
    case video
    case closeIcon
    case shake
    case slide
    
}
