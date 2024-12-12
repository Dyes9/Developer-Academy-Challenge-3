//
//  Apirequest.swift
//  Challenge 3 App
//
//  Created by Dylan Esposito on 11/12/24.
//
import SwiftUI

struct ApirequestView: View {
    @State private var allTags: [[String]] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Text("Tag riconosciuti:")
                .font(.headline)
                .padding()
            
            if let errorMessage = errorMessage {
                Text("Errore: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                
                    List(allTags.indices, id: \.self) { index in
                        Section(header: Text("Immagine \(index + 1)")) {
                            ForEach(allTags[index], id: \.self) { tag in
                                Text(tag)
                            }
                        }
                    }
                }
            
            
            Button(action: uploadImages) {
                Text("Carica immagini")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
    
    func uploadImages() {
        let apiKey = "acc_88422574634afc4"
        let apiSecret = "5b927e883d12f57bf9c977dbc1225751"
        let credentials = "\(apiKey):\(apiSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else { return }
        let base64Credentials = credentialsData.base64EncodedString()

        // Immagini da caricare
        let images = ["image1.jpg", "image2.jpg", "image3.jpg"] // Nomi immagini locali
        allTags = Array(repeating: [], count: images.count) // Reset tags per ogni immagine

        let url = URL(string: "https://api.imagga.com/v2/tags")!

        for (index, imageName) in images.enumerated() {
            guard let image = UIImage(named: imageName),
                  let imageData = image.jpegData(compressionQuality: 0.8) else {
                DispatchQueue.main.async {
                    errorMessage = "Errore nel caricare l'immagine: \(imageName)"
                }
                continue
            }

            // Configura richiesta per ogni immagine
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            let body = createMultipartBody(data: imageData, boundary: boundary, filename: imageName, mimeType: "image/jpeg", fieldName: "image")
            request.httpBody = body

            // Esegui richiesta
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

                // Analizza la risposta JSON
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
                            errorMessage = "Formato risposta non valido per \(imageName)"
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
