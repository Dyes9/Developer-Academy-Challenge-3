//
//  ChatGPTrequest.swift
//  Challenge 3 App
//
//  Created by Dylan Esposito on 13/12/24.
//

import Foundation
import SwiftUI

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let text: String
}

class OpenAIClient {
    let apiKey = "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" //my API KEY

    func generatePrompt(for input: String, completion: @escaping (String?) -> Void) {
        // Configura l'URL e la richiesta
        guard let url = URL(string: "https://api.openai.com/v1/completions") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Configura il payload
        let parameters: [String: Any] = [
            "model": "gpt-4o-mini", // Usa un modello GPT supportato
            "prompt": input,
            "temperature": 0.7,
            "max_tokens": 150
        ]

        // Converte i parametri in JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Errore nella serializzazione JSON: \(error)")
            completion(nil)
            return
        }

        // Effettua la richiesta
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Errore nella richiesta: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("Nessun dato ricevuto.")
                completion(nil)
                return
            }

            // Analizza la risposta JSON
            do {
                let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                let generatedPrompt = result.choices.first?.text.trimmingCharacters(in: .whitespacesAndNewlines)
                completion(generatedPrompt)
            } catch {
                print("Errore nel parsing della risposta: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}


