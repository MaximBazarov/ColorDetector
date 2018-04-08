//
//  ColorDetectionService.swift
//  ColorDetector
//
//  Created by Maxim Bazarov on 4/4/18.
//  Copyright © 2018 Maxim Bazarov. All rights reserved.
//

import UIKit
import ColorThiefSwift
import FunctionalFoundation

struct SmartColor {
    let value: UIColor
    let name: String
}

class ColorDetector {
    
    let colorStream = Observable<SmartColor?>(nil)
    
    func detectColor(forImage image: UIImage){
        let cropped = crop(image)
        guard let color = ColorThief.getColor(from: cropped)?.makeUIColor()
            , let name = ColorDetector.colorNameRepository.name(for: color) else { return }
        colorStream.value = SmartColor(value: color, name: name)
    }
 
    init(cropRect rect:CGRect) {
        self.cropRect = rect
    }

    // MARK: - Implementation
    private let cropRect: CGRect
    private static let colorNameRepository = ColorNameRepository()

    
    public func crop(_ image:UIImage) -> UIImage {
        let croppedCGImage:CGImage = (image.cgImage?.cropping(to: cropRect))!
        return UIImage(cgImage: croppedCGImage)
    }
    
    
}
