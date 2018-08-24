//
//  AGAnimatedBackgroundLayer.swift
//
//  Created by Alexander Smetannikov on 17/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

extension CGFloat {
    func toRadians() -> CGFloat {
       return self*CGFloat.pi/180
    }
}

public enum AGBackgroundAnimationKind {
    case scrollUp
    case scrollDown
    case rotateUp
    case rotateDown
    case stop
}

class AGSymbolPath {
    static let symbolDefaultSize: CGFloat = 340
    static func getPath(withScale scale: CGFloat)-> CGPath {
        let path = UIBezierPath()

        path.move(to: CGPoint(x: (4+31)*scale, y: 334*scale))
        path.addLine(to: CGPoint(x: (74+31)*scale, y: 317*scale))
        path.addLine(to: CGPoint(x: (139+31)*scale, y: 71*scale))
        path.addLine(to: CGPoint(x: (206+31)*scale, y: 317*scale))
        path.addLine(to: CGPoint(x: (274+31)*scale, y: 334*scale))
        path.addLine(to: CGPoint(x: (186+31)*scale, y: 6*scale))
        path.addLine(to: CGPoint(x: (92+31)*scale, y: 6*scale))
        path.addLine(to: CGPoint(x: (4+31)*scale, y: 334*scale))

        return path.cgPath
    }
}

class AGSymbolLayer: CAShapeLayer {
    var symbolColor: UIColor!
    var defaultAngle: CGFloat!

    init(withPath: CGPath, angle: CGFloat, symbolColor: UIColor) {
        defaultAngle = angle
        self.symbolColor = symbolColor
        super.init()
        path = withPath
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        if let layer = layer as? AGSymbolLayer {
            symbolColor = layer.symbolColor
            defaultAngle = layer.defaultAngle
        }
        super.init(layer: layer)
    }

    func draw(withAngle: CGFloat? = nil) {
        strokeColor = symbolColor.cgColor
        fillColor = symbolColor.cgColor
        lineWidth = 1

        let angle: CGFloat = withAngle ?? defaultAngle
        if angle != 0 {
            transform = CATransform3DMakeRotation(angle.toRadians(), 0, 0, 1)
        }
    }

    func rotate(angle: CGFloat) {
        transform = CATransform3DMakeRotation(angle.toRadians(), 0, 0, 1)
    }
}


class AGSymbolsRowLayer: CALayer {
    private var symbolLayers: [AGSymbolLayer] = []
    private var symbolSize: CGFloat!

