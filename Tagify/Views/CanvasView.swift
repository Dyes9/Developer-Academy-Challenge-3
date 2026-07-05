import SwiftUI
import PhotosUI

struct CanvasView: View {
    //
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                VStack {
                    Text("Sono")
                        .font(.custom(
                                "Charter",
                                fixedSize: 40))
                        .multilineTextAlignment(.leading)
                        .bold()
                        .padding(.bottom, 20)
                    
                    // accessibility
                        .accessibilityHint("Header")
                    
                    Text("What does it sound like?")
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
