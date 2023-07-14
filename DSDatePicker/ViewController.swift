//
//  ViewController.swift
//  DSDatePicker
//
//  Created by dexiong on 2023/7/13.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var datePicker: DatePickerView = {
        let picker = DatePickerView(frame: .zero)
        picker.backgroundColor = .white
        picker.layer.cornerRadius = 8
        picker.selectDate = { date in
            print(date)
        }
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        
        view.addSubview(datePicker)
        datePicker.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(40)
            $0.top.equalToSuperview().offset(100)
            $0.height.equalTo(240)
        }
    }


}

