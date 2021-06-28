//
//  ViewController.swift
//  SwiftReviewDemo
//
//  Created by zhengzeqin on 2021/6/25.
//

import UIKit

enum ZQHeaderCellType {
    /// 泛型
    case generic
}


class ViewController: UIViewController {

    // MARK: - Private Property
    fileprivate lazy var tableView: UITableView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        return $0
    } (UITableView())
    
    /// 功能类型数组
    fileprivate let funcTypeArr: [ZQHeaderCellType] = [
        .generic
    ]
    
    fileprivate let cellId = "CELLID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
    }


}


// MARK: - Private Method
extension ViewController {
    fileprivate func initUI() {
        self.tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        self.view.addSubview(self.tableView)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.funcTypeArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.cellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: self.cellId)
        }
        
        var cellTitle = "none"
        let funcType = self.funcTypeArr[indexPath.item]
        switch funcType {
        case .generic:
            cellTitle = "ZQGenericViewController"
        }
        cell?.textLabel?.text = cellTitle
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vc: UIViewController?
        let funcType = self.funcTypeArr[indexPath.item]
        switch funcType {
        case .generic:
            vc = ZQGenericViewController()
        }
        guard let _vc = vc else { return }
        self.navigationController?.pushViewController(_vc, animated: true)
    }
}
