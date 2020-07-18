//
//  ContentView.swift
//  Zones WatchKit Extension
//
//  Created by Steph Ananth on 7/17/20.
//  Copyright © 2020 Steph K. Ananth. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        Circle()
            .fill(viewModel.heartRateZoneColor)
            .frame(width: 100, height: 100)
            .overlay(
                Text("\(Int(viewModel.heartRate))")
        ).onAppear {
            print("ContentView.body.onAppear()")
            self.viewModel.authorizeHealthKit()
            self.viewModel.refreshView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
