//
//  MXRefreshView.swift
//  MXRefresh
//
//  Created by mx on 2017/3/18.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

enum MXRefreshStatus {
    case refreshing
    case none
}

enum MXRefreshPosition {
    case left
    case right
    case middle
}

class MXRefreshView: UIView {
    
    var superScrollView : UIScrollView!

    fileprivate weak var refreshLoadingImageView : MXRefreshLoadingImageView!
    
    //下拉弹力的线
    fileprivate weak var waveLayer : CAShapeLayer!
    
    //Animations,应该只需要一种就可以了
    fileprivate var waveLayerAnimation :  CAKeyframeAnimation!
    
    //直线 Path
    
    fileprivate var rectPath : UIBezierPath!
    //调用回调
    private var operation : MXOperation!
    
    //动画时间
    var duration : Double = 0
    
    //触摸位置
    var touchPositionX : CGFloat = 0
    
    //振幅
    private let waveHighPosition : CGFloat = 50.0
    
    //状态
    private var refreshStatus : MXRefreshStatus = MXRefreshStatus.none
    
    init(superScrollView : UIScrollView,operation : @escaping MXOperation,duration : Double){
        
        let frame : CGRect = CGRect.init(x: 0, y: -300, width: superScrollView.frame.width, height: 300)
        
        super.init(frame: frame)
        //初始化动画
        self.initSubViews()
        self.initAnimations()
        // 设置相关属性
        self.superScrollView = superScrollView
        
        //self.backgroundColor = colorWith(red: 146.0, green: 61.0, blue: 96.0)
        //添加
        self.superScrollView.addSubview(self)
        
        self.operation = operation
        
        self.duration = duration
        //设置 kvo
        self.superScrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //MARK: Initialize
    private func initSubViews(){
        //WaveLayer
        let wave = CAShapeLayer()
        
        self.waveLayer = wave
        //CGRect.init(x: 0.0, y: self.frame.height - self.waveHighPosition , width: self.frame.width, height: self.waveHighPosition)
        
        self.waveLayer.frame = self.bounds
        //初始化曲线
        //矩形边框
        self.rectPath = UIBezierPath.init()
        
        self.rectPath.move(to: CGPoint.init(x: 0, y: 0))
        
        self.rectPath.addLine(to: CGPoint.init(x: self.waveLayer.frame.width, y: 0))
        
        self.rectPath.addLine(to: CGPoint.init(x: self.waveLayer.frame.width, y: self.waveLayer.frame.height))
        
        self.rectPath.addLine(to: CGPoint.init(x: 0, y: self.waveLayer.frame.height))
        
        self.rectPath.addLine(to: CGPoint.init(x: 0, y: 0))
        
        self.rectPath.close()
        
        self.waveLayer.path = self.rectPath.cgPath
        
        self.waveLayer.lineWidth = 1.0
        
        self.waveLayer.strokeColor = colorWith(red: 146.0, green: 61.0, blue: 96.0).cgColor
        
        self.waveLayer.fillColor =  colorWith(red: 146.0, green: 61.0, blue: 96.0).cgColor
        
        self.layer.addSublayer(self.waveLayer)
        
        //初始化
        let loadingCircleView = MXRefreshLoadingImageView.init(frame: CGRect.init(x: self.frame.size.width / 2.0 - 15.0, y: self.frame.height - 80, width: 40, height: 40))
    
        self.refreshLoadingImageView = loadingCircleView
        
        self.addSubview(self.refreshLoadingImageView)
    }
    
    private func initAnimations(){
        //
        self.waveLayerAnimation = CAKeyframeAnimation.init(keyPath: "path")
        
        self.waveLayerAnimation.values = [
            self.updateWavePath(highPointY: 100.0, position: .left).cgPath,
            self.updateWavePath(highPointY: -80.0, position: .left).cgPath,
            self.updateWavePath(highPointY: 60.0, position: .left).cgPath,
            self.updateWavePath(highPointY: -40.0, position: .left).cgPath,
            self.updateWavePath(highPointY: 10.0, position: .left).cgPath,
            self.updateWavePath(highPointY: -5.0, position: .left).cgPath,
            self.updateWavePath(highPointY: 1.0, position: .left).cgPath,
            self.rectPath.cgPath
        ]
        
        self.waveLayerAnimation.isRemovedOnCompletion = false
        
        self.waveLayerAnimation.fillMode = kCAFillModeForwards
        
        self.waveLayerAnimation.duration = 0.5
        
        self.waveLayerAnimation.autoreverses = false
        
        //*************************************
        //Delegate
        self.waveLayerAnimation.delegate = self
        self.waveLayerAnimation.setValue("WaveAnimation", forKey: "identifier")
        
    }
    
    //MARK: wavePath Stroke
    private func updateWavePath(highPointY : CGFloat,position : MXRefreshPosition?)->UIBezierPath{
        
        let path = UIBezierPath.init()
        
        let lineY = self.waveLayer.bounds.size.height
        
        path.move(to: CGPoint.init(x: 0, y: 0))
        
        path.addLine(to: CGPoint.init(x: self.waveLayer.frame.width, y: 0.0))
        
        path.addLine(to: CGPoint.init(x: self.waveLayer.frame.width, y: self.waveLayer.frame.height))
        //不使用三角函数
        //使用贝塞尔曲线
        //控制点
        var controlPoint : CGPoint!
        
        if position != nil {
            let controlX : CGFloat = self.waveLayer.frame.width / 2.0
            
            controlPoint = CGPoint.init(x: controlX, y: highPointY + lineY)
            //Path
            path.addQuadCurve(to: CGPoint.init(x: 0, y: lineY), controlPoint: controlPoint)
        }else{
            //触摸
            controlPoint = CGPoint.init(x: self.touchPositionX, y: highPointY + lineY)
            //绘制路径
            if (self.touchPositionX != 0 && self.touchPositionX <= self.superScrollView.frame.width / 3.0) || (position != nil && position == .left) {
                //左边
                let destinationPointX = self.waveLayer.frame.width / 3.0 * 2.0
                
                path.addLine(to: CGPoint.init(x: destinationPointX, y: lineY))
                
                path.addQuadCurve(to: CGPoint.init(x: 0, y: lineY), controlPoint: controlPoint)
                
            }else if (self.touchPositionX != 0 && self.touchPositionX >= (self.superScrollView.frame.width - self.superScrollView.frame.width / 3.0)) || (position != nil && position == .right) {
                //右边
                let destinationPointX = self.waveLayer.frame.width / 3.0
                
                path.addQuadCurve(to: CGPoint.init(x: destinationPointX, y: lineY), controlPoint: controlPoint)
                path.addLine(to: CGPoint.init(x: 0, y: lineY))
                
            }else{
                //中间
                let leftStartPositionX = self.waveLayer.frame.width / 4.0
                
                let rightEndPositionX = self.waveLayer.frame.width / 4.0 * 3.0
                
                path.addLine(to: CGPoint.init(x: rightEndPositionX, y: lineY))
                
                path.addQuadCurve(to: CGPoint.init(x: leftStartPositionX, y: lineY), controlPoint: controlPoint)
                
                path.addLine(to: CGPoint.init(x: 0, y: lineY))
            }
        }
        //闭合路径，连接首尾
        path.close()
        
        return path
    }
    
    //MARK: obeserve
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //在这里实现监听
        if self.superScrollView.contentOffset.y > 0 {
            return
        }
        if self.refreshStatus == .none {
            //获取点击位置
            if self.touchPositionX == 0 {
                self.touchPositionX = self.superScrollView.panGestureRecognizer.location(in: self.superScrollView).x
            }
            
            let contentOffsetY = abs(self.superScrollView.contentOffset.y)
            //从64开始，默认存在导航栏
            //是否还在拖动
            if self.superScrollView.isDragging {
                //继续拖动
                //最高点坐标
                let highPointY = contentOffsetY - 64.0
                
                let path = self.updateWavePath(highPointY: highPointY, position: nil)
                
                self.waveLayer.path = path.cgPath
                
            }else{
                //没有拖动了，判断是否直接刷新
                if contentOffsetY >= 150{
                    //改变状态
                    self.refreshStatus = .refreshing
                    //执行弹性动画
                    self.waveLayer.add(self.waveLayerAnimation, forKey: "WaveAnimation")
                    //固定住
                    var contentInset = self.superScrollView.contentInset
                    
                    contentInset.top = 214
                    
                    
                    self.superScrollView.contentInset = contentInset
                    
                    //开始执行 block
                    self.operation(true)
                    //设置延时操作
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.duration, execute: {
                        //去除所有动画
                        self.removeAllAnimtion()
                        //修改状态
                        self.refreshStatus = .none
                        //回收刷新 View
                        var contentInset = self.superScrollView.contentInset
                        
                        contentInset.top = 64
                        
                        self.superScrollView.contentInset = contentInset
                        //修改点击位置
                        self.touchPositionX = 0
                    })
                   
                }else{
                    //不做操作,直接缩放回去
                    if self.waveLayer.path != self.rectPath.cgPath {
                        self.waveLayer.path = self.rectPath.cgPath
                    }
                    //修改点击位置
                    self.touchPositionX = 0
                    //修改状态
                    self.refreshStatus = .none
                }
            }
        }else{
            //正处于刷新状态,直接返回
            return
        }
    }
    
    private func removeAllAnimtion(){
        self.refreshLoadingImageView.endAnimationAndRemove()
        self.waveLayer.removeAllAnimations()
    }
}

//MARK: Delegate
extension MXRefreshView : CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        switch anim.value(forKey: "identifier") as! String {
        case "WaveAnimation":
            //改变 Path
            self.initRectPath()
            //执行圆圈动画
            self.refreshLoadingImageView.startAnimation()
            break
        default:
            
            break
        }
    }
    
    private func initRectPath(){
        if self.waveLayer.path != self.rectPath.cgPath {
            self.waveLayer.path = self.rectPath.cgPath
        }
    }
}
