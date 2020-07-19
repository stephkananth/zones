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
        guard let previousZone = viewModel.previousHeartRateZone else {
            return Text("\(viewModel.heartRateZone.getBody())").fontWeight(.ultraLight)
        }
        return Text("\(previousZone.getBody()) -> \(viewModel.heartRateZone.getBody())").fontWeight(.ultraLight)
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
