from tests.base import BaseTestCase
from edt.models import Article, Tag
from tests.schemas.base import CallFunc


class TestCreateArticle(CallFunc, BaseTestCase):
    meth = 'createArticle'

    def setUp(self):
        super().setUp()
        self.x = 1
        self.created_tag_name = 'x'
        self.session.add(Tag(name=self.created_tag_name))
        self.session.flush()

    def assertProps(self, result, expected):
        created = self.session.query(Article) \
            .filter(Article.id == result.data['createArticle']['id']).one()
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


# class TestEditArticle(CallFunc, BaseTestCase):
#     meth = 'editArticle'
#
#     def setUp(self):
#         self.tag = Tag(name='tag1')
#         self.session.add(self.tag)
#         self.without_tag = Article(title='hoge', body='fuga')
#         self.with_tag = Article(title='foo', body='bar')
#         self.with_tag.tags.append(self.tag)
#         self.session.add_all([self.without_tag, self.with_tag])
#         self.session.flush()
#
#     def test_update_title_for_without_tag_article(self):
#         pass
