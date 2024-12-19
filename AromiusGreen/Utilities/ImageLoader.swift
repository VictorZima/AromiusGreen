//
//  ImageLoader.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

//actor ImageLoader {
//    private static let cache = NSCache<NSURL, UIImage>()
//    private static let urlCache = URLCache.shared
//    
//    /// Загружает изображение асинхронно по URL
//    static func loadImage(from url: URL) async -> Image? {
//        // Попытка извлечь из локального кэша
//        if let cachedImage = cache.object(forKey: url as NSURL) {
//            return Image(uiImage: cachedImage)
//        }
//
//        // Создание запроса
//        let request = URLRequest(url: url)
//        
//        // Проверка в URLCache
//        if let data = urlCache.cachedResponse(for: request)?.data,
//           let uiImage = UIImage(data: data) {
//            cache.setObject(uiImage, forKey: url as NSURL) // Сохранение в локальный кэш
//            return Image(uiImage: uiImage)
//        }
//        
//        do {
//            // Запрос данных через URLSession
//            let (data, response) = try await URLSession.shared.data(for: request)
//            
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                print("Ошибка: недействительный HTTP-ответ для URL \(url)")
//                return nil
//            }
//            
//            if let uiImage = UIImage(data: data) {
//                // Сохранение в кэши
//                let cachedResponse = CachedURLResponse(response: response, data: data)
//                urlCache.storeCachedResponse(cachedResponse, for: request)
//                cache.setObject(uiImage, forKey: url as NSURL)
//                return Image(uiImage: uiImage)
//            } else {
//                print("Ошибка: не удалось создать UIImage из данных для URL \(url)")
//            }
//        } catch {
//            print("Ошибка загрузки изображения: \(error.localizedDescription)")
//        }
//        
//        return nil
//    }
//}
class ImageLoader {
    static func loadImage(from url: URL) async -> Image? {
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

