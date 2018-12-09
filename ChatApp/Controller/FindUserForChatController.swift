//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 31.10.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit
import Firebase

class FindUserForChatController: UITableViewController {

	private var cellID = "cellID"
	private var users = [User]()
	public var messagesController:MessagesController?
	private var timer:Timer? // таймер-задержка перезагрузки таблицы
	public var owner:User?
	
	// образец 2-х мерного массива, используемого в этой таблице
	let arr = [
		["Андрей", "Алексей", "Аня"],
		["Боря", "Богдан"],
		["Витя", "Вова", "Владик"]
	]
	private var twoD = [[User]]()
	private var letter = [String]() // массив первых букв юзеров
	private var disposeVar:(DatabaseReference, UInt)!
	
	private var searchBar:UISearchBar = {
		let sb = UISearchBar()
		sb.translatesAutoresizingMaskIntoConstraints = false
		return sb
	}()
	private var searchController:UISearchController!
//	private var fetchResultsController:NSFetchedResultsController
	private var filteredResultArray = [[User]]()
	
	
	
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// section headers не будут прилипать сверху таблицы
		// self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
		
		fetchUsers()
		
		// чтоб до viewDidLoad не отображалась дефолтная таблица
		tableView.tableFooterView = UIView(frame: CGRect.zero)
		tableView.backgroundColor = UIColor.white
		
		navigationItem.title = "Все юзеры"
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Отмена", style: .plain, target: self, action: #selector(onCancelClick))
		searchController = UISearchController(searchResultsController: nil)
		
		tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
		tableView.sectionIndexColor = UIConfig.mainThemeColor
		tableView.separatorColor = UIConfig.mainThemeColor.withAlphaComponent(0.5)
		
		setupSearchBar()
	}
	
		

	
	
	private func setupSearchBar(){
		
		guard #available(iOS 11.0, *) else { return }
		
		navigationItem.searchController = searchController
		navigationItem.hidesSearchBarWhenScrolling = false
		//searchController.searchResultsUpdater = self
		//searchController.searchBar.delegate = self
		
		//отключаем затемнение вьюконтроллера при вводе
		searchController.dimsBackgroundDuringPresentation = false
		
		searchController.searchBar.barTintColor = .white
		searchController.searchBar.tintColor = UIConfig.mainThemeColor
		searchController.searchBar.searchBarStyle = .minimal
		searchController.searchBar.backgroundImage = UIImage()
		searchController.searchBar.backgroundColor = .clear
		// цвет текста в поиске
		// UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIConfig.mainThemeColor]
		
		// цвет кнопки "Отмена" в поисковой строке, а точнее цвет надписи
		UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white], for: .normal)
		
		if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
			if let backgroundview = textfield.subviews.first {
				// Background color
				backgroundview.backgroundColor = UIColor.white
				// Rounded corner
				backgroundview.layer.cornerRadius = 12
				backgroundview.clipsToBounds = true
			}
		}
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
	private func prepareData(){
		
		// иногда сюда может зайти несколько раз, потому нужно чистить
		letter.removeAll()
		twoD.removeAll()
		
		// убираем себя из массива
		users = users.filter { // нужно возвратить то, что должно остатся
			(user) -> Bool in
			return user.name != owner?.name
		}
		
		// создаем массив букв (без повтора)
		for value in users {
			let char = value.name?.prefix(1).uppercased()
			if !letter.contains(char!){
				letter.append(char!)
				twoD.append([])
			}
			letter.sort()
		}
		
		// заполняем массив массивов юзеров, согласно алфавита
		for value in users {
			let char = value.name?.prefix(1).uppercased()
			let index = letter.index(of: char!)
			twoD[index!].append(value)
		}
		
		// сортируем элементы каждого внутреннего массива
		var newArr = [[User]]()
		for var value in twoD {
			// value.sort{$0.lowercased() < $1.lowercased()}
			value.sort{($0.name)!.localizedCaseInsensitiveCompare($1.name!) == .orderedAscending}
			
			newArr.append(value)
		}
		twoD = newArr
	}
	
	
	

	
	private func attemptReloadofTable(){
		timer?.invalidate()
		timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.delayedRelodTable), userInfo: nil, repeats: false)
	}
	/// (без этого таблица перезагружается десятки раз)
	@objc private func delayedRelodTable(){
		users.sort{$0.email!.localizedCaseInsensitiveCompare($1.email!) == .orderedAscending}
		DispatchQueue.main.async {
			self.prepareData()
			self.tableView.reloadData()
		}
	}
	
	
	
	@objc private func onCancelClick(){
		disposeVar.0.removeObserver(withHandle: disposeVar.1)
		disposeVar = nil
		dismiss(animated: true, completion: nil)
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
		
		
//		cell.iTag = ((indexPath.section).description + (indexPath.row).description) // для идентификации ячейки в кложере
//		let basePath = cell.iTag

		if let profileImageUrl = user.profileImageUrl{
			// качаем картинку
			cell.profileImageView.loadImageUsingCache(urlString: profileImageUrl){
				(image) in
				// перед тем как присвоить ячейке скачанную картинку, нужно убедиться, что она видима (в границах экрана)
				// и обновить ее в главном потоке
				DispatchQueue.main.async {
//					if cell.iTag == basePath{
						cell.profileImageView.image = image
//					}
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
	
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if searchController.isActive{
			return
		}
		
		// убиваем слушателя базы
		disposeVar.0.removeObserver(withHandle: disposeVar.1)
		
		dismiss(animated: true) {
			// дожидаемся окончания убивания этого контроллера и в контроллере-родителе запускаем ф-цию goToChat()
			let user = self.twoD[indexPath.section][indexPath.row]
			
			// чиститим непрочит. сообщения от юзера(если таковой был ранее) с которым идем на диалог
			var indexPath:IndexPath? = nil
			for (index, value) in self.messagesController!.messages.enumerated(){
				if value.chatPartnerID() == user.id {
					indexPath = IndexPath(row: index, section: 0)
					break
				}
			}
			self.messagesController?.savedIndexPath = indexPath
			
			self.messagesController?.goToChatWith(user: user)
		}
	}
	
	
	/// алфавитный указатель секций справа
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return letter
	}
	
	
	
	
	

	
	
	
	
	
}


















