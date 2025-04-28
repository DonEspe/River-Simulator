//
//  Neighbor.swift
//  RiverSimulator
//
//  Created by Don Espe on 4/26/25.
//

import Foundation

enum Direction: CaseIterable {

    case up
    case down
    case left
    case right
}


struct Neighbor: Identifiable {
    var id = UUID()
    var x: Int
    var y: Int
    var elevation: Double
    var waterLevel: Double
    var offMap: Bool = false
    var direction: Direction?
    //    var type: ParticleType
}
