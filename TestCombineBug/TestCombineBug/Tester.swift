//
//  Tester.swift
//  TestCombineBug
//
//  Created by Nikola Milovanovic on 6.12.22..
//

import Foundation
import Combine
import SwiftUI

enum SomeError: Error {
    case some
}

final class Tester: ObservableObject {
    
    private let subject1 = PassthroughSubject<Int, Never>()
    private let subject2 = PassthroughSubject<[Int], Never>()
    private let subject3 = PassthroughSubject<Void, Never>()
    private let subject4 = PassthroughSubject<String, Never>()
    
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    func start() {
        sendEvents()
    }
    
    private func sendEvents() {
        print("\nPushing values on all subjects, except merged one:\n")
        subject1.send(1)
        subject2.send([1])
        subject4.send("Test")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("\nPushing new value on first subject, to trigger combineLatest:\n")
            self.subject1.send(3)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("\nPushing value on merged one:\n")
            self.subject3.send()
        }
    }
    
    func subscribe() {
        let pub1 = subject1.combineLatest(subject2).print("PUB1")
        
        let pub2 = pub1.map { _ in true }.merge(with: subject3.map { false }).print("PUB2")
                
        pub2.combineLatest(subject4)
            .print("PUB3 - 1")
            .flatMap(maxPublishers: .max(1)) { [weak self] tuple -> AnyPublisher<[Int], Never> in
                guard let self = self else { return Empty().eraseToAnyPublisher() }
                
                return self.loadNumbers()
            }
            .print("PUB3 - 2")
            .sink { numbers in
                print("Finished with numbers:", numbers, "\n")
            }
            .store(in: &subscriptions)
    }
        
    private var lastNumber = 1
    
    private func loadNumbers() -> AnyPublisher<[Int], Never> {
        return Deferred {
            Future { promise in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let output = Array((self.lastNumber..<self.lastNumber+3).map { $0 } )
                    self.lastNumber += 3
                    promise(.success(output))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
