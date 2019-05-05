//
//  ViewController.swift
//  ThanosSnap
//
//  Created by potato04 on 2019/4/29.
//  Copyright © 2019 potato04. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var playing = false
    var tableView: UITableView!
    var testImageView: UIImageView!
    var dustView: DustEffectView!
    
    var snapContext: (cells:[UITableViewCell], index: Int)?
    
    let cellReuseIdentifier = "UITableViewCell"
    let searchResult: [(title: String, content:String, imageName: String?)] = [
        ("灭霸_百度百科", "灭霸（Thanos，音译为萨诺斯）是美国漫威漫画旗下的超级反派，初次登场于《钢铁侠》（Iron Man）第55期（1973年1月）。是出生在土星卫星泰坦上的永恒一族，实力极其 ...", "baidu"),
        ("灭霸- 维基百科，自由的百科全书 - Wikipedia",
         "萨诺斯（英语：Thanos），美国漫威漫画创造的虚拟漫画角色，是一个超级反派。由漫画家吉姆·史达林所创造，首次登场于《钢铁人》（Iron Man）#55（1973年二月）。",
         "wikipedia"),
        ("在 iOS 中实现谷歌灭霸彩蛋 - 掘金","最近上映的复仇者联盟4据说没有片尾彩蛋，不过谷歌帮我们做了。只要在谷歌搜索灭霸，在结果的右侧点击无限手套，你将化身为灭霸，其中一半的搜索结果会化为灰烬消失...",
         "juejin"),
        ("全网最全灭霸资料！ - 知乎","孤独中才见真挚苦难中才见真诚死亡中才见真相——灭霸《复仇者联盟3》大陆定档于5月11日，和全球首映时间相比晚了近半个月。这是漫威电影在内地首次因“翻译”...", "google")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        let gauntlet = ThanosGauntlet(frame: .zero)
        gauntlet.delegate = self
        view.addSubview(gauntlet)
        
        
        tableView = UITableView(frame: .zero)
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        dustView = DustEffectView(frame: .zero)
        dustView.translatesAutoresizingMaskIntoConstraints = false
        dustView.delegate = self
        tableView.addSubview(dustView)
        
        let margin = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: margin.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: margin.topAnchor),
            tableView.widthAnchor.constraint(equalTo: margin.widthAnchor),
            tableView.heightAnchor.constraint(equalToConstant: 420),
            
            gauntlet.widthAnchor.constraint(equalToConstant: 80),
            gauntlet.heightAnchor.constraint(equalToConstant: 80),
            gauntlet.centerXAnchor.constraint(equalTo: margin.centerXAnchor),
            gauntlet.topAnchor.constraint(equalTo: tableView.bottomAnchor),
        ])
    }
    
    func turnCellsToDust() {
        if let context = snapContext, context.index <  context.cells.count {
            let cell = context.cells[context.index]
            dustView.frame = cell.frame
            dustView.image = cell.renderToImage()
            cell.isHidden = true
            snapContext!.index += 1
        }
    }
}

//MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "DefaultCell")
        }
        let result = searchResult[indexPath.row]
        cell!.textLabel?.text = result.title
        cell!.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell!.textLabel?.textColor = UIColor.blue
        cell!.detailTextLabel?.text = result.content
        cell!.detailTextLabel?.numberOfLines = 0
        if let imageName = result.imageName {
            cell?.imageView?.image = UIImage(named: imageName)
        }
        return cell!
    }
}

//MARK: ThanosGauntletDelegate
extension ViewController: ThanosGauntletDelegate {
    func ThanosGauntletDidSnapped() {
        let cellCount = searchResult.count
        var cells = [UITableViewCell]()
        for (index, row) in Array(0..<cellCount).shuffled().enumerated() {
            if index == cellCount / 2 { break }
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) {
                cells.append(cell)
            }
        }
        snapContext = (cells, 0)
        turnCellsToDust()
    }
    func ThanosGauntletDidReversed() {
        if let context = snapContext {
            for cell in context.cells {
                cell.textLabel?.textColor = UIColor(red: 0.0, green: 0.4, blue: 0.13, alpha: 1.0)
                cell.detailTextLabel?.textColor = UIColor(red: 0.0, green: 0.4, blue: 0.13, alpha: 1.0)
                //cell.isHidden = false
            }
            DispatchQueue.main.async {
                for cell in context.cells {
                    cell.isHidden = false
                    UIView.transition(with: cell.textLabel!, duration: 2.0, options: .transitionCrossDissolve, animations: {
                        cell.textLabel?.textColor = UIColor.blue
                    }, completion: nil)
                    UIView.transition(with: cell.detailTextLabel!, duration: 2.0, options: .transitionCrossDissolve, animations: {
                        cell.detailTextLabel?.textColor = UIColor.black
                    }, completion: nil)
                }
            }
        }
    }
}

//MARK: DustEffectViewDelegate
extension ViewController: DustEffectViewDelegate {
    func DustEffectDidCompleted() {
        turnCellsToDust()
    }
}

extension UIView {
    func renderToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
}

