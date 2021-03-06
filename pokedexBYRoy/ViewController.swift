//
//  ViewController.swift
//  pokedexBYRoy
//
//  Created by Roy Morisi on 11/04/2017.
//  Copyright © 2017 RoyMorisi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, UISearchBarDelegate
{

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var searcBar: UISearchBar!
    
    
    var pokemon = [Pokemon]()
    var filterdPokemon = [Pokemon]()
    var musicPlayer : AVAudioPlayer!
    var inSearchMode = false
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        searcBar.delegate = self
        searcBar.returnKeyType = UIReturnKeyType.done
        //parsePokemonCSV()
        initAudio()
    }
    
    func initAudio ()
    {
        let path = Bundle.main.path(forResource: "music", ofType: "mp3")!
        
        do
        {
            musicPlayer = try AVAudioPlayer(contentsOf: NSURL(string: path)! as URL)
            musicPlayer.prepareToPlay()
            musicPlayer.numberOfLoops = -1
            musicPlayer.play()
        }
        catch let err as NSError
        {
            print(err.debugDescription)
        }
        
    }

    func parsePokemonCSV()
    {
        let path = Bundle.main.path(forResource: "Pokemon" ,ofType: "csv")!
        
        do
        {
            let csv = try CSV (contentsOfURL: path)
            let rows = csv.rows
            
            for row in rows
            {
                let pokeID = Int(row["id"]!)!
                let name = row["identifier"]
                let poke = Pokemon(name: name!, pokedexId: pokeID)
                pokemon.append(poke)
            }
            
        }
        
        catch let err as NSError
        {
            print(err.debugDescription)
        }
    }
    
    //pragma mark - UICollectionView Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if inSearchMode
        {
            return filterdPokemon.count
        }
        return pokemon.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PokeCell", for: indexPath) as? PokeCell
        {
            var poke = pokemon
            
            if inSearchMode
            {
              poke = [filterdPokemon[indexPath.row]]
            }
            else
            {
                poke = [pokemon[indexPath.row]]
            }
          cell.configureCell(poke)
            
            return cell
        }
        else
        {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        var poke: Pokemon!
        if inSearchMode
        {
            poke = filterdPokemon[indexPath.row]
        }
        
        poke = pokemon[indexPath.row]
        
        performSegue(withIdentifier: "PokemonDetailVC", sender: poke)
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width :105 , height:  105)
        
    }
    @IBAction func musicBTNPressed(_ sender: UIButton)
    {
        if musicPlayer.isPlaying
        {
            musicPlayer.stop()
            sender.alpha = 0.2
        }
        else
        {
            musicPlayer.play()
            sender.alpha = 1.0
        }

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        view.endEditing(true)
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if searchBar.text == nil  || searchBar.text == ""
        {
            inSearchMode = false
            view.endEditing(true)
            collection.reloadData()
            
        }
        else
        {
            inSearchMode = true
            let lower = searchBar.text!.lowercased()
            filterdPokemon = pokemon.filter({$0.name.range(of: lower) != nil })
            collection.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "PokemonDetailVC"
        {
            
        if let detailsVC = segue.destination as? PokemonDetailsVC
        {
            if let poke = sender as? Pokemon
            {
                detailsVC.pokemon = poke
            }
        }
            
        }
    }
    
}

