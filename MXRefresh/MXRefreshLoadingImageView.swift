//
//  MXRefreshLoadingImageView.swift
//  MXRefresh
//
//  Created by mx on 2017/3/18.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

class MXRefreshLoadingImageView: UIView {
    
    fileprivate weak var bigLoadingCircle : CAShapeLayer!
    
    fileprivate var minLoadingCircles : [CAShapeLayer] = [CAShapeLayer]()

    //Animations
    fileprivate var bigLoadingCircleAnimation : CAKeyframeAnimation!
    
    fileprivate var minLoadingCirclesAnimations : [CAKeyframeAnimation] = [CAKeyframeAnimation]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //初始化
        self.initSublayers()
        self.initAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initSublayers(){
        //圆的颜色
        let bigLoading = CAShapeLayer()
        
        self.bigLoadingCircle = bigLoading
        
        self.bigLoadingCircle.frame = self.bounds
        
        let path = UIBezierPath.init(arcCenter: CGPoint.init(x: self.bigLoadingCircle.frame.width / 2.0, y: self.bigLoadingCircle.frame.width / 2.0), radius: self.bigLoadingCircle.frame.width / 2.0, startAngle: 0, endAngle:CGFloat(M_PI * 2.0), clockwise: true)
        
        self.bigLoadingCircle.path = path.cgPath
        
        self.bigLoadingCircle.lineWidth = 1.0
        
        self.bigLoadingCircle.strokeColor = colorWith(red: 241.0, green: 162.0, blue: 95.0).cgColor

        self.bigLoadingCircle.fillColor = colorWith(red: 241.0, green: 162.0, blue: 95.0).cgColor
        
        self.layer.addSublayer(self.bigLoadingCircle)
        //小圆
        for i in 0..<5 {
            let minLoadingCircle = CAShapeLayer()
            
            minLoadingCircle.frame = CGRect.init(x: self.frame.width - CGFloat(5 * (i + 1)), y: self.frame.height / 2.0 - 2.5, width: 5, height: 5)
            
            let minPath = UIBezierPath.init(arcCenter: CGPoint.init(x: minLoadingCircle.frame.width / 2.0, y: minLoadingCircle.frame.height / 2.0), radius: minLoadingCircle.frame.width / 2.0, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
            
            minLoadingCircle.path = minPath.cgPath
            
            minLoadingCircle.lineWidth = 1.0
            
            minLoadingCircle.strokeColor = colorWith(red: 241.0, green: 162.0, blue: 95.0).cgColor
            
            minLoadingCircle.fillColor = colorWith(red: 241.0, green: 162.0, blue: 95.0).cgColor
            
            self.minLoadingCircles.append(minLoadingCircle)
            
            self.layer.addSublayer(minLoadingCircle)
        }
        
    }
    
    private func initAnimations(){
        //BigCircle
        self.bigLoadingCircleAnimation = CAKeyframeAnimation.init(keyPath: "path")
        
        self.bigLoadingCircleAnimation.values = [
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.bigLoadingCircle.frame.width / 2.0, y: self.bigLoadingCircle.frame.width / 2.0), radius: self.bigLoadingCircle.frame.width / 3.0, startAngle: 0, endAngle:CGFloat(M_PI * 2.0), clockwise: true).cgPath,
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.bigLoadingCircle.frame.width / 2.0, y: self.bigLoadingCircle.frame.width / 2.0), radius: self.bigLoadingCircle.frame.width / 4.0, startAngle: 0, endAngle:CGFloat(M_PI * 2.0), clockwise: true).cgPath,
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.bigLoadingCircle.frame.width / 2.0, y: self.bigLoadingCircle.frame.width / 2.0), radius: self.bigLoadingCircle.frame.width / 5.0, startAngle: 0, endAngle:CGFloat(M_PI * 2.0), clockwise: true).cgPath,
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.bigLoadingCircle.frame.width / 2.0, y: self.bigLoadingCircle.frame.width / 2.0), radius: self.bigLoadingCircle.frame.width / 6.0, startAngle: 0, endAngle:CGFloat(M_PI * 2.0), clockwise: true).cgPath,
            UIBezierPath.init(arcCenter: CGPoint.init(x: self.bigLoadingCircle.frame.width / 2.0, y: self.bigLoadingCircle.frame.width / 2.0), radius: 2.5, startAngle: 0, endAngle:CGFloat(M_PI * 2.0), clockwise: true).cgPath
        ]
        
        self.bigLoadingCircleAnimation.timingFunctions = [CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)]
        
        self.bigLoadingCircleAnimation.isRemovedOnCompletion = false
        
        //相当于无限循环
        self.bigLoadingCircleAnimation.repeatCount = Float.infinity
        
        self.bigLoadingCircleAnimation.autoreverses = true
        
        self.bigLoadingCircleAnimation.duration = 2.0
        
        //MinCircle
        //有多少个小圆，就有多少个动画，因为每个圆的动画有时延
        for index in 0..<self.minLoadingCircles.count {
            
            let minLoadingCirclesAnimation = CAKeyframeAnimation.init(keyPath: "position")
            
            let circleMovePath = CGMutablePath.init()
            
            circleMovePath.addArc(center: CGPoint.init(x: self.frame.width / 2.0, y: self.frame.height + 6.0), radius: self.frame.width / 2.0 + 6.0, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: false)
            //每一个间隔0.2秒
            minLoadingCirclesAnimation.path = circleMovePath
            
            minLoadingCirclesAnimation.isRemovedOnCompletion = false
            //相当于无限循环
            minLoadingCirclesAnimation.repeatCount = Float.infinity
            
            minLoadingCirclesAnimation.autoreverses = false
            
            minLoadingCirclesAnimation.duration = 2.0
            
            self.minLoadingCirclesAnimations.append(minLoadingCirclesAnimation)
            
            //Delegate
            minLoadingCirclesAnimation.setValue(String.init(format: "MinCircleAnimation%d", index), forKey: "identifier")
            minLoadingCirclesAnimation.delegate = self
        }
    }
    
    //MARK:Action
    func startAnimation(){
        for index in 0..<self.minLoadingCircles.count{
        //在这里设置时间
        self.minLoadingCirclesAnimations[index].beginTime = CACurrentMediaTime() + 0.2 * Double(index)
        self.minLoadingCircles[index].add(self.minLoadingCirclesAnimations[index], forKey: String.init(format: "MinCircleAnimation%d", index))
        }
        
    }
    
    func endAnimationAndRemove(){
        self.bigLoadingCircle.removeAllAnimations()
        
        for minCircle in self.minLoadingCircles {
            minCircle.removeAllAnimations()
        }
    }
}

extension MXRefreshLoadingImageView : CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
        switch anim.value(forKey: "identifier") as! String {
        case "MinCircleAnimation0":
            //大圆动画
            self.bigLoadingCircle.add(self.bigLoadingCircleAnimation, forKey: "BigLoading")
            break
        default:
            break
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
       
    }
}
