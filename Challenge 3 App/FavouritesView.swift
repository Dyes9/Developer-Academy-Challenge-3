//
//  TagView.swift
//  Challenge 3 App
//
//  Created by Dylan Esposito on 10/12/24.
//

import SwiftUI

struct FavouritesView: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1).ignoresSafeArea()
            VStack {
                Text("Favourites")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                Text("placeholder")
                    .font(.headline)
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    FavouritesView()
}
