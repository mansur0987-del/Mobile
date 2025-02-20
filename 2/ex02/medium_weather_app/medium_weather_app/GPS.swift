//
//  GPS.swift
//  medium_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
	private var locationManager = CLLocationManager()
	
	@Published var latitude: Double?
	@Published var longitude: Double?
	@Published var error : String?
	
	override init() {
		super.init()
		self.locationManager.delegate = self
	}
	
	func requestLocation() {
		self.error = nil
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.requestLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		DispatchQueue.main.async {
			self.latitude = location.coordinate.latitude
			self.longitude = location.coordinate.longitude
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		if let clError = error as? CLError {
			switch clError.code {
			case .denied:
				self.error = "Access to geolocation is prohibited. Allow it in the settings."
			case .locationUnknown:
				self.error = "Couldn't determine location."
			default:
				self.error = "Error: \(clError.localizedDescription)"
			}
		}
	}
}

