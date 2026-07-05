//
//  TagListViiew.swift
//  Tagify
//
//  Created by Dylan Esposito on 29/06/2026.
//
import SwiftUI
struct TagListView: View {
    let imageTags: [(UIImage, [String])]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(0..<imageTags.count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Image(uiImage: imageTags[index].0)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                        
                        Text("Tags:")
                            .font(.headline)
                        
                        Text(imageTags[index].1.map { "#\($0)" }.joined(separator: " "))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .textSelection(.enabled)
                        //selectable text
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground)) // Sfondo più leggibile
    }
}
