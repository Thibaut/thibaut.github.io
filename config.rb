Time.zone = 'UTC'
I18n.enforce_available_locales = false

activate :directory_indexes
set :trailing_slash, true

activate :blog do |blog|
  blog.prefix = 'articles'
  blog.layout = 'article'
  blog.permalink = ':title/index.html'
  blog.sources = ':year-:month-:day-:title.html'
  blog.default_extension = '.erb'
end

page '/shopify.html', layout: false
page '/resume.html', layout: false
page '/feed.xml', layout: false

set :css_dir,    'stylesheets'
set :js_dir,     'javascripts'
set :images_dir, 'images'

set :markdown_engine, :redcarpet
set :markdown, fenced_code_blocks: true, autolink: true, smartypants: true

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :gzip
  activate :asset_hash, exts: %w(.js .css)
end
