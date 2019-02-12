
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "ab7f5a7202255afe4c50c53b6bc285fc"
    
    //declare instance variables here
    let locationManager = CLLocationManager();
    let weatherDataModel = WeatherDataModel();
    
    //IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Set up the location manager here
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //get Weather Data method
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if (response.result.isSuccess) {
                print("Success! Got data");
                
                let weatherJSON : JSON = JSON(response.result.value!);
                self.updateWeatherData(json: weatherJSON);
                print(weatherJSON);
            
            } else {
                print("Error", response.result.error);
                self.cityLabel.text = "Connection Issues";
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //update Weather Data method
    
    func updateWeatherData(json : JSON) {
        
        if let temp = json["main"]["temp"].double {
        
            weatherDataModel.temperature = Int(((temp - 273.15) * (9 / 5)) + 32);
        
            weatherDataModel.city = json["name"].stringValue;
        
            weatherDataModel.condition = json["weather"][0]["id"].intValue;
        
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition);
            
            //calls updateUI to display weather data
            updateUIWithWeatherData();
            
            
        } else {
            cityLabel.text = "Weather Unavailable";
        }
    }
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city;
        temperatureLabel.text = String(weatherDataModel.temperature);
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName);
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1];
        if (location.horizontalAccuracy > 0) {
            locationManager.stopUpdatingLocation();
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)");
            
            let latitude = String(location.coordinate.latitude);
            let longitude = String(location.coordinate.longitude);
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID];
            
            getWeatherData(url: WEATHER_URL, parameters: params);
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
        cityLabel.text = "Location Unavailable";
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params);
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "changeCityName") {
            
            let destinationVC = segue.destination as! ChangeCityViewController;
            
            destinationVC.delegate = self;
        }
    }
    
    
    
    
}


