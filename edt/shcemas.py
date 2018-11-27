from graphene import Field
from graphene_sqlalchemy import SQLAlchemyObjectType

from . import models


class Article(SQLAlchemyObjectType):
    class Meta:
        model = models.Article


class ArticleQuery(graphene.ObjectType):
    article = Field(Article)

    def resolve_article
