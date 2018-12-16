from tests.base import BaseTestCase
from edt.models import Article, Tag
from tests.schema.base import CallFunc


class TestCreateArticle(CallFunc, BaseTestCase):
    meth = 'createArticle'

    from edt.schema.mutation import CreateArticle
    root_cls = CreateArticle

    def setUp(self):
        super().setUp()
        self.x = 1
        self.created_tag_name = 'x'
        self.session.add(Tag(name=self.created_tag_name))
        self.session.flush()

    def assertProps(self, result, expected):
        created = self.session.query(Article) \
            .filter(Article.id == result.data[self.meth]['id']).one()
        self.assertEqual(created.title, expected['title'])
        self.assertEqual(created.body, expected['body'])
        self.assertEqual([x.name for x in created.tags], expected['tags'])
        self.assertFalse(created.published)

    def test_new_article(self):
        title = 'hoge'
        body = 'fuga'
        result = self._callFUT(self.q(title=title, body=body))
        self.assertProps(result, {'title': title, 'body': body, 'tags': []})

    def test_new_article_with_new_tags(self):
        title = 'hoge'
        body = 'fuga'
        tags = ['a', 'b']
        result = self._callFUT(self.q(
            title=title,
            body=body,
            tags=tags,
            fields=[
                'id', 'title', 'body', 'published',
                'createdAt', 'tags {\nname\n}'
            ],
        ))
        self.assertProps(result, {'title': title, 'body': body, 'tags': tags})

    def test_new_article_with_existed_tags(self):
        title = 'hoge'
        body = 'fuga'
        tags = [self.created_tag_name, 'a']
        result = self._callFUT(self.q(
            title=title,
            body=body,
            tags=tags,
            fields=[
                'id', 'title', 'body', 'published',
                'createdAt', 'tags {\nname\n}'
            ],
        ))
        self.assertTrue(
            len(self.session.execute('select * from taggings').fetchall()) > 0
        )
        self.assertProps(result, {'title': title, 'body': body, 'tags': tags})
