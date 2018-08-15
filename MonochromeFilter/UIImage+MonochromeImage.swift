//  UIImage extension, create monochrome image from source image
//  Created by Alexander Smetannikov on 31/07/2018.
//  More info about filters https://developer.apple.com/library/archive/documentation/GraphicsImaging/Reference/CoreImageFilterReference/index.html

import UIKit

extension UIImage {
    func monochromeImage(color: UIColor, intesity: Float = 1.0) -> UIImage? {
        guard let filter = CIFilter(name: "CIColorMonochrome" ) else {
            return nil
        }
        filter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        filter.setValue(CIColor(color: color), forKey: kCIInputColorKey)
        filter.setValue(NSNumber(value: intesity), forKey: kCIInputIntensityKey)

        let resultImage = filter.outputImage

        return resultImage == nil ? nil : UIImage(ciImage: resultImage!)
    }

    func monochromeImage(color: UIColor, intesity: Float = 1.0, result: @escaping ((UIImage?)->Void) ) {
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
