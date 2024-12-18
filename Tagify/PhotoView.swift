import SwiftUI
import PhotosUI

struct PhotoView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    @State private var selectedImages: [UIImage?] = Array(repeating: nil, count: 9)
    @State private var photoPickerSelections: [PhotosPickerItem?] = Array(repeating: nil, count: 9)
    @State private var imageTags: [(UIImage, [String])] = []
    @State private var isShowingModal: Bool = false
    @State private var isLoading: Bool = false // Stato per il caricamento

    var body: some View {
        VStack {
            // Grid
            VStack {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<9, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.5))
                                .frame(width: 80, height: 80)

                            if let image = selectedImages[index] {
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
                                PhotosPicker(selection: $photoPickerSelections[index], matching: .images, photoLibrary: .shared()) {
                                    Text("+")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .accessibilityHint("Select an image")
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
                                                print("Errore during loading: \(error.localizedDescription)")
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
            .frame(width: 350, height: 400)
            .background(.gray.opacity(0.5))
            .cornerRadius(15)
            .padding(8)
            
            // Generate button
            Button(action: uploadImages) {
                if isLoading {
                    ProgressView()
                        .frame(width: 150, height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                } else {
                    Text("Generate")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 150, height: 50)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .accessibilityHint("Generate tags for selected images")
                }
            }
            .padding(.top, 20)
        }
        .sheet(isPresented: $isShowingModal) {
            TagListView(imageTags: imageTags)
        }
    }

    func removeImage(at index: Int) {
        selectedImages[index] = nil
        photoPickerSelections[index] = nil
    }

    func uploadImages() {
        let apiKey = "acc_16a0bbcebb07d6f"
        let apiSecret = "3a7f720a0a7667c0282557eccb7b0d94"
        let credentials = "\(apiKey):\(apiSecret)"
        guard let credentialsData = credentials.data(using: .utf8) else { return }
        let base64Credentials = credentialsData.base64EncodedString()

        let url = URL(string: "https://api.imagga.com/v2/tags")!
        var newImageTags: [(UIImage, [String])] = []
        let dispatchGroup = DispatchGroup()

        isLoading = true
        for (index, image) in selectedImages.enumerated() {
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
}

// View per mostrare la lista di immagini e tag
struct TagListView: View {
    let imageTags: [(UIImage, [String])]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<imageTags.count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Image(uiImage: imageTags[index].0)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                        
                        Text("Tags:")
                            .font(.headline)
                        
                        Text(imageTags[index].1.map { "#\($0)" }.joined(separator: " "))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .textSelection(.enabled)
                        //selectable text
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground)) // Sfondo più leggibile
    }
}
#Preview {
    PhotoView()
}
