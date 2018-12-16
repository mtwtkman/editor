from graphene import Schema

from ..models import DBSession


session = DBSession


from .query import Query  # noqa
from .mutation import Mutation  # noqa


schema = Schema(query=Query, mutation=Mutation)
