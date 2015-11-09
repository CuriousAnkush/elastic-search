class Article < ActiveRecord::Base
	include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  settings index: { number_of_shards: 1 } do
	  mappings dynamic: 'false' do
	    indexes :title, analyzer: 'snowball'
	    indexes :content, analyzer: 'snowball'
	  end
	end
end
Article.__elasticsearch__.client.indices.delete index: Article.index_name rescue nil

# Create the new index with the new mapping
Article.__elasticsearch__.client.indices.create \
  index: Article.index_name,
  body: { settings: Article.settings.to_hash, mappings: Article.mappings.to_hash }

# Index all article records from the DB to Elasticsearch
Article.import