from tests.base import BaseTestCase
from edt.models import Article, Tag
from tests.schemas.base import CallFunc


class TestMutation(CallFunc, BaseTestCase):
    def setUp(self):
        super().setUp()
        self.x = 1
        self.created_tag_name = 'x'
        self.session.add(Tag(name=self.created_tag_name))

    def t(self, tags):
        return f'''[{','.join([f'{{name: "{t}"}}' for t in tags])}]'''

    def q(
        self,
        title,
        body,
        tags=None,
        fields=['id', 'title', 'body', 'published', 'createdAt']
    ):
        article_arg = f'''article: {{title: "{title}", body: "{body}"}}'''
        tags_arg = f', tags: {self.t(tags)}' if tags else ''
        fields = '\n'.join(fields)
        return f'''
        mutation AddNewArticle {{
            createArticle({article_arg}{tags_arg}) {{
                {fields}
            }}
        }}
        '''

    def assertProps(self, result, expected):
        created = self.session.query(Article).filter(Article.id == result.data['createArticle']['id']).one()
        self.assertEqual(created.title, expected['title'])
        self.assertEqual(created.body, expected['body'])
        self.assertEqual([x.name for x in created.tags], expected['tags'])
        self.assertFalse(created.published)

    def test_new_article(self):
        title = 'hoge'
        body = 'fuga'
        result = self._callFUT(self.q(title, body))
        self.assertProps(result, {'title': title, 'body': body, 'tags': []})

    def test_new_article_with_new_tags(self):
        title = 'hoge'
        body = 'fuga'
        tags = ['a', 'b']
        result = self._callFUT(self.q(
            title,
            body,
            tags,
            ['id', 'title', 'body', 'published', 'createdAt', 'tags {\nname\n}'],
        ))
        self.assertProps(result, {'title': title, 'body': body, 'tags': tags})

    def test_new_article_with_existed_tags(self):
        title = 'hoge'
        body = 'fuga'
        tags = [self.created_tag_name, 'a']
        result = self._callFUT(self.q(
            title,
            body,
            tags,
            ['id', 'title', 'body', 'published', 'createdAt', 'tags {\nname\n}'],
        ))
        self.assertProps(result, {'title': title, 'body': body, 'tags': tags})
