//
//  Follow.swift
//  Assesment
//
//  Created by Govindharaj Murugan on 06/01/21.
//

import Foundation

struct Follow: Decodable {
    
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
    
    enum CodingKeys: String, CodingKey {
        case login, id
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
        case type
        case siteAdmin = "site_admin"
    }
}
