from tests.base import BaseTestCase
from edt.models import Article, Tag
from tests.schemas.base import CallFunc


class TestMutation(CallFunc, BaseTestCase):
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
        created = self.session.query(Article).filter(Article.id == result.data['createArticle']['id']).one()
        self.assertEqual(created.title, title)
        self.assertEqual(created.body, body)
        self.assertFalse(created.published)
