from graphene_sqlalchemy import SQLAlchemyObjectType
from graphene import String, Boolean, InputObjectType

from .. import models


class Article(SQLAlchemyObjectType):
    class Meta:
        model = models.Article


class Tag(SQLAlchemyObjectType):
    class Meta:
        model = models.Tag


class TagInput(InputObjectType):
    name = String(required=True)


class ArticleInput(InputObjectType):
    title = String(required=True)
    body = String(required=True)
    published = Boolean()
