//
//  Action.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation

enum ActOfKindness: String, CaseIterable {
    case messageFriend = "Send a message to a friend asking how they are doing"
    case contactFamily = "Send a kind thought to a family member"
    case donateToCharity = "Send some money to your favorite charity"
    case volunteer = "Volunteer at local homeless shelter"
    case giveGifts = "Give gifts to local orphanage"
    case payItForward = "Pay for next person in line"
}

