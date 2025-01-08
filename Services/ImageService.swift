import UIKit
import FirebaseStorage

enum ImageError: LocalizedError {
    case compressionFailed
    case uploadFailed
    case downloadFailed
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Failed to compress image"
        case .uploadFailed:
            return "Failed to upload image"
        case .downloadFailed:
            return "Failed to download image"
        }
    }
}

actor ImageService {
    static let shared = ImageService()
    private let cache = NSCache<NSString, UIImage>()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    func uploadProfileImage(_ image: UIImage, userId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw ImageError.compressionFailed
        }
        
        let path = "profile_images/\(userId).jpg"
        let imageRef = storage.child(path)
        
        _ = try await imageRef.putDataAsync(imageData)
        let url = try await imageRef.downloadURL()
        return url.absoluteString
    }
    
    func getCachedImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func cacheImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
} 
