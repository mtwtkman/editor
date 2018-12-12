from tests.base import BaseTestCase, fixture
from tests.schemas.base import CallFunc
from edt.models import Article, Tag


class TestQuery(fixture, CallFunc, BaseTestCase):
    def setUp(self):
        super().setUp()
        self.insert()

    def test_articles(self):
        expected = [x[0] for x in self.session.query(Article.title).all()]
        result = self._callFUT('query { articles { title }}')
        subject = [x['title'] for x in result.data['articles']]
        self.assertEqual(subject, expected)

    def test_article_with_tag(self):
        target = self.session.query(Article).first()
        query = f'''
        query Data {{
            article(id: {target.id}) {{
                title,
                body,
                published,
                createdAt,
                updatedAt,
                tags {{
                    name
                }}
            }}
        }}
        '''
        result = self._callFUT(query)
        expected = {
            'article': {
                'title': target.title,
                'body': target.body,
                'published': target.published,
                'createdAt': target.created_at.isoformat(),
                'updatedAt': target.updated_at.isoformat(),
                'tags': [{'name': x.name} for x in target.tags],
            },
        }
        self.assertEqual(result.data, expected)

    def test_tags(self):
        expected = [x[0] for x in self.session.query(Tag.name).all()]
        result = self._callFUT('query { tags { name }}')
        subject = [x['name'] for x in result.data['tags']]
        self.assertEqual(subject, expected)
