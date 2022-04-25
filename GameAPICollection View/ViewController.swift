//
//  ViewController.swift
//  GameAPICollection View
//
//  Created by Pravin Kumar on 27/03/22.
//

import UIKit

struct Hero: Decodable {
    let localized_name : String
    let img : String
    
}


class ViewController: UIViewController {
    
    var heroes = [Hero]()
    
    @IBOutlet weak var collectionview: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionview.dataSource = self
        let url = URL(string: "https://api.opendota.com/api/heroStats")
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            if error == nil {
                do{
                    self.heroes = try JSONDecoder().decode([Hero].self, from: data!)
                }catch{print(error.localizedDescription)}
                DispatchQueue.main.async {
                    self.collectionview.reloadData()
                }
            }
        }.resume()
        
    }


}

extension ViewController :  UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return heroes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: "gamecell", for: indexPath) as! gameCollectionViewCell
        cell.namelbl.text = heroes[indexPath.row].localized_name.capitalized
        let defaultlink = "https://api.opendota.com"
        let completelink = defaultlink+heroes[indexPath.row].img
        cell.imageview.downloaded(from: completelink)
        cell.imageview.clipsToBounds = true
        cell.imageview.layer.cornerRadius = cell.imageview.frame.height/2
        cell.imageview.contentMode = .scaleAspectFill

        return cell
        
    }
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
        
    }
}
