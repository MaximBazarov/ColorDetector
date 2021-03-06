//
//  FunctionalFoundation.h
//  FunctionalFoundation
//
//  Created by Maxim Bazarov on 4/2/18.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public final class Future<T> {
    
    private let queue = DispatchQueue(label: "Future<T> private queue (FunctionalFoundation)")
    
    private var value: T?
    private var callbacks: [(T) -> ()] = []
    
    public func onComplete(execute: @escaping (T) -> ()) {
        queue.async {
            if let value = self.value {
                execute(value)
            } else {
                self.callbacks.append(execute)
            }
        }
    }
    
    public init(_ value: T) {
        self.value = value
    }
    
    public init(task: (@escaping (T) -> ()) -> ()) {
        task { value in
            self.queue.async {
                self.value = value
                self.callbacks.forEach { $0(value) }
                self.callbacks = []
            }
        }
    }
}

extension Future {
    func map<U>(_ transform: @escaping (T) -> U) -> Future<U> {
        return Future<U> { complete in
            self.onComplete { t in complete(transform(t)) }
        }
    }
}

extension Future {
    public func then<U>(_ execute: @escaping (T) -> Future<U>) -> Future<U> {
        return Future<U> { complete in
            self.onComplete { value in
                execute(value).onComplete(execute: complete)
            }
        }
    }
}

extension Future {
    public func and<U>(_ future: Future<U>) -> Future<(T, U)> {
        return Future<(T, U)> { complete in
            self.onComplete { (value: T) in
                future.onComplete { (anotherValue: U) in
                    complete((value, anotherValue))
                }
            }
        }
    }
}




