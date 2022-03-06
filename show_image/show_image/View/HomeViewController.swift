//
//  HomeViewController.swift
//  show_image
//
//  Created by shogo harada on 01/03/2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var listPhoto: [PhotoRecord] = []
    let pendingOperations = PendingOperation()
    let imageOperationManager = ImageOperationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchImage()
    }
    
    func setupUI() {
        self.title = "List Photo"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
    }
    
    func fetchImage() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let alertController = UIAlertController(title: "Oops!",
                                                message: "There was an error fetching photo details.",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        ServiceManager.share.fetchImage { result in
            switch result {
            case .success(let photos):
                for photo in photos {
                    self.listPhoto.append(PhotoRecord(photo: photo))
                }
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.tableView.reloadData()
                }
                break
            case .failure(let error):
                self.present(alertController, animated: true, completion: nil)
                break
            }
        }
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listPhoto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)// as! ImageTableViewCell
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(style: .gray)
                cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        var photo = listPhoto[indexPath.row]
        cell.textLabel?.text = photo.photo.description
        cell.imageView?.image = photo.image
        //        cell.setupUI(urlString: self.listPhoto![indexPath.row].photo.urls.thumb, description: self.listPhoto![indexPath.row].description ?? "Phuc")
        switch photo.state {
        case .downloaded, .new:
            indicator.startAnimating()
            startOperations(at: indexPath)
        case .failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
        case .filtered:
            indicator.stopAnimating()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 7
    }
    
    func startOperations(at indexPath: IndexPath) {
        print(listPhoto[indexPath.row].state)
        switch listPhoto[indexPath.row].state {
        case .downloaded:
            imageOperationManager.startFiltration(for: listPhoto[indexPath.row], at: indexPath) { [self] indexPath, photoState in
                listPhoto[indexPath.row].state = photoState
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        case .new:
            imageOperationManager.startDownload(for: listPhoto[indexPath.row], at: indexPath) { [self] indexPath, photoState in
                listPhoto[indexPath.row].state = photoState
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        default:
            print("do nothing")
        }
    }
}

