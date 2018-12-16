from graphene import ObjectType, List, Field, Int, String

from .. import models
from .type import Article, Tag


class Query(ObjectType):
    articles = List(Article)
    tags = List(Tag)
    article = Field(Article, id=Int())
    tag = Field(Tag, name=String())

    def resolve_articles(self, info):
        query = Article.get_query(info)
        return query.all()

    def resolve_tags(self, info):
        query = Tag.get_query(info)
        return query.all()

    def resolve_article(self, info, id):
        query = Article.get_query(info)
        return query.filter(models.Article.id == id).one()

    def resolve_tag(self, info, name):
        query = Tag.get_query(info)
        return query.filter(models.Tag.name == name).one()
