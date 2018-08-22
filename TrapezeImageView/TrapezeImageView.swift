//
//  TrapezeImageView.swift
//
//  Created by Alexander Smetannikov on 31/07/2018.
//  Copyright © 2018 AlexSmetannikov. All rights reserved.
//

import UIKit

/// ImageView c наложением трапецивидной маски в верхней части
public class TrapezeImageView: UIImageView {

    /// Видимая пропорция левой стороны, от 0 до 1, по умолчаннию 0.5
    public var leftSideRatio: CGFloat = 0.5 {
        didSet {
            applyMask()
            setNeedsDisplay()
        }
    }

    /// Видимая пропорция правой стороны, от 0 до 1, по умолчанию 1.0
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

    override public var frame: CGRect {
        didSet {
            applyMask()
        }
    }
}
