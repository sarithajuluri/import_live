class Product
  include Mongoid::Document
  include ActiveModel::MassAssignmentSecurity

  field :name, type: String
  field :price, type: Integer
  field :language, type: String
  attr_accessible :name, :price, :language
	def self.import(file)
		spreadsheet = Roo::Spreadsheet.open(file.path, extension: File.extname(file.original_filename).delete('.'))
		if spreadsheet.sheets.count > 0
			spreadsheet.default_sheet = spreadsheet.sheets.first
		end
		header = spreadsheet.row(1)
		(2..spreadsheet.last_row).each do |i|
			row = Hash[[header, spreadsheet.row(i)].transpose].to_hash.slice("name", "price")
			@product = Product.where(:name => row["name"]).count
			if @product < 1
				Product.create(name: row["name"], price: row["price"])
			end
		end
	end

  
	def self.to_csv(options = {})
		CSV.generate(options) do |csv|
		csv << self.fields.keys[1..-1]
			all.each do |product|
			  csv << product.attributes.values_at(*self.fields.keys[1..-1])
			end
		end
	end

end
