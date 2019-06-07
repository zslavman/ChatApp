//
//  MultiThreading.swift
//  ChatApp
//
//  Created by Zinko Vyacheslav on 28.12.2018.
//  Copyright © 2018 Zinko Vyacheslav. All rights reserved.
//

import UIKit


class MultiThreading {
	
	// выполнение задачи в другом потоке (serial/concurrent)
	public func setTaskInGlobalQueue(){
		let queue = DispatchQueue.global(qos: .userInitiated)
		//		let queue = DispatchQueue(label: "setTaskInGlobalQueue", qos: .userInitiated, attributes: .concurrent)
		
		let closure = DispatchWorkItem {
			print("Кетура ...")
			print(Thread.current)
			Thread.sleep(forTimeInterval: 3.0)
		}
		// по завершению задания выше выполнить блок в главном потоке
		closure.notify(queue: .main) {
			print("Задание завершено!")
		}
		queue.async(execute: closure)
	}
	
	
	// семафор в действии
	public func semaphoreRun(){
		
		let semaphore = DispatchSemaphore(value: 2) // кол-во потоков
		// для симафора всегда нужно использовать .concurrent очередь, иначе в нем нет смысла
		let queue = DispatchQueue(label: "f1", attributes: .concurrent)
		
		queue.async {
			semaphore.wait() // value -= 1
			print("run block = 1")
			Thread.sleep(forTimeInterval: 1)
			semaphore.signal() // value += 1
		}
		queue.async {
			semaphore.wait()
			print("run block = 2")
			Thread.sleep(forTimeInterval: 1)
			semaphore.signal()
		}
		queue.async {
			semaphore.wait()
			print("run block = 3")
			Thread.sleep(forTimeInterval: 1)
			semaphore.signal()
		}
		queue.async {
			semaphore.wait()
			print("run block = 4")
			Thread.sleep(forTimeInterval: 1)
			semaphore.signal()
		}
	}
	
	
	
	// барьер в действии
	public func concurrentIterations(){
		
		var tempArray = [Int]()
		let queue = DispatchQueue(label: "f2", attributes: .concurrent)
		let iterCount = 10
		
		DispatchQueue.concurrentPerform(iterations: iterCount) {
			(index) in
			//print("Thread = \(Thread.current)")
			let core = Thread.current
			
			appendix(arg: index, core: core)
		}
		
		func appendix(arg:Int, core:Thread){
			// для избежания Race condition, устанавливаем барьер (аля уникальный доступ к замыканию)
			// каждый поток, сможет перазаписать массив лишь когда предыдущий закончит
			// если массив будет занят, поток сделает это сразу как массив освободится (справедливо, лишь если всё делается с единого потока, иначе массив запишут лишь те потоки которые не будут отвергнуты)
			queue.async(flags: .barrier) {
			// queue.async { // так будет ошибка Race condition
				tempArray.append(arg)
				 // Thread.sleep(forTimeInterval: 0.1)
//				 print("Thread = \(Thread.current)")
			}
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
			print("tempArray = \(tempArray.sorted()) count = \(tempArray.count)")
		}
		// выполнится только после асинхронных, т.е. в конце (но это тормозит основной интерфейс)
		//		queue.sync {
		//			print("tempArray = \(tempArray.sorted()) count = \(tempArray.count)")
		//		}
		
	}
	

	public func opearationsQueue(){
//		let queue = BlockOperation()
//		queue.addExecutionBlock { // выполняется в неосновной очереди
//			print("Mark 1")
//			Thread.sleep(forTimeInterval: 1)
//		}
//		queue.addExecutionBlock {
//			print("Mark 2")
//			Thread.sleep(forTimeInterval: 2)
//		}
//		queue.completionBlock = { // сработает так же не в основной очереди, отличной от очереди выполнения блоков
//			print("Thread = \(Thread.current)")
//		}
//		queue.start()
		
		//******************
		
		let operationQueue = OperationQueue()
		operationQueue.addOperation {
			sleep(1)
			print("Mark 1")
			print("Thread = \(Thread.current)")
		}
		operationQueue.addOperation {
			sleep(2)
			print("Mark 2")
			print("Thread = \(Thread.current)")
		}
		// барьер
		operationQueue.waitUntilAllOperationsAreFinished()
		
		operationQueue.addOperation {
			print("Mark 3")
		}
		operationQueue.addOperation {
			print("Mark 4")
		}
		
	}
		
}
































