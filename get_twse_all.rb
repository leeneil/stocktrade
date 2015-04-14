# encoding=utf-8
require 'net/http'
require 'date'

unless File.exists?("TWSE")
	Dir.mkdir("TWSE")
end

url = 'http://www.twse.com.tw/ch/trading/exchange/MI_INDEX/MI_INDEX.php'
uri = URI(url)

if ARGV[0].nil?
	input_date = DateTime.now - 1
else
	input_date = DateTime.parse(ARGV[0])
end

if ARGV[1].nil?
	n = 0
	end_date = input_date
else
	n = ARGV[1].to_i
	end_date = input_date + n
end

if end_date > DateTime.now
	puts "End date truncated."
	end_date = DateTime.now.to_date - 1
	n = (end_date - input_date).to_i
end

puts "From: " + input_date.strftime('%Y/%m/%d')
puts "To:   " +   end_date.strftime('%Y/%m/%d')

sel_type = 'ALLBUT0999'

for d in 0..n
	current_date = input_date + d
	unless current_date.saturday? || current_date.sunday? 
		sel_date = current_date.year - 1911
		sel_date = sel_date.to_s + current_date.strftime('/%m/%d')

		csv = Net::HTTP.post_form(uri,
		 "qdate"=>sel_date, "download"=>"csv", "selectType"=>sel_type)

		open("TWSE/" + current_date.strftime('%Y%m%d') +".csv", "wb") do |file|
			file.write((csv.body).encode(Encoding::UTF_8, Encoding::BIG5, :invalid => :replace, :undef => :replace, :replace => ''))
		end
		puts current_date.strftime('%Y/%m/%d') + 'saved'
	end
end
