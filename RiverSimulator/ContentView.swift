//
//  ContentView.swift
//  RiverSimulator
//
//  Created by Don Espe on 5/9/24.
//

import SwiftUI

let actualSize = (width: 350, height: 480)
let scale = 5
let playSize = (width: actualSize.width / scale, height: actualSize.height / scale)

struct ContentView: View {

    @State var map = Array(repeating: Array(repeating: Particle(type: .sand, elevation: Double.random(in: -10...10)), count: Int(playSize.height)), count: Int(playSize.width))
    @State var drawSize = 10.0
    @State var showActive = false
    @State var rainParticles = true

    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    //    @StateObject private var storm = Storm()

    @State var paused = false
    let rainColor = Color(red: 0.25, green: 0.5, blue: 0.75)

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.01, paused: paused)) { timeline in

            VStack {
                Text("River Simulator")
                    .bold()
                    .font(.title)
                    .padding()
                ZStack {
                    Rectangle()
                        .stroke(lineWidth: 2)
                        .foregroundColor(.blue)
                    Canvas { context, size in
                        for y in 0..<(playSize.height) {
                            for x in 0..<(playSize.width) {
                                context.fill(
                                    Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * scale), y: CGFloat(y * scale)), size: CGSize(width: scale, height: scale)), cornerSize: CGSize(width: 0, height: 0)),
                                    with: (.color(map[x][y].color())))

                                context.fill(
                                    Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * scale), y: CGFloat(y * scale)), size: CGSize(width: scale, height: scale)), cornerSize: CGSize(width: 0, height: 0)),
                                    with: (map[x][y].waterAmount > 0.2 ? .color(.blue.opacity(0.4)) : .color(.clear)))

                                if showActive {
                                    context.fill(
                                        Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * scale), y: CGFloat(y * scale)), size: CGSize(width: scale, height: scale)), cornerSize: CGSize(width: 0, height: 0)),
                                        with: (map[x][y].active ? .color(.green.opacity(0.25)) : .color(.clear)))
                                }
                            }
                        }
                    }
                }
                .frame(width: CGFloat(playSize.width * scale), height: CGFloat(playSize.height * scale))
                .padding()
                .scaledToFill()

                Button("Reset") {
                    for i in 0..<playSize.width  {
                        for j in 0..<playSize.height  {
                            map[i][j] = Particle(type: .sand, elevation: Double.random(in: -6...15))
                        }
                    }

                    // Smooth

//                    for i in stride(from: 0, through:playSize.width - 3, by: 1)  {
//                        for j in stride(from: 0, through:playSize.height - 3, by: 1)  {

                    for i in 0...playSize.width - 3 {
                        for j in 0...playSize.height - 3 {

                            let upperLeft = map[i][j].elevation
                            let upperCenter = map[i+1][j].elevation
                            let upperRight = map[i+2][j].elevation
                            let Left = map[i][j+1].elevation
                            let Center = map[i+1][j+1].elevation
                            let Right = map[i+2][j+1].elevation
                            let lowerLeft = map[i][j+2].elevation
                            let lowerCenter = map[i+1][j+2].elevation
                            let lowerRight = map[i+2][j+2].elevation

                            let average = (upperLeft + upperCenter + upperRight + Left + Center + Right + lowerLeft + lowerCenter + lowerRight) / 9.0
                            map[i][j].elevation = (average + map[i][j].elevation)  / 2
                            map[i+1][j].elevation = (average + map[i+1][j].elevation)  / 2
                            map[i+2][j].elevation = (average + map[i+2][j].elevation)  / 2
                            map[i][j+1].elevation = (average + map[i][j+1].elevation)  / 2
                            map[i+1][j+1].elevation = (average + map[i+1][j+1].elevation)  / 2
                            map[i+2][j+1].elevation = (average + map[i+2][j+1].elevation)  / 2
                            map[i][j+2].elevation = (average + map[i][j+2].elevation)  / 2
                            map[i+1][j+2].elevation = (average + map[i+1][j+2].elevation)  / 2
                            map[i+2][j+2].elevation = (average + map[i+2][j+2].elevation)  / 2
                        }
                    }

                    //                    for (index, point) in map.enumerated() {
                    //                        print("index: ", index)
                    //                        map[index][index] = Particle(type: .sand, elevation: Double.random(in: -10...10))
                    //                    }
                    //                    map = Array(repeating: Array(repeating: Particle(type: .sand, elevation: Double.random(in: -10...10)), count: Int(playSize.height)), count: Int(playSize.width))
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Spacer()
            }
            //            .background(.black)
            .onReceive(timer, perform: { _ in
                if paused {
                    return
                }

                if rainParticles {
                    for _ in 0...5 {
                        let randomX = Int.random(in: 0..<playSize.width)
                        let randomY = Int.random(in: 0..<playSize.height)

                        map[randomX][randomY].waterAmount += 0.1
                        map[randomX][randomY].active = true
                    }
                }

                for i in 0..<playSize.width {
                    for j in (0..<playSize.height)  { // .reversed() {
//                        if map[i][j].active || nonMoving.contains(map[i][j].type) {
                            map = moveParticle(particles: map, position: (x: i, y: j))
//                        }
                    }
                }
            })
        }
    }

    func calcNeighbor(position: (x: Int, y: Int), open: [ParticleType] = [.none]) -> Neighbor? {
        if position.x < 0 || position.x >= playSize.width || position.y < 0 || position.y >= playSize.height {
            return Neighbor(x: 0, y: 0, elevation: 0, waterLevel: 0, offMap: true)
        }

        if !open.contains(map[position.x][position.y].type) {
            return nil
        }

        return Neighbor(x: position.x, y: position.y, elevation: map[position.x][position.y].elevation, waterLevel: map[position.x][position.y].waterAmount)
    }


    func moveParticle(particles: [[Particle]], position: (x: Int, y: Int)) -> [[Particle]] {

        let particle = map[position.x][position.y]

        if !particle.active {
            return particles
        }

        var tempMap = particles

        if nonMoving.contains(particle.type) || !particle.active {
            tempMap[position.x][position.y].active = false
            return tempMap
        }

        var neighbors = [Neighbor]()
        switch particle.type {
            case .solid, .none:
                return tempMap

            case .sand:
                if let right = calcNeighbor(position: (x: position.x + 1, y: position.y), open: [.sand, .water, .snow]) {
                    neighbors.append(right)
                }

                if let left = calcNeighbor(position: (x: position.x - 1, y: position.y), open: [.sand, .water, .snow]) {
                    neighbors.append(left)
                }

                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1), open: [.sand, .water, .snow]) {
                    neighbors.append(down)
                }

                if let up = calcNeighbor(position: (x: position.x, y: position.y - 1), open: [.sand, .water, .snow]) {
                    neighbors.append(up)
                }


            case .rainbowSand:
                print("rainbow")
            case .water:
                print("water")
            case .snow:
                print("snow")
            case .ice:
                print("ice")
            case .fire:
                print("fire")
            case .steam:
                print("steam")
        }

        if !neighbors.isEmpty {
//            while !neighbors.isEmpty {
////                print("neighbors count:, ", neighbors.count)
//                if let location = neighbors.randomElement() {
//                    if location.offMap {
//                        if particle.waterAmount > 0 {
//                            tempMap[position.x][position.y].waterAmount -= 0.1
//                        }
//                    } else {
//                        if ((location.waterLevel + location.elevation) < (particle.elevation + particle.waterAmount)) { //&& (particle.waterAmount > 0)  { // && !location.offMap {
//                            if tempMap[position.x][position.y].waterAmount > 0 {
//                                tempMap[position.x][position.y].waterAmount -= 0.2
//                                tempMap[location.x][location.y].waterAmount += 0.2
//                                tempMap[location.x][location.y].elevation += 0.175
//                                tempMap[position.x][position.y].elevation -= 0.175
//                            }
//                        }
//                    }
//                    neighbors.removeAll(where: { $0.id == location.id })
//                }
//            }

            for location in neighbors {
                if location.offMap && tempMap[position.x][position.y].waterAmount > 0 {
                    tempMap[position.x][position.y].waterAmount -= 0.1
//                    print("moved offmap... new level = ", tempMap[position.x][position.y].waterAmount)
                }

                if ((tempMap[location.x][location.y].waterAmount + tempMap[location.x][location.y].elevation) < (tempMap[position.x][position.y].elevation + tempMap[position.x][position.y].waterAmount)) && !location.offMap {
                    if tempMap[position.x][position.y].waterAmount > 0 {
                        tempMap[position.x][position.y].waterAmount -= 0.2
                        tempMap[location.x][location.y].waterAmount += 0.2
                        tempMap[location.x][location.y].elevation += 0.175
                        tempMap[position.x][position.y].elevation -= 0.175
                    }
                }
            }
        }


//        if !neighbors.isEmpty {
//            for i in (position.x - 1)...(position.x + 1) {
//                for j in (position.y - 1)...(position.y + 1) {
//                    if i >= 0 && i < (playSize.width) && j >= 0 && j < (playSize.height) {
//                        tempMap[i][j].active = true
//                    }
//                }
//            }
//        } else {
//            tempMap[position.x][position.y].active = false
//            return tempMap
//        }

        return tempMap
    }

}


//struct Raindrop: Hashable, Equatable {
//    var x: Double
//    var removalDate: Date
//    var speed: Double
//}
//
//class Storm: ObservableObject {
//    var drops = Set<Raindrop>()
//
//    func update(to date: Date) {
//        drops = drops.filter { $0.removalDate > date }
//        drops.insert(Raindrop(x: Double.random(in: 0...1), removalDate: date + 1, speed: Double.random(in: 1...2)))
//    }
//}

//#Preview {
//    ContentView()
//}
