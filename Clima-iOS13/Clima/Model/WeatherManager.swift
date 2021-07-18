//
//  WeatherManager.swift
//  Clima
//
//  Created by Ahmed Nagy on 15/07/2021.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ error: Error)
}

class WeatherManager {
    
    var delegate: WeatherManagerDelegate?
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b105bd5cb0278ed3e09efc8098f4311e&units=metric"
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitute: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitute)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        //1. Create a URL
        guard let url = URL(string: urlString) else { print("Invalid URL"); return }
        
        //2. Create a URLSession
        let session = URLSession(configuration: .default)
        
        //3. Give a sessoin task
        let task = session.dataTask(with: url) { (data, response, error) in
            guard let safaData = data else {
                self.delegate?.didFailWithError(error!)
                return
            }
            
            guard let weather = self.parseJSON(safaData) else {
                print(error!.localizedDescription)
                return
            }
            self.delegate?.didUpdateWeather(self, weather: weather)
            
        }
        //4. Start the task
        task.resume()
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temperature = decodedData.main.temp
            let cityName = decodedData.name
            
            let weather = WeatherModel(conditionID: id, temperature: temperature, cityName: cityName)
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
    
    
}
