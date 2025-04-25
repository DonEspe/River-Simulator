//
//  ContentView.swift
//  RiverSimulator
//
//  Created by Don Espe on 5/9/24.
//

import SwiftUI

let actualSize = (width: 350, height: 480)
let scale = 4
let playSize = (width: actualSize.width / scale, height: actualSize.height / scale)

struct ContentView: View {

    @State var map = Array(repeating: Array(repeating: Particle(type: .sand, elevation: Double.random(in: -10...10)), count: Int(playSize.height)), count: Int(playSize.width))
    @State var drawSize = 10.0
    @State var showActive = false
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
                            map[i][j] = Particle(type: .sand, elevation: Double.random(in: -2...17))
                        }
                    }

                    // Smooth

                    for i in stride(from: 0, through:playSize.width - 3, by: 3)  {
                        for j in stride(from: 0, through:playSize.height - 3, by: 3)  {
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
                            map[i+2][j+1].elevation = (average + map[i+1][j+1].elevation)  / 2
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
        }
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

#Preview {
    ContentView()
}
