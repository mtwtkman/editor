from datetime import datetime

from factory.alchemy import SQLAlchemyModelFactory

from edt.models import Article, Tag, Tagging


class ArticleFactory(SQLAlchemyModelFactory):
    title = factory.Sequence(lambda n: f'article{n}')
    body = factory.Sequence(lambda n: f'body{n}')
    published = True
    created_at = factory.LazyFunction(datetime.now)
    updated_at = factory.LazyFunction(datetime.now)

    class Meta:
        model = Article


class TagFactory(SQLAlchemyModelFactory):
    name = factory.Sequence(lambda n: f'tag{n}')

    class Meta:
        model = Tag


class TaggingFactory(SQLAlchemyModelFactory):
    article = factory.Subfactory(ArticleFactory)

    class Meta:
        model = Tagging
