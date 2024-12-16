import SwiftUI
import PhotosUI
import Foundation

struct PhotoView: View {
    
    //Key management
    struct Secrets {
        static func value(for key: String) -> String? {
            guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
                  let dictionary = NSDictionary(contentsOfFile: path) else { return nil }
            return dictionary[key] as? String
        }
    }
    
    //Grid
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    // Array for storing images
    @State private var selectedImages: [UIImage?] = Array(repeating: nil, count: 9)
    //Photo selection from gallery
    @State private var photoPickerSelections: [PhotosPickerItem?] = Array(repeating: nil, count: 9)
    //Error message
    @State private var errorMessage: String?
    
    @State private var generatedPrompt: String? // Storia generata da ChatGPT
    @State private var isShowingModal: Bool = false // Stato per mostrare o nascondere la modale
    
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
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            } else {
                                // Pulsante "+" per selezionare una foto
                                PhotosPicker(selection: $photoPickerSelections[index], matching: .images, photoLibrary: .shared()) {
                                    Text("+")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .accessibilityHint("oiiaioiiiai")
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
                                                print("Error during loading phase: \(error.localizedDescription)")
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
            
            // Pulsante per generare i tag e il prompt, posizionato sotto la CardView
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
        .sheet(isPresented: $isShowingModal) {
            if let prompt = generatedPrompt {
                PromptModalView(prompt: prompt)
            } else {
                Text("No prompt was generated.")
            }
        }
    }
    
    func removeImage(at index: Int) {
        selectedImages[index] = nil
    }

    func uploadImages() {
        
        // Key management  ------------------------------------------
        
        
        let imaggaAPIKey = Secrets.value(for: "ImaggaAPI")
        let imaggaAPISecret = Secrets.value(for: "ImaggaAPISecret")
        
        // -----------------------------------------------------------
        
        print("Images upload started...")
        
        let apiKey = imaggaAPIKey
        let apiSecret = imaggaAPISecret
        let credentials = "\(String(describing: apiKey)):\(String(describing: apiSecret))"
        guard let credentialsData = credentials.data(using: .utf8) else { return }
        let base64Credentials = credentialsData.base64EncodedString()

        let url = URL(string: "https://api.imagga.com/v2/tags")!
        var allTags: [[String]] = [] // Per salvare i tag di tutte le immagini
        let dispatchGroup = DispatchGroup()
        
        for (index, image) in selectedImages.enumerated() {
            guard let image = image, let imageData = image.jpegData(compressionQuality: 0.8) else {
                continue
            }

            dispatchGroup.enter() // New operation begins
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

            let body = createMultipartBody(data: imageData, boundary: boundary, filename: "user_image_\(index).jpg", mimeType: "image/jpeg", fieldName: "image")
            request.httpBody = body

            URLSession.shared.dataTask(with: request) { data, response, error in
                defer { dispatchGroup.leave() } // Operation end
                if let error = error {
                    print("Error during Imagga API request: \(error.localizedDescription)")
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
                        
                        print("Image tags \(index + 1): \(recognizedTags)") // tags printed in console for debugging purposes
                        allTags.append(recognizedTags)
                    }
                } catch {
                    print("Error in parsing JSON: \(error.localizedDescription)")
                }
            }.resume()
        }

        // After collecting all the tags, prompt should be sent
        dispatchGroup.notify(queue: .main) {
            print("all tags successfully fetched: \(allTags)")
            generatePrompt(with: allTags)
        }
    }
    
    func generatePrompt(with tags: [[String]]) {
        
  //Key management-------------------------------------------------
        let ChatgptAPIKey = Secrets.value(for: "ChatgptAPI")
        
  //---------------------------------------------------------------

        
        print("ChatGPT request begin...")
        let openAIKey = ChatgptAPIKey // API KEY
        let url = URL(string: "https://api.openai.com/v1/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(String(describing: openAIKey))", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let tagsString = tags.map { $0.joined(separator: ", ") }.joined(separator: "; ")
        let prompt = "Create a short story, max 500 characters, inspired by the following tags: \(tagsString)."
        print("Prompt inviato: \(prompt)")
        
        let body: [String: Any] = [
            "model": "text-davinci-003",
            "prompt": prompt,
            "max_tokens": 150
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("ChatGPT API error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Error: no data received from ChatGPT API")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let text = choices.first?["text"] as? String {
                    DispatchQueue.main.async {
                        self.generatedPrompt = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        print("Your Story: \(self.generatedPrompt ?? "No story was generated")")
                        self.isShowingModal = true // Show modal view
                    }
                }
            } catch {
                print("Errore nel parsing JSON: \(error.localizedDescription)")
            }
        }.resume()
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

// Modal View appear after pushing button
struct PromptModalView: View {
    let prompt: String
    
    var body: some View {
        VStack {
            Text("Generated Story")
                .font(.headline)
                .padding(.top)
            
            Text(prompt)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()
            
            Button("Dismiss") {
                dismiss()
            }
            .foregroundColor(.white)
            .frame(width: 150, height: 50)
            .background(Color.blue)
            .cornerRadius(10)
            .padding()
        }
    }
    
    @Environment(\.dismiss) private var dismiss
}
#Preview {
    PhotoView()
}
