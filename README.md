CabbageDoc
==========
A lean and mean *interactive API* documentation generator.

![Screenshot](cabbage_doc.png)

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

  config.authentication = proc do |auth, request|
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

By default, the documentation used by the UI is regenerated only by running the *documentation generation* rake task.

This behavior can be changed by setting the `dev` property to `true` in the configuration block.

```ruby
CabbageDoc.configure do |config|
  config.dev = Rails.env.development?
end
```

When *dev* is set to *true*, the documentation will be regenerated on each request.

#### Customize
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
# Public: Resources
#
# PATH: /resources
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

It is also possible to add a longer description like so:

```ruby
# Public: Delete
#
# DELETE: /resources/:id
#
# Description: Deletes a resource.
#
# Parameters:
#   id (String) [required] - resource id
def destroy # :cabbagedoc:
end
```

Multline descriptions are also possible:

```ruby
# Public: Delete
#
# DELETE: /resources/:id
#
# Description:
#   Deletes a resource.
#   And it also does something magical.
#
# Parameters:
#   id (String) [required] - resource id
def destroy # :cabbagedoc:
end
```

The `description` is processed via Markdown.

#### Parameters

Parameters in the URL (path components) should be prefixed
with a *:* and then added to the list of parameters.

CabbageDoc is smart enough to detect this and make the
necessary substitutions when interacting wit the action
in question.

```ruby
# Public: Delete
#
# DELETE: /resources/:parent_id/comments/:id
#
# Parameters:
#   parent_id (String) [required] - parent resource id
#   id (String) [required] - id
def destroy # :cabbagedoc:
end
```

These *parameters* should be marked as required.

Here is a list of all `parameter` types:

- Number
- Numeric
- Decimal
- Integer
- String
- Id
- Enumeration
- Array
- Hash
- Date
- Time
- Timestamp

An `Enumeration` represents a finite number of choices (think of it as a select box).

```ruby
# detail (Enumeration) - level of detail (default: basic, values: full|basic)
```

The values are separated by `|` and it is possible to provide a default value.

If there is no default value, then `nothing` will be selected by default. However if the
parameter in question is required, a default value **MUST** be provided.

An `Array` represents a flat array of values and a `Hash` a group of key-value pairs.

Nested `hashes` are not supported at this point in time.

#### Visibility
In the examples above, we used the default `Public` visibility. Here is a list of all
visibility options.

- Public
- Private
- Internal
- Beta
- Unreleased

By default only controllers and actions `marked` as `Public` will show up in the generated
documentation.

You can turn on additional visibility options in the initializer like so:

```ruby
config.authentication = proc do |auth, request|
  auth.visibility += [:private, :internal, :beta, :unreleased]
end
```

`Beta` and `Unreleased` visibility will display a "warning" on each `marked` action.

![Screenshot](cabbage_doc_warning.png)

#### Examples
It is also possible to provide examples for each action.

```ruby
# Examples:
#   Example One - (detail: basic)
```

![Screenshot](cabbage_doc_example.png)

#### Templates
Often times it is needed to *document* a so called *subresource* which can be
*mounted* under a number of *parent resources*.

To enable this, CabbageDoc offers *templates*. Templates can be inline or global.

##### Inline Templates
Inline templates are useful when there is a subresource which is specific to a
given application and will only live within the context of that application.

```ruby
# Public: {Post,Ideas} Resource
#
# PATH: /{posts,ideas}/:{post,idea}_id/resources
class ResourcesController # :cabbagedoc:
  # Public: List
  #
  # GET: /{posts,ideas}/:{post,idea}_id/resources
  #
  # Parameters:
  #   {post,idea}_id - {post,idea} ID
  #   detail (Enumeration) - level of detail (default: basic, values: full|basic)
  #   per_page (Numeric) - resources per page (default: 25)
  #   categories (Array) - filter by categories
  #   search (String) - filter by search string
  def index # :cabbagedoc:
  end
end
```

When CabbageDoc will process this, it will detect it uses inline templates and will
generate two *copies* with the template values substituted.

Why two? Because each *template string* has two values, separated by *,*.

##### Global Templates
Global templates are useful when there is a subresource that lives outside the
context of a single application and will most likely be *mounted* within multiple
applications.

The prime example of this would be a *Rails Engine*.

In this case, it is not desirable to litter the documentation with specific
terminology, because the *engine* could be mounted in several applications.

This is where global templates come into play, by allowing us to use generic
templates and then provide specific *values* in the CabbageDoc configuration.

```ruby
  config.tags = %i[main_app secondary_app]
  config.controllers = proc
  {
    main_app: CabbageDoc.glob([
          ['..', 'main_app', 'app', 'controllers', 'api', 'v1', '*.rb'],
          ['..', 'racl', 'app', 'controllers', 'api', 'v1', '*.rb']
    ]),
    secondary_app: CabbageDoc.glob([
          ['..', 'secondary_app', 'app', 'controllers', 'api', 'v1', '*.rb'],
          ['..', 'racl', 'app', 'controllers', 'api', 'v1', '*.rb']
    ])
  }
```

The *engine* called *racl* is sourced into both apps as shown above.

```ruby
# Public: {racl:collection} Resource
#
# PATH: /{racl:root}/{racl:resource}/:{racl:resource_id}/resources
module Racl
  class Resource # :cabbagedoc:
    # Public: List {racl:resource}
    #
    # GET: /{racl:root}/{racl:resource}/:{racl:resource_id}/resources
    #
    # Parameters:
    #   {racl:resource_id} - {racl:resource_name} ID
    #   detail (Enumeration) - level of detail (default: basic, values: full|basic)
    #   per_page (Numeric) - resources per page (default: 25)
    #   categories (Array) - filter by categories
    #   search (String) - filter by search string
    def index # :cabbagedoc:
    end
  end
end
```

These *templates* will be substituted with what it is defined in the global
CabbageDoc configuration for each *application*.

```ruby
  config.templates = {
    main_app: {
      '{racl:collection}' => [
        'Content',
        'Idea'
      ],
      '{racl:root}' => [
        'api/v1',
        'api/v1'
      ],
      '{racl:resource}' => [
        'content',
        'ideas'
      ],
      '{racl:resource_id}' => [
        'content_id',
        'idea_id'
      ],
      '{racl:resource_name}' => [
        'content',
        'idea'
      ]
    },
    secondary_app: {
      '{racl:collection}' => [
        'Dashboards'
      ],
      '{racl:root}' => [
        'api/v1'
      ],
      '{racl:resource}' => [
        'dashboards'
      ],
      '{racl:resource_id}' => [
        'dashboard_id'
      ],
      '{racl:resource_name}' => [
        'dashboard'
      ]
    }
  }
```

By running `rake cabbagedoc`, CabbageDoc parses all comments and generates
the necessary metadata which is then used to render the documentation.

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
