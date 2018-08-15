//
//  TrapezeImageView.swift
//
//  Created by Alexander Smetannikov on 31/07/2018.
//  Copyright © 2018 AlexSmetannikov. All rights reserved.
//

import UIKit

class TrapezeImageView: UIImageView {
    
    public var leftSideRatio: CGFloat = 0.5 {
        didSet {
            applyMask()
            setNeedsDisplay()
        }
    }

    public var rightSideRatio: CGFloat = 1.0 {
        didSet {
            applyMask()
            setNeedsDisplay()
        }
    }

    private var maskLayer = CAShapeLayer()

    private func applyMask() {
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

    override var frame: CGRect {
        didSet {
            applyMask()
        }
    }
}
