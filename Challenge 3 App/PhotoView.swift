import SwiftUI
import PhotosUI

struct PhotoView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // 3 colonne flessibili
    @State private var selectedImages: [UIImage?] = Array(repeating: nil, count: 9) // Array per memorizzare le immagini selezionate
    @State private var photoPickerSelections: [PhotosPickerItem?] = Array(repeating: nil, count: 9) // Foto selezionate dalla galleria
    @State private var errorMessage: String? // Messaggio di errore

    var body: some View {
        VStack {
            // CardView con la griglia di selezione foto
            VStack {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<9, id: \.self) { index in
                        ZStack {
                            // Sfondo del rettangolo
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 80, height: 80)
                            
                            if let image = selectedImages[index] {
                                // Mostra l'immagine selezionata
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            removeImage(at: index)
                                        } label: {
                                            Label("Elimina immagine", systemImage: "trash")
                                        }
                                    }
                            } else {
                                // Pulsante "+" per selezionare una foto
                                PhotosPicker(selection: $photoPickerSelections[index], matching: .images, photoLibrary: .shared()) {
                                    Text("+")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .onChange(of: photoPickerSelections[index]) { newValue in
                                    guard let newValue = newValue else { return }
                                    newValue.loadTransferable(type: Data.self) { result in
                                        DispatchQueue.main.async {
                                            switch result {
                                            case .success(let data):
                                                if let data = data, let image = UIImage(data: data) {
                                                    selectedImages[index] = image
                                                }
                                            case .failure(let error):
                                                print("Errore durante il caricamento: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .frame(width: 350, height: 400) // Dimensioni della CardView
            .background(.gray.opacity(0.5)) // Sfondo grigio trasparente
            .cornerRadius(15) // Angoli arrotondati
            .padding(8)
            
            // Pulsante per generare i tag, posizionato sotto la CardView
            Button(action: uploadImages) {
                Text("Generate")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 150, height: 50)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
            .padding(.top, 20) // Spazio tra CardView e il pulsante
        }
    }

    func removeImage(at index: Int) {
        selectedImages[index] = nil
    }

    func uploadImages() {
        let apiKey = "acc_88422574634afc4"
        let apiSecret = "5b927e883d12f57bf9c977dbc1225751"
        let credentials = "\(apiKey):\(apiSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else { return }
        let base64Credentials = credentialsData.base64EncodedString()

        let url = URL(string: "https://api.imagga.com/v2/tags")!

        for (index, image) in selectedImages.enumerated() {
            guard let image = image, let imageData = image.jpegData(compressionQuality: 0.8) else {
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
                        
                        print("Tags per immagine \(index + 1): \(recognizedTags)")
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
    PhotoView()
}
