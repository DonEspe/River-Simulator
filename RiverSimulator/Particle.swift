
import Foundation
import SwiftUI

enum ParticleType: String, CaseIterable {

    case sand = "Sand"
    case rainbowSand = "Rainbow Sand"
    case water = "Water"
    case snow = "Snow"
    case ice = "Ice"
    case fire = "Fire"
    case steam = "Steam"
    case solid = "Solid"
    case none = "Blank"
}

let highestElevation = 20.0

let nonMoving:[ParticleType] = [.none, .solid]

struct Particle: Identifiable {
    var id = UUID()
    //    var position: CGPoint
    var type: ParticleType
    var moved = false
    var active = true
    var hueCount = 0.0
    var elevation: Double {
        didSet {
            if elevation < 0 {
                self.waterAmount -= elevation
                self.elevation = 0
            }
            if elevation > highestElevation {
                self.elevation = highestElevation
            }
        }
    }
    
    var waterAmount = 0.0 {
        didSet {
            if waterAmount < 0 {
                waterAmount = 0
            }
        }
    }
    
    func color() -> Color {
        let adjustedElevation = (elevation) / highestElevation
//        if waterAmount < 0.5 && elevation < 0.5 {
//            return Color(red: 0, green: 1, blue: 1)
//        }
        
//        if waterAmount <= 0.2 {  // 0.3 {
            return Color(red: adjustedElevation , green: adjustedElevation, blue: adjustedElevation)
//        } else {
//            print("waterLevel: \(waterAmount)")
//            return Color(red: 0, green: 0, blue: (waterAmount / 4) + 0.3) // showing elevation of 1... possibly move water into these areas...
//        }
    }
}
