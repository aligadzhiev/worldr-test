//
//  CollectionViewController.swift
//  WorldrTest
//
//  Created by Ali Gadzhiev on 10.08.2021.
//

import UIKit

private let reuseIdentifier = "Cell"

final class CollectionViewController: UICollectionViewController {

    private let viewModel = ViewModel(pageSize: 50)
    private let heightCalculator = CellHeightCalculator()
    private let sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    private var itemSizeCache = [IndexPath: CGSize]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Worldr Test"
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(refreshContent), for: .valueChanged)

        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = .zero
            layout.sectionInset = sectionInset
        }

        collectionView.refreshControl?.beginRefreshing()
        refreshContent()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return viewModel.itemsCount
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        if let cell = cell as? CollectionViewCell {
            cell.item = viewModel.item(at: indexPath.item)
        }
        return cell
    }

    // MARK: UIScrollViewDelegate

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if viewModel.hasMoreItems, scrollView.bounds.maxY >= scrollView.contentSize.height {
            guard let newIndices = viewModel.showNextPage() else { return }
            let indexPaths = newIndices.map { IndexPath(item: $0, section: 0) }
            collectionView.performBatchUpdates {
                self.collectionView.insertItems(at: indexPaths)
            }
        }
    }

    @objc
    private func refreshContent() {
        viewModel.load { [weak self] error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(with: error)
            } else {
                self.didRefreshContent()
            }
        }
    }

    private func didRefreshContent() {
        itemSizeCache.removeAll()
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionView.refreshControl?.endRefreshing()
    }

    private func showAlert(with error: Error) {
        let title = "Oops, something went wrong 😅"
        let controller = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        controller.addAction(.init(title: "Ok", style: .cancel, handler: nil))
    }

}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let cachedSize = itemSizeCache[indexPath] {
            return cachedSize
        }

        let item = viewModel.item(at: indexPath.item)
        let itemWidth = collectionView.frame.width - (sectionInset.left + sectionInset.right)
        let itemHeight = heightCalculator.height(for: item, maxWidth: itemWidth)
        let itemSize = CGSize(width: itemWidth, height: itemHeight)
        itemSizeCache[indexPath] = itemSize
        return itemSize
    }

}
