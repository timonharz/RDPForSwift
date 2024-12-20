//
//  SwiftRDP.swift
//  Oneboard
//
//  Created by Timon Harz on 20.03.24.
//

import SwiftUI
import UIKit
import CoreGraphics
import Foundation

//MARK: - CGPoint based

class DouglasPeucker {
    var epsilon: CGFloat

    init(epsilon: CGFloat) {
        self.epsilon = epsilon
    }

    func simplify(points: [CGPoint]) -> [CGPoint] {
        guard points.count >= 3 else { return points }

        let dmaxIndex = points.indices.dropFirst().dropLast().max { i, j in
            perpendicularDistance(point: points[i], lineStart: points.first!, lineEnd: points.last!) <
            perpendicularDistance(point: points[j], lineStart: points.first!, lineEnd: points.last!)
        }!

        let dmax = perpendicularDistance(point: points[dmaxIndex], lineStart: points.first!, lineEnd: points.last!)

        if dmax > epsilon {
            let firstPart = simplify(points: Array(points[...(dmaxIndex)]))
            let secondPart = simplify(points: Array(points[dmaxIndex...]))
            return firstPart.dropLast() + secondPart
        } else {
            let angleThreshold = cos(Double(45) * Double.pi / Double(180)) // Adjust as needed
            var maxCosine = -1.0
            var index = 0

            for i in 1..<(points.count - 1) {
                let cosine = calculateCosine(points[i - 1], points[i], points[i + 1])

                if cosine > maxCosine {
                    maxCosine = cosine
                    index = i
                }
            }

            if maxCosine < angleThreshold {
                return [points.first!] + [points[index]] + [points.last!]
            } else {
                return [points.first!, points.last!]
            }
        }
    }

    func perpendicularDistance(point: CGPoint, lineStart: CGPoint, lineEnd: CGPoint) -> CGFloat {
        let dx = lineEnd.x - lineStart.x
        let dy = lineEnd.y - lineStart.y

        guard dx != 0 || dy != 0 else { return sqrt(pow(point.x - lineStart.x, 2) + pow(point.y - lineStart.y, 2)) }

        let u = ((point.x - lineStart.x) * dx + (point.y - lineStart.y) * dy) / (dx * dx + dy * dy)
        let x = lineStart.x + u * dx
        let y = lineStart.y + u * dy

        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }

    func calculateCosine(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGFloat {
        let v1 = CGVector(dx: p2.x - p1.x, dy: p2.y - p1.y)
        let v2 = CGVector(dx: p3.x - p2.x, dy: p3.y - p2.y)

        let dotProduct = v1.dx * v2.dx + v1.dy * v2.dy
        let magnitudeProduct = sqrt((v1.dx * v1.dx + v1.dy * v1.dy) * (v2.dx * v2.dx + v2.dy * v2.dy))

        if magnitudeProduct == 0 {
            return 1.0 // Avoid division by zero
        }

        return dotProduct / magnitudeProduct
    }
}
