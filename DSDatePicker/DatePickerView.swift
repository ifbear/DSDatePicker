//
//  DatePickerView.swift
//  DSDatePicker
//
//  Created by dexiong on 2023/7/13.
//

import UIKit
import SnapKit

extension DateFormatter {
    /// shared
    internal static let shared: DateFormatter = {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.locale = .current
        dateFormatter.timeZone = .current
        return dateFormatter
    }()
    
    internal static func date(from string: String, dateFormat: String = "yyyy年MM月dd日") -> Date? {
        let formatter = DateFormatter.shared
        formatter.dateFormat = dateFormat
        return formatter.date(from: string)
    }
    
    internal static func string(from date: Date, dateFormat: String = "yyyy年MM月dd日") -> String {
        let formatter = DateFormatter.shared
        formatter.dateFormat = dateFormat
        return formatter.string(from: date)
    }
}

enum Component {
    case date(_ date: Date)
    case number(_ number: Int)
    
    internal var title: String {
        switch self {
        case .date(let date):
            var format = DateFormatter.string(from: date, dateFormat: "MM月dd日")
            switch Calendar.current.component(.weekday, from: date) {
            case 1: format.append("星期日")
            case 2: format.append("星期一")
            case 3: format.append("星期二")
            case 4: format.append("星期三")
            case 5: format.append("星期四")
            case 6: format.append("星期五")
            case 7: format.append("星期六")
            default: break
            }
            return format
        case .number(let number):
            return "\(number)"
        }
    }
    
    internal var date: Date {
        switch self {
        case .date(let date):
            return date
        case .number(_):
            fatalError("不支持")
        }
    }
}

class DatePickerView: UIView {
    
    internal var minDate: Date = .startOfCurrentYear {
        didSet { reloadDateComponent() }
    }
    
    internal var maxDate: Date = .endOfCurrentYear {
        didSet { reloadDateComponent() }
    }
    
    internal var callbackHandler: ((Date) -> Void)? = nil
    
    private let locale: Locale = .init(identifier: "zh-hans")
    
    /// pickerView
    private lazy var pickerView: UIPickerView = {
        let picker: UIPickerView = .init(frame: .zero)
        picker.contentMode = .center
        picker.dataSource = self
        picker.delegate = self
        return picker
    }()
    
    /// titleLabel
    private lazy var titleLabel: UILabel = {
        let _label = UILabel(frame: .zero)
        _label.font = .systemFont(ofSize: 12.0)
        _label.textAlignment = .center
        var text: String = ""
        if let standard = TimeZone.current.localizedName(for: .standard, locale: locale) {
            text.append(standard)
        }
        if let abbreviation = TimeZone.current.abbreviation() {
            text.append("(\(abbreviation))")
        }
        _label.text = text
        return _label
    }()
    
    private var dateComponent: [Component] = []
    private var hourComponent: [Component] = []
    private var minuteComponent: [Component] = []
    
    private var currentDate: Date {
        return Date().addingTimeInterval(TimeInterval(Calendar.current.timeZone.secondsFromGMT()))
    }

    internal override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(12.0)
        }
        
        addSubview(pickerView)
        pickerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        reloadDateComponent()
        reloadHourComponent()
        reloadMinuteComponent()
        selectCurrentDate()
    }
    
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension DatePickerView {
    
    /// 刷新date
    private func reloadDateComponent() {
        let timeInterval = TimeInterval(Calendar.current.timeZone.secondsFromGMT())
        // 今年
        let min = Calendar.current.component(.year, from: minDate)
        let max = Calendar.current.component(.year, from: maxDate)
        
        var dateComponents: [Component] = []
        for y in min...max {
            let isLeapYear = y % 4 == 0 ? (y % 100 == 0 ? (y % 400 == 0 ? true : false) : true) : false;
            for m in Array(1...12) {
                let days: Int
                if m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12 { // 31 天
                    days = 31
                } else if m == 4 || m == 6 || m == 9 || m == 11 { // 30 天
                    days = 30
                } else if isLeapYear == true { // 29 天
                    days = 29
                } else { // 28 天
                    days = 28
                }
                for d in 1...days {
                    guard let date = DateFormatter.date(from: "\(y)年\(m)月\(d)日")?.addingTimeInterval(timeInterval) else { continue }
                    dateComponents.append(.date(date))
                }
            }
        }
        self.dateComponent = dateComponents
        pickerView.reloadComponent(0)
    }
    
    /// 刷新小时
    private func reloadHourComponent() {
        // 小时
        var hoursComponents: [Component] = []
        for h in 0...23 {
            hoursComponents.append(.number(h))
        }
        self.hourComponent = hoursComponents
    }
    
    /// 刷新分钟
    private func reloadMinuteComponent() {
        var minutesComponents: [Component] = []
        for m in 0...59 {
            minutesComponents.append(.number(m))
        }
        self.minuteComponent = minutesComponents
    }
    
    // 选中当前时间
    private func selectCurrentDate(animated: Bool = false) {
        for (offset, element) in dateComponent.enumerated() {
            if Calendar.current.isDateInToday(element.date) {
                pickerView.selectRow(offset, inComponent: 0, animated: animated)
                break
            }
        }
        
        let hour = Calendar.current.component(.hour, from: Date())
        pickerView.selectRow(hour, inComponent: 1, animated: animated)
        
        let minute = Calendar.current.component(.minute, from: Date())
        pickerView.selectRow(minute, inComponent: 2, animated: animated)
        
    }
}

