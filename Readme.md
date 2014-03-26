# heroku-deploy

It's better than `git push`

## Introduction

TODO

I haven't written the introduction and proper usage stuff yet, sorry. I was roped into doing a presentation at Rails Meetup at the last minute, and I open sourced this thing quickly. So if you want to know more, poke @keithpitt on Twitter and Github!

## Installation and Usage

You need the heroku-cli installed before you can use this plugin.

```bash
heroku plugins:install git://github.com/envato/heroku-deploy.git
heroku deploy
```

Because we don't do asset compliation on Heroku anymore, we can easily remove the
asset group from being bundled, giving us a nice speed boost.

```bash
heroku config:add BUNDLE_WITHOUT="development:test:assets"
```


## Migrations

By default any safe migrations will run without any downtime. So adding a new
column/table/index. If a migration file contains an unsafe keyword
`remove_column`, `execute` as examples, a maintenance page will be used for a
downtime deploy. If you would like to prevent this behavior, then you can add a
`# safe` comment on the destructive line. This allows a zero downtime deploy
even with destructive operations.

## Development

```bash
git clone git@github.com:envato/heroku-deploy.git

mkdir -p ~/.heroku/plugins
cd ~/.heroku/plugins
ln -s ~/path/to/heroku-deploy heroku-deploy
```

This should allow you to test the plugin and use it locally.


## Testing

The tests can be run with `rspec spec`

## Contributing

We encourage all community contributions. Keeping this in mind, please follow these general guidelines when contributing:

* Fork the project
* Create a topic branch for what you’re working on (git checkout -b awesome_feature)
* Commit away, push that up (git push your\_remote awesome\_feature)
* Create a new GitHub Issue with the commit, asking for review. Alternatively, send a pull request with details of what you added.

## License

heroku-deploy is released under the MIT License (see the [license file](https://github.com/envato/heroku-deploy/blob/master/LICENCE)) and is copyright Envato & Keith Pitt, 2013.
