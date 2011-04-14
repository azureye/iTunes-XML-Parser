# usage: ruby itunesparser.rb infile

def timeCalc infile
	total = 0.0
	tempTime = 0.0
	tempPlayCount = 0.0
	File.readlines(infile).each do |line|
		if /<key>Total Time<\/key><[a-z]*>(.*)<\/[a-z]*>/.match(line) != nil
			tempTime = /<key>Total Time<\/key><[a-z]*>(.*)<\/[a-z]*>/.match(line)[1].to_f
			tempTime = tempTime / 1000.0
		elsif /<key>Play Count<\/key><[a-z]*>(.*)<\/[a-z]*>/.match(line) != nil
			tempPlayCount = /<key>Play Count<\/key><[a-z]*>(.*)<\/[a-z]*>/.match(line)[1].to_f
			total = total + (tempTime * tempPlayCount)
		elsif /<key>Playlists<\/key>/.match(line) != nil
			return total
		end
	end
	return total
end

def readFile(infile,type)
	# will contain all data we're interested in
	bigArray = []
	
	# for each line, if there's a match to song name, put in bigArray
	# if we reach playlists, then stop
	File.readlines(infile).each do |line|
		if /<key>#{Regexp.escape(type)}<\/key><[a-z]*>(.*)<\/[a-z]*>/.match(line) != nil
			temp = /<key>#{Regexp.escape(type)}<\/key><[a-z]*>(.*)<\/[a-z]*>/.match(line)[1]
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
	if ARGV[0] == nil
		puts "Usage: ruby itunesparser.rb infile"
		return
	else
		infile = ARGV[0]
	end
	
	if File.exists?(infile) == false
		puts "Invalid file name!"
		return
	end

	puts "Enter the appropriate number based on what you would like listed."
	puts "(1) Song names"
	puts "(2) Artist names"
	puts "(3) Composer names"
	puts "(4) Album names"
	puts "(5) Genre names"
	puts "(6) Total listening time"

	choice = STDIN.gets.chomp.to_i
	
	if choice == 6
		timeInSeconds = timeCalc infile
		timeInMinutes = timeInSeconds / 60.0
		timeInHours = timeInMinutes / 60.0
		timeInDays = timeInHours / 24.0
		puts "You have listened to #{timeInDays} days' worth of music"
	else
		if choice == 1
			type = "Name"
		elsif choice == 2
			type = "Artist"
		elsif choice == 3
			type = "Composer"
		elsif choice == 4
			type = "Album"
		elsif choice == 5
			type = "Genre"
		else
			puts "Invalid choice!"
			return
		end
		puts "Please enter the name of the file you want results written to."
		outfile = STDIN.gets.chomp.to_s
		results = readFile(infile,type)
		exportFile(results,outfile)
	end
	return
end

main