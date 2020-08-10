//
//  OAuthManager.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 04/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

// swiftlint:disable identifier_name

import Foundation

protocol OAuthManagerDelegate: class {

    func didReciveToken(_ oauthManager: OAuthManager)

    func didRemoveToken(_ oauthManager: OAuthManager)

    func didOAuthFailWithError(_ error: Error)

}

extension OAuthManagerDelegate {
    func didRemoveToken(_ oauthManager: OAuthManager) { }
}

enum OAuthError: Error {
    case invalidState
}

struct OAuthManager {

    weak var delegate: OAuthManagerDelegate?

    private let reddit_url = "https://www.reddit.com/api/v1"
    private let reddit_authorize_url = "/authorize.compact"
    private let reddit_access_token_url = "/access_token"
    private let reddit_revoke_token_url = "/revoke_token"

    func createNewSessionURL() -> URL? {
        let urlString = "\(reddit_url)\(reddit_authorize_url)"
        let state = UUID().uuidString

        UserDefaults.standard.set(state, forKey: K.UD_URL_STATE)

        let queryParams = [
            URLQueryItem(name: "client_id", value: K.REDDIT_CLIENT_ID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "redirect_uri", value: K.REDIRECT_URI),
            URLQueryItem(name: "duration", value: "permanent"),
            URLQueryItem(name: "scope", value: "read identity")
        ]

        var url = URLComponents(string: urlString)!
        url.queryItems = queryParams

        return url.url
    }

    func handleAuthSession(url: URL?, error: Error?) {
        if error != nil {
            self.delegate?.didOAuthFailWithError(error!)
            return
        }

        if let response = url {
            let responseURL = URLComponents(string: response.absoluteString)
            let stateSent = UserDefaults.standard.string(forKey: K.UD_URL_STATE)!

            let state = responseURL?.queryItems?.first(where: {$0.name == "state"})?.value
            let code = responseURL?.queryItems?.first(where: {$0.name == "code"})?.value

            do {
                try validateState(sent: stateSent, retrieve: state!)
                UserDefaults.standard.removeObject(forKey: K.UD_URL_STATE)

                getToken(authToken: code!)
            } catch {
                self.delegate?.didOAuthFailWithError(error)
            }
        }
    }

    func validateToken() {
        if let code = UserDefaults.standard.string(forKey: K.UD_REFRESH_TOKEN) {
            // swiftlint:disable:next force_cast
            let dateRetrieveToken = UserDefaults.standard.object(forKey: K.UD_TOKEN_DATE) as! Date
            let dateExpToken = Calendar.current.date(byAdding: .minute, value: 50, to: dateRetrieveToken)
            let currentDate = Date.init()

            if dateExpToken! < currentDate {
                refreshToken(code)
            } else {
                self.delegate?.didReciveToken(self)
            }
        }
    }

    func closeSession() {
        if let code = UserDefaults.standard.string(forKey: K.UD_TOKEN) {
            UserDefaults.standard.removeObject(forKey: K.UD_TOKEN)
            UserDefaults.standard.removeObject(forKey: K.UD_REFRESH_TOKEN)
            UserDefaults.standard.removeObject(forKey: K.UD_TOKEN_DATE)
            UserDefaults.standard.removeObject(forKey: K.UD_URL_STATE)

            revokeToken(code)
        }
    }

    private func validateState(sent: String, retrieve: String) throws {
        if sent != retrieve {
            throw OAuthError.invalidState
        }
    }

    private func getToken(authToken code: String) {
        let username = K.REDDIT_CLIENT_ID
        let password = ""
        let loginString = SM.generate_basic_authorization(with: username, and: password)

        let bodyParams = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": K.REDIRECT_URI
        ]

        let urlString = "\(reddit_url)\(reddit_access_token_url)"
        let url = URL(string: urlString)

        var request =  URLRequest(url: url!)

        request.httpMethod = "POST"
        request.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = SM.generate_x_www_form_urlencoded(with: bodyParams)

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                self.delegate?.didOAuthFailWithError(error!)
                return
            }

            if let dataResponse = data {
                do {
                    let decoder = JSONDecoder()

                    let decodedData = try decoder.decode(AccessTokenData.self, from: dataResponse)

                    let accessToken = decodedData.access_token
                    let refreshToken = decodedData.refresh_token

                    UserDefaults.standard.set(accessToken, forKey: K.UD_TOKEN)
                    UserDefaults.standard.set(refreshToken!, forKey: K.UD_REFRESH_TOKEN)
                    UserDefaults.standard.set(Date.init(), forKey: K.UD_TOKEN_DATE)

                    self.delegate?.didReciveToken(self)
                } catch {
                    self.delegate?.didOAuthFailWithError(error)
                }
            }
        }

        task.resume()
    }

    private func refreshToken(_ code: String) {
        let username = K.REDDIT_CLIENT_ID
        let password = ""
        let loginString = SM.generate_basic_authorization(with: username, and: password)

        let bodyParams = [
            "grant_type": "refresh_token",
            "refresh_token": code
        ]

        let urlString = "\(reddit_url)\(reddit_access_token_url)"
        let url = URL(string: urlString)

        var request =  URLRequest(url: url!)

        request.httpMethod = "POST"
        request.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = SM.generate_x_www_form_urlencoded(with: bodyParams)

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if error != nil {
                self.delegate?.didOAuthFailWithError(error!)
                return
            }

            if let dataResponse = data {
                do {
                    let decoder = JSONDecoder()

                    let decodedData = try decoder.decode(AccessTokenData.self, from: dataResponse)

                    let accessToken = decodedData.access_token

                    UserDefaults.standard.set(accessToken, forKey: K.UD_TOKEN)

                    self.delegate?.didReciveToken(self)
                } catch {
                    self.delegate?.didOAuthFailWithError(error)
                }
            }
        }

        task.resume()
    }

    private func revokeToken(_ code: String) {
        let username = K.REDDIT_CLIENT_ID
        let password = ""
        let loginString = SM.generate_basic_authorization(with: username, and: password)

        let bodyParams = [
            "token": code,
            "token_type_hint": "access_token"
        ]

        let urlString = "\(reddit_url)\(reddit_revoke_token_url)"
        let url = URL(string: urlString)

        var request =  URLRequest(url: url!)

        request.httpMethod = "POST"
        request.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = SM.generate_x_www_form_urlencoded(with: bodyParams)

        let task = URLSession.shared.dataTask(with: request) { (_, _, error) in
            if error != nil {
                self.delegate?.didOAuthFailWithError(error!)
                return
            }

            self.delegate?.didRemoveToken(self)
        }

        task.resume()
    }

}
