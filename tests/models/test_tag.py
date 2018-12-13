from tests.base import BaseTestCase, fixture, assertFields
from edt.models import Tag


class TestSelect(fixture, assertFields, BaseTestCase):
    def setUp(self):
        super().setUp()
        self.insert()

    def assertAttrs(self, results, expected):
        self.assertAttrsOf(['name'], results, expected)

    def test_one(self):
        expected = self.tag_data[0]
        result = self.session.query(Tag).first()
        self.assertAttrs([result], [expected])

    def test_all(self):
        expected = self.tag_data
        results = self.session.query(Tag).all()
        self.assertAttrs(results, expected)

    def test_with_article(self):
        for data in self.tagged_tag_data:
            expected = [x.id for x in data.articles]
            one = self.session.query(Tag).filter(Tag.name == data.name).one()
            results = [x.id for x in one.articles]
            self.assertEqual(results, expected)


class TestInsert(BaseTestCase):
    def setUp(self):
        super().setUp()
        self.data = Tag(name='tag')

    def teset_success(self):
        before = self.session.query(Tag).count()
        self.session.add(self.data)
        after = self.session.query(Tag).count()
        self.assertEqual(before + 1, after)


class TestDelete(BaseTestCase):
    def setUp(self):
        super().setUp()
        self.data = Tag(name='tag')
        self.session.add(self.data)

    def test_success(self):
        target = self.session.query(Tag) \
            .filter(Tag.name == self.data.name).one()
        before = self.session.query(Tag).count()
        self.session.delete(target)
        after = self.session.query(Tag).count()
        self.assertEqual(before - 1, after)
