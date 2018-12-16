from tests.base import BaseTestCase
from edt.models import Article, Tag
from tests.schema.base import CallFunc


class TestUpdateArticle(CallFunc, BaseTestCase):
    meth = 'updateArticle'

    from edt.schema.mutation import UpdateArticle
    root_cls = UpdateArticle

    def setUp(self):
        self.tag = Tag(name='tag1')
        self.session.add(self.tag)
        self.without_tag = Article(title='hoge', body='fuga')
        self.with_tag = Article(title='foo', body='bar')
        self.with_tag.tags.append(self.tag)
        self.session.add_all([self.without_tag, self.with_tag])
        self.session.flush()

    def test_update_title_for_without_tag_article(self):
        title = f'{self.without_tag.title} - x'
        target_id = self.without_tag.id
        result = self._callFUT(self.q(id_=target_id, title=title))
        subject = result[self.meth]
        updated = self.session.query(Article) \
            .filter(Article.id == target_id).one()
        expected = {
            'title': title,
            'body': self.without_tag.body,
            'published': self.without_tag.published,
            'tags': self.without_tag.tags,
        }
        for i in ['title', 'body', 'published', 'tags']:
            e = expected[i]
            self.assertEqual(subject[i], e)
            self.assertEqual(updated[i], e)
