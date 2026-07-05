import SwiftUI
import PhotosUI
// cronology




struct PhotoView: View {

    @State private var imageTags: [(UIImage, [String])] = []
    @State private var isShowingModal: Bool = false
    @State private var isLoading: Bool = false // Stato per il caricamento

    var body: some View {
        VStack {
            // Grid
            VStack {
              // Quì dovrà comparire la foto caticata dall'utente
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
