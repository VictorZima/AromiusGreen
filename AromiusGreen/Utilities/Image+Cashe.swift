//
//  Image+Cashe.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

extension Image {
    static func load(url: URL) async -> Image? {
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        
        if let data = cache.cachedResponse(for: request)?.data, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let uiImage = UIImage(data: data) {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                cache.storeCachedResponse(cachedResponse, for: request)
                return Image(uiImage: uiImage)
            }
        } catch {
            print("Error loading image: \(error)")
        }
        
        return nil
    }
}
