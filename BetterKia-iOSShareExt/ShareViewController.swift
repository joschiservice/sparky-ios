//
//  ShareViewController.swift
//  BetterKia-iOSShareExt
//
//  Created by Joschua Haß on 16.06.23.
//

import UIKit
import UniformTypeIdentifiers
import MapKit
import SwiftUI

class ShareViewController: UIViewController {
    let mapItemIdentifier = "com.apple.mapkit.map-item";
    var hostingController: UIHostingController<ShareView>!;
    var uiState = ShareViewState()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Construct View
        hostingController = UIHostingController(rootView: ShareView(state: uiState))
        hostingController.view.backgroundColor = .clear;
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.didMove(toParent: self)
        
        loadMapItemData();
    }
    
    private func loadMapItemData() {
        guard let extensionItem = extensionContext!.inputItems.first as? NSExtensionItem else {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return;
        }
        
        if (extensionItem.attachments == nil) {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return;
        }
        
        let mapItemProvider = extensionItem.attachments!.first {
            $0.hasItemConformingToTypeIdentifier(mapItemIdentifier)
        }
        
        if (mapItemProvider == nil) {
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
            return;
        }
        
        mapItemProvider!.loadItem(forTypeIdentifier: mapItemIdentifier, options: nil) { (item, error) in
            
            guard let data = item as? Data else {
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                return;
            }
            
            var mapItem: MKMapItem!;
            do {
                mapItem = try NSKeyedUnarchiver.unarchivedObject(ofClass: MKMapItem.self, from: data)
            } catch {
                print("An error occured while unarchiving the map item: \(error)")
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                return;
            }
            
            if (mapItem == nil) {
                self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                return;
            }
            
            self.processMapItemData(mapItem)
        }
    }
    
    private func processMapItemData(_ mapItem: MKMapItem) {
        let placemark = mapItem.placemark;
        
        let phone = mapItem.phoneNumber;
        let coord = placemark.coordinate;
        
        // No localized address available, so we stick to the German format for now
        let addr = "\(placemark.thoroughfare ?? "") \(mapItem.placemark.subThoroughfare ?? "")";
        
        let zip = placemark.postalCode;
        let name = mapItem.name;
        
        print(name);
        print(addr);
        
        Task {
            try await Task.sleep(nanoseconds: UInt64(4 * Double(NSEC_PER_SEC)))
            
            uiState.status = .success
            
            try await Task.sleep(nanoseconds: UInt64(2 * Double(NSEC_PER_SEC)))
            
            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        }
    }
}
