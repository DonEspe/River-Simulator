
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

let nonMoving:[ParticleType] = [.none, .solid]

struct Particle: Identifiable {
    var id = UUID()
    //    var position: CGPoint
    var type: ParticleType
    var moved = false
    var active = true
    var hueCount = 0.0
    var elevation = 0.0

    func color() -> Color {
        let adjustedElevation = (elevation + 2) / 20

        if elevation > 0 {

            return Color(red: adjustedElevation , green: adjustedElevation, blue: adjustedElevation)
        } else {
            return Color(red: 0, green: 0, blue: 1)
        }


//        switch type {
//            case .sand:
//                return .yellow
//            case .rainbowSand:
//                return Color(hue: hueCount, saturation: 1, brightness: 1)
//            case .solid:
//                return .gray
//            case .water:
//                return .blue
//            case .snow:
//                return .white
//            case .steam:
//                return .gray.opacity(0.4)
//            case .ice:
//                return .teal
//            case .fire:
//                return .red
//            case .none:
//                return .clear
//        }
    }

}
