import SwiftUI
import PhotosUI

struct CanvasView: View {
    // memorize text written by user
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                VStack {
                    Text("Tagify")
                        .font(.custom(
                                "Charter",
                                fixedSize: 40))
                        .multilineTextAlignment(.leading)
                        .bold()
                        .padding(.bottom, 20)
                    
                    // accessibility
                        .accessibilityHint("Header")
                    
                    Text("Upload your images here ")
                        .font(.custom(
                                "Charter",
                                fixedSize: 20))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 15)
                    
                    //accessibility
                        
                        .accessibilityHint("Subheader")
                    
                    PhotoView() //
                    
                 
                    .padding(.top, 5)
                    
                    
                    Spacer()
                  
                }
                .padding(.top, 20)
            }
        }
    }
}





#Preview {
    CanvasView()
}
