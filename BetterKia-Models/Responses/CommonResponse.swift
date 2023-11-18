//
//  CommonResponse.swift
//  BetterKia-iOS
//
//  Created by Joschua Haß on 15.11.23.
//

public struct CommonResponse<T> {
    let failed: Bool
    let error: ApiErrorType
    let data: T?
}
