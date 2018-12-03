from graphene import ObjectType, Schema, List, Field, Int
from graphene_sqlalchemy import SQLAlchemyObjectType

from . import models


class Article(SQLAlchemyObjectType):
    class Meta:
        model = models.Article


class Tag(SQLAlchemyObjectType):
    class Meta:
        model = models.Tag


class Query(ObjectType):
    articles = List(Article)
    tags = List(Tag)
    hoge = Field(Article, id=Int())

    def resolve_articles(self, info):
        query = Article.get_query(info)
        return query.all()

    def resolve_hoge(self, info, id):
        query = Article.get_query(info)
        return query.filter(models.Article.id==id).one()

schema = Schema(query=Query)
