//
//  PulseButtonAnimation.swift
//  Leapper
//
//  Created by Екатерина Узбекова on 14.01.2021.
//  Copyright © 2021 Leapper Technologies. All rights reserved.
//

import Foundation
import UIKit

class PulseAnimation: CALayer {

    var animationGroup = CAAnimationGroup()
    var animationDuration: TimeInterval = 1.5
    var radius: CGFloat = 180
    var numebrOfPulse: Float = Float.infinity
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(numberOfPulse: Float = Float.infinity, radius: CGFloat, postion: CGPoint){
        super.init()
        self.backgroundColor = UIColor.black.cgColor
        self.contentsScale = UIScreen.main.scale
        self.opacity = 0
        self.radius = radius
        self.numebrOfPulse = numberOfPulse
        self.position = postion
        
        self.bounds = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        self.cornerRadius = radius
        
        DispatchQueue.global(qos: .default).async {
            self.setupAnimationGroup()
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: "pulse")
           }
        }
    }
    
    func scaleAnimation() -> CABasicAnimation {
        let scaleAnimaton = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimaton.fromValue = NSNumber(value: 0)
        scaleAnimaton.toValue = NSNumber(value: 1)
        scaleAnimaton.duration = animationDuration
        return scaleAnimaton
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        let opacityAnimiation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimiation.duration = animationDuration
        opacityAnimiation.values = [0.4,0.8,0]
        opacityAnimiation.keyTimes = [0,0.3,1]
        return opacityAnimiation
    }
    
    func setupAnimationGroup() {
        self.animationGroup.duration = animationDuration
        self.animationGroup.repeatCount = numebrOfPulse
        let defaultCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.default)
        self.animationGroup.timingFunction = defaultCurve
        self.animationGroup.animations = [scaleAnimation(),createOpacityAnimation()]
    }
    
    
}


/**
 Represents a single type of confetti piece.
 */
class ConfettiType {
    let color: UIColor
    let shape: ConfettiShape
    let position: ConfettiPosition
    lazy var name = UUID().uuidString
    init(color: UIColor, shape: ConfettiShape, position: ConfettiPosition) {
        self.color = color
        self.shape = shape
        self.position = position
    }
    
    lazy var image: UIImage = {
         let imageRect: CGRect = {
             switch shape {
             case .rectangle:
                 return CGRect(x: 0, y: 0, width: 20, height: 13)
             case .circle:
                 return CGRect(x: 0, y: 0, width: 10, height: 10)
             }
         }()

         UIGraphicsBeginImageContext(imageRect.size)
         let context = UIGraphicsGetCurrentContext()!
         context.setFillColor(color.cgColor)

         switch shape {
         case .rectangle:
             context.fill(imageRect)
         case .circle:
             context.fillEllipse(in: imageRect)
         }

         let image = UIGraphicsGetImageFromCurrentImageContext()
         UIGraphicsEndImageContext()
         return image!
     }()
}

enum ConfettiShape {
    case rectangle
    case circle
}

enum ConfettiPosition {
    case foreground
    case background
}
extension CAEmitterLayer {

    /**
     Pauses a CAEmitterLayer.
     */
    public func pause() {
        speed = 0.0 // Freeze the CAEmitterCells.
        timeOffset = convertTime(CACurrentMediaTime(), from: self) - beginTime
        lifetime = 0.0 // Produce no new CAEmitterCells.
    }

    /**
     Resumes a paused CAEmitterLayer.
     */
    public func resume() {
        speed = 1.0 // Unfreeze the CAEmitterCells.
        beginTime = convertTime(CACurrentMediaTime(), from: self) - timeOffset
        timeOffset = 0.0
        lifetime = 1.0 // Produce CAEmitterCells at previous rate.
    }

}
