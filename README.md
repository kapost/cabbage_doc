CabbageDoc
==========
A lean and mean *interactive API* documentation generator and validator.

Getting Started
---------------
CabbageDoc has been designed from the ground-up to be easy to configure and use.

Start by adding the gem to your `Gemfile`.

```
gem 'cabbage_doc'
```

#### Configuration
Before using CabbageDoc, it is necessary to configure a couple of basic settings.

```ruby
CabbageDoc.configure do |config|
  config.root = Rails.root.join('doc')

  config.domain = 'example.com'

  config.authenticate = proc do |auth, request|
    auth.type = :basic
    auth.username = request.params[:username]
    auth.password = request.params[:password]
    auth.configurable = [:username, :password]
  end

  config.controllers = proc do
    Dir.glob(Rails.root.join('app', 'controllers', 'api', 'v1', '*.rb')).sort
  end

  config.title = "Developer Documentation"
  config.welcome = <<-WELCOME
  Developer Documentation
  =======================
  Awesome developer documentation.
WELCOME
end
```

#### Task
Create a new `.rake` file in your project, usually within `lib/tasks` and add the following line:

```ruby
CabbageDoc::Task.define do |config|
  config.name = :cabbagedoc
end
```

Run `rake -T` to see the newly defined rake tasks.

#### Web
The default UI is a mountable Sinatra application. It's perfectly fine to mount
it within a Rails application, namely `config/routes.rb`.

```ruby
mount CabbageDoc::Web, at: '/docs'
```

If you don't want your documentation to be public, fear not, CabbageDoc got you covered:

```ruby
CabbageDoc::Web.use(Rack::Auth::Basic) do |username, password|
  username == 'cabbage' && password == 'doc'
end
```

If you do not fancy the default UI, you can customize it to suit your own needs.

In order to do that, you will have to run the `customize` rake task.

```bash
rake cabbagedoc:customize
```

This will copy the internal `web` directory into the `root` directory you configured in your
initializer.

When this alternate `web` directory exists, CabbageDoc will use it, instead of the internal `web` directory.

How to document?
----------------
CabbageDoc uses a simple and readable *structured comment style* inspired by [Tomdoc](http://tomdoc.org/).

```ruby
class ResourcesController # :cabbagedoc:
  # Public: List
  #
  # GET: /resources
  #
  # Parameters:
  #   detail (Enumeration) - level of detail (default: basic, values: full|basic)
  #   per_page (Numeric) - resources per page (default: 25)
  #   categories (Array) - filter by categories
  #   search (String) - filter by search string
  def index # :cabbagedoc:
  end

  # Public: Show
  #
  # GET: /resources/:id
  #
  # Parameters:
  #   id (String) [required] - resource id
  #   detail (Enumeration) - level of detail (default: basic, values: full|basic)
  def show # :cabbagedoc:
  end

  # Public: Create
  #
  # POST: /resources
  #
  # Parameters:
  #   title (String) [required] - resource title
  #   text (String) - resource text
  def create # :cabbagedoc:
  end

  # Public: Update
  #
  # PUT: /resources/:id
  #
  # Parameters:
  #   id (String) [required] - resource id
  #   title (String) - resource title
  #   text (String) - resource text
  def update # :cabbagedoc:
  end

  # Public: Delete
  #
  # DELETE: /resources/:id
  #
  # Parameters:
  #   id (String) [required] - resource id
  def destroy # :cabbagedoc:
  end
end
```

By running `rake cabbagedoc`, CabbageDoc parses all comments and generates
the necessary metadata which is then used to render the documentation.

What's Missing
--------------
The following *features* have not been implemented yet:

- generating contracts from *examples* via [Pacto](https://github.com/thoughtworks/pacto)
- generating specs (rspec) from *examples* which are then validated via [Pacto](https://github.com/thoughtworks/pacto)

Also, at this very moment there are no `specs` :(.

Contribute
----------
- Fork the project.
- Make your feature addition or bug fix.
- Do **not** bump the version number.
- Send me a pull request. Bonus points for topic branches.

License
-------
CabbageDoc is provided **as-is** under the **MIT** license.
For more information see LICENSE.
