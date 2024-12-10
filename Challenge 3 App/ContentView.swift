import SwiftUI

// CardView con una griglia di placeholder per le foto
struct CardView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())] // Definisce 3 colonne flessibili
    
    var body: some View {
        VStack {
            Text("Day Out Photos")
                .font(.headline)
                .padding(.top, 17)
            
            // Griglia per mostrare placeholder per le foto
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(1...9, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.5)) // Placeholder di colore grigio
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("+") // Segnaposto per aggiungere foto
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
            }
            .padding()
            
            Spacer()
        }
        .frame(width: 350, height: 400) // Dimensioni della CardView
        .background(.gray.opacity(0.5)) // Sfondo grigio trasparente
        .cornerRadius(15) // Angoli arrotondati
        .padding(8)
    }
}

// ContentView con TabView e una singola Card con griglia
struct ContentView: View {
    var body: some View {
        TabView {
            // Prima scheda - CanvasView
            CanvasView()
                .tabItem {
                    Image(systemName: "note")
                    Text("Notes")
                }
            
            // Seconda scheda - HomeView
            HomeView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Tags")
                }
            
            // Terza scheda - SettingsView
            SettingsView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Settings")
                }
        }
        .accentColor(.orange) // Cambia il colore attivo delle schede
        .toolbarBackground(.red, for: .tabBar) // Cambia lo sfondo della barra
    }
}

// CanvasView: Schermata principale con una singola Card, casella di testo e tasto
struct CanvasView: View {
    @State private var userText: String = "" // Stato per memorizzare il testo inserito dall'utente
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.1).ignoresSafeArea() // Sfondo della schermata
                VStack {
                    Text("All canvases")
                        .font(.system(size: 40))
                        .bold()
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    
                    Text("Day out with friends")
                        .font(.headline)
                        .padding(.bottom, 20)
                        .offset(x: -100)
                    
                    CardView() // Mostra la Card con la griglia
                    
                    // Casella di testo per inserire una descrizione
                    TextField("Enter description of your day...", text: $userText)
                        .textFieldStyle(RoundedBorderTextFieldStyle()) // Stile della casella di testo
                        .padding()
                        .frame(width: 350)
                    
                    // Tasto per inviare o salvare la descrizione
                    Button(action: {
                        print("User entered: \(userText)") // Azione al clic del tasto
                    }) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 150, height: 50)
                            .background(Color.blue) // Colore del tasto
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
    }
}

// HomeView: Una seconda schermata (Tasks)
struct HomeView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2).ignoresSafeArea()
            VStack {
                Text("Your Tasks")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                Text("Here you can see all your tasks.")
                    .font(.headline)
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}

// SettingsView: Una terza schermata (Impostazioni)
struct SettingsView: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.1).ignoresSafeArea()
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                
                Text("Adjust your preferences here.")
                    .font(.headline)
                    .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}

// Preview
#Preview {
    ContentView()
}
