//
//  AddressBook.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2022/04/13.
//

import UIKit

class AddressBook: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var btn: UIButton!
    
    var addrBook = [Any]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationThemeUtil.defaultShadowTheme(self.navigationController, selfView: self, title: "주소록")
        navigationController?.isNavigationBarHidden = false
        
        addrBook = UserDefaults.standard.array(forKey: "addrBook") ?? []
        
        self.tableView.reloadData()
        
        btn.layer.cornerRadius = btn.frame.size.height / 2
        
    }
    
    @objc func deleteHandler(sender: UIButton) {
        
        let alert = UIAlertController(title: "선택하신 카드를 삭제하시겠습니까?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { action in

            self.addrBook.remove(at: sender.tag)
            UserDefaults.standard.set(self.addrBook, forKey: "addrBook")
            self.tableView.reloadData()

        }))

        self.present(alert, animated: true, completion: nil)
        
    }

}

extension AddressBook: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let total = self.addrBook.count
        
        if total == 0{
            tableView.setEmptyView(title: "", message: "등록된 주소가 없습니다.", imageStr: "", imageW: 0, imageH: 0)
        } else {
            tableView.restore()
            tableView.separatorStyle = .none
        }
        
        return total
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let obj = addrBook[indexPath.row] as! NSDictionary
        let addr = obj["addr"] as! String
        
        store.copyAddr = addr
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddrBookCell", for: indexPath) as! AddrBookCell
        let obj = addrBook[indexPath.row] as! NSDictionary
        let name = obj["name"] as! String
        let addr = obj["addr"] as! String

        cell.label_name.text = name
        cell.label_addr.text = addr
        cell.btn_delete.tag = indexPath.row
        
        cell.btn_delete.addTarget(self, action: #selector(deleteHandler(sender:)), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    
}
