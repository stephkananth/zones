//
//  ContentView.swift
//  Zones WatchKit Extension
//
//  Created by Steph Ananth on 7/17/20.
//  Copyright © 2020 Steph K. Ananth. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel = ViewModel.shared

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(viewModel.heartRateZone.getColor())
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2.5)
                            .frame(width: 100, height: 100)
                )
            }
            ZStack {
                Text("\(Int(viewModel.heartRate))")
                    .font(.system(size: 48))
                    .fontWeight(.ultraLight)
            }
        }
        .onAppear {
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
