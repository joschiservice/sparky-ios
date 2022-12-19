//
//  VehicleStatusWidgetBundle.swift
//  VehicleStatusWidget
//
//  Created by Joschua Haß on 19.12.22.
//

import WidgetKit
import SwiftUI

@main
struct VehicleStatusWidgetBundle: WidgetBundle {
    var body: some Widget {
        VehicleStatusWidget()
        VehicleStatusWidgetLiveActivity()
    }
}
