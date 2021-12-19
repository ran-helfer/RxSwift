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

    func print1<T: CustomStringConvertible>(label: String, event: Event<T>) {
      print(label, event.element ?? event.error ?? event)
    }
    
    public func example(of description: String, action: () -> Void) {
        print("\n--- Example of:", description, "---")
        action()
    }
    
    func test() {
        
        
    }
    
    func testtakeUntil() {
        example(of: "takeUntil") {
            let disposeBag = DisposeBag()
            // 1
            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()
            // 2
            subject.takeUntil(trigger)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            // 3
            subject.onNext("1")
            subject.onNext("2")
            
            trigger.onNext("X")
            subject.onNext("3")
        }
        /**
         The X stops the taking, so 3 is not allowed through and nothing more is printed.
         */
    }
    
    func testTakeWhile() {
        example(of: "takeWhile") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of(2, 2, 4, 4, 6, 6)
            // 2
                .enumerated()
            // 3
                .takeWhile { index, integer in
                    // 4
                    integer % 2 == 0 && index < 3
                }
            // 5
                .map { $0.element }
            // 6
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        /**

         Like skipUntil, there's also a takeUntil operator, shown in this marble diagram, taking from the source observable until the trigger observable emits an element.
         Add this new example, which is just like the skipUntil example you created earlier:
         --- Example of: takeWhile ---
         2
         2
         4
         */
    }
    
    func testTake() {
        example(of: "take") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of(1, 2, 3, 4, 5, 6)
            // 2
                .take(3)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        /**
         
         --- Example of: take ---
         1
         2
         3
         */
    }
    
    func testskipUntil() {
        example(of: "skipUntil") {
            let disposeBag = DisposeBag()
            // 1
            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()
            // 2
            subject
                .skipUntil(trigger)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            subject.onNext("A")
            subject.onNext("B")
            
            trigger.onNext("X")
            
            subject.onNext("now it will print ")

        }
    }
    
    func testskipWhile() {
        example(of: "skipWhile") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of(2, 2, 3, 4, 4)
            // 2
                .skipWhile { integer in
                    integer % 2 == 0
                }
                .subscribe(onNext: {
                    print($0)
                }).disposed(by: disposeBag)
        }
        /**
         --- Example of: skipWhile ---
         3
         4
         4

         
         */
    }
    
    func testSkip() {
        example(of: "skip") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of("A", "B", "C", "D", "E", "F")
            // 2
                .skip(3)
                .subscribe(onNext: {
                    print($0) })
                .disposed(by: disposeBag)
        }
    }
    
    func testFilter() {
        example(of: "filter") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of(1, 2, 3, 4, 5, 6)
            // 2
                .filter { integer in
                    integer % 2 == 0
                }
            // 3
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func testElementAt() {
        example(of: "elementAt") {
            // 1
            let strikes = PublishSubject<String>()
            let disposeBag = DisposeBag()
            // 2
            strikes
                .elementAt(2)
                .subscribe(onNext: { element in
                    print("You're out! \(element)")
                })
                .disposed(by: disposeBag)
            
            strikes.onNext("X")
            strikes.onNext("Y")
            strikes.onNext("Z")
            strikes.onNext("dfgdfg")
        }
    }
    
    func testIgnoreElements() {
        example(of: "ignoreElements") {
            // 1
            let strikes = PublishSubject<String>()
            let disposeBag = DisposeBag()
            // 2
            strikes
                .ignoreElements()
                .subscribe { _ in
                    print("You're out!")
                }
                .disposed(by: disposeBag)
            
            strikes.onCompleted()
        }
    }
    
    func testReplaySubject() {
        example(of: "ReplaySubject") {
          // 1
          let subject = ReplaySubject<String>.create(bufferSize: 2)
          let disposeBag = DisposeBag()
        // 2
          subject.onNext("1") // Will never get emitted if the size is 2
          subject.onNext("2")
          subject.onNext("3")
        // 3
        subject.subscribe {
            self.print1(label: "1)", event: $0)
          }
          .disposed(by: disposeBag)
        
        subject
          .subscribe {
              self.print1(label: "2)", event: $0)
          }
          .disposed(by: disposeBag)
        
        subject.onNext("4")
        
        subject.onError(MyError.anError)
            
        subject.dispose()
            
        subject
              .subscribe {
                  self.print1(label: "3)", event: $0)
              }
              .disposed(by: disposeBag)
        
        }
        
        
    }
    
    func testBehaviorSubject() {
        // 3
        example(of: "BehaviorSubject") {
            // 4
            let subject = BehaviorSubject(value: "Initial value")
            let disposeBag = DisposeBag()
            
            
            subject
                .subscribe {
                    self.print1(label: "1)", event: $0)
                }
                .disposed(by: disposeBag)
            
            subject.onNext("X")
            
            // 1
            subject.onError(MyError.anError)
            
            // 2
            subject
              .subscribe {
                  self.print1(label: "2)", event: $0)
              }
              .disposed(by: disposeBag)
            
            subject.onNext("this won't be emittedd ")


        }
    }
    
    func testPublishSubject() {
        example(of: "PublishSubject") {
            
            let subject = PublishSubject<String>()
            subject.onNext("Is anyone listening?")
            
            let subscriptionOne = subject
                .subscribe(onNext: { string in
                    print(string)
            })
            
            subject.on(.next("1"))
            subject.onNext("2")
            
            
            let subscriptionTwo = subject
              .subscribe { event in
                print("2)", event.element ?? event)
            }
            
            subject.onNext("3")
            
            subscriptionOne.dispose()
            
            subject.onNext("4")
            
            // 1
            subject.onCompleted()
            // 2
            subject.onNext("5")
            // 3
            subscriptionTwo.dispose()
            let disposeBag = DisposeBag()
            // 4
            subject
              .subscribe {
                print("3)", $0.element ?? $0)
              }
              .disposed(by: disposeBag)
            subject.onNext("?")
        }
    }
    
    /* Rather than creating an observable that waits around for subscribers, it’s possible to create observable factories that vend a new observable to each subscriber. */
    func testDeferred() {
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
    
    
    /**The do operator allows you to insert side effects; that is, handlers to do things that will not change the emitted event in any way. do will just pass the event through to the next operator in the chain. do also includes an onSubscribe handler, something that subscribe does not. **/
    func testDo() {
        example(of: "DO Operator") {
            let disposeBag = DisposeBag()

            Observable<String>.create { observer in
                return Disposables.create()
            }.do { observable in

            } onError: { error in

            } onCompleted: {

            } onSubscribe: {

            } onSubscribed: {

            } onDispose: {

            }.subscribe(onNext: { observer in
                
            }).disposed(by: disposeBag)

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
                //print(event.element)  /* usually we want the element */
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

