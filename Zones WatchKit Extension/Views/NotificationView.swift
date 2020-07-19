//
//  NotificationView.swift
//  Zones WatchKit Extension
//
//  Created by Steph Ananth on 7/17/20.
//  Copyright © 2020 Steph K. Ananth. All rights reserved.
//

import SwiftUI

struct NotificationView: View {
    private let viewModel = ViewModel.shared

    var body: some View {
        guard let previousZoneValue = viewModel.previousHeartRateZone?.rawValue else {
            return Text("Zone \(viewModel.heartRateZone.rawValue)")
        }
        return Text("Zone \(previousZoneValue) -> Zone \(viewModel.heartRateZone.rawValue)")
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
