//
//  ProfileViewController.swift
//  Bobber
//
//  Created by Aryan Ghassemi on 3/22/15.
//  Copyright (c) 2015 aryaxt. All rights reserved.
//

public class ProfileViewController: BaseViewController {
	
	@IBOutlet private var nameLabel: UILabel!
	@IBOutlet private var userImageView: UIImageView!
	@IBOutlet private var addFriendButton: UIButton!
	@IBOutlet private var blockUserButton: UIButton!
	public var user: User!
	private lazy var friendService = FriendService()
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		
		title = user.firstName
	}
	
	
	@IBAction func addFriendSelected() {
		friendService.sendFriendRequest(user) { error in
			
		}
	}
}
