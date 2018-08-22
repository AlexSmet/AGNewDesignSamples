//
//  UIImage+Monochrome.swift
//
//  UIImage extension, создание монохромного изображения из исходного
//  More info about filters https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html
//
//  Created by Alexander Smetannikov on 31/07/2018.


import UIKit

extension UIImage {

    /// Создание монохромного изображения из исходного
    func monochrome(color: UIColor, intesity: Float = 1.0) -> UIImage? {
        guard let filter = CIFilter(name: "CIColorMonochrome" ) else {
            return nil
        }
        filter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        filter.setValue(CIColor(color: color), forKey: kCIInputColorKey)
        filter.setValue(NSNumber(value: intesity), forKey: kCIInputIntensityKey)

        let resultImage = filter.outputImage

        return resultImage == nil ? nil : UIImage(ciImage: resultImage!)
    }

    /// Асинхронное создание монохромного изображения из исходного
    func monochrome(color: UIColor, intesity: Float = 1.0, result: @escaping ((UIImage?)->Void) ) {
        guard let filter = CIFilter(name: "CIColorMonochrome" ) else {
            result(nil)
            return
        }
        filter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        filter.setValue(CIColor(color: color), forKey: kCIInputColorKey)
        filter.setValue(NSNumber(value: intesity), forKey: kCIInputIntensityKey)

        DispatchQueue.global(qos: .utility).async {
            let resultImage = filter.outputImage
            DispatchQueue.main.async {
                result(resultImage == nil ? nil : UIImage(ciImage: resultImage!))
            }
        }
    }
}
