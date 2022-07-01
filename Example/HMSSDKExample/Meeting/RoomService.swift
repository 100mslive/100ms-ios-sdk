//
//  RoomService.swift
//  HMSSDKExample
//
//  Created by Yogesh Singh on 05/03/21.
//  Copyright © 2021 100ms. All rights reserved.
//

import Foundation

struct RoomService {
    // MARK: - Room Token

    static func fetchToken(for user: String,
                                 _ room: String,
                                 completion: @escaping (String?) -> Void) {

        requestToken(for: user, room) { token, error in

            guard error == nil, let token = token
            else {
                let message = "Fetch Token Error " + (error?.localizedDescription ?? "") +
                    " Description: " + error.debugDescription
                print(#function, "Error: ", message)

                NotificationCenter.default.post(name: Constants.hmsError,
                                                object: nil,
                                                userInfo: ["error": message])
                completion(nil)
                return
            }
            completion(token)
        }
    }

    static func requestToken(for user: String,
                                     _ roomID: String,
                                     completion: @escaping (String?, Error?) -> Void) {

        if let request = createRequest(for: Constants.getTokenURL, user, roomID) {

            URLSession.shared.dataTask(with: request) { data, response, error in

                guard error == nil, response != nil, let data = data else {
                    let message = error?.localizedDescription ??  "Unexpected Error"
                    print(#function, "Error: ", message)
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    
                    return
                }

                let (parsedData, error) = parseResponse(data, for: Constants.tokenKey)

                DispatchQueue.main.async {
                    completion(parsedData, error)
                }
            }.resume()
        }
    }

    // MARK: - Service Helpers

    private static func createRequest(for url: String, _ user: String, _ room: String) -> URLRequest? {

        guard let url = URL(string: url)
        else {
            print("Error: ", #function, "Get Token & Socket Endpoint URLs are incorrect")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        var body = [  "room_id": room,
                      "user_id": user,
                      "role": "host"]

        print(#function, "URL: ", request.url?.absoluteString ?? "bad url", "\nBody: ", body)

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        } catch {
            print("Error: ", #function, "Incorrect body parameters provided")
            print(error.localizedDescription)
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }

    private static func parseResponse(_ data: Data, for key: String) -> (String?, Error?) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data,
                                                           options: .mutableContainers) as? [String: Any] {

                print(#function, "JSON: ", json)

                if let value = json[key] as? String {
                    return (value, nil)
                } else {
                    return (nil, NSError(domain: "RoomService",
                                         code: 0,
                                         userInfo: ["error": "Unexpectedly found nil for key: \(key)"]))
                }
            }
        } catch {
            print(#function, error.localizedDescription, String(data: data, encoding: .utf8) ?? "")
            return(nil, error)
        }

        return (nil, NSError(domain: "RoomService", code: 0, userInfo: ["error": "Unexpected Data Format"]))
    }
}
