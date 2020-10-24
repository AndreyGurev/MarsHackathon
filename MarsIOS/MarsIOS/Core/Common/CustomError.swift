//
//  CustomError.swift
//  MarsIOS
//
//  Created by Andrey Gurev on 24.10.2020.
//

import UIKit

final class CustomError {
    static let imageLoadFail = CustomError(text: "Ошибка загрузки картинки")
    static let unknown = CustomError(text: "Произошла неизвестная ошибка")
    static let parsingFail = CustomError(text: "Неизвестный формат данных c сервера")
    static let networkFail = CustomError(title: "Слабое интернет соединение или вовсе отсутствует", text: "Попробуйте наладить соединение и повторите запрос")
    
    static let tokenDie = CustomError(text: "Время жизни токена авторизации истекло, повторите вход")
    static let serverError = CustomError(text: "Сервер временно недоступен, повторите попытку позже")

    private let title: String?
    private let text: String
    private var code: Int?
    
    init(title: String? = nil, text: String, code: Int? = nil) {
        self.title = title
        self.text = text
        self.code = code
    }
    
    static func mapError(value: Any?) -> CustomError? {
        if let data = value as? [String: Any] {
            if let message = data["message"] as? String {
                return CustomError(text: message)
            }
        }
        
        return nil
    }
}
