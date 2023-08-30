//
//  ContentView.swift
//  BetterRest
//
//  Created by Julian Miño on 29/08/2023.
//
import CoreML
import SwiftUI

struct ResultView: View {
    var idealBedtime: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center) {
                Spacer()
                Spacer()
                Text("Your ideal bedtime is:")
                    .fontWeight(.medium)
                    .font(.title2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(idealBedtime)")
                    .fontWeight(.heavy)
                    .font(.system(size: 50))
                Spacer()
                Spacer()
            }
            Spacer()
        }
    }
}

extension Color {
    static var random: Color {
        let red = Double.random(in: Double.random(in: 0.3...0.5)...Double.random(in: 0.5...1))
        let green = Double.random(in: Double.random(in: 0.3...0.5)...Double.random(in: 0.5...1))
        let blue = Double.random(in: Double.random(in: 0.3...0.5)...Double.random(in: 0.5...1))
        return Color(red: red, green: green, blue: blue)
    }
}

struct ContentView: View {
    @State private var wakeUpTime = defaultWakeUpTime
    @State private var sleepHours = 8.0
    @State private var cupsOfCoffee = 1
    
    static var defaultWakeUpTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        ZStack {
            AngularGradient(colors: [.random, .random, .random, .random], center: .topLeading)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("BetterRest")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(.thinMaterial)
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                    .clipShape(Capsule())
                Form {
                    Section {
                        DatePicker("Please enter a time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    } header: {
                        Text("When do you want to wake up?")
                    }
                    Section {
                        Stepper("\(sleepHours.formatted()) hours", value: $sleepHours, in: 4...12, step: 0.25)
                    } header: {
                        Text("Desired amount of sleep")
                    }
                    Section {
                        HStack {
                            Spacer()
                            Picker("Daily coffee intake", selection: $cupsOfCoffee, content: {
                                ForEach(1...20, id: \.self) { number in
                                    Text(number == 1 ? "1 cup" : "\(number) cups")
                                }
                            })
                            .labelsHidden()
                            .pickerStyle(.menu)
                        }
                    } header: {
                        Text("Daily coffee intake")
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                GeometryReader { geometry in
                    ResultView(idealBedtime: calculateBedtime().formatted(date: .omitted, time: .shortened))
                        .frame(height: geometry.size.height)
                        .background(.thickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(20)
        }
    }
    
    private func calculateBedtime() -> Date {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hoursInSeconds = (components.hour ?? 0) * 60 * 60
            let minutesInSeconds = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hoursInSeconds + minutesInSeconds), estimatedSleep: sleepHours, coffee: Double(cupsOfCoffee))
            
            let sleepTime = wakeUpTime - prediction.actualSleep
            return sleepTime
        } catch {
            return Date.now
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
