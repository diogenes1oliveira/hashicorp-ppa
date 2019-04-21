#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from base64 import b64encode
from functools import partial
from pathlib import PosixPath
import re
from urllib.parse import urlparse

from bs4 import BeautifulSoup
from markdown import markdown
import scrapy

from hashiscraper.items import VersionItem


class VagrantSpider(scrapy.Spider):
    name = 'vagrant'

    start_urls = [
        'https://www.vagrantup.com/downloads.html'
    ]

    def parse(self, response: scrapy.http.response.html.HtmlResponse):
        os = getattr(self, 'os', 'linux')
        arch = getattr(self, 'arch', 'amd64')

        link_selector = (
            '//div[has-class("downloads")]'
            '//a[@data-os=$os][@data-arch=$arch]'
        )
        link = response.xpath(link_selector, os=os, arch=arch)
        download_url = link.attrib['href']
        version = link.attrib['data-version']

        checksums_url = response.xpath(
            '//div[has-class("downloads")]'
            '//a[contains(@href, "SHA256SUMS")][not(contains(@href, ".sig"))]'
            '/@href'
        ).get()

        checksums_signature_url = response.xpath(
            '//div[has-class("downloads")]'
            '//a[contains(@href, "SHA256SUMS.sig")]'
            '/@href'
        ).get()

        changelog_url = response.xpath(
            '//div[has-class("downloads")]'
            '//a[contains(@href, "CHANGELOG.md")]'
            '/@href'
        ).get().replace('/blob/', '/raw/')

        item = {
            'download_url': download_url,
            'version': version,
            'changelog_url': changelog_url,
            'checksums_url': checksums_url,
            'checksums_signature_url': checksums_signature_url,
        }
        yield response.follow(
            changelog_url,
            callback=self.parse_changelog,
            meta={'item': item},
        )

    def parse_changelog(self, response: scrapy.http.response.html.HtmlResponse):
        item = response.meta['item'].copy()
        content = response.body_as_unicode()

        match = re.match(f"(##\\s+){item['version']}\\s.*", content)
        _, i_start = match.span()
        i_next = content.find(match.group(1), i_start)

        item['changelog'] = content[i_start:i_next].strip()

        yield response.follow(
            item['checksums_url'],
            callback=self.parse_checksums,
            meta={'item': item},
        )

    def parse_checksums(self, response: scrapy.http.response.html.HtmlResponse):
        item = response.meta['item'].copy()

        item['checksums_content'] = response.body_as_unicode()
        filename = PosixPath(urlparse(item['download_url']).path).parts[-1]
        item['download_url_sha256_sum'] = [
            l.split()[0].strip()
            for l in item['checksums_content'].split("\n")
            if filename in l
        ][0]

        yield response.follow(
            item['checksums_signature_url'],
            callback=self.parse_checksums_signature,
            meta={'item': item},
        )

    def parse_checksums_signature(self, response: scrapy.http.Response):
        item = response.meta['item'].copy()

        item['checksums_signature_base64'] = b64encode(
            response.body).decode('ascii')

        yield VersionItem.from_dict(item)
