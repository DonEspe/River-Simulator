
import Foundation
import SwiftUI

enum ParticleType: String, CaseIterable {

    case sand = "Sand"
//    case water = "Water"
    case rock = "Rock"
//    case snow = "Snow"
//    case ice = "Ice"
    case solid = "Solid"
    case none = "Blank"
}

let highestElevation = 10.0 //20.0

let nonMoving:[ParticleType] = [.none, .solid]

struct Particle: Identifiable {
    var id = UUID()
    //    var position: CGPoint
    var type: ParticleType
    var moved = false
    var active = true
//    var hueCount = 0.0
    var previousDirection: Direction?
    var elevation: Double {
        didSet {
            if elevation < 0 {
                if self.waterAmount <= 0 {
                    self.waterAmount -= elevation
                }
                self.elevation = 0
            }
            if elevation > highestElevation {
                self.elevation = highestElevation
            }
        }
    }

    var partOfCircle = false

    var waterAmount = 0.0 {
        didSet {
            if waterAmount < 0 {
                waterAmount = 0
            }
        }
    }

    func adjustedColor() -> Color {

        if type == .solid {
            return Color(.white)
        }

        let adjustedElevation = (elevation + waterAmount) / highestElevation

        return Color(red: adjustedElevation , green: adjustedElevation, blue: adjustedElevation)
    }

    func color() -> Color {
        if type == .solid {
            return Color(.white)
        }

        let adjustedElevation = (elevation) / highestElevation

        return Color(red: adjustedElevation , green: adjustedElevation, blue: adjustedElevation)

    }
}
