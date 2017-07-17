//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Tara Wilson on 7/17/17.
//  Copyright © 2017 twil. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {

    var selectedImage: UIImage?
    
    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        let sharetext = contentText

        if let inputItem = extensionContext!.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first as? NSItemProvider {
                // This line was missing
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    itemProvider.loadItem(forTypeIdentifier: kUTTypeImage as String) { [unowned self] (imageData, error) in
                        print(error)
                        self.shareToFacebook(text: sharetext, image: imageData as? UIImage)
                        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    func shareToFacebook(text: String?, image: UIImage?) {
        guard let text = text, let image = image else { return }
        
        
        if let userDefaults = UserDefaults(suiteName: "group.musiquelive.datashare") {
            userDefaults.set(text, forKey: "shareText")
            
            let relativePath = "image_\(NSDate.timeIntervalSinceReferenceDate).jpg"
            let imagePath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(relativePath)!
            if let jpegData = UIImageJPEGRepresentation(image, 1) {
                try! jpegData.write(to: imagePath)
                userDefaults.set(relativePath, forKey: "path")
            }
            
            userDefaults.synchronize()
        }
        
    }


    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
