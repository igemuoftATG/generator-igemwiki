import sys  # for command-line arguments
import urllib.request  # for http
import http.cookiejar as cookielib  # for cookies and session
from urllib import parse  # for urlencode
import getpass  # password reading from commandline
#import urllib
#------ SETTINGS -------#
LOGIN_URL = "http://igem.org/Login"
# DO NOT end base url with "/"
BASE_URL = "http://2015.igem.org/Team:Toronto"
AUTO_PAGES = ["index", "Business", "Research", "Team", "Journal", "Modeling", "Cooperation", "Outreach"]
#-----------------------#

# Wrangler class - parser object which parses HTML
from html.parser import HTMLParser


class Wrangler(HTMLParser):
    # The tags, a.k.a. id's are stored here. For example wpEditToken
    ids = {}
    # Method which handles every start tag eg. <input>

    def handle_starttag(self, tag, attrs):
        if (tag == 'input'):
            for i in attrs:
                if (i[0] == 'name'):
                    if (i[1] == 'wpAutoSummary' or i[1] == 'wpEditToken' or i[1] == 'wpSave' or i[1] == 'wpSection' or i[1] == 'wpStarttime' or i[1] == 'wpEdittime' or i[1] == 'oldid'):
                        name = i[1]
                        value = [c for c in attrs if c[0] == 'value'][0][1]
                        self.ids[name] = value


# http://stackoverflow.com/questions/189555/how-to-use-python-to-login-to-a-webpage-and-retrieve-cookies-for-later-usage
# def main(argv=sys.argv):
def upload(page, file, headerfooter=True):
    global opener
    #-------- get edit id --------#
    try:
        if (page == "index"):
            url = BASE_URL + "?action=edit"
        else:
            url = BASE_URL + "/" + page + "?action=edit"

        # print(url)
        resp = opener.open(url)
        content = resp.read()
        # print(content)
        parser = Wrangler()
        parser.feed(content.decode('utf8'))
        data = parser.ids  # stores wpEditToken and wp AutoSummary
    # except NameError:
    except:
        print("Error:", sys.exc_info()[0])
        return 3

    #---- read requested file ----#
    try:
        with open(file, "r", encoding="utf8") as myfile:
            file_data = myfile.read()
    except FileNotFoundError:
        #print("File {:s} not found".format(file))
        return 2

    #------- post new edit -------#
    try:
        data['wpTextbox1'] = file_data
        #data['wpSave'] = 'Save page'

        encoded_data = parse.urlencode(data)
        if (page == "index"):
            resp = opener.open(BASE_URL + "?action=submit", encoded_data.encode('utf8'))
        else:
            resp = opener.open(BASE_URL + "/" + page + "?action=submit", encoded_data.encode('utf8'))

        print (resp.read())
        # headers = {"Content-type": "multipart/form-data;",
    except:
        print("Error:", sys.exc_info()[0])
        return 3
    #print('No errors encountered. Although i cannot verify the success :)')
    return 0


def login(username, password):
    global opener
    #---------- log in------------#
    try:
        login_data = {
            'id': '0',
            'new_user_center': '',
            'new_user_right': '',
            'hidden_new_user': '',
            'return_to': 'http://2015.igem.org/Team:Toronto&action=edit',
            'username': username,
            'password': password,
            'Login': 'Log+in',
            'search_text': ''
        }
        cookie = cookielib.CookieJar()
        opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cookie))
        encoded_data = parse.urlencode(login_data)
        resp = opener.open(LOGIN_URL, encoded_data.encode('utf8'))
        # check if login failed
        response = resp.read()
        # print (response)
        if (response.find(b"That username") != -1):
            return 2
    except urllib.error.URLError:
        print("Login server not found. Perhaps the URL is wrong in the code?")
        return 1
    except:
        print("Error:", sys.exc_info()[0])
        return 1
    return 0


def main(argv=sys.argv):
    #----- arguments -------------#
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
    #------- automation ---------#
    if (argv[1] == '-auto'):
        print("Auto updating pages: ", ",".join(AUTO_PAGES))
        for p in AUTO_PAGES:
            r = upload(p, p + ".html", True)
            if (r == 2):
                print("{:s}.html\t\tFile not found".format(p))
            elif (r == 1):
                print("{:s}.html\t\tServer error".format(p))
            elif (r == 3):
                print("{:s}.html\t\tUnknown error".format(p))
            else:
                print("{:s}.html\t\tUploaded".format(p))
    else:
        print("Uploading contents of \"{:s}\" to \"{:s}\"".format(file, page))
        r = upload(page, file)
        if (r == 2):
            print("{:s}.html\t\tFile not found".format(file))
        elif (r != 0):
            print("Error occured")
    print("Done")


main()