    init(frame: CGRect, symbolsInRow: Int, symbolPath: CGPath, symbolSize: CGFloat, symbolColor: UIColor, defaultAngles: [CGFloat]) {
        super.init()

        anchorPoint = CGPoint(x: 0, y: 0)
        self.frame = frame

        let xMargin = (frame.width - (CGFloat(symbolsInRow)*2 - 1)*symbolSize)/2
        let yMargin = (frame.height - symbolSize) / 2

        for index in 0..<symbolsInRow {
            let angleIndex =  index % defaultAngles.count
            let agSymbol = AGSymbolLayer(withPath: symbolPath, angle: defaultAngles[angleIndex], symbolColor: symbolColor)
            agSymbol.frame = CGRect(x: xMargin + (symbolSize*2) * CGFloat(index), y: yMargin + agSymbol.bounds.height/2, width: symbolSize, height: symbolSize)
            symbolLayers.append(agSymbol)
            addSublayer(agSymbol)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(layer: Any) {
        if let layer = layer as? AGSymbolsRowLayer {
            symbolSize = layer.symbolSize
        }
        super.init(layer: layer)
    }

    func draw() {
        symbolLayers.forEach { $0.draw() }
    }

    func rotateUp() {
        symbolLayers.forEach { $0.rotate(angle: 0) }
    }

    func rotateDown() {
        symbolLayers.forEach { $0.rotate(angle: 180) }
    }

    func rotateToDefaulPosition() {
        symbolLayers.forEach { $0.rotate(angle: $0.defaultAngle) }
    }
}

class AGAnimatedBackgroundLayer: CAScrollLayer, CAAnimationDelegate {

    override var frame: CGRect { didSet { redraw() } }
    var rowHeight: CGFloat! { didSet { redraw() } }
    var symbolSize: CGFloat! { didSet { redraw() } }
    var symbolColor: UIColor! { didSet { redraw() } }
    var symbolsAngles: [[CGFloat]]! { didSet { redraw() } }

    private var symbolsRowLayers: [AGSymbolsRowLayer]? {
        get { return sublayers?.filter({ $0 is AGSymbolsRowLayer }) as? [AGSymbolsRowLayer] }
    }

    private var kindOfAnimation: AGBackgroundAnimationKind = .stop
    private var currentAnimation: CABasicAnimation?
    private var scrollUpAnimation: CABasicAnimation!
    private var scrollDownAnimation: CABasicAnimation!

    init(frame: CGRect, backgroundColor: UIColor, rowHeight: CGFloat, symbolSize: CGFloat, symbolColor: UIColor, symbolsAngles: [[CGFloat]]) {
        self.rowHeight = rowHeight
        self.symbolColor = symbolColor
        self.symbolSize = symbolSize
        self.symbolsAngles = symbolsAngles
        super.init()
        self.frame = frame
        self.backgroundColor = backgroundColor.cgColor

        scrollUpAnimation = createScrollAnimation(toValue: -rowHeight, withCycleDuration: 1)
        scrollDownAnimation = createScrollAnimation(toValue: rowHeight, withCycleDuration: 1)

        draw()
    }

    override init(layer: Any) {
        if let layer = layer as? AGAnimatedBackgroundLayer {
            rowHeight = layer.rowHeight
            symbolColor = layer.symbolColor
            symbolSize = layer.symbolSize
            symbolsAngles = layer.symbolsAngles
            scrollUpAnimation = layer.scrollUpAnimation
            scrollDownAnimation = layer.scrollDownAnimation
        }

        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func draw() {
        let partsInRow = (frame.width/symbolSize).rounded(.down)
        let symbolsInRow = Int((partsInRow/2).rounded())
        let symbolScale: CGFloat = symbolSize/AGSymbolPath.symbolDefaultSize
        let symbolPath = AGSymbolPath.getPath(withScale: symbolScale)

        // (-1, +1) добавляем две дополнительных строки символов для анимации
        for i in -1...(Int(frame.height / rowHeight) + 1) {
            let anglesIndex = abs(i % symbolsAngles.count)
            let rotationRow = AGSymbolsRowLayer(
                frame: CGRect(x: 0, y: CGFloat(i)*rowHeight, width: frame.width, height: rowHeight),
                symbolsInRow: symbolsInRow,
                symbolPath: symbolPath,
                symbolSize: symbolSize,
                symbolColor: symbolColor,
                defaultAngles: symbolsAngles[anglesIndex])
            rotationRow.draw()
            addSublayer(rotationRow)
        }
    }

    private func redraw() {
        sublayers?.removeAll()
        draw()
        animate(kindOfAnimation)
    }

    private func createScrollAnimation(toValue: CGFloat, withCycleDuration: CFTimeInterval) -> CABasicAnimation {
        let scrollingAnimation = CABasicAnimation(keyPath: "sublayerTransform.translation.y")
        scrollingAnimation.duration = 1
        scrollingAnimation.fromValue = 0
        scrollingAnimation.toValue = toValue
        scrollingAnimation.repeatCount = 1

        return scrollingAnimation
    }

    public func animate(_ kindOfAnimation: AGBackgroundAnimationKind) {
        removeAllAnimations()
        self.kindOfAnimation = kindOfAnimation
        // создаем нужный тип анимации
        switch kindOfAnimation {
        case .scrollUp:
            symbolsRowLayers?.forEach({ $0 .rotateUp() })
            currentAnimation = scrollUpAnimation
        case .scrollDown:
            symbolsRowLayers?.forEach({ $0.rotateDown() })
            currentAnimation = scrollDownAnimation
        case .rotateUp:
            symbolsRowLayers?.forEach({ $0.rotateUp() })
            currentAnimation?.delegate = nil
            currentAnimation = nil
        case .rotateDown:
            symbolsRowLayers?.forEach({ $0.rotateDown() })
            currentAnimation?.delegate = nil
            currentAnimation = nil
        case .stop:
            symbolsRowLayers?.forEach({ $0.rotateToDefaulPosition() })
            currentAnimation?.delegate = nil
            currentAnimation = nil
        }

        // стартуем анимацию
        if let currentAnimation = currentAnimation {
            currentAnimation.delegate = self
            add(currentAnimation, forKey: "scrolling")
        }
    }

    public func stop() {
        currentAnimation = nil
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else {
            return
        }

        if let currentAnimation = currentAnimation {
            add(currentAnimation, forKey: "scrolling")
        }
    }
}




