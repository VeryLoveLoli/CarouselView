//
//  CarouselItemProtocol.swift
//  
//
//  Created by 韦烽传 on 2021/11/20.
//

import Foundation
import UIKit

/**
 轮播项协议
 */
public protocol CarouselItemProtocol {
    
    // MARK: - Parameter
    
    /// 图片
    var image: UIImage? { get set }
    /// 图片名称
    var imageName: String? { get set }
    /// 图片地址
    var imageURLString: String? { get set }
}
