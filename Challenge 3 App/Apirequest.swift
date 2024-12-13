//
//  Apirequest.swift
//  Challenge 3 App
//
//  Created by Dylan Esposito on 11/12/24.

//IMAGGA API


import SwiftUI
import PhotosUI

struct ApirequestView: View {
    @State private var allTags: [[String]] = []
    @State private var errorMessage: String?
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var userImages: [UIImage] = []

    var body: some View {
        VStack {
            Text("Image tags")
                .font(.headline)
                .padding()
            
            if let errorMessage = errorMessage {
                Text("Errore: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else if !allTags.isEmpty {
                List(allTags.indices, id: \.self) { index in
                    Section(header: Text("Immagine \(index + 1)")) {
                        ForEach(allTags[index], id: \.self) { tag in
                            Text(tag)
                        }
                    }
                }
            }
            
            PhotosPicker(
                selection: $selectedPhotos,
                matching: .images,
                photoLibrary: .shared()
            ) {
                //Text("Seleziona Immagini")
                  //  .padding()
                    //.background(Color.blue)
                    //.foregroundColor(.white)
                    //.cornerRadius(10)
            }
            .onChange(of: selectedPhotos) { newItems in
                userImages = []
                for item in newItems {
                    item.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let data):
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    userImages.append(image)
                                }
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                errorMessage = "Errore nel caricamento immagine: \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }
            
            Button(action: uploadImages) {
                Text("Upload Test")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    func uploadImages() {
        let apiKey = "acc_88422574634afc4"
        let apiSecret = "5b927e883d12f57bf9c977dbc1225751"
        let credentials = "\(apiKey):\(apiSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else { return }
        let base64Credentials = credentialsData.base64EncodedString()

        let url = URL(string: "https://api.imagga.com/v2/tags")!
        allTags = Array(repeating: [], count: userImages.count) // Reset tags per ogni immagine

        for (index, image) in userImages.enumerated() {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async {
                    errorMessage = "Errore nella conversione dell'immagine"
                }
                continue
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            let body = createMultipartBody(data: imageData, boundary: boundary, filename: "user_image_\(index).jpg", mimeType: "image/jpeg", fieldName: "image")
            request.httpBody = body

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        errorMessage = "Nessun dato ricevuto"
                    }
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let result = json["result"] as? [String: Any],
                       let tagsArray = result["tags"] as? [[String: Any]] {
                        
                        let recognizedTags = tagsArray.compactMap { $0["tag"] as? [String: Any] }
                            .compactMap { $0["en"] as? String }
                        
                        DispatchQueue.main.async {
                            allTags[index] = recognizedTags
                        }
                    } else {
                        DispatchQueue.main.async {
                            errorMessage = "Formato risposta non valido"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        errorMessage = "Errore nel parsing JSON: \(error.localizedDescription)"
                    }
                }
            }.resume()
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
}
#Preview {
    ApirequestView()
}
