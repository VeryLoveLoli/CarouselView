//
//  CarouselItemView.swift
//  
//
//  Created by 韦烽传 on 2021/11/20.
//

import Foundation
import UIKit
import Network

/**
 轮播项视图
 */
open class CarouselItemView: UIControl {
    
    // MARK: - Parameter
    
    /// 图片
    open var imageView: UIImageView?
    /// 数据源
    open var source: CarouselItemProtocol? {
        
        didSet {
            
            update()
        }
    }
    
    // MARK: - Event
    
    /**
     默认设置
     */
    open func defaultSetting() {
        
        imageView = UIImageView()
        imageLayoutConstraint()
    }
    
    /**
     图片约束
     */
    open func imageLayoutConstraint() {
        
        if let i = imageView, i.superview == nil {
            
            addSubview(i)
            i.translatesAutoresizingMaskIntoConstraints = false
            
            var lcs: [NSLayoutConstraint] = []
            
            lcs.append(NSLayoutConstraint(item: i, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
            lcs.append(NSLayoutConstraint(item: i, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
            lcs.append(NSLayoutConstraint(item: i, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
            lcs.append(NSLayoutConstraint(item: i, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
            
            NSLayoutConstraint.activate(lcs)
        }
        
    }
    
    /**
     更新
     */
    open func update() {
        
        var defaultImage: Image? = nil
        
        if let image = source?.image {
            
            defaultImage = Image(image)
        }
        else if let imageName = source?.imageName, let image = UIImage(named: imageName) {
            
            defaultImage = Image(image)
        }
        
        imageView?.load(source?.imageURLString ?? "", defaultImage: defaultImage)
    }
}
