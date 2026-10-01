import Foundation

/// Minimal client for the Gemini "generateContent" REST endpoint.
/// Docs: https://ai.google.dev/api/generate-content
enum GeminiError: LocalizedError {
    case missingAPIKey
    case badResponse(String)
    case http(Int, String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey: "Add a Gemini API key in Settings first."
        case .badResponse(let s): "Couldn't understand Gemini's response: \(s)"
        case .http(let code, let s): "Gemini request failed (\(code)): \(s)"
        }
    }
}

struct GeminiClient {
    var apiKey: String
    var model: String = "gemini-3.8-flash"

    /// Sends `prompt` and asks Gemini to return JSON matching `schema`
    /// (an OpenAPI-subset schema dictionary, per Gemini's structured output support).
    /// Returns the raw JSON text of the response.
    func generateJSON(prompt: String, schema: [String: Any]) async throws -> String {
        guard !apiKey.isEmpty else { throw GeminiError.missingAPIKey }

        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent") else {
            throw GeminiError.badResponse("bad URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key")

        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]],
            "generationConfig": [
                "responseMimeType": "application/json",
                "responseSchema": schema
            ]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw GeminiError.badResponse("no HTTP response")
        }
        guard 200..<300 ~= http.statusCode else {
            let message = String(data: data, encoding: .utf8) ?? "unknown error"
            throw GeminiError.http(http.statusCode, message)
        }

        guard
            let top = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let candidates = top["candidates"] as? [[String: Any]],
            let content = candidates.first?["content"] as? [String: Any],
            let parts = content["parts"] as? [[String: Any]],
            let text = parts.first?["text"] as? String
        else {
            throw GeminiError.badResponse(String(data: data.prefix(300), encoding: .utf8) ?? "")
        }
        return text
    }
}
