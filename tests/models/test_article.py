import transaction

from sqlalchemy.exc import OperationalError
from sqlalchemy import update

from edt.models import Article, Tag
from tests.models.base import BaseTestCase


class TestSelect(BaseTestCase):
    def setUp(self):
        super().setUp()
        self.article_data = [Article(title=f'title{i}', body=f'body{i}') for i in range(10)]
        self.tag_data = [Tag(name=f'tag{i}') for i in range(10)]
        self.session.add_all(self.article_data)
        self.session.add_all(self.tag_data)

        self.tagged_article_data = self.article_data[:3]
        for x in self.tagged_article_data:
            x.tags = self.tag_data[:3]

    def assertAttrs(self, results, expected):
        for r, e in zip(results, expected):
            for a in ['title', 'body']:
                self.assertEqual(getattr(r, a), getattr(e, a))

    def test_one(self):
        expected = self.article_data[0]
        result = self.session.query(Article).first()
        self.assertAttrs([result], [expected])

    def test_all(self):
        expected = self.article_data
        results = self.session.query(Article).order_by(Article.id).all()
        self.assertAttrs(results, expected)

    def test_with_tag(self):
        for data in self.tagged_article_data:
            expected = [x.name for x in data.tags]
            one = self.session.query(Article).filter(Article.title == data.title).one()
            results = [x.name for x in one.tags]

            self.assertEqual(results, expected)


class TestInsert(BaseTestCase):
    def setUp(self):
        super().setUp()
        self.data = Article(title='minami', body='mirei')

    def test_success(self):
        before = self.session.query(Article).count()
        self.session.add(self.data)
        after = self.session.query(Article).count()
        self.assertEqual(before + 1, after)

    def test_with_published(self):
        published = False
        self.data.published = published
        self.session.add(self.data)
        result = self.session.query(Article.published).filter(Article.title == self.data.title).scalar()
        self.assertEqual(result, published)


class TestDelete(BaseTestCase):
    def setUp(self):
        super().setUp()
        self.data = Article(title='minami', body='mirei')
        self.session.add(self.data)

    def test_success(self):
        target = self.session.query(Article).filter(Article.title == self.data.title).one()
        before = self.session.query(Article).count()
        self.session.delete(target)
        after = self.session.query(Article).count()
        self.assertEqual(before - 1, after)


class TestUpdate(BaseTestCase):
    def setUp(self):
        super().setUp()
        self.data = Article(title='minami', body='mirei')
        self.session.add(self.data)
        self.target = self.session.query(Article).first()

    def test_title(self):
        title = f'x{self.data.title}'
        stmt = update(Article).where(Article.id == self.target.id).values(title=title)
        self.session.execute(stmt)
        result = self.session.query(Article.title).filter(Article.id == self.target.id).scalar()
        self.assertEqual(result, title)
