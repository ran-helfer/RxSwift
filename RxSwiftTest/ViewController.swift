//
//  ViewController.swift
//  RxSwiftTest
//
//  Created by Ran Helfer on 12/12/2021.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var cityName: UILabel!
    fileprivate let disposeBag = DisposeBag()
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var cityNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ApiController.shared.currentWeather(city: "HAIFA")
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { [weak self] weather in
//                self?.setUpView(weather: weather)
//            }).disposed(by: disposeBag)
        
        let search = cityNameTextField.rx.text
          .filter { ($0 ?? "").count > 0 }
          .flatMapLatest { text in
              //flatMapLatest, makes the search result reusable and transforms a single-use data source into a multi-use Observable.
              return ApiController.shared.currentWeather(city: text ?? "").catchErrorJustReturn(Weather.someWeather())
          }
          .share(replay: 1)
          .observeOn(MainScheduler.instance)
          .throttle(0.5, scheduler: MainScheduler.instance)
         
          
//        search.map { "\(round((($0.main.temp-273.15) * 100) / 100))° C" }
//          .bind(to: tempratureLabel.rx.text)
//          .disposed(by: disposeBag)
//
//        search.map { "\($0.name)" }
//          .bind(to: cityName.rx.text)
//          .disposed(by: disposeBag)
//
//        search.map { "\($0.main.humidity)%" }
//          .bind(to: humidityLabel.rx.text)
//          .disposed(by: disposeBag)
        
        search.map { [weak self] weather in
            self?.setUpView(weather: weather)
            return "\(weather.main.humidity)%"
        }
        .bind(to: humidityLabel.rx.text)
        .disposed(by: disposeBag)
        
    }
    
    private func setUpView(weather: Weather) {
        self.humidityLabel.text = String(weather.main.humidity)
        self.tempratureLabel.text = String(round(((weather.main.temp-273.15) * 100) / 100))
        self.cityName.text = String(weather.name)
        
        guard let firstWeather = weather.weather.first,
                firstWeather.icon.count > 0 else {
            imageView.image = nil
            return
        }
        
        ApiController.shared.imageForIconId(iconUrlString: weather.weather.first?.iconUrl ?? "")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                self?.imageView.image = image
            }).disposed(by: disposeBag)
    }
}

