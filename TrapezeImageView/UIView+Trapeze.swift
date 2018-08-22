//
//  UIView+Trapeze.swift
//
//  Created by Alexander Smetannikov on 20/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

extension UIView {
    public func applyTrapezeMask(leftSideRatio: CGFloat = 0.5, rightSideRatio: CGFloat = 1.0) {
        let maskLayer = CAShapeLayer()
        let width = bounds.width
        let height = bounds.height

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: height))
        path.addLine(to: CGPoint(x: 0, y: height - height * leftSideRatio))
        path.addLine(to: CGPoint(x: width, y: height - height * rightSideRatio))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))

        maskLayer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: height))
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.strokeColor = UIColor.white.cgColor
        maskLayer.path = path.cgPath

        layer.mask = maskLayer
    }
}
