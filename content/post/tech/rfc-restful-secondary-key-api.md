---
title: RFC Restful Secondary Key API
slug: rfc-restful-secondary-key-api
date: 2022-08-08T22:12:21Z
lastMod: 2022-08-08T22:12:21Z
description: A RESTful API design conundrum and a proposed solution.
tags: [REST, API, Secondary Key, RFC]
type: post
---

I've been working on a simple CRUD API at [work], with an eye to make a
nicely-designed REST interface for managing a single type of resource. It's not
a complicated API, following best practices recommended by [Apigee] and
[Microsoft]. It features exactly the sorts for APIs you'd expect if you're
familiar with REST, including:

*   `POST /users`: Create a new user resource
*   `GET /users/{uid}`: Read a user resource
*   `PUT /users/{uid}`: Update a user resource
*   `DELETE /users/{uid}`: Delete a user resource
*   `GET /users?{params}`: Search for user resources

If you're familiar with REST, you get the idea.

There is one requirement that proved a bit of design challenge. We will be
creating canonical ID for all resources managed by the service, which will
function as the primary key. The APIs above reference that key by the `{uid}`
path variable. However, we also need to support fetching a single resource by a
number of existing identifiers, including multiple legacy IDs, and natural keys
like, sticking to the users example, usernames and email addresses. Unlike the
search API, which returns an array of resources, we need a nice single API like
`GET /users/{uid}` that returns a single resource, but for a secondary key. What
should it look like?

None of my initial proposals were great (using `username` as the sample
secondary key, though again, we need to support a bunch of these):

*   `GET /users?username={username}` --- consistent with search, but does it
    return a collection like search or just a single entry like `GET
    /users/{uid}`? Would be weird not to return an array or not based on which
    parameters were used.
*   `GET /users/by/username/{username}` --- bit weird to put a preposition in
    the URL. Besides, it might conflict with a planned API to fetch subsets of
    info for a single resource, e.g., `GET /users/{uid}/profile`, which might
    return just the profile object.
*   `GET /user?username={username}` --- Too subtle to have the singular rather
    than plural, but perhaps the most REST-ish.
*   `GET /lookup?obj=user&username={username}` Use special verb, not very
    RESTful

I asked around a coding Slack, posting a few possibilities, and friendly API
designers suggested some others. We agreed it was an interesting problem, easily
solved if there was just one alternate that never conflicts with the primary key
ID, such as `GET /users/{uid || username}`. But of course that's not the problem
we have: there are a bunch of these fields, and they may well overlap!

There was some interest in `GET /users/by/username/{username}` as an
aesthetically-pleasing URL, plus it allows for

*   `/by` => list of unique fields
*   `/by/username/` => list of all usernames?

But again, it runs up against the planned use of subdirectories to return
sub-objects of a resource. One other I played around with was: `GET
/users/user?username={username}`: The `user` sub-path indicates we want just one
user much more than `/by` does, and it's unlikely we'd ever use `user` to name
an object in a user resource. But still, it overloads the path to mean one thing
when it's `user` and another when it's a UID.

Looking back through the options, I realized that what we *really* want is an
API that is identical to `GET /users/{uid}` in its behaviors and response, just
with a different key. So what if we just keep using that, as originally
suggested by a colleague as `GET /users/{uid || username}` but instead of just
the raw value, we encode the key name in the URL. Turns out, colons (`:`) are
valid in paths, so I defined this route:

*   `GET /users/{key}:{value}`: Fetch a single resource by looking up the
    `{key}` with the `{value}`. Supported `{key}` params are `legacy_id`,
    `username`, `email_address`, and even `uid`. This then becomes the canonical
    "look up a user resource by an ID" API.

The nice thing about this API is that it's consistent: all keys are treated the
same, as long as no key name contains a colon. Best of all, we can keep the
original `GET /users/{uid}` API around as an alias for `GET /users/uid:{value}`.
Or, better, continue to refer to it as the canonical path, since the `PUT` and
`DELETE` actions map only to it, and document the `GET /users/{key}:{value}` API
as accessing an alias for symlink for `GET /users/{uid}`. Perhaps return a
`Location` header to the canonical URL, too?

In any event, as far as I can tell this is a unique design, so maybe it's too
weird or not properly RESTful? Would love to know of any other patterns designed
to solve the problem of supporting arbitrarily-named secondary unique keys.
What do you think?

  [work]: https://nytimes.com "The New York Times"
  [Apigee]: https://pages.apigee.com/rs/apigee/images/api-design-ebook-2012-03.pdf
    "Web API Design: Crafting Interfaces that Developers Love"
  [Microsoft]: https://docs.microsoft.com/en-us/azure/architecture/best-practices/api-design
    "Azure Docs: “RESTful web API design”"
