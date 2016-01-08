//
//  KMScrollLabel.swift
//  StopSmokingPrograms
//
//  Created by Fran on 15/11/2.
//  Copyright © 2015年 kimree. All rights reserved.
//

import UIKit

enum KMScrollDirection: Int{
    case Left = 0
    case Right
    case Up
    case Down
}

class KMScrollLabel: UIScrollView {
    
    // label 是只读的
    // 在外部只修改label的text即可, 其他属性在封装中可能会发生变化
    private var label = UILabel()
    var textLabel: UILabel{
        get{
            return label
        }
    }
    
    // label是否在滑动
    private var keepScroll = false
    
    // 动画时间
    var animationDuringTime:Double = 5
    
    deinit{
        KMLog("KMScrollLabel deinit")
    }
    
    convenience init(){
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        KMLog("init frame")
        
        self.scrollEnabled = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.addSubview(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        KMLog("init aDecoder")
        
        self.scrollEnabled = false
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.addSubview(label)
    }
    
    // MARK: - 开始滑动
    func startScroll(direction: KMScrollDirection = .Left){
        fitFrame(direction)
        
        // 当label不处于滑动状态时， 才可以开始滑动， 避免动画效果叠加
        if !keepScroll{
            keepScroll = true
            self.contentOffset = CGPointZero
            beginScroll(direction)
        }
    }
    
    // removeAllAnimations 之后会立刻执行 animation block 的 completion 部分, 
    // 目前无法确定 completion 部分的参数总会是 false， 为了避免巧合, 需要配合 keepScroll 参数一起使用
    func stopScroll(){
        keepScroll = false
        self.layer.removeAllAnimations()
    }
    
    // MARK: - 具体怎样滑动
    func beginScroll(direction: KMScrollDirection = .Left){
        let w = label.frame.size.width
        let h = label.frame.size.height
        
        switch direction{
        case .Left:
            self.contentOffset.x = 0
            UIView.animateWithDuration(animationDuringTime, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self]() -> Void in
                self?.contentOffset.x = w
                }, completion: { [weak self](finished: Bool) -> Void in
                    if finished && (self != nil && self!.keepScroll){
                        self!.contentOffset.x = 0
                        self!.beginScroll(direction)
                    }
                })
            
        case .Right:
            self.contentOffset.x = w
            UIView.animateWithDuration(animationDuringTime, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self]() -> Void in
                self?.contentOffset.x = 0
                }, completion: { [weak self](finished: Bool) -> Void in
                    if finished && (self != nil && self!.keepScroll){
                        self!.contentOffset.x = w
                        self!.beginScroll(direction)
                    }
                })
            
        case .Up:
            self.contentOffset.y = 0
            UIView.animateWithDuration(animationDuringTime, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self]() -> Void in
                self?.contentOffset.y = h
                }, completion: { [weak self](finished: Bool) -> Void in
                    if finished && (self != nil && self!.keepScroll){
                        self!.contentOffset.y = 0
                        self!.beginScroll(direction)
                    }
                })
            
        case .Down:
            self.contentOffset.y = h
            UIView.animateWithDuration(animationDuringTime, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { [weak self]() -> Void in
                self?.contentOffset.y = 0
                }, completion: { [weak self](finished: Bool) -> Void in
                    if finished && (self != nil && self!.keepScroll){
                        self!.contentOffset.y = h
                        self!.beginScroll(direction)
                    }
                })
        }
        
    }
    
    // MARK: - 适配frame
    private func fitFrame(direction: KMScrollDirection){
        // 按照水平方向移动的要求修改frame
        func fitFrameAtHorizontalDirection(){
            
            let width = self.frame.size.width
            var height = self.frame.size.height
            
            label.numberOfLines = 1
            label.lineBreakMode = .ByWordWrapping
            var size = label.sizeThatFits(CGSizeMake(CGFloat.max, height))
            
            // scroll 的 height 不能小于 label 的 height
            if height < size.height{
                self.frame.size.height = size.height
                height = size.height
            }
            
            // label 的 width 要加上 scroll width 的一半作为留白, 并且 label 的 width 不能小于 scroll 的 width
            size.width += width / 2.0
            if size.width < width{
                size.width = width
            }
            
            label.frame = CGRectMake(0, (height - size.height) / 2.0, size.width, size.height)
            
            let tempLabel = NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(label)) as! UILabel
            tempLabel.frame.origin.x += size.width
            self.addSubview(tempLabel)
            
            self.contentSize = CGSizeMake(2 * size.width, height)
        }
        
        // 按照竖直方向移动的要求修改frame
        func fitFrameAtVerticalDirection(){
            
            var width = self.frame.size.width
            let height = self.frame.size.height
            
            label.numberOfLines = 0
            label.lineBreakMode = .ByWordWrapping
            let originalText = label.text
            
            // 获取单个文字的宽度
            label.text = "田"
            let singleSize = label.sizeThatFits(CGSizeZero)
            
            label.text = originalText
            var size = label.sizeThatFits(CGSizeMake(singleSize.width, CGFloat.max))
            
            if width < size.width{
                self.frame.size.width = size.width
                width = size.width
            }
            
            size.height += height / 2.0
            if size.height < height{
                size.height = height
            }
            
            label.frame = CGRectMake((width - size.width) / 2.0, 0, size.width, size.height)
            
            let tempLabel = NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(label)) as! UILabel
            tempLabel.frame.origin.y += size.height
            self.addSubview(tempLabel)
            
            self.contentSize = CGSizeMake(width, 2 * size.height)
        }
        
        // 首先遍历 scroll 的所有 subView, 将占位的 label 移除
        for view in self.subviews{
            if view != label{
                view.removeFromSuperview()
            }
        }
        
        switch direction{
        case .Left, .Right:
            fitFrameAtHorizontalDirection()
        case .Up, .Down:
            fitFrameAtVerticalDirection()
        }
        
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}
