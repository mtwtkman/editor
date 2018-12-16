from sqlalchemy.sql.expression import desc
import graphene
from graphene import ObjectType, List

from .. import models
from . import session
from .type import Article, ArticleInput, TagInput


class ArticleMutationBase(graphene.Mutation):
    class Arguments:
        article = ArticleInput(required=True)
        tags = List(TagInput)

    Output = Article

    def mutate(source, info, article, tags=None):
        data = source.data_factory(article)
        if tags:
            data.tags = list(source.traverse(tags))
        session.add(data)
        return source.fetch_one()

    @staticmethod
    def data_factory(article):
        raise NotImplementedError

    @staticmethod
    def fetch_one():
        raise NotImplementedError

    @staticmethod
    def traverse(tags):
        for t in tags:
            tag = session.query(models.Tag) \
                .filter(models.Tag.name == t['name']) \
                .first() or models.Tag(**t)
            if tag not in session:
                session.add(tag)
                session.flush()
            yield tag


class CreateArticle(ArticleMutationBase):
    @staticmethod
    def data_factory(article):
        return models.Article(**article)

    @staticmethod
    def fetch_one():
        return session.query(models.Article) \
            .order_by(desc(models.Article.id)).first()


class UpdateArticle(ArticleMutationBase):
    def mutate(self, info, article, tags=None):
        tag_data = []


class Mutation(ObjectType):
    create_article = CreateArticle.Field()
    update_article = UpdateArticle.Field()
