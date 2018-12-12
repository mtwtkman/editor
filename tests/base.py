from unittest import TestCase
import os
from pathlib import Path
from typing import List

from pyramid import testing
from sqlalchemy import engine_from_config
from pyramid.paster import get_appsettings

from edt.models import Base, Article, Tag, DBSession


here = Path(os.path.dirname(__file__))
settings = get_appsettings(str(here / '..' / 'test.ini'))


class BaseTestCase(TestCase):
    @classmethod
    def setUpClass(cls):
        cls.engine = engine_from_config(settings, prefix='sqlalchemy.')
        Base.metadata.create_all(cls.engine)
        DBSession.configure(bind=cls.engine)
        cls.session = DBSession

    @classmethod
    def tearDownClass(cls):
        Base.metadata.drop_all(cls.engine)
        cls.session.remove()

    def setUp(self):
        self.config = testing.setUp()

    def tearDown(self):
        self.session.rollback()
        self.session.close()
        testing.tearDown()


class fixture:
    def insert(self):
        self.article_data = [
            Article(title=f'title{i}', body=f'body{i}') for i in range(10)
        ]
        self.tag_data = [Tag(name=f'tag{i}') for i in range(10)]
        self.session.add_all(self.article_data)
        self.session.add_all(self.tag_data)
        self.tagged_article_data = self.article_data[:3]
        self.tagged_tag_data = self.tag_data[:3]
        for x in self.tagged_article_data:
            x.tags = self.tagged_tag_data


class assertFields:
    def assertAttrsOf(self, fields: List[str], results, expected):
        for r, e in zip(results, expected):
            for a in fields:
                self.assertEqual(getattr(r, a), getattr(e, a))
