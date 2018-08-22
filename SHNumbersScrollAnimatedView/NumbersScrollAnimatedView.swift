
//
//  NumbersScrollAnimatedView.swift
//
//
//  Inspired by https://github.com/jonathantribouharet/JTNumberScrollAnimatedView
//
//  Created by Alexander Smetannikov on 07/08/2018.
//  Copyright © 2018 Alexander Smetannikov. All rights reserved.
//

import UIKit

public class NumbersScrollAnimatedView: UIView {
    /// Значение для отображния, числовые символы будут скроллироваться
    public var text: String = ""

    public var font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    public var textColor: UIColor = .black
    /// Длительность анимации
    public var animationDuration: CFTimeInterval = 5

    /**
     Позволяет задать функцию которая определяет смещение времени начала анимации каждого символа.
     По умолчанию задана функция возвращающая случайные значения от 0 до 1.

     Параметры:

     **text**: отоброжаемый текст

     **index**: индекс символа для которго будет применена эта функция

     Возвращает смещение времени начала анимации конкретного символа.
     */

    public var animationTimeOffsetRule: ((_ text: String, _ index: Int) -> CFTimeInterval)!
    /**
     Позволяет задать функцию которая определяет уменшение длительности анимации каждого символа.
     По умолчанию задана функция возвращающая случайные значения от 0 до 1

     Параметры:

     **text**: отоброжаемый текст

     **index**: индекс символа для которго будет применена эта функция

     Возвращает значение для уменьшения длительности анимации конкретного символа.
     */
    public var animationDurationOffsetRule: ((_ text: String, _ forColumn: Int) -> CFTimeInterval)!

    /**
     Позволяет задать функцию которая определяет направление анимации каждого символа, вверх (.up) или вниз (.down).
     По умолчанию задана функция возвращающая случайные значения.

     Параметры:

     **text**: отоброжаемый текст

     **index**: индекс символа для которго будет применена эта функция

     Возвращает направление анимации для конкретного символа
     */
    public var scrollingDirectionRule: ((_ text: String, _ forColumn: Int) -> NumbersScrollAnimationDirection)!

    /**
     Позволяет задать функцию которая определяет выполнять или нет инвертацию последовательности цифр.
     По умолчанию инвертация не выполняется, для анимации используется послеловательность 0123456789, если задана инвертация, то при анимации сипользуется последовательность 9876543210

     Параметры:

     **text**: отоброжаемый текст

     **index**: индекс символа для которго будет применена эта функция

     Возвращает bool-значение выполнять или не выполнять инвертацию последовательности цифр 01234567890
     */
    public var inverseSequenceRule: ((_ text: String, _ forColumn: Int) -> Bool)!

    private var scrollableColumns: [ NumbersScrollableColumn] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        animationTimeOffsetRule = NumbersScrollAnimatedView.random
        animationDurationOffsetRule = NumbersScrollAnimatedView.random
        scrollingDirectionRule = NumbersScrollAnimatedView.random
        inverseSequenceRule = NumbersScrollAnimatedView.random
    }

    public func setValue(_ value: Int, animated: Bool) {

    }

    public func startAnimation() {
        prepareAnimation()
        createAnimations()
    }

    private func prepareAnimation() {
        scrollableColumns.forEach { $0.removeFromSuperlayer() }
        scrollableColumns.removeAll()

        createScrollColumns()
    }

    public func stopAnimation() {
        scrollableColumns.forEach { $0.removeAllAnimations() }
    }

    fileprivate func createScrollColumns() {
        let height: CGFloat = frame.height

        let numericSymbolWidth = String.numericSymbolsMaxWidth(usingFont: font)
        var width: CGFloat
        var xPosition: CGFloat = 0
        for character in text {
            if let _ = Int(String(character)) {
                width = numericSymbolWidth
            } else {
                width = String(character).width(usingFont: font)
            }

            let newColumnFrame = CGRect(x: xPosition , y: 0, width: width, height: height)
            let newColumn =  NumbersScrollableColumn(withFrame: newColumnFrame, forLayer: layer, font: font, textColor: textColor)
            newColumn.symbol = character
            scrollableColumns.append(newColumn)

            xPosition += width
        }

        let xOffset = (layer.bounds.width - xPosition) / 2.0
        scrollableColumns.forEach { $0.scrollLayer.position.x += xOffset }
    }

    fileprivate func createAnimations() {
        for (index, column) in scrollableColumns.enumerated() {
            column.createAnimation(
                timeOffset: animationTimeOffsetRule(text, index),
                duration: animationDuration,
                durationOffset: animationDurationOffsetRule(text, index),
                scrollingDirection: scrollingDirectionRule(text, index),
                inverseSequence: inverseSequenceRule(text, index))
        }
    }
}

extension NumbersScrollAnimatedView {

    static func random(_ scrollableValue: String, _ forColumn: Int) -> CFTimeInterval {
        return drand48()
    }

    static func random(_ scrollableValue: String, _ forColumn: Int) -> Bool {
        let randomValue = arc4random_uniform(2)
        if  randomValue == 0 {
            return true
        } else {
            return false
        }
    }

    static func random(_ scrollableValue: String, _ forColumn: Int) -> NumbersScrollAnimationDirection {
        if arc4random_uniform(2) == 0 {
            return .down
        } else {
            return .up
        }
    }
}

private extension String {
    func size(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedStringKey.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size
    }

    func width(usingFont font: UIFont) -> CGFloat {
        return size(usingFont: font).width
    }

    func height(usingFont font: UIFont) -> CGFloat {
        return size(usingFont: font).height
    }

    static func numericSymbolsMaxWidth(usingFont font: UIFont) -> CGFloat {
        var maxWidth:CGFloat = 0

        for symbol in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] {
            maxWidth = Swift.max(maxWidth, symbol.width(usingFont: font))
        }

        return maxWidth
    }
}
