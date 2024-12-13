//
//  Homeview.swift
//  Challenge 3 App
//
//  Created by Dylan Esposito on 10/12/24.
//

import SwiftUI

struct StoryView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            VStack {
                Text("Your stories")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                Text("Here you can see all your stories .")
                    .font(.headline)
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}

#Preview {
    StoryView()
}
