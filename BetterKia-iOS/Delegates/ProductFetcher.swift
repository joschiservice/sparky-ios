//
//  ProductFetcher.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 26.03.23.
//

import Foundation
import StoreKit

class ProductFetcher: NSObject, SKProductsRequestDelegate {
    
    var productsRequest: SKProductsRequest?
    var productsCompletionHandler: (([SKProduct]?, Error?) -> Void)?
    
    func fetchProductInformation(for productIdentifiers: Set<String>, completionHandler: @escaping ([SKProduct]?, Error?) -> Void) {
        productsCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        productsCompletionHandler?(response.products, nil)
        clearRequestAndHandler()
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        productsCompletionHandler?(nil, error)
        clearRequestAndHandler()
    }
    
    private func clearRequestAndHandler() {
        productsRequest = nil
        productsCompletionHandler = nil
    }
    
}
