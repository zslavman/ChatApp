//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 31.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase


class FindUserForChatController: UITableViewController, UISearchBarDelegate {

	private var cellID = "cellID"
	private var users = [User]()
	private var timer:Timer? // таймер-задержка перезагрузки таблицы
	private var owner:User?
	
	private var twoD = [[User]]()
	private var letter = [String]() // массив первых букв юзеров
	private var disposeVar:(DatabaseReference, UInt)!
	
	private var searchController:UISearchController!
	private var filteredResultArray = [[User]]()
	
	private var isSearchingNow: Bool {
		// return searchController.isActive && !searchController.searchBar.text!.isEmpty
		return searchController.searchBar.isFirstResponder && !searchController.searchBar.text!.isEmpty
	}
	
	private var labelNoResults:UILabel!
	

	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// section headers не будут прилипать сверху таблицы
		// self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
		
		let messagesController = tabBarController?.viewControllers![0].childViewControllers.first as! MessagesController
		owner = messagesController.owner
		
		// searchController = UISearchController(searchResultsController: nil)
		searchController = SearchController(searchResultsController: nil)
		searchController.searchBar.delegate = self

		//navigationItem.title = "Все юзеры"
		navigationController?.view.backgroundColor = UIConfig.mainThemeColor
		navigationController!.navigationBar.isTranslucent = false
		
		fetchUsers()
		
		// чтоб до viewDidLoad не отображалась дефолтная таблица
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.backgroundColor = UIColor.white
		
		tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
		tableView.sectionIndexColor = UIConfig.mainThemeColor
		tableView.separatorColor = UIConfig.mainThemeColor.withAlphaComponent(0.5)
		
		setupSearchBar()
		installNoResultsLabel()
	}
	
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		searchController.searchBar.placeholder = dict[18]![LANG] // Поиск
		
		if let cancelButton = searchController.searchBar.value(forKey: "cancelButton") as? UIButton {
			cancelButton.setTitle(dict[19]![LANG], for: .normal) // Отмена
		}
		
		labelNoResults.text = dict[33]![LANG] // "Нет результатов"
		
//		UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = dict[19]![LANG] // Отмена
//		for view in (searchController.searchBar.subviews[0]).subviews{
//			if let button = view as? UIButton{
//				button.setTitle(dict[19]![LANG], for:.normal)
//			}
//		}
	}

	
	
	// не сработает, если не закончили поиск
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		searchController.isActive = false
		searchController.dismiss(animated: false, completion: nil)
	}

	
	
	public func dispose(){
		disposeVar?.0.removeObserver(withHandle: disposeVar.1)
		disposeVar = nil
	}
	
	
	private func installNoResultsLabel(){
		
		labelNoResults = {
			let label = UILabel()
			label.text = dict[33]![LANG]   // "Нет результатов"
			label.backgroundColor = .clear
			label.textColor = .lightGray
			label.font = UIFont.boldSystemFont(ofSize: 22)
			label.textAlignment = .center
			label.translatesAutoresizingMaskIntoConstraints = false
			label.isHidden = true
			return label
		}()
		
		tableView.addSubview(labelNoResults)
		
		labelNoResults.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
		labelNoResults.topAnchor.constraint(equalTo: tableView.topAnchor, constant: 150).isActive = true
	}


	
	
	
	
	private func setupSearchBar(){
		
//		if #available(iOS 11.0, *) {
//			navigationItem.searchController = searchController
//			//navigationItem.hidesSearchBarWhenScrolling = false
//		}
//		else {
			// searchController.searchBar.placeholder = "Найти собеседника"
			navigationItem.titleView = searchController.searchBar
			definesPresentationContext = false
			searchController.hidesNavigationBarDuringPresentation = false
//		}
		
		//отключаем затемнение вьюконтроллера при вводе
		searchController.dimsBackgroundDuringPresentation = false
		searchController.obscuresBackgroundDuringPresentation = false

		searchController.searchBar.barTintColor = .white
		searchController.searchBar.tintColor = UIConfig.mainThemeColor // цвет курсора
		searchController.searchBar.searchBarStyle = .prominent
//		searchController.searchBar.backgroundImage = UIImage() 	// не дает эффекта
//		searchController.searchBar.backgroundColor = .clear 	// не дает эффекта
		searchController.searchBar.isTranslucent = false

		// цвет текста в поиске
		// UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIConfig.mainThemeColor]
		
		// цвет кнопки "Отмена" в поисковой строке, а точнее цвет надписи
		UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white], for: .normal)
		
		if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
			
			if #available(iOS 11.0, *) {
				searchTextField.layer.cornerRadius = 18 // 18
			}
			else {
				searchTextField.layer.cornerRadius = 14
			}
			searchTextField.clipsToBounds = true
			
			if let some = searchTextField.subviews.first {
				some.backgroundColor = UIColor.white
				some.layer.backgroundColor = UIColor.white.cgColor
			}
		}
		
		// изменение размеров searchBar
