//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON
//import MapKit


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDateModel = WeatherDataModel()
    

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String: String]){

        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in

            if response.result.isSuccess {

                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result

                if let json = response.result.value {

                    print("JSON: \(JSON(json))") // serialized json response
                    self.updateWeatherData(json: JSON(json))
                }

//                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    print("Data: \(utf8Text)") // original server data as UTF8 string
//                }
            }else{


                if let error = response.result.error?.localizedDescription{
                    NSLog(error)
                    self.cityLabel.text = "connection issues"
                }

            }


        }

    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        if let temp = json["main"]["temp"].double{
            weatherDateModel.temperature = Int(temp - 273.15)

            let name = json["name"].stringValue
            weatherDateModel.city = name

            weatherDateModel.condition = json["weather"][0]["id"].intValue

            weatherDateModel.weatherIconName = weatherDateModel.updateWeatherIcon(condition: weatherDateModel.condition)

            updateUIWithWeatherData()
        } else {
            cityLabel.text = "Weather unavaible"
        }



    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        self.cityLabel.text = weatherDateModel.city
        self.temperatureLabel.text = String(weatherDateModel.temperature)
        self.weatherIcon.image = UIImage(named: weatherDateModel.weatherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]

        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil

            print("\(location.coordinate.latitude) / \(location.coordinate.longitude)")

            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)

            let params: [String : String] = ["lat" : lat, "lon" : lon, "appid" : APP_ID]

            getWeatherData(url: WEATHER_URL, parameters: params )

            fetchCityAndCountry(from: location) { (city, country, error) in
                guard let city = city, let country = country, error == nil else { return }
                print(city + ", " + country)
                self.cityLabel.text = city
            }
        }
    }

    //Write the fetchCityAndCountry method here:
    func fetchCityAndCountry(from location: CLLocation, completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            completion(placemarks?.first?.locality,
                       placemarks?.first?.country,
                       error)
        }
    }
    
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog(error.localizedDescription)
        cityLabel.text = error.localizedDescription
    }
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnterANewCity(city: String) {

        if city.isNilOrEmpty() == false  {
            print("Pesquisando pela cidade \(city)")

            let params: [String : String] = ["q" : city, "appid" : APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params )
        }

    }
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {

            let destinationVC = segue.destination as! ChangeCityViewController

            destinationVC.delegate = self


        }
    }
    
    
    
    
    
}


