//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by Ran Helfer on 12/12/2021.
//

import UIKit
import RxSwift
import RxCocoa

enum MyError: Error {
  case anError
}

class ViewController: UIViewController {

    @IBOutlet weak var tapButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var numberLabel: UILabel!
    fileprivate let disposeBag = DisposeBag()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberLabel.text = "0"
        
        tapButton.rx.tap.subscribe({ [weak self] _ in
            guard let this = self else {
                return
            }
            guard let text = this.numberLabel.text else {
                return
            }
            guard let number = Int(text) else {
                return
            }
            this.numberLabel.text = String(number+1)
        }).disposed(by: disposeBag)
        
        resetButton.rx.tap.subscribe({ [weak self] _ in
            guard let this = self else {
                return
            }
            this.numberLabel.text = "0"
        }).disposed(by: disposeBag)
        
        test()
    }

    
    public func example(of description: String, action: () -> Void) {
      print("\n--- Example of:", description, "---")
        action()
    }
    
    func test() {
        example(of: "deferred") {
            let disposeBag = DisposeBag()
            // 1
            var flip = false
            // 2
            let factory: Observable<Int> = Observable.deferred {
                // 3
                flip = !flip
                // 4
                if flip {
                    return Observable.of(1, 2, 3)
                } else {
                    return Observable.of(4, 5, 6)
                }
            }
        }
    }
    
    func test_subscription_events() {
        example(of: "create") {
            let disposeBag = DisposeBag()
            Observable<String>.create { observer in
                // 1
                observer.onNext("1")
                observer.onNext("13")
                observer.onError(MyError.anError)
                
                observer.onNext("1777")
                // 2
                //observer.onCompleted()
                // 3 - this won't be called
                observer.onNext("jkhkjhkjhkjh")
                // 4
                return Disposables.create()
            }.subscribe(
                onNext: { print($0) },
                onError: { print($0) },
                onCompleted: { print("Completed") },
                onDisposed: { print("Disposed") }
              )
              .disposed(by: disposeBag)
        }
    }
    
    func test_initial() {
        
        example(of: "just, of, from") {
            // 1
            let one = 1
            let two = 2
            let three = 3
            // 2 - just one
            let observable: Observable<Int> = Observable<Int>.just(one)
            
            // 3 - an obersvable of int
            let observable2: Observable<Int> = Observable.of(one, two, three)
            
            // 3 - an obersvable of [Int]
            let observable3:Observable<[Int]> = Observable.of([one, two, three])
            
            // 4 - from operator - only takes an array
            // The from operator creates an observable of individual type instances from a regular array of elements
            let observable4 = Observable.from([one, two, three])
        }

        /**
            Ran h
            To my best understanding the developer can subscribe to any sequence and get the event or object inside the event closure
         
         */
        
        example(of: "subscribe") {
            let one = 1
            let two = 2
            let three = 3
            let observable = Observable.of(one, two, three)
            observable.subscribe { event in
                sleep(1)
                //print(event.element)
               // print(event.isCompleted)
                //print(event.error)
                // Event is next
                
                if let element = event.element {
                    print("with event --- + \(element)")
                  }
            }.disposed(by: disposeBag)
            
            /* Ignoring the event and getting the element */
            observable.subscribe(onNext: { element in
                sleep(1)
              print(element)
            }).disposed(by: disposeBag)
        }
        
        
        example(of: "empty") {
          let observable = Observable<Void>.empty()
            observable.subscribe(
            // 1
                onNext: { element in
                  print(element)
            },
            // 2
                onCompleted: {
                  print("Completed")
            }).disposed(by: disposeBag)
        }
        
        
        example(of: "never") {
            let observable = Observable<Any>.never()
            observable
                .subscribe(
                    onNext: { element in
                        print(element)
                    },
                    onCompleted: {
                        print("Completed")
                    }
                ).disposed(by: disposeBag)
        }
        
        let sequence = 0..<7
        var iterator = sequence.makeIterator()
        sleep(6)
        while let n = iterator.next() {
            sleep(1)
            print(n)
        }
    }

}

