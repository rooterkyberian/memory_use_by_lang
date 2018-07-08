import urllib.request

with urllib.request.urlopen('https://www.google.com/robots.txt') as response:
    response.read()
