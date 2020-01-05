import os

import pickle as pkl
import requests as req
from bs4 import BeautifulSoup as BS
from tqdm import tqdm
from dateutil import parser

url = "https://www.cnblogs.com/tanglizi/archive/%d/%02d.html"
links = []
headers = {
        "Referer": "https://www.cnblogs.com/",
        "Host": "www.cnblogs.com",
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:71.0) Gecko/20100101 Firefox/71.0", 
        "Cookie": "",
}

def normTitle(s):
    return s.replace(' ', '_').replace('`', "'").replace('/', '||') + '.md'

if !os.exists('links.pkl'):
    for year in range(2017, 2020+1):
        for month in range(1, 12+1):
            resp = req.get(url%(year, month), headers=headers)
            soup = BS(resp.content, 'lxml')

            names = soup.find_all('a', class_="entrylistItemTitle")
            times = soup.find_all('a', title="permalink")
            if len(names) != len(times):
                print(f"WARNING on {year} {month}")

            for name, t in zip(names, times):
                links.append((
                    normTitle(name.text),
                    name.attrs['href'].replace('html', 'md'),
                    parser.parse(t.text).timestamp()
                ))
    print(links)
    pkl.dump(links, open('links.pkl', 'wb'))
else:
    links = pkl.load(open('links.pkl', 'rb'))

for article in tqdm(links):
    name = 'post/' + article[0]
    link = article[1]
    resp = req.get(link, headers=headers)
    mdfile = open(name, 'w')
    mdfile.write(resp.text)
    mdfile.close()

    mtime = article[2]
    os.utime(name, (mtime, mtime))

