//
//  ContentView.swift
//  NotchStats
//
//  Created by Abhigyan Mohanta on 27/10/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var systemStats = SystemStats()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.0)
                
                HStack(spacing: 0) {
                    // Left side stats
                    VStack(alignment: .trailing) {
                        StatView(title: "CPU", value: "\(systemStats.cpuUsage)%")
                        StatView(title: "Memory", value: "\(systemStats.memoryUsage)%")
                    }
                    .frame(width: geometry.size.width * 0.3)
                    .frame(maxHeight: .infinity)
                    .background(
                        LeftRoundedShape(radius: 10)
                            .fill(Color.black)
                    )
                    
                    // Center space for notch
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geometry.size.width * 0.28)
                        .frame(maxHeight: .infinity)
                        .background(Color.black)
                    
                    // Right side stats
                    VStack(alignment: .leading) {
                        StatView(title: "  "+"", value: "Abhigyan Mohanta")
                        StatView(title: "    "+"\(systemStats.firstLineFromFile)", value: "")
                    }
                    .frame(width: geometry.size.width * 0.3)
                    .frame(maxHeight: .infinity)
                    .background(
                        RightRoundedShape(radius: 10)
                            .fill(Color.black)
                    )
                }.circulatingOutline()
            }
        }
        .frame(height: 40)
        .ignoresSafeArea()
    }
}
