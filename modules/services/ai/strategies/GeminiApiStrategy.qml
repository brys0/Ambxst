import QtQuick
import "../AiModel.qml"

ApiStrategy {
    function getEndpoint(modelObj, apiKey) {
        return modelObj.endpoint + modelObj.model + ":generateContent?key=" + apiKey;
    }

    function getHeaders(apiKey) {
        return ["Content-Type: application/json"];
    }

    function getBody(messages, model, tools) {
        // Convert messages to Gemini format
        // Gemini expects { role: "user"|"model", parts: [{ text: "..." }] }
        // For function calls: { role: "model", parts: [{ functionCall: { ... } }] }
        // For function responses: { role: "function", parts: [{ functionResponse: { ... } }] }
        let contents = messages.map(msg => {
            if (msg.role === "assistant") {
                if (msg.functionCall) {
                    return {
                        role: "model",
                        parts: [{ functionCall: msg.functionCall }]
                    };
                }
                return {
                    role: "model",
                    parts: [{ text: msg.content }]
                };
            } else if (msg.role === "function") {
                return {
                    role: "function",
                    parts: [{
                        functionResponse: {
                            name: msg.name,
                            response: {
                                name: msg.name,
                                content: msg.content
                            }
                        }
                    }]
                };
            } else {
                return {
                    role: "user",
                    parts: [{ text: msg.content }]
                };
            }
        });
        
        let body = {
            contents: contents,
            generationConfig: {
                temperature: 0.7,
                maxOutputTokens: 2048
            }
        };

        if (tools && tools.length > 0) {
            body.tools = [{ function_declarations: tools }];
        }

        return body;
    }
    
    function parseResponse(response) {
        try {
            if (!response || response.trim() === "") return { content: "Error: Empty response from API" };
            
            let json = JSON.parse(response);
            
            if (json.error) {
                return { content: "API Error (" + json.error.code + "): " + json.error.message };
            }
            
            if (json.candidates && json.candidates.length > 0) {
                let content = json.candidates[0].content;
                if (content && content.parts && content.parts.length > 0) {
                    let part = content.parts[0];
                    if (part.functionCall) {
                        return {
                            functionCall: part.functionCall,
                            content: null // No text content for function calls typically
                        };
                    }
                    return { content: part.text };
                }
                // Handle case where content is present but parts are missing or blocked
                if (json.candidates[0].finishReason) {
                    return { content: "Response finished with reason: " + json.candidates[0].finishReason };
                }
            }
            
            return { content: "Error: Unexpected response format. Raw: " + response };
        } catch (e) {
            return { content: "Error parsing response: " + e.message + ". Raw: " + response };
        }
    }
}
