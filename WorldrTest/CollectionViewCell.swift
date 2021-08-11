//
//  CollectionViewCell.swift
//  WorldrTest
//
//  Created by Ali Gadzhiev on 10.08.2021.
//

import UIKit
import AlamofireImage

final class CollectionViewCell: UICollectionViewCell {

    static let font = UIFont.systemFont(ofSize: 16)

    var item: Item? {
        didSet {
            guard item != oldValue else { return }

            itemChanged()
        }
    }
    private lazy var stackView = UIStackView(arrangedSubviews: [imageView, label])
    private let imageView = UIImageView()
    private let label = UILabel()
    private var imageRatioConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

    private func itemChanged() {
        guard let item = item else {
            imageView.image = nil
            label.text = nil
            stackView.isHidden = true
            return
        }

        label.text = item.text

        if let attachment = item.attachment {
            setupImageRatioConstraint(for: attachment)

            imageView.af.setImage(withURL: attachment.url)
            imageView.isHidden = false
        } else {
            imageView.isHidden = true
            imageView.af.cancelImageRequest()
        }
    }

    private func setupImageRatioConstraint(for attachment: Attachment) {
        if let constraint = imageRatioConstraint {
            NSLayoutConstraint.deactivate([constraint])
        }
        let multiplier = CGFloat(attachment.width / attachment.height)
        let imageRatioConstraint = imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor,
                                                                    multiplier: multiplier)
        NSLayoutConstraint.activate([
            imageRatioConstraint
        ])

        self.imageRatioConstraint = imageRatioConstraint
    }

    private func commonInit() {
        label.font = Self.font
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        contentView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

}
