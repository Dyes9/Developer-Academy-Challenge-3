//
//  Worker.swift
//  Tagify
//
//  Created by Dylan Esposito on 28/06/2026.
//

import SwiftUI
import PhotosUI
import UIKit



// funzione per la rimozione degli indici dagli array, che rimuove di fatto le immagini dalla griglia
// Probabile che cambierà l'interfaccia, quindi questa funzione potrebbe essere modificata.

/*
func removeImage(at index: Int,  images:  inout [UIImage?], photoPickerItem: inout [PhotosPickerItem?]  ) -> Void

{
    images[index] = nil
    photoPickerItem[index] = nil
}
*/


// chiamata API con endpoint "V2" di Imagga

func uploadImages(_images images: [UIImage?]) {
    let apiKey = "YOURAPIKEYHERE"
    let apiSecret = "YOURAPISECRETHERE"
    let credentials = "\(apiKey):\(apiSecret)"
    guard let credentialsData = credentials.data(using: .utf8) else { return }
    let base64Credentials = credentialsData.base64EncodedString()

    let url = URL(string: "https://api.imagga.com/v2/tags")!
    var newImageTags: [(UIImage, [String])] = []
    let dispatchGroup = DispatchGroup()

    //isLoading = true
    for (index, image) in images.enumerated() {
        guard let image = image, let imageData = image.jpegData(compressionQuality: 0.8) else {
            continue
        }

        dispatchGroup.enter()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let body = createMultipartBody(data: imageData, boundary: boundary, filename: "user_image_\(index).jpg", mimeType: "image/jpeg", fieldName: "image")
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { dispatchGroup.leave() }
            if let error = error {
                print("Error during API request: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Error: no data received.")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let result = json["result"] as? [String: Any],
                   let tagsArray = result["tags"] as? [[String: Any]] {
                    
                    let recognizedTags = tagsArray.compactMap { $0["tag"] as? [String: Any] }
                        .compactMap { $0["en"] as? String }
                    
                    print("Tags for picture \(index + 1): \(recognizedTags)")
                    DispatchQueue.main.async {
                        newImageTags.append((image, recognizedTags))
                    }
                }
            } catch {
                print("Error in parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

    dispatchGroup.notify(queue: .main) {
        self.imageTags = newImageTags
        self.isShowingModal = true
        self.isLoading = false
    }
}

func createMultipartBody(data: Data, boundary: String, filename: String, mimeType: String, fieldName: String) -> Data {
    var body = Data()
    
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
    body.append(data)
    body.append("\r\n".data(using: .utf8)!)
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    
    return body
}

class HistoryManager: ObservableObject {
    @Published var imageHistory: [(UIImage, [String])] = []
    
    func addToHistory(image: UIImage, tags: [String]) {
        imageHistory.append((image, tags))
    }
}
