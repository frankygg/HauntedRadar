import Foundation
import UIKit
import Photos

public struct Assets {
    
    /// Requests access to the user's contacts
    ///
    /// - Parameter requestGranted: Result as Bool
    public static func requestAccess(_ requestGranted: @escaping (PHAuthorizationStatus) -> ()) {
        PHPhotoLibrary.requestAuthorization { status in
            requestGranted(status)
        }
    }
    
    /// Result Enum
    ///
    /// - Success: Returns Array of PHAsset
    /// - Error: Returns error
    public enum FetchResults {
        case success(response: [PHAsset])
        case error(error: Error)
    }
    
    public static func fetch(_ completion: @escaping (FetchResults) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            let error: NSError = NSError(domain: "PhotoLibrary Error", code: 1, userInfo: [NSLocalizedDescriptionKey: "No PhotoLibrary Access"])
            completion(FetchResults.error(error: error))
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchResult = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
            
            if fetchResult.count > 0 {
                var assets = [PHAsset]()
                fetchResult.enumerateObjects { object, _, _ in
                    assets.insert(object, at: 0)
                }
                
                DispatchQueue.main.async {
                    completion(FetchResults.success(response: assets))
                }
            }
        }
    }
    
    public static func resolve(asset: PHAsset, size: CGSize = PHImageManagerMaximumSize, completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        requestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
            if let info = info, info["PHImageFileUTIKey"] == nil {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }

}
