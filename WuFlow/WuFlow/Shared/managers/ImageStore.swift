//
//  ImageStore.swift
//  WuFlow
//
//  Created by Roberto Ramirez on 5/4/26.
//


import UIKit


final class ImageStore {
    
    private let cache = NSCache<NSString, UIImage>()
    static let shared = ImageStore()
    private init() {}
    
    // MARK: - Public API
    
    /// Saves an image, returns relative path string you can store in SwiftData
    func save(_ image: UIImage,
              category: ImageCategory,
              maxDimension: CGFloat = 1024,
              compression: CGFloat = 0.6) throws -> String {
        
        let resized = resize(image, maxDimension: maxDimension)
        guard let data = resized.jpegData(compressionQuality: compression) else {
            throw ImageError.encodingFailed
        }
        
        let url = try makeURL(category: category)
        try data.write(to: url, options: [.atomic])
        
        return url.lastPathComponent// store this in your model
    }
    
    /// Loads image safely (never crashes)
    func load(
        from fileName: String?,
        category: ImageCategory? = .activity
    ) -> UIImage? {
        guard let fileName else { return nil }
        
        // 1. Check cache first
        if let cached = cache.object(forKey: fileName as NSString) {
            return cached
        }
        
        // 2. Load from disk
        guard let url = try? url(
            for: fileName,
            category: category ?? .activity
        ) else {
            return nil
        }

        guard let image = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        
        // 3. Store in cache
        cache.setObject(image, forKey: fileName as NSString)
        
        return image
    }
    
    /// Deletes image file if exists
    func delete(at path: String?) {
        guard let path else { return }
        try? FileManager.default.removeItem(atPath: path)
    }
    
    /// Cleanup: remove files not referenced by your DB (call occasionally)
    func cleanup(unusedPaths: Set<String>, category: ImageCategory) {
        guard let dir = try? directoryURL(category: category) else { return }
        let files = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        
        for file in files where !unusedPaths.contains(file.lastPathComponent) {
            try? FileManager.default.removeItem(at: file)
        }
    }
}

// MARK: - Internals

private extension ImageStore {
    
    enum ImageError: Error { case encodingFailed }
    
    func makeURL(category: ImageCategory) throws -> URL {
        let dir = try directoryURL(category: category)
        let filename = UUID().uuidString + ".jpg"
        return dir.appendingPathComponent(filename)
    }
    
    func directoryURL(category: ImageCategory) throws -> URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("WuFlowImages/\(category.rawValue)", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: dir.path) {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
    
    /// Resize keeping aspect ratio
    func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let maxCurrent = max(size.width, size.height)
        guard maxCurrent > maxDimension else { return image }
        
        let scale = maxDimension / maxCurrent
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    func url(
        for fileName: String,
        category: ImageCategory
    ) throws -> URL {
        
        let dir = try directoryURL(category: category)
        
        return dir.appendingPathComponent(fileName)
    }
}

enum ImageCategory: String {
    case activity
    case user
    case progress
}
