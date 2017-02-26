//
//  UserModelSpec.swift
//  Octowire
//
//  Created by Mart Roosmaa on 26/02/2017.
//  Copyright © 2017 Mart Roosmaa. All rights reserved.
//

import Foundation
import Quick
import Nimble
import ObjectMapper
@testable import Octowire

class UserModelSpec: QuickSpec {
    override func spec() {
        it("parses json") {
            let rawJson = "{\u{22}login\u{22}: \u{22}octocat\u{22}, \u{22}id\u{22}: 583231, \u{22}avatar_url\u{22}: \u{22}https://avatars.githubusercontent.com/u/583231?v=3\u{22}, \u{22}gravatar_id\u{22}: \u{22}\u{22}, \u{22}url\u{22}: \u{22}https://api.github.com/users/octocat\u{22}, \u{22}html_url\u{22}: \u{22}https://github.com/octocat\u{22}, \u{22}followers_url\u{22}: \u{22}https://api.github.com/users/octocat/followers\u{22}, \u{22}following_url\u{22}: \u{22}https://api.github.com/users/octocat/following{/other_user}\u{22}, \u{22}gists_url\u{22}: \u{22}https://api.github.com/users/octocat/gists{/gist_id}\u{22}, \u{22}starred_url\u{22}: \u{22}https://api.github.com/users/octocat/starred{/owner}{/repo}\u{22}, \u{22}subscriptions_url\u{22}: \u{22}https://api.github.com/users/octocat/subscriptions\u{22}, \u{22}organizations_url\u{22}: \u{22}https://api.github.com/users/octocat/orgs\u{22}, \u{22}repos_url\u{22}: \u{22}https://api.github.com/users/octocat/repos\u{22}, \u{22}events_url\u{22}: \u{22}https://api.github.com/users/octocat/events{/privacy}\u{22}, \u{22}received_events_url\u{22}: \u{22}https://api.github.com/users/octocat/received_events\u{22}, \u{22}type\u{22}: \u{22}User\u{22}, \u{22}site_admin\u{22}: false, \u{22}name\u{22}: \u{22}The Octocat\u{22}, \u{22}company\u{22}: \u{22}GitHub\u{22}, \u{22}blog\u{22}: \u{22}http://www.github.com/blog\u{22}, \u{22}location\u{22}: \u{22}San Francisco\u{22}, \u{22}email\u{22}: \u{22}octocat@github.com\u{22}, \u{22}hireable\u{22}: null, \u{22}bio\u{22}: null, \u{22}public_repos\u{22}: 7, \u{22}public_gists\u{22}: 8, \u{22}followers\u{22}: 1739, \u{22}following\u{22}: 6, \u{22}created_at\u{22}: \u{22}2011-01-25T18:44:36Z\u{22}, \u{22}updated_at\u{22}: \u{22}2017-02-23T05:44:30Z\u{22}}"

            let user = UserModel(JSONString: rawJson)
            expect(user).toNot(beNil())
            expect(user?.id).to(equal(583231))
            expect(user?.username).to(equal("octocat"))
            expect(user?.avatarUrl).to(equal("https://avatars.githubusercontent.com/u/583231?v=3"))
            expect(user?.name).to(equal("The Octocat"))
            expect(user?.bio).to(beNil())
            expect(user?.location).to(equal("San Francisco"))
            expect(user?.email).to(equal("octocat@github.com"))
            expect(user?.website).to(equal("http://www.github.com/blog"))
        }
    }
}
