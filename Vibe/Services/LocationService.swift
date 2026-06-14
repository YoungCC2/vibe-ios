//
//  LocationService.swift
//  Vibe
//
//  定位服务 — 获取当前位置并反解地址
//

import Foundation
import CoreLocation

@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    @Published var currentLocationName: String?
    @Published var isLocating = false

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationContinuation: CheckedContinuation<String?, Never>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    /// 请求权限并获取当前位置名称
    /// 返回类似 "重庆市渝中区" 的字符串，失败返回 nil
    func requestLocationName() async -> String? {
        let status = manager.authorizationStatus
        switch status {
        case .denied, .restricted:
            return nil
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            break
        }

        // 防止重复 resume：如果已有 continuation 先 cancel
        if locationContinuation != nil {
            locationContinuation?.resume(returning: nil)
            locationContinuation = nil
        }

        isLocating = true
        return await withCheckedContinuation { continuation in
            locationContinuation = continuation
            manager.requestLocation()
        }
    }

    /// 清除已选位置
    func clearLocation() {
        currentLocationName = nil
    }

    private func resolveLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location, preferredLocale: Locale(identifier: "zh_CN")) { [weak self] placemarks, _ in
            var name: String? = nil
            if let pm = placemarks?.first {
                // 拼接：城市 + 区/县
                var parts: [String] = []
                if let city = pm.locality ?? pm.subAdministrativeArea { parts.append(city) }
                if let district = pm.subLocality ?? pm.administrativeArea { parts.append(district) }
                // 如果有具体地名，更精确
                if let name2 = pm.name, parts.count < 2 {
                    parts.append(name2)
                }
                name = parts.isEmpty ? pm.description : parts.joined(separator: "·")
            }
            Task { @MainActor in
                guard let self else { return }
                self.currentLocationName = name
                self.isLocating = false
                // 只有在有 continuation 时才 resume
                if let cont = self.locationContinuation {
                    self.locationContinuation = nil
                    cont.resume(returning: name)
                }
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            resolveLocation(location)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationService] Failed: \(error)")
        Task { @MainActor in
            isLocating = false
            // 只有在有 continuation 时才 resume
            if let cont = locationContinuation {
                locationContinuation = nil
                cont.resume(returning: nil)
            }
        }
    }
}
