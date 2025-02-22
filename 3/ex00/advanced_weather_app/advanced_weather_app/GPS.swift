//
//  GPS.swift
//  advanced_weather_app
//
//  Created by Mansur Kakushkin on 2/20/25.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
	private var locationManager = CLLocationManager()
	
	@Published var latitude: Double?
	@Published var longitude: Double?
	@Published var location: String?
	@Published var error : String?
	
	override init() {
		super.init()
		self.locationManager.delegate = self
	}
	
	func requestLocation() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.requestLocation()
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = locations.last else { return }
		DispatchQueue.main.async {
			self.latitude = location.coordinate.latitude
			self.longitude = location.coordinate.longitude
			self.fetchLocationName(from: location)
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		if let clError = error as? CLError {
			switch clError.code {
			case .denied:
				self.error = "Access to geolocation is prohibited. Allow it in the settings.";
			case .locationUnknown:
				self.error = "Couldn't determine location."
			default:
				self.error = "Error: \(clError.localizedDescription)"
			}
			self.latitude = nil
			self.longitude = nil
			self.location = nil
		}
	}
	
	func fetchLocationName(from location: CLLocation) {
		let geocoder = CLGeocoder()
		geocoder.reverseGeocodeLocation(location) { placemarks, error in
			guard let placemark = placemarks?.first, error == nil else { return }
			
			DispatchQueue.main.async {
				self.location = CollectName(line_1: placemark.locality, line_2: placemark.administrativeArea, line_3: nil, line_4: nil, country: placemark.country)
			}
		}
	}
}

