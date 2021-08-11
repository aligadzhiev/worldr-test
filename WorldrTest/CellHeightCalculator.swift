//
//  CellHeightCalculator.swift
//  WorldrTest
//
//  Created by Ali Gadzhiev on 10.08.2021.
//

import UIKit

final class CellHeightCalculator {

    func height(for item: Item, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - 16
        let attributes: [NSAttributedString.Key: Any] = [
            .font: CollectionViewCell.font
        ]
        let attributedText = NSAttributedString(string: item.text, attributes: attributes)
        let textRect = attributedText.boundingRect(with: .init(width: width, height: .greatestFiniteMagnitude),
                                                   options: [.usesLineFragmentOrigin],
                                                   context: nil)

        let imageHeight: CGFloat
        if let attachment = item.attachment {
            imageHeight = width / CGFloat(attachment.width / attachment.height)
        } else {
            imageHeight = 0
        }
        return textRect.integral.height + 16 + imageHeight
    }
}
