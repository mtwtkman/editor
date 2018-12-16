from tests.base import BaseTestCase
from edt.models import Article, Tag
from tests.schema.base import CallFunc


def parameterize(meth):
    def _inner(self, *args, **kwargs):
        (prop_name, target_name) = meth.__name__.split('__')[1:]
        target = getattr(self, target_name)
        prop = getattr(target, prop_name)
        edited_prop = meth(self, prop)
        result = self._callFUT(
            self.q(id_=target.id, **{prop_name: edited_prop})
        )
        subject = result[self.meth]
        updated = self.session.query(Article) \
            .filter(Article.id == target.id).one()
        for x in (subject, updated):
            self.assertEqual(x[prop_name], edited_prop)
    return _inner


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

    @parameterize
    def test_update__title__without_tag(self, prop):
        return f'{prop} -x'

    @parameterize
    def test_update__body__without_tag(self, prop):
        return f'{prop} -x'

    @parameterize
    def test_update__published__without_tag(self, prop):
        return not prop
