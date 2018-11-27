import os
from pathlib import Path
from unittest import TestCase

from pyramid import testing
from sqlalchemy import engine_from_config
from pyramid.paster import get_appsettings
import transaction

from edt.models import DBSession, Base, Article


here = Path(os.path.dirname(__file__))
settings = get_appsettings(str(here / '..' / '..' / 'test.ini'))


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

    def setUp(self):
        self.config = testing.setUp()

    def tearDown(self):
        self.session.remove()
        testing.tearDown()


class TestSelect(BaseTestCase):
    article_data = [{'title': f'title{i}', 'body': f'body{i}'} for i in range(10)]
    tag_data = [{'name': f'tag{i}'} for i in range(10)]

    def setUp(self):
        super().setUp()
        with transaction.manager:
            self.session.add_all([Article(**v) for v in self.article_data])

    def assertAttrs(self, results, expected):
        for r, e in zip(results, expected):
            for a in ['title', 'body']:
                self.assertEqual(getattr(r, a), e[a])

    def test_one(self):
        expected = self.article_data[0]
        result = self.session.query(Article).first()
        self.assertAttrs([result], [expected])

    def test_all(self):
        expected = self.article_data
        results = self.session.query(Article).order_by(Article.id).all()
        self.assertAttrs(results, expected)

