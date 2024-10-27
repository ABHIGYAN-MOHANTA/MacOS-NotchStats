//
//  CirculatingOutlineShape.swift
//  NotchStats
//
//  Created by Abhigyan Mohanta on 27/10/24.
//


import SwiftUI

struct CirculatingOutlineShape: Shape {
    var radius: CGFloat
    var trimStart: CGFloat
    var trimEnd: CGFloat

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(trimStart, trimEnd) }
        set {
            trimStart = newValue.first
            trimEnd = newValue.second
        }
    }

    func path(in rect: CGRect) -> Path {
        let centerSpaceWidth = 0.0
        let sideWidth = rect.width * 0.3
        let leftSectionEnd = sideWidth
        let rightSectionStart = leftSectionEnd + centerSpaceWidth

        var path = Path()

        // Start from the top-left, outline clockwise
        path.move(to: CGPoint(x: 0, y: 0))

        // Top left section
        path.addLine(to: CGPoint(x: leftSectionEnd, y: 0))

        // Right top section
        path.move(to: CGPoint(x: rightSectionStart, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))

        // Right side
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        // Bottom side, continuous from right to left
        path.addLine(to: CGPoint(x: radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)

        // Left side, back to start
        path.addLine(to: CGPoint(x: 0, y: 0))

        // Complete outline with trim effect
        return path.trimmedPath(from: trimStart, to: trimEnd)
    }
}

struct CirculatingOutlineModifier: ViewModifier {
    @State private var trimStart: CGFloat = 0
    @State private var trimEnd: CGFloat = 0.15 // Length of the moving line

    func body(content: Content) -> some View {
        content
            .overlay(
                CirculatingOutlineShape(radius: 10, trimStart: trimStart, trimEnd: trimEnd)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.purple.opacity(0.8),
                                Color.blue.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .blur(radius: 0.5)
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 3)
                        .repeatForever(autoreverses: false)
                ) {
                    trimStart = 1
                    trimEnd = 1.15
                }
            }
    }
}

extension View {
    func circulatingOutline() -> some View {
        modifier(CirculatingOutlineModifier())
    }
}