extension DatePickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int {
        3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return dateComponent.count
        case 1: return hourComponent.count
        case 2: return minuteComponent.count
        default: return 0
        }
    }
    
    internal func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let value = view as? UILabel {
            label = value
        } else {
             label = UILabel(frame: .zero)
        }
        if component == 0 {
            label.textAlignment = .right
            label.text = dateComponent[row].title
        } else if component == 1 {
            label.textAlignment = .center
            label.text = hourComponent[row].title
        } else {
            label.textAlignment = .left
            label.text = minuteComponent[row].title
        }
        label.minimumScaleFactor = 0.5
        label.font = .systemFont(ofSize: 16.0, weight: .regular)
        label.adjustsFontSizeToFitWidth = true
        
        setSelectRowStyle(pickerView, viewForRow: row, forComponent: component)
        
        return label
    }
    
    
    private func setSelectRowStyle(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int) {
//        let systemVersion = UIDevice.current.systemVersion
        // 1.设置分割线的颜色
//        if Double(systemVersion) ?? 0 < 14.0 {
//            for view in pickerView.subviews {
//                if view.bounds.height <= 1.0 {
//                    view.backgroundColor = .gray
//                }
//            }
//        }
        // 2.设置选择器中间选中行的背景颜色
//        if let contentView = pickerView.subviews.first {
//            // 设置选中行背景色
//            if let cacheViews = contentView.value(forKey: "subviewCache") as? [AnyObject],
//               let columnView = cacheViews.compactMap({ $0 as? UIView }).first,
//               let selectRowView = columnView.value(forKey: "middleContainerView") as? UIView
//            {
//                 selectRowView.backgroundColor = .white
//            }
//            if Double(systemVersion) ?? 0 > 14.0 {
//                // ①隐藏中间选择行的背景样式
//                if let lastView = pickerView.subviews.last {
//                    lastView.isHidden = true
//                }
//                // ②清除iOS14上选择器默认的内边距
//                clearPickerAllSubviews(contentView)
//            }
//        }
        // 3.设置选择器中间选中行的字体颜色/字体大小
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let label = pickerView.view(forRow: row, forComponent: component) as? UILabel {
                label.font = .systemFont(ofSize: 16.0, weight: .medium)
            }
        }
    }
    
    private func clearPickerAllSubviews(_ view: UIView) {
        if view.subviews.count == 0 || view is UILabel { return }
        for v in view.subviews {
            if String(describing: v.self) == "UIPickerColumnView" {
                var frame = v.frame
                frame.origin.x = 0
                frame.size.width = view.bounds.size.width
                v.frame = frame
            }
            if String(describing: view.self) == "UIPickerColumnView" {
                var frame = v.frame
                frame.size.width = view.bounds.width
                v.frame = frame
            }
            if v is UILabel {
                var frame = v.frame
                frame.origin.x = 10
                v.frame = frame
            }
            clearPickerAllSubviews(v)
        }
        
    }
    
    internal func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return bounds.size.width * 0.5
        case 1:
            return bounds.size.width * 0.2
        case 2:
            return bounds.size.width * 0.3
        default:
            return 0
        }
    }
    
    internal func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40.0
    }
    
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 判断时间小于当前时间，选中当前时间
        let dateRow = pickerView.selectedRow(inComponent: 0)
        let hour = pickerView.selectedRow(inComponent: 1)
        let minute = pickerView.selectedRow(inComponent: 2)
        
        let selected = dateComponent[dateRow].date.addingTimeInterval(TimeInterval(hour * 3600 + minute * 60 + 59))
        
        if selected.compare(currentDate) == .orderedAscending {
            selectCurrentDate(animated: true)
            callbackHandler?(currentDate)
        } else {
            callbackHandler?(selected)
        }
    }
}
