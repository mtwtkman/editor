from tests.base import BaseTestCase, fixture
from edt.schemas import Article
from edt.models import Article as ArticleModel


class TestQuery(fixture, BaseTestCase):
    def setUp(self):
        super().setUp()
        self.insert()

    def _callFUT(self, q):
        from edt.schemas import schema as testFunc
        return testFunc.execute(q)

    def test_articles(self):
        expected = [x[0] for x in self.session.query(ArticleModel.title).all()]
        result = self._callFUT('query { articles { title }}')
        subject = [x['title'] for x in result.data['articles']]
        self.assertEqual(subject, expected)

    def test_hoge(self):
        id_ = self.session.query(ArticleModel.id).first()[0]
        query = f'''
        query Hoge {{
            hoge(id: {id_}) {{
                title
            }}
        }}
        '''
        result = self._callFUT(query)

        import pdb; pdb.set_trace()

        self.assertEqual(1, 1)
