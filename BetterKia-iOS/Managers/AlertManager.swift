//
//  AlertManager.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 19.02.23.
//

import Foundation

public class AlertManager : ObservableObject {
    public static var shared = AlertManager()
    
    @Published var showAlert = false {
        didSet {
            if (showAlert == true) {
                return
            }
            alertQueue.remove(at: 0)
            setNextAlert()
        }
    }
    @Published var currentAlertTitle = ""
    @Published var currentAlertDescription = ""
    
    private var alertQueue: [AlertItem] = []
    
    public func publishAlert(_ title: String, description: String) {
        if (alertQueue.count == 0) {
            alertQueue.append(AlertItem(title: title, description: description))
            setNextAlert()
            return
        }
        
        alertQueue.append(AlertItem(title: title, description: description))
    }
    
    private func setNextAlert() {
        if (alertQueue.count > 0) {
            DispatchQueue.main.async {
                self.currentAlertTitle = self.alertQueue.first!.title
                self.currentAlertDescription = self.alertQueue.first!.description
                self.showAlert = true
            }
        }
    }
    
    struct AlertItem {
        let title: String
        let description: String
    }
}
