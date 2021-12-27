//
//  Tests.swift
//  RxSwiftTest
//
//  Created by Ran Helfer on 27/12/2021.
//

import Foundation
import RxSwift
import RxCocoa


struct Student {
    var score: BehaviorSubject<Int>
}

enum MyError: Error {
    case anError
}


class Tests {
   
    fileprivate let disposeBag = DisposeBag()

    func print1<T: CustomStringConvertible>(label: String, event: Event<T>) {
        print(label, event.element ?? event.error ?? event)
    }
    
    public func example(of description: String, action: () -> Void) {
        print("\n--- Example of:", description, "---")
        action()
    }
    
    func test() {
        /**
         
         */
        example(of: "switchLatest From source") {
            // 1
            let one = PublishSubject<String>()
            let two = PublishSubject<String>()
            let three = PublishSubject<String>()
            let source = PublishSubject<Observable<String>>()
            
            // 2
            let observable = source.switchLatest()
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            // 3
            source.onNext(one)
            one.onNext("Some text from sequence one")
            two.onNext("Some text from sequence two - this ignored")
            
            source.onNext(two)
            two.onNext("More text from sequence two")
            one.onNext("and also from sequence one - this ignored")
            
            source.onNext(three)
            two.onNext("Why don't you see me?")
            one.onNext("I'm alone, help me")
            three.onNext("Hey it's three. I win.")
            
            source.onNext(one)
            one.onNext("Nope. It's me, one!")
            
            
            disposable.dispose()
        }
    }
    
    func test_amb() {
        /**
         The amb(_:) operator subscribes to left and right observables. It waits for any of them to emit an element, then unsubscribes from the other one. After that, it only relays elements from the first active observable. It really does draw its name from the term ambiguous: at first, you don’t know which sequence you’re interested in, and want to decide only when one fires.
         This operator is often overlooked. It has a few select practical applications, like connecting to redundant servers and sticking with the one that responds first.
         */
        
        example(of: "amb") {
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            // 1
            let observable = left.amb(right)
            let disposable = observable.subscribe(onNext: { value in
                print(value)
            })
            // 2
            left.onNext("Lisbon")
            right.onNext("Copenhagen")
            left.onNext("London")
            left.onNext("Madrid")
            right.onNext("Vienna")
            disposable.dispose()
        }
    }
    
    func test_withSample() {
        /*
         It does nearly the same thing as withLatestFrom with just one variation: each time the trigger observable emits a value, sample(_:) emits the latest value from the “other” observable, but only if it arrived since the last “tick”. If no new data arrived, sample(_:) won’t emit anything. If data is the same - no new emitted event
         
         Note: Don’t forget that withLatestFrom(_:) takes the data observable as a parameter, while sample(_:) takes the trigger observable as a parameter. This can easily be a source of mistakes — so be careful!
         */
        example(of: "withSample") {
            // 1
            let button = PublishSubject<Void>()
            let textField = PublishSubject<String>()
            // 2
            /* button is the trigger for sampling */
            let observable = textField.sample(button)
            _ = observable.subscribe(onNext: { value in
                print(value)
            })
            // 3
            textField.onNext("Par")
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext(())
            button.onNext(())
            button.onNext(())
            textField.onNext("Paris diff")
            button.onNext(())
            button.onNext(())
        }
    }
    
    func testWithLatestFrom() {
        /*
         Simple and straightforward! withLatestFrom(_:) is useful in all situations where you want the current (latest) value emitted from an observable, but only when a particular trigger occurs.
         */

        example(of: "withLatestFrom") {
          // 1
          let button = PublishSubject<Void>()
          let textField = PublishSubject<String>()
        // 2
          let observable = button.withLatestFrom(textField)
          _ = observable.subscribe(onNext: { value in
            print(value)
          })
        // 3
          textField.onNext("Par")
          textField.onNext("Pari")
          textField.onNext("Paris")
          button.onNext(())
          button.onNext(())
        }
    }
    
