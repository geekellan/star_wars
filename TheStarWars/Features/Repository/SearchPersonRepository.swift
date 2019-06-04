//
//  SearchPersonRepository.swift
//  TheStarWars
//
//  Created by Ellan Esenaliev on 6/4/19.
//  Copyright © 2019 Ellan Esenaliev. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper

class SearchPersonRepository {
    
    func loadCharacters(text: String) -> Observable<BaseModel> {
        return Observable.create({ (observer) -> Disposable in
            ApiClient.shared.search(person: text) { (response, error) in
                if let json = response as? [String: Any], let baseModel = Mapper<BaseModel>().map(JSON: json) {
                    observer.onNext(baseModel)
                    observer.onCompleted()
                } else {
                    observer.onError(error ?? NetworkError.BACKEND_ERROR)
                }
            }
            return Disposables.create()
        })
    }
    
    func loadCharacters(nextPage: String) -> Observable<BaseModel> {
        return Observable.create({ (observer) -> Disposable in
            ApiClient.shared.open(url: nextPage) { (response, error) in
                if let json = response as? [String: Any], let baseModel = Mapper<BaseModel>().map(JSON: json) {
                    observer.onNext(baseModel)
                    observer.onCompleted()
                } else {
                    observer.onError(error ?? NetworkError.BACKEND_ERROR)
                }
            }
            return Disposables.create()
        })
    }
}