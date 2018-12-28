from sqlalchemy.sql.expression import desc
from graphene import ObjectType, List, Int, Mutation

from .. import models
from . import session
from .type import Article, ArticleInput, TagInput


def traverse(tags):
    for t in tags:
        tag = session.query(models.Tag) \
            .filter(models.Tag.name == t['name']) \
            .first() or models.Tag(**t)
        if tag not in session:
            session.add(tag)
            session.flush()
        yield tag


class ArticleOutput:
    Output = Article


class CreateArticle(ArticleOutput, Mutation):
    class Arguments:
        article = ArticleInput(required=True)
        tags = List(TagInput)

    def mutate(source, info, article, tags=None):
        data = models.Article(**article)
        if tags:
            data.tags = list(traverse(tags))
        session.add(data)
        return session.query(models.Article) \
            .order_by(desc(models.Article.id)).first()


class UpdateArticle(ArticleOutput, Mutation):
    class Arguments:
        id = Int(required=True)
        article = ArticleInput(required=True)
        tags = List(TagInput)

    def mutate(source, info, id_, article, tags=None):

        import pdb; pdb.set_trace()

        print(0)


class Mutation(ObjectType):
    create_article = CreateArticle.Field()
    update_article = UpdateArticle.Field()
