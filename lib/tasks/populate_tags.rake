desc 'Populates the Tags table'
task populate_tags: :environment do
  tag = Tag.new :tag => "meta", :description => "Lobsters-related"
  tag.save
end
