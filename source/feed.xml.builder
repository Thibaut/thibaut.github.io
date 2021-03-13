xml.instruct!
xml.feed 'xml:lang' => 'en-US', xmlns: 'http://www.w3.org/2005/Atom' do
  xml.title 'Thibaut Courouble'
  xml.id "#{data.config.base_url}/"
  xml.link href: "#{data.config.base_url}/", type: 'text/html', rel: 'alternate'
  xml.link href: "#{data.config.base_url}/feed.xml", type: 'application/atom+xml', rel: 'self'
  xml.updated blog.articles.first.date.to_time.iso8601
  xml.author { xml.name 'Thibaut Courouble' }

  blog.articles[0..20].each do |article|
    xml.entry do
      xml.id "#{data.config.base_url}#{article.url}"
      xml.title article.title
      xml.link href: "#{data.config.base_url}#{article.url}", rel: 'alternate', type: 'text/html'
      xml.published article.date.to_time.iso8601
      xml.updated article.date.to_time.iso8601
      xml.author { xml.name 'Thibaut' }
      xml.content article.body, type: 'html'
    end
  end
end
