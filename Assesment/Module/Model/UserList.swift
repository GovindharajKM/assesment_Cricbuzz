//
//  UserList.swift
//  Assesment
//
//  Created by Govindharaj Murugan on 06/01/21.
//

import Foundation

// MARK: - UserList
struct UserList: Decodable {
    
    var totalCount: Int = 0
    var incompleteResults: Bool = false
    var items: [Item] = [Item]()
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
    
}

// MARK: - Item
struct Item: Codable {
    
    var login = ""
    var id = 0
    var nodeID = ""
    var avatarURL = ""
    var gravatarID = ""
    var url = ""
    var htmlURL = ""
    var followersURL = ""
    var followingURL = ""
    var gistsURL = ""
    var starredURL = ""
    var subscriptionsURL = ""
    var organizationsURL = ""
    var reposURL = ""
    var eventsURL = ""
    var receivedEventsURL = ""
    var type = ""
    var siteAdmin = false
    var score = 0

    enum CodingKeys: String, CodingKey {
        case login = "login"
        case id = "id"
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type = "type"
        case siteAdmin = "site_admin"
        case score = "score"
    }
}

enum TypeEnum: String, Codable {
    case user = "User"
}

