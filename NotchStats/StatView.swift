//
//  StatView.swift
//  NotchStats
//
//  Created by Abhigyan Mohanta on 27/10/24.
//


import SwiftUI

struct LeftRoundedShape: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Start from top-left
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                   radius: radius,
                   startAngle: .degrees(90),
                   endAngle: .degrees(180),
                   clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct RightRoundedShape: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                   radius: radius,
                   startAngle: .degrees(0),
                   endAngle: .degrees(90),
                   clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .foregroundColor(.gray)
            Text(value)
                .foregroundColor(.white)
        }
        .font(.system(size: 12, weight: .medium))
    }
}
