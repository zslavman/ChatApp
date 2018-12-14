//
//  Locales.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 11.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import Foundation


// global scope
var LANG:Int!

let dict:[Int:[String]] = [
	0:["Звук", "Incoming sound", "Son entrant"],
	1:["Вибрация", "Use vibro", "Utilisez vibro"],
	2:["Сообщений:", "Messages:", "Messages:"],
	3:["Язык", "Language", "La langue"],
	4:["О приложении", "About", "A propos de l'application"],
	5:["Новое сообщение", "New message", "Nouveau message"],
	6:["Воспроизведение звука/вибро при получении нового сообщения",
	   "Play sound/vibro on incoming",
	   "Jouer le son / vibrer sur entrant"],
	7:["Оптимизация", "Optimization", "Optimisation"],
	8:["Макс. кол-во подгружаемых с сервера сообщений при открытии диалога",
	   "Max preloaded messages on dialog opening",
	   "Max messages préchargés à l'ouverture de la boîte de dialogue"],
	9:["Разное", "Miscellaneous", "Divers"],
	10:["Русский", "English", "Française"], // тут не должно быть пустых ячеек
	11:["Войти", "Login", "S'identifier"],
	12:["Выйти", "Logout", "Connectez - Out"],
	13:["Выйти из аккаунта", "Account logout", "Déconnexion du compte"],
	14:["Язык приложения", "Application language", "Langue d'application"],
	15:["Чаты", "Chats", "Chats"],
	16:["Контакты", "Contacts", "Contacts"],
	17:["Настройки", "Settings", "Réglages"],
	18:["Поиск", "Search", "Chercher"],
	19:["Отмена", "Cancel", "Annuler"],
	20:["Назад", "Back", "Retour"],
	21:["Aa"], // 1
	22:["вчера", "yesterday", "hier"],
	23:["сегодня", "today", "aujourd'hui"],
	24:["ru_US", "en_US", "fr_US"], // локаль dateFormatter
	25:["Регистр.", "Register", "Enregistrement"],
	26:["Пароль", "Password", "Mot de passe"],
	27:["Имя", "Name", "Prénom"],
	28:["Обнаружены незаполненные поля, все поля обязательные для регистрации!",
		"Empty field(s) detected. All fields are required!",
		"Champs vides détectés. Tous les champs sont requis!"],
	29:["[видео]", "[video]", "[vidéo]"],
	30:["[картинка]", "[picture]", "[image]"],
	31:["Загрузка...", "Loading...", "Chargement..."],
	32:["Нет сообщений", "No messages", "Pas de messages"],
	33:["Нет результатов", "No results", "Aucun résultat"],
	34:["Выберите другое видео (не более 10 МБ), или сократите его длительность",
		"Choose another video (no more than 10 MB), or shorten duration",
		"Choisissez une autre vidéo (pas plus de 10 Mb), ou raccourcissez la durée"],
	35:["Слишком большой файл", "File too large", "Fichier trop large"],
	36:["Для использования этой функции необходимо разрешить использование геолокации в настройках",
		"To use this feature, you have to enable geolocation in the settings",
		"Pour utiliser cette fonctionnalité, vous devez activer la géolocalisation dans les paramètres"],
	37:["Включите геолокацию", "Turn on geolocation", "Activer la géolocalisation"],
	38:["OK", "OK", "OK"],
	39:["© 2018 ChatApp все права защищены",
		"© 2018 ChatApp All rights reserved",
		"© 2018 ChatApp Tous les droits sont réservés"],
	40:["Разработка и поддержка:\n", "Development and support:\n", "Développement et support:\n"],
	41:["ChatApp"], 			// 1
	42:[" v1.0"], 				// 1
	44:["zslavman@gmail.com"], 	// 1
	43:["ChatApp проблема", "ChatApp issue", "ChatApp problème"],
	45:["Не удалось отправить письмо", "Failed to send email", "Impossible d'envoyer un email"],
	46:["Вячеслав Зинько", "Viacheslav Zinko", "Viacheslav Zinko"],
	47:["Привет, Вячеслав \n \n[~опишите свою проблему здесь~]",
		"Hi Viacheslav, \n \n[~describe problem here~]",
		"Bonjour, Viacheslav \n \n[~décrire le problème ici~]"],
	48:["", "", ""],
	49:["", "", ""],
	50:["", "", ""],
	51:["", "", ""],
	52:["", "", ""],
	53:["", "", ""],

]



class Locales {
	
}








