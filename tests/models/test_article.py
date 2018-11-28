import transaction

from edt.models import Article
from tests.models.base import BaseTestCase
from tests.factories import ArticleFactory


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
