# heroku-deploy

## Introduction

TODO

## Installation and Usage

You need the heroku-cli installed before you can use this plugin.

```bash
heroku plugins:install git://github.com/envato/heroku-deploy.git
heroku deploy
```

## Development

```bash
git clone git@github.com:envato/heroku-deploy.git

mkdir -p ~/.heroku/plugins
cd ~/.heroku/plugins
ln -s ~/path/to/heroku-deploy heroku-deploy
```

This should allow you to test the plugin and use it locally.

## Contributing

We encourage all community contributions. Keeping this in mind, please follow these general guidelines when contributing:

* Fork the project
* Create a topic branch for what you’re working on (git checkout -b awesome_feature)
* Commit away, push that up (git push your\_remote awesome\_feature)
* Create a new GitHub Issue with the commit, asking for review. Alternatively, send a pull request with details of what you added.

## License

heroku-deploy is released under the MIT License (see the [license file](https://github.com/envato/heroku-deploy/blob/master/LICENCE)) and is copyright Envato & Keith Pitt, 2013.
