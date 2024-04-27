//
//  ContentView.swift
//  focus
//
//  Created by Maxime Kahn on 16/09/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var circleTimer : CGFloat = 1.0
    @State private var timerMinutes : Int = 0
    @State private var timerSeconds : Int = 0
    @State private var timerAllSecondsFixed : Int = 0
    @State private var isEditing = false
    @State private var crown : Angle = Angle(degrees: 0)
    @State private var onPress : Bool = true
    let animation = Animation
            .easeOut(duration: 3)
            .delay(0.1)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func trimTimer(timerAllSecondsFixed: Int, timerAllSeconds: Int) -> CGFloat
    {
        return (1 / CGFloat(timerAllSecondsFixed)) * CGFloat(timerAllSecondsFixed - timerAllSeconds)
    }
    
    func angle(for location: CGPoint) -> Angle {
        let vector = CGVector(dx: location.x, dy: location.y)
        return .radians(Double(atan2(vector.dy, vector.dx)))
    }
    
    var body: some View {
            VStack {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 25, dash: [2]))
                    .foregroundStyle(Color.white)
                    .frame(width: 360, height: 360)
                    .rotationEffect(crown)
                    .gesture(
                        DragGesture(minimumDistance: 0.0)
                            .onChanged { value in
                                onPress = true
                                let drag = CGVector(dx: value.translation.width, dy: value.translation.height)
                                let angle = Angle(radians: Double(atan2(drag.dy, drag.dx)))
                                let delta = angle.degrees - round(crown.degrees)
                                if(delta > 0){
                                    if(timerSeconds >= 59){
                                        timerSeconds = 0
                                        timerMinutes = timerMinutes + 1
                                    }
                                    timerSeconds = timerSeconds + 1
                                }else if(delta < 0) {
                                    if(timerSeconds > 0){
                                        timerSeconds = timerSeconds - 1
                                    }else if(timerSeconds == 0){
                                        timerSeconds = 59
                                        if(timerMinutes > 0){
                                            timerMinutes = timerMinutes - 1
                                        }
                                    }
                                }
                                crown.degrees = angle.degrees
                                
                            }
                            .onEnded { value in
                                onPress = false
                                timerAllSecondsFixed = 60 * timerMinutes + timerSeconds
                            }
                    )
                    .overlay {
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 45))
                            .foregroundStyle(.tertiary)
                            .frame(width: 232, height: 300)
                            .overlay {
                                Circle()
                                    .trim(from: 0, to: circleTimer)
                                    .stroke(style: StrokeStyle(lineWidth: 45, lineCap: .round))
                                    .fill(.pink)
                                    .rotationEffect(.degrees(-90))
                                    .animation(animation, value: circleTimer)
                                    .overlay {
                                        Text("\(timerMinutes)m \(timerSeconds)s")
                                            
                                            .fontWeight(.bold)
                                            .font(.system(size: 36))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                    }
                            }
                            .onReceive(timer) { time in
                                if(!onPress){
                                    if timerSeconds > 0 {
                                        timerSeconds = timerSeconds - 1
                                    } else if(timerMinutes > 0 && timerSeconds <= 0){
                                        timerMinutes = timerMinutes - 1
                                        timerSeconds = 59
                                    }else{
                                        timerSeconds = 0
                                    }
                                    var timerAllSeconds = timerSeconds + 60 * timerMinutes
                                    circleTimer = trimTimer(timerAllSecondsFixed: timerAllSecondsFixed, timerAllSeconds: timerAllSeconds)
                                    print(circleTimer)
                                }
                            }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
