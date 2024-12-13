import SwiftUI
import PhotosUI

struct ContentView: View {
    var body: some View {
        TabView {

            CanvasView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }

            ApirequestView()
                .tabItem {
                    Image(systemName: "star.square.on.square.fill")
                    Text("Stories")
                }
            
    
            FavouritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favourites")
                }
        }
        .accentColor(.orange)
        .toolbarBackground(.red, for: .tabBar)
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
                    Text("Home")
                        .font(.custom(
                                "Charter",
                                fixedSize: 30))
                     
                        .bold()
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    
                    Text("Upload your images here and let the magic happen")
                        .font(.custom(
                                "Charter",
                                fixedSize: 20))
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 15)
                    
                    PhotoView() //
                    
                 
                    .padding(.top, 5)
                    
                    
                    Spacer()
                  
                }
                .padding(.top, 20)
            }
        }
    }
}




// Preview
#Preview {
    ContentView()
}
