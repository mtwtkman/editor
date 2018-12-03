from datetime import datetime

from pyramid.security import Allow, Everyone
from sqlalchemy import (
    Column,
    Integer,
    Text,
    Boolean,
    ColumnDefault,
    TIMESTAMP,
    String,
    ForeignKey,
    Table,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import scoped_session, sessionmaker, relationship
from zope.sqlalchemy import ZopeTransactionExtension


DBSession = scoped_session(
    sessionmaker(extension=ZopeTransactionExtension())
)
Base = declarative_base()
Base.query = DBSession.query_property()


taggings = Table(
    'taggings',
    Base.metadata,
    Column('id', Integer, primary_key=True),
    Column('article_id', Integer, ForeignKey('articles.id'), nullable=False),
    Column('tag_name', Integer, ForeignKey('tags.name'), nullable=False),
)


class Article(Base):
    __tablename__ = 'articles'
    sqlite_autoincrement = True
    id = Column(Integer, primary_key=True)
    title = Column(Text, nullable=False)
    body = Column(Text, nullable=False)
    published = Column(Boolean, nullable=False, default=ColumnDefault(False))
    created_at = Column(TIMESTAMP, default=datetime.now, nullable=False)
    updated_at = Column(TIMESTAMP, default=datetime.now, nullable=False)

    tags = relationship('Tag', secondary=taggings, backref='tags')


class Tag(Base):
    __tablename__ = 'tags'
    name = Column(String, primary_key=True)

    articles = relationship('Article', secondary=taggings, backref='articles')
