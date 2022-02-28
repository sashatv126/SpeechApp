//
//  UIView+Utilities.swift
//

import UIKit

extension UIView {
    func shadow(
        radius: CGFloat = 8,
        offset: CGSize = CGSize(width: 0, height: 7),
        opacity: Float = 1.0,
        color: UIColor = UIColor.black.withAlphaComponent(0.2)
    ) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
