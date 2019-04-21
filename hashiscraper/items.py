# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class VersionItem(scrapy.Item):
    download_url = scrapy.Field()
    version = scrapy.Field()
    download_url_sha256_sum = scrapy.Field()
    changelog = scrapy.Field()
    checksums_content = scrapy.Field()
    checksums_signature_base64 = scrapy.Field()

    @classmethod
    def from_dict(cls, d):
        return cls(
            download_url=d['download_url'],
            version=d['version'],
            download_url_sha256_sum=d['download_url_sha256_sum'],
            changelog=d['changelog'],
            checksums_content=d['checksums_content'],
            checksums_signature_base64=d['checksums_signature_base64'],
        )
