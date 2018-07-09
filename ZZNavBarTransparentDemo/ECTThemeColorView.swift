//
//  ECTThemeColorView.swift
//  ECharts
//
//  Created by zerry on 2018/6/27.
//  Copyright © 2018年 Feng. All rights reserved.
//

import UIKit

class ECTThemeColorView: UIView {
    var colorfulLayer : CAGradientLayer!
    var isRepeat : Bool = false
    var isRemoved : Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        
    }
    
    fileprivate func setup(_ isRemove:Bool = false) {
        
        if self.layer.sublayers != nil {
            for layer in self.layer.sublayers! {
                layer.removeFromSuperlayer()
            }
            
            self.flag = false
        }
        
        if isRemove {
            self.isRemoved = isRemove
            return
        }
        
        let colors = [
            RGBCOLOR(150, 150, 255).cgColor,
            RGBCOLOR(50, 50, 200).cgColor,
            RGBCOLOR(0, 0, 200).cgColor,
            ]
        
        let locations : [NSNumber] = [0.0,0.5,1.0]
        for index in 0...2 {
            
            colorfulLayer = CAGradientLayer()
            colorfulLayer.colors = index % 2 == 0 ? colors : colors.reversed()
            colorfulLayer.locations = locations
            colorfulLayer.startPoint = CGPoint(x: 0, y: 0)
            colorfulLayer.endPoint = CGPoint(x: 1, y: 0)
            colorfulLayer.frame = CGRect(x: -frame.width, y: 0, width: frame.width, height: frame.height)
            self.layer.insertSublayer(colorfulLayer, at: 0)
        }
    }
    
    func startAnimate(withRepeat isRepeat:Bool = false) {
        self.isRepeat = isRepeat
        
        setup()
        
        self.startAnimate(self.layer.sublayers![0],index:0)
        self.startAnimate(self.layer.sublayers![1],index:1)
        
    }
    
    fileprivate func createAnimate(_ layer:CALayer,index:Int) -> CAKeyframeAnimation {
        
        let keyAnimate = CAKeyframeAnimation(keyPath: "position")
        
        let value0 = NSValue(cgPoint: CGPoint.init(x: ( -layer.frame.width) * 0.5 , y: layer.frame.height * 0.5))
        let value1 = NSValue(cgPoint: CGPoint(x:layer.frame.width * 1.5 * (index == 0 ? 0.25 : 1 ) , y:layer.frame.height * 0.5))
        let value2 = NSValue(cgPoint: CGPoint.init(x: ( -layer.frame.width) * 0.5 , y: layer.frame.height * 0.5))
        
        let tf = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
        keyAnimate.timingFunctions = [tf,tf]
        keyAnimate.keyTimes = [0,1,0]
        keyAnimate.values = [value0,value1,value2]
        
        keyAnimate.autoreverses = false
        keyAnimate.repeatCount = Float(index == 0 ? 1 : CGFloat.infinity)
        keyAnimate.duration = index == 0 ? 1.5:3
        keyAnimate.delegate = self
        keyAnimate.isRemovedOnCompletion = true
        
        return keyAnimate
    }
    
    fileprivate func startAnimate(_ layer:CALayer,index:Int) {
        var animate = layer.animation(forKey: "position\(index)")
        if animate == nil {
            animate = createAnimate(layer,index: index)
        }
        
        if !self.isRepeat && index > 0 {
            animate?.repeatCount = 3
            if index == 2{
                animate?.repeatCount = 2
            }
            
        }
        
        layer.add(animate!, forKey: "position\(index)")
    }
    
    func remove() {
        self.setup(true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    var flag = false
}

extension ECTThemeColorView:CAAnimationDelegate{
    
    func animationDidStart(_ anim: CAAnimation) {
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if self.isRemoved {
            return
        }
        
        if !self.isRepeat {
            if !self.flag {
                self.startAnimate(self.layer.sublayers![2],index:2)
                self.flag = true
            }else{
                self.layer.sublayers![0].frame = self.layer.bounds
            }
            
            return
        }
        
        self.startAnimate(self.layer.sublayers![2],index:2)

        
        if self.isRepeat {
            
        } else {
            
            
            
            //            for (_ , layer) in (self.layer.sublayers?.enumerated())!{
            //                layer.removeFromSuperlayer()
            //            }
        }
        
    }
}
