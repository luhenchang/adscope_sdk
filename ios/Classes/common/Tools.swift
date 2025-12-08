//
//  Tools.swift
//  amps_sdk
//
//  Created by duzhaoquan on 2025/10/22.
//

import Foundation
import UIKit

func getKeyWindow() -> UIWindow? {
    // iOS 15+ 推荐使用 sceneDelegate 管理的窗口
    if #available(iOS 15.0, *) {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    } else if #available(iOS 13.0, *) {
        // iOS 13-14 多场景适配
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    } else {
        // iOS 12 及以下（单窗口时代）
        return UIApplication.shared.keyWindow
    }
}


struct Tools {
    static func convertToModel<T: Codable>(from dict: [String: Any]) -> T? {
        do {
            // 先将字典转为 JSON 数据
            let jsonData = try JSONSerialization.data(withJSONObject: dict)
            // 再通过 JSONDecoder 解码为对象
            let decoder = JSONDecoder()
            // 可选：设置日期格式（如果有日期属性）
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            print("转换失败：\(error)")
            return nil
        }
    }
    /// 异步请求网络图片数据（推荐，不阻塞主线程）
    /// - Parameters:
    ///   - urlString: 图片URL字符串
    ///   - completion: 回调结果（Data? 或 Error?）
        
    static func fetchImageData(from urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // 1. 校验URL
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的图片URL"])))
            return
        }
        
        // 2. 创建URLSession任务
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // 处理错误
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // 3. 校验响应状态（HTTP 200 OK）
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "InvalidResponse", code: -2, userInfo: [NSLocalizedDescriptionKey: "网络响应无效"])))
                return
            }
            
            // 4. 校验数据
            guard let imageData = data else {
                completion(.failure(NSError(domain: "NoData", code: -3, userInfo: [NSLocalizedDescriptionKey: "未获取到图片数据"])))
                return
            }
            
            // 5. 回调成功结果（确保在主线程回调，方便后续更新UI）
            DispatchQueue.main.async {
                completion(.success(imageData))
            }
        }
        
        // 启动任务
        task.resume()
    }
}




extension UIColor {
    /// 从十六进制字符串创建 UIColor
    /// - Parameter hexString: 十六进制颜色字符串，格式支持：#RRGGBB、#RRGGBBAA、RRGGBB、RRGGBBAA
    convenience init?(hexString: String) {
        // 移除字符串中的 # 符号
        let cleanedString = hexString.trimmingCharacters(in: .init(charactersIn: "#"))
        
        // 定义字符集（只保留 0-9、a-f、A-F）
        let validCharacters = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        guard cleanedString.rangeOfCharacter(from: validCharacters.inverted) == nil else {
            return nil // 包含无效字符
        }
        
        // 检查长度是否合法（6位：RGB；8位：RGBA）
        guard cleanedString.count == 6 || cleanedString.count == 8 else {
            return nil
        }
        
        // 解析 RGB 分量
        let scanner = Scanner(string: cleanedString)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else {
            return nil
        }
        
        let red: UInt64, green: UInt64, blue: UInt64, alpha: UInt64
        
        if cleanedString.count == 6 {
            // 格式：RRGGBB（默认 alpha 为 1.0）
            red = (hexNumber >> 16) & 0xFF
            green = (hexNumber >> 8) & 0xFF
            blue = hexNumber & 0xFF
            alpha = 0xFF // 完全不透明
        } else {
            // 格式：RRGGBBAA
            red = (hexNumber >> 24) & 0xFF
            green = (hexNumber >> 16) & 0xFF
            blue = (hexNumber >> 8) & 0xFF
            alpha = hexNumber & 0xFF
        }
        
        // 转换为 0.0~1.0 的浮点数
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(alpha) / 255.0
        )
    }
}


import UIKit

extension UIViewController {
    /// 获取当前显示的顶层视图控制器
    static func current() -> UIViewController? {
        // 1. 获取当前活跃的窗口（适配 iOS 13+ 多场景）
        guard let window = getKeyWindow() else {
            return nil
        }
        
        // 2. 从窗口根控制器开始遍历
        var currentVC = window.rootViewController
        
        // 递归处理容器控制器（导航栏、标签栏、模态窗口等）
        while let nextVC = currentVC?.presentedViewController {
            currentVC = nextVC
        }
        
        // 处理 UINavigationController（取顶层控制器）
        if let nav = currentVC as? UINavigationController {
            currentVC = nav.topViewController ?? nav.viewControllers.last
        }
        
        // 处理 UITabBarController（取选中的控制器）
        if let tab = currentVC as? UITabBarController {
            currentVC = tab.selectedViewController ?? tab.viewControllers?.first
        }
        
        return currentVC
    }
}
