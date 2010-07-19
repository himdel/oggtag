#!/usr/bin/ruby

# == Synopsis
#
# oggtag: shows and changes tags in files supported by libtag
# consider it alpha, changes in read only files are silently ignored
#
# == Usage
#
# oggtag [OPTION...] FILES...
#
# Options:
#
# -h, --help:
#    Display help and exit
#
# -l, --list:
#    Lists the tag(s) on the file(s)
#
# -a, --artist ARTIST:
#    Set the artist information
#
# -A, --album ALBUM:
#    Set the album title information
#
# -t, --song SONG:
#    Set the song title information
#
# -c, --comment COMMENT:
#    Set the comment information
#
# -g, --genre GENRE:
#    Set the genre
#
# -y, --year num:
#    Set the year
#
# -T, --track num:
#    Set the track number
#
# FILES: List of files to be changed.

# requires taglib (libtag1-ruby in debian)
# (the file is /usr/lib/ruby/1.8/taglib.rb)
# (file:///usr/share/doc/libtag1-doc/html/index.html)
require 'taglib'
require 'getoptlong'
require 'rdoc/usage'


opts = GetoptLong.new(
[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
[ '--list', '-l', GetoptLong::NO_ARGUMENT ],
[ '--artist', '-a', GetoptLong::REQUIRED_ARGUMENT ],
[ '--album', '-A', GetoptLong::REQUIRED_ARGUMENT ],
[ '--title', '-t', GetoptLong::REQUIRED_ARGUMENT ],
[ '--song', '-s', GetoptLong::REQUIRED_ARGUMENT ],	# same as -t
[ '--comment', '-c', GetoptLong::REQUIRED_ARGUMENT ],
[ '--genre', '-g', GetoptLong::REQUIRED_ARGUMENT ],
[ '--year', '-y', GetoptLong::REQUIRED_ARGUMENT ],
[ '--track', '-T', GetoptLong::REQUIRED_ARGUMENT ]
)

list = false
artist = album = title = comment = genre = year = track = nil
opts.each do |opt, arg|
	case opt
		when '--help'
			RDoc::usage
		when '--list'
			list = true
		when '--artist'
			artist = arg
		when '--album'
			album = arg
		when '--title'
			title = arg
		when '--song'
			title = arg
		when '--comment'
			comment = arg
		when '--genre'
			genre = arg
		when '--year'
			year = arg.to_i
		when '--track'
			track = arg.to_i
	end
end
		
if ARGV.length < 1
	puts "Missing file(s) argument (try --help)"
	exit 1
end

tags = [ :artist, :album, :title, :comment, :genre, :year, :track ]
ARGV.each do |fn|
	puts "#{fn} ..."
	begin
		f = TagLib::File.new(fn)
		if list then
			tags.each do |t|
				s = f.send(t)
				puts "#{t.to_s} = #{s}" if s and s != "" and s != 0
			end
			puts
		end
		chng = false
		tags.each do |k|
			v = eval "#{k}"
			next if v.nil?
			chng = true
			eval "f.#{k} = v"
		end
		if chng then
			if File.writable? fn then
				f.save
			else
				puts "error: can't write to file #{fn}, skipping"
			end
		end
		f.close
	rescue Exception #TagLib::BadFile
		puts "error: #{$!}"
	end
end
