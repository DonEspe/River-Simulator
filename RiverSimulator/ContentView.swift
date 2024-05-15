//
//  ContentView.swift
//  RiverSimulator
//
//  Created by Don Espe on 5/9/24.
//

import SwiftUI

let actualSize = (width: 350, height: 480)
let scale = 3
let playSize = (width: actualSize.width / scale, height: actualSize.height / scale)

struct ContentView: View {

    @State var map = Array(repeating: Array(repeating: Particle(type: .none ), count: Int(playSize.height)), count: Int(playSize.width))
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
                    map = Array(repeating: Array(repeating: Particle(type: .none, active: true), count: Int(playSize.height)), count: Int(playSize.width))
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
