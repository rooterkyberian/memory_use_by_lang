import urllib.urequest

response = urllib.urequest.urlopen('https://www.google.com/robots.txt').read()
response.read()
response.close()
