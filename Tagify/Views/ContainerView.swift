//
//  ContainerView.swift
//  Challenge 3 App
//
//  Created by Dylan Esposito on 17/12/24.
//

import SwiftUI

struct ContainerView: View {
    var body: some View {
        TabView {

            CanvasView()
                .tabItem {
                    Image(systemName: "number.square.fill")
                    Text("Tagify")
                    
                }

        
    
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                    Text("History")
                }
        }
        .accentColor(.orange)
    }
}
#Preview {
    ContainerView()
}