//		let image = Calculations.getImageWithColor(color: UIColor.white, size: CGSize(width: 180, height: 26))
//		searchController.searchBar.setSearchFieldBackgroundImage(image, for: .normal)
		
	}
	
	
	
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		// фильтруем 2-мерный массив
//		filteredResultArray = twoD.filter({ // здесь возвращает массив с подходящими и не подходящими элементами
//			(userArr:[User]) -> Bool in
//
//			let newArr = userArr.filter({
//				(user:User) -> Bool in
//				return user.email!.lowercased().contains(searchText.lowercased()) || user.name!.lowercased().contains(searchText.lowercased())
//			})
//			return newArr.count > 0
//		})
		if !searchText.isEmpty{
			let filtered = users.filter {
				(user:User) -> Bool in
				return user.email!.lowercased().contains(searchText.lowercased()) || user.name!.lowercased().contains(searchText.lowercased())
			}
			prepareData(source: filtered)
			if twoD.isEmpty {
				labelNoResults?.isHidden = false
			}
			else {
				labelNoResults?.isHidden = true
			}
		}
		else {
			prepareData(source: users)
		}
		
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}

	}
	
	

	
	
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

		searchBar.resignFirstResponder()
		prepareData(source: users)
		tableView.reloadData()
		labelNoResults?.isHidden = true
	}
	
	
	
	private func fetchUsers(){
		
		let ref = Database.database().reference(withPath: "users")
		let handler = ref.observe(.childAdded, with: { // по сути - это цикл
			(snapshot) in
			
			if let dict = snapshot.value as? [String:AnyObject]{
				let user = User()
				// крашанет если в классе не найдется переменных с именами ключей словаря
				user.setValuesForKeys(dict)
				
				// ГЛЮК БАЗЫ - юзер у которого всё = nil!!!!! (c браузера его не видно!)
				if user.email != nil{
					self.users.append(user)
				}
			}
			self.attemptReloadofTable()
		}, withCancel: nil)
		
		disposeVar = (ref, handler)
	}
	
	
	
	
	/// преобразовывает масив юзеров в 2-х мерного массив для секций таблицы
	private func prepareData(source:[User]){
		
		var temp1D = [User]()
		var temp2D = [[User]]()
		letter.removeAll()
		
		// убираем себя из массива
		temp1D = source.filter { // нужно возвратить то, что должно остатся
			(user) -> Bool in
			return user.name != owner?.name
		}
		
		// создаем массив букв (без повтора)
		for value in temp1D {
			let char = value.name?.prefix(1).uppercased()
			if !letter.contains(char!){
				letter.append(char!)
				temp2D.append([])
			}
			letter.sort()
		}
		
		// заполняем массив массивов юзеров, согласно алфавита
		for value in temp1D {
			let char = value.name?.prefix(1).uppercased()
			let index = letter.index(of: char!)
			temp2D[index!].append(value)
		}
		
		// сортируем элементы каждого внутреннего массива
		var newArr = [[User]]()
		for var value in temp2D {
			// value.sort{$0.lowercased() < $1.lowercased()}
			value.sort{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedAscending}
			
			newArr.append(value)
		}
		
		twoD = newArr
		if !twoD.isEmpty{
			labelNoResults.isHidden = true
		}
	}
	
	
	
	

	
	private func attemptReloadofTable(){
		timer?.invalidate()
		timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.delayedRelodTable), userInfo: nil, repeats: false)
	}

	@objc private func delayedRelodTable(){
		// users.sort{$0.email!.localizedCaseInsensitiveCompare($1.email!) == .orderedAscending}
		prepareData(source: users)
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	
	

	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		label.text = "       " + letter[section]
		label.textColor = UIConfig.mainThemeColor
		label.backgroundColor = ChatMessageCell.blueColor
		label.font = UIFont.boldSystemFont(ofSize: 16)
		return label
	}
	

	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return twoD[section].count
	}
	
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return twoD.count
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
		
		let user = twoD[indexPath.section][indexPath.row]

		cell.textLabel?.text = user.name
		cell.detailTextLabel?.text = user.email
		
		if user.isOnline {
			cell.onlinePoint.backgroundColor = UserCell.onLineColor
		}
		else {
			cell.onlinePoint.backgroundColor = UserCell.offLineColor
		}
		

		if let profileImageUrl = user.profileImageUrl{
			// качаем картинку
			cell.profileImageView.loadImageUsingCache(urlString: profileImageUrl){
				(image) in
				// перед тем как присвоить ячейке скачанную картинку, нужно убедиться, что она видима (в границах экрана)
				// и обновить ее в главном потоке
				DispatchQueue.main.async {
					cell.profileImageView.image = image
				}
			}
		}
		
		// цвет выделения при клике на ячейку
		let selectionColor = UIView()
		selectionColor.backgroundColor = ChatMessageCell.blueColor.withAlphaComponent(0.45)
		cell.selectedBackgroundView = selectionColor
		cell.selectionStyle = .default
		
		return cell
	}
	
	
	
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 72.0
	}
	
	// на iOS 10 не будет работать без этого, так как в 10-ке по умолчанию heightForHeaderInSection = 0 (независимо задан ли viewForHeaderInSection)
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 22
	}
	
	
	
	
	
//	override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		// убиваем слушателя базы
//		disposeVar.0.removeObserver(withHandle: disposeVar.1)
		let user = twoD[indexPath.section][indexPath.row]
		
		let messagesController = tabBarController?.viewControllers![0].childViewControllers.first as! MessagesController
		let mess = messagesController.messages
	
		// чиститим непрочит. сообщения от юзера(если таковой был ранее) с которым идем на диалог
		var indexPath:IndexPath? = nil
		for (index, value) in mess.enumerated(){
			if value.chatPartnerID() == user.id {
				indexPath = IndexPath(row: index, section: 0)
				break
			}
		}

		messagesController.savedIndexPath = indexPath
		
		func go(){
			self.tabBarController?.selectedIndex = 0
			messagesController.goToChatWith(user: user)
		}
		
		// деактивируем searchController
		if searchController.searchBar.isFirstResponder || !searchController.searchBar.text!.isEmpty{
			searchController.dismiss(animated: false, completion: {
				go()
			})
		}
		else {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
				go()
			}
		}
		
		

	}
	
	
	
	
	/// алфавитный указатель секций справа
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return letter
	}
	
	
	
	
	

	
	
	
	
	
}


















