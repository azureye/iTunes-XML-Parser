# usage: ruby itunesparser.rb infile outfile

def readFile infile
	# will contain all data we're interested in
	bigArray = []
	
	# for each line, if there's a match to song name, put
	# song in bigArray
	# if we reach playlists, then stop
	File.readlines(infile).each do |line|
		if /<key>Name<\/key><[a-z]*>(.*)<\/[a-z]*>/.match(line) != nil
			temp = /<key>Name<\/key><[a-z]*>(.*)<\/[a-z]*>/.match(line)[1]
			# hack: cleans input for my library, since half my music is ocremix
			if (temp.size > 8) && (temp[-8..-1] == "OC ReMix")
				temp = temp[0..-10]
			end
			bigArray << temp
		elsif /<key>Playlists<\/key>/.match(line) != nil
			return bigArray
		end
	end
	
	return bigArray
end

def exportFile(results,outfile)
	File.open(outfile,'w') do |line|
		results.each do |item|
			line.puts(item)
		end
	end
end

def main
	if ARGV[0] == nil || ARGV[1] == nil
		puts "Usage: ruby itunesparser.rb infile outfile"
		return
	else
		infile = ARGV[0]
		outfile = ARGV[1]
	end
	
	if File.exists?(infile) == false
		puts "Invalid file name!"
		return
	end
	
	# Currently only outputs list of song titles — will include
	# this menu later
	# puts "Enter the appropriate number based on what you would like listed."
	# puts "(1) Song names"
	# puts "(2) Artist names"
	# puts "(3) Composer names"
	# puts "(4) Album names"
	# puts "(5) Genre names"
	# puts "(6) Total listening time"
	
	results = readFile infile
	
	exportFile(results,outfile)

	return
end

main