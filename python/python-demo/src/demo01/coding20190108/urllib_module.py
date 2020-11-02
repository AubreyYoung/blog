import urllib.request
import urllib.response
test = urllib.request.urlopen('http://www.iplaypy.com/')
print(urllib.request.getproxies_environment(test))