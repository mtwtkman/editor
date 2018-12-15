from sqlalchemy.sql.expression import desc
import graphene
from graphene import (
    ObjectType, Schema, List, Field, Int,
    String, InputObjectType, Boolean,
)
from graphene_sqlalchemy import SQLAlchemyObjectType

from . import models


session = models.DBSession


class Article(SQLAlchemyObjectType):
    class Meta:
        model = models.Article


class Tag(SQLAlchemyObjectType):
    class Meta:
        model = models.Tag


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


class TagInput(InputObjectType):
    name = String(required=True)


class ArticleInput(InputObjectType):
    title = String(required=True)
    body = String(required=True)
    published = Boolean()


class CreateArticle(graphene.Mutation):
    class Arguments:
        article = ArticleInput(required=True)
        tags = List(TagInput)

    Output = Article

    def mutate(self, info, article, tags=None):
        tag_data = []
        for t in tags or []:
            tag = session.query(models.Tag) \
                .filter(models.Tag.name == t['name']) \
                .first() or models.Tag(**t)
            if tag not in session:
                session.add(tag)
                session.flush()
            tag_data.append(tag)
        data = models.Article(**article)
        data.tags = tag_data
        session.add(data)
        created = session.query(models.Article) \
            .order_by(desc(models.Article.id)).first()
        return created


class Mutation(ObjectType):
    create_article = CreateArticle.Field()


schema = Schema(query=Query, mutation=Mutation)