    func testZip() {
        /**
         Did you notice how Vienna didn’t show up in the output? Why is that?
         
         The explanation lies in the way zip operators work. They wait until each of the inner observables emits a new value. If one of them completes, zip completes as well. It doesn’t wait until all of the inner observables are done! This is called indexed sequencing, which is a way to walk though sequences in lockstep.*
         */
        
        example(of: "zip") {
          enum Weather {
            case cloudy
            case sunny
          }
            let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy,
          .sunny)
            let right = Observable.of("Lisbon", "Copenhagen", "London", "Madrid",
          "Vienna")
            let observable = Observable.zip(left, right) { weather, city in
               return "It's \(weather) in \(city)"
             }
             observable.subscribe(onNext: { value in
               print(value)
           })
            
        }
    }
    
    func testStartWith() {
        
        //Create a sequence starting with the value 1, then continue with the original sequence of numbers.
        example(of: "startWith") {
          // 1
          let numbers = Observable.of(2, 3, 4)
        // 2
          let observable = numbers.startWith(1)
          observable.subscribe(onNext: { value in
            print(value)
          })
        }
    }
    
    func testCombineLatest() {
        example(of: "combineLatest") {
          let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            // 1
              let observable = Observable.combineLatest(left, right, resultSelector:
            {
                lastLeft, lastRight in
                "\(lastLeft) \(lastRight)"
              })
              let disposable = observable.subscribe(onNext: { value in
                print(value)
              })
            // 2
            print("> Sending a value to Left")
            left.onNext("Hello,")
            print("> Sending a value to Right")
            right.onNext("world")
            print("> Sending another value to Right")
            right.onNext("RxSwift")
            print("> Sending another value to Left")
            left.onNext("Have a good day,")
            
            disposable.dispose()
         }
            
            
    }
    
    func testMapOperator() {
        let urlString = ["Some_string_url"]
        
        let urlRequest:[URLRequest] =
            urlString.map { urlString -> URL in
                let string = "https://api.github.com/repos/\(urlString)/events"
                if let url = URL(string: string) {
                    return url
                }
                return URL(fileURLWithPath: "")
            }.map { url -> URLRequest in
                return URLRequest(url: url)
            }
    }
    
    func test_materialize_dematerialize() {
        example(of: "materialize and dematerialize") {
            // 1
            enum MyError: Error {
                case anError
            }
            let disposeBag = DisposeBag()
            // 2
            let ryan = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 100))
            let student = BehaviorSubject(value: ryan)
            
            // 1
            let studentScore = student
                .flatMapLatest {
                    $0.score.materialize()
                }
            // 2
            studentScore
                .filter {
                    /* Without this filter charolote score won't be printed */
                    guard $0.error == nil else {
                        print($0.error!)
                        return false
                    }
                    return true
                }
                .dematerialize()
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            // 3
            ryan.score.onNext(85)
            ryan.score.onError(MyError.anError)
            ryan.score.onNext(90)
            // 4
            student.onNext(charlotte)
        }
        
        
    }
    
    func testFlatMap() {
        example(of: "flatMap") {
            let disposeBag = DisposeBag()
            // 1
            let ryan = Student(score: BehaviorSubject(value: 80))
            let charlotte = Student(score: BehaviorSubject(value: 100))
            // 2
            let student = PublishSubject<Student>()
            // 3
            student
                .flatMap {
                    $0.score }
            // 4
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            student.onNext(ryan)
            ryan.score.onNext(85)
            ryan.score.onNext(90)
            
            student.onNext(charlotte)

        }
    }
    
    func testEnumeratedAndMap() {
        example(of: "enumerated and map") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of(1, 2, 3, 4, 5, 6)
            // 2
                .enumerated()
            // 3
                .map { index, integer in
                    index > 2 ? integer * 2 : integer
                }
            // 4
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
    }
    
    
    func testMapTransformer() {
        example(of: "MapTransformer") {
            let disposeBag = DisposeBag()
            // 1
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            // 2
            Observable<NSNumber>.of(123, 4, 56)
            // 3
                .map {
                    formatter.string(from: $0) ?? ""
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
    }
    func testToArray() {
        
        
        example(of: "toArray") {
            let disposeBag = DisposeBag()
            // 1
            Observable.of("A", "B", "C")
            // 2
                .toArray()
                .subscribe(onNext: {
                    print($0) }
                )
                .disposed(by: disposeBag)
        }
        
        //        example(of: "toArray") {
        //            let disposeBag = DisposeBag()
        //            // 1
        //            let subject = PublishSubject<String>()
        //
        //            subject.onNext("here")
        //            sleep(1)
        //            subject.onNext("here1")
        //            sleep(1)
        //            subject.onNext("here2")
        //            sleep(1)
        //            subject.onNext("here3")
        //            sleep(1)
        //
        //            Observable.of(subject)
        //            // 2
        //                //.toArray()
        //                .subscribe(onNext: {
        //                    print("next")
        //
        //                    print($0)
        //
        //                }, onCompleted: {
        //                    print("completed")
        //                })
        //                .disposed(by: disposeBag)
        //
        //
        //
        //            subject.onCompleted()
        //
        //        }
        
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
