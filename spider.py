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
        "Cookie": "_ga=GA1.2.1709316944.1518302183; _dx_uzZo5y=319fd0476c32d875196091834769ca07cae40165c7064447af4b1f14c6fe65ac4788c278; .Cnblogs.AspNetCore.Cookies=CfDJ8FKe-Oc4rmBCjdz4t-OOIu02yC9MWH7a8MzZkC1GMOLzNfM4UreP7x5thVX3FIS0uMihKwMKu4ainhANf92b-mJkSASeqUNl9KKSOjr3cVao9APQ81pAvFIqJYmK0KJ_qq4NRLLF6mZddZFezY__uNNuQE_Gvbv2zlM7JT2KvqUzpBwcRbFWDP-sc0Ua7NvZHyXGr_4zQOaJz2SvejLTAC03xH10SUxkc0ziHvjL5c_GzYrB7MRyHqX1uuqjRsYLftr-j_MW2Xz6y3THfIk9GOJ9FhlNt833WUZ9n2YUDGBLSdUIvymstb1CYXYvfSpIjMbBMxJRQkDhd5Hb9SW-5GmYRL4Dmkkp_jp633FaQKBpc2Qb5qQYUdCU-ccKmnkt55lWf_oWTNYsZtH5pJFyIOmiOz47dIXYo6VzqlJtD5T3zMtB0hrXllhnJhcAIra0sNNnxtrFIAhfHNk0TOIIUtfMd3ct3Pw0Fcy-DqgXc6McHxP7N49VXWp6aKcKMzPcVw6DT68LRtEkBu3ROULVEHDvfxD7mtBefSjXAoIl3fI9; .CNBlogsCookie=CE1BD3773EA768197F7DD27E8A5FEA5F8C31EE393439180B9A9BE9F81FD5ADB43ABBC03D2620C8D43723D74F9D72626EF9183690F882309831CFF9D7B79A73C86C7F3FFB1A663623E7EE42A627A224399D5F2AB5",
}

def normTitle(s):
    return s.replace(' ', '_').replace('`', "'").replace('/', '||') + '.md'

if not os.path.exists('links.pkl'):
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
                    t.text.split(' ')[0]
                ))
    print(links)
    pkl.dump(links, open('links.pkl', 'wb'))
else:
    links = pkl.load(open('links.pkl', 'rb'))

for article in tqdm(links):
    name = 'post/' + article[2] + '_' + article[0]
    link = article[1]
    resp = req.get(link, headers=headers)
    mdfile = open(name, 'w')
    mdfile.write(resp.text)
    mdfile.close()

    mtime = parser.parse(article[2]).timestamp()
    os.utime(name, (mtime, mtime))

