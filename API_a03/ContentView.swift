//
//  ContentView.swift
//  API_a03
//
//  Created by นายธนภัทร สาระธรรม on 6/3/2567 BE.
//

import SwiftUI

struct ContentView: View {
    @StateObject var weatherViewModel = WeatherViewModel()
    @State private var cityName: String = ""
    @State private var showErrorAlert = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Text("The Weather")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.black)
                    .padding(.top, -150)
                
                TextField("Enter city name", text: $cityName, onCommit: {
                    weatherViewModel.fetchWeather(for: cityName)
                })
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.system(size: 24, weight: .bold, design: .serif))
    
                if let weather = weatherViewModel.weather {
                    Text("City: \(weather.name)")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                    Text("Temperature: \(weather.main.temp - 273)°C")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                    Text("Description: \(weather.weather.first?.description ?? "")")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                    Text("Humidity: \(weather.main.humidity)%")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                } else if let error = weatherViewModel.error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.black).fontWeight(.bold)
                } else {
                    Text("Loading...")
                        .foregroundColor(.black)
                }
            }
            .font(.system(size: 25))
            .padding()
        }
    }
}

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherData?
    @Published var error: Error?
    
    func fetchWeather(for city: String) {
        let apiKey = "e7a1945e99848a309c4a4484bd4fa231"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)"
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data {
                        do {
                            self.weather = try JSONDecoder().decode(WeatherData.self, from: data)
                        } catch {
                            self.error = error
                        }
                    } else if let error = error {
                        self.error = error
                    }
                }
            }.resume()
        }
    }
}

func isValidCityName(_ city: String) -> Bool {
    return !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
}

struct WeatherData: Codable {
    let name: String
    let weather: [Weather]
    let main: Main
}

struct Weather: Codable {
    let main: String
    let description: String
}

struct Main: Codable {
    let temp: Double
    let humidity: Int
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
