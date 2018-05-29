//
//  CustomTextField.swift
//  HuntedRadar
//
//  Created by BoTingDing on 2018/5/29.
//  Copyright © 2018年 BoTingDing. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class SPTextField: UITextField {
    
    private let borderThickness: (active: CGFloat, inactive: CGFloat) = (active: 1, inactive: 1)
    private let inactiveBorderLayer = CALayer()
    private let activeBorderLayer = CALayer()
    
    @IBInspectable
    var leftImage : UIImage? {
        didSet {
            updateView()
        }
    }
    @IBInspectable
    var rigthPadding : CGFloat = 0 {
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var borderInactiveColor : UIColor = .clear{
        didSet{
            updateBorder()
        }
    }
    @IBInspectable
    var borderActiveColor : UIColor = .clear{
        didSet{
            updateBorder()
        }
    }
    
    @IBInspectable
    var alertImage : UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var imageSize : CGFloat = 20 {
        didSet{
            updateView()
        }
    }
    override open func willMove(toSuperview newSuperview: UIView!) {
        if newSuperview != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditing), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: self)
            
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditing), name: NSNotification.Name.UITextFieldTextDidEndEditing, object: self)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    @objc open func textFieldDidBeginEditing() {
        activeBorderLayer.frame = actionForBorder(borderThickness.active, isFilled: true)
        rightViewMode = .never
    }
    @objc open func textFieldDidEndEditing() {
        activeBorderLayer.frame = actionForBorder(borderThickness.active, isFilled: false)
        rightViewMode = .never
    }
    
    private func actionForBorder(_ thickness: CGFloat, isFilled: Bool) -> CGRect {
        if isFilled {
            return CGRect(origin: CGPoint(x: imageSize, y: frame.height - thickness), size: CGSize(width: 0, height: thickness))
        } else {
            return CGRect(origin: CGPoint(x: imageSize, y: frame.height - thickness), size: CGSize(width: 0, height: thickness))
        }
    }
    
    private func updateBorder() {
        inactiveBorderLayer.frame = actionForBorder(borderThickness.inactive, isFilled: true)
        inactiveBorderLayer.backgroundColor = borderInactiveColor.cgColor
        
        activeBorderLayer.frame = actionForBorder(borderThickness.active, isFilled: false)
        activeBorderLayer.backgroundColor = borderActiveColor.cgColor
        
        layer.addSublayer(inactiveBorderLayer)
        layer.addSublayer(activeBorderLayer)
    }
    
    private func updateView() {
        if let icon = leftImage{
            leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
            
            var width = imageSize + rigthPadding
            
            if borderStyle == UITextBorderStyle.none || borderStyle == UITextBorderStyle.line {
                width += 5
            }
            imageView.image = icon
            imageView.tintColor = tintColor
            let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
            view.addSubview(imageView)
            leftView = view
        }else{
            
            leftViewMode = .never
        }
//
//        if let alertIcon = alertImage {
//            rightViewMode = .never
//            let alertImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
//            let alertView = UIView(frame:  CGRect(x: 0, y: 0, width: imageSize+5, height: imageSize))
//            alertImageView.image = alertIcon
//            alertImageView.tintColor = tintColor
//            alertView.addSubview(alertImageView)
//            rightView = alertView
//        }else{
//            rightViewMode = .never
//        }
    }
    
    public func invalidFieldAlert() {
        rightViewMode = .unlessEditing
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint : CGPoint.init(x: self.center.x - 5.0, y: self.center.y))
        animation.toValue = NSValue(cgPoint : CGPoint.init(x: self.center.x + 5.0, y: self.center.y))
        layer.add(animation, forKey: "position")
    }
}
