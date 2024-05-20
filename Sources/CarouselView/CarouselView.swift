//
//  CarouselView.swift
//
//
//  Created by 韦烽传 on 2021/11/20.
//

import Foundation
import UIKit

/**
 轮播视图
 */
open class CarouselView: UIScrollView, UIScrollViewDelegate {
    
    open override var frame: CGRect {
        
        didSet {
            
            let midIndex = CGFloat(items.count/2 + items.count%2) - 1
            setContentOffset(CGPoint.init(x: isVertical ? 0 : midIndex*frame.width, y: isVertical ? midIndex*frame.height : 0), animated: true)
        }
    }
    
    /// 定时器
    open weak var timer: Timer? = nil
    /// 时间间隔
    open internal(set) var timeInterval: TimeInterval = 0
    
    /// 回调索引值
    open var callback: ((Int)->Void)? = nil
    
    /// 视图列表
    open var items: [CarouselItemView] = []
    /// 约束
    var lcs: [NSLayoutConstraint] = []
    
    /// 是否竖向滑动（`true`：竖向；`false`：横向）
    var isVertical = false {
        
        didSet {
            
            itemsLayoutConstraint()
        }
    }
    
    /// 索引
    open var index: Int = 0 {
        
        didSet {
            
            update()
        }
    }
    
    /// 数据源
    open var source: [CarouselItemProtocol] = [] {
        
        didSet {
            
            update()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    /**
     将开始拖动
     */
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        timer?.fireDate = Date.distantFuture
    }
    
    /**
     结束拖动
     */
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        timer?.fireDate = Date.init(timeIntervalSince1970: Date.init().timeIntervalSince1970 + timeInterval)
    }
    
    /**
     减速结束
     */
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        updateIndex()
    }
    
    /**
     滑动动画结束
     */
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        updateIndex()
    }
    
    // MARK: - Event
    
    /**
     默认设置
     */
    open func defaultSetting() {
        
        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        
        items = (0..<5).map { _ -> CarouselItemView in
            
            let item = CarouselItemView()
            item.defaultSetting()
            
            return item
        }
        
        itemsLayoutConstraint()
    }
    
    /**
     视图列表约束
     */
    open func itemsLayoutConstraint() {
        
        NSLayoutConstraint.deactivate(lcs)
        lcs = []
        
        var last: CarouselItemView?
        
        if isVertical {
            
            for item in items {
                
                addSubview(item)
                
                item.translatesAutoresizingMaskIntoConstraints = false
                
                lcs.append(NSLayoutConstraint(item: item, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
                lcs.append(NSLayoutConstraint(item: item, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
                lcs.append(NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
                lcs.append(NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))
                
                if let last = last {
                    
                    lcs.append(NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal, toItem: last, attribute: .bottom, multiplier: 1, constant: 0))
                }
                else {
                    
                    lcs.append(NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                }
                
                last = item
            }
            
            if let last = last {
                
                lcs.append(NSLayoutConstraint(item: last, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
            }
        }
        else {
            
            for item in items {
                
                addSubview(item)
                
                item.translatesAutoresizingMaskIntoConstraints = false
                
                lcs.append(NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
                lcs.append(NSLayoutConstraint(item: item, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
                lcs.append(NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
                lcs.append(NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0))
                
                if let last = last {
                    
                    lcs.append(NSLayoutConstraint(item: item, attribute: .left, relatedBy: .equal, toItem: last, attribute: .right, multiplier: 1, constant: 0))
                }
                else {
                    
                    lcs.append(NSLayoutConstraint(item: item, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
                }
                
                last = item
            }
            
            if let last = last {
                
                lcs.append(NSLayoutConstraint(item: last, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
            }
        }
        
        NSLayoutConstraint.activate(lcs)
    }
    
    /**
     开始
     
     - parameter    timeInterval:   时间间隔
     */
    open func start(_ timeInterval: TimeInterval) {
        
        delegate = self
        
        self.timeInterval = timeInterval
        
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { [weak self] timer in
            
            if self == nil && timer.isValid {
                
                timer.invalidate()
            }
            else if let self = self {
                
                let number = self.items.count
                
                self.setContentOffset(CGPoint.init(x: CGFloat(number/2 + number%2)*self.frame.width, y: 0), animated: true)
            }
        }
    }
    
    /**
     停止
     */
    open func stop() {
        
        if timer?.isValid ?? false {
            
            timer?.invalidate()
        }
        
        timer = nil
    }
    
    /**
     更新
     */
    open func update() {
        
        timer?.fireDate = Date.distantFuture
        
        let midIndex = CGFloat(items.count/2 + items.count%2) - 1
        
        if source.count > 0 {
            
            let start_index = index - Int(midIndex) + source.count
            
            for i in 0..<items.count {
                
                if items[i].source?.id == source[(start_index + Int(midIndex))%source.count].id && items[i].source?.id != nil {
                    
                    if i < Int(midIndex) {
                        
                        for _ in 0..<(Int(midIndex) - i) {
                            
                            let item = items.removeLast()
                            items.insert(item, at: 0)
                        }
                        
                        itemsLayoutConstraint()
                    }
                    else if i > Int(midIndex) {
                        
                        for _ in 0..<(i - Int(midIndex)) {
                            
                            let item = items.removeFirst()
                            items.append(item)
                        }
                        
                        itemsLayoutConstraint()
                    }
                    
                    break
                }
            }
            
            items[Int(midIndex)].source = source[(start_index + Int(midIndex))%source.count]
            items[Int(midIndex)].index = Int(midIndex)
            items[Int(midIndex)].midIndex = Int(midIndex)
            
            if isVertical {
                
                if contentSize.height < CGFloat(items.count)*frame.size.height {
                    
                    contentSize.height = CGFloat(items.count)*frame.size.height
                }
                
                contentOffset = CGPoint.init(x: 0, y: midIndex*frame.size.height)
            }
            else {
                
                if contentSize.width < CGFloat(items.count)*frame.size.width {
                    
                    contentSize.width = CGFloat(items.count)*frame.size.width
                }
                
                contentOffset = CGPoint.init(x: midIndex*frame.size.width, y: 0)
            }
            
            for i in 0..<items.count {
                
                if i == Int(midIndex) {
                    continue
                }
                
                items[i].source = source[(start_index+i)%source.count]
                items[i].index = start_index+i
                items[i].midIndex = Int(midIndex)
            }
        }
        
        timer?.fireDate = Date.init(timeIntervalSince1970: Date.init().timeIntervalSince1970 + timeInterval)
        
        callback?(index)
    }
    
    /**
     更新索引
     */
    open func updateIndex() {
        
        let midIndex = items.count/2 + items.count%2 - 1
        var offsetIndex = isVertical ? Int(contentOffset.y/frame.size.height) : Int(contentOffset.x/frame.size.width)
        
        offsetIndex -= midIndex
        
        var newIndex = 0
        
        if source.count > 0 {
            
            newIndex = index + offsetIndex
            
            while newIndex < 0 {
                
                newIndex += source.count
            }
            
            newIndex = newIndex%source.count
        }
        
        index = newIndex
    }
}
