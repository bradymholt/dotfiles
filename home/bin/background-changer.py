# background.py
# Author Brian.Christner@gmail.com
# www.brianchristner.io
# Source: https://github.com/vegasbrianc/mac-background

# Unsplash Application ID
api_key = 'dd4e7d120de8fb5bdad1e633b5ad4e1f3c5e1b50379102325106d2c952e99ae1' 

############################################################################
import subprocess
import urllib
import urllib2
import json
#########################################################################

# build the usplash URL

# Grab random picture from unsplash
url = 'https://api.unsplash.com/photos/random?client_id=' + api_key

# Change the Background script
cmd = """/usr/bin/osascript<<END
tell application "Finder"
set desktop picture to POSIX file "%s"
end tell
END"""

# Iterrate through the URL and json

try:
    f = urllib2.urlopen(url)
    json_string = f.read()
    f.close()
    parsed_json = json.loads(json_string)
    photo = parsed_json['urls']['full']
    urllib.urlretrieve(photo, "/tmp/background.jpeg") # Location where we download the image to.
    subprocess.Popen(cmd%"/tmp/background.jpeg", shell=True)
    subprocess.call(["killall Dock"], shell=True)

except KeyboardInterrupt:
    print "The Computer says NO!"
