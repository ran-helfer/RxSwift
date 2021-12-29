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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiController.shared.currentWeather(city: "HAIFA")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] weather in
                self?.setUpView(weather: weather)
            }).disposed(by: disposeBag)
        
    }
    
    private func setUpView(weather: Weather) {
        self.humidityLabel.text = String(weather.main.humidity)
        self.tempratureLabel.text = String(round(((weather.main.temp-273.15) * 100) / 100))
        self.cityName.text = String(weather.name)
        
        ApiController.shared.imageForIconId(iconUrlString: weather.weather.first?.iconUrl ?? "")
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
                self?.imageView.image = image
            }).disposed(by: disposeBag)

    }
}

