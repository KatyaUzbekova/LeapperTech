//
//  SlideInTransition.swift
//  Leapper
//
//  Created by Kratos on 8/28/20.
//  Copyright © 2020 Leapper Technologies. All rights reserved.
//

import UIKit

class SlideInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresention = false
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) else{return}
         guard let fromViewController = transitionContext.viewController(forKey: .from) else {return}
        let containerView = transitionContext.containerView
        let finalWidth = toViewController.view.bounds.width * 0.8
        let finalHeight = toViewController.view.bounds.height
        if isPresention {
            containerView.addSubview(toViewController.view)
            toViewController.view.frame = CGRect(x: -finalWidth, y: 0, width: finalWidth, height: finalHeight)
        }
        let transform = {
            toViewController.view.transform = CGAffineTransform(translationX: finalWidth, y: 0)
            
        }
        let identity = {
            fromViewController.view.transform = .identity
        }
        let duration  = transitionDuration(using: transitionContext)
        
        let isCancelled = transitionContext.transitionWasCancelled
        UIView.animate(withDuration: duration, animations: {
             self.isPresention ? transform() :identity()
        }){(_)in
            transitionContext.completeTransition(!isCancelled)
        }
        
    }
    
    func transitionDuration(using transitionContext:UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}
