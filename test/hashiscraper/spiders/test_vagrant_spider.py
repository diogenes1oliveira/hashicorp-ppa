import json
from pathlib import Path
from pprint import pprint
from pdb import set_trace
from tempfile import TemporaryDirectory
from urllib.parse import urlparse

from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings

from hashiscraper.spiders.vagrant_spider import VagrantSpider


TEST_SPIDERS_DATA_PATH = Path(__file__).absolute().parent / 'data'
TEST_FILES = list(
    (TEST_SPIDERS_DATA_PATH / 'www.vagrantup.com').glob('*.html'))
VERSIONS_IN_TEST_FILES = [
    str(p.parts[-1]).replace('.html', '') for p in TEST_FILES
]


class MyTestVagrantSpider(VagrantSpider):
    start_urls = ['file://%s' % p.absolute() for p in TEST_FILES]
    all_items = []
    custom_settings = {
        # 'LOG_LEVEL': 'ERROR',
        'FEED_FORMAT': 'jsonlines',
    }

    @classmethod
    def set_output_file(cls, fpath):
        cls.custom_settings['FEED_URI'] = 'file://%s' % Path(fpath).absolute()


def test_versions():
    with TemporaryDirectory() as tempdir:
        fpath = str(Path(tempdir) / 'results.json')
        MyTestVagrantSpider.set_output_file(fpath)

        process = CrawlerProcess(get_project_settings())
        process.crawl(MyTestVagrantSpider)
        process.start()

        with open(fpath) as fp:
            crawled_versions = set()

            for line in fp:
                item = json.loads(line)
                crawled_versions.add(item['version'])

            assert set(VERSIONS_IN_TEST_FILES) == crawled_versions
