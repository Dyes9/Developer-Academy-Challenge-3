import SwiftUI
import PhotosUI
// cronology




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
                                            //removeImage(at: index)
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
            Button(action: {}) {
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

   




}

// View per mostrare la lista di immagini e tag

#Preview {
    PhotoView()
}
