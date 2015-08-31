# For command-line arguments
import sys
# For http requests
import urllib.request
# For cookies and session
import http.cookiejar as cookielib
# For Content-Type:application/x-www-form-urlencoded and
# Content-Type:multipart/form-data
from urllib import parse
# For parsing HTML
from html.parser import HTMLParser
# For password reading from commandline
import getpass


LOGIN_URL = "http://igem.org/Login"
BASE_URL = "http://2015.igem.org/Team:Toronto"

# Wrangler
class Wrangler(HTMLParser):
    # The tags, a.k.a. id's are stored here. For example, wpEditToken.
    ids = {}

    # Method which handles every start tag eg. <input>
    def handle_starttag(self, tag, attrs):
        if (tag == 'input'):
            for i in attrs:
                if (i[0] == 'name'):
                    if (
                        i[1] == 'wpAutoSummary' or
                        i[1] == 'wpEditToken' or
                        i[1] == 'wpSave' or
                        i[1] == 'wpSection' or
                        i[1] == 'wpStarttime' or
                        i[1] == 'wpEdittime' or
                        i[1] == 'oldid'
                    ):
                        name = i[1]
                        value = [c for c in attrs if c[0] == 'value'][0][1]
                        self.ids[name] = value

# Login
# Returns 0 on success, 1 on error, 2 on login failure
def login(username, password):
    # Global opener object so that cookies can be used elsewhere
    global opener

    try:
        login_data = {
            'id'              : '0',
            'new_user_center' : '',
            'new_user_right'  : '',
            'hidden_new_user' : '',
            'return_to'       : '',
            'username'        : username,
            'password'        : password,
            'Login'           : 'Log+in',
            'search_text'     : ''
        }

        # Cookie jar
        cookie = cookielib.CookieJar()
        # Build opener with our cookie jar
        opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie))
        # Encode login data as urlencoded
        encoded_data = parse.urlencode(login_data)
        # POST to LOGIN_URL with login_data as Content-Type:x-www-form-urlencoded
        resp = opener.open(LOGIN_URL, encoded_data.encode('utf8'))

        # Check if login failed
        response = resp.read()
        if (response.find(b"That username") != -1):
            return 2

    except urllib.error.URLError:
        print("Login server not found at " + LOGIN_URL)
        return 1

    except:
        print("Error: ", sys.exc_info()[0])
        return 1

    # Successful login
    return 0

# Upload
def upload(page, file):
    # Use same opener object to maintain cookies
    global opener

    # Get edit id
    try:
        if (page == "index"):
            url = BASE_URL + "?action=edit"
        else:
            url = BASE_URL + "/" + page + "?action=edit"

        # Open url
        resp = opener.open(url)
        content = resp.read()
        # Parse the response's HTML body
        parser = Wrangler()
        parser.feed(content.decode('utf8'))
        # Stores wpEditToken and wpAutoSummary
        data = parser.ids

    except:
        print("Error:", sys.exc_info()[0])
        return 3

    # Read requested file
    try:
        with open(file, "r", encoding="utf8") as myfile:
            file_data = myfile.read()
    except FileNotFoundError:
        # print("File {:s} not found".format(file))
        return 2

    # Post new edit
    try:
        data['wpTextbox1'] = file_data
        #data['wpSave'] = 'Save page'

        encoded_data = parse.urlencode(data)
        if (page == "index"):
            resp = opener.open(BASE_URL + "?action=submit", encoded_data.encode('utf8'))
        else:
            resp = opener.open(BASE_URL + "/" + page + "?action=submit", encoded_data.encode('utf8'))

    except:
        print("Error:", sys.exc_info()[0])
        return 3

    #print('No errors encountered. Although i cannot verify the success :)')
    return 0


def main(argv=sys.argv):

    # Command line arguments
    try:
        if (argv[1] != '-auto'):
            page = argv[1]
            file = argv[2]
    except IndexError:
        print("Usage: upload.py wikipage filename\n\nwikipage\tThe subpage in the wiki.\n\t\teg. in igem.org/wiki/index.php?title=Team:teamname/members\n\t\twikipage=members\n\nfile\t\tfilename in current directory")
        return

    #------- read input ----------#
    try:
        print("-- iGEM wiki quickify --\ncmd + d to abort.")
        username = input("Username: ")
        username = username.encode("utf8")
        password = getpass.getpass('Password: ')
        #input("Password: ")
    except EOFError:
        print("Aborting...")
        return 1

    print("Logging in")
    login_result = login(username, password)

    if (login_result == 2):
        print("Invalid username/password")
        return 1
    elif (login_result != 0):
        print("Server error when logging in")
        return 1
        
    print("Uploading contents of \"{:s}\" to \"{:s}\"".format(file, page))
    r = upload(page, file)
    if (r == 2):
        print("{:s}.html\t\tFile not found".format(file))
    elif (r != 0):
        print("Error occured")

    print("Done")


main()
