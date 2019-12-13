package LANraragi::Plugin::MyAnimeList;

use strict;
use warnings;

#Plugins can freely use all Perl packages already installed on the system 
#Try however to restrain yourself to the ones already installed for LRR (see tools/cpanfile) to avoid extra installations by the end-user.
use Mojo::UserAgent;
use URI::Escape;
use Mojo::DOM;

use LANraragi::Model::Plugins;
use LANraragi::Model::Config;

my $MAL_URL = "https://myanimelist.net/manga.php?q=";

# In case of rapid consecutive runs
# Comment out sleep($SLEEP) and this line to avoid sleeping
my $SLEEP = 2;

#Meta-information about your plugin.
sub plugin_info {
    return (
        #Standard metadata
        name  => "MyAnimeList.net",
        type  => "metadata",
        namespace => "malmetadata",
        author => "Seraphine",
        version  => "0.1",
        description => "Searches MyAnimeList.net for tags matching your archive.",
        icon => "data:image/jpeg;base64,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",
        #This name will be displayed in plugin configuration next to an input box for global arguments, and in archive edition for one-shot arguments.
        parameters  => [
            {type => "bool", desc => "Save archive title"},
            {type => "bool", desc => "Exact title match"}
        ],
        oneshot_arg => "MyAnimeList page URL (Will attach matching tags to your archive)"
    );

}

#Mandatory function to be implemented by your plugin
sub get_tags {

    #LRR gives your plugin the recorded title for the file, the filesystem path to the file, and the custom arguments if available.
    shift;
    my ( $title, $tags, $thumbhash, $file, $oneshotarg, $savetitle, $search ) = @_;

    #Use the logger to output status - they'll be passed to a specialized logfile and written to STDOUT.
    my $logger = LANraragi::Utils::Generic::get_logger("MyAnimeList","plugins");

	sleep($SLEEP);

    #Work your magic here - You can create subroutines below to organize the code better
    $logger->info("Searching myanimelist.net...");
    $logger->info("Received title: " . $title);
    
	my $url = "";
    my $new_title = "";
    my $new_tags = "";

	# Remove leading and trailing whitespace
	my $regex = qr/^\ *(.+[^ ])\ */;
    if ($title =~ m/$regex/) {
        $title = $1;
    }
	$logger->debug("parsing 1: " . $title);
	
	# Remove clusters of two or more whitespace
	$title =~ s/\ +/\ /g;
	$logger->debug("parsing 2: " . $title);

	# Locate URL from user or by searching
	$url = $oneshotarg;
	if ($url eq "") {
		 ($url) = get_url($title, $search, $logger);
	}
    $logger->debug("URL: " . $url);
	
	# Check if URL is valid
    if ($url eq $MAL_URL or $url eq "") {
        $logger->info("Search failed!");
        return (tags => $new_tags);
    }
	
	# Process URL web page and convert to text
    my $ua = Mojo::UserAgent->new;
    my $res = $ua->get($url)->result; 
    my $dom = Mojo::DOM->new( $res->body );
	my $txt = $dom->to_string;


	# Reduce the search area
	$regex = qr/(English:.*?)<h2>Statistics/;
	if ($txt =~ m/$regex/s) {
		$txt = $1;
	}

	# Title
	my $string = 
    $regex = qr/English:<\/span> *(.+?) *<\/div>/;
	if ($txt =~ m/$regex/) {
		$new_title = $1;
	}
	
	# Type
	$regex = qr/type=.+">(.*?)</;
	if ($txt =~ m/$regex/) {
		$new_tags .= process_tag("type", $1, $logger);
		$logger->debug("type:" . $1);
	}
	
	# Volumes
	$regex = qr/Volumes:<\/span> ([0-9]*)/;
	if ($txt =~ m/$regex/) {
		$new_tags .= process_tag("volumes", $1, $logger);
		$logger->debug("volumes:" . $1);
	} 

	# Chapters
	$regex = qr/Chapters:<\/span> ([0-9]*)/;
	if ($txt =~ m/$regex/) {
		$new_tags .= process_tag("chapters", $1, $logger);
		$logger->debug("chapters:" . $1);
	}
	
	# Status
    $regex = qr/Status:<\/span> *(.+?) *<\/div>/;
	if ($txt =~ m/$regex/) {
		$new_tags .= process_tag("status", $1, $logger);
		$logger->debug("status:" . $1);
	}
	
	# Genres
	$regex = qr/\/genre\/.*?title="(.*?)"/;
	while ($txt =~ m/$regex/g) {
		$new_tags .= process_tag("genre", $1, $logger);
		$logger->debug("genre:" . $1);
	}

	# Authors
	$regex = qr/\/people\/.*?">(.*?)<\/a>\ *(\(.*?\))[,<]/;
	while ($txt =~ m/$regex/g) {
		$new_tags .= process_tag("author", $1 . " " . $2, $logger);
		$logger->debug("author:" . $1 . " " . $2);
	}

	# Serialization
    $regex = qr/Serialization.*title="(.*?)"/;
	if ($txt =~ m/$regex/s) {
		$new_tags .= process_tag("serialization", $1, $logger);
		$logger->debug("serialization:" . $1);
	}

	# Source
	my $source = $url =~ m/https?:\/\/(.*)/;
	$new_tags .= "source:" . $source;
	$logger->debug("source:" . $url);

    # Remove trailing colon and space.
    $new_tags =~ s/,\ $//m;

    # Returning tags.
    if ($savetitle && $new_tags ne "") {
        $logger->info("Sendings tags LRR: " . $new_tags);
        $logger->info("Sending title to LRR: " . $new_title);
        return (tags => $new_tags, title => $new_title);
    }
    else {
        $logger->info("Sending tags to LRR: " . $new_tags);
        return (tags => $new_tags);
    }
}

