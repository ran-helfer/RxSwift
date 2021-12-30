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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.isHidden = true

        cityNameTextField.layer.borderColor = UIColor.blue.cgColor
        cityNameTextField.layer.borderWidth = 1

        ApiController.shared.currentWeather(city: "paris")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] weather in
                self?.setUpView(weather: weather)
            }).disposed(by: disposeBag)
        
        let search = cityNameTextField.rx.text
          .filter { ($0 ?? "").count > 0 }
          .flatMapLatest { text in
              //flatMapLatest, makes the search result reusable and transforms a single-use data source into a multi-use Observable.
              return ApiController.shared.currentWeather(city: text ?? "").catchErrorJustReturn(Weather.someWeather())
          }
          .share(replay: 1)
          .observeOn(MainScheduler.instance)
          .throttle(0.5, scheduler: MainScheduler.instance)
         
        
        cityNameTextField.rx.controlEvent(.editingChanged).asObservable().subscribe { [weak self] value in
            self?.activityIndicator.startAnimating()
            self?.activityIndicator.isHidden = false
        }.disposed(by: disposeBag)


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
        humidityLabel.text = String(weather.main.humidity)
        tempratureLabel.text = String(round(((weather.main.temp-273.15) * 100) / 100))
        cityName.text = String(weather.name)
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true

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

