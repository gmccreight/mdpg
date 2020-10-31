[![Build Status](https://travis-ci.org/gmccreight/mdpg.png?branch=master)](
https://travis-ci.org/gmccreight/mdpg
)
[![Coverage Status](https://coveralls.io/repos/gmccreight/mdpg/badge.png)](
https://coveralls.io/r/gmccreight/mdpg
)

MDPG is a web-based note-taking application.  It's also a good excuse to try
out a lot of ideas.

# Design Goals

## Speed

### Fast Tests

First and foremost, I want the tests to run extremely quickly.  Even the
integration tests.  This is the primary design goal; all else is secondary.
If the tests take more than a second to run on a top-of-the-line computer,
then we're not meeting our goal.

As of this writing (Oct 2020), the tests run in 0.7 seconds on my Macbook
Pro.  There are 440 assertions, many of which are high-level in Rack::Test.

### Fast Deploys

I also want to be able to deploy in less than a second.  This is, again, all
about lowering the barrier to making changes in the system.  If I can run
all the tests and deploy in two seconds, I'm likely to do it often.

As of this writing (Oct 2020) it takes less than a second to deploy to
production.

## Readily Refactorable

A secondary, but also critically important, goal is that the codebase be
ready-to-refactor at all times.  I guess this means aiming for 100% test
coverage, but I'm not going to be pedantic about it.  Basically, the point of
this goal is that I can't often get several hours of hacking time set aside,
but I can get a half hour here and there.  I want the code to facilitate
making very quick changes and refactorings.

In his book, "The Clean Coder", Uncle Bob Martin says:

"TDD is another big help. I you have a failing test, that test holds the
context of where you are. You can return to it after an interruption and
continue to make that failing test pass."

## Fun!

This can't be overstated.  Nobody's paying me to work on this, so it had
better be gosh-darn fun!

## Installation

I'm going to try to get all of this done with Ruby 2 core and Sinatra.  We'll
see how that goes.

### Installation - Karma

In order to run the full suite of tests, you will need to have `karma`
installed (including support for CoffeeScript)

    npm install karma -g
    npm install karma-jasmine@0.1.6 -g
    npm install karma-phantomjs-launcher -g
    npm install karma-coffee-preprocessor -g

## Quick backup

One of my takeaways from pageoftext.com is that the data model made it very
easy to quickly back up the site, even as the data grew large.  It's very easy
to rsync gigs of data as long as it is split up nicely.  This project goes
even further than pageoftext.com in that direction, using the same object
directory model as git.  That model uses a cryptographically solid hash
function, SHA-1, to get a very even key distribution, then uses the first two
characters of the 40 hex character code as the directory name.  In other
words, the data will be nicely distributed into a large number of buckets.
Unlike git, however, the objects are not content-addressible, rather the hash
is a hash of the data's key.

Another nice side-effect of the quick backup is that it makes it easy to
quickly load the production data into the development environment.  As of this
writing (Oct 2020) it takes about 10 seconds to load the incremental changes
to the > 110,000 files of production data into the development environment.

The command to run the sync of production data to development is:

    rake sync

There is also another, similar, command which will get you a local copy of
production data, but will also preserve a timestamped version of your
pre-existing development data:

    rake copy

## Relatively easy to reason about the datastore

Since this thing is highly experimental, it's possible that the quickest way
of migrating the datastore will be to actually run macros on the datastore
files themselves.  Their format and structure should facilitate that.

## Runs on a cheap machine

It should be able to run great on a $5-6/mo cloud machine.

## Collaboration

### The public at large

Sometimes you want to share something with people that you don't want to have
to have sign up for the site.

#### Easy-to-remember URLs

The best way to share is an easy-to-remember URL (like on pageoftext.com)

#### Obviously unguessable URLs

If you really want to force people to type in something long, you can use this
option, too.

## Very flexible tagging

### Tag renaming

Sometimes you had the wrong name for a concept, or your understanding of a
concept is emerging over time.  Wouldn't it be great to be able to rename tags
in bulk?  Only some tags?  Etc.

### Tag searching

It would be great to be able to search for tags and see their surrounding
context.

### Tag relationships

Is a tag really closely related to another tag?  How about creating a
relationship between them and specifying the strength of the relationship.

### Tag creation (typo reduction and canonicalization)

When creating a tag, you should suggest tags that have a similar name to the
one you are currently filling in (and also, you should show related tags)

Canonicalization serves to help define a tag ontology.  Outliers and one-offs
are specifically flagged and made obvious.

---

# Learning Goals

## Markdown

Part of the reason for this site using markdown is that I'd like be become
fluent in it.

## Sinatra

I've always wanted to have a project where Sinatra makes sense.  I think this
is one.

## Ruby 2

I'm actively looking for new features and functionality from Ruby 2 to use
in the code.  I'll highlight them with the [tag:ruby2:gem] tag.  I also want
to see what kind of performance I can get with it.

## Minitest

I wanted to see what all the fuss is about, so we're using it instead
of rspec.

## Angular

I need some SPA islands in the pages, and Angular is very testable, so it
seems like a good fit.

## Gaining a better understanding of what to test and how much to test

Nuf' said

## Interface design

I'd like to try the analogous thing to having piles of paper on your desk.
So, piles of pages where piling by creation date and modification date.

Also, I wonder if there's merit in having a page with a huge number of things
directly in the page.

---

# Coding conventions

## Keyword Arguments

I'm using these in some places to try them out, and to see how verbose they
feel.

---

# Documentation

To run on an actual production system, you can use:
mdpg_production=1 ./bin/run_server

Ideally, you'd proxy it behind a *real* webserver