# Searches the url of the work given title
sub get_url {
    my ( $title, $search, $logger ) = @_;
	
	# Search URL
    my $url = $MAL_URL . $title;
    $logger->debug("get_url URL: " . $url);
	$logger->debug("get_url title(old): " . $title);
		
	# Get the search page and convert it to text
    my $ua = Mojo::UserAgent->new;
    my $res = $ua->get($url)->result;
    my $dom = Mojo::DOM->new( $res->body );
    my $string = $dom->to_string;
	
	# Checking for anything that would throw off regex
	$title =~ s/\\\Q/.Q/g;
	$title =~ s/\\\E/.E/g;
	$logger->debug("get_url title(new): " . $title);
		
	# Exact title match, return immediately
	my $regex = qr/href=\"(.+\/manga\/.+?)\".+>(\Q$title\E)</;
	if ($string =~ m/$regex/) {
		$logger->debug("get_url found[MATCH]: " . $1);
		return $1;
	}
	
	# First search result, return if not matching exact title
	$regex = qr/href=\"(.+\/manga\/.+?)\"/;
	if ($string =~ m/$regex/ && !$search) {
	
		$logger->debug("get_url found: " . $1);
		return $1;
    }
	$logger->debug("get_url search failed");
	
	# Search failed
	return $MAL_URL;
}

# Processes and returns formated tags
sub process_tag {
    my ( $tag_name, $tag_contents, $logger ) = @_;
	
	my $tag_content = $tag_contents;
	# Checking for anything that would throw off regex
	$tag_content =~ s/\\\Q/.Q/g;
	$tag_content =~ s/\\\E/.E/g;
	
	# Get rid of colons so Lanraragi can process tags properly
    if ($tag_content =~ m/ : /g or $tag_content =~ m/[^ ]:[^ ]/g) {
        $tag_content =~ s/:/-/g;
    }
    if ($tag_content =~ m/[^ ]: | :[^ ]/g) {
        $tag_content =~ s/://g;
    }

	# Author / Artist split
	if ($tag_name eq "author" && $tag_content =~ m/Art/) {
		$tag_name = "artist"; 
	}
	
	# Remove parentheses
	#$tag_content =~ s/ ?\(.*\)/;
	if  ($tag_content =~  m/*(.+[^ \n]) */) {
		$tag_content = $1;
	}
	
	# Remove leading and trailing whitespace
	
	# Reverse Japanese last name, first name
	if ($tag_content =~ m/(.*?), ([^ \(\n]+)/) {
		$tag_content = $2 . " " . $1;
	}
	
    return ($tag_content ne "") ? ($tag_name . ":" . $tag_content . ", ") : "";
}


1;
