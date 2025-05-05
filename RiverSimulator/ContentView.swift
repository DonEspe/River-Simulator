//
//  ContentView.swift
//  RiverSimulator
//
//  Created by Don Espe on 5/9/24.
//

import SwiftUI
import Foundation

let actualSize = (width: 350, height: 460)
let scale = 4
let playSize = (width: actualSize.width / scale, height: actualSize.height / scale)

struct ContentView: View {

    @State var map = Array(repeating: Array(repeating: Particle(type: .sand, elevation: Double.random(in: -10...10)), count: Int(playSize.height)), count: Int(playSize.width))
    @State var drawSize = 10.0
    @State var sprayLevel = 70.0
    @State var showActive = false
    @State var rain = true
    @State var showWater = true
    @State var changeElevation = false
    @State var lowerElevation = true
    @State var showElevation = false
    @State var drawType = ParticleType.sand

    @State var totalWater = 0.0

    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    @State var paused = false
    let rainColor = Color(red: 0.25, green: 0.5, blue: 0.75)

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.01, paused: paused)) { timeline in
            VStack {
                Text("River Simulator")
                    .bold()
                    .font(.title)
                    .padding(.top)
                ZStack {
                    Rectangle()
                        .stroke(lineWidth: 3)
                        .foregroundColor(.blue)
                    Canvas { context, size in
                        for y in 0..<(playSize.height) {
                            for x in 0..<(playSize.width) {
                                if !showElevation {
                                    context.fill(
                                        Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * scale), y: CGFloat(y * scale)), size: CGSize(width: scale, height: scale)), cornerSize: CGSize(width: 0, height: 0)),
                                        with: (.color(map[x][y].color())))

                                    if map[x][y].type == .rock {
                                        context.fill(
                                            Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * scale), y: CGFloat(y * scale)), size: CGSize(width: scale, height: scale)), cornerSize: CGSize(width: 0, height: 0)),
                                            with: .color(Color(red: 0.5 , green: 0.25 , blue: 0).opacity(0.3)))
                                    }
                                } else {
                                    context.fill(
                                        Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * scale), y: CGFloat(y * scale)), size: CGSize(width: scale, height: scale)), cornerSize: CGSize(width: 0, height: 0)),
                                        with: (.color(map[x][y].adjustedColor())))
                                }

                                if showWater {
                                    context.fill(
                                        Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * scale), y: CGFloat(y * scale)), size: CGSize(width: scale, height: scale)), cornerSize: CGSize(width: 0, height: 0)),
                                        with: (map[x][y].waterAmount > 0 ? .color(.blue.opacity(( map[x][y].waterAmount / 3) + 0.2)) : .color(.clear)))
                                }

                                if showActive || map[x][y].partOfCircle {
                                    context.fill(
                                        Path(roundedRect: CGRect(origin: CGPoint(x: CGFloat(x * scale), y: CGFloat(y * scale)), size: CGSize(width: scale, height: scale)), cornerSize: CGSize(width: 0, height: 0)),
                                        with: (map[x][y].active ? .color(.green.opacity(0.25)) : .color(.clear)))
                                }
                            }
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let radius = Int(drawSize)
                                let useLocation = (x: Int(value.location.x / CGFloat(scale)), y: Int(value.location.y / CGFloat(scale)))
                                if useLocation.y < playSize.height - 1 && useLocation.x < playSize.width - 1 && useLocation.x >= 0 && useLocation.y >= 0 {
                                    for i in (useLocation.x - radius - 2)...(useLocation.x + radius + 2) {
                                        for j in (useLocation.y - radius - 2)...(useLocation.y + radius + 2) {
                                            if ((i - useLocation.x) * (i - useLocation.x)) + ((j - useLocation.y) * (j - useLocation.y)) < radius * 2 {
                                                if i >= 0 && i < playSize.width && j >= 0 && j < playSize.height {
                                                    map[i][j].partOfCircle = true
                                                    if  Double.random(in: 0...100) <= sprayLevel {
                                                        if changeElevation {
                                                            map[i][j].type = drawType

                                                            if nonMoving.contains(drawType) {
                                                                map[i][j].waterAmount = 0
                                                            }

                                                           if lowerElevation {
                                                               map[i][j].elevation -= 0.3
                                                           } else {
                                                               map[i][j].elevation += 0.3
                                                           }
                                                       } else {
                                                           map[i][j].waterAmount += 0.1
                                                       }
                                                       map[i][j].active = true
                                                       for x in (i - 1)...(i + 1) {
                                                           for y in (j - 1)...(j + 1) {
                                                               if x >= 0 && x < (playSize.width) && y >= 0 && y < (playSize.height) {
                                                                   map[x][y].active = true
                                                               }
                                                           }
                                                       }
                                                   }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .onEnded { _ in
                            })

                }
                .frame(width: CGFloat(playSize.width * scale), height: CGFloat(playSize.height * scale))
                .padding()
                .scaledToFill()
                HStack {
                    Toggle(isOn: $showElevation) {
                        Text("Show elevation")
                    }
                    .toggleStyle(CheckToggleStyle())
                    Spacer()
                    Toggle(isOn: $showWater) {
                        Text("Show Water")
                    }
                    .toggleStyle(CheckToggleStyle())
                    Spacer()
                    Text("Total Water: \(Int(totalWater))")
                }
                .font(.subheadline)

                HStack {
                    Text("Draw size (\(Int(drawSize))): ")
                    Slider(value: $drawSize, in: 1...50)
                }

                HStack {
                    Text("Spray Level (\(Int(sprayLevel))): ")
                    Slider(value: $sprayLevel, in: 0...100)
                }
                HStack(spacing: 10) {
                    Toggle(isOn: $rain) {
                        Text("Rain")
                    }
                    .toggleStyle(CheckToggleStyle())

                    Spacer()
                    HStack {
                        Spacer()
                        if changeElevation {
                            Text("Draw type: ")
                            Picker("Draw type", selection: $drawType) {
                                ForEach(ParticleType.allCases, id: \.self) {
                                    Text($0.rawValue)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(Color.primary.blendMode(.difference))
                            .background(.blue.opacity(0.6))
                            .clipShape(.capsule)
                            Spacer()
                        }
                    }
                    Spacer()
                    Toggle(isOn: $paused) {
                        Text("Pause")
                    }
                    .toggleStyle(CheckToggleStyle())
                }

                HStack() {
                    Text("Touches: ")
                    Button(action: {
                        changeElevation.toggle()
                    }) {
                        Text(changeElevation ? "Modify": "Rain")
                    }

                    if changeElevation {
                        Spacer()

                        Button(action: {
                            lowerElevation.toggle()
                        }) {
                            Text("\(lowerElevation ? "Lower":"Raise") Elevation")
                        }
                    }

                    Spacer()
                }
                HStack {
                    Button("Dump water over entire map") {
                        for i in 0..<playSize.width  {
                            for j in 0..<playSize.height  {
                                map[i][j].waterAmount += 0.05
                            }
                        }
                    }
                    Spacer()
                    Button("Remove water") {
                        for i in 0..<playSize.width  {
                            for j in 0..<playSize.height  {
                                map[i][j].waterAmount = 0
                            }
                        }
                    }
                }

                Button("Reset") {
                    for i in 0..<playSize.width  {
                        for j in 0..<playSize.height  {
                            map[i][j] = Particle(type: .sand, elevation: Double.random(in: -6...15))
                            if Int.random(in: 0...100) > 90 {
                                map[i][j].type = .rock
                            }
                        }
                    }

                    // Smooth
                    for i in 0...playSize.width - 1 {
                        for j in 0...playSize.height - 1 {
                            var tempTotal: Double = 0.0
                            var count = 0

                            for x in -1...1 {
                                for y in -1...1 {
                                    if i + x < playSize.width {
                                        if let elevation = getElevation(map: map, position: (x: i + x, y: j + y)) {
                                            count += 1
                                            tempTotal += elevation
                                        }
                                    }
                                }
                            }

                            let average = tempTotal / Double(count)

                            for x in -1...1 {
                                for y in -1...1 {
                                    if i + x < playSize.width {
                                        if let elevation = getElevation(map: map, position: (x: i + x, y: j + y)) {
                                            map[i + x][j + y].elevation = (elevation + average) / 2
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Spacer()
            }

            .onReceive(timer, perform: { _ in
                if paused {
                    return
                }

                if rain {
                    for _ in 0...10 {
                        let randomX = Int.random(in: 0..<playSize.width)
                        let randomY = Int.random(in: 0..<playSize.height)
                        if !nonMoving.contains(map[randomX][randomY].type) {
                            map[randomX][randomY].waterAmount += 0.15
                            map[randomX][randomY].active = true
                        }
                    }
                }
                totalWater = 0.0
                for i in 0..<playSize.width {
                    for j in (0..<playSize.height) {
                        totalWater += map[i][j].waterAmount
                        if !map[i][j].moved {
                            map[i][j].previousDirection = nil
                        }
                        map[i][j].moved = false
                        map[i][j].partOfCircle = false
                    }
                }

                for i in 0..<playSize.width {
                    for j in (0..<playSize.height) {
                        map = moveParticle(particles: map, position: (x: i, y: j))
                    }
                }
            })
        }
    }

    func getElevation(map: [[Particle]], position: (x: Int, y: Int)) -> Double? {
        if position.x >= 0 && position.x < playSize.width && position.y >= 0 && position.y < playSize.height {
            return map[position.x][position.y].elevation
        }

        return nil
    }

    func calcNeighbor(position: (x: Int, y: Int), direction: Direction?, open: [ParticleType] = [.none]) -> Neighbor? {
        if position.x < 0 || position.x >= playSize.width || position.y < 0 || position.y >= playSize.height {
            return Neighbor(x: 0, y: 0, elevation: 0, waterLevel: 0, offMap: true)
        }

        if !open.contains(map[position.x][position.y].type) {
            return nil
        }

        return Neighbor(x: position.x, y: position.y, elevation: map[position.x][position.y].elevation, waterLevel: map[position.x][position.y].waterAmount, direction: direction)
    }

    func moveParticle(particles: [[Particle]], position: (x: Int, y: Int)) -> [[Particle]] {

        let particle = particles[position.x][position.y]

        if !particle.active || particle.moved {
            return particles
        }

        var tempMap = particles

        if  !particle.active { //}|| nonMoving.contains(particle.type) {
            tempMap[position.x][position.y].active = false
            return tempMap
        }

        var neighbors = [Neighbor]()
        switch particle.type {
            case .solid, .none:
                tempMap[position.x][position.y].waterAmount = 0
                return tempMap

            case .sand, .rock:
                if let down = calcNeighbor(position: (x: position.x, y: position.y + 1),direction: .down, open: [.sand, .rock]) {
                    neighbors.append(down)
                }
                if let up = calcNeighbor(position: (x: position.x, y: position.y - 1), direction: .up, open: [.sand, .rock]) {
                    neighbors.append(up)
                }
                if let right = calcNeighbor(position: (x: position.x + 1, y: position.y), direction: .right, open: [.sand, .rock]) {
                    neighbors.append(right)
                }

                if let left = calcNeighbor(position: (x: position.x - 1, y: position.y), direction: .left, open: [.sand, .rock]) {
                    neighbors.append(left)
                }
        }

        if !neighbors.isEmpty {
            neighbors.shuffle()
            if let inertialLocation = neighbors.first(where: {$0.direction == particle.previousDirection}) {
                neighbors.removeAll(where: { $0.id == inertialLocation.id })
                neighbors.insert(inertialLocation, at: 0)
            }

            var erosionAdjust = 10.0

            switch particle.type {
                case .sand:
                    erosionAdjust = 2.0
                case .rock:
                    erosionAdjust = 10.0
                case .solid, .none:
                    erosionAdjust = 100000
            }

            for location in neighbors {
                let endElevation = (tempMap[location.x][location.y].waterAmount + tempMap[location.x][location.y].elevation)
                let startElevation = (tempMap[position.x][position.y].elevation + tempMap[position.x][position.y].waterAmount)
                let difference = endElevation - startElevation
                if difference < 0 {
                    if tempMap[position.x][position.y].waterAmount > 0 {
                        let moveAmount = min(0.2, tempMap[position.x][position.y].waterAmount, abs(difference))
                        tempMap[position.x][position.y].previousDirection = location.direction
                        tempMap[position.x][position.y].waterAmount -= moveAmount
                        tempMap[position.x][position.y].elevation -= (moveAmount / erosionAdjust)

                        if !location.offMap  {
                            tempMap[location.x][location.y].waterAmount += moveAmount
                            tempMap[location.x][location.y].elevation += (moveAmount / erosionAdjust)
                            tempMap[location.x][location.y].previousDirection = location.direction
                        }
                        tempMap[location.x][location.y].moved = true
                    }
                }
            }
        }

        return tempMap
    }
}

#Preview {
    ContentView()
}
