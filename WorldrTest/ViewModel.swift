//
//  ViewModel.swift
//  WorldrTest
//
//  Created by Ali Gadzhiev on 10.08.2021.
//

import Alamofire
import Foundation

final class ViewModel {

    private var isLoading = false
    private var items = [Item]()
    private let networkSession = AF
    private let url = "https://s3.us-west-2.amazonaws.com/secure.notion-static.com/0d9b2471-6c63-4114-9e6a-d15884bd90c6/testfile.json?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAT73L2G45O3KS52Y5%2F20210810%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20210810T144552Z&X-Amz-Expires=86400&X-Amz-Signature=2fff56931dfc1374a81def67d93376da8b16bd2615fc4d2efff7dae88ea81daa&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22testfile.json%22"
    private let workQueue = DispatchQueue(label: "worldrtest.view-model-working-queue")
    private let pageSize: Int

    private(set) var itemsCount = 0
    private(set) var hasMoreItems = false

    init(pageSize: Int = 50) {
        self.pageSize = pageSize
    }

    func item(at index: Int) -> Item {
        items[index]
    }

    func showNextPage() -> Range<Int>? {
        guard hasMoreItems else { return nil }

        let newItemsCount = min(items.count, itemsCount + pageSize)
        let range = itemsCount..<newItemsCount
        itemsCount = newItemsCount
        hasMoreItems = itemsCount < items.count
        return range
    }

    func load(completion: @escaping (Error?) -> Void) {
        guard !isLoading else { return }

        isLoading = true
        networkSession
            .request(url, method: .get)
            .responseDecodable(of: [Item].self, queue: workQueue) { [weak self] response in
                DispatchQueue.main.async {
                    guard let self = self else { return }

                    self.isLoading = false
                    switch response.result {
                    case .success(let items):
                        self.items = items
                        self.itemsCount = min(items.count, self.pageSize)
                        self.hasMoreItems = self.itemsCount < self.items.count
                        completion(nil)
                    case .failure(let error):
                        completion(error)
                    }
                }
            }
    }
}
