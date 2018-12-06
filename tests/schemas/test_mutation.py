from tests.base import BaseTestCase
from edt.models import Article, Tag
from tests.schemas.base import CallFunc


class TestMutation(CallFunc, BaseTestCase):
    def assertProps(self, result, expected):
        created = self.session.query(Article).filter(Article.id == result.data['createArticle']['id']).one()
        self.assertEqual(created.title, expected['title'])
        self.assertEqual(created.body, expected['body'])
        self.assertEqual(created.tags, expected['tags'])
        self.assertFalse(created.published)

    def test_new_article(self):
        title = 'hoge'
        body = 'fuga'
        query = f'''
        mutation AddNewArticle {{
            createArticle(article: {{title: "{title}", body: "{body}"}}) {{
                id
                title
                body
                published
                createdAt
            }}
        }}
        '''
        result = self._callFUT(query)
        self.assertProps(result, {'title': title, 'body': body, 'tags': []})

    def test_new_article_with_tags(self):
        title = 'hoge'
        body = 'fuga'
        tags = ['a', 'b']
        t = f'''[{','.join([f'{{name: "{t}"}}' for t in tags])}]'''
        query = f'''
        mutation AddNewArticleWithTags {{
            createArticle(article: {{title: "{title}", body: "{body}"}}, tags: {t}) {{
                id
                title
                body
                published
                createdAt
                tags {{
                    name
                }}
            }}
        }}
        '''.replace('\'', '"')
        result = self._callFUT(query)
        self.assertProps(result, {'title': title, 'body': body, 'tags': tags})
