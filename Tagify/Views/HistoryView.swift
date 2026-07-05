//
//  TagView.swift
//  Challenge 3 App
//
//  Created by Dylan Esposito on 10/12/24.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            VStack {
                Text("History")
                    .font(.custom(
                            "Charter",
                            fixedSize: 40))
                    .multilineTextAlignment(.leading)
                    .bold()
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                
                
                Text("Recently generated tags")
                    .font(.custom(
                            "Charter",
                            fixedSize: 20))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 15)
                
                Spacer()
            }
        }
    }
}

#Preview {
    HistoryView()
}
