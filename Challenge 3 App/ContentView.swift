import SwiftUI
import PhotosUI

struct ContentView: View {
    var body: some View {
        TabView {

            CanvasView()
                .tabItem {
                    Image(systemName: "bubbles.and.sparkles.fill")
                    Text("Create")
                }

        
    
            FavouritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Saved")
                }
        }
        .accentColor(.orange)
    }
}

//main screen

struct CanvasView: View {
    // memorize text written by user
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea()
                VStack {
                    Text("Create")
                        .font(.custom(
                                "Charter",
                                fixedSize: 30))
                        .multilineTextAlignment(.leading)
                     
                        .bold()
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    
                    // accessibility
                        .accessibilityHint("Header")
                    
                    Text("Upload your images here and let the magic happen")
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
    ContentView()
}
