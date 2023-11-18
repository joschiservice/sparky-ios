//
//  RefreshTokenResponse.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
